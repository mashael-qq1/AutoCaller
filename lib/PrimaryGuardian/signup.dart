// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:autocaller/PrimaryGuardian/PGHomePage.dart';
import 'package:autocaller/PrimaryGuardian/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:autocaller/SchoolAdmin/NavBarAdmin.dart';
import 'package:autocaller/SchoolAdmin/AdminHomePage.dart';

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
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isPassword = false,
    bool isConfirmPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword
          ? (isConfirmPassword
              ? !_isConfirmPasswordVisible
              : !_isPasswordVisible)
          : false,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide.none,
          
        ),
          focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(40),
        borderSide: BorderSide.none,
      ),
      labelStyle: TextStyle(
        color: Color(0xFF57636C), // Keep label gray
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

  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _hasMinLength = false;
  final FocusNode _passwordFocusNode = FocusNode();

  void _updatePasswordValidation(String password) {
    setState(() {
      _hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
      _hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
      _hasNumber = RegExp(r'\d').hasMatch(password);
      _hasSpecialChar = RegExp(r'[\W_]').hasMatch(password);
      _hasMinLength = password.length >= 8;
    });
  }

  Widget _buildPasswordRequirement(String text, bool isMet) {
    return Row(
      children: [
        Icon(Icons.check_circle,
            color: isMet ? Colors.blue : Color(0xFF57636C), size: 16),
        SizedBox(width: 6),
        Text(text, style: TextStyle(color: isMet ? Colors.blue :  Color(0xFF57636C))),
      ],
    );
  }

  Widget _buildPasswordField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        controller: _passwordController,
        focusNode: _passwordFocusNode, // Attach the FocusNode
        obscureText: !_isPasswordVisible,
        onChanged: _updatePasswordValidation,
        onTap: () {
          setState(() {
            // Update the visibility of password requirements when tapped
            _isPasswordVisible = true;
          });
        },
        decoration: InputDecoration(
          labelText: "Password",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide.none,
          ),
          labelStyle: TextStyle(
            color: Color(0xFF57636C), // Keep label gray
          ),
          suffixIcon: IconButton(
            icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
      ),
      // Show password requirements only when the field is focused
      if (_passwordFocusNode.hasFocus) ...[
        SizedBox(height: 8),
        _buildPasswordRequirement("At least 8 characters", _hasMinLength),
        _buildPasswordRequirement("At least one uppercase letter", _hasUpperCase),
        _buildPasswordRequirement("At least one lowercase letter", _hasLowerCase),
        _buildPasswordRequirement("At least one number", _hasNumber),
        _buildPasswordRequirement("At least one special character", _hasSpecialChar),
      ],
    ],
  );
}
  // Validation functions
  bool _isValidName(String name) {
    return RegExp(r'^(?!.*\s{3,})[a-zA-Z\s]{3,}$').hasMatch(name);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^05\d{8}$').hasMatch(phone); // Starts with 05 & 10 digits
  }

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

      _showSuccessMessage("Signed up Successfully!");
      _clearFormFields();
       Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => GuardianHomePage()), // Replace with your homepage widget
    );
    } catch (e) {
      _showError("Failed to add guardian: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _clearFormFields() {
    _fullNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF), // Pure white at the top
              Color.fromARGB(255, 255, 255, 255), // Light blue transition
              Color.fromARGB(255, 96, 178, 245), // Deeper blue at the bottom
            ],
            stops: [0.0, 0.2, 1.0], // Adjust stops to give white more space
            begin: Alignment.topCenter,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Keeps the width consistent
            child: Column(
              children: [
                // Logo Image right below the back button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.asset(
                    'assets/9-removebg-preview.png', // Replace with the actual path to your logo image
                    height: 150, // Set the height of the logo
                    width: 110,  // Set the width of the logo
                    fit: BoxFit.contain, // Adjust the image size without distortion
                  ),
                ),
                SizedBox(height: 0), // To add space between the logo and form
               // Align the "Get Started" text to the left
                Align(
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                
                // Align the description text to the left
                Align(
                  child: Text(
                    'Use the form below to get started.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF57636C)),
                  ),
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
                _buildPasswordField(),
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
                        : const Text('Sign up ',
                            style:
                                TextStyle(fontSize: 14, color: Colors.white)),
                  ),
                ),
              SizedBox(height: 30),
RichText(
  text: TextSpan(
    style: TextStyle(
      fontSize: 14,
      color: Color(0xFF57636C),
    ),
    children: [
      TextSpan(
        text: 'Already have an account? ',
         style: TextStyle(
          color: const Color.fromARGB(255, 0, 0, 0),
        
        ),
      ),
      TextSpan(
        text: 'login',
        style: TextStyle(
          color: const Color.fromARGB(255, 0, 0, 0),
         fontWeight:FontWeight.w700 ,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GuardianLoginPage(),
              ),
            );
          },
      ),
    ],
  ),
),
SizedBox(height: 100),


              ],
            ),
          ),
        ),
      ),
    ),
   
  );
}
}