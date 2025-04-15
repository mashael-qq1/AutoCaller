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
  bool? isAuthorized;

  @override
  void initState() {
    super.initState();
    _fetchGuardianData();
  }

  /// Fetch guardian data (authorization and student references)
  Future<void> _fetchGuardianData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      var guardianDoc = await FirebaseFirestore.instance
          .collection('Secondary Guardian')
          .doc(user.uid)
          .get();

      if (guardianDoc.exists) {
        bool guardianIsAuthorized = guardianDoc['isAuthorized'] ?? false;
        setState(() {
          isAuthorized = guardianIsAuthorized;
          if (guardianIsAuthorized) {
            List<dynamic>? childrenList = guardianDoc['children'];
            if (childrenList != null) {
              childrenRefs = childrenList.cast<DocumentReference>();
            }
          }
        });
      } else {
        setState(() {
          isAuthorized = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Error fetching guardian data: $e");
      setState(() {
        isAuthorized = false;
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
      body: _buildBody(),
      bottomNavigationBar: NavBarSG(
        loggedInGuardianId: widget.loggedInGuardianId,
        currentIndex: 1,
      ),
    );
  }

  Widget _buildBody() {
    if (isAuthorized == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!isAuthorized!) {
      return _accessRevokedMessage();
    }

    return childrenRefs == null
        ? const Center(child: CircularProgressIndicator())
        : _buildStudentList();
  }

  /// Displays the list of students
  /// Displays the list of students
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

  /// Fetch each student document from Firestore
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

  /// Shown when no students are linked
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

  /// Shown when the guardian is unauthorized
  Widget _accessRevokedMessage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.block, color: Colors.red, size: 50),
          SizedBox(height: 10),
          Text(
            "You have been disabled by the Primary Guardian,\n"
            "you no longer have access to their students.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

/// Student card with image and details
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
              backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
                  ? NetworkImage(photoUrl!)
                  : null,
              child: photoUrl == null || photoUrl!.isEmpty
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
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
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
