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

  /// **Fetches Guardian Data (Children References & Authorization Status)**
  Future<void> _fetchGuardianData() async {
    String? guardianEmail = FirebaseAuth.instance.currentUser?.email;

    if (guardianEmail == null) {
      debugPrint("❌ No guardian email found");
      return;
    }

    try {
      var guardianQuery = await FirebaseFirestore.instance
<<<<<<< HEAD
          .collection(
              'Secondary Guardian') // ✅ Fetch from Secondary Guardian Collection
=======
          .collection('Secondary Guardian')
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
          .where('email', isEqualTo: guardianEmail.trim().toLowerCase())
          .get();

      if (guardianQuery.docs.isNotEmpty) {
        var guardianDoc = guardianQuery.docs.first;
        bool guardianIsAuthorized = guardianDoc['isAuthorized'] ?? false;

        setState(() {
          isAuthorized = guardianIsAuthorized;
          if (guardianIsAuthorized) {
<<<<<<< HEAD
            childrenRefs = (guardianDoc['children'] as List<dynamic>?)
                ?.cast<DocumentReference>();
=======
            List<dynamic>? childrenList = guardianDoc['children'];
            if (childrenList != null) {
              childrenRefs = childrenList
                  .map((childId) => FirebaseFirestore.instance
                      .collection('Student')
                      .doc(childId))
                  .toList();
            }
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
          }
        });
      }
    } catch (e) {
      debugPrint("❌ Error fetching guardian data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
<<<<<<< HEAD
        automaticallyImplyLeading: false, // Removes the back button
=======
        automaticallyImplyLeading: false,
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
        title: const Text(
          "Students",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
<<<<<<< HEAD
            fontSize: 18, // Consistent font size
          ),
        ),
        centerTitle: true, // Centers the title
        backgroundColor: Colors.white, // White background for the AppBar
=======
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar: NavBarSG(
<<<<<<< HEAD
          loggedInGuardianId: widget.loggedInGuardianId, currentIndex: 1),
=======
        loggedInGuardianId: widget.loggedInGuardianId,
        currentIndex: 1,
      ),
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
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

  /// **Displays List of Students**
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

  /// **Fetch Student Documents**
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

  /// **Message When No Students Are Found**
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

  /// **Message When Guardian Is Disabled**
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

/// **Student Card UI**
class StudentCard extends StatelessWidget {
  final String name;
  final String gradeLevel;

  const StudentCard({super.key, required this.name, required this.gradeLevel});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
<<<<<<< HEAD
      elevation: 3, // ✅ Add shadow for consistency
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // ✅ Match the design
=======
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
<<<<<<< HEAD
            // 🔹 Profile Picture
            CircleAvatar(
              radius: 25, // ✅ Keep consistent size
=======
            CircleAvatar(
              radius: 25,
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
              backgroundColor: Colors.blue.shade100,
              child: Icon(
                Icons.person,
                color: Colors.blue.shade700,
              ),
            ),
<<<<<<< HEAD
            const SizedBox(width: 12), // ✅ Space between image and text

            // 🔹 Name & Grade
=======
            const SizedBox(width: 12),
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
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
<<<<<<< HEAD
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
=======
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
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
