// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PrimaryGuardianSignUpPage extends StatefulWidget {
  const PrimaryGuardianSignUpPage({super.key});

  @override
  _PrimaryGuardianSignUpPageState createState() =>
      _PrimaryGuardianSignUpPageState();
}

class _PrimaryGuardianSignUpPageState extends State<PrimaryGuardianSignUpPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  /// Validation Functions
  bool _isValidName(String name) {
    return RegExp(r'^[a-zA-Z\s]{3,}$').hasMatch(name);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^05\d{8}$').hasMatch(phone); // Starts with 05 & 10 digits
  }

  bool _isValidPassword(String password) {
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$')
        .hasMatch(password); // Password rules
  }

  /// Function to handle guardian sign-up (used for adding guardian)
  void _signUpGuardian() async {
    String fullName = _fullNameController.text.trim();
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (fullName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showError("Please fill in all fields.");
      return;
    }

    if (!_isValidName(fullName)) {
      _showError(
          "Full name should be at least 3 characters and contain only letters.");
      return;
    }
    if (!_isValidEmail(email)) {
      _showError("Please enter a valid email address.");
      return;
    }
    if (!_isValidPhone(phone)) {
      _showError("Phone number must start with '05' and be 10 digits.");
      return;
    }
    if (!_isValidPassword(password)) {
      _showError(
          "Password must be at least 8 characters, include uppercase, lowercase, number, and special character.");
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
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _firestore
          .collection('Primary Guardian')
          .doc(userCredential.user!.uid)
          .set({
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'userId': userCredential.user!.uid,
      });

      _showSuccessMessage("Guardian Added Successfully!");
      _clearFormFields();
    } catch (e) {
      _showError("Failed to add guardian: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Shows a Success Message
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue, // Blue color for success message
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Clears all form fields after successful guardian addition
  void _clearFormFields() {
    _fullNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  /// Display error messages
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Reusable TextField widget with eye icon for password fields
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isPassword = false,
    bool isConfirmPassword = false,
    TextInputType keyboardType = TextInputType.text, // Add this parameter
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword
          ? (isConfirmPassword
              ? !_isConfirmPasswordVisible
              : !_isPasswordVisible)
          : false,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isConfirmPassword
                      ? (_isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off)
                      : (_isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                ),
                onPressed: () {
                  setState(() {
                    if (isConfirmPassword) {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    } else {
                      _isPasswordVisible = !_isPasswordVisible;
                    }
                  });
                },
              )
            : null,
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
                    Image.asset('assets/9-removebg-preview.png', height: 100),
                    SizedBox(height: 16),
                    Text(
                      'Add Guardian',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Enter the guardian’s details below.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF57636C)),
                    ),
                    SizedBox(height: 24),
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
                    _buildTextField(
                        _confirmPasswordController, "Confirm Password",
                        isPassword: true, isConfirmPassword: true),
                    SizedBox(height: 24),
                    SizedBox(
                      width: 150,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signUpGuardian,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF23a8ff),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40)),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : const Text('Add Guardian',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                      ),
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
}
