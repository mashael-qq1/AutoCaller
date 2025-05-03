// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:autocaller/SchoolAdmin/ResetPassword.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:autocaller/firstPage.dart';
import 'NavBarAdmin.dart'; // Import the NavBarAdmin
import 'ResetPassword.dart';

class SchoolProfilePage extends StatefulWidget {
  final bool showResetWarning;

  const SchoolProfilePage({Key? key, this.showResetWarning = false})
      : super(key: key);

  @override
  _SchoolProfilePageState createState() => _SchoolProfilePageState();
}

class _SchoolProfilePageState extends State<SchoolProfilePage> {
  Map<String, dynamic>? schoolData;
  DocumentReference? schoolRef;
  String? adminID;

  @override
  @override
  void initState() {
    super.initState();
    fetchAdminData();

    if (widget.showResetWarning) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('Admin')
              .doc(user.uid)
              .update({'needsPasswordReset': false});
        }
        _showResetPasswordPopup();
      });
    }
  }

  Future<void> fetchAdminData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }

      adminID = user.uid;
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance
          .collection('Admin')
          .doc(adminID)
          .get();

      if (adminDoc.exists) {
        var data = adminDoc.data() as Map<String, dynamic>?;

        if (data != null && data.containsKey('AschoolID')) {
          schoolRef = data['AschoolID'];
          if (schoolRef != null) {
            fetchSchoolData(schoolRef!);
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching admin data: $e");
    }
  }

  Future<void> fetchSchoolData(DocumentReference schoolRef) async {
    try {
      DocumentSnapshot schoolDoc = await schoolRef.get();
      if (schoolDoc.exists) {
        setState(() {
          schoolData = schoolDoc.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      debugPrint("Error fetching school data: $e");
    }
  }

 void _showResetPasswordPopup() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFF1EAF7),
        title: const Text(
          'Reset Required',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'As this is your first login, you are required to reset your password for security reasons.',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // ✅ Just dismiss, no snackbar
            },
            child: const Text('OK', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}


  Future<void> _confirmLogout(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () async {
                Navigator.of(context).pop();
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomeScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes back button
        title: const Text(
          'School Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        centerTitle: true, // Centers title
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: schoolData == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: schoolData!['logo'] != null &&
                                    schoolData!['logo'].isNotEmpty
                                ? Image.network(
                                    schoolData!['logo'],
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      debugPrint(
                                          '❌ Error loading school logo: $error');
                                      return const Icon(Icons.school,
                                          size: 48, color: Colors.grey);
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      );
                                    },
                                  )
                                : const Icon(Icons.school,
                                    size: 48, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 20),
                        buildInfoRow("School Name:",
                            schoolData!['name'] ?? 'Not Available'),
                        buildInfoRow(
                          "Phone:",
                          schoolData!['phoneNum'] ?? 'Not Available',
                          //color: Color(0xFF23A8FF)
                        ),
                        buildInfoRow(
                            "Email:", schoolData!['email'] ?? 'Not Available'),
                        buildInfoRow("Address:",
                            schoolData!['address'] ?? 'Not Available'),
                        const SizedBox(height: 20),
                        Divider(thickness: 1, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        Center(
                          child: SizedBox(
                            width: 400,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ResetPasswordPage()));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                elevation: 2,
                                shadowColor:
                                    const Color.fromARGB(255, 200, 199, 199),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Reset Password",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios,
                                      color: Colors.black, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Center(
                          child: SizedBox(
                            width: 200,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                _confirmLogout(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF23a8ff),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                              child: const Text(
                                'Logout',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          NavBarAdmin(currentIndex: 4), // Add the navbar here
        ],
      ),
    );
  }

  Widget buildInfoRow(String title, String value,
      {Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Color(0xFF57636C)),
          ),
          Text(
            value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.normal, color: color),
          ),
        ],
      ),
    );
  }
}
