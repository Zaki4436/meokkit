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
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {
  late TextEditingController fullNameController;
  late TextEditingController usernameController;

  late String selectedRole;

  bool loading = false;

  final roles = [
    'Lecturer',
    'Staff',
    'Student',
  ];

  @override
  void initState() {
    super.initState();

    fullNameController =
        TextEditingController(
      text: widget.user.fullName,
    );

    usernameController =
        TextEditingController(
      text: widget.user.username,
    );

    selectedRole = widget.user.role;
  }

  Future<void> _updateProfile() async {
    final fullName =
        fullNameController.text.trim();

    final username =
        usernameController.text.trim();

    if (fullName.isEmpty ||
        username.isEmpty) {
      _showMessage(
        'Please fill in all fields.',
      );
      return;
    }

    setState(() {
      loading = true;
    });

    final result = await ApiService.post({
      'action': 'updateProfile',
      'user_id': widget.user.userId,
      'full_name': fullName,
      'role': selectedRole,
      'username': username,
    });

    setState(() {
      loading = false;
    });

    if (result['success'] == true) {
      final updatedUser =
          User.fromJson(result['data']);

      await AuthService.saveUser(
        updatedUser,
      );

      if (!mounted) return;

      Navigator.pop(context);
    } else {
      _showMessage(
        result['message']?.toString() ??
            'Update failed.',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    usernameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            TextField(
              controller: fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
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

            const SizedBox(height: 20),

            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed:
                    loading ? null : _updateProfile,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}