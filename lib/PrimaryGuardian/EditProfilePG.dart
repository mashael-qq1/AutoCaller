// EditProfilePG.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic>? guardianData;

  const EditProfilePage({Key? key, required this.userId, required this.guardianData}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _editableGuardianData;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _editableGuardianData = widget.guardianData != null
        ? Map.from(widget.guardianData!)
        : {};
    _loadUserData();
  }

  void _loadUserData() {
    if (widget.guardianData != null) {
      setState(() {
        _editableGuardianData = Map.from(widget.guardianData!);
        _nameController.text = _editableGuardianData['fullName'] ?? '';
        _emailController.text = _editableGuardianData['email'] ?? '';
        _phoneController.text = _editableGuardianData['phone'] ?? '';
      });
    } else {
      FirebaseFirestore.instance
          .collection('Primary Guardian')
          .doc(widget.userId)
          .get()
          .then((userDoc) {
        if (userDoc.exists) {
          setState(() {
            _editableGuardianData = userDoc.data() as Map<String, dynamic>;
            _nameController.text = _editableGuardianData['fullName'] ?? '';
            _emailController.text = _editableGuardianData['email'] ?? '';
            _phoneController.text = _editableGuardianData['phone'] ?? '';
          });
        }
      });
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Name cannot be empty or only spaces";
    }
    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
      return "Only letters and spaces allowed";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email cannot be empty";
    }
    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
      return "Enter a valid email address";
    }
    return null;
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      bool confirm = await _showConfirmationDialog("Confirm Changes", "Are you sure you want to save changes?");
      if (confirm) {
        await FirebaseFirestore.instance
            .collection('Primary Guardian')
            .doc(widget.userId)
            .update({
          'fullName': _nameController.text.trim(),
          'email': _emailController.text.trim(),
        });
        Navigator.pop(context, true); // Pass true back to the previous screen
      }
    }
  }

  void _cancelChanges() async {
    bool confirm = await _showConfirmationDialog("Discard Changes?", "Are you sure you want to discard your changes?");
    if (confirm) {
      Navigator.pop(context);
    }
  }

  Future<bool> _showConfirmationDialog(String title, String message) async {
    bool? result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("Yes"),
              ),
            ],
          ),
        );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Edit Profile"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Icon(
                    Icons.account_circle,
                    size: 100,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 20),
                Text("Your Name", style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: "Enter your name",
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontStyle: FontStyle.italic,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateName,
                  onChanged: (value) {
                    _editableGuardianData['fullName'] = value;
                  },
                ),
                SizedBox(height: 10),
                Text("Your Email", style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Enter your email",
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontStyle: FontStyle.italic,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateEmail,
                  onChanged: (value) {
                    _editableGuardianData['email'] = value;
                  },
                ),
                SizedBox(height: 10),
                Text("Your Phone", style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    hintText: "Your phone number",
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontStyle: FontStyle.italic,
                    ),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  readOnly: true,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _saveChanges,
                      child: Text("Save Changes", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF23a8ff),
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _cancelChanges,
                      child: Text("Cancel", style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}