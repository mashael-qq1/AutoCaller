import 'package:autocaller/PrimaryGuardian/ManageSG.dart';
import 'package:autocaller/PrimaryGuardian/PGprofile.dart';
import 'package:flutter/material.dart';
import '../PrimaryGuardian/PGHomePage.dart';
import '../PrimaryGuardian/dismissalstatusPG.dart';
import 'signup.dart'; // Add Guardian (Unfunctional for now)
import 'StudentListPG.dart';
import 'AddSecondaryGuardian.dart';
import 'ManageSG.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NavBarPG extends StatelessWidget {
  final String loggedInGuardianId;
  final int currentIndex;

  const NavBarPG({
    super.key,
    required this.loggedInGuardianId,
    required this.currentIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    print("Tapped on index: $index");

    if (index == currentIndex) return;

    switch (index) {
      case 0:
        print("Navigating to DismissalStatusPG");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DismissalStatusPG()),
        );
        break;
      case 1:
        print("Navigating to ManageSG");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ManageSG(loggedInGuardianId: loggedInGuardianId),
          ),
        );
        break;
      case 2:
        print("Navigating to GuardianHomePage");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GuardianHomePage()),
        );
        break;
      case 3:
        print("Navigating to StudentListPG");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                StudentListPG(loggedInGuardianId: loggedInGuardianId),
          ),
        );
        break;
      case 4:
        print("Navigating to PrimaryGuardianProfilePage");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PrimaryGuardianProfilePage()),
        );
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
          _buildNavItem(Icons.person_add, 1, context), // Add Guardian
          _buildNavItem(Icons.home, 2, context), // Home
          _buildNavItem(Icons.groups, 3, context), // Students
          _buildNavItem(Icons.person, 4, context), // Profile
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("Button pressed: Index $index");
        _onItemTapped(context, index);
      },
      child: Icon(
        icon,
        color: currentIndex == index ? Colors.blue : Colors.grey,
        size: 28,
      ),
    );
  }
}
