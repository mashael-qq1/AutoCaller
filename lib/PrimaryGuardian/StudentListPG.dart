import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'NavBarPG.dart';

class StudentListPG extends StatefulWidget {
  final String loggedInGuardianId;

  const StudentListPG({super.key, required this.loggedInGuardianId});

  @override
  _StudentListPGState createState() => _StudentListPGState();
}

class _StudentListPGState extends State<StudentListPG> {
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
          .collection('Primary Guardian')
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
        title: const Text("Students."),
        backgroundColor: Colors.white,
      ),
      body: childrenRefs == null
          ? const Center(child: CircularProgressIndicator())
          : _buildStudentList(),
      bottomNavigationBar:
          NavBarPG(loggedInGuardianId: widget.loggedInGuardianId),
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
          Text("No children found",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red)),
        ],
      ),
    );
  }
}

class StudentCard extends StatelessWidget {
  final String name;
  final String gradeLevel;

  const StudentCard({super.key, required this.name, required this.gradeLevel});

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
        subtitle: Text("Grade: $gradeLevel"),
      ),
    );
  }
}
