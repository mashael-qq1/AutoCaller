import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:autocaller/PrimaryGuardian/NavBarPG.dart';

class GuardianHomePage extends StatefulWidget {
  const GuardianHomePage({super.key});

  @override
  _GuardianHomePageState createState() => _GuardianHomePageState();
}

class _GuardianHomePageState extends State<GuardianHomePage> {
  Set<String> selectedStudentIds = {};
  bool isArrived = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Home Page',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18, // Match StudentListPG
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildStudentList(),
      ),
      bottomNavigationBar: NavBarPG(
        loggedInGuardianId: FirebaseAuth.instance.currentUser?.uid ?? "",
        currentIndex: 2,
      ),
    );
  }

  Widget _buildStudentList() {
  String? guardianUid = FirebaseAuth.instance.currentUser?.uid;

  if (guardianUid == null) {
    return const Center(child: Text("User not logged in."));
  }

  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance
        .collection('Primary Guardian')
        .doc(guardianUid)
        .get(),
    builder: (context, guardianSnapshot) {
      if (guardianSnapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!guardianSnapshot.hasData || !guardianSnapshot.data!.exists) {
        return const Center(child: Text("Guardian data not found."));
      }

      String? guardianPhone = guardianSnapshot.data!.get('phone');

      if (guardianPhone == null || guardianPhone.isEmpty) {
        return const Center(child: Text("Guardian phone number missing."));
      }

      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Student')
            .where('PGphone', isEqualTo: guardianPhone)
            .snapshots(),
        builder: (context, studentSnapshot) {
          if (studentSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          List<DocumentSnapshot> students = studentSnapshot.data?.docs ?? [];

        // ❗️ Pass the student list even if it's empty
    return _buildStudentListUI(students);
        },
      );
    },
  );
}



  Widget _buildStudentListUI(List<DocumentSnapshot> students) {
   

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Confirm Pickup',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 25,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2), // Light shadow
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: Offset(0, 3), // Shadow position
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 8),
                  child: Text(
                    'Select Student:',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Color.fromARGB(255, 117, 117, 117),
                    ),
                  ),
                ),
                if (students.isEmpty)
  const Padding(
    padding: EdgeInsets.symmetric(vertical: 12.0),
    child: Center(
      child: Text(
        "No students found.",
        
      ),
    ),
  )
else
               
  ...students
      .where((student) => !(student['absent'] ?? false)) // ✅ filter out absent == true
      .toList()
      .asMap()
      .entries
      .map((entry) {
                  int index = entry.key;
                  var student = entry.value;
                  String studentId = student['StudentID'];
                  String studentName = student['Sname'];
                  String photoUrl = student['photoUrl'] ?? '';
                  String dismissalStatus =
                      student['dismissalStatus'] ?? 'waiting';
                  bool isSelected = selectedStudentIds.contains(studentId);

                  return Column(
                    children: [
                      InkWell(
                        onTap: dismissalStatus == 'picked up'
                            ? null
                            : () {
                                setState(() {
                                  if (isSelected) {
                                    selectedStudentIds.remove(studentId);
                                  } else {
                                    selectedStudentIds.add(studentId);
                                  }
                                });
                              },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                backgroundImage: photoUrl.isNotEmpty
                                    ? NetworkImage(photoUrl)
                                    : const AssetImage(
                                            'assets/default_avatar.png')
                                        as ImageProvider,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  studentName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              dismissalStatus == 'picked up'
                                  ? const Text(
                                      'Picked Up',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Icon(
                                      isSelected
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color: Colors.blue,
                                    ),
                            ],
                          ),
                        ),
                      ),
                      if (index < students.length - 1)
                        const Divider(
                          color: Colors.grey,
                          thickness: 0.5,
                          indent: 8,
                          endIndent: 8,
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: [
              ElevatedButton(
                onPressed: (!isArrived || selectedStudentIds.isEmpty)
                    ? null
                    : () async {
                        for (String studentId in selectedStudentIds) {
                          await _updateDismissalStatus(studentId);
                        }
                        setState(() {
                          selectedStudentIds.clear();
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Confirm Pickup',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (!isArrived || selectedStudentIds.isEmpty)
                const Text(
                  'The button is disabled until you are in the school zone and a student is selected.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromARGB(255, 131, 124, 124),
                    fontSize: 13,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Add this helper function above _updateDismissalStatus
  Future<String> getGuardianName() async {
    String? guardianId = FirebaseAuth.instance.currentUser?.uid;
    if (guardianId == null) return 'Unknown Guardian';

    // Try Primary Guardian
    var primaryDoc = await FirebaseFirestore.instance
        .collection('Primary Guardian')
        .doc(guardianId)
        .get();

    if (primaryDoc.exists && primaryDoc.data()!.containsKey('fullName')) {
      return primaryDoc['fullName'];
    }

    // Try Secondary Guardian
    var secondaryDoc = await FirebaseFirestore.instance
        .collection('Secondary Guardian')
        .doc(guardianId)
        .get();

    if (secondaryDoc.exists && secondaryDoc.data()!.containsKey('FullName')) {
      return secondaryDoc['FullName'];
    }

    return 'Unknown Guardian';
  }

  Future<void> _updateDismissalStatus(String studentId) async {
    String? guardianUid = FirebaseAuth.instance.currentUser?.uid;
    if (guardianUid == null) return;

    DocumentReference studentRef =
        FirebaseFirestore.instance.collection('Student').doc(studentId);

    await studentRef.update({
      'dismissalStatus': 'picked up',
      'pickupTimestamp': FieldValue.serverTimestamp(),
      'pickedUpBy': guardianUid, // ✅ store UID, not full name
    });

    Future.delayed(const Duration(hours: 20), () async {
      await studentRef.update({
        'dismissalStatus': 'waiting',
        'pickupTimestamp': FieldValue.serverTimestamp(),
      });
    });
  }
}
