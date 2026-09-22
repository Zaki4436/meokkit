import 'package:flutter/material.dart';

import '../models/history.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class ActivityHistoryScreen
    extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() =>
      _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState
    extends State<ActivityHistoryScreen> {
  bool loading = true;

  List<ActivityHistory> history = [];

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
      'getActivityHistory',
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
                ActivityHistory.fromJson(item),
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
          'Activity History',
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : history.isEmpty
              ? const Center(
                  child: Text(
                    'No activity history.',
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];

                    return Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.self_improvement,
                        ),
                        title: Text(
                          item.methodName,
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