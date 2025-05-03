import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// The main widget for the Reset Password Page
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

/// The state class that contains the logic and UI for Reset Password Page
class _ResetPasswordPageState extends State<ResetPasswordPage> {
  // Controller for the email input field to retrieve the entered email
  final TextEditingController _emailController = TextEditingController();

  // Global key to uniquely identify the form and manage its state
  final _formKey = GlobalKey<FormState>();

  // Firebase Authentication instance to interact with Firebase services
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _resetPassword() async {
    // Validate the form fields
    if (_formKey.currentState!.validate()) {
      try {
        // Send a password reset email to the provided email
        await _auth.sendPasswordResetEmail(email: _emailController.text.trim());

        // Show a success message using a blue SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Password reset link sent to your email!',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.blue, // ✅ Blue background
            behavior: SnackBarBehavior
                .floating, // Floating style for better visibility
            elevation: 5,
          ),
        );
      } catch (e) {
        // Handle errors and show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// The build method renders the UI
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Dismiss keyboard focus on tap
      },
      child: Scaffold(
       backgroundColor: Colors.white
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Password',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Want to change your password? Enter the email associated with your account below and we will send you a new link.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Email Address',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Please enter a valid email...',
                    filled: true,
                    fillColor: const Color.fromARGB(255, 244, 244, 244),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Send Reset Link',
                      style: TextStyle(
                          color: Color.fromARGB(255, 247, 245, 245),
                          fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } //t
}
