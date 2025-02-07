import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DismissalStatus extends StatefulWidget {
  const DismissalStatus({super.key});

  @override
  _DismissalStatusState createState() => _DismissalStatusState();
}

class _DismissalStatusState extends State<DismissalStatus> {
  String? schoolID;

  @override
  void initState() {
    super.initState();
    _fetchAdminSchoolID();
  }

  Future<void> _fetchAdminSchoolID() async {
    String? adminEmail = FirebaseAuth.instance.currentUser?.email;
    if (adminEmail == null) {
      print("❌ No admin email found");
      return;
    }

    try {
      var adminQuery = await FirebaseFirestore.instance
          .collection('Admin')
          .where('email', isEqualTo: adminEmail)
          .get();

      if (adminQuery.docs.isNotEmpty) {
        var schoolRef = adminQuery.docs.first['AschoolID']; // 🔹 This is a DocumentReference
        if (schoolRef is DocumentReference) {
          setState(() {
            schoolID = schoolRef.path; // ✅ Extracts the document path
          });
          print("✅ Retrieved schoolID: $schoolID");
        } else if (schoolRef is String) {
          setState(() {
            schoolID = schoolRef;
          });
          print("✅ Retrieved schoolID as String: $schoolID");
        } else {
          print("❌ Unexpected schoolID type: ${schoolRef.runtimeType}");
        }
      } else {
        print("❌ No admin found with this email.");
      }
    } catch (e) {
      print("❌ Error fetching schoolID: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dismissal Status"),
        backgroundColor: Colors.blue,
      ),
      body: schoolID == null
          ? const Center(child: CircularProgressIndicator()) // Show loading
          : _buildDismissalStatusList(),
    );
  }

  Widget _buildDismissalStatusList() {
    print("✅ Querying students with schoolID: '$schoolID'");

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Student')
          .where('schoolID', isEqualTo: schoolID) // ✅ Ensures correct query
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print("❌ No students found for schoolID: $schoolID");
          return _noStudentsFound();
        }

        var students = snapshot.data!.docs;
        print("✅ Found ${students.length} students");

        for (var student in students) {
          print("📌 Student: ${student['Sname']}, Status: ${student['dismissalStatus']}");
        }

        return ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            var student = students[index];
            return StudentCard(
              name: student['Sname'],
              status: student['dismissalStatus'] ?? "Unknown",
              dismissalTime: student['lastDismissalTime'] ?? '------',
            );
          },
        );
      },
    );
  }

  Widget _noStudentsFound() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 40),
          SizedBox(height: 10),
          Text(
            "No students found",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ],
      ),
    );
  }
}

class StudentCard extends StatelessWidget {
  final String name;
  final String status;
  final String dismissalTime;

  const StudentCard({super.key, required this.name, required this.status, required this.dismissalTime});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Status: $status"),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dismissalTime,
              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}