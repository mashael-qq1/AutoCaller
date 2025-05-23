import 'package:flutter/material.dart';
import 'package:autocaller/SecondaryGuardian/SGhome.dart';
import 'package:autocaller/SecondaryGuardian/dissmisalstatusSG.dart';
import 'package:autocaller/SecondaryGuardian/profileSG.dart';
import 'package:autocaller/SecondaryGuardian/studentsListSG.dart';

class NavBarSG extends StatelessWidget {
  final String loggedInGuardianId;
  final int currentIndex;

  const NavBarSG({
    super.key,
    required this.loggedInGuardianId,
    required this.currentIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DismissalStatusSG()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                StudentListSG(loggedInGuardianId: loggedInGuardianId),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SGhome(loggedInGuardianId: loggedInGuardianId),
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SecondaryGuardianProfilePage(),
          ),
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
            _buildNavItem(Icons.groups, "Students", 1, context),
            _buildNavItem(Icons.home, "Home", 2, context),
            _buildNavItem(Icons.person, "Profile", 3, context),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    BuildContext context,
  ) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(context, index),
      child: SizedBox(
        height: 56,
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
  }
}
