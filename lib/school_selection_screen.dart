import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'iot_screen.dart';

class SchoolSelectionScreen extends StatefulWidget {
  @override
  _SchoolSelectionScreenState createState() => _SchoolSelectionScreenState();
}

class _SchoolSelectionScreenState extends State<SchoolSelectionScreen> {
  String? selectedSchool;
  List<String> schoolNames = [];

  @override
  void initState() {
    super.initState();
    fetchSchools();
  }

  // Fetch schools from Firestore
  Future<void> fetchSchools() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('School').get();
      setState(() {
        schoolNames = snapshot.docs.map((doc) => doc['name'].toString()).toList();
      });
    } catch (e) {
      print("❌ Error fetching schools: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF), // Pure white at the top
              Color.fromARGB(255, 255, 255, 255), // Light blue transition
              Color.fromARGB(255, 96, 178, 245), // Deeper blue at the bottom
            ],
            stops: [0.0, 0.3, 1.0],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔹 App Logo (Same as on Welcome Screen)
            Image.asset(
              'assets/9-removebg-preview.png',
              height: 200.0,
              width: 200.0,
            ),
            const SizedBox(height: 20.0),

            // 🔹 Title Text: Indicating the screen is for dismissal
            const Text(
              'Dismissal Screen',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004AAD),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10.0),

            // 🔹 Description Text: Additional explanation
            const Text(
              'where you can manage students dismissal',
              style: TextStyle(
                fontSize: 16.0,
                color: Color.fromARGB(95, 22, 101, 154),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30.0),

            // 🔹 School Selection Text
            /*const Text(
              'Select Your School',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30.0), */

            // 🔹 School Dropdown
            DropdownButton<String>(
              value: selectedSchool,
              hint: const Text("Select a School"),
              style: const TextStyle(fontSize: 18.0, color: Colors.black),
              items: schoolNames.map((school) {
                return DropdownMenuItem(value: school, child: Text(school));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSchool = value;
                });
              },
            ),

            const SizedBox(height: 20.0),
             
// 🔹 Open IoT Screen Button
            SizedBox(
              width: 300.0,
              height: 55.0,
              child: ElevatedButton(
                onPressed: selectedSchool != null
                    ? () {
                        // Navigate to IoT Screen with the selected school name.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IoTScreen(schoolName: selectedSchool!),
                          ),
                        );
                      }
                    : null, // Disable the button if no school is selected
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text(
                  'Open Dismissal Screen',
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}