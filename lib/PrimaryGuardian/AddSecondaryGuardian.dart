import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:autocaller/dynamic_link_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'NavBarPG.dart';

class AddSecondaryGuardian extends StatefulWidget {
  final String loggedInGuardianId;

  const AddSecondaryGuardian({super.key, required this.loggedInGuardianId});

  @override
  _AddSecondaryGuardianState createState() => _AddSecondaryGuardianState();
}

class _AddSecondaryGuardianState extends State<AddSecondaryGuardian> {
  final TextEditingController _guardianNameController = TextEditingController();
<<<<<<< HEAD
  final TextEditingController _guardianPhoneController = TextEditingController();
  List<Map<String, dynamic>> children = []; // Stores fetched students
  List<String> selectedChildren = []; // Stores selected child IDs
=======
  final TextEditingController _guardianPhoneController =
      TextEditingController();
  List<Map<String, dynamic>> children = [];
  List<String> selectedChildren = [];
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _fetchChildren(); // Fetch students on page load
  }

  /// **🔹 Fetches students linked to the Primary Guardian**
  Future<void> _fetchChildren() async {
    debugPrint("🔄 Fetching students for Guardian ID: ${widget.loggedInGuardianId}");

    try {
      DocumentSnapshot guardianDoc = await FirebaseFirestore.instance
          .collection('Primary Guardian')
          .doc(widget.loggedInGuardianId)
          .get();

      if (!guardianDoc.exists) {
        debugPrint("❌ No guardian document found.");
        return;
      }

      var data = guardianDoc.data() as Map<String, dynamic>?;

      if (data == null || !data.containsKey('children') || data['children'] == null) {
        debugPrint("❌ No 'children' field found in Firestore.");
        return;
      }

      List<dynamic> childRefs = data['children'];

      if (childRefs.isEmpty) {
        debugPrint("❌ Guardian has no students associated.");
        return;
      }

      debugPrint("✅ Found ${childRefs.length} students. Fetching details...");

      List<Map<String, dynamic>> tempChildren = [];

      for (var ref in childRefs) {
        try {
          DocumentReference childRef;
          if (ref is String) {
            debugPrint("🟡 Warning: Expected DocumentReference, got String: $ref");
            childRef = FirebaseFirestore.instance.doc(ref);
          } else {
            childRef = ref as DocumentReference;
          }

          DocumentSnapshot childDoc = await childRef.get();

          if (childDoc.exists) {
            tempChildren.add({
              'id': childDoc.id,
              'name': childDoc['Sname'] ?? "Unknown",
              'grade': childDoc['gradeLevel'] ?? "N/A", // Fetching only Name & Grade
            });
            debugPrint("✅ Loaded student: ${childDoc['Sname']}");
          } else {
            debugPrint("❌ Skipped missing student document: ${childRef.id}");
          }
        } catch (e) {
          debugPrint("❌ Error fetching student document: $e");
        }
      }

      if (mounted) {
        setState(() {
          children = tempChildren;
        });
      }

      debugPrint("✅ Successfully loaded ${children.length} students.");
    } catch (e) {
      debugPrint("❌ Error fetching students: $e");
    }
  }

  /// **🔹 Toggles student selection**
  void _toggleChildSelection(String childId) {
    setState(() {
      if (selectedChildren.contains(childId)) {
        selectedChildren.remove(childId);
      } else {
        selectedChildren.add(childId);
      }
    });
  }

  /// **🔹 Generates a Dynamic Link and shares it**
=======
    _fetchChildren();
  }

Future<void> _fetchChildren() async {
  try {
    DocumentSnapshot guardianDoc = await FirebaseFirestore.instance
        .collection('Primary Guardian')
        .doc(widget.loggedInGuardianId)
        .get();

    if (!guardianDoc.exists) return;

    var data = guardianDoc.data() as Map<String, dynamic>?;

    if (data == null || data['children'] == null) return;

    List<dynamic> childRefs = data['children'];
    List<Map<String, dynamic>> tempChildren = [];

    for (var ref in childRefs) {
      // Always get it like this because it's saved with full path
      DocumentReference childRef = FirebaseFirestore.instance.doc(ref.path);

      DocumentSnapshot childDoc = await childRef.get();

      if (childDoc.exists) {
        tempChildren.add({
          'id': childDoc.id,
          'name': childDoc['Sname'] ?? "Unknown",
          'grade': childDoc['gradeLevel'] ?? "N/A",
        });
      }
    }

    if (mounted) {
      setState(() {
        children = tempChildren;
      });
    }
  } catch (e) {
    debugPrint("❌ Error fetching students: $e");
  }
}

  void _toggleChildSelection(String childId) {
    setState(() {
      selectedChildren.contains(childId)
          ? selectedChildren.remove(childId)
          : selectedChildren.add(childId);
    });
  }

