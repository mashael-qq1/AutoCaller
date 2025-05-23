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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.access_time, "Status", 0, context),
            _buildNavItem(Icons.person_add, "Guardians", 1, context),
            _buildNavItem(Icons.home, "Home", 2, context),
            _buildNavItem(Icons.groups, "Students", 3, context),
            _buildNavItem(Icons.person, "Profile", 4, context),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon, String label, int index, BuildContext context) {
  final isSelected = currentIndex == index;

  return GestureDetector(
    onTap: () {
      _onItemTapped(context, index);
    },
    child: SizedBox(
      height: 56, // Adjust this if needed
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? Colors.blue : Colors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
    }}