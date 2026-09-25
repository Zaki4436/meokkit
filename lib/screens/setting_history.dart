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

class _SettingHistoryScreenState extends State<SettingHistoryScreen> {
  late PageController _pageController;
  late int _selectedIndex;

  bool _loadingEmotion = true;
  bool _loadingActivity = true;

  List<EmotionHistory> _emotionHistory = [];
  List<ActivityHistory> _activityHistory = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _loadAllHistory();
  }

  @override
  void dispose() {
    _pageController.dispose();
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

    try {
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
    } catch (_) {}

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

    try {
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
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _loadingActivity = false;
    });
  }

  Widget _buildToggleBar() {
    return Container(
      width: 250,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFFED0D0),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          // 1. Emotion Tab
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_selectedIndex != 0) {
                  setState(() => _selectedIndex = 0);
                  _pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _selectedIndex == 0 ? Colors.red : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Emotion',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // 2. Activity Tab
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_selectedIndex != 1) {
                  setState(() => _selectedIndex = 1);
                  _pageController.animateToPage(
                    1,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _selectedIndex == 1 ? Colors.red : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Activity',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.red),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 4),

            // Stylized Title: HISTORY
            const Text(
              'HISTORY',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                fontFamily: 'serif',
                color: Colors.red,
                letterSpacing: 1.0,
              ),
            ),

            const SizedBox(height: 18),

            // Pill-shaped Toggle: [ Emotion | Activity ]
            _buildToggleBar(),

            const SizedBox(height: 16),

            // History Content Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
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
        child: CircularProgressIndicator(color: Colors.red),
      );
    }

    if (_emotionHistory.isEmpty) {
      return RefreshIndicator(
        color: Colors.red,
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
      color: Colors.red,
      onRefresh: _loadEmotionHistory,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: _emotionHistory.length,
        itemBuilder: (context, index) {
          final item = _emotionHistory[index];
          final isStressed = item.answer.trim().toLowerCase() == 'yes';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: CircleAvatar(
                backgroundColor: isStressed
                    ? const Color(0xFFFFEBEE)
                    : const Color(0xFFE8F5E9),
                child: Icon(
                  isStressed ? Icons.mood_bad_rounded : Icons.check_circle,
                  color: isStressed ? Colors.red : Colors.green,
                ),
              ),
              title: Text(
                item.answer,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2C2C2C),
                ),
              ),
              subtitle: Text(
                '${item.date} • ${item.time}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityHistoryView() {
    if (_loadingActivity) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.red),
      );
    }

    if (_activityHistory.isEmpty) {
      return RefreshIndicator(
        color: Colors.red,
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
      color: Colors.red,
      onRefresh: _loadActivityHistory,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: _activityHistory.length,
        itemBuilder: (context, index) {
          final item = _activityHistory[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFEBEE),
                child: Icon(
                  Icons.self_improvement,
                  color: Colors.red,
                ),
              ),
              title: Text(
                item.methodName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2C2C2C),
                ),
              ),
              subtitle: Text(
                '${item.date} • ${item.time}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
