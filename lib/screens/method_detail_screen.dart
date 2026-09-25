import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/link.dart';
import '../models/method.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class MethodDetailScreen extends StatefulWidget {
  final Method method;

  const MethodDetailScreen({
    super.key,
    required this.method,
  });

  @override
  State<MethodDetailScreen> createState() => _MethodDetailScreenState();
}

class _MethodDetailScreenState extends State<MethodDetailScreen> {
  bool loading = true;
  List<MethodLink> links = [];

  @override
  void initState() {
    super.initState();
    _loadLinks();
    _saveActivity();
  }

  Future<void> _loadLinks() async {
    final result = await ApiService.get(
      'getLink',
      params: {
        'method_id': widget.method.methodId,
      },
    );

    if (result['success'] == true) {
      final data = result['data'];
      final List<dynamic> linkData = data['links'] ?? [];

      links = linkData
          .map((item) => MethodLink.fromJson(item))
          .where((link) => link.linkUrl.isNotEmpty)
          .toList();
    }

    if (!mounted) return;
    setState(() {
      loading = false;
    });
  }

  Future<void> _saveActivity() async {
    final user = await AuthService.getUser();
    if (user == null) return;

    try {
      await ApiService.post({
        'action': 'saveActivity',
        'user_id': user.userId,
        'method_id': widget.method.methodId,
        'method_name': widget.method.methodName,
      });
    } catch (_) {}
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open link.'),
        ),
      );
    }
  }

  Widget _buildCustomBottomBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFFFFCDD2), // Soft pink background
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Home Tab
          _buildNavItem(
            icon: Icons.home,
            isSelected: false,
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const HomeScreen(initialIndex: 0),
                ),
                (route) => false,
              );
            },
          ),
          // 10B / Methods Tab (Active)
          _buildNavItem(
            icon: Icons.self_improvement,
            isSelected: true,
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
          // Setting Tab
          _buildNavItem(
            icon: Icons.settings,
            isSelected: false,
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const HomeScreen(initialIndex: 2),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            color: isSelected ? Colors.red : Colors.transparent,
            borderRadius: BorderRadius.circular(27),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
        ),
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
            const SizedBox(height: 10),

            // Fixed Title: “Methods Name” in quotes matching mockup
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '“${widget.method.methodName}”',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'serif',
                    color: Colors.red,
                    letterSpacing: 1.0,
                    height: 1.2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Scrollable Details & Links
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    if (widget.method.description.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.method.description,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade800,
                            height: 1.45,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Activities / Links Section Header
                    const Text(
                      'Activities',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (loading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: CircularProgressIndicator(color: Colors.red),
                        ),
                      )
                    else if (links.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: Text(
                            'No links available for this method.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      )
                    else
                      ...links.map(
                        (link) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.2,
                            ),
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
                                Icons.play_circle_outline,
                                color: Colors.red,
                              ),
                            ),
                            title: Text(
                              link.linkName.isEmpty
                                  ? 'Open Activity'
                                  : link.linkName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF2C2C2C),
                              ),
                            ),
                            trailing: const Icon(
                              Icons.open_in_new,
                              color: Colors.red,
                              size: 20,
                            ),
                            onTap: () {
                              _openLink(link.linkUrl);
                            },
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}