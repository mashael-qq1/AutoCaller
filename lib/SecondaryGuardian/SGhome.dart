import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:autocaller/SecondaryGuardian/NavBarSG.dart';

class SGhome extends StatefulWidget {
  final String loggedInGuardianId;
  const SGhome({super.key, required this.loggedInGuardianId});

  @override
  _GuardianHomePageState createState() => _GuardianHomePageState();
}

class _GuardianHomePageState extends State<SGhome> {
  Map<String, bool> isLoading = {};
  bool? isAuthorized;
  List<dynamic>? children;

  @override
  void initState() {
    super.initState();
    _fetchGuardianData();
  }

  Future<void> _fetchGuardianData() async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection('Secondary Guardian')
          .doc(widget.loggedInGuardianId)
          .get();

      if (doc.exists) {
        bool authorized = doc['isAuthorized'] ?? false;
        setState(() {
          isAuthorized = authorized;
          if (authorized) {
            children = doc['children'] ?? [];
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching guardian data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Home Page',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: _buildBody(),
      bottomNavigationBar: NavBarSG(
        loggedInGuardianId: widget.loggedInGuardianId,
        currentIndex: 2,
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
    if (children == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Confirm Pickup',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildStudentList(),
          ],
        ),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    return Column(
      children: children!.map<Widget>((childRef) {
        return StreamBuilder<DocumentSnapshot>(
          stream: childRef.snapshots(),
          builder: (context, studentSnapshot) {
            if (studentSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (studentSnapshot.hasError) {
              return const Center(child: Text('Error fetching student data.'));
            }
            if (!studentSnapshot.hasData || studentSnapshot.data == null) {
              return const Center(child: Text('Student not found.'));
            }

            var studentData = studentSnapshot.data!;
            String studentName = studentData['Sname'] ?? 'Unknown';
            String studentPhotoUrl = studentData['photoUrl'] ?? '';
            String studentId = studentData['StudentID'];
            String dismissalStatus =
                studentData['dismissalStatus'] ?? 'waiting';

            bool loading = isLoading[studentId] ?? false;

            return Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  backgroundImage: studentPhotoUrl.isNotEmpty
                      ? NetworkImage(studentPhotoUrl)
                      : const AssetImage('assets/default_avatar.png')
                          as ImageProvider,
                ),
                title: Text(studentName, style: const TextStyle(fontSize: 16)),
                trailing: ElevatedButton(
                  onPressed: () {
                    if (dismissalStatus != 'picked up') {
                      setState(() {
                        isLoading[studentId] = true;
                      });
                      _updateDismissalStatus(studentId);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          dismissalStatus == 'picked up'
                              ? 'Picked Up'
                              : 'Confirm Pickup',
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Future<void> _updateDismissalStatus(String studentId) async {
    DocumentReference studentRef =
        FirebaseFirestore.instance.collection('Student').doc(studentId);

    await studentRef.update({
      'dismissalStatus': 'picked up',
      'pickupTimestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      isLoading[studentId] = false;
    });

    Future.delayed(const Duration(hours: 20), () async {
      await studentRef.update({
        'dismissalStatus': 'waiting',
        'pickupTimestamp': FieldValue.serverTimestamp(),
      });
    });
  }
}
