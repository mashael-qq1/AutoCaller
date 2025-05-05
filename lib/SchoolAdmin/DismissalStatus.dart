import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'NavBarAdmin.dart';
import 'DismissalHistoryAdmin.dart';

class DismissalStatus extends StatefulWidget {
  const DismissalStatus({super.key});

  @override
  _DismissalStatusState createState() => _DismissalStatusState();
}

class _DismissalStatusState extends State<DismissalStatus> {
  DocumentReference? schoolRef;

  @override
  void initState() {
    super.initState();
    _fetchAdminSchoolID();
  }

  Future<void> _fetchAdminSchoolID() async {
    String? adminEmail = FirebaseAuth.instance.currentUser?.email;
    if (adminEmail == null) return;

    try {
      var adminQuery = await FirebaseFirestore.instance
          .collection('Admin')
          .where('email', isEqualTo: adminEmail)
          .get();

      if (adminQuery.docs.isNotEmpty) {
        var schoolReference = adminQuery.docs.first['AschoolID'];
        if (schoolReference is DocumentReference) {
          setState(() {
            schoolRef = schoolReference;
          });
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching admin school ID: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Dismissal Status",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildDismissalStatusList(),
      bottomNavigationBar: const NavBarAdmin(currentIndex: 0),
    );
  }

  Widget _buildDismissalStatusList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Student').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _noStudentsFound();
        }

        var students = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: students.length,
          itemBuilder: (context, index) {
            var student = students[index].data() as Map<String, dynamic>;

            return StudentCard(
              name: student['Sname'] ?? 'Unknown',
              status: student['dismissalStatus'] ?? 'Unknown',
              photoUrl: student['photoUrl'] ?? '',
              onShowHistory: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DismissalHistoryAdminPage(studentId: students[index].id),
                  ),
                );
              },
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
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ],
      ),
    );
  }
}

class StudentCard extends StatelessWidget {
  final String name;
  final String status;
  final String photoUrl;
  final VoidCallback onShowHistory;

  const StudentCard({
    super.key,
    required this.name,
    required this.status,
    required this.photoUrl,
    required this.onShowHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.blue.shade100,
              backgroundImage:
                  photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
              child: photoUrl.isEmpty
                  ? Icon(Icons.person, color: Colors.blue.shade700)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black)),
                  const SizedBox(height: 4),
                  Text("Status: $status",
                      style: const TextStyle(
                          color: Colors.black54, fontSize: 14)),
                  const SizedBox(height: 6),
                  TextButton.icon(
                    onPressed: onShowHistory,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                      backgroundColor: Colors.blue.withOpacity(0.08),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: const Icon(Icons.history, size: 18),
                    label: const Text(
                      "Show History",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}