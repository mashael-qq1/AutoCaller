// ignore_for_file: prefer_const_constructors

import 'package:autocaller/firstPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
  // Initialize Firebase here
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ignore: prefer_const_constructors
      home: Scaffold(
        // ignore: prefer_const_constructors
        body: WelcomeScreen(), // Use the widget here
      ),
      debugShowCheckedModeBanner: false,
    );}}
