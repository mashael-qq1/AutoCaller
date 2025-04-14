import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:autocaller/PrimaryGuardian/NavBarPG.dart';

class SGhome extends StatefulWidget {
  const SGhome({super.key});
  @override
  _GuardianHomePageState createState() => _GuardianHomePageState();
}

class _GuardianHomePageState extends State<SGhome> {
  Map<String, bool> isLoading = {}; // Track loading state for each button

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Home Page',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const SizedBox(height: 24),
              const Text(
                'Confirm Pickup',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildStudentList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          const NavBarPG(loggedInGuardianId: "guardian_id", currentIndex: 2),
    );
  }

  Widget _buildStudentList() {
    String guardianId = FirebaseAuth.instance.currentUser?.uid ?? "";

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Secondary Guardian')
          .doc(guardianId)
          .snapshots(), // Real-time updates
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching data.'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Guardian data not found.'));
        }

        List<dynamic> children = snapshot.data!['children'] ?? [];
        return Column(
          children: children.map<Widget>((childRef) {
            return StreamBuilder<DocumentSnapshot>(
              stream:
                  childRef.snapshots(), // Real-time updates for each student
              builder: (context, studentSnapshot) {
                if (studentSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (studentSnapshot.hasError) {
                  return const Center(
                      child: Text('Error fetching student data.'));
                }

                if (!studentSnapshot.hasData || studentSnapshot.data == null) {
                  return const Center(child: Text('Student not found.'));
                }

                var studentData = studentSnapshot.data!;
                String studentName = studentData['Sname'] ?? 'Unknown';
                String studentPhotoUrl = studentData['photoUrl'] ?? '';
                String studentId = studentData['StudentID'];
                String dismissalStatus = studentData['dismissalStatus'] ??
                    'waiting'; // Get dismissalStatus

                bool loading = isLoading[studentId] ?? false;

                return Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      backgroundImage: studentPhotoUrl.isNotEmpty
                          ? NetworkImage(studentPhotoUrl)
                          : const AssetImage('assets/default_avatar.png')
                              as ImageProvider,
                    ),
                    title:
                        Text(studentName, style: const TextStyle(fontSize: 16)),
                    trailing: ElevatedButton(
                      onPressed: () {
                        if (dismissalStatus != 'picked up') {
                          setState(() {
                            isLoading[studentId] = true; // Show loading spinner
                          });
                          _updateDismissalStatus(studentId);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              dismissalStatus == 'picked up'
                                  ? 'Picked Up'
                                  : 'Confirm Pickup',
                              style: const TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _updateDismissalStatus(String studentId) async {
    String guardianId = FirebaseAuth.instance.currentUser?.uid ?? "";

    DocumentReference studentRef =
        FirebaseFirestore.instance.collection('Student').doc(studentId);
    setState(() {
      isLoading[studentId] =
          false; // Hide the loading spinner after operation is completed
    });
    // Update the dismissalStatus to 'picked up' and set the timestamp
    await studentRef.update({
      'dismissalStatus': 'picked up',
      'pickupTimestamp': FieldValue.serverTimestamp(),
    });

    // After updating, set a delay of 1 minute to reset dismissal status
    Future.delayed(Duration(hours: 20), () async {
      await studentRef.update({
        'dismissalStatus': 'waiting',
        'pickupTimestamp': FieldValue.serverTimestamp(),
      });
    });
  }
}
