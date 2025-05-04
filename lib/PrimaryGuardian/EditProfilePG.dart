import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic>? guardianData;

  const EditProfilePage({
    super.key,
    required this.userId,
    required this.guardianData,
  });

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
    _editableGuardianData =
        widget.guardianData != null ? Map.from(widget.guardianData!) : {};
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
    if (value == null || value.trim().isEmpty) return "Name cannot be empty";
    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
      return "Only letters and spaces allowed";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Email cannot be empty";
    if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value)) {
      return "Enter a valid email";
    }
    return null;
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      bool confirm = await _showConfirmationDialog(
        "Confirm Changes",
        "Are you sure you want to save changes?",
      );
      if (confirm) {
        await FirebaseFirestore.instance
            .collection('Primary Guardian')
            .doc(widget.userId)
            .update({
          'fullName': _nameController.text.trim(),
          'email': _emailController.text.trim(),
        });
        Navigator.pop(context, true);
      }
    }
  }

  void _cancelChanges() async {
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
              child: Text("No")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Yes")),
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
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
                            const Icon(Icons.account_circle,
                                size: 100, color: Colors.grey),
                            const SizedBox(height: 20),
                            _buildLabeledField(
                                "Your Name", _nameController, _validateName),
                            const SizedBox(height: 16),
                            _buildLabeledField(
                                "Your Email", _emailController, _validateEmail),
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
}

