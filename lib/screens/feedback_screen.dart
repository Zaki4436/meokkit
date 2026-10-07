import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/app_background.dart';

class FeedbackScreen extends StatefulWidget {
  final String? initialMethodId;
  final String? initialMethodName;

  const FeedbackScreen({
    super.key,
    this.initialMethodId,
    this.initialMethodName,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isSubmitting = false;
  String? _statusMessage;
  bool _statusIsSuccess = false;
  String _selectedMethod = 'Keseluruhan Kaedah 10B';
  String? _selectedMethodId;
  String? _selectedAnswer; // 'Yes' or 'No'

  static const Map<String, String> _methodIdMap = {
    'Bertenang': '1',
    'Bernafas Dengan Dalam': '2',
    'Berkata "Relakslah"': '3',
    'Beribadat': '4',
    'Bercakap Dengan Seseorang': '5',
    'Berurut': '6',
    'Berehat & Mendengar Muzik': '7',
    'Beriadah': '8',
    'Bersenam': '9',
    'Berfikiran Positif': '10',
  };

  final List<String> _methodsList = [
    'Keseluruhan Kaedah 10B',
    'Bertenang',
    'Bernafas Dengan Dalam',
    'Berkata "Relakslah"',
    'Beribadat',
    'Bercakap Dengan Seseorang',
    'Berurut',
    'Berehat & Mendengar Muzik',
    'Beriadah',
    'Bersenam',
    'Berfikiran Positif',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialMethodId != null &&
        widget.initialMethodId!.trim().isNotEmpty) {
      _selectedMethodId = widget.initialMethodId!.trim();
    }

    if (widget.initialMethodName != null &&
        widget.initialMethodName!.trim().isNotEmpty) {
      final match = _methodsList.firstWhere(
        (m) =>
            m.toLowerCase() == widget.initialMethodName!.trim().toLowerCase(),
        orElse: () => widget.initialMethodName!.trim(),
      );
      if (!_methodsList.contains(match)) {
        _methodsList.insert(1, match);
      }
      _selectedMethod = match;
      _selectedMethodId ??= _methodIdMap[match];
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showStatus(String message, {required bool isSuccess}) {
    setState(() {
      _statusMessage = message;
      _statusIsSuccess = isSuccess;
    });
  }

  Future<void> _submitFeedback() async {
    if (_selectedAnswer == null) {
      _showStatus(
        'Sila pilih "Ya" atau "Tidak" terlebih dahulu.',
        isSuccess: false,
      );
      return;
    }

    final text = _feedbackController.text.trim();

    final user = await AuthService.getUser();
    if (!mounted) return;
    if (user == null) {
      _showStatus(
        'Sila log masuk untuk menghantar maklum balas.',
        isSuccess: false,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _statusMessage = null;
    });

    final isAll = _selectedMethod == 'Keseluruhan Kaedah 10B';
    final methodName = isAll ? '' : _selectedMethod;
    final methodId = isAll
        ? ''
        : (_selectedMethodId != null && _selectedMethodId!.isNotEmpty
            ? _selectedMethodId!
            : (_methodIdMap[_selectedMethod] ?? ''));

    try {
      final result = await ApiService.post({
        'action': 'saveFeedback',
        'user_id': user.userId,
        'method_id': methodId,
        'method_name': methodName,
        'answer': _selectedAnswer,
        'description': text,
      });

      if (!mounted) return;

      if (result['success'] == true) {
        _feedbackController.clear();
        _focusNode.unfocus();
        setState(() {
          _selectedAnswer = null;
          _statusMessage =
              'Maklum balas anda telah berjaya dihantar! Terima kasih.';
          _statusIsSuccess = true;
        });
      } else {
        _showStatus(
          result['message'] ?? 'Gagal menghantar maklum balas.',
          isSuccess: false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showStatus('Ralat sambungan: $e', isSuccess: false);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFBD3546);
    const accentColor = Color(0xFFE65B63);
    const inkColor = Color(0xFF382C2C);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: AppBackground(
        child: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 66, 22, 12),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, progress, child) => Opacity(
                  opacity: progress,
                  child: Transform.translate(
                    offset: Offset(0, 16 * (1 - progress)),
                    child: child,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'FEEDBACK',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white,
                            const Color(0xFFFFE9E8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF9B6669),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.rate_review_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Maklum Balas Kaedah 10B',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: inkColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Kongsi pendapat, perasaan, atau pengalaman anda selepas mencuba teknik pengurusan stres 10B.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Method selection dropdown
                    const Text(
                      'Kaedah 10B Yang Dicuba',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF1D4D2)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedMethod,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down,
                              color: primaryColor),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: inkColor,
                          ),
                          items: _methodsList.map((String method) {
                            return DropdownMenuItem<String>(
                              value: method,
                              child: Text(method),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedMethod = newValue;
                                _selectedMethodId =
                                    _methodIdMap[newValue] ?? '';
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Ya/Tidak Selection (Simple Box)
                    const Text(
                      'Adakah kaedah ini membantu anda?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: _buildSimpleBox(
                            label: 'Ya',
                            isSelected: _selectedAnswer == 'Yes' ||
                                _selectedAnswer == 'Ya',
                            activeColor: const Color(0xFF5B9B70),
                            onTap: () {
                              setState(() {
                                _selectedAnswer = 'Yes';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSimpleBox(
                            label: 'Tidak',
                            isSelected: _selectedAnswer == 'No' ||
                                _selectedAnswer == 'Tidak',
                            activeColor: accentColor,
                            onTap: () {
                              setState(() {
                                _selectedAnswer = 'No';
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Feedback description input
                    const Text(
                      'Maklum Balas / Pengalaman Anda',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF1D4D2)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9F3D48).withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _feedbackController,
                        focusNode: _focusNode,
                        maxLines: 6,
                        minLines: 4,
                        textInputAction: TextInputAction.newline,
                        style: const TextStyle(
                          fontSize: 14,
                          color: inkColor,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Tulis apa sahaja maklum balas anda di sini... Contohnya bagaimana kaedah ini membantu anda berasa lebih tenang.',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade400,
                            height: 1.4,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    AnimatedSize(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeInOutCubic,
                      child: _statusMessage == null
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Container(
                                  key: ValueKey(
                                    '${_statusIsSuccess}_$_statusMessage',
                                  ),
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusIsSuccess
                                        ? const Color(0xFFEAF5ED)
                                        : const Color(0xFFFFEEEE),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _statusIsSuccess
                                          ? const Color(0xFFA8D2B1)
                                          : const Color(0xFFE9B8B8),
                                    ),
                                  ),
                                  child: Text(
                                    _statusMessage!,
                                    style: TextStyle(
                                      color: _statusIsSuccess
                                          ? const Color(0xFF28633A)
                                          : const Color(0xFF9B3038),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),

                    // Submit button
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [accentColor, primaryColor],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.24),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: _isSubmitting ? null : _submitFeedback,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: _isSubmitting
                              ? const SizedBox(
                                  key: ValueKey('submitting'),
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  key: ValueKey('submit'),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.send_rounded, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Hantar Maklum Balas',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 41,
            left: 12,
            child: Material(
              color: Colors.white.withOpacity(0.88),
              shape: const CircleBorder(),
              elevation: 3,
              shadowColor: primaryColor.withOpacity(0.16),
              child: IconButton(
                tooltip: 'Back',
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: primaryColor,
                  size: 19,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildSimpleBox({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubic,
        height: 48,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    activeColor,
                    Color.lerp(activeColor, Colors.black, 0.12)!,
                  ],
                )
              : const LinearGradient(
                  colors: [Colors.white, Color(0xFFFFF9F8)],
                ),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFF1D4D2),
            width: isSelected ? 1.6 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFF333333),
            ),
          ),
        ),
      ),
    );
  }
}
