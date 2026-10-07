import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../cubits/auth_cubit.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/app_background.dart';
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

class _SettingScreenState extends State<SettingScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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

      } else {
        debugPrint(
          result['message']?.toString() ??
              'Profile picture updated locally but upload failed.',
        );
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
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

  Future<void> _logout() async {
    await context.read<AuthCubit>().logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final authCubit = context.read<AuthCubit>();
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFBFA),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xFFF1D4D2)),
        ),
        title: const Text(
          'Delete Account',
          style: TextStyle(
            color: Color(0xFF382C2C),
            fontWeight: FontWeight.w800,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
          style: TextStyle(
            color: Color(0xFF65585A),
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF775F62),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBD3546),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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

      await authCubit.logout();
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
      height: 54,
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFFFF9F8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9F3D48).withOpacity(0.07),
            blurRadius: 13,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF9B6669),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF382C2C),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bodyContent = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
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
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFFFE9E8)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF1D4D2)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9F3D48).withOpacity(0.09),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _uploadingImage ? null : _showImagePickerModal,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: const Color(0xFFF5DADB),
                        child: _uploadingImage
                            ? const CircularProgressIndicator(
                                color: Color(0xFFBD3546),
                              )
                            : _localImageBytes != null
                                ? ClipOval(
                                    child: SizedBox.expand(
                                      child: Image.memory(
                                        _localImageBytes!,
                                        fit: BoxFit.cover,
                                        filterQuality: FilterQuality.high,
                                      ),
                                    ),
                                  )
                                : (user?.profilePicture.isNotEmpty == true)
                                    ? ClipOval(
                                        child: SizedBox.expand(
                                          child: Image.network(
                                            user!.profilePicture,
                                            fit: BoxFit.cover,
                                            filterQuality: FilterQuality.high,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(
                                              Icons.person,
                                              size: 56,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person,
                                        size: 56,
                                        color: Colors.white,
                                      ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.fullName.isNotEmpty == true
                        ? user!.fullName
                        : 'User Full Name',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF382C2C),
                    ),
                  ),
                ],
              ),
            ),

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
              onTap: _logout,
            ),

            // 5. Delete Account Button
            _buildActionButton(
              title: 'Delete Account',
              onTap: _confirmDeleteAccount,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    if (widget.showAppBar) {
      return AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            title: const Text(
              'Settings',
              style: TextStyle(
                color: Color(0xFFBD3546),
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
        ),
      );
    }

    return _buildSettingsBackground(
      child: SafeArea(
        child: bodyContent,
      ),
    );
  }

  Widget _buildSettingsBackground({required Widget child}) {
    return AppBackground(child: child);
  }

  Widget _buildCustomBottomBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFDFC), Color(0xFFFFE9E8)],
        ),
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: const Color(0xFFF1D4D2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9F3D48).withOpacity(0.12),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE65B63), Color(0xFFBD3546)],
                  )
                : null,
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
