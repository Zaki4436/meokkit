import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/app_background.dart';
import 'counselor_screen.dart';

class ResultDassScreen extends StatefulWidget {
  final Map<int, int> answers;

  const ResultDassScreen({
    super.key,
    required this.answers,
  });

  @override
  State<ResultDassScreen> createState() => _ResultDassScreenState();
}

class _ResultDassScreenState extends State<ResultDassScreen> {
  // Question sets according to Bahagian 2
  static const List<int> stressQuestions = [1, 6, 8, 11, 12, 14, 18];
  static const List<int> anxietyQuestions = [2, 4, 7, 9, 15, 19, 20];
  static const List<int> depressionQuestions = [3, 5, 10, 13, 16, 17, 21];

  late int stressScore;
  late int anxietyScore;
  late int depressionScore;

  late String stressLevel;
  late String anxietyLevel;
  late String depressionLevel;

  bool _isSaving = true;
  bool _saveSuccess = false;
  String? _saveErrorMessage;

  @override
  void initState() {
    super.initState();
    _calculateScores();
    _saveResultsToDatabase();
  }

  void _calculateScores() {
    stressScore = 0;
    for (final q in stressQuestions) {
      stressScore += widget.answers[q] ?? 0;
    }

    anxietyScore = 0;
    for (final q in anxietyQuestions) {
      anxietyScore += widget.answers[q] ?? 0;
    }

    depressionScore = 0;
    for (final q in depressionQuestions) {
      depressionScore += widget.answers[q] ?? 0;
    }

    // Determine levels based on SKOR SARINGAN
    stressLevel = _getStressLevel(stressScore);
    anxietyLevel = _getAnxietyLevel(anxietyScore);
    depressionLevel = _getDepressionLevel(depressionScore);
  }

  // Stress thresholds: Normal (0-7), Ringan (8-9), Sederhana (10-13), Teruk (14-17), Sangat Teruk (18+)
  String _getStressLevel(int score) {
    if (score <= 7) return 'Normal';
    if (score <= 9) return 'Ringan';
    if (score <= 13) return 'Sederhana';
    if (score <= 17) return 'Teruk';
    return 'Sangat Teruk';
  }

  // Anzieti thresholds: Normal (0-4), Ringan (5-6), Sederhana (7-8), Teruk (9-10), Sangat Teruk (11+)
  String _getAnxietyLevel(int score) {
    if (score <= 4) return 'Normal';
    if (score <= 6) return 'Ringan';
    if (score <= 8) return 'Sederhana';
    if (score <= 10) return 'Teruk';
    return 'Sangat Teruk';
  }

  // Depression thresholds: Normal (0-5), Ringan (6-7), Sederhana (8-10), Teruk (11-14), Sangat Teruk (15+)
  String _getDepressionLevel(int score) {
    if (score <= 5) return 'Normal';
    if (score <= 7) return 'Ringan';
    if (score <= 10) return 'Sederhana';
    if (score <= 14) return 'Teruk';
    return 'Sangat Teruk';
  }

