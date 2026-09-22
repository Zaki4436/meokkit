import 'package:flutter/material.dart';

class CounselorScreen extends StatelessWidget {
  const CounselorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Counselor Contact',
        ),
      ),
      body: Center(
        child: Image.asset(
          'assets/icon/full_logo.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}