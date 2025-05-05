import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dismissal_history.dart';
import 'NavBarPG.dart';

class DismissalStatusPG extends StatefulWidget {
  const DismissalStatusPG({super.key});

  @override
  State<DismissalStatusPG> createState() => _DismissalStatusPGState();
}

class _DismissalStatusPGState extends State<DismissalStatusPG> {
  String? guardianID;

  @override
  void initState() {
    super.initState();
    guardianID = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "My Children's Dismissal Status",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: guardianID == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Primary Guardian')
                  .doc(guardianID)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var childrenRefs = snapshot.data!['children'] ?? [];

                if (childrenRefs.isEmpty) {
                  return const Center(child: Text("No children found."));
                }

                return FutureBuilder<List<DocumentSnapshot>>(
                  future: _fetchStudents(childrenRefs),
                  builder: (context, studentSnapshot) {
                    if (!studentSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var students = studentSnapshot.data!;

                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        var data = students[index].data() as Map<String, dynamic>;

                        String name = data['Sname'] ?? "Unknown";
                        String status = data['dismissalStatus'] ?? "Unknown";
                        String photoUrl = data['photoUrl'] ?? '';

                        return StudentCard(
                          name: name,
                          status: status,
                          photoUrl: photoUrl,
                          onShowHistory: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DismissalHistoryPage(
                                  studentId: students[index].id,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
      bottomNavigationBar: guardianID != null
          ? NavBarPG(loggedInGuardianId: guardianID!, currentIndex: 0)
          : null,
    );
  }

  Future<List<DocumentSnapshot>> _fetchStudents(List<dynamic> childrenRefs) async {
    List<DocumentSnapshot> students = [];
    for (var ref in childrenRefs) {
      students.add(await (ref as DocumentReference).get());
    }
    return students;
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
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.blue.shade100,
              backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
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
                      style: const TextStyle(color: Colors.black54, fontSize: 14)),
                  const SizedBox(height: 6),
                  TextButton.icon(
                    onPressed: onShowHistory,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                      backgroundColor: Colors.blue.withOpacity(0.08),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: const Icon(Icons.history, size: 18),
                    label: const Text(
                      "Show History",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}