import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AddSecondaryGuardian.dart'; // Ensure this import is correct
import 'NavBarPG.dart';

class ManageSG extends StatefulWidget {
  final String loggedInGuardianId;

  const ManageSG({super.key, required this.loggedInGuardianId});

  @override
  _ManageSGState createState() => _ManageSGState();
}

class _ManageSGState extends State<ManageSG> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Manage Secondary Guardians",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(child: _buildSecondaryGuardianList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddSecondaryGuardian(
                  loggedInGuardianId: widget.loggedInGuardianId),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: NavBarPG(
        loggedInGuardianId: widget.loggedInGuardianId,
        currentIndex: 1, // Set the index to match 'Add Guardian'
      ),
    );
  }

  Widget _buildSecondaryGuardianList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Secondary Guardian')
          .where('primaryGuardianID', isEqualTo: widget.loggedInGuardianId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No secondary guardians found"));
        }

        var secondaryGuardians = snapshot.data!.docs;

        return ListView.builder(
          itemCount: secondaryGuardians.length,
          itemBuilder: (context, index) {
            var guardianData =
                secondaryGuardians[index].data() as Map<String, dynamic>? ?? {};
            String guardianName = guardianData['FullName'] ?? "Unknown";

            return _buildGuardianCard(
                guardianName, secondaryGuardians[index].reference);
          },
        );
      },
    );
  }

  Widget _buildGuardianCard(String name, DocumentReference guardianRef) {
    return Card(
      color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => _removeGuardian(guardianRef),
          child: const Text("Remove", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Future<void> _removeGuardian(DocumentReference guardianRef) async {
    try {
      await guardianRef.update({'isAuthorized': false});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Secondary Guardian removed successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}
