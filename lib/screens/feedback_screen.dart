import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';

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

  Future<void> _submitFeedback() async {
    if (_selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sila pilih "Yes" atau "No" terlebih dahulu.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final text = _feedbackController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sila tulis maklum balas anda terlebih dahulu.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = await AuthService.getUser();
    if (!mounted) return;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sila log masuk untuk menghantar maklum balas.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
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
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Maklum balas anda telah berjaya dihantar! Terima kasih.'),
            backgroundColor: Color(0xFF2E7D32),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal menghantar maklum balas.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ralat sambungan: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
    const primaryColor = Color(0xFFD94B4B);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'FEEDBACK',
          style: TextStyle(
            color: primaryColor,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.12),
                      primaryColor.withOpacity(0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.25),
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
                              color: Color(0xFF1E1E1E),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
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
                      color: Color(0xFF1E1E1E),
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
                          _selectedMethodId = _methodIdMap[newValue] ?? '';
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
                      isSelected: _selectedAnswer == 'Yes' || _selectedAnswer == 'Ya',
                      activeColor: const Color(0xFF2E7D32),
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
                      isSelected: _selectedAnswer == 'No' || _selectedAnswer == 'Tidak',
                      activeColor: primaryColor,
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
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _feedbackController,
                  focusNode: _focusNode,
                  maxLines: 6,
                  minLines: 4,
                  textInputAction: TextInputAction.newline,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1E1E1E),
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

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
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

              const SizedBox(height: 30),
            ],
          ),
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
        duration: const Duration(milliseconds: 150),
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade300,
            width: isSelected ? 1.8 : 1.0,
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
