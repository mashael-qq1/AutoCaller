import 'package:autocaller/SchoolAdmin/SchoolProfile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/SchoolAdmin/ResetPassword.dart';
import '/SchoolAdmin/AdminHomePage.dart';

class SchoolAdminLoginPage extends StatefulWidget {
  const SchoolAdminLoginPage({super.key});

  @override
  _SchoolAdminLoginPageState createState() => _SchoolAdminLoginPageState();
}

class _SchoolAdminLoginPageState extends State<SchoolAdminLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  void _loginAdmin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty) {
      _showError("Please enter an email.");
      return;
    }
    if (password.isEmpty) {
      _showError("Please enter a password.");
      return;
    }
    if (email.contains(' ')) {
      _showError("Spaces are not allowed in email.");
      return;
    }
    if (password.contains(' ')) {
      _showError("Spaces are not allowed in passwords.");
      return;
    }
    if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email)) {

      _showError("Please enter a valid email e.g: Autocaller@gmail.com");
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

      DocumentSnapshot adminSnapshot = await _firestore
          .collection('Admin')
          .doc(userCredential.user!.uid)
          .get();

      if (adminSnapshot.exists) {
        _showSuccess("Login Success!");
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SchoolProfilePage()),
        );
      } else {
        _showError("This account is not authorized as an admin.");
        await _auth.signOut();
      }
    } catch (e) {
      _showError("Login failed, the supplied credentials is incorrect.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 96, 178, 245),
            ],
            stops: [0.0, 0.3, 1.0],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 40,
              left: 16,
              child: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: Colors.black, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/9-removebg-preview.png', height: 150),
                      const SizedBox(height: 10),
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      const SizedBox(height: 8),
                     Center(
  child: const Text(
    'Use the form below to access your account as school admin.',
    style: TextStyle(fontSize: 14, color: Color(0xFF57636C)),
    textAlign: TextAlign.center, // Ensures the text is centered
  ),
),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(color: Color(0xFF57636C)),
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
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(color: Color(0xFF57636C)),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ResetPasswordPage()));
                            },
                            child: const Text('Forgot Password?',
                                style: TextStyle(
                                    fontSize: 14, color: Color(0xFF57636C))),
                          ),
                          SizedBox(
                            width: 130,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _loginAdmin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF23a8ff),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40)),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text('Sign In',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
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