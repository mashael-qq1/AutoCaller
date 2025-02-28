import 'package:flutter/material.dart';
import 'package:autocaller/SecondaryGuardian/SGhome.dart';
import 'package:autocaller/SecondaryGuardian/dissmisalstatusSG.dart';
import 'package:autocaller/SecondaryGuardian/profileSG.dart';
import 'package:autocaller/SecondaryGuardian/studentsListSG.dart';

class NavBarSG extends StatelessWidget {
  final String loggedInGuardianId;
  final int currentIndex;

  const NavBarSG(
      {super.key,
      required this.loggedInGuardianId,
      required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    print("Tapped on index: $index");

    if (index == currentIndex) return;

    switch (index) {
      case 0:
        print("Navigating to DismissalStatusSG");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DismissalStatusSG()),
        );
        break;
      case 1:
        print("Navigating to SGStudentList");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  StudentListSG(loggedInGuardianId: loggedInGuardianId)),
        );
        break;
      case 2:
        print("Navigating to SGhome");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SGhome()),
        );
        break;
      case 3:
        print("Navigating to SGProfile");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => SecondaryGuardianProfilePage()),
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
          _buildNavItem(Icons.groups, 1, context), // View Students
          _buildNavItem(Icons.home, 2, context), // Home (Centered)
          _buildNavItem(Icons.person, 3, context), // View Profile
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
