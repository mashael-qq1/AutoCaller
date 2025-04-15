import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'NavBarSG.dart';

class DismissalStatusSG extends StatefulWidget {
  const DismissalStatusSG({super.key});

  @override
  _DismissalStatusSGState createState() => _DismissalStatusSGState();
}

class _DismissalStatusSGState extends State<DismissalStatusSG> {
  List<DocumentReference>? childrenRefs;
  bool? isAuthorized;

  @override
  void initState() {
    super.initState();
    _fetchGuardianData();
  }

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
            childrenRefs = (guardianDoc['children'] as List<dynamic>?)
                ?.cast<DocumentReference>();
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
        automaticallyImplyLeading: false,
        title: const Text("My Children's Dismissal Status",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar: NavBarSG(
          loggedInGuardianId: FirebaseAuth.instance.currentUser?.uid ?? "",
          currentIndex: 0),
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
        : _buildDismissalStatusList();
  }

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
        return ListView(
          children: snapshot.data!.map((doc) {
            var studentData = doc.data() as Map<String, dynamic>? ?? {};
            return StudentCard(
              name: studentData['Sname'] ?? "Unknown",
              status: studentData['dismissalStatus'] ?? "Unknown",
              dismissalTime: studentData['pickupTimestamp'] != null
                  ? _formatTimestamp(studentData['pickupTimestamp'])
                  : "------",
              photoUrl: studentData['photoUrl'],
            );
          }).toList(),
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
          Text("No students found",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red)),
        ],
      ),
    );
  }

  Widget _accessRevokedMessage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.block, color: Colors.red, size: 50),
          SizedBox(height: 10),
          Text(
            "You have been disabled by the Primary Guardian,\n you no longer have access to their students.",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
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
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[month - 1];
  }
}

class StudentCard extends StatelessWidget {
  final String name;
  final String status;
  final String dismissalTime;
  final String? photoUrl;

  const StudentCard({
    super.key,
    required this.name,
    required this.status,
    required this.dismissalTime,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
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
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black)),
                    Text("Status: $status",
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 14))
                  ]),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("Dismissal Time:",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
                Text(dismissalTime,
                    style: const TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
