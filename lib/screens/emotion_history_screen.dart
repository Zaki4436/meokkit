import 'package:flutter/material.dart';

import '../models/history.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class EmotionHistoryScreen extends StatefulWidget {
  const EmotionHistoryScreen({super.key});

  @override
  State<EmotionHistoryScreen> createState() =>
      _EmotionHistoryScreenState();
}

class _EmotionHistoryScreenState
    extends State<EmotionHistoryScreen> {
  bool loading = true;

  List<EmotionHistory> history = [];

  @override
  void initState() {
    super.initState();

    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final user =
        await AuthService.getUser();

    if (user == null) return;

    final result = await ApiService.get(
      'getEmotionHistory',
      params: {
        'user_id': user.userId,
      },
    );

    if (result['success'] == true) {
      final data = result['data'];

      final List<dynamic> items =
          data['history'] ?? [];

      history = items
          .map(
            (item) =>
                EmotionHistory.fromJson(item),
          )
          .toList();

      history = history.reversed.toList();
    }

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Emotion History',
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : history.isEmpty
              ? const Center(
                  child: Text(
                    'No emotion history.',
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];

                    return Card(
                      child: ListTile(
                        leading: Icon(
                          item.answer == 'Yes'
                              ? Icons.mood_bad
                              : Icons.check_circle,
                        ),
                        title: Text(
                          item.answer,
                        ),
                        subtitle: Text(
                          '${item.date} • ${item.time}',
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}