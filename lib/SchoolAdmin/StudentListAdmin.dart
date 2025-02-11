import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'NavBarAdmin.dart'; // Import the NavBarAdmin

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes back button
        title: const Text(
          'Students',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Ensures consistency
            fontSize: 18,
            color: Colors.black, // Matches other pages
          ),
        ),
        centerTitle: true, // Centers the title
        backgroundColor: Colors.white, // White background
        elevation: 0, // Removes shadow
      ),
      bottomNavigationBar:
          const NavBarAdmin(currentIndex: 3), // Set index 3 for Students
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('Student').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No students found.'));
            }

            final students = snapshot.data!.docs;

            return ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final name = student['Sname'] ?? 'Unknown';
                final gradeLevel = student['gradeLevel'] ?? 'N/A';

                return Card(
                  color: Colors.white,
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(
                        Icons.person,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text('Grade: $gradeLevel'),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
