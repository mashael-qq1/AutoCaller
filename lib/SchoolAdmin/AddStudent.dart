// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors

import 'package:autocaller/SchoolAdmin/NavBarAdmin.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddStudentPage extends StatefulWidget {
  @override
  _AddStudentPageState createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _gradeLevelController = TextEditingController();
  final TextEditingController _guardianNameController = TextEditingController();
  final TextEditingController _guardianPhoneNumberController = TextEditingController();
  final TextEditingController _guardianEmailController = TextEditingController();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addStudent() async {
    String studentName = _studentNameController.text.trim();
    String gradeLevel = _gradeLevelController.text.trim();
    String guardianName = _guardianNameController.text.trim();
    String guardianPhoneNumber = _guardianPhoneNumberController.text.trim();
    String guardianEmail = _guardianEmailController.text.trim();

    if (studentName.isEmpty ||
        gradeLevel.isEmpty ||
        guardianName.isEmpty ||
        guardianPhoneNumber.isEmpty ||
        guardianEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required!")),
      );
      return;
    }

    try {
      // Check if a Primary Guardian already exists with the same name & phone number
      QuerySnapshot guardianQuery = await firestore
          .collection('Primary Guardian')
          .where('guardianPhoneNumber', isEqualTo: guardianPhoneNumber)
          .where('guardianName', isEqualTo: guardianName)
          .get();

      String primaryGuardianID;
      DocumentReference guardianRef;

      if (guardianQuery.docs.isNotEmpty) {
        // Guardian exists, get the ID
        guardianRef = guardianQuery.docs.first.reference;
        primaryGuardianID = guardianRef.id;
      } else {
        // Guardian does not exist, create a new one
        guardianRef = await firestore.collection('Primary Guardian').add({
          'guardianName': guardianName,
          'guardianPhoneNumber': guardianPhoneNumber,
          'guardianEmail': guardianEmail,
          'studentsID': [],
        });
        primaryGuardianID = guardianRef.id;
      }

      // Add Student to Firestore
      DocumentReference newStudentRef = await firestore.collection('Student').add({
        'Sname': studentName,
        'gradeLevel': gradeLevel,
        'primaryGuardianID': primaryGuardianID,
      });

      // Update Primary Guardian's studentsID array
      await guardianRef.update({
        'studentsID': FieldValue.arrayUnion([newStudentRef.id]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Student added successfully!")),
      );

      // Clear input fields
      _studentNameController.clear();
      _gradeLevelController.clear();
      _guardianNameController.clear();
      _guardianPhoneNumberController.clear();
      _guardianEmailController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text(
        "Add Student",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color.fromARGB(255, 0, 0, 0),
        ),
      ),
      automaticallyImplyLeading: false, 
      centerTitle: true, // Centers the title
      backgroundColor: Colors.white,
      elevation: 0, // Removes the shadow
    ),
      bottomNavigationBar:
          const NavBarAdmin(currentIndex: 1),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 255, 255, 255), Color.fromARGB(255, 255, 255, 255)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               
                SizedBox(height: 20),
                _buildTextField(_studentNameController, "Student Name"),
                _buildTextField(_gradeLevelController, "Student Level"),
                _buildTextField(_guardianNameController, "Gurdian Name"),
                _buildTextField(_guardianPhoneNumberController, "Guardian Phone Number"),
                _buildTextField( _guardianEmailController, "Gurdian Email"),
                SizedBox(height: 20),
               Center(
  child: Container(
    width: 200,  // Set width
    height: 50,  // Set height
    child: ElevatedButton(
      onPressed: () {
        // Add student logic here
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF23a8ff),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            "Add Student",
            style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    ),
  ),
)


              ],
            ),
          ),
        ),
      ),
    );
    
  }
 Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFF57636C)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(color: Colors.grey, width: 0.5),
          ),
           focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(color: const Color.fromARGB(255, 119, 118, 118), width: 0.5),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    _gradeLevelController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneNumberController.dispose();
    _guardianEmailController.dispose();
    super.dispose();
  }
}
