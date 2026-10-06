import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';

class CheckEmotionScreen extends StatefulWidget {
  const CheckEmotionScreen({super.key});

  @override
  State<CheckEmotionScreen> createState() => _CheckEmotionScreenState();
}

class _CheckEmotionScreenState extends State<CheckEmotionScreen>
    with SingleTickerProviderStateMixin {
  static const Color _accent = Color(0xFFE65B63);
  static const Color _deepAccent = Color(0xFFBD3546);
  static const Color _ink = Color(0xFF382C2C);

  late final AnimationController _entranceController;
  String? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

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
      extendBody: true,
      backgroundColor: const Color(0xFFFFF8F7),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFF5F2),
                    Color(0xFFFFFCFB),
                    Color(0xFFFFF1F3),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 28,
                    right: -70,
                    child: _backgroundOrb(
                      210,
                      const Color(0xFFF4A6A0).withOpacity(0.10),
                    ),
                  ),
                  Positioned(
                    bottom: 95,
                    left: -95,
                    child: _backgroundOrb(
                      230,
                      const Color(0xFFE98F9A).withOpacity(0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  Positioned.fill(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(22, 64, 22, 12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildEntrance(
                                0,
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 20,
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 14),
                                      const Expanded(
                                        child: Text(
                                          'STRESS CHECK',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: _ink,
                                            fontSize: 23,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 7),
                              _buildEntrance(
                                0.18,
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.92),
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                        color: const Color(0xFFF1D4D2)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF9F3D48)
                                            .withOpacity(0.08),
                                        blurRadius: 16,
                                        offset: const Offset(0, 5),
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
                                          color: _ink,
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildChoiceCard(
                                              label: 'No',
                                              sublabel: 'I feel calm & okay',
                                              icon: Icons
                                                  .sentiment_satisfied_alt_rounded,
                                              isSelected:
                                                  _selectedAnswer == 'No',
                                              isLocked: _selectedAnswer != null,
                                              activeColor:
                                                  const Color(0xFF5B9B70),
                                              onTap: _selectedAnswer == null
                                                  ? () =>
                                                      _onAnswerSelected('No')
                                                  : null,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildChoiceCard(
                                              label: 'Yes',
                                              sublabel: 'I feel stressed',
                                              icon: Icons
                                                  .sentiment_dissatisfied_rounded,
                                              isSelected:
                                                  _selectedAnswer == 'Yes',
                                              isLocked: _selectedAnswer != null,
                                              activeColor: _accent,
                                              onTap: _selectedAnswer == null
                                                  ? () =>
                                                      _onAnswerSelected('Yes')
                                                  : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 480),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                transitionBuilder: (child, animation) =>
                                    FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.07),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                ),
                                child: _selectedAnswer == null
                                    ? _buildPromptPlaceholder()
                                    : _buildResultCard(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 12,
                    child: Material(
                      color: Colors.white.withOpacity(0.88),
                      shape: const CircleBorder(),
                      elevation: 3,
                      shadowColor: _deepAccent.withOpacity(0.16),
                      child: IconButton(
                        tooltip: 'Back',
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: _deepAccent,
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
        ],
      ),
    );
  }

  Widget _backgroundOrb(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildEntrance(double start, Widget child) {
    return AnimatedBuilder(
      animation: _entranceController,
      child: child,
      builder: (context, child) {
        final progress = Curves.easeOutCubic.transform(
          ((_entranceController.value - start) / (1 - start))
              .clamp(0.0, 1.0)
              .toDouble(),
        );
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - progress)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildPromptPlaceholder() {
    return Container(
      key: const ValueKey('prompt'),
      width: double.infinity,
      height: 104,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF1D4D2),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9F3D48).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.92, end: 1),
          duration: const Duration(milliseconds: 750),
          curve: Curves.easeInOut,
          builder: (context, scale, child) => Transform.scale(
            scale: scale,
            child: child,
          ),
          child: Text(
            'Select your current emotion\nstate to see the result',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _ink,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
        ),
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
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
      opacity: isDimmed ? 0.45 : 1.0,
      child: AnimatedScale(
        scale: isSelected ? 1.035 : 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(17),
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeInOutCubic,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 13),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          activeColor.withOpacity(0.12),
                          activeColor.withOpacity(0.05),
                        ],
                      )
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, Color(0xFFFFF9F8)],
                      ),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: isSelected
                      ? activeColor.withOpacity(0.7)
                      : const Color(0xFFF1D4D2),
                  width: isSelected ? 1.8 : 1.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: activeColor.withOpacity(isSelected ? 0.14 : 0.04),
                    blurRadius: isSelected ? 14 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AnimatedScale(
                        scale: isSelected ? 1.12 : 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        child: Icon(
                          icon,
                          color: isSelected ? activeColor : _deepAccent,
                          size: 25,
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isSelected ? activeColor : Colors.white,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: isSelected
                                ? activeColor
                                : const Color(0xFFDCC8C8),
                            width: 1.4,
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: isSelected
                              ? const Icon(
                                  Icons.check_rounded,
                                  key: ValueKey('selected'),
                                  color: Colors.white,
                                  size: 15,
                                )
                              : const SizedBox(
                                  key: ValueKey('unselected'),
                                  width: 15,
                                  height: 15,
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? activeColor : _ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sublabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? activeColor.withOpacity(0.82)
                          : const Color(0xFF887779),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final isYes = _selectedAnswer == 'Yes';
    final resultColor = isYes ? _deepAccent : const Color(0xFF5B9B70);

    return Container(
      key: ValueKey(_selectedAnswer),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFFFF9F8)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: resultColor.withOpacity(0.32),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: resultColor.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Card Title: WHY? or CONGRATULATIONS
          Text(
            isYes ? 'WHY?' : 'CONGRATULATIONS',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: resultColor,
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

          const SizedBox(height: 22),

          // Action Button
          if (isYes) ...[
            // "Start" button for Yes
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_accent, _deepAccent],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: _deepAccent.withOpacity(0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
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
                  color: _deepAccent,
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
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFFFF1F0)],
                ),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: const Color(0xFFF1D4D2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: _deepAccent.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(13),
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
                      Text(
                        'Back to Home',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _ink,
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
