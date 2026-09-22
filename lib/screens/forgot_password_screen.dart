import 'package:flutter/material.dart';

import '../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final newPasswordController =
      TextEditingController();
  final confirmPasswordController =
      TextEditingController();

  bool loading = false;

  Future<void> _resetPassword() async {
    final fullName =
        fullNameController.text.trim();

    final username =
        usernameController.text.trim();

    final newPassword =
        newPasswordController.text;

    final confirmPassword =
        confirmPasswordController.text;

    if (fullName.isEmpty ||
        username.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage(
        'Please fill in all fields.',
      );
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage(
        'Passwords do not match.',
      );
      return;
    }

    setState(() {
      loading = true;
    });

    final result = await ApiService.post({
      'action': 'forgotPassword',
      'full_name': fullName,
      'username': username,
      'new_password': newPassword,
    });

    setState(() {
      loading = false;
    });

    if (result['success'] == true) {
      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Password Reset Successful',
            ),
            content: const Text(
              'You can now login using your new password.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.pop(context);
    } else {
      _showMessage(
        result['message']?.toString() ??
            'Password reset failed.',
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
    newPasswordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const SizedBox(height: 20),

            TextField(
              controller: fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed:
                    loading ? null : _resetPassword,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Reset Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}