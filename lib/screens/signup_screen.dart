import 'package:flutter/material.dart';

import '../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController =
      TextEditingController();

  String? selectedRole;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool loading = false;

  final List<String> roles = [
    'Lecturer',
    'Staff',
    'Student',
  ];

  Future<void> _signup() async {
    final fullName =
        fullNameController.text.trim();

    final username =
        usernameController.text.trim();

    final password =
        passwordController.text;

    final confirmPassword =
        confirmPasswordController.text;

    if (fullName.isEmpty) {
      _showMessage('Please enter your full name.');
      return;
    }

    if (selectedRole == null) {
      _showMessage('Please select your role.');
      return;
    }

    if (username.isEmpty) {
      _showMessage('Please enter username.');
      return;
    }

    if (password.isEmpty) {
      _showMessage('Please enter password.');
      return;
    }

    if (password != confirmPassword) {
      _showMessage(
        'Password and confirm password do not match.',
      );
      return;
    }

    setState(() {
      loading = true;
    });

    final result = await ApiService.post({
      'action': 'register',
      'full_name': fullName,
      'role': selectedRole,
      'username': username,
      'password': password,
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
            title: const Text('Registration Successful'),
            content: const Text(
              'Your account has been successfully created.',
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
            'Registration failed.',
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
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                  setState(() {
                    selectedRole = value;
                  });
                },
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
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword =
                            !obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword =
                            !obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: loading ? null : _signup,
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text('Sign Up'),
                ),
              ),

              const SizedBox(height: 15),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Already have an account? Login',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}