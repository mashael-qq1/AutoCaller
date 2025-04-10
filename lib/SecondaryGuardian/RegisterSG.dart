import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'SGhome.dart'; // Navigate to Secondary Guardian Home Page after registration

class RegisterSecondaryGuardianPage extends StatefulWidget {
  final String primaryGuardianID;
  final List<String> studentIDs;

  const RegisterSecondaryGuardianPage({
    Key? key,
    required this.primaryGuardianID,
    required this.studentIDs,
  }) : super(key: key);

  @override
  _RegisterSecondaryGuardianPageState createState() =>
      _RegisterSecondaryGuardianPageState();
}

class _RegisterSecondaryGuardianPageState
    extends State<RegisterSecondaryGuardianPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  Future<void> _registerSecondaryGuardian() async {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create Secondary Guardian Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String secondaryGuardianID = userCredential.user!.uid;

      // Store Secondary Guardian in Firestore
      await _firestore.collection('Secondary Guardian').doc(secondaryGuardianID).set({
        "FullName": _nameController.text.trim(),
        "PhoneNum": _phoneController.text.trim(),
        "email": _emailController.text.trim(),
        "isAuthorized": true,
        "uid": secondaryGuardianID,
        "primaryGuardianID": widget.primaryGuardianID,
        "children": widget.studentIDs,
      });

      // Update Primary Guardian with Secondary Guardian ID
      await _firestore.collection('Primary Guardian').doc(widget.primaryGuardianID).update({
        "secondaryGuardiansID": FieldValue.arrayUnion([secondaryGuardianID])
      });

      await _sendNotificationToPrimaryGuardian();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SGhome()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendNotificationToPrimaryGuardian() async {
    DocumentSnapshot primaryDoc = await _firestore
        .collection('Primary Guardian')
        .doc(widget.primaryGuardianID)
        .get();

    String? fcmToken = primaryDoc['fcmToken'];

    if (fcmToken == null) return;

    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=BLCIoXmBAMnLvvq9bTvqNxqJUWc4aY8mXrYyce8p--KTJ5LK-aS65KAz70vHtC_0oYlqrm7IjVqldpbbd12k72E', // Replace with your real FCM Server Key
      },
      body: jsonEncode({
        "to": fcmToken,
        "notification": {
          "title": "Invitation Accepted",
          "body":
              "${_nameController.text.trim()} accepted your invitation as a Secondary Guardian.",
        },
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Secondary Guardian Registration",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField("Full Name", "Enter your name", _nameController),
            const SizedBox(height: 12),
            _buildInputField("Phone Number", "Enter phone number", _phoneController,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _buildInputField("Email", "Enter email", _emailController,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _buildInputField("Password", "Enter password", _passwordController,
                obscureText: true),
            const SizedBox(height: 12),
            _buildInputField("Confirm Password", "Re-enter password",
                _confirmPasswordController, obscureText: true),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
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
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text("Register",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}