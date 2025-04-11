// ignore_for_file: prefer_const_constructors

import 'package:autocaller/firstPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

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
  runApp(const MyApp());
}
// Function to request location permissions
Future<void> requestPermissions() async {
  LocationPermission permission = await Geolocator.requestPermission();

  if (permission == LocationPermission.denied) {
    print("❌ Location permission denied");
  } else if (permission == LocationPermission.deniedForever) {
    print("❌ Location permissions are permanently denied. Enable them from app settings.");
  } else {
    print("✅ Location permission granted");
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable the debug banner
      home: Scaffold(
        body: WelcomeScreen(), // Set WelcomeScreen as the home screen
      ),
    );
  }
}