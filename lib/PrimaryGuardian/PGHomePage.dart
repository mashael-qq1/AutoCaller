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
          style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
      bottomNavigationBar:
          const NavBarPG(loggedInGuardianId: "guardian_id"), // Attach NavBarPG
    );
  }
}
