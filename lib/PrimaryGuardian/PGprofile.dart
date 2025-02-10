import 'package:autocaller/SchoolAdmin/ResetPassword.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:autocaller/firstPage.dart'; // Import your WelcomeScreen

class PrimaryGuardianProfilePage extends StatefulWidget {
  const PrimaryGuardianProfilePage({super.key});

  @override
  _PrimaryGuardianProfilePageState createState() =>
      _PrimaryGuardianProfilePageState();
}

class _PrimaryGuardianProfilePageState
    extends State<PrimaryGuardianProfilePage> {
  Map<String, dynamic>? guardianData;
  String? guardianID;

  @override
  void initState() {
    super.initState();
    _fetchGuardianData();
  }

  Future<void> _fetchGuardianData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }

      guardianID = user.uid;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Primary Guardian')
          .where('userId', isEqualTo: guardianID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot guardianDoc = querySnapshot.docs[0];
        setState(() {
          guardianData = guardianDoc.data() as Map<String, dynamic>;
        });
      } else {
        print("Guardian document not found");
      }
    } catch (e) {
      print("Error fetching guardian data: $e");
    }
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
                  MaterialPageRoute(
                      builder: (context) => const WelcomeScreen()),
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
        title: const Text('Guardian Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: guardianData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Center(
                    child: Icon(
                      Icons.account_circle,
                      size: 100,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildInfoRow("Guardian Name:",
                      guardianData!['fullName'] ?? 'Not Available'),
                  buildInfoRow(
                      "Email:", guardianData!['email'] ?? 'Not Available'),
                  buildInfoRow("Phone Number:",
                      guardianData!['phone'] ?? 'Not Available'),

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
                                    const ResetPasswordPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: const Color.fromARGB(255, 200, 199, 199),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  const SizedBox(height: 10),

                  buildProfileButton("Edit Profile", () {
                    // TODO: Implement edit profile functionality
                  }),
                  const SizedBox(height: 30),
                  //Divider(thickness: 1, color: Colors.grey.shade400),
                  const SizedBox(height: 10),

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
                          "Logout",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
            style: const TextStyle(
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

  Widget buildProfileButton(String text, VoidCallback onPressed) {
    return Center(
      child: SizedBox(
        width: 400,
        height: 50,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            elevation: 2,
            shadowColor: const Color.fromARGB(255, 200, 199, 199),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.black, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