  Future<void> _saveResultsToDatabase() async {
    setState(() {
      _isSaving = true;
      _saveSuccess = false;
      _saveErrorMessage = null;
    });

    final user = await AuthService.getUser();
    if (user == null) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveErrorMessage = 'Pengguna tidak ditemui. Sila log masuk semula.';
        });
      }
      return;
    }

    try {
      final result = await ApiService.saveDassTest(
        userId: user.userId,
        matrikNo: user.matrikNo,
        fullName: user.fullName,
        stress: stressLevel,
        anzieti: anxietyLevel,
        depression: depressionLevel,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _isSaving = false;
          _saveSuccess = true;
        });
      } else {
        setState(() {
          _isSaving = false;
          _saveErrorMessage =
              result['message']?.toString() ?? 'Gagal menyimpan keputusan.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saveErrorMessage = 'Ralat sambungan';
      });
    }
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Normal':
        return const Color(0xFF2E7D32); // Green
      case 'Ringan':
        return const Color(0xFF0288D1); // Light Blue / Info
      case 'Sederhana':
        return const Color(0xFFEF6C00); // Orange
      case 'Teruk':
        return const Color(0xFFC62828); // Red
      case 'Sangat Teruk':
        return const Color(0xFF880E4F); // Dark Red/Maroon
      default:
        return const Color(0xFF382C2C);
    }
  }

  Color _getLevelBgColor(String level) {
    switch (level) {
      case 'Normal':
        return const Color(0xFFE8F5E9);
      case 'Ringan':
        return const Color(0xFFE1F5FE);
      case 'Sederhana':
        return const Color(0xFFFFF3E0);
      case 'Teruk':
        return const Color(0xFFFFEBEE);
      case 'Sangat Teruk':
        return const Color(0xFFFCE4EC);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  bool get _needsCounselorAdvice {
    return stressLevel == 'Teruk' ||
        stressLevel == 'Sangat Teruk' ||
        anxietyLevel == 'Teruk' ||
        anxietyLevel == 'Sangat Teruk' ||
        depressionLevel == 'Teruk' ||
        depressionLevel == 'Sangat Teruk';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
                  children: [
                    // Save Status Banner
                    _buildSaveStatusBanner(),
                    const SizedBox(height: 14),

                    // BAHAGIAN 3: KEPUTUSAN UJIAN DASS
                    _buildBahagian3Card(),
                    const SizedBox(height: 18),

                    // Counselor prompt if high stress/anxiety/depression
                    if (_needsCounselorAdvice) ...[
                      _buildCounselorPromptCard(),
                      const SizedBox(height: 18),
                    ],

                    // BAHAGIAN 2: PANDUAN MENGIRA SKOR & SKOR SARINGAN
                    _buildBahagian2Card(),
                    const SizedBox(height: 24),

                    // Home button
                    _buildActionButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            color: const Color(0xFF382C2C),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Keputusan Ujian DASS',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF382C2C),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSaveStatusBanner() {
    if (_isSaving) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF90CAF9)),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text(
              'Menyimpan keputusan ke pangkalan data...',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1565C0),
              ),
            ),
          ],
        ),
      );
    }

    if (_saveSuccess) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFA5D6A7)),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Keputusan telah berjaya disimpan ke pangkalan data.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_saveErrorMessage != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFCDD2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Color(0xFFC62828), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _saveErrorMessage!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFC62828),
                ),
              ),
            ),
            TextButton(
              onPressed: _saveResultsToDatabase,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
              ),
              child: const Text('Cuba Lagi'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ==========================================
  // BAHAGIAN 3: KEPUTUSAN UJIAN DASS
  // ==========================================
  Widget _buildBahagian3Card() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFD4D4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB64A52).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD94B4B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'BAHAGIAN 3',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'KEPUTUSAN UJIAN DASS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF382C2C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Berikut adalah status kesihatan mental anda berdasarkan jawapan yang telah anda berikan:',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6E5658),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Result Tile 1: Stres
          _buildResultTile(
            categoryTitle: 'Stres (Tekanan)',
            score: stressScore,
            level: stressLevel,
            icon: Icons.psychology_outlined,
          ),
          const SizedBox(height: 12),

          // Result Tile 2: Anzieti
          _buildResultTile(
            categoryTitle: 'Anzieti (Kerisauan)',
            score: anxietyScore,
            level: anxietyLevel,
            icon: Icons.favorite_border_rounded,
          ),
          const SizedBox(height: 12),

          // Result Tile 3: Kemurungan
          _buildResultTile(
            categoryTitle: 'Kemurungan (Depression)',
            score: depressionScore,
            level: depressionLevel,
            icon: Icons.sentiment_very_dissatisfied_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildResultTile({
    required String categoryTitle,
    required int score,
    required String level,
    required IconData icon,
  }) {
    final levelColor = _getLevelColor(level);
    final levelBgColor = _getLevelBgColor(level);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: levelBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: levelColor.withOpacity(0.35), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: levelColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: levelColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryTitle,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2223),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Jumlah Skor: $score',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF5A4647),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: levelColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: levelColor.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              level,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounselorPromptCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD54F), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: Color(0xFFE65100), size: 22),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Saranan Sokongan Psikologi',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE65100),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Keputusan saringan anda menunjukkan indikasi tahap yang memerlukan perhatian. Anda digalakkan untuk berbincang bersama Kaunselor Kolej Matrikulasi Johor bagi sokongan bimbingan.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF5D4037),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE65100),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CounselorScreen()),
                );
              },
              icon: const Icon(Icons.calendar_today_rounded, size: 18),
              label: const Text(
                'Tempah Sesi Bersama Kaunselor',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BAHAGIAN 2: PANDUAN MENGIRA SKOR & SKOR SARINGAN
  // ==========================================
  Widget _buildBahagian2Card() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE0D8D8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF5A4647),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'BAHAGIAN 2',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Panduan Mengira Skor & Saringan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF382C2C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Skala markah jawapan bagi setiap soalan mengikut kategori:',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6E5658),
            ),
          ),
          const SizedBox(height: 12),

          // Stress Table Breakdown
          _buildCategoryBreakdownTable(
            title: 'STRESS (TEKANAN)',
            questionIds: stressQuestions,
            totalScore: stressScore,
          ),
          const SizedBox(height: 10),

          // Anzieti Table Breakdown
          _buildCategoryBreakdownTable(
            title: 'ANZIETI (KERISAUAN)',
            questionIds: anxietyQuestions,
            totalScore: anxietyScore,
          ),
          const SizedBox(height: 10),

          // Depression Table Breakdown
          _buildCategoryBreakdownTable(
            title: 'DEPRESSION (KEMURUNGAN)',
            questionIds: depressionQuestions,
            totalScore: depressionScore,
          ),
          const SizedBox(height: 18),

          const Divider(height: 10),
          const SizedBox(height: 12),

          const Text(
            'PETAK SKOR SARINGAN',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF382C2C),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),

          // SKOR SARINGAN Reference Table
          _buildSkorSaringanTable(),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownTable({
    required String title,
    required List<int> questionIds,
    required int totalScore,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFBF9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: const BoxDecoration(
              color: Color(0xFFE0D8D8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF382C2C),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 32,
              dataRowMinHeight: 30,
              dataRowMaxHeight: 32,
              columnSpacing: 14,
              horizontalMargin: 12,
              columns: [
                const DataColumn(
                  label: Text(
                    'Soalan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                  ),
                ),
                for (final q in questionIds)
                  DataColumn(
                    label: Text(
                      'S$q',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 11.5),
                    ),
                  ),
                const DataColumn(
                  label: Text(
                    'Jumlah',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                      color: Color(0xFFD94B4B),
                    ),
                  ),
                ),
              ],
              rows: [
                DataRow(
                  cells: [
                    const DataCell(
                      Text(
                        'Markah',
                        style: TextStyle(
                            fontSize: 11.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                    for (final q in questionIds)
                      DataCell(
                        Text(
                          '${widget.answers[q] ?? 0}',
                          style: const TextStyle(fontSize: 11.5),
                        ),
                      ),
                    DataCell(
                      Text(
                        '$totalScore',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD94B4B),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkorSaringanTable() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Table(
          border: TableBorder.all(color: Colors.grey.shade300, width: 0.8),
          columnWidths: const {
            0: FlexColumnWidth(1.2),
            1: FlexColumnWidth(1.1),
            2: FlexColumnWidth(1.0),
            3: FlexColumnWidth(1.0),
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFE8E0E0)),
              children: [
                _buildTableHeaderCell('Tahap'),
                _buildTableHeaderCell('Kemurungan'),
                _buildTableHeaderCell('Anzieti'),
                _buildTableHeaderCell('Stress'),
              ],
            ),
            _buildTableRow('Normal', '0 - 5', '0 - 4', '0 - 7',
                highlight: stressLevel == 'Normal' ||
                    anxietyLevel == 'Normal' ||
                    depressionLevel == 'Normal'),
            _buildTableRow('Ringan', '6 - 7', '5 - 6', '8 - 9',
                highlight: stressLevel == 'Ringan' ||
                    anxietyLevel == 'Ringan' ||
                    depressionLevel == 'Ringan'),
            _buildTableRow('Sederhana', '8 - 10', '7 - 8', '10 - 13',
                highlight: stressLevel == 'Sederhana' ||
                    anxietyLevel == 'Sederhana' ||
                    depressionLevel == 'Sederhana'),
            _buildTableRow('Teruk', '11 - 14', '9 - 10', '14 - 17',
                highlight: stressLevel == 'Teruk' ||
                    anxietyLevel == 'Teruk' ||
                    depressionLevel == 'Teruk'),
            _buildTableRow('Sangat Teruk', '15+', '11+', '18+',
                highlight: stressLevel == 'Sangat Teruk' ||
                    anxietyLevel == 'Sangat Teruk' ||
                    depressionLevel == 'Sangat Teruk'),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E2223),
        ),
      ),
    );
  }

  TableRow _buildTableRow(
    String col1,
    String col2,
    String col3,
    String col4, {
    bool highlight = false,
  }) {
    return TableRow(
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFFFF0F0) : Colors.white,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
          child: Text(
            col1,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
              color: highlight ? const Color(0xFFD94B4B) : const Color(0xFF382C2C),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
          child: Text(
            col2,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              color: const Color(0xFF382C2C),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
          child: Text(
            col3,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              color: const Color(0xFF382C2C),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
          child: Text(
            col4,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              color: const Color(0xFF382C2C),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD94B4B),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
        },
        child: const Text(
          'Kembali ke Laman Utama',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

