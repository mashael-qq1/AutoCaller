import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IoTScreen extends StatelessWidget {
  final String schoolName;

  const IoTScreen({super.key, required this.schoolName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("IoT Screen - $schoolName"),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('School')
            .where('name', isEqualTo: schoolName)
            .limit(1)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No school found!"));
          }

          DocumentSnapshot schoolDoc = snapshot.data!.docs.first;
          // Get the schoolID as a DocumentReference
          DocumentReference schoolReference = schoolDoc.reference;

          print("School Reference: $schoolReference"); // Debugging: Print School Reference

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Student')
                .where('schoolID', isEqualTo: schoolReference) // Query using the DocumentReference
                .where('readyForPickup', isEqualTo: true)
                .where('absent', isEqualTo: false)
                .where('dismissalStatus', isNotEqualTo: 'Picked Up')
                .snapshots(),
            builder: (context, studentSnapshot) {
              if (studentSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (studentSnapshot.hasError) {
                print("Firestore Error: ${studentSnapshot.error}"); // Debugging
                return Center(child: Text("Error: ${studentSnapshot.error}"));
              }

              final students = studentSnapshot.data?.docs ?? [];

              if (students.isEmpty) {
                return Center(child: Text("No students are ready for pickup"));
              }

              return ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  var studentData = students[index].data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(studentData['Sname'] ?? 'Unknown'),
                    subtitle: Text(
                        'Grade: ${studentData['gradeLevel'] ?? 'N/A'}\nStatus: ${studentData['dismissalStatus'] ?? 'Not Confirmed'}'),
                    trailing: studentData['dismissalStatus'] == 'Picked Up'
                        ? Icon(Icons.check, color: Colors.green)
                        : null,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}