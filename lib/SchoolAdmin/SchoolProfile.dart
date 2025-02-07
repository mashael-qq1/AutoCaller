import 'package:autocaller/SchoolAdmin/ResetPassword.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SchoolProfilePage extends StatefulWidget {
  @override
  _SchoolProfilePageState createState() => _SchoolProfilePageState();
}

class _SchoolProfilePageState extends State<SchoolProfilePage> {
  Map<String, dynamic>? schoolData;
  DocumentReference? schoolRef; // 🔹 Store reference properly
  String? adminID;

  @override
  void initState() {
    super.initState();
    fetchAdminData();
  }

  /// Step 1: Fetch Admin's Document to get the School Reference (AschoolID)
  Future<void> fetchAdminData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('❌ No user is signed in.');
        return;
      }

      adminID = user.uid;
      debugPrint("✅ Admin ID: $adminID");

      // Query Firestore to get the "AschoolID" field from Admin document
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance
          .collection('Admin') // ✅ Ensure this is the correct collection
          .doc(adminID) // ✅ Fetch the document where adminID is the document ID
          .get();

      if (adminDoc.exists) {
        var data = adminDoc.data() as Map<String, dynamic>?;

        if (data != null && data.containsKey('AschoolID')) {
          schoolRef = data['AschoolID']; // 🔹 This is a Firestore DocumentReference
          debugPrint("✅ Found AschoolID reference: ${schoolRef?.path}");

          if (schoolRef != null) {
            fetchSchoolData(schoolRef!);
          } else {
            debugPrint("❌ AschoolID reference is null.");
          }
        } else {
          debugPrint("❌ AschoolID field does not exist in Admin document.");
        }
      } else {
        debugPrint("❌ No Admin document found for ID: $adminID");
      }
    } catch (e) {
      debugPrint("❌ Error fetching admin data: $e");
    }
  }

  /// Step 2: Fetch School Data using AschoolID Reference
  Future<void> fetchSchoolData(DocumentReference schoolRef) async {
    try {
      DocumentSnapshot schoolDoc = await schoolRef.get(); // ✅ Fetch document using reference

      if (schoolDoc.exists) {
        setState(() {
          schoolData = schoolDoc.data() as Map<String, dynamic>;
        });
        debugPrint("✅ School data retrieved successfully.");
      } else {
        debugPrint("❌ No school data found for reference: ${schoolRef.path}");
      }
    } catch (e) {
      debugPrint("❌ Error fetching school data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('School Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: schoolData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // School Logo
                    Center(
                      child: schoolData!['logo'] != null
                          ? Image.network(
                              schoolData!['logo'],
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.school, size: 100, color: Colors.grey),
                            )
                          : Icon(Icons.school, size: 100, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // School Information
                    buildInfoRow("School Name:", schoolData!['name'] ?? 'Not Available'),
                    buildInfoRow("Phone:", schoolData!['phoneNum'] ?? 'Not Available', color: Color(0xFF23A8FF)),
                    buildInfoRow("Email:", schoolData!['email'] ?? 'Not Available'),
                    buildInfoRow("Address:", schoolData!['address'] ?? 'Not Available'),
                    const SizedBox(height: 20),

                    // Divider
                    Divider(thickness: 1, color: Colors.grey.shade400),
                    const SizedBox(height: 10),

                    // Reset Password Box
                    Center(
                      child: SizedBox(
                        width: 400,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordPage()));
                          },
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
                                "Reset Password",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios, color: Colors.black, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Logout Button
                    Center(
                      child: SizedBox(
                        width: 200,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            FirebaseAuth.instance.signOut();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF23a8ff),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          child: const Text(
                            'Logout',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// Helper function to build a labeled info row
  Widget buildInfoRow(String title, String value, {Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Color(0xFF57636C)),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: color),
          ),
        ],
      ),
    );
  }
}