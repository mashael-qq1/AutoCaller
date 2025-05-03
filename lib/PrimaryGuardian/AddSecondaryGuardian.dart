import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:autocaller/dynamic_link_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'NavBarPG.dart';

class AddSecondaryGuardian extends StatefulWidget {
  final String loggedInGuardianId;

  const AddSecondaryGuardian({super.key, required this.loggedInGuardianId});

  @override
  _AddSecondaryGuardianState createState() => _AddSecondaryGuardianState();
}

class _AddSecondaryGuardianState extends State<AddSecondaryGuardian> {
  final TextEditingController _guardianNameController = TextEditingController();
  List<Map<String, dynamic>> children = [];
  List<String> selectedChildren = [];

  @override
  void initState() {
    super.initState();
    _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    debugPrint(
        "🔄 Fetching students for Guardian ID: ${widget.loggedInGuardianId}");

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

      if (data == null ||
          !data.containsKey('children') ||
          data['children'] == null) {
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
            debugPrint(
                "🟡 Warning: Expected DocumentReference, got String: $ref");
            childRef = FirebaseFirestore.instance.doc(ref);
          } else {
            childRef = ref as DocumentReference;
          }

          DocumentSnapshot childDoc = await childRef.get();

          if (childDoc.exists) {
            tempChildren.add({
              'id': childDoc.id,
              'name': childDoc['Sname'] ?? "Unknown",
              'grade': childDoc['gradeLevel'] ?? "N/A",
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

  void _toggleChildSelection(String childId) {
    setState(() {
      if (selectedChildren.contains(childId)) {
        selectedChildren.remove(childId);
      } else {
        selectedChildren.add(childId);
      }
    });
  }

  Future<void> _generateAndShareLink() async {
    String name = _guardianNameController.text.trim();

    final nameRegex = RegExp(r"^(?!\d+$)[a-zA-Z0-9 ]{1,20}$");

    if (!nameRegex.hasMatch(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Invalid name. Use 1–20 characters, no special symbols, and not only numbers.")),
      );
      return;
    }

    if (selectedChildren.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one student.")),
      );
      return;
    }

    String link = await DynamicLinkService.createDynamicLink(
      widget.loggedInGuardianId,
      selectedChildren.join(","),
    );

    Share.share('You’ve been invited as a guardian. Click here: $link');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add Secondary Guardian",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField("Secondary Guardian Name", "Enter Guardian Name",
                _guardianNameController),
            const SizedBox(height: 20),
            const Text("Select Student(s) to Grant Access",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(height: 8),
            Expanded(child: _buildStudentList()),
            const SizedBox(height: 10),
            _buildShareButton(),
          ],
        ),
      ),
      bottomNavigationBar: NavBarPG(
        loggedInGuardianId: widget.loggedInGuardianId,
        currentIndex: 1,
      ),
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
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            filled: true,
            fillColor: const Color.fromARGB(255, 244, 244, 244),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30), // ✅ rounded like reset
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentList() {
    if (children.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: children.length,
      itemBuilder: (context, index) {
        var student = children[index];
        return CheckboxListTile(
          title: Text("${student['name']} (Grade: ${student['grade']})"),
          value: selectedChildren.contains(student['id']),
          onChanged: (bool? value) {
            _toggleChildSelection(student['id']);
          },
          activeColor: Colors.blue.shade700,
        );
      },
    );
  }

  Widget _buildShareButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _generateAndShareLink,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Generate & Share Link',
          style: TextStyle(
              color: Color.fromARGB(255, 247, 245, 245), fontSize: 16),
        ),
      ),
    );
  }
}
