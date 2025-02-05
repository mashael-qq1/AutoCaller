// ignore_for_file: prefer_const_constructors

import 'package:autocaller/PrimaryGuardian/PGHomePage.dart';
import 'package:autocaller/PrimaryGuardian/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PrimaryGuardianSignUpPage extends StatefulWidget {
  const PrimaryGuardianSignUpPage({super.key});

  @override
  _PrimaryGuardianSignUpPageState createState() => _PrimaryGuardianSignUpPageState();
}

class _PrimaryGuardianSignUpPageState extends State<PrimaryGuardianSignUpPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  void _signUpGuardian() async {
    String fullName = _fullNameController.text.trim();
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (fullName.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError("Please fill in all fields.");
      return;
    }

    if (password != confirmPassword) {
      _showError("Passwords do not match.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('Primary Guardian').doc(userCredential.user!.uid).set({
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'userId': userCredential.user!.uid,
      });
Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>GuardianHomePage()),
      );
    } catch (e) {
      _showError("Sign-up failed: ${e.toString()}");
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFF90CAF9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 40,
              left: 16,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/logo.png', height: 100),
                    const SizedBox(height: 16),
                    const Text(
                      'Create Account',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign up to manage your familys tasks.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF57636C)),
                    ),
                    const SizedBox(height: 24),

                    TextField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: 150,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signUpGuardian,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF23a8ff),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : const Text('Sign Up', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                     Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? ", style: TextStyle(fontSize: 14, color: Colors.black)),
                    GestureDetector(
                      onTap: () {
                        // Navigate back or to login screen
                        Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>GuardianLoginPage()),
      );
                      },
                      child: const Text(
                        'Log In',
                        style: TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
