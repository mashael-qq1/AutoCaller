import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'NavBarAdmin.dart'; // Import NavBar

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
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching schoolID: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes back button
        title: const Text(
          "Dismissal Status",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        centerTitle: true, // Centers the AppBar title
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: schoolRef == null
                ? const Center(child: CircularProgressIndicator())
                : _buildDismissalStatusList(),
          ),
        ],
      ),
      bottomNavigationBar: const NavBarAdmin(currentIndex: 0),
    );
  }

  Widget _buildDismissalStatusList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Student')
          .where('schoolID', isEqualTo: schoolRef)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _noStudentsFound();
        }

        var students = snapshot.data!.docs;

        return ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            var studentData = students[index].data() as Map<String, dynamic>;

            String name = studentData['Sname'] ?? "Unknown";
            String status = studentData['dismissalStatus'] ?? "Unknown";
            String formattedTime =
                _formatTimestamp(studentData['lastDismissalTime']);

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

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return "${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}, ${dateTime.hour}:${dateTime.minute}:${dateTime.second}";
    }
    return "------";
  }

  String _getMonthName(int month) {
    const List<String> months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[month - 1];
  }
}


/// **Student Card UI Component**
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
      color: Colors.white, // ✅ Keep background clean
      elevation: 0, // ✅ Remove shadow
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300, width: 1), // ✅ Subtle border
      ),
      child: Padding(
        padding: const EdgeInsets.all(12), // ✅ Adjust padding
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // ✅ Distribute space evenly
          children: [
            // Left side (Profile Picture)
            CircleAvatar(
              backgroundColor: Colors.blueAccent, // ✅ Keep blue for contrast
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 10), // ✅ Space between image and text
            
            // Center (Name & Status)
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
                  const SizedBox(height: 5), // ✅ Add small spacing
                  Text(
                    "Status: $status",
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Right side (Last Dismissal Time)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "Last Dismissal Time:",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey, // ✅ Distinct color
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
