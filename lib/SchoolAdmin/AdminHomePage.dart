import 'package:flutter/material.dart';
import 'SchoolProfile.dart';

class SchoolAdminHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('School Admin Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 1200, // Limits the width of the page for larger screens
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Container to hold the welcome message and cards
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
                          'Welcome to SchoolFlow, the place where you can manage everything with ease!',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),

                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            'Manage your school profile, students, and dismissal status effortlessly with SchoolFlow.',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Horizontal scrolling for navigation cards
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal, // Horizontal scroll
                          child: Row(
                            children: [
                              _createNavCard(
                                context,
                                'School Profile',
                                Icons.school,
                                Colors.blue.shade500, // Consistent blue shade
                                () {
                                  // Navigate to School Profile
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SchoolProfilePage(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 20),
                              _createNavCard(
                                context,
                                'Associated Students',
                                Icons.people,
                                Colors.blue.shade600, // Slightly darker blue
                                () {
                                  // Navigate to Associated Students
                                },
                              ),
                              const SizedBox(width: 20),
                              _createNavCard(
                                context,
                                'Dismissal Status',
                                Icons.access_time,
                                Colors.blue.shade700, // Even darker blue
                                () {
                                  // Navigate to Dismissal Status
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to create a navigation card
  Widget _createNavCard(BuildContext context, String title, IconData icon, Color color, Function onTap) {
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
          width: 220, // Width of the card
          height: 220, // Height of the card
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

class SchoolProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('School Profile'),
        backgroundColor: Colors.blue.shade500,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.school,
              size: 100,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              'School Profile Details Here',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'You can edit or view your school\'s information here.',
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
