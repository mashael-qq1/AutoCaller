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
  final TextEditingController _guardianPhoneController =
      TextEditingController();
  List<Map<String, dynamic>> children = [];
  List<String> selectedChildren = [];

  @override
  void initState() {
    super.initState();
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

  Future<void> _generateAndShareLink() async {
    if (_guardianNameController.text.isEmpty ||
        _guardianPhoneController.text.isEmpty ||
        selectedChildren.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Please enter all details and select at least one student.")),
      );
      return;
    }

    String link = await DynamicLinkService.createDynamicLink(
      widget.loggedInGuardianId,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Add Secondary Guardian",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
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
            _buildShareButton(),
          ],
        ),
      ),
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
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
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
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ),
    );
  }
}
