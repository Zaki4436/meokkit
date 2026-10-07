import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/app_background.dart';

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
  String? _message;

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
    selectedRole =
        widget.user.role.isNotEmpty && roles.contains(widget.user.role)
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
        Navigator.pop(context, true);
      } else {
        _showMessage(result['message']?.toString() ?? 'Update failed.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        saving = false;
      });
      _showMessage('Error updating profile: $e');
    }
  }

  void _showMessage(String message) {
    setState(() {
      _message = message;
    });
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
          style: const TextStyle(
            color: Color(0xFF8D7476),
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.82),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFF1D4D2)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9F3D48).withOpacity(0.045),
                blurRadius: 12,
                offset: const Offset(0, 4),
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
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFE65B63),
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(26, 68, 26, 24),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutCubic,
                builder: (context, progress, child) => Opacity(
                  opacity: progress,
                  child: Transform.translate(
                    offset: Offset(0, 14 * (1 - progress)),
                    child: child,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title: PROFILE
                    const Text(
                      'EDIT PROFILE',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        color: Color.fromARGB(255, 0, 0, 0),
                        letterSpacing: 0.7,
                      ),
                    ),

                    const SizedBox(height: 26),

                    Container(
                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.68),
                        borderRadius: BorderRadius.circular(23),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.92),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9F3D48).withOpacity(0.055),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildFormFieldWrapper(
                            label: 'Full Name',
                            child: TextFormField(
                              controller: fullNameController,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF382C2C),
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: _inputDecoration(),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _buildFormFieldWrapper(
                            label: 'Username',
                            child: TextFormField(
                              controller: usernameController,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF382C2C),
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: _inputDecoration(),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _buildFormFieldWrapper(
                            label: 'Role',
                            child: DropdownButtonFormField<String>(
                              value: selectedRole,
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xFF8D7476),
                                size: 28,
                              ),
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF382C2C),
                                fontWeight: FontWeight.w600,
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
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (_message != null) ...[
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F0),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFF1D4D2)),
                        ),
                        child: Text(
                          _message!,
                          style: const TextStyle(
                            color: Color(0xFF8E303A),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],

                    // Button 1: Change Password
                    _buildActionButton(
                      title: 'Change Password',
                      onTap: () {
                        Navigator.pushNamed(context, '/forgot-password');
                      },
                      secondary: true,
                    ),

                    const SizedBox(height: 14),

                    // Button 2: Save Edit
                    _buildActionButton(
                      title: 'Save Edit',
                      onTap: saving ? null : _updateProfile,
                      loading: saving,
                    ),

                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 12,
              child: Material(
                color: Colors.white.withOpacity(0.88),
                shape: const CircleBorder(),
                elevation: 3,
                shadowColor: const Color(0xFFBD3546).withOpacity(0.16),
                child: IconButton(
                  tooltip: 'Back',
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFFBD3546),
                    size: 19,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required VoidCallback? onTap,
    bool secondary = false,
    bool loading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: secondary
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE65B63), Color(0xFFBD3546)],
              ),
        color: secondary ? Colors.white.withOpacity(0.8) : null,
        borderRadius: BorderRadius.circular(16),
        border: secondary ? Border.all(color: const Color(0xFFF1D4D2)) : null,
        boxShadow: [
          BoxShadow(
            color: secondary
                ? const Color(0xFF9F3D48).withOpacity(0.06)
                : const Color(0xFFBD3546).withOpacity(0.22),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    title,
                    style: TextStyle(
                      color: secondary ? const Color(0xFF8E303A) : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
