import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../widgets/app_drawer.dart';

import 'check_emotion_screen.dart';
import 'methods_screen.dart';
import 'information_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user;

  static const String dassUrl =
      'https://e2pk.moe.gov.my/kframe.cfm?page_daftar#!';

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

  Future<void> _openDass() async {
    final uri = Uri.parse(dassUrl);

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open DASS link.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('MeOkKit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${user?.fullName ?? ''}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              user?.role ?? '',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 30),

            _homeCard(
              icon: Icons.psychology,
              title: 'Check Emotion',
              subtitle:
                  'Check your current emotional condition.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const _CheckEmotionRoute(),
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            _homeCard(
              icon: Icons.assignment,
              title: 'DASS Test',
              subtitle:
                  'Take the DASS assessment.',
              onTap: _openDass,
            ),

            const SizedBox(height: 15),

            _homeCard(
              icon: Icons.self_improvement,
              title: '10B Stress Management',
              subtitle:
                  'Explore activities to manage stress.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const _MethodsRoute(),
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            _homeCard(
              icon: Icons.info,
              title: 'Information',
              subtitle:
                  'Learn more about stress management.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const _InformationRoute(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _homeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(
          icon,
          size: 35,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }
}

// Temporary wrappers.
// Kita akan replace dengan actual screens below.

class _CheckEmotionRoute extends StatelessWidget {
  const _CheckEmotionRoute();

  @override
  Widget build(BuildContext context) {
    return const CheckEmotionScreen();
  }
}

class _MethodsRoute extends StatelessWidget {
  const _MethodsRoute();

  @override
  Widget build(BuildContext context) {
    return const MethodsScreen();
  }
}

class _InformationRoute extends StatelessWidget {
  const _InformationRoute();

  @override
  Widget build(BuildContext context) {
    return const InformationScreen();
  }
}