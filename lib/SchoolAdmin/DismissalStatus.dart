import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  /// Fetches the school ID associated with the logged-in admin.
  Future<void> _fetchAdminSchoolID() async {
    String? adminEmail = FirebaseAuth.instance.currentUser?.email;
    if (adminEmail == null) {
      debugPrint("❌ No admin email found");
      return;
    }

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
          debugPrint("✅ Retrieved schoolID: ${schoolRef!.path}");
        } else {
          debugPrint("❌ Unexpected schoolID type: ${schoolReference.runtimeType}");
        }
      } else {
        debugPrint("❌ No admin found with this email.");
      }
    } catch (e) {
      debugPrint("❌ Error fetching schoolID: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dismissal Status"),
        backgroundColor: Colors.blue,
      ),
      body: schoolRef == null
          ? const Center(child: CircularProgressIndicator()) // Show loading spinner
          : _buildDismissalStatusList(),
    );
  }

  /// Fetches students linked to the school
  Widget _buildDismissalStatusList() {
    debugPrint("✅ Querying students with schoolID: '${schoolRef!.path}'");

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Student')
          .where('schoolID', isEqualTo: schoolRef) // Use DocumentReference comparison
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          debugPrint("❌ No students found for schoolID: ${schoolRef!.path}");
          return _noStudentsFound();
        }

        var students = snapshot.data!.docs;
        debugPrint("✅ Found ${students.length} students");

        return ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            var studentData = students[index].data() as Map<String, dynamic>;

            // Extract student details
            String name = studentData['Sname'] ?? "Unknown";
            String status = studentData['dismissalStatus'] ?? "Unknown";

            // Handle Firestore Timestamp
            String formattedTime = _formatTimestamp(studentData['lastDismissalTime']);

            debugPrint("📌 Student: $name, Status: $status, Dismissal Time: $formattedTime");

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

  /// Handles the case when no students are found
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

  /// **Corrected Timestamp Handling**
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp != null) {
      if (timestamp is Timestamp) {
        DateTime dateTime = timestamp.toDate();
        return "${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}, ${dateTime.hour}:${dateTime.minute}:${dateTime.second}";
      } else {
        debugPrint("❌ Unexpected type for timestamp: ${timestamp.runtimeType}");
      }
    }
    return "------"; // Default if timestamp is null or missing
  }

  /// Converts month number to month name
  String _getMonthName(int month) {
    const List<String> months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return months[month - 1];
  }
}

/// **Student Card UI Component**
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