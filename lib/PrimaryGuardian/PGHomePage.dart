import 'package:flutter/material.dart';
import 'package:autocaller/PrimaryGuardian/NavBarPG.dart';

class GuardianHomePage extends StatelessWidget {
  const GuardianHomePage({super.key});

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Below is a summary of your activities.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
           Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Reduces space between cards
  children: [
    _buildSummaryCard('Associated Students', '3', Icons.group),
    _buildSummaryCard('Dismissals', '2', Icons.home),
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
              'Select Student:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildStudentList(),
          ],
        )
        ),
      ),
      bottomNavigationBar:
          const NavBarPG(loggedInGuardianId: "guardian_id",currentIndex:2),
    );
  }

 Widget _buildSummaryCard(String title, String value, IconData icon) {
  return Expanded( // Ensures both cards take equal space and prevent overflow
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
            const SizedBox(width: 8), // Reduced spacing between icon and text
            Expanded( // Prevents text from causing overflow
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    overflow: TextOverflow.ellipsis, // Prevents text from overflowing
                    maxLines: 1,
                  ),
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
              children: [

                const Text(
                  'Tuesday, 10:00am',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
                Chip(
                  label: const Text('In Progress'),
                  backgroundColor: Colors.grey[400],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    List<String> students = ['Ali Al-Hassan', 'Khaled Al-Hassan', 'Sara Al-Hassan'];
    return Column(
      children: students.map((student) {
        return Card(
          color: Colors.white, 
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(student, style: const TextStyle(fontSize: 16)),
            trailing: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Confirm Pickup', style: TextStyle(color: Colors.white)),
            ),
          ),
        );
      }).toList(),
    );
  }
}

