import 'package:flutter/material.dart';

import '../widgets/app_background.dart';
import '../widgets/app_back_button.dart';
import 'result_dass_screen.dart';

class DassQuestionsScreen extends StatefulWidget {
  const DassQuestionsScreen({super.key});

  @override
  State<DassQuestionsScreen> createState() => _DassQuestionsScreenState();
}

class _DassQuestionsScreenState extends State<DassQuestionsScreen> {
  // 21 DASS questions 
  final List<String> questions = const [
    'Saya rasa susah untuk bertenang',
    'Saya sedar mulut saya rasa kering',
    'Saya seolah-olah tidak dapat mengalami perasaan positif sama sekali',
    'Saya mengalami kesukaran bernafas (contohnya, bernafas terlalu cepat Tercungap-cungap walaupun tidak melakukan aktiviti fizikal)',
    'Saya rasa tidak bersemangat untuk memulakan sesuatu keadaan',
    'Saya cenderung bertindak secara berlebihan kepada sesuatu keadaan',
    'Saya pernah menggeletar (contohnya tangan)',
    'Saya rasa saya terlalu gelisah',
    'Saya risau akan berlaku keadaan di mana saya panik dan berkelakuan bodoh',
    'Saya rasa tidak ada yang saya harapkan (putus harapan)',
    'Saya dapati saya mudah resah',
    'Saya merasa sukar untuk relaks',
    'Saya rasa muram dan sedih',
    'Saya tidak boleh terima apa jua yang menghalangi saya daripada meneruskan apa yang saya sedang lakukan',
    'Saya rasa hampir panik',
    'Saya tidak bersemangat langsung',
    'Saya rasa diri saya tidak berharga',
    'Saya mudah tersinggung',
    'Walaupun saya tidak melakukan aktiviti fizikal, saya sedar akan debaran Jantung saya (contoh: degupan jantung lebih cepat)',
    'Saya rasa takut tanpa sebab',
    'Saya rasa hidup ini tidak beerti lagi',
  ];

  final Map<int, String> scaleDescriptions = const {
    0: 'Tidak pernah sama sekali',
    1: 'Jarang',
    2: 'Kerap',
    3: 'Sangat kerap',
  };

  // Map of question index (1-based: 1..21) to selected score (0..3)
  final Map<int, int> answers = {};

  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _questionKeys = {};

  bool _attemptedSubmit = false;

  @override
  void initState() {
    super.initState();
    for (int i = 1; i <= questions.length; i++) {
      _questionKeys[i] = GlobalKey();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onSelectScore(int questionNumber, int score) {
    setState(() {
      answers[questionNumber] = score;
    });
  }

  void _submitAndGetResult() {
    // Check if any questions are unanswered
    final unanswered = <int>[];
    for (int i = 1; i <= questions.length; i++) {
      if (!answers.containsKey(i)) {
        unanswered.add(i);
      }
    }

    if (unanswered.isNotEmpty) {
      setState(() {
        _attemptedSubmit = true;
      });

      final firstUnanswered = unanswered.first;
      final key = _questionKeys[firstUnanswered];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.12,
        );
      }
      return;
    }

    // All 21 questions answered -> Navigate to ResultDassScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultDassScreen(answers: answers),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final answeredCount = answers.length;
    final totalCount = questions.length;
    final progress = answeredCount / totalCount;

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
                        'UJIAN DASS',
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

                  // Kemajuan Jawapan
                  _buildProgressSection(answeredCount, totalCount, progress),
                  const SizedBox(height: 12),

                  // Questions list
                  Expanded(
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 40),
                      children: [
                        // Instructions card (Bahagian 1)
                        _buildInstructionCard(),
                        const SizedBox(height: 16),

                        // 21 Question cards
                        for (int i = 0; i < questions.length; i++) ...[
                          _buildQuestionCard(i + 1, questions[i]),
                          const SizedBox(height: 14),
                        ],

                        const SizedBox(height: 10),

                        // Kotak "Lihat Keputusan" di bawah soalan terakhir
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                ],
              ),
              const AppBackButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(int answeredCount, int totalCount, double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kemajuan Jawapan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              Text(
                '$answeredCount / $totalCount soalan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: answeredCount == totalCount
                      ? const Color(0xFF2E7D32)
                      : const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                answeredCount == totalCount
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFD94B4B),
              ),
            ),
          ),
          if (_attemptedSubmit && answeredCount < totalCount) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFECEC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFB3B3), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 16, color: Color(0xFFD94B4B)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sila lengkapkan ${totalCount - answeredCount} soalan lagi untuk mendapatkan keputusan.',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD94B4B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD4D4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB64A52).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Saringan Minda Sihat',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Sila baca kenyataan dan pilih jawapan (skala 0, 1, 2, 3) yang menggambarkan keadaan anda SEMINGGU yang lepas. Tidak ada jawapan yang betul atau salah. Jangan guna terlalu banyak masa untuk mana-mana kenyataan.',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const Divider(height: 20, thickness: 0.8),
          const Text(
            'Panduan Skala Markah:',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildScaleBadge('0', 'Tidak pernah sama sekali'),
              _buildScaleBadge('1', 'Jarang'),
              _buildScaleBadge('2', 'Kerap'),
              _buildScaleBadge('3', 'Sangat kerap'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScaleBadge(String score, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFD2D2)),
      ),
      child: Text(
        '$score = $label',
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: Color.fromARGB(255, 140, 52, 57),
        ),
      ),
    );
  }



  Widget _buildQuestionCard(int questionNumber, String questionText) {
    final selectedScore = answers[questionNumber];
    final isAnswered = selectedScore != null;
    final isHighlighted = !isAnswered && _attemptedSubmit;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      key: _questionKeys[questionNumber],
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isHighlighted
              ? const Color(0xFFD94B4B)
              : const Color(0xFFE8DFDF),
          width: isHighlighted ? 2.0 : (isAnswered ? 1.5 : 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$questionNumber .',
                style: const TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  height: 1.35,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  questionText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (int score = 0; score <= 3; score++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: score == 0 ? 0 : 4,
                      right: score == 3 ? 0 : 4,
                    ),
                    child: _buildOptionButton(
                      questionNumber: questionNumber,
                      score: score,
                      isSelected: selectedScore == score,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required int questionNumber,
    required int score,
    required bool isSelected,
  }) {

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onSelectScore(questionNumber, score),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD94B4B) : const Color(0xFFF9F7F7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFD94B4B)
                  : Colors.grey.shade300,
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD94B4B).withOpacity(0.24),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD94B4B),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: _submitAndGetResult,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Lihat Keputusan',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}