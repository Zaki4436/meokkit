import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  final String currentPage;

  const AppDrawer({
    super.key,
    this.currentPage = '',
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Text(
                    'MeOkKit',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Stress Management',
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/profile',
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Emotion History'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/emotion-history',
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.history_toggle_off),
              title: const Text('Activity History'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/activity-history',
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Counselor Contact'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/counselor',
                );
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await AuthService.logout();

                if (!context.mounted) return;

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}