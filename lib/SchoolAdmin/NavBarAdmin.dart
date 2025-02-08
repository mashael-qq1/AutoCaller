import 'package:autocaller/PrimaryGuardian/signup.dart';
import 'package:flutter/material.dart';
import 'AdminHomePage.dart';
import 'DismissalStatus.dart';
import 'StudentListAdmin.dart';
import 'SchoolProfile.dart';
import 'package:autocaller/PrimaryGuardian/signup.dart';

class NavBarAdmin extends StatelessWidget {
  final int currentIndex;

  const NavBarAdmin({Key? key, required this.currentIndex}) : super(key: key);

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return; // Avoid unnecessary navigation

    switch (index) {
      case 0:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => DismissalStatus()));
        break;
      case 1:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => PrimaryGuardianSignUpPage()));
        break;
      case 2:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => SchoolAdminHomePage()));
        break;
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => StudentsPage()));
        break;
      case 4:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => SchoolProfilePage()));
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
          _buildNavItem(Icons.access_time, "Dismissal", 0, context),
          _buildNavItem(Icons.person_add, "Add Guardian", 1, context),
          _buildNavItem(Icons.home, "Home", 2, context),
          _buildNavItem(Icons.group, "Students", 3, context),
          _buildNavItem(Icons.account_circle, "Profile", 4, context),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, int index, BuildContext context) {
    return GestureDetector(
      onTap: () => _onItemTapped(context, index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: currentIndex == index ? Colors.blue : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              color: currentIndex == index ? Colors.blue : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
