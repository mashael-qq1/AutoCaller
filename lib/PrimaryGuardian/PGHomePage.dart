import 'package:flutter/material.dart';
import 'package:autocaller/PrimaryGuardian/NavBarPG.dart';

class GuardianHomePage extends StatelessWidget {
  const GuardianHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Guardian Home',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true, // Centers the app bar title
        backgroundColor: Colors.white, // Makes the app bar white
        elevation: 0,
      ),
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
