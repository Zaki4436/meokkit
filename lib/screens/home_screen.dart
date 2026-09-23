import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

import 'check_emotion_screen.dart';
import 'information_screen.dart';
import 'methods_screen.dart';
import 'setting_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;
  User? user;

  static const String dassUrl =
      'https://e2pk.moe.gov.my/kframe.cfm?page_daftar#!';

  final List<String> _titles = const [
    'MeOkKit',
    '10B',
    'Setting',
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadUser();
  }

  Future<void> _loadUser() async {
    final currentUser = await AuthService.getUser();
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
          content: Text('Unable to open DASS link.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeBody(),
          const MethodsScreen(showAppBar: false),
          const SettingScreen(showAppBar: false),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
            _loadUser();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.self_improvement_outlined),
            selectedIcon: Icon(Icons.self_improvement),
            label: '10B',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Setting',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            icon: Icons.info,
            title: 'Information',
            subtitle: 'Learn more about stress management.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InformationScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 15),
          _homeCard(
            icon: Icons.psychology,
            title: 'Check Emotion',
            subtitle: 'Check your current emotional condition.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CheckEmotionScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 15),
          _homeCard(
            icon: Icons.assignment,
            title: 'DASS Test',
            subtitle: 'Take the DASS assessment.',
            onTap: _openDass,
          ),
        ],
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