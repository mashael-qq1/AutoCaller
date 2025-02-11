import 'package:flutter/material.dart';
import 'package:autocaller/PrimaryGuardian/NavBarPG.dart';

class GuardianHomePage extends StatelessWidget {
  const GuardianHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the back button
        title: const Text(
          'Guardian Home',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Same bold font style as Profile page
            fontSize: 18, // Consistent font size
            color: Colors.black, // Black text for clarity
          ),
        ),
        centerTitle: true, // Centers the app bar title
        backgroundColor: Colors.white, // Sets the app bar background to white
        elevation: 0,
      ),
      backgroundColor:
          Colors.white, // Ensures the entire page has a white background
      body: const Center(
        child: Text(
          'Welcome to the Guardian Home Page!',
          style: TextStyle(
            fontSize: 16, // Adjusted to match other pages
            fontWeight: FontWeight.normal, // Matches profile page styling
            color: Colors.black, // Consistent text color
          ),
          textAlign: TextAlign.center,
        ),
      ),
      bottomNavigationBar:
          const NavBarPG(loggedInGuardianId: "guardian_id"), // Attach NavBarPG
    );
  }
}
