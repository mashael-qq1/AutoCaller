import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'NavBarPG.dart'; // Import the Primary Guardian NavBar

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
  String? guardianUid = FirebaseAuth.instance.currentUser?.uid;

  if (guardianUid == null) {
    debugPrint("❌ No guardian UID found");
    return;
  }

  try {
    var guardianDoc = await FirebaseFirestore.instance
        .collection('Primary Guardian')
        .doc(guardianUid)
        .get();

    if (guardianDoc.exists) {
      var data = guardianDoc.data() as Map<String, dynamic>;

      if (data.containsKey('children')) {
        List<dynamic> children = data['children'] ?? [];
        List<DocumentReference> refs = children.cast<DocumentReference>();

        // ✅ Only set state once
        if (!listEquals(childrenRefs, refs)) {
          setState(() {
            childrenRefs = refs;
          });
        }
      } else {
        debugPrint("ℹ️ No 'children' field found in guardian doc.");
        setState(() {
          childrenRefs = [];
        });
      }
    } else {
      debugPrint("❌ Guardian document not found.");
      setState(() {
        childrenRefs = [];
      });
    }
  } catch (e) {
    debugPrint("❌ Error fetching children references: $e");
    setState(() {
      childrenRefs = [];
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Students",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: childrenRefs == null
          ? const Center(child: CircularProgressIndicator())
          : _buildStudentList(),
      bottomNavigationBar: NavBarPG(
          loggedInGuardianId: widget.loggedInGuardianId, currentIndex: 3),
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
            String? photoUrl = studentData['photoUrl'];

            return StudentCard(
              name: name,
              gradeLevel: gradeLevel,
              photoUrl: photoUrl,
            );
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
          SizedBox(height: 10),
          Text(
            "No students found",
            
          ),
        ],
      ),
    );
  }
}

/// ✅ Updated Student Card UI with photoUrl support
class StudentCard extends StatelessWidget {
  final String name;
  final String gradeLevel;
  final String? photoUrl;

  const StudentCard({
    super.key,
    required this.name,
    required this.gradeLevel,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.blue.shade100,
              backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty)
                  ? NetworkImage(photoUrl!)
                  : null,
              child: (photoUrl == null || photoUrl!.isEmpty)
                  ? Icon(Icons.person, color: Colors.blue.shade700)
                  : null,
            ),
            const SizedBox(width: 12),
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