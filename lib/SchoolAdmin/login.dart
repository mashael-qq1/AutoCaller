import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/SchoolAdmin/ResetPassword.dart';
import '/SchoolAdmin/AdminHomePage.dart'; // Import your Admin Home Page

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

  void _loginAdmin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Please enter both email and password.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Authenticate with Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if the authenticated user is in the Admin collection
      DocumentSnapshot adminSnapshot =
          await _firestore.collection('Admin').doc(userCredential.user!.uid).get();

      if (adminSnapshot.exists) {
        // Successful login -> Navigate to Admin Home Page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SchoolAdminHomePage()),
        );
      } else {
        _showError("This account is not authorized as an admin.");
        await _auth.signOut(); // Log out the user if not an admin
      }
    } catch (e) {
      _showError("Login failed: ${e.toString()}");
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
                    Image.asset('assets/9-removebg-preview.png', height: 100),
                    const SizedBox(height: 16),
                    const Text(
                      'Welcome Back!',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Use the form below to access your account.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF57636C)),
                    ),
                    const SizedBox(height: 24),

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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordPage()));
                          },
                          child: const Text('Forgot Password?', style: TextStyle(fontSize: 14, color: Color(0xFF57636C))),
                        ),
                        SizedBox(
                          width: 130,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _loginAdmin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF23a8ff),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : const Text('Sign In', style: TextStyle(fontSize: 16, color: Colors.white)),
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
