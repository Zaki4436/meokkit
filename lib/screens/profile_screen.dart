import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool showAppBar;

  const ProfileScreen({
    super.key,
    this.showAppBar = false,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  bool loading = true;

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
      loading = false;
    });
  }

  Widget _buildFieldBox({
    required String label,
    required String value,
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
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 58),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFFFF9F8)],
            ),
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
          child: Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(
              color: Color(0xFF382C2C),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackground({required Widget child}) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFF5F2),
                  Color(0xFFFFFCFB),
                  Color(0xFFFFF1F3),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 18,
          right: -76,
          child: _backgroundOrb(
            210,
            const Color(0xFFF4A6A0).withOpacity(0.10),
          ),
        ),
        Positioned(
          bottom: 55,
          left: -95,
          child: _backgroundOrb(
            230,
            const Color(0xFFE98F9A).withOpacity(0.08),
          ),
        ),
        child,
      ],
    );
  }

  Widget _backgroundOrb(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyContent = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 60),
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
            Text(
              'PROFILE',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: Color(0xFF382C2C),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.66),
                borderRadius: BorderRadius.circular(23),
                border: Border.all(color: Colors.white.withOpacity(0.9)),
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
                  _buildFieldBox(
                    label: 'Full Name',
                    value: user?.fullName ?? '',
                  ),
                  const SizedBox(height: 17),
                  _buildFieldBox(
                    label: 'Username',
                    value: user?.username ?? '',
                  ),
                  const SizedBox(height: 17),
                  _buildFieldBox(
                    label: 'Role',
                    value: user?.role ?? '',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE65B63), Color(0xFFBD3546)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFBD3546).withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: user == null
                      ? null
                      : () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfileScreen(
                                user: user!,
                              ),
                            ),
                          );
                          if (!mounted) return;
                          if (result == true || result == null) {
                            _loadUser();
                          }
                        },
                  child: const Center(
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
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
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F7),
      body: SafeArea(
        child: _buildBackground(
          child: Stack(
            children: [
              if (loading)
                const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFBD3546),
                  ),
                )
              else
                bodyContent,
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
}
