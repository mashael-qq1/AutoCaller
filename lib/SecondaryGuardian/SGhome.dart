import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:autocaller/SecondaryGuardian/NavBarSG.dart';

class SGhome extends StatefulWidget {
  final String loggedInGuardianId;
  const SGhome({super.key, required this.loggedInGuardianId});

  @override
  _SGhomeState createState() => _SGhomeState();
}

class _SGhomeState extends State<SGhome> {
  bool? isAuthorized;
  List<dynamic>? children;
  Set<String> selectedStudentIds = {};

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
        setState(() {
          isAuthorized = doc['isAuthorized'] ?? false;
          if (isAuthorized == true) children = doc['children'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching guardian data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Home Page',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildBody(),
      ),
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
    if (children == null || children!.isEmpty) {
      return const Center(child: Text('No students assigned.'));
    }

    return FutureBuilder<List<DocumentSnapshot>>(
      future:
          Future.wait(children!.map((ref) => (ref as DocumentReference).get())),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        var students = snapshot.data!;
        return _buildStudentListUI(students);
      },
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
            "You have been disabled by the Primary Guardian,\nyou no longer have access to their students.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentListUI(List<DocumentSnapshot> students) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Confirm Pickup',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 25,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 8),
                  child: Text(
                    'Select Student:',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Color.fromARGB(255, 117, 117, 117),
                    ),
                  ),
                ),
                ...students.asMap().entries.map((entry) {
                  int index = entry.key;
                  var student = entry.value;
                  String studentId = student['StudentID'];
                  String studentName = student['Sname'];
                  String photoUrl = student['photoUrl'] ?? '';
                  String dismissalStatus =
                      student['dismissalStatus'] ?? 'waiting';
                  bool isSelected = selectedStudentIds.contains(studentId);

                  return Column(
                    children: [
                      InkWell(
                        onTap: dismissalStatus == 'picked up'
                            ? null
                            : () {
                                setState(() {
                                  isSelected
                                      ? selectedStudentIds.remove(studentId)
                                      : selectedStudentIds.add(studentId);
                                });
                              },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                backgroundImage: photoUrl.isNotEmpty
                                    ? NetworkImage(photoUrl)
                                    : const AssetImage(
                                            'assets/default_avatar.png')
                                        as ImageProvider,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  studentName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              dismissalStatus == 'picked up'
                                  ? const Text(
                                      'Picked Up',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Icon(
                                      isSelected
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color: Colors.blue,
                                    ),
                            ],
                          ),
                        ),
                      ),
                      if (index < students.length - 1)
                        const Divider(
                          color: Colors.grey,
                          thickness: 0.5,
                          indent: 8,
                          endIndent: 8,
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: selectedStudentIds.isEmpty
                  ? null
                  : () async {
                      for (String studentId in selectedStudentIds) {
                        await _updateDismissalStatus(studentId);
                      }
                      setState(() => selectedStudentIds.clear());
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Confirm Pickup',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateDismissalStatus(String studentId) async {
    DocumentReference studentRef =
        FirebaseFirestore.instance.collection('Student').doc(studentId);

    await studentRef.update({
      'dismissalStatus': 'picked up',
      'pickupTimestamp': FieldValue.serverTimestamp(),
      'pickedUpBy': FirebaseAuth.instance.currentUser!.uid,
    });

    Future.delayed(const Duration(hours: 20), () async {
      await studentRef.update({
        'dismissalStatus': 'waiting',
        'pickupTimestamp': FieldValue.serverTimestamp(),
      });
    });
  }
}

