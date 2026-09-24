import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class CheckEmotionScreen extends StatefulWidget {
  const CheckEmotionScreen({super.key});

  @override
  State<CheckEmotionScreen> createState() => _CheckEmotionScreenState();
}

class _CheckEmotionScreenState extends State<CheckEmotionScreen> {
  String? _selectedAnswer; // 'Yes' or 'No'

  void _onAnswerSelected(String answer) {
    if (_selectedAnswer != null) return;
    setState(() {
      _selectedAnswer = answer;
    });
    _saveAnswer(answer);
  }

  Future<void> _saveAnswer(String answer) async {
    final user = await AuthService.getUser();
    if (user == null) return;

    try {
      await ApiService.post({
        'action': 'saveEmotion',
        'user_id': user.userId,
        'answer': answer,
      });
    } catch (_) {
      // Ignore background save errors so UI remains responsive
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // Title: STRESS CHECK
              const Center(
                child: Text(
                  'STRESS CHECK',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: 1.0,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Subtitle: Are you stress?
              const Center(
                child: Text(
                  'Are you stress?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Yes / No options with square check boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildOptionItem(
                    label: 'Yes',
                    isSelected: _selectedAnswer == 'Yes',
                    onTap: () => _onAnswerSelected('Yes'),
                  ),
                  const SizedBox(width: 48),
                  _buildOptionItem(
                    label: 'No',
                    isSelected: _selectedAnswer == 'No',
                    onTap: () => _onAnswerSelected('No'),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Result Card (shown when an option is selected)
              if (_selectedAnswer != null) _buildResultCard(),

              const SizedBox(height: 20),
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

  Widget _buildOptionItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _selectedAnswer == null ? onTap : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 26,
            height: 24,
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.white,
              border: Border.all(
                color: Colors.black,
                width: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final isYes = _selectedAnswer == 'Yes';

    return Container(
      width: double.infinity,
      height: 340,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Card Title
          Text(
            isYes ? 'WHY?' : 'CONGRATULATIONS',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red,
              fontSize: isYes ? 24 : 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 18),

          // Card Description
          Text(
            isYes
                ? 'Take early preventive measures to prevent the situation from worsening.'
                : 'You have managed your emotion succesfully.\nContinue your positive life.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.45,
            ),
          ),

          const Spacer(),

          // Card Action Button
          if (isYes)
            // "Start" button for Yes
            Container(
              width: double.infinity,
              height: 48,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/methods');
                  },
                  child: const Center(
                    child: Text(
                      'Start',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            // "Back to Home" button for No
            Center(
              child: Container(
                width: 150,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.shade400,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    },
                    child: const Center(
                      child: Text(
                        'Back to Home',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 6),
        ],
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
            color: Colors.black.withOpacity(0.08),
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