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
import '../widgets/app_back_button.dart';
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
      return;
    }

    // Jika tiada dalam simpanan tempatan, muat turun dari backend (elak isu CORS)
    if (user != null && user!.profilePicture.isNotEmpty) {
      _fetchProfileImageFromServer(userId);
    }
  }

  Future<void> _fetchProfileImageFromServer(String userId) async {
    try {
      final result = await ApiService.post({
        'action': 'getProfileImage',
        'user_id': userId,
        'matrik_no': user?.matrikNo ?? userId,
      });

      if (result['success'] == true && result['data'] != null) {
        final base64Data = result['data']['image_base64']?.toString() ?? '';
        if (base64Data.isNotEmpty) {
          final cleanBase64 = base64Data.contains(',')
              ? base64Data.split(',').last
              : base64Data;
          final bytes = base64Decode(cleanBase64);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('profile_image_$userId', cleanBase64);

          if (mounted) {
            setState(() {
              _localImageBytes = bytes;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching profile image: $e');
    }
  }

  String _formatDriveImageUrl(String url) {
    if (url.isEmpty) return '';
    if (url.contains('drive.google.com')) {
      final regExp = RegExp(r'(?:id=|\/d\/)([a-zA-Z0-9_-]+)');
      final match = regExp.firstMatch(url);
      if (match != null && match.group(1) != null) {
        return 'https://drive.google.com/thumbnail?id=${match.group(1)}&sz=w800';
      }
    }
    return url;
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
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
        'matrik_no': user!.matrikNo,
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

      }

    } catch (e) {
      debugPrint('Error uploading image');
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
                    'Kemaskini Gambar Profil',
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
                  title: const Text('Ambil gambar dari Kamera'),
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFEBEE),
                    child: Icon(Icons.photo_library, color: Colors.red),
                  ),
                  title: const Text('Pilih gambar dari Galeri'),
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
          'Padamkan Akaun',
          style: TextStyle(
            color: Color(0xFF382C2C),
            fontWeight: FontWeight.w800,
          ),
        ),
        content: const Text(
          'Anda pasti mahu memadamkan akaun ini? Tindakan ini tidak boleh dibatalkan.',
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
            child: const Text('Batal'),
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
            child: const Text('Padam'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && user != null) {
      try {
        await ApiService.post({
          'action': 'deleteAccount',
          'matrik_no': user!.matrikNo,
          'user_id': user!.userId,
        });
      } catch (_) {}

      await authCubit.logout();
      if (!mounted) return;

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
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
  }) {
    final hasCustomBg = backgroundColor != null;
    return Container(
      width: double.infinity,
      height: 54,
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: hasCustomBg
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFFFF9F8)],
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: hasCustomBg
                ? backgroundColor.withOpacity(0.25)
                : const Color(0xFF9F3D48).withOpacity(0.07),
            blurRadius: 13,
            offset: const Offset(0, 4),
          ),
        ],
        border: hasCustomBg
            ? (borderColor != null
                ? Border.all(color: borderColor, width: 2)
                : null)
            : Border.all(
                color: borderColor ?? const Color(0xFF9B6669),
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
              style: TextStyle(
                color: textColor ?? const Color(0xFF382C2C),
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
                                            _formatDriveImageUrl(
                                                user!.profilePicture),
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
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF382C2C),
                    ),
                  ),
                ],
              ),
            ),

            // 1. Profile Button
            _buildActionButton(
              title: 'Profil',
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
              title: 'Teknik Yang Dilakukan',
              onTap: () {
                Navigator.pushNamed(context, '/setting-history');
              },
            ),

            // 3. Counselor Contact Button
            /*_buildActionButton(
              title: 'Hubungi Kaunselor',
              onTap: () {
                Navigator.pushNamed(context, '/counselor');
              },
            ),*/

            // 4. Logout Button
            _buildActionButton(
              title: 'Log Keluar',
              onTap: _logout,
            ),

            // 5. Delete Account Button
            _buildActionButton(
              title: 'Padam Akaun',
              onTap: _confirmDeleteAccount,
              backgroundColor: const Color(0xFFBD3546),
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );

    if (widget.showAppBar) {
      return AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 45),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        child: const Text(
                          'Settings',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFBD3546),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: bodyContent),
                  ],
                ),
                const AppBackButton(),
              ],
            ),
          ),
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
