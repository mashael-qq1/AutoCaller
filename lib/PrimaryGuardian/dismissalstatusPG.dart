import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'NavBarPG.dart'; // Import the Primary Guardian NavBar

class DismissalStatusPG extends StatefulWidget {
  const DismissalStatusPG({super.key});

  @override
  _DismissalStatusPGState createState() => _DismissalStatusPGState();
}

class _DismissalStatusPGState extends State<DismissalStatusPG> {
  List<DocumentReference>? childrenRefs;
  String? guardianID;

  @override
  void initState() {
    super.initState();
    _fetchGuardianChildren();
  }

  /// Fetches the Guardian's `children` references using the logged-in email
  Future<void> _fetchGuardianChildren() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("❌ No guardian logged in");
      return;
    }

    guardianID = user.uid;
    debugPrint("📌 Guardian ID: $guardianID");

    try {
      var guardianQuery = await FirebaseFirestore.instance
          .collection('Primary Guardian')
          .where('userId', isEqualTo: guardianID) // Ensure correct field
          .get();

      if (guardianQuery.docs.isNotEmpty) {
        var guardianDoc = guardianQuery.docs.first;
        List<dynamic>? children = guardianDoc['children']; // ✅ Get `children` array

        if (children != null && children.isNotEmpty) {
          setState(() {
            childrenRefs = children.cast<DocumentReference>(); // ✅ Convert to DocumentReference List
          });

          debugPrint("✅ Retrieved ${childrenRefs!.length} children references.");
        } else {
          debugPrint("❌ No children found in guardian document.");
        }
      } else {
        debugPrint("❌ No guardian found with this ID.");
      }
    } catch (e) {
      debugPrint("❌ Error fetching children references: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ Match School Profile Page
      appBar: AppBar(
        title: const Text("My Children's Dismissal Status"),
        backgroundColor: Colors.transparent, // ✅ Removed blue
        elevation: 0, // ✅ Remove shadow
      ),
      body: Column(
        children: [
          Expanded(
            child: childrenRefs == null
                ? const Center(child: CircularProgressIndicator()) // Show loading spinner
                : _buildDismissalStatusList(),
          ),
        ],
      ),
      
      // ✅ Add NavBar at the bottom
      bottomNavigationBar: guardianID != null ? NavBarPG(loggedInGuardianId: guardianID!) : null,
    );
  }

  /// Fetches student data from Firestore using references stored in `children`
  Widget _buildDismissalStatusList() {
    if (childrenRefs == null || childrenRefs!.isEmpty) {
      debugPrint("❌ No children references available.");
      return _noChildrenFound();
    }

    return FutureBuilder<List<DocumentSnapshot>>(
      future: _fetchStudentDocuments(childrenRefs!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          debugPrint("❌ No children data found.");
          return _noChildrenFound();
        }

        var children = snapshot.data!;
        debugPrint("✅ Found ${children.length} children");

        return ListView.builder(
          itemCount: children.length,
          itemBuilder: (context, index) {
            var studentData = children[index].data() as Map<String, dynamic>? ?? {};

            // Extract student details
            String name = studentData['Sname'] ?? "Unknown";
            String status = studentData.containsKey('dismissalStatus') ? studentData['dismissalStatus'] : "Unknown";

            // Handle Firestore Timestamp
            String formattedTime = studentData.containsKey('lastDismissalTime') && studentData['lastDismissalTime'] != null
                ? _formatTimestamp(studentData['lastDismissalTime'])
                : "------";

            debugPrint("📌 Child: $name, Status: $status, Dismissal Time: $formattedTime");

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

  /// Fetches all student documents using the references
  Future<List<DocumentSnapshot>> _fetchStudentDocuments(List<DocumentReference> studentRefs) async {
    List<DocumentSnapshot> studentDocs = [];

    for (var ref in studentRefs) {
      try {
        var doc = await ref.get();
        if (doc.exists) {
          studentDocs.add(doc);
        } else {
          debugPrint("❌ Student document does not exist: ${ref.path}");
        }
      } catch (e) {
        debugPrint("❌ Error fetching student document: $e");
      }
    }

    return studentDocs;
  }

  /// Handles the case when no children are found
  Widget _noChildrenFound() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 40),
          SizedBox(height: 10),
          Text(
            "No children found",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ],
      ),
    );
  }

  /// Formats Firestore Timestamp into a readable string
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return "${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}, ${dateTime.hour}:${dateTime.minute}:${dateTime.second}";
    }
    return "------"; // Default if timestamp is missing
  }

  /// Converts month number to month name
  String _getMonthName(int month) {
    const List<String> months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return months[month - 1];
  }
}/// Student Card UI Component
class StudentCard extends StatelessWidget {
  final String name;
  final String status;
  final String dismissalTime;

  const StudentCard({super.key, required this.name, required this.status, required this.dismissalTime});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white, // ✅ Set background to white
      elevation: 0, // ✅ Remove shadow if needed
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300, width: 1), // ✅ Optional: Add subtle border
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blueAccent, // ✅ Keep blue for contrast
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black, // ✅ Ensure text color is black
          ),
        ),
        subtitle: Text(
          "Status: $status",
          style: const TextStyle(color: Colors.black), // ✅ Ensure subtitle is black
        ),
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