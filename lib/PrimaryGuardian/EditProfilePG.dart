import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic>? guardianData;

  const EditProfilePage({
    super.key,
    required this.userId,
    required this.guardianData,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  late Map<String, dynamic> _editableGuardianData;
  String? _profilePhotoUrl;
  File? _newProfileImage;
  bool _removePhoto = false;

  @override
  void initState() {
    super.initState();
    _editableGuardianData =
        widget.guardianData != null ? Map.from(widget.guardianData!) : {};
    _loadUserData();
  }

  void _loadUserData() async {
    if (widget.guardianData != null) {
      _setUserFields(widget.guardianData!);
    } else {
      final doc = await FirebaseFirestore.instance
          .collection('Primary Guardian')
          .doc(widget.userId)
          .get();
      if (doc.exists) {
        _setUserFields(doc.data()!);
      }
    }
  }

  void _setUserFields(Map<String, dynamic> data) {
    setState(() {
      _editableGuardianData = data;
      _nameController.text = data['fullName'] ?? '';
      _emailController.text = data['email'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _profilePhotoUrl = data['profilePhotoUrl'];
    });
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _newProfileImage = File(picked.path);
        _removePhoto = false;
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_photos')
        .child('${widget.userId}.jpg');

    await storageRef.putFile(image);
    return await storageRef.getDownloadURL();
  }

  Future<void> _removeProfileImage() async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('${widget.userId}.jpg');
      await storageRef.delete();
    } catch (e) {
      // ignore if photo doesn't exist
    }

    setState(() {
      _profilePhotoUrl = null;
      _newProfileImage = null;
      _removePhoto = true;
    });
  }

  String? _validateName(String? value) {
    if (value == null  || value.trim().isEmpty) return "Name cannot be empty";
    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
      return "Only letters and spaces allowed";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null  || value.isEmpty) return "Email cannot be empty";
    if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value)) {
      return "Enter a valid email";
    }
    return null;
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      bool confirm = await _showConfirmationDialog(
        "Confirm Changes",
        "Are you sure you want to save changes?",
      );
      if (!confirm) return;

      String? photoUrl = _profilePhotoUrl;

      if (_removePhoto) {
        await _removeProfileImage();
        photoUrl = null;
      } else if (_newProfileImage != null) {
        photoUrl = await _uploadImage(_newProfileImage!);
      }

      await FirebaseFirestore.instance
          .collection('Primary Guardian')
          .doc(widget.userId)
          .update({
        'fullName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'profilePhotoUrl': photoUrl,
      }); 
if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:    Text("Profile updated successfully!", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
            //behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _cancelChanges() async {
    bool confirm = await _showConfirmationDialog(
      "Discard Changes?",
      "Are you sure you want to discard your changes?",
    );
    if (confirm) Navigator.pop(context);
  }

  Future<bool> _showConfirmationDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("No")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes")),
        ],
      ),
    );
    return result ?? false;
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color.fromARGB(255, 244, 244, 244),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    );
  }

  Widget _buildLabeledField(
    String label,
    TextEditingController controller,
    String? Function(String?)? validator, {
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          validator: validator,
          style: TextStyle(
            color: readOnly ? Colors.grey[600] : Colors.black,
          ),
          decoration: _fieldDecoration("Enter $label"),
        ),
      ],
    );
  }

  Widget _buildProfilePhoto() {
    Widget avatar;

    if (_newProfileImage != null) {
      avatar = CircleAvatar(
        radius: 50,
        backgroundImage: FileImage(_newProfileImage!),
      );
    } else if (_profilePhotoUrl != null && _profilePhotoUrl!.isNotEmpty) {
      avatar = CircleAvatar(
        radius: 50,
        backgroundImage: NetworkImage(_profilePhotoUrl!),
      );
    } else {
      avatar =CircleAvatar( // Wrap the Icon with CircleAvatar
                      radius: 50,
                          backgroundColor: Colors.blue.shade100, // Choose your desired background color
    child: Icon(
                  Icons.person,
                  size: 80,
                  color: Colors.blue.shade700,
                ),
              );
    }

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            avatar,
            GestureDetector(
              onTap: _pickImage,
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Icon(Icons.edit, size: 18, color: Colors.black),
              ),
            ),
          ],
        ),
        if (_profilePhotoUrl != null || _newProfileImage != null)
          TextButton.icon(
            onPressed: _removeProfileImage,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label: const Text("Remove Photo",
                style: TextStyle(color: Colors.red)),
          ),
      ],
    );
  } 
@override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const Text(
            "Edit Profile",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20),
                    child: Form(
                      key: _formKey,
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 20),
                            Center(child: _buildProfilePhoto()),
                            const SizedBox(height: 20),
                            _buildLabeledField(
                                "Your Name", _nameController, _validateName),
                            const SizedBox(height: 16),
                            _buildLabeledField("Your Email", _emailController,
                                _validateEmail),
                            const SizedBox(height: 16),
                            _buildLabeledField(
                              "Your Phone",
                              _phoneController,
                              null,
                              readOnly: true,
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _saveChanges,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text('Save Changes',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _cancelChanges,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: const Text('Cancel',
                                        style: TextStyle( 
color: Colors.black, fontSize: 16)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}