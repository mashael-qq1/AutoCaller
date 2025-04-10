// ignore_for_file: prefer_const_constructors

import 'package:autocaller/firstPage.dart';
import 'package:autocaller/SecondaryGuardian/RegisterSG.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

// Global navigator key for deep linking
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
            appId: "1:132580101106:web:46fcaedc08f6f8a82cb96b"));
  } else {
    await Firebase.initializeApp();
  }

  // Request Location Permissions before running the app
  await requestPermissions();

  runApp(MyApp());
}

// Request Location Permissions
Future<void> requestPermissions() async {
  LocationPermission permission = await Geolocator.requestPermission();

  if (permission == LocationPermission.denied) {
    print("❌ Location permission denied");
  } else if (permission == LocationPermission.deniedForever) {
    print(
        "❌ Location permissions are permanently denied. Enable them from app settings.");
  } else {
    print("✅ Location permission granted");
  }
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
    _handleDynamicLinks();
  }

  // Handle Firebase Dynamic Links
  void _handleDynamicLinks() async {
    // Foreground links
    FirebaseDynamicLinks.instance.onLink.listen((PendingDynamicLinkData data) {
      _handleDeepLink(data);
    });

    // App launched from a terminated state
    final initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      _handleDeepLink(initialLink);
    }
  }

  // Extract link parameters and navigate to the registration page
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
      home: WelcomeScreen(),
    );
  }
}
