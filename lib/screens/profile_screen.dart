import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  User? user;

  @override
  void initState() {
    super.initState();

    _loadUser();
  }

  Future<void> _loadUser() async {
    final currentUser =
        await AuthService.getUser();

    if (!mounted) return;

    setState(() {
      user = currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: user == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(
                      Icons.person,
                      size: 50,
                    ),
                  ),

                  const SizedBox(height: 25),

                  _info(
                    'Full Name',
                    user!.fullName,
                  ),

                  _info(
                    'Role',
                    user!.role,
                  ),

                  _info(
                    'Username',
                    user!.username,
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditProfileScreen(
                              user: user!,
                            ),
                          ),
                        );

                        _loadUser();
                      },
                      child: const Text(
                        'Edit Profile',
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _info(
    String title,
    String value,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 15,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}