import 'package:autocaller/PrimaryGuardian/signup.dart';
import 'package:autocaller/SchoolAdmin/StudentListAdmin.dart';
import 'package:flutter/material.dart';
import 'SchoolProfile.dart';
import 'package:autocaller/SchoolAdmin/DismissalStatus.dart';

class SchoolAdminHomePage extends StatelessWidget {
  const SchoolAdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFF90CAF9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: const Text('School Admin Dashboard'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false, // Removes the back button
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 1200,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Adjusts to child size
                        children: [
                          const SizedBox(height: 20),

                          // Container for welcome message and cards
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 3,
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Welcome to AutoCaller, the place where you can manage everything with ease!',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 30),

                                const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 20.0),
                                  child: Text(
                                    'Manage your school profile, students, and dismissal status effortlessly with AutoCaller.',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // Horizontal scrolling for navigation cards
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _createNavCard(
                                        context,
                                        'School Profile',
                                        Icons.school,
                                        Colors.blue.shade500,
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SchoolProfilePage(),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 20),
                                      _createNavCard(
                                        context,
                                        'Associated Students',
                                        Icons.people,
                                        Colors.blue.shade600,
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  StudentsPage(),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 20),
                                      _createNavCard(
                                        context,
                                        'Dismissal Status',
                                        Icons.access_time,
                                        Colors.blue.shade700,
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const DismissalStatus()),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 20),
                                      
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create a navigation card
  Widget _createNavCard(BuildContext context, String title, IconData icon,
      Color color, Function onTap) {
    return GestureDetector(
      onTap: () => onTap(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.6),
              spreadRadius: 2,
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SizedBox(
          width: 220,
          height: 220,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 60, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
