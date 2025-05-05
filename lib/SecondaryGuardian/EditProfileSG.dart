import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileSG extends StatefulWidget {
  final String userId;
  final Map<String, dynamic>? guardianData;

  const EditProfileSG({
    super.key,
    required this.userId,
    required this.guardianData,
  });

  @override
  _EditProfileSGState createState() => _EditProfileSGState();
}

class _EditProfileSGState extends State<EditProfileSG> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _editableGuardianData;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  File? _selectedImage;
  String? _photoUrl;
  bool _isRemovingPhoto = false;

  @override
  void initState() {
    super.initState();
    _editableGuardianData =
        widget.guardianData != null ? Map.from(widget.guardianData!) : {};
    _loadUserData();
  }

  void _loadUserData() async {
    if (widget.guardianData != null) {
      setState(() {
        _editableGuardianData = Map.from(widget.guardianData!);
        _nameController.text = _editableGuardianData['FullName'] ?? '';
        _emailController.text = _editableGuardianData['email'] ?? '';
        _phoneController.text = _editableGuardianData['PhoneNum'] ?? '';
        _photoUrl = _editableGuardianData['photoUrl'];
      });
    } else {
      var userDoc = await FirebaseFirestore.instance
          .collection('Secondary Guardian')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          _editableGuardianData = userDoc.data() as Map<String, dynamic>;
          _nameController.text = _editableGuardianData['FullName'] ?? '';
          _emailController.text = _editableGuardianData['email'] ?? '';
          _phoneController.text = _editableGuardianData['PhoneNum'] ?? '';
          _photoUrl = _editableGuardianData['photoUrl'];
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _isRemovingPhoto = false;
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('guardian_photos')
          .child('${widget.userId}.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Image upload failed: $e");
      return null;
    }
  }

  Future<void> _removePhoto() async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('guardian_photos')
          .child('${widget.userId}.jpg');
      await storageRef.delete();
    } catch (e) {
      // ignore if photo doesn't exist
    }

    setState(() {
      _photoUrl = null;
      _selectedImage = null;
      _isRemovingPhoto = true;
    });
  }

  String? _validateName(String? value) {
    if (value == null  || value.trim().isEmpty) {
      return "Name cannot be empty";
    }
    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
      return "Only letters and spaces allowed";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null  || value.isEmpty) {
      return "Email cannot be empty";
    }
    if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value)) {
      return "Enter a valid email";
    }
    return null;
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      bool confirm = await _showConfirmationDialog(
          "Confirm Changes", "Are you sure you want to save changes?");
      if (confirm) {
        String? uploadedUrl = _photoUrl; 
if (_isRemovingPhoto) {
          await FirebaseStorage.instance
              .ref()
              .child('guardian_photos/${widget.userId}.jpg')
              .delete()
              .catchError((_) {}); // Ignore if not found
          uploadedUrl = null;
        } else if (_selectedImage != null) {
          uploadedUrl = await _uploadImage(_selectedImage!);
        }

        await FirebaseFirestore.instance
            .collection('Secondary Guardian')
            .doc(widget.userId)
            .update({
          'FullName': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'photoUrl': uploadedUrl,
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile updated successfully!",
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.green,
              //behavior: SnackBarBehavior.floating, // You can uncomment this if you prefer a floating behavior
            ),
          );
          Navigator.pop(context, true);
        }
      }
    }
  }

  Future<void> _cancelChanges() async {
    bool confirm = await _showConfirmationDialog(
        "Discard Changes?", "Are you sure you want to discard your changes?");
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
              child: Text("No")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Yes")),
        ],
      ),
    );
    return result ?? false;
  }

  InputDecoration _fieldDecoration(String hint, {bool readOnly = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: readOnly ? Colors.grey : Colors.grey[500],
      ),
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
          style: TextStyle(color: readOnly ? Colors.grey[600] : Colors.black),
          decoration: _fieldDecoration("Enter $label", readOnly: readOnly),
        ),
      ],
    );
  }

  Widget _buildProfilePhoto() {
    Widget avatar;

    if (_selectedImage != null) {
      avatar = CircleAvatar(
        radius: 50,
        backgroundImage: FileImage(_selectedImage!),
      );
    } else if (_photoUrl != null && _photoUrl!.isNotEmpty) {
      avatar = CircleAvatar(
        radius: 50,
        backgroundImage: NetworkImage(_photoUrl!),
      );
    } else {
      avatar = CircleAvatar( // Wrap the Icon with CircleAvatar
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
        if (_photoUrl != null || _selectedImage != null)
          TextButton.icon(
            onPressed: _removePhoto,
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
                            _buildLabeledField(
                                "Your Email", _emailController, _validateEmail),
                            const SizedBox(height: 16),
                            _buildLabeledField("Your Phone", _phoneController,
                                null,
                                readOnly: true),
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
                                        borderRadius:
                                            BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text('Save Changes',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16)),
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
                                        borderRadius:
                                            BorderRadius.circular(30),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: const Text('Cancel',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16)),
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