// ignore_for_file: prefer_const_constructors

import 'package:autocaller/PrimaryGuardian/login.dart';
// ignore: unused_import
import 'package:autocaller/PrimaryGuardian/signup.dart';
import 'package:autocaller/SchoolAdmin/login.dart';
import 'package:flutter/material.dart';
//import 'SchoolAdmin/login.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo

            Image.asset(
              'assets/9-removebg-preview.png', // Replace with the path to your logo image
              height: 200.0, // Increase the height for a larger image
              width: 200.0, // You can also set the width for more control
            ),

            // Welcome Text
            const Text(
              'Welcome to AutoCaller',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004AAD),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Your partner in creating a seamless and secure\n'
              'dismissal experience for students',
              style: TextStyle(
                fontSize: 16.0,
                color: Color.fromARGB(95, 22, 101, 154),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30.0),
            const Text(
              'Sign in as',
              style: TextStyle(
                fontSize: 40.0,
                color: Color(0xFF004AAD),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30.0),
            // Buttons
            SizedBox(
              width: 300.0, // Explicit width
              height: 55.0, // Explicit height
              child: ElevatedButton(
                onPressed: () {
                  // Action for Guardian button
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GuardianLoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Background color
                  padding: const EdgeInsets.symmetric(
                      horizontal: 60.0, vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text(
                  'Guardian',
                  style: TextStyle(
                      fontSize: 18.0, color: Color.fromRGBO(255, 255, 255, 1)),
                ),
              ),
            ),
            const SizedBox(height: 15.0),
            SizedBox(
              width: 300.0, // Explicit width
              height: 55.0, // Explicit height
              child: ElevatedButton(
                onPressed: () {
                  // Action for School Admin button
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SchoolAdminLoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Background color
                  padding: const EdgeInsets.symmetric(
                      horizontal: 60.0, vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text(
                  'School Admin',
                  style: TextStyle(
                      fontSize: 18.0, color: Color.fromRGBO(255, 255, 255, 1)),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
