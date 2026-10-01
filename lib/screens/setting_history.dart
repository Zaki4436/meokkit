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
  final ScrollController _scrollController = ScrollController();
  static const int _pageSize = 10;

  bool _loading = true;
  bool _loadingMore = false;
  int _displayedCount = _pageSize;

  List<ActivityHistory> _activityHistory = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadActivityHistory();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 150) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_loadingMore || _displayedCount >= _activityHistory.length) return;

    setState(() {
      _loadingMore = true;
    });

    // Smooth delay for pagination experience
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() {
        _displayedCount =
            (_displayedCount + _pageSize).clamp(0, _activityHistory.length);
        _loadingMore = false;
      });
    });
  }

  Future<void> _loadActivityHistory() async {
    setState(() {
      _loading = true;
      _displayedCount = _pageSize;
      _loadingMore = false;
    });

    final user = await AuthService.getUser();
    if (user == null) {
      if (mounted) setState(() => _loading = false);
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
      _loading = false;
    });
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

            // Activity History Content
            Expanded(
              child: _buildActivityHistoryView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityHistoryView() {
    if (_loading) {
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

    final visibleCount = _displayedCount.clamp(0, _activityHistory.length);
    final hasMore = visibleCount < _activityHistory.length;

    return RefreshIndicator(
      color: Colors.red,
      onRefresh: _loadActivityHistory,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: visibleCount + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Bottom loading spinner when loading next 20 items
          if (index == visibleCount) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.red,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            );
          }

          final item = _activityHistory[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
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
            ),
          );
        },
      ),
    );
  }
}
