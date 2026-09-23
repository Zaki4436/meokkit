import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'info_detail_screen.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  static const List<Map<String, String>> informationTopics = [
    {
      'title': 'What is Stress?',
      'content':
          'Stress is the body\'s natural response to challenges, demands, or pressures from your environment. When you encounter a stressful situation, your body releases hormones like adrenaline and cortisol, preparing you to react quickly.\n\nWhile short-term stress can motivate you to meet deadlines or face challenges, prolonged or chronic stress can wear down your mental and physical wellbeing.',
    },
    {
      'title': 'Signs of Stress',
      'content':
          'Stress can manifest in various ways across your emotions, thoughts, body, and behavior:\n\n• Emotional: Feeling overwhelmed, irritable, anxious, or experiencing mood swings.\n• Mental: Difficulty concentrating, racing thoughts, constant worrying, or memory problems.\n• Physical: Headaches, muscle tension, fatigue, rapid heartbeat, or sleep disturbances.\n• Behavioral: Changes in appetite, procrastination, withdrawing from others, or restlessness.',
    },
    {
      'title': 'Effects of Stress',
      'content':
          'If left unmanaged, chronic stress can have significant effects on your overall health:\n\n• Physical Health: Weakened immune system, high blood pressure, increased risk of heart disease, and chronic pain.\n• Mental Health: Increased risk of depression, chronic anxiety disorders, and burnout.\n• Daily Life: Decreased productivity, relationship difficulties, and reduced quality of life.\n\nRecognizing the signs and effects early is the first step toward taking proactive steps to protect your health.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // Title: INFORMATION
              const Center(
                child: Text(
                  'INFORMATION',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: 1.0,
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Topic Cards
              ...informationTopics.map(
                (item) => _buildTopicCard(context, item),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _buildCustomBottomBar(context),
      ),
    );
  }

  Widget _buildTopicCard(BuildContext context, Map<String, String> item) {
    return Container(
      width: double.infinity,
      height: 104,
      margin: const EdgeInsets.only(bottom: 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => InfoDetailScreen(
                  title: item['title']!,
                  content: item['content']!,
                ),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                item['title']!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'See more',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
          // Home Tab (Active)
          _buildNavItem(
            context: context,
            icon: Icons.home,
            isSelected: true,
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
          ),
          // 10B Tab
          _buildNavItem(
            context: context,
            icon: Icons.self_improvement,
            isSelected: false,
            onTap: () {
              Navigator.pushReplacementNamed(context, '/methods');
            },
          ),
          // Setting Tab
          _buildNavItem(
            context: context,
            icon: Icons.settings,
            isSelected: false,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const HomeScreen(initialIndex: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
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
}