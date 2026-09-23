import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'methods_screen.dart';

class CheckEmotionScreen extends StatefulWidget {
  const CheckEmotionScreen({super.key});

  @override
  State<CheckEmotionScreen> createState() =>
      _CheckEmotionScreenState();
}

class _CheckEmotionScreenState
    extends State<CheckEmotionScreen> {
  bool loading = false;

  Future<void> _saveAnswer(String answer) async {
    final user = await AuthService.getUser();

    if (user == null) {
      return;
    }

    setState(() {
      loading = true;
    });

    final result = await ApiService.post({
      'action': 'saveEmotion',
      'user_id': user.userId,
      'answer': answer,
    });

    setState(() {
      loading = false;
    });

    if (result['success'] != true) {
      _showMessage(
        result['message']?.toString() ??
            'Unable to save emotion.',
      );
      return;
    }

    if (answer == 'Yes') {
      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Thank You',
            ),
            content: const Text(
              'You may be experiencing stress. '
              'We recommend trying some stress management activities.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Continue'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const MethodsScreen(showAppBar: true),
        ),
      );
    } else {
      _showMessage(
        'Thank you for checking your emotion.',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Emotion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.psychology,
              size: 80,
            ),

            const SizedBox(height: 30),

            const Text(
              'Are you currently feeling stressed?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 50),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: loading
                    ? null
                    : () => _saveAnswer('Yes'),
                child: const Text('Yes'),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                onPressed: loading
                    ? null
                    : () => _saveAnswer('No'),
                child: const Text('No'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}