import 'package:flutter/material.dart';

import '../widgets/app_background.dart';
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
                        'HISTORY',
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
                    child: _buildActivityHistoryView(),
                  ),
                ],
              ),
              Positioned(
                top: 8,
                left: 12,
                child: Material(
                  color: Colors.white.withOpacity(0.88),
                  shape: const CircleBorder(),
                  elevation: 3,
                  shadowColor: const Color(0xFFBD3546).withOpacity(0.16),
                  child: IconButton(
                    tooltip: 'Back',
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFFBD3546),
                      size: 19,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
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
            child: TweenAnimationBuilder<double>(
              key: ValueKey('${item.methodName}-$index'),
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 320 + (index % 6) * 45),
              curve: Curves.easeOutCubic,
              builder: (context, progress, child) => Opacity(
                opacity: progress,
                child: Transform.translate(
                  offset: Offset(0, 12 * (1 - progress)),
                  child: child,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Color(0xFFFFF9F8)],
                  ),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: const Color(0xFFF1D4D2)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9F3D48).withOpacity(0.07),
                      blurRadius: 13,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 2,
                  ),
                  title: Text(
                    item.methodName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF382C2C),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
