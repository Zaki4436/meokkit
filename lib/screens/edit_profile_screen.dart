import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController fullNameController;
  late TextEditingController usernameController;
  late String selectedRole;

  bool saving = false;

  final roles = [
    'Lecturer',
    'Staff',
    'Student',
  ];

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController(text: widget.user.fullName);
    usernameController = TextEditingController(text: widget.user.username);
    selectedRole = widget.user.role.isNotEmpty && roles.contains(widget.user.role)
        ? widget.user.role
        : roles.first;
  }

  @override
  void dispose() {
    fullNameController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    final fullName = fullNameController.text.trim();
    final username = usernameController.text.trim();

    if (fullName.isEmpty || username.isEmpty) {
      _showMessage('Please fill in all fields.');
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final result = await ApiService.post({
        'action': 'updateProfile',
        'user_id': widget.user.userId,
        'full_name': fullName,
        'role': selectedRole,
        'username': username,
      });

      setState(() {
        saving = false;
      });

      if (result['success'] == true) {
        var updatedUser = User.fromJson(result['data']);
        // Keep existing profile image if backend returned empty image
        if (updatedUser.profilePicture.isEmpty &&
            widget.user.profilePicture.isNotEmpty) {
          updatedUser = updatedUser.copyWith(
            profilePicture: widget.user.profilePicture,
          );
        }

        await AuthService.saveUser(updatedUser);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        _showMessage(result['message']?.toString() ?? 'Update failed.');
      }
    } catch (e) {
      setState(() {
        saving = false;
      });
      _showMessage('Error updating profile: $e');
    }
  }



  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Widget _buildFormFieldWrapper({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.red),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title: PROFILE
                    const Text(
                      'PROFILE',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'serif',
                        color: Colors.red,
                        letterSpacing: 1.0,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // 1. Username
                    _buildFormFieldWrapper(
                      label: 'Username',
                      child: TextFormField(
                        controller: usernameController,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2C2C2C),
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _inputDecoration(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 2. Full Name
                    _buildFormFieldWrapper(
                      label: 'Full Name',
                      child: TextFormField(
                        controller: fullNameController,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2C2C2C),
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _inputDecoration(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 3. Role Dropdown
                    _buildFormFieldWrapper(
                      label: 'Role',
                      child: DropdownButtonFormField<String>(
                        value: selectedRole,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF555555),
                          size: 28,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2C2C2C),
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _inputDecoration(),
                        items: roles.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            selectedRole = value;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Button 1: Change Password
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            Navigator.pushNamed(context, '/forgot-password');
                          },
                          child: const Center(
                            child: Text(
                              'Change Password',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Button 2: Save Edit
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: saving ? null : _updateProfile,
                          child: Center(
                            child: saving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Save Edit',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}