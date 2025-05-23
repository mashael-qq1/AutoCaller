import 'package:autocaller/PrimaryGuardian/signup.dart';
import 'package:autocaller/firstPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '/SchoolAdmin/ResetPassword.dart';
import '/PrimaryGuardian/PGHomePage.dart';

class GuardianLoginPage extends StatefulWidget {
  const GuardianLoginPage({super.key});

  @override
  _GuardianLoginPageState createState() => _GuardianLoginPageState();
}

class _GuardianLoginPageState extends State<GuardianLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  void _loginGuardian() async {
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
      // Attempt to sign in with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if the user is a guardian by querying the Firestore database
      DocumentSnapshot guardianSnapshot = await _firestore
          .collection('Primary Guardian')
          .doc(userCredential.user!.uid)
          .get();

      if (guardianSnapshot.exists) {
        // Show success message first
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text("Login Success!", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );

        // Wait for a short moment to let the user read it (optional but nice UX)
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate to the home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GuardianHomePage()),
        );
      } else {
        _showError("This account is not authorized as a guardian.");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF), // Pure white at the top
              Color.fromARGB(255, 255, 255, 255), // Light blue transition
              Color.fromARGB(255, 96, 178, 245), // Deeper blue at the bottom
            ],
            stops: [0.0, 0.3, 1.0], // Adjust stops to give white more space
            begin: Alignment.topCenter,
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
                onPressed: () {
                  // Navigate to the first page (e.g., HomePage or any specific page)
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const WelcomeScreen(), // Replace with your first page widget
                    ),
                  );
                },
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/9-removebg-preview.png',
                        height: 150,
                      ),

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
    'Use the form below to access your account as primary guardian.',
    style: TextStyle(fontSize: 14, color: Color(0xFF57636C)),
    textAlign: TextAlign.center, // Ensures the text is centered
  ),
),
                      const SizedBox(height: 24),

                      // Email Input Field
                      TextField(
                        key: Key('emailField'),
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
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

                      // Password Input Field
                      TextField(
                        key: Key('passwordField'),
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

                      // Forgot Password and Sign In Button
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
                                    fontSize: 14, color: Color(0xFF57636C),decoration: TextDecoration.underline,)),
                          ),
                          SizedBox(
                            width: 130,
                            height: 50,
                            child: ElevatedButton(
                              key: Key('signInButton'),
                              onPressed: _isLoading ? null : _loginGuardian,
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
                      const SizedBox(height: 32),
                      RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: const TextStyle(
                            fontSize: 14,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                          children: [
                            TextSpan(
                              text: "Create one",
                              style: const TextStyle(
                                fontSize: 14,
                                color: const Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.w700,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const PrimaryGuardianSignUpPage(),
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),

                      // Give space before the bottom
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