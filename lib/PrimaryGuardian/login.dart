// lib/PrimaryGuardian/login.dart
// ignore_for_file: prefer_const_constructors

import 'package:autocaller/PrimaryGuardian/signup.dart';
import 'package:autocaller/firstPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '/SchoolAdmin/ResetPassword.dart';
import '/PrimaryGuardian/PGHomePage.dart';

class GuardianLoginPage extends StatefulWidget {
  const GuardianLoginPage({super.key});

  @override
  State<GuardianLoginPage> createState() => _GuardianLoginPageState();
}

class _GuardianLoginPageState extends State<GuardianLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _loginGuardian() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Please enter both email and password.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;
      print('🔥 Logged in User ID: $userId');

      final guardianSnapshot = await _firestore
          .collection('Primary Guardian')
          .doc(userId)
          .get();

      print('📦 Document Exists in Firestore: ${guardianSnapshot.exists}');

      if (!guardianSnapshot.exists) {
        _showError("This account is not authorized as a Primary Guardian.");
        await _auth.signOut();
        return;
      }

      // Try to get FCM Token
      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
        print('🔔 Retrieved FCM Token: $fcmToken');
      } catch (e) {
        print('⚠️ Could not get FCM Token: $e');
      }

      if (fcmToken != null) {
        await _firestore.collection('Primary Guardian').doc(userId).update({
          'fcmToken': fcmToken,
        });
        print("✅ FCM Token saved successfully.");
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        await _firestore.collection('Primary Guardian').doc(userId).update({
          'fcmToken': newToken,
        });
        print('🔁 Auto Refreshed Token Saved: $newToken');
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GuardianHomePage()),
      );
    } catch (e) {
      print('❌ Login Error: $e');
      _showError("Login failed. Please check your credentials.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFFFFFFF),
              Color.fromARGB(255, 96, 178, 245),
            ],
            stops: [0.0, 0.3, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                SizedBox(height: 80),
                Image.asset('assets/9-removebg-preview.png', height: 150),
                SizedBox(height: 10),
                Text('Welcome Back!',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                Text('Use the form below to access your account.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF57636C))),
                SizedBox(height: 24),

                _buildTextField(_emailController, "Email"),
                SizedBox(height: 16),
                _buildTextField(_passwordController, "Password", isPassword: true),
                SizedBox(height: 16),

                _buildActions(),
                SizedBox(height: 32),
                _buildSignUpText(),
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? !_isPasswordVisible : false,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF57636C)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ResetPasswordPage()));
          },
          child: Text('Forgot Password?',
              style: TextStyle(fontSize: 14, color: Color(0xFF57636C))),
        ),
        SizedBox(
          width: 130,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _loginGuardian,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF23a8ff),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
            ),
            child: _isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text('Sign In',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpText() {
    return RichText(
      text: TextSpan(
        text: "Don't have an account? ",
        style: TextStyle(fontSize: 14, color: Colors.black),
        children: [
          TextSpan(
            text: "Create one",
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PrimaryGuardianSignUpPage()),
                );
              },
          ),
        ],
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