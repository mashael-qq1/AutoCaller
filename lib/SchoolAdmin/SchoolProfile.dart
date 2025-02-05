import 'package:flutter/material.dart';

class SchoolProfilePage extends StatelessWidget {
  // Mock data for the school profile
  final Map<String, String> schoolData = {
    'name': 'ABC School',
    'phoneNum': '123-456-7890',
    'email': 'contact@abcschool.com',
    'address': '123 Main St, Springfield, IL',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
  title: Text('School Profile'),
  backgroundColor: Colors.transparent,
  elevation: 0,
  //centerTitle: true, // This centers the title
),

      body: Container(
        color: Colors.transparent, // Set background color to white
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // School Logo (replace with your actual logo)
              Image.asset(
                'assets/logo.png', // Replace with your logo path
                height: 100,
              ),
              const SizedBox(height: 20),

              // Profile Information in a single container
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white, // Set background color to white
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // School Name
                    Text(
                      "School Name: ",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      schoolData['name'] ?? 'Not Available',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF57636C),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // School Phone Number
                    Text(
                      "Phone: ",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      schoolData['phoneNum'] ?? 'Not Available',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF57636C),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // School Email
                    Text(
                      "Email: ",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      schoolData['email'] ?? 'Not Available',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF57636C),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // School Address
                    Text(
                      "Address: ",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      schoolData['address'] ?? 'Not Available',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF57636C),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Logout Button (inside the container)
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle logout action here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF23a8ff),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}