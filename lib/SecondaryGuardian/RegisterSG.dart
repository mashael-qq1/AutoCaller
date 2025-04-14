// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autocaller/notification_service.dart';
import 'SGhome.dart';

class RegisterSecondaryGuardianPage extends StatefulWidget {
  final String primaryGuardianID;
  final List<String> studentIDs;

  const RegisterSecondaryGuardianPage({
    Key? key,
    required this.primaryGuardianID,
    required this.studentIDs,
  }) : super(key: key);

  @override
  State<RegisterSecondaryGuardianPage> createState() =>
      _RegisterSecondaryGuardianPageState();
}

class _RegisterSecondaryGuardianPageState
    extends State<RegisterSecondaryGuardianPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  final phoneRegExp = RegExp(r'^05[0-9]{8}$');
  final emailRegExp =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  Future<void> _registerSecondaryGuardian() async {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showSnackBar("Please fill in all fields.");
      return;
    }

    // Phone number validation
    String phone = _phoneController.text.trim();
    if (phone.length != 10) {
      _showSnackBar("Phone number must be 10 digits long.");
      return;
    } else if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      _showSnackBar("Phone number must contain only digits.");
      return;
    } else if (!phoneRegExp.hasMatch(phone)) {
      _showSnackBar(
          "Please enter a valid Saudi phone number starting with 05.");
      return;
    }

    // Email validation
    if (!emailRegExp.hasMatch(_emailController.text.trim())) {
      _showSnackBar("Please enter a valid email address.");
      return;
    }

    // Password match validation
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar("Passwords do not match.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String secondaryGuardianID = userCredential.user!.uid;

      // Convert student IDs to DocumentReferences
      List<DocumentReference> studentRefs = widget.studentIDs
          .map((id) => _firestore.collection('Student').doc(id))
          .toList();

      await _firestore
          .collection('Secondary Guardian')
          .doc(secondaryGuardianID)
          .set({
        "FullName": _nameController.text.trim(),
        "PhoneNum": _phoneController.text.trim(),
        "email": _emailController.text.trim(),
        "isAuthorized": true,
        "uid": secondaryGuardianID,
        "primaryGuardianID": widget.primaryGuardianID,
        "children": studentRefs,
      });

      await _firestore
          .collection('Primary Guardian')
          .doc(widget.primaryGuardianID)
          .update({
        "secondaryGuardiansID": FieldValue.arrayUnion([secondaryGuardianID])
      });

      await NotificationService.callSecondaryGuardianArrival(
        primaryGuardianID: widget.primaryGuardianID,
        secondaryGuardianName: _nameController.text.trim(),
      );

      _showSnackBar("Registration successful!");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SGhome(loggedInGuardianId: secondaryGuardianID)),
      );
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Secondary Guardian Registration",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField("Full Name", "Enter your name", _nameController),
            SizedBox(height: 12),
            _buildInputField(
                "Phone Number", "Enter phone number", _phoneController,
                keyboardType: TextInputType.phone),
            SizedBox(height: 12),
            _buildInputField("Email", "Enter email", _emailController,
                keyboardType: TextInputType.emailAddress),
            SizedBox(height: 12),
            _buildInputField("Password", "Enter password", _passwordController,
                obscureText: true),
            SizedBox(height: 12),
            _buildInputField("Confirm Password", "Re-enter password",
                _confirmPasswordController,
                obscureText: true),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _buildRegisterButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
      String label, String hint, TextEditingController controller,
      {TextInputType? keyboardType, bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _registerSecondaryGuardian,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text("Register",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ),
    );
  }
}
