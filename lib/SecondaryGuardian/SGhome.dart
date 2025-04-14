import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autocaller/SecondaryGuardian/NavBarSG.dart';

class SGhome extends StatefulWidget {
  final String loggedInGuardianId;
  const SGhome({super.key, required this.loggedInGuardianId});

  @override
  State<SGhome> createState() => _SGhomeState();
}

class _SGhomeState extends State<SGhome> {
  List<Map<String, dynamic>> students = [];
  bool isLoading = true;
  bool? isAuthorized;

  @override
  void initState() {
    super.initState();
    fetchGuardianAndStudents();
  }

  Future<void> fetchGuardianAndStudents() async {
    try {
      final sgDoc = FirebaseFirestore.instance
          .collection('Secondary Guardian')
          .doc(widget.loggedInGuardianId);

      final docSnapshot = await sgDoc.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        final bool guardianIsAuthorized = data['isAuthorized'] ?? false;

        setState(() {
          isAuthorized = guardianIsAuthorized;
        });

        if (guardianIsAuthorized) {
          final List<dynamic>? childrenRefs = data['children'];

          List<Map<String, dynamic>> fetchedStudents = [];

          if (childrenRefs != null) {
            for (var ref in childrenRefs) {
              DocumentReference studentRef = ref as DocumentReference;
              final studentDoc = await studentRef.get();

              if (studentDoc.exists) {
                fetchedStudents.add(studentDoc.data()! as Map<String, dynamic>);
              }
            }
          }

          setState(() {
            students = fetchedStudents;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching guardian or students: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Dashboard',
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (isAuthorized == false
              ? _accessRevokedMessage()
              : _buildAuthorizedContent()),
      bottomNavigationBar: NavBarSG(
        loggedInGuardianId: widget.loggedInGuardianId,
        currentIndex: 2,
      ),
    );
  }

  Widget _buildAuthorizedContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Below is a summary of your activities.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryCard('Associated Students',
                    students.length.toString(), Icons.group),
                _buildSummaryCard('Dismissals', '1', Icons.home),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Confirm Pickup',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildPickupCard(),
            const SizedBox(height: 16),
            const Text(
              'Associated Student:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildStudentList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Icon(icon, color: Colors.blue, size: 28),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(title,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickupCard() {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Image.asset(
            'assets/Screenshot 2025-02-11 at 2.12.38 PM.png',
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Tuesday, 10:00am',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
                Chip(
                  label: Text('In Progress'),
                  backgroundColor: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    if (students.isEmpty) {
      return const Text("No associated students.");
    }

    return Column(
      children: students.map((student) {
        String name = student['Sname'] ?? student['name'] ?? 'Unnamed';
        return Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(name, style: const TextStyle(fontSize: 16)),
            trailing: ElevatedButton(
              onPressed: () {
                // Handle pickup logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Confirm Pickup',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        );
      }).toList(),
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
}
