import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'NavBarSG.dart'; // Import the Secondary Guardian NavBar

class DismissalStatusSG extends StatefulWidget {
  const DismissalStatusSG({super.key});

  @override
  _DismissalStatusSGState createState() => _DismissalStatusSGState();
}

class _DismissalStatusSGState extends State<DismissalStatusSG> {
  List<DocumentReference>? childrenRefs;
  String? guardianID;

  @override
  void initState() {
    super.initState();
    _fetchGuardianChildren();
  }

  /// Fetch student references from the Secondary Guardian document
  Future<void> _fetchGuardianChildren() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    guardianID = user.uid.trim();
    debugPrint("🔍 Querying for guardianID: $guardianID");

    try {
      var guardianDoc = await FirebaseFirestore.instance
          .collection('Secondary Guardian')
          .doc(guardianID)
          .get();

      if (guardianDoc.exists) {
        List<dynamic>? children = guardianDoc['children'];

        if (children != null && children.isNotEmpty) {
          setState(() {
            childrenRefs = children.cast<DocumentReference>();
          });
        } else {
          debugPrint("⚠️ No children found for this secondary guardian");
        }
      } else {
        debugPrint("❌ Guardian document not found!");
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
        automaticallyImplyLeading: false,
        title: const Text(
          "My Children's Dismissal Status",
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
      body: Column(
        children: [
          Expanded(
            child: childrenRefs == null
                ? const Center(child: CircularProgressIndicator())
                : _buildDismissalStatusList(),
          ),
        ],
      ),
      bottomNavigationBar: guardianID != null
          ? NavBarSG(loggedInGuardianId: guardianID!, currentIndex: 0)
          : null, 
    );
  }

  /// Fetch and display student data
  Widget _buildDismissalStatusList() {
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
            String status = studentData['dismissalStatus'] ?? "Unknown";
            String formattedTime = studentData['lastDismissalTime'] != null
                ? _formatTimestamp(studentData['lastDismissalTime'])
                : "------";

            return StudentCard(
              name: name,
              status: status,
              dismissalTime: formattedTime,
            );
          },
        );
      },
    );
  }

  /// Fetch student documents using references stored in `children` array
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

  /// Display message if no children are found
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

  /// Format Firestore Timestamp to readable format
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return "${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}, ${dateTime.hour}:${dateTime.minute}:${dateTime.second}";
    }
    return "------";
  }

  /// Convert month number to month name
  String _getMonthName(int month) {
    const List<String> months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month - 1];
  }
}

/// **Student Card UI**
class StudentCard extends StatelessWidget {
  final String name;
  final String status;
  final String dismissalTime;

  const StudentCard({
    super.key,
    required this.name,
    required this.status,
    required this.dismissalTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3, 
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), 
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔹 Profile Image
            CircleAvatar(
              radius: 25, 
              backgroundColor: Colors.blue.shade100,
              child: Icon(
                Icons.person,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 12), 

            // 🔹 Name & Status
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
                    "Status: $status",
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ],
              ),
            ),

            // 🔹 Last Dismissal Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "Dismissal Time:",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey, 
                  ),
                ),
                Text(
                  dismissalTime,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}