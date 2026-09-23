import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../widgets/app_drawer.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  User? user;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      drawer: const AppDrawer(currentPage: 'Setting'),
      appBar: AppBar(
        title: const Text('Setting'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  await Navigator.pushNamed(context, '/profile');
                  _loadUser();
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: primaryColor.withValues(alpha: 0.15),
                        child: Icon(
                          Icons.person,
                          size: 34,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName.isNotEmpty == true
                                  ? user!.fullName
                                  : 'User Profile',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.role.isNotEmpty == true
                                  ? user!.role
                                  : (user?.username ?? 'Tap to view details'),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                'General Settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            // Settings Options Card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // 1. Profile Page
                  _buildSettingTile(
                    icon: Icons.person_outline,
                    iconBgColor: Colors.blue.shade50,
                    iconColor: Colors.blue.shade700,
                    title: 'Profile',
                    subtitle: 'View and edit profile details',
                    onTap: () async {
                      await Navigator.pushNamed(context, '/profile');
                      _loadUser();
                    },
                  ),
                  const Divider(height: 1, indent: 68),

                  // 2. Setting History Page
                  _buildSettingTile(
                    icon: Icons.history,
                    iconBgColor: Colors.orange.shade50,
                    iconColor: Colors.orange.shade800,
                    title: 'Setting History',
                    subtitle: 'Emotion & activity history records',
                    onTap: () {
                      Navigator.pushNamed(context, '/setting-history');
                    },
                  ),
                  const Divider(height: 1, indent: 68),

                  // 3. Counselor Contact Page
                  _buildSettingTile(
                    icon: Icons.support_agent,
                    iconBgColor: Colors.purple.shade50,
                    iconColor: Colors.purple.shade700,
                    title: 'Counselor Contact',
                    subtitle: 'Counselor info and support channels',
                    onTap: () {
                      Navigator.pushNamed(context, '/counselor');
                    },
                  ),
                  const Divider(height: 1, indent: 68),

                  // 4. Logout Page / Action
                  _buildSettingTile(
                    icon: Icons.logout,
                    iconBgColor: Colors.red.shade50,
                    iconColor: Colors.red.shade700,
                    title: 'Logout',
                    subtitle: 'Sign out from your account',
                    isDestructive: true,
                    onTap: _confirmLogout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: iconBgColor,
        child: Icon(
          icon,
          size: 22,
          color: iconColor,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red.shade700 : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDestructive ? Colors.red.shade400 : Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }
}

