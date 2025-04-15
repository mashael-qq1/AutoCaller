import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DismissalHistoryPage extends StatelessWidget {
  final String studentId;

  const DismissalHistoryPage({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Dismissal History",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('Student').doc(studentId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Student data not found."));
          }

          final studentData = snapshot.data!.data() as Map<String, dynamic>?;

          if (studentData == null) {
            return const Center(child: Text("Student data is empty."));
          }

          List<dynamic> history = studentData.entries
              .firstWhere(
                  (e) => e.key.trim() == 'dismissalHistory',
                  orElse: () => const MapEntry('dismissalHistory', []))
              .value;

          if (history.isEmpty) {
            return const Center(child: Text("No dismissal history available."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: history.length,
            itemBuilder: (context, index) {
              var entry = history[index];
              DateTime time = (entry['timestamp'] as Timestamp).toDate();
              String status = entry['status'];

              return Card(
                color: Colors.white, // ✅ force white background
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(Icons.history, color: Colors.blue.shade700),
                  ),
                  title: Text(
                    "${time.day}/${time.month}/${time.year} - ${time.hour}:${time.minute.toString().padLeft(2, '0')}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
                  ),
                  subtitle: Text(
                    "Status: $status",
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black54),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}