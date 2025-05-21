// lib/main.dart
// ignore_for_file: prefer_const_constructors

import 'package:autocaller/firstPage.dart';
import 'package:autocaller/SecondaryGuardian/RegisterSG.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:autocaller/SchoolAdmin/StudentPickupList.dart';
import 'GeofenceManager.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📩 Background Notification Received: ${message.notification?.title}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAzoP9b--fAARxjc8QbG6km5Yuy3Bzrg-k",
        authDomain: "autocaller-196cc.firebaseapp.com",
        projectId: "autocaller-196cc",
        storageBucket: "autocaller-196cc.firebasestorage.app",
        messagingSenderId: "132580101106",
        appId: "1:132580101106:web:46fcaedc08f6f8a82cb96b",
      ),
    );

 
  } else {
    // Initialize Firebase for mobile platforms
    await Firebase.initializeApp();

    await requestPermissions();
    GeofenceManager.startGeofenceMonitoring();
  }
  await _initLocalNotification();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  String? fcmToken = await FirebaseMessaging.instance.getToken();
  print('🔥 My FCM Token: $fcmToken');

  runApp(MyApp());
}

Future<void> requestPermissions() async {
  await Geolocator.requestPermission();
// Request location permission on mobile
  LocationPermission permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied) {
    print("❌ Location permission denied");
  } else if (permission == LocationPermission.deniedForever) {
    print(
        "❌ Location permissions are permanently denied. Enable them from app settings.");
  } else {
    print("✅ Location permission granted");
  }
  NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('✅ User granted notification permission');
  } else {
    print('❌ User denied notification permission');
  }
}

Future<void> _initLocalNotification() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
      InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Handle Notification when App is in Foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
          ),
        ),
      );
    }
  });

  // Handle Token Auto Refresh
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    print('🔁 Auto Refreshed FCM Token: $newToken');
    // Optional: Update Firestore here if user is logged in
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      requestPermissions();
      _handleDynamicLinks();
    }
  }

  void _handleDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink.listen((PendingDynamicLinkData data) {
      _handleDeepLink(data);
    });

    final initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      _handleDeepLink(initialLink);
    }
  }

  void _handleDeepLink(PendingDynamicLinkData data) {
    final Uri deepLink = data.link;
    final guardianId = deepLink.queryParameters['guardianId'];
    final studentId = deepLink.queryParameters['studentId'];

    if (guardianId != null && studentId != null) {
      final studentIDList = studentId.split(',');
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => RegisterSecondaryGuardianPage(
            primaryGuardianID: guardianId,
            studentIDs: studentIDList,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: kIsWeb ? StudentPickupList() : WelcomeScreen(),
    );
  }
}
