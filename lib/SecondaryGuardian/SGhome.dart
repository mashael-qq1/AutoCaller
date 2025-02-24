import 'package:flutter/material.dart';
import 'package:autocaller/SecondaryGuardian/NavBarSG.dart';

class SGhome extends StatelessWidget {
  const SGhome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hello Secondary Guardian"),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: const Center(
        child: Text("Welcome to the Secondary Guardian Home Page"),
      ),
      bottomNavigationBar: const NavBarSG(
        loggedInGuardianId: "secondary_guardian_id",
        currentIndex: 0,
      ),
    );
  }
}