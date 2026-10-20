import 'package:flutter/material.dart';

import '../services/dass_service.dart';
import '../utils/dass_calculator.dart';
import '../widgets/app_background.dart';
/*import 'counselor_screen.dart';
import 'methods_screen.dart';*/

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
  late final DassCalculationResult calculationResult;

  @override
  void initState() {
    super.initState();
    // 1. Calculation: evaluate scores and severity levels from answers
    calculationResult = DassCalculator.calculate(widget.answers);

    // 2. Backend: save calculation results to database asynchronously
    DassService.saveResult(calculationResult);
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Normal':
        return const Color(0xFF2E7D32); // Green
      case 'Ringan':
        return const Color(0xFF2E7D32); // Light Blue / Info
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
        return const Color(0xFFFFFFFF);
      case 'Ringan':
        return const Color(0xFFFFFFFF);
      case 'Sederhana':
        return const Color(0xFFFFFFFF);
      case 'Teruk':
        return const Color(0xFFFFFFFF);
      case 'Sangat Teruk':
        return  const Color(0xFFFFFFFF);
      default:
        return const Color(0xFFFFFFFF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Content
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 40, 18, 40),
                      children: [
                        // BAHAGIAN 3: KEPUTUSAN UJIAN DASS
                        _buildBahagian3Card(),
                        const SizedBox(height: 18),

                        // Counselor prompt if high stress/anxiety/depression
                        if (calculationResult.needsCounselorAdvice) ...[
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
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // KEPUTUSAN UJIAN DASS
  // ==========================================
  Widget _buildBahagian3Card() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE0D8D8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB64A52).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'KEPUTUSAN UJIAN DASS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000000),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Berikut adalah status kesihatan mental anda berdasarkan jawapan yang telah anda berikan:',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF000000),
              height: 1.4,
              //fontWeight: FontWeight.w300
            ),
          ),
          const SizedBox(height: 16),

          // Result Tile 1: Stres
          _buildResultTile(
            categoryTitle: 'Stres',
            score: calculationResult.stressScore,
            level: calculationResult.stressLevel,
          ),
          const SizedBox(height: 12),

          // Result Tile 2: Anzieti
          _buildResultTile(
            categoryTitle: 'Anzieti',
            score: calculationResult.anxietyScore,
            level: calculationResult.anxietyLevel,
          ),
          const SizedBox(height: 12),

          // Result Tile 3: Kemurungan
          _buildResultTile(
            categoryTitle: 'Kemurungan',
            score: calculationResult.depressionScore,
            level: calculationResult.depressionLevel,
          ),
        ],
      ),
    );
  }

  Widget _buildResultTile({
    required String categoryTitle,
    required int score,
    required String level,
  }) {
    final levelColor = _getLevelColor(level);
    final levelBgColor = _getLevelBgColor(level);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: levelBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: levelColor.withOpacity(0.35), width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryTitle,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Jumlah Skor: $score',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF000000),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color.fromARGB(255, 190, 0, 0), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Saranan Sokongan Psikologi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 190, 0, 0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Keputusan saringan anda menunjukkan indeks pada tahap yang memerlukan perhatian. Anda digalakkan untuk berbincang bersama Kaunselor bagi sokongan bimbingan. Atau anda boleh melakukan Teknik Pengurusan Stress 10B.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF000000),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 190, 0, 0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/counselor');
              },
              child: const Text(
                'Hubungi Kaunselor',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 190, 0, 0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/methods',
                  (route) => true,
                );
              },
              child: const Text(
                'Teknik 10B',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          /*GestureDetector(
            child: Text(
              'Lakukan Teknik 10B',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF5D4037).withOpacity(0.9),
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),*/
        ],
      ),
    );
  }

  // ==========================================
  // PANDUAN MENGIRA SKOR & SKOR SARINGAN
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
          const Row(
            children: [
              Expanded(
                child: Text(
                  'PANDUAN MENGIRA SKOR & SARINGAN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
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
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          // Stress Table Breakdown
          _buildCategoryBreakdownTable(
            title: 'STRESS',
            questionIds: DassCalculator.stressQuestions,
            totalScore: calculationResult.stressScore,
          ),
          const SizedBox(height: 10),

          // Anzieti Table Breakdown
          _buildCategoryBreakdownTable(
            title: 'ANZIETI',
            questionIds: DassCalculator.anxietyQuestions,
            totalScore: calculationResult.anxietyScore,
          ),
          const SizedBox(height: 10),

          // Depression Table Breakdown
          _buildCategoryBreakdownTable(
            title: 'KEMURUNGAN',
            questionIds: DassCalculator.depressionQuestions,
            totalScore: calculationResult.depressionScore,
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
                color: Colors.black,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              border: TableBorder(
                top: BorderSide(color: Colors.grey.shade300, width: 0.8),
                horizontalInside:
                    BorderSide(color: Colors.grey.shade300, width: 0.8),
                verticalInside:
                    BorderSide(color: Colors.grey.shade300, width: 0.8),
              ),
              headingRowHeight: 32,
              dataRowMinHeight: 32,
              dataRowMaxHeight: 32,
              columnSpacing: 10,
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
                    headingRowAlignment: MainAxisAlignment.center,
                    label: SizedBox(
                      width: 28,
                      child: Center(
                        child: Text(
                          'S$q',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11.5),
                        ),
                      ),
                    ),
                  ),
                const DataColumn(
                  headingRowAlignment: MainAxisAlignment.center,
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
                        SizedBox(
                          width: 28,
                          child: Center(
                            child: Text(
                              '${widget.answers[q] ?? 0}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 11.5),
                            ),
                          ),
                        ),
                      ),
                    DataCell(
                      Center(
                        child: Text(
                          '$totalScore',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD94B4B),
                          ),
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
            _buildTableRow(
              level: 'Normal',
              depressionRange: '0 - 5',
              anxietyRange: '0 - 4',
              stressRange: '0 - 7',
              highlightDepression:
                  calculationResult.depressionLevel == 'Normal',
              highlightAnxiety: calculationResult.anxietyLevel == 'Normal',
              highlightStress: calculationResult.stressLevel == 'Normal',
            ),
            _buildTableRow(
              level: 'Ringan',
              depressionRange: '6 - 7',
              anxietyRange: '5 - 6',
              stressRange: '8 - 9',
              highlightDepression:
                  calculationResult.depressionLevel == 'Ringan',
              highlightAnxiety: calculationResult.anxietyLevel == 'Ringan',
              highlightStress: calculationResult.stressLevel == 'Ringan',
            ),
            _buildTableRow(
              level: 'Sederhana',
              depressionRange: '8 - 10',
              anxietyRange: '7 - 8',
              stressRange: '10 - 13',
              highlightDepression:
                  calculationResult.depressionLevel == 'Sederhana',
              highlightAnxiety: calculationResult.anxietyLevel == 'Sederhana',
              highlightStress: calculationResult.stressLevel == 'Sederhana',
            ),
            _buildTableRow(
              level: 'Teruk',
              depressionRange: '11 - 14',
              anxietyRange: '9 - 10',
              stressRange: '14 - 17',
              highlightDepression: calculationResult.depressionLevel == 'Teruk',
              highlightAnxiety: calculationResult.anxietyLevel == 'Teruk',
              highlightStress: calculationResult.stressLevel == 'Teruk',
            ),
            _buildTableRow(
              level: 'Sangat Teruk',
              depressionRange: '15+',
              anxietyRange: '11+',
              stressRange: '18+',
              highlightDepression:
                  calculationResult.depressionLevel == 'Sangat Teruk',
              highlightAnxiety:
                  calculationResult.anxietyLevel == 'Sangat Teruk',
              highlightStress: calculationResult.stressLevel == 'Sangat Teruk',
            ),
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
          color: Color(0xFF000000),
        ),
      ),
    );
  }

  TableRow _buildTableRow({
    required String level,
    required String depressionRange,
    required String anxietyRange,
    required String stressRange,
    required bool highlightDepression,
    required bool highlightAnxiety,
    required bool highlightStress,
  }) {
    return TableRow(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
          child: Text(
            level,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF000000),
            ),
          ),
        ),
        _buildScoreCell(depressionRange, isHighlight: highlightDepression),
        _buildScoreCell(anxietyRange, isHighlight: highlightAnxiety),
        _buildScoreCell(stressRange, isHighlight: highlightStress),
      ],
    );
  }

  Widget _buildScoreCell(String text, {required bool isHighlight}) {
    return Container(
      color: isHighlight ? const Color(0xFFFFECEC) : Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
          color: isHighlight ? const Color(0xFFD94B4B) : const Color(0xFF000000),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE65B63), Color(0xFFBD3546)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBD3546).withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          },
          child: const Center(
            child: Text(
              'Kembali ke Laman Utama',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
