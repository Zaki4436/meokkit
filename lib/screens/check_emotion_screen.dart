import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';

class CheckEmotionScreen extends StatefulWidget {
  const CheckEmotionScreen({super.key});

  @override
  State<CheckEmotionScreen> createState() => _CheckEmotionScreenState();
}

class _CheckEmotionScreenState extends State<CheckEmotionScreen> {
  String? _selectedAnswer;

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title: STRESS CHECK
              const Text(
                'STRESS CHECK',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'serif',
                  color: Colors.red,
                  letterSpacing: 1.0,
                ),
              ),

              const SizedBox(height: 28),

              // Question Box with Choice Cards
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBFBFB),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Are you feeling stressed?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Choice options (Yes & No)
                    Row(
                      children: [
                        Expanded(
                          child: _buildChoiceCard(
                            label: 'No',
                            sublabel: 'I feel calm & okay',
                            icon: Icons.sentiment_satisfied_alt_rounded,
                            isSelected: _selectedAnswer == 'No',
                            isLocked: _selectedAnswer != null,
                            activeColor: const Color(0xFF2E7D32),
                            onTap: _selectedAnswer == null
                                ? () => _onAnswerSelected('No')
                                : null,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildChoiceCard(
                            label: 'Yes',
                            sublabel: 'I feel stressed',
                            icon: Icons.sentiment_dissatisfied_rounded,
                            isSelected: _selectedAnswer == 'Yes',
                            isLocked: _selectedAnswer != null,
                            activeColor: Colors.red,
                            onTap: _selectedAnswer == null
                                ? () => _onAnswerSelected('Yes')
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Animated Result Section
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.08),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _selectedAnswer == null
                    ? _buildPromptPlaceholder()
                    : _buildResultCard(),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromptPlaceholder() {
    return Container(
      key: const ValueKey('prompt'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFFEBEE),
            radius: 28,
            child: Icon(
              Icons.touch_app_outlined,
              color: Colors.red.shade400,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Select an option above',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose "Yes" or "No" to get personalized recommendations.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceCard({
    required String label,
    required String sublabel,
    required IconData icon,
    required bool isSelected,
    required bool isLocked,
    required Color activeColor,
    required VoidCallback? onTap,
  }) {
    final bool isDimmed = isLocked && !isSelected;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isDimmed ? 0.45 : 1.0,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade300,
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? activeColor.withOpacity(0.15)
                  : Colors.black.withOpacity(0.03),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: isSelected ? activeColor : Colors.grey.shade500,
                  size: 24,
                ),
                // Square check box matching the mockup aesthetic
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isSelected ? activeColor : Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: isSelected ? activeColor : Colors.grey.shade400,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 15,
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? activeColor : const Color(0xFF1E1E1E),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                sublabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? activeColor.withOpacity(0.8)
                      : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildResultCard() {
    final isYes = _selectedAnswer == 'Yes';

    return Container(
      key: ValueKey(_selectedAnswer),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isYes ? Colors.red.shade200 : Colors.green.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isYes ? Colors.red : Colors.green).withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Emotion Avatar Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isYes ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isYes ? Icons.favorite_border_rounded : Icons.verified_rounded,
              color: isYes ? Colors.red : const Color(0xFF2E7D32),
              size: 34,
            ),
          ),

          const SizedBox(height: 16),

          // Card Title: WHY? or CONGRATULATIONS
          Text(
            isYes ? 'WHY?' : 'CONGRATULATIONS',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isYes ? Colors.red : const Color(0xFF2E7D32),
              fontSize: isYes ? 26 : 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 12),

          // Card Description matching original wording
          Text(
            isYes
                ? 'Take early preventive measures to prevent the situation from worsening.'
                : 'You have managed your emotion succesfully.\nContinue your positive life.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 8),

          // Extra supportive helper tip
          Text(
            isYes
                ? 'Explore our 10B stress management techniques to help you relax and regain control.'
                : 'Keep practicing healthy habits and self-care daily.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 24),

          // Action Button
          if (isYes) ...[
            // "Start" button for Yes
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/methods');
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Start 10B Techniques',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Counselor shortcut
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/counselor');
              },
              child: Text(
                'Need to talk to someone? Contact a counselor',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ] else ...[
            // "Back to Home" button for No
            Container(
              width: 170,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home_outlined,
                          size: 18, color: Colors.black87),
                      SizedBox(width: 6),
                      Text(
                        'Back to Home',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}