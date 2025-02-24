// ignore_for_file: prefer_const_constructors
import 'package:autocaller/SecondaryGuardian/login.dart';  // ✅ Import Secondary Guardian Login
import 'package:autocaller/PrimaryGuardian/login.dart';
import 'package:autocaller/SchoolAdmin/login.dart';
import 'package:flutter/material.dart';

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
            colors: [
              Color(0xFFFFFFFF), // Pure white at the top
              Color.fromARGB(255, 255, 255, 255), // Light blue transition
              Color.fromARGB(255, 96, 178, 245), // Deeper blue at the bottom
            ],
            stops: [0.0, 0.3, 1.0], 
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔹 App Logo
            Image.asset(
              'assets/9-removebg-preview.png', 
              height: 200.0,
              width: 200.0,
            ),
            const SizedBox(height: 20.0),

            // 🔹 Welcome Text
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

            // 🔹 "Sign in as" Title
            const Text(
              'Sign in as',
              style: TextStyle(
                fontSize: 40.0,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30.0),

            // 🔹 Guardian Button
            _buildLoginButton(context, 'Guardian', Colors.blue, GuardianLoginPage()),

            const SizedBox(height: 15.0),

            // 🔹 School Admin Button
            _buildLoginButton(context, 'School Admin', Colors.blue, SchoolAdminLoginPage()),

            const SizedBox(height: 15.0),

            // 🔹 Secondary Guardian Button (✅ FIXED ✅)
            _buildLoginButton(context, 'Secondary Guardian', Colors.blue, SecondaryGuardianLoginPage()),

            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  // 🔹 Function to Create a Styled Button
  Widget _buildLoginButton(BuildContext context, String title, Color color, Widget page) {
    return SizedBox(
      width: 300.0,
      height: 55.0,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        ),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18.0, color: Colors.white),
        ),
      ),
    );
  }
}
