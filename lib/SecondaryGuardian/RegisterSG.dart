import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
<<<<<<< HEAD
=======
import 'package:autocaller/notification_service.dart'; // correct import

import 'SGhome.dart';
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b

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

<<<<<<< HEAD
  /// **Registers the Secondary Guardian**
=======
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
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
<<<<<<< HEAD
      // Create user in Firebase Authentication
=======
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String secondaryGuardianID = userCredential.user!.uid;

<<<<<<< HEAD
      // Store secondary guardian in Firestore
=======
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
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
        "children": widget.studentIDs,
      });

<<<<<<< HEAD
      // Link the Secondary Guardian under the Primary Guardian
      await _firestore
          .collection('PrimaryGuardian')
=======
      await _firestore
          .collection('Primary Guardian')
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
          .doc(widget.primaryGuardianID)
          .update({
        "secondaryGuardiansID": FieldValue.arrayUnion([secondaryGuardianID])
      });

<<<<<<< HEAD
=======
      // Get FCM Token of Primary Guardian
      DocumentSnapshot primaryDoc = await _firestore
          .collection('Primary Guardian')
          .doc(widget.primaryGuardianID)
          .get();

      String? fcmToken = primaryDoc['fcmToken'];

      print("📲 Primary Guardian FCM Token: $fcmToken");

      if (fcmToken != null) {
        await NotificationService.sendNotification(
          token: fcmToken,
          title: "Invitation Accepted",
          body:
              "${_nameController.text.trim()} accepted your invitation as a Secondary Guardian.",
        );
      }

>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful!")),
      );

<<<<<<< HEAD
      Navigator.pop(context);
=======
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SGhome()),
      );
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Secondary Guardian Registration",
<<<<<<< HEAD
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
=======
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
        ),
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
<<<<<<< HEAD
            _buildInputField(
                "Phone Number", "Enter phone number", _phoneController,
                keyboardType: TextInputType.phone),
=======
            _buildInputField("Phone Number", "Enter phone number",
                _phoneController, keyboardType: TextInputType.phone),
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
            const SizedBox(height: 12),
            _buildInputField("Email", "Enter email", _emailController,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
<<<<<<< HEAD
            _buildInputField("Password", "Enter password", _passwordController,
                obscureText: true),
            const SizedBox(height: 12),
            _buildInputField("Confirm Password", "Re-enter password",
                _confirmPasswordController,
                obscureText: true),
=======
            _buildInputField("Password", "Enter password",
                _passwordController, obscureText: true),
            const SizedBox(height: 12),
            _buildInputField("Confirm Password", "Re-enter password",
                _confirmPasswordController, obscureText: true),
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildRegisterButton(),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  /// **Input Field Builder**
  Widget _buildInputField(
      String label, String hint, TextEditingController controller,
=======
  Widget _buildInputField(String label, String hint,
      TextEditingController controller,
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
      {TextInputType? keyboardType, bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
<<<<<<< HEAD
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
=======
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
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
<<<<<<< HEAD
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
=======
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          ),
        ),
      ],
    );
  }

<<<<<<< HEAD
  /// **Register Button**
=======
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _registerSecondaryGuardian,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          padding: const EdgeInsets.symmetric(vertical: 12),
<<<<<<< HEAD
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text("Register",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ),
    );
  }
}
=======
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text("Register",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
