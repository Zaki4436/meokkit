import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'profile_screen.dart';

class SettingScreen extends StatefulWidget {
  final bool showAppBar;

  const SettingScreen({
    super.key,
    this.showAppBar = false,
  });

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  User? user;
  Uint8List? _localImageBytes;
  bool _uploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final currentUser = await AuthService.getUser();
    if (!mounted) return;
    setState(() {
      user = currentUser;
    });

    if (currentUser != null) {
      _loadLocalImage(currentUser.userId);
    }
  }

  Future<void> _loadLocalImage(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final base64Str = prefs.getString('profile_image_$userId');
    if (base64Str != null && mounted) {
      setState(() {
        _localImageBytes = base64Decode(base64Str);
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // Close bottom sheet
    if (user == null) return;

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      setState(() {
        _localImageBytes = bytes;
        _uploadingImage = true;
      });

      // Save locally so it appears immediately
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_${user!.userId}', base64Image);

      // Upload to Google Drive via Google Apps Script
      final filename =
          'profile_${user!.userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await ApiService.post({
        'action': 'uploadProfileImage',
        'user_id': user!.userId,
        'image_base64': base64Image,
        'file_name': filename,
        'mime_type': 'image/jpeg',
      });

      if (!mounted) return;

      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];
        final driveUrl = data['url']?.toString() ??
            data['user_image']?.toString() ??
            data['profile_picture']?.toString() ??
            data['file_url']?.toString();

        if (driveUrl != null && driveUrl.isNotEmpty) {
          final updatedUser = user!.copyWith(profilePicture: driveUrl);
          await AuthService.saveUser(updatedUser);
          if (!mounted) return;
          setState(() {
            user = updatedUser;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture saved to Google Drive!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message']?.toString() ??
                  'Profile picture updated locally.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _uploadingImage = false;
        });
      }
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Wrap(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'Update Profile Picture',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFEBEE),
                    child: Icon(Icons.camera_alt, color: Colors.red),
                  ),
                  title: const Text('Take Photo with Camera'),
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFEBEE),
                    child: Icon(Icons.photo_library, color: Colors.red),
                  ),
                  title: const Text('Choose from Gallery'),
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await AuthService.logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && user != null) {
      try {
        await ApiService.post({
          'action': 'deleteAccount',
          'user_id': user!.userId,
        });
      } catch (_) {}

      await AuthService.logout();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deleted successfully.'),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }

  Widget _buildActionButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 48,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1E1E1E),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyContent = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),

          // User Avatar Placeholder with Camera Badge
          Center(
            child: GestureDetector(
              onTap: _uploadingImage ? null : _showImagePickerModal,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.grey.shade300,
                    child: _uploadingImage
                        ? const CircularProgressIndicator(color: Colors.red)
                        : _localImageBytes != null
                            ? ClipOval(
                                child: Image.memory(
                                  _localImageBytes!,
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : (user?.profilePicture.isNotEmpty == true)
                                ? ClipOval(
                                    child: Image.network(
                                      user!.profilePicture,
                                      width: 96,
                                      height: 96,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.person,
                                        size: 56,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 56,
                                    color: Colors.white,
                                  ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // User Full Name
          Text(
            user?.fullName.isNotEmpty == true
                ? user!.fullName
                : 'User Full Name',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E1E),
            ),
          ),

          const SizedBox(height: 28),

          // 1. Profile Button
          _buildActionButton(
            title: 'Profile',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
              if (!mounted) return;
              _loadUser();
            },
          ),

          // 2. History Button
          _buildActionButton(
            title: 'History',
            onTap: () {
              Navigator.pushNamed(context, '/setting-history');
            },
          ),

          // 3. Counselor Contact Button
          _buildActionButton(
            title: 'Counselor Contact',
            onTap: () {
              Navigator.pushNamed(context, '/counselor');
            },
          ),

          // 4. Logout Button
          _buildActionButton(
            title: 'Logout',
            onTap: _confirmLogout,
          ),

          // 5. Delete Account Button
          _buildActionButton(
            title: 'Delete Account',
            onTap: _confirmDeleteAccount,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );

    if (widget.showAppBar) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: const Text(
            'Settings',
            style: TextStyle(
              color: Colors.red,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: bodyContent,
        bottomNavigationBar: SafeArea(
          top: false,
          child: _buildCustomBottomBar(context),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: bodyContent,
      ),
    );
  }

  Widget _buildCustomBottomBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFFFFCDD2), // Soft pink background
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Home Tab
          _buildNavItem(
            context: context,
            icon: Icons.home,
            isSelected: false,
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
          ),
          // 10B / Methods Tab
          _buildNavItem(
            context: context,
            icon: Icons.self_improvement,
            isSelected: false,
            onTap: () {
              Navigator.pushReplacementNamed(context, '/methods');
            },
          ),
          // Setting / Profile Tab (Active)
          _buildNavItem(
            context: context,
            icon: Icons.settings,
            isSelected: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            color: isSelected ? Colors.red : Colors.transparent,
            borderRadius: BorderRadius.circular(27),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
