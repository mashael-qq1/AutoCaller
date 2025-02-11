import 'package:flutter/material.dart';
import 'dismissalstatusPG.dart'; // Import your dismissal status page
import 'PGprofile.dart';
import 'package:autocaller/PrimaryGuardian/NavBarPG.dart';

class GuardianHomePage extends StatelessWidget {
  const GuardianHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Guardian Home',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Centers the app bar title
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to the Guardian Home Page!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to DismissalStatusPG
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DismissalStatusPG()),
                );
              },
              child: const Text('View Dismissal Status'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to GuardianProfile
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PrimaryGuardianProfilePage()),
                );
              },
              child: const Text('View Profile'),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          const NavBarPG(loggedInGuardianId: "guardian_id"), // Attach NavBarPG
    );
  }
}
