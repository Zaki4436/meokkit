import 'package:flutter/material.dart';

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
              leading: const Icon(Icons.self_improvement),
              title: const Text('10B'),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/methods',
                  (route) => false,
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Setting'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/setting',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}