// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:autocaller/ResetPassword.dart';
import 'package:flutter/material.dart';

class SchoolAdminLoginPage extends StatefulWidget {
  @override
  _SchoolAdminLoginPageState createState() => _SchoolAdminLoginPageState();
}

class _SchoolAdminLoginPageState extends State<SchoolAdminLoginPage> {
  // Controllers for email and password
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE3F2FD), // Light Blue
              Color(0xFF90CAF9), // Medium Blue
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/logo.png', // Replace with your logo path
                  height: 100,
                ),
                const SizedBox(height: 16),

                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: Colors.black, // Custom blue color
                  ),
                ),
                const SizedBox(height: 8), // Add spacing between the texts
                const Text(
                  'Use ythe form below to access your account.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFF57636C), // Custom blue color
                  ),
                ),

                const SizedBox(height: 24),

                // Email TextField
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(
                      color: Color(0xFF57636C), // Label color
                      fontSize: 14, // Label font size
                    ),
                    hintText: 'Enter your email here',
                    hintStyle: TextStyle(
                      color: Colors.grey, // Hint text color
                      fontSize: 14, // Hint text font size
                      fontStyle: FontStyle.italic, // Hint text style
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password TextField
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(
                      color: Color(0xFF57636C), // Label color
                      fontSize: 14, // Label font size
                    ),
                    hintText: 'Enter your password here',
                    hintStyle: TextStyle(
                      color: Colors.grey, // Hint text color
                      fontSize: 14, // Hint text font size
                      fontStyle: FontStyle.italic, // Hint text style
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Adjust alignment
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Handle forgot password action
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF57636C),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 130,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle sign-in action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF23a8ff),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Create Account Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Handle create account action
                      },
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
