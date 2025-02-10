import 'package:autocaller/PrimaryGuardian/PGprofile.dart';
import 'package:flutter/material.dart';
import '../PrimaryGuardian/PGHomePage.dart';
import '../PrimaryGuardian/dismissalstatusPG.dart';
// ignore: unused_import
import '../PrimaryGuardian/signup.dart'; // Add Guardian (Unfunctional for now)
import '../PrimaryGuardian/StudentListPG.dart';

class NavBarPG extends StatelessWidget {
  final String loggedInGuardianId;

  const NavBarPG({super.key, required this.loggedInGuardianId});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.access_time, '',
              const DismissalStatusPG()),
          _buildNavItem(context, Icons.person_add, '',
              null), // Unfunctional for now
          _buildNavItem(context, Icons.home, '', const GuardianHomePage()),
          _buildNavItem(context, Icons.groups, '',
              StudentListPG(loggedInGuardianId: loggedInGuardianId)),
          _buildNavItem(
              context, Icons.person, '', PrimaryGuardianProfilePage()),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, String label, Widget? page) {
    return InkWell(
      onTap: page != null
          ? () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page),
              )
          : null, // Disabled for "Add Guardian"
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.grey.shade700),
          Text(label, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
