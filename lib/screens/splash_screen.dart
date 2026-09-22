import 'dart:async';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _startApp();
  }

  Future<void> _startApp() async {
    await Future.delayed(
      const Duration(seconds: 2),
    );

    final loggedIn = await AuthService.isLoggedIn();

    if (!mounted) return;

    if (loggedIn) {
      Navigator.pushReplacementNamed(
        context,
        '/home',
      );
    } else {
      Navigator.pushReplacementNamed(
        context,
        '/login',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'MeOkKit',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            CircularProgressIndicator(
              color: Colors.red.shade400,
            ),
          ],
        ),
      ),
    );
  }
}