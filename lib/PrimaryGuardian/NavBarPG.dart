import 'package:autocaller/PrimaryGuardian/PGprofile.dart';
import 'package:flutter/material.dart';
import '../PrimaryGuardian/PGHomePage.dart';
import '../PrimaryGuardian/dismissalstatusPG.dart';
import 'signup.dart'; // Add Guardian (Unfunctional for now)
import 'StudentListPG.dart';

class NavBarPG extends StatelessWidget {
  final String loggedInGuardianId;
  final int currentIndex;

  const NavBarPG(
      {super.key,
      required this.loggedInGuardianId,
      required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return; // Avoid unnecessary navigation

    switch (index) {
      case 0:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const DismissalStatusPG()));
        break;
      case 1:
        // No action for Add Guardian (unfunctional for now)
        break;
      case 2:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const GuardianHomePage()));
        break;
      case 3:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    StudentListPG(loggedInGuardianId: loggedInGuardianId)));
        break;
      case 4:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => PrimaryGuardianProfilePage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.access_time, 0, context), // Dismissal Status
          _buildNavItem(Icons.person_add, 1, context,
              isDisabled: true), // Add Guardian (Unfunctional)
          _buildNavItem(Icons.home, 2, context), // Home
          _buildNavItem(Icons.groups, 3, context), // Students
          _buildNavItem(Icons.person, 4, context), // Profile
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, BuildContext context,
      {bool isDisabled = false}) {
    return GestureDetector(
      onTap: isDisabled ? null : () => _onItemTapped(context, index),
      child: Icon(
        icon,
        color: currentIndex == index ? Colors.blue : Colors.grey,
        size: 28,
      ),
    );
  }
}
