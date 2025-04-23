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
  List<Map<String, dynamic>> children = [];
  List<String> selectedChildren = [];

  @override
  void initState() {
    super.initState();
    _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    debugPrint("🔄 Fetching students for Guardian ID: ${widget.loggedInGuardianId}");

    setState(() => children = []); // Show loading indicator

    try {
      final guardianDoc = await FirebaseFirestore.instance
          .collection('Primary Guardian')
          .doc(widget.loggedInGuardianId)
          .get();

      final data = guardianDoc.data() as Map<String, dynamic>?;

      if (data == null || data['children'] == null) {
        debugPrint("❌ No children found.");
        return;
      }

      final childRefs = List.from(data['children']);
      final tempChildren = <Map<String, dynamic>>[];

      for (final ref in childRefs) {
        try {
          DocumentReference childRef;
          if (ref is String) {
            childRef = FirebaseFirestore.instance.doc(ref);
          } else {
            childRef = ref as DocumentReference;
          }

          final doc = await childRef.get();
          if (doc.exists) {
            tempChildren.add({
              'id': doc.id,
              'name': doc['Sname'] ?? 'Unknown',
              'grade': doc['gradeLevel'] ?? 'N/A',
            });
          }
        } catch (e) {
          debugPrint("❌ Error fetching child: $e");
        }
      }

      if (mounted) {
        setState(() {
          children = tempChildren;
        });
      }

      debugPrint("✅ Loaded ${children.length} students.");

    } catch (e) {
      debugPrint("❌ Error: $e");
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
    if (_guardianNameController.text.isEmpty || selectedChildren.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a name and select at least one student.")
        ),
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
            _buildInputField("Secondary Guardian Name", "Enter Guardian Name", _guardianNameController),
            const SizedBox(height: 20),
            const Text(
              "Select Student(s) to Grant Access",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
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
    String label,
    String hint,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
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
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentList() {
    return RefreshIndicator(
      onRefresh: _fetchChildren,
      child: children.isEmpty
          ? ListView(
              children: const [
                Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            )
          : ListView.builder(
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
            ),
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
        child: const Text(
          "Generate & Share Link",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}