import 'package:autocaller/SecondaryGuardian/SGhome.dart';
import 'package:autocaller/firstPage.dart';
import 'package:autocaller/SchoolAdmin/ResetPassword.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SecondaryGuardianLoginPage extends StatefulWidget {
  const SecondaryGuardianLoginPage({super.key});

  @override
  _SecondaryGuardianLoginPageState createState() =>
      _SecondaryGuardianLoginPageState();
}

class _SecondaryGuardianLoginPageState
    extends State<SecondaryGuardianLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  void _loginSecondaryGuardian() async {
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
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      DocumentSnapshot guardianSnapshot =
          await _firestore.collection('Secondary Guardian').doc(uid).get();

      if (guardianSnapshot.exists) {
  if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text("Login Success!", style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.green,
            ),
          );
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SGhome(loggedInGuardianId: uid),
          ),
        );
      } else {
        _showError("This account is not authorized as a secondary guardian.");
        await _auth.signOut();
      }
    } catch (e) {
      _showError("Login failed, incorrect credentials.");
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 96, 178, 245),
            ],
            stops: [0.0, 0.3, 1.0],
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WelcomeScreen()),
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
                      Image.asset('assets/9-removebg-preview.png', height: 150),
                      const SizedBox(height: 10),
                      const Text(
                        'Welcome Back! ',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                     Center(
  child: const Text(
    'Use the form below to access your account as Secondary Guardian .',
    style: TextStyle(fontSize: 14, color: Color(0xFF57636C)),
    textAlign: TextAlign.center, // Ensures the text is centered
  ),
),
                      const SizedBox(height: 24),

                      // Email Input Field
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: const TextStyle(color: Color(0xFF57636C)),
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
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: const TextStyle(color: Color(0xFF57636C)),
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
                                        const ResetPasswordPage()),
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xFF57636C)),
                            ),
                          ),
                          SizedBox(
                            width: 130,
                            height: 50,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading ? null : _loginSecondaryGuardian,
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
                    ],
                  ),
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