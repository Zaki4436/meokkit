import 'package:flutter/material.dart';

import '../models/history.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class SettingHistoryScreen extends StatefulWidget {
  final int initialIndex;

  const SettingHistoryScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<SettingHistoryScreen> createState() => _SettingHistoryScreenState();
}

class _SettingHistoryScreenState extends State<SettingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _loadingEmotion = true;
  bool _loadingActivity = true;

  List<EmotionHistory> _emotionHistory = [];
  List<ActivityHistory> _activityHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialIndex,
    );

    _loadAllHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllHistory() async {
    await Future.wait([
      _loadEmotionHistory(),
      _loadActivityHistory(),
    ]);
  }

  Future<void> _loadEmotionHistory() async {
    setState(() {
      _loadingEmotion = true;
    });

    final user = await AuthService.getUser();
    if (user == null) {
      if (mounted) setState(() => _loadingEmotion = false);
      return;
    }

    final result = await ApiService.get(
      'getEmotionHistory',
      params: {
        'user_id': user.userId,
      },
    );

    if (result['success'] == true) {
      final data = result['data'];
      final List<dynamic> items = data['history'] ?? [];

      _emotionHistory = items
          .map((item) => EmotionHistory.fromJson(item))
          .toList()
          .reversed
          .toList();
    }

    if (!mounted) return;
    setState(() {
      _loadingEmotion = false;
    });
  }

  Future<void> _loadActivityHistory() async {
    setState(() {
      _loadingActivity = true;
    });

    final user = await AuthService.getUser();
    if (user == null) {
      if (mounted) setState(() => _loadingActivity = false);
      return;
    }

    final result = await ApiService.get(
      'getActivityHistory',
      params: {
        'user_id': user.userId,
      },
    );

    if (result['success'] == true) {
      final data = result['data'];
      final List<dynamic> items = data['history'] ?? [];

      _activityHistory = items
          .map((item) => ActivityHistory.fromJson(item))
          .toList()
          .reversed
          .toList();
    }

    if (!mounted) return;
    setState(() {
      _loadingActivity = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black87,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.psychology, size: 20),
                    text: 'Emotion History',
                  ),
                  Tab(
                    icon: Icon(Icons.self_improvement, size: 20),
                    text: 'Activity History',
                  ),
                ],
              ),
            ),

            // Tab View Pages
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEmotionHistoryView(),
                  _buildActivityHistoryView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionHistoryView() {
    if (_loadingEmotion) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_emotionHistory.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadEmotionHistory,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No emotion history recorded yet.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEmotionHistory,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _emotionHistory.length,
        itemBuilder: (context, index) {
          final item = _emotionHistory[index];
          final isStressed = item.answer.trim().toLowerCase() == 'yes';

          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isStressed
                    ? Colors.orange.shade100
                    : Colors.green.shade100,
                child: Icon(
                  isStressed ? Icons.warning_amber_rounded : Icons.check_circle,
                  color: isStressed ? Colors.deepOrange : Colors.green,
                ),
              ),
              title: Text(
                'Answer: ${item.answer}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text('${item.date} • ${item.time}'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityHistoryView() {
    if (_loadingActivity) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_activityHistory.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadActivityHistory,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.self_improvement,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No activity history recorded yet.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadActivityHistory,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _activityHistory.length,
        itemBuilder: (context, index) {
          final item = _activityHistory[index];

          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.self_improvement,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(
                item.methodName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text('${item.date} • ${item.time}'),
            ),
          );
        },
      ),
    );
  }
}

