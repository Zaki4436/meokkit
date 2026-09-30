import 'package:flutter/material.dart';

import '../models/history.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class FeedbackScreen extends StatefulWidget {
  final String? initialMethodName;

  const FeedbackScreen({
    super.key,
    this.initialMethodName,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isSubmitting = false;
  bool _isLoadingHistory = true;
  String _selectedMethod = 'Keseluruhan Kaedah 10B';

  List<FeedbackItem> _feedbackList = [];

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
    }
    _loadFeedbackHistory();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadFeedbackHistory() async {
    final user = await AuthService.getUser();
    if (user == null) {
      if (mounted) setState(() => _isLoadingHistory = false);
      return;
    }

    try {
      final result = await ApiService.get(
        'getFeedback',
        params: {
          'user_id': user.userId,
        },
      );

      if (result['success'] == true) {
        final data = result['data'];
        final List<dynamic> items = data['feedback'] ?? [];

        if (mounted) {
          setState(() {
            _feedbackList = items
                .map((item) => FeedbackItem.fromJson(item))
                .toList()
                .reversed
                .toList();
            _isLoadingHistory = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingHistory = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _submitFeedback() async {
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

    // Send method_name and answer
    final methodName = _selectedMethod == 'Keseluruhan Kaedah 10B'
        ? ''
        : _selectedMethod;

    try {
      final result = await ApiService.post({
        'action': 'saveFeedback',
        'user_id': user.userId,
        'method_name': methodName,
        'answer': text,
      });

      if (!mounted) return;

      if (result['success'] == true) {
        _feedbackController.clear();
        _focusNode.unfocus();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maklum balas anda telah berjaya disimpan! Terima kasih.'),
            backgroundColor: Color(0xFF2E7D32),
            duration: Duration(seconds: 3),
          ),
        );

        // Reload history
        _loadFeedbackHistory();
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
                      primaryColor.withValues(alpha: 0.12),
                      primaryColor.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.25),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedMethod,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: primaryColor),
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
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Feedback input
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
                  maxLines: 5,
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

              const SizedBox(height: 20),

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

              const SizedBox(height: 32),

              
              const SizedBox(height: 12),

              if (_isLoadingHistory)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              else if (_feedbackList.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 38,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Belum ada maklum balas yang dihantar.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _feedbackList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = _feedbackList[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.date.isNotEmpty ? item.date : '-',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              if (item.time.isNotEmpty)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      item.time,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          if (item.methodName.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.methodName,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            item.answer,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1E1E1E),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
