import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'NavBarSG.dart'; // Import the Secondary Guardian NavBar

class StudentListSG extends StatefulWidget {
  final String loggedInGuardianId;

  const StudentListSG({super.key, required this.loggedInGuardianId});

  @override
  _StudentListSGState createState() => _StudentListSGState();
}

class _StudentListSGState extends State<StudentListSG> {
  List<DocumentReference>? childrenRefs;

  @override
  void initState() {
    super.initState();
    _fetchGuardianChildren();
  }

  Future<void> _fetchGuardianChildren() async {
    String? guardianEmail = FirebaseAuth.instance.currentUser?.email;

    if (guardianEmail == null) {
      debugPrint("❌ No guardian email found");
      return;
    }

    try {
      var guardianQuery = await FirebaseFirestore.instance
          .collection('Secondary Guardian') // ✅ Fetch from Secondary Guardian Collection
          .where('email', isEqualTo: guardianEmail.trim().toLowerCase())
          .get();

      if (guardianQuery.docs.isNotEmpty) {
        var guardianDoc = guardianQuery.docs.first;
        List<dynamic>? children = guardianDoc['children'];

        if (children != null && children.isNotEmpty) {
          setState(() {
            childrenRefs = children.cast<DocumentReference>();
          });
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching children references: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the back button
        title: const Text(
          "Students",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18, // Consistent font size
          ),
        ),
        centerTitle: true, // Centers the title
        backgroundColor: Colors.white, // White background for the AppBar
        elevation: 0,
      ),
      body: childrenRefs == null
          ? const Center(child: CircularProgressIndicator())
          : _buildStudentList(),
      bottomNavigationBar: NavBarSG(
          loggedInGuardianId: widget.loggedInGuardianId, currentIndex: 1),
    );
  }

  Widget _buildStudentList() {
    if (childrenRefs == null || childrenRefs!.isEmpty) {
      return _noChildrenFound();
    }

    return FutureBuilder<List<DocumentSnapshot>>(
      future: _fetchStudentDocuments(childrenRefs!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _noChildrenFound();
        }

        var children = snapshot.data!;

        return ListView.builder(
          itemCount: children.length,
          itemBuilder: (context, index) {
            var studentData =
                children[index].data() as Map<String, dynamic>? ?? {};

            String name = studentData['Sname'] ?? "Unknown";
            String gradeLevel = studentData['gradeLevel'] ?? "N/A";

            return StudentCard(name: name, gradeLevel: gradeLevel);
          },
        );
      },
    );
  }

  Future<List<DocumentSnapshot>> _fetchStudentDocuments(
      List<DocumentReference> studentRefs) async {
    List<DocumentSnapshot> studentDocs = [];
    for (var ref in studentRefs) {
      try {
        var doc = await ref.get();
        if (doc.exists) {
          studentDocs.add(doc);
        }
      } catch (e) {
        debugPrint("❌ Error fetching student document: $e");
      }
    }
    return studentDocs;
  }

  Widget _noChildrenFound() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 40),
          SizedBox(height: 10),
          Text(
            "No students found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

/// **Student Card UI**
class StudentCard extends StatelessWidget {
  final String name;
  final String gradeLevel;

  const StudentCard({super.key, required this.name, required this.gradeLevel});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3, // ✅ Add shadow for consistency
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // ✅ Match the design
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔹 Profile Picture
            CircleAvatar(
              radius: 25, // ✅ Keep consistent size
              backgroundColor: Colors.blue.shade100,
              child: Icon(
                Icons.person,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 12), // ✅ Space between image and text

            // 🔹 Name & Grade
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Grade: $gradeLevel",
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
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