>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
  Future<void> _generateAndShareLink() async {
    if (_guardianNameController.text.isEmpty ||
        _guardianPhoneController.text.isEmpty ||
        selectedChildren.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
<<<<<<< HEAD
        const SnackBar(content: Text("Please enter all details and select at least one student.")),
=======
        const SnackBar(
            content: Text(
                "Please enter all details and select at least one student.")),
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
      );
      return;
    }

    String link = await DynamicLinkService.createDynamicLink(
      widget.loggedInGuardianId,
<<<<<<< HEAD
      selectedChildren.join(","), // Join multiple selected students
    );

    Share.share('You’ve been invited as a guardian. Click here: $link');
=======
      selectedChildren.join(","),
    );

    String message =
        "You have been invited To Autocaller as a Secondary Guardian to pick up the children. Please download the app and register using this link: $link";

    await Share.share(message);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Referral link shared successfully!")),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/ManageSG');
    });
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: Colors.white, // Match Dismissal Status Page
=======
      backgroundColor: Colors.white,
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Add Secondary Guardian",
<<<<<<< HEAD
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
=======
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
<<<<<<< HEAD
            // 🔹 Guardian Name Input
            _buildInputField("Secondary Guardian Name", "Enter Guardian Name", _guardianNameController),
            const SizedBox(height: 12),

            // 🔹 Guardian Phone Input
            _buildInputField("Guardian Phone Number", "Enter Phone Number", _guardianPhoneController,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 20),

            // 🔹 Student Selection Checklist
            const Text("Select Student(s) to Grant Access",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 8),
            Expanded(child: _buildStudentList()),

            const SizedBox(height: 10),

            // 🔹 Share Button
=======
            _buildInputField("Secondary Guardian Name", "Enter Guardian Name",
                _guardianNameController),
            const SizedBox(height: 12),
            _buildInputField("Guardian Phone Number", "Enter Phone Number",
                _guardianPhoneController,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            const Text("Select Student(s) to Grant Access",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(height: 8),
            Expanded(child: _buildStudentList()),
            const SizedBox(height: 10),
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
            _buildShareButton(),
          ],
        ),
      ),
<<<<<<< HEAD

      // 🔹 Bottom Navigation Bar
      bottomNavigationBar: NavBarPG(loggedInGuardianId: widget.loggedInGuardianId, currentIndex: 1),
    );
  }

  /// **🔹 Input Field Builder**
  Widget _buildInputField(String label, String hint, TextEditingController controller, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
=======
      bottomNavigationBar: NavBarPG(
          loggedInGuardianId: widget.loggedInGuardianId, currentIndex: 1),
    );
  }

  Widget _buildInputField(
      String label, String hint, TextEditingController controller,
      {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
<<<<<<< HEAD
                borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
=======
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
          ),
        ),
      ],
    );
  }

<<<<<<< HEAD
  /// **🔹 Builds the Student Selection List**
=======
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
  Widget _buildStudentList() {
    if (children.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
<<<<<<< HEAD

=======
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
    return ListView.builder(
      itemCount: children.length,
      itemBuilder: (context, index) {
        var student = children[index];
        return CheckboxListTile(
<<<<<<< HEAD
          title: Text("${student['name']} (Grade: ${student['grade']})"), // Name & Grade
=======
          title: Text("${student['name']} (Grade: ${student['grade']})"),
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
          value: selectedChildren.contains(student['id']),
          onChanged: (bool? value) {
            _toggleChildSelection(student['id']);
          },
          activeColor: Colors.blue.shade700,
        );
      },
    );
  }

<<<<<<< HEAD
  /// **🔹 Builds the Share Button**
=======
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
  Widget _buildShareButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _generateAndShareLink,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text("Generate & Share Link",
<<<<<<< HEAD
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
=======
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ),
    );
  }
}
>>>>>>> a862083c429fe302339e754937aaedbe94427d4b
