// lib/PrimaryGuardian/signup.dart
// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:autocaller/PrimaryGuardian/login.dart';
import 'package:autocaller/PrimaryGuardian/PGHomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PrimaryGuardianSignUpPage extends StatefulWidget {
  const PrimaryGuardianSignUpPage({super.key});

  @override
  State<PrimaryGuardianSignUpPage> createState() =>
      _PrimaryGuardianSignUpPageState();
}

class _PrimaryGuardianSignUpPageState
    extends State<PrimaryGuardianSignUpPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  bool _isValidPhone(String phone) =>
      RegExp(r'^05\d{8}$').hasMatch(phone.trim());

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(email.trim());

  Future<void> _signUpGuardian() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (fullName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage("Please fill in all fields.", isError: true);
      return;
    }

    if (!_isValidPhone(phone)) {
      _showMessage("Phone must start with '05' and be 10 digits.",
          isError: true);
      return;
    }

    if (!_isValidEmail(email)) {
      _showMessage("Invalid email format.", isError: true);
      return;
    }

    if (password != confirmPassword) {
      _showMessage("Passwords do not match.", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await _firestore
          .collection('Primary Guardian')
          .doc(userCredential.user!.uid)
          .set({
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'userId': userCredential.user!.uid,
      });

      _showMessage("Registration Successful!");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GuardianHomePage()),
      );
    } catch (e) {
      _showMessage("Registration Failed: ${e.toString()}", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.blue,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isPassword = false, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 40),
                Image.asset('assets/9-removebg-preview.png', height: 150),
                SizedBox(height: 20),
                Text("Get Started",
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                _buildTextField(_fullNameController, "Full Name"),
                SizedBox(height: 16),
                _buildTextField(_emailController, "Email",
                    keyboardType: TextInputType.emailAddress),
                SizedBox(height: 16),
                _buildTextField(_phoneController, "Phone Number",
                    keyboardType: TextInputType.phone),
                SizedBox(height: 16),
                _buildTextField(_passwordController, "Password",
                    isPassword: true),
                SizedBox(height: 16),
                _buildTextField(_confirmPasswordController, "Confirm Password",
                    isPassword: true),
                SizedBox(height: 24),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUpGuardian,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF23a8ff),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Sign Up"),
                  ),
                ),
                SizedBox(height: 24),
                RichText(
                  text: TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                            text: "Login",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            GuardianLoginPage()));
                              })
                      ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}