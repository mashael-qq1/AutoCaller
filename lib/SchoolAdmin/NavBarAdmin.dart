import 'package:autocaller/PrimaryGuardian/signup.dart';
import 'package:autocaller/SchoolAdmin/AddStudent.dart';
import 'package:flutter/material.dart';
import 'AdminHomePage.dart';
import 'DismissalStatus.dart';
import 'StudentListAdmin.dart';
import 'SchoolProfile.dart';

class NavBarAdmin extends StatelessWidget {
  final int currentIndex;

  const NavBarAdmin({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return; // Avoid unnecessary navigation

    switch (index) {
      case 0:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const DismissalStatus()));
        break;
      case 1:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => AddStudentPage()));
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
          _buildNavItem(Icons.access_time, 0, context), // Dismissal Status
          _buildNavItem(Icons.person_add, 1, context), // Add Guardian
          _buildNavItem(Icons.group, 3, context), // Students
          _buildNavItem(Icons.account_circle, 4, context), // Profile
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, BuildContext context) {
    return GestureDetector(
      onTap: () => _onItemTapped(context, index),
      child: Icon(
        icon,
        color: currentIndex == index ? Colors.blue : Colors.grey,
        size: 28, // Adjust size if needed
      ),
    );
  }
}
