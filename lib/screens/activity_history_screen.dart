import 'package:flutter/material.dart';

import '../widgets/app_background.dart';
import '../widgets/app_back_button.dart';
import '../models/history.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  bool loading = true;

  List<ActivityHistory> history = [];

  @override
  void initState() {
    super.initState();

    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final user = await AuthService.getUser();

    if (user == null) return;

    final result = await ApiService.get(
      'getActivityHistory',
      params: {
        'matrik_no': user.matrikNo,
        'user_id': user.userId,
      },
    );

    if (result['success'] == true) {
      final data = result['data'];

      final List<dynamic> items = data['history'] ?? [];

      history = items
          .map(
            (item) => ActivityHistory.fromJson(item),
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
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 45),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      child: const Text(
                        'Teknik yang Dilakukan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          color: Color.fromARGB(255, 0, 0, 0),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: loading
                        ? const Center(child: CircularProgressIndicator())
                        : history.isEmpty
                            ? const Center(child: Text('Tiada teknik yang dilakukan.'))
                            : ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: history.length,
                                itemBuilder: (context, index) {
                                  final item = history[index];
                                  return Card(
                                    child: ListTile(
                                      leading: const Icon(Icons.self_improvement),
                                      title: Text(item.methodName),
                                      subtitle: Text('${item.date} • ${item.time}'),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
              const AppBackButton(),
            ],
          ),
        ),
      ),
    );
  }
}
