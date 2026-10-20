/// Calculation and Scoring Logic for DASS-21 (Depression Anxiety Stress Scales)
class DassCalculationResult {
  final int stressScore;
  final int anxietyScore;
  final int depressionScore;

  final String stressLevel;
  final String anxietyLevel;
  final String depressionLevel;

  final Map<int, int> answers;

  const DassCalculationResult({
    required this.stressScore,
    required this.anxietyScore,
    required this.depressionScore,
    required this.stressLevel,
    required this.anxietyLevel,
    required this.depressionLevel,
    required this.answers,
  });

  /// Check whether any category falls under 'Teruk' or 'Sangat Teruk'
  bool get needsCounselorAdvice =>
      stressLevel == 'Teruk' ||
      stressLevel == 'Sangat Teruk' ||
      anxietyLevel == 'Teruk' ||
      anxietyLevel == 'Sangat Teruk' ||
      depressionLevel == 'Teruk' ||
      depressionLevel == 'Sangat Teruk';
}

/// DASS-21 Questions grouping and calculation formulas
class DassCalculator {
  // Question sets according to DASS-21 Bahagian 2
  static const List<int> stressQuestions = [1, 6, 8, 11, 12, 14, 18];
  static const List<int> anxietyQuestions = [2, 4, 7, 9, 15, 19, 20];
  static const List<int> depressionQuestions = [3, 5, 10, 13, 16, 17, 21];

  /// Calculate scores and severity levels from answers map (questionId -> score)
  static DassCalculationResult calculate(Map<int, int> answers) {
    int stressScore = 0;
    for (final q in stressQuestions) {
      stressScore += answers[q] ?? 0;
    }

    int anxietyScore = 0;
    for (final q in anxietyQuestions) {
      anxietyScore += answers[q] ?? 0;
    }

    int depressionScore = 0;
    for (final q in depressionQuestions) {
      depressionScore += answers[q] ?? 0;
    }

    return DassCalculationResult(
      stressScore: stressScore,
      anxietyScore: anxietyScore,
      depressionScore: depressionScore,
      stressLevel: getStressLevel(stressScore),
      anxietyLevel: getAnxietyLevel(anxietyScore),
      depressionLevel: getDepressionLevel(depressionScore),
      answers: answers,
    );
  }

  /// Stress thresholds: Normal (0-7), Ringan (8-9), Sederhana (10-13), Teruk (14-17), Sangat Teruk (18+)
  static String getStressLevel(int score) {
    if (score <= 7) return 'Normal';
    if (score <= 9) return 'Ringan';
    if (score <= 13) return 'Sederhana';
    if (score <= 17) return 'Teruk';
    return 'Sangat Teruk';
  }

  /// Anzieti thresholds: Normal (0-4), Ringan (5-6), Sederhana (7-8), Teruk (9-10), Sangat Teruk (11+)
  static String getAnxietyLevel(int score) {
    if (score <= 4) return 'Normal';
    if (score <= 6) return 'Ringan';
    if (score <= 8) return 'Sederhana';
    if (score <= 10) return 'Teruk';
    return 'Sangat Teruk';
  }

  /// Depression thresholds: Normal (0-5), Ringan (6-7), Sederhana (8-10), Teruk (11-14), Sangat Teruk (15+)
  static String getDepressionLevel(int score) {
    if (score <= 5) return 'Normal';
    if (score <= 7) return 'Ringan';
    if (score <= 10) return 'Sederhana';
    if (score <= 14) return 'Teruk';
    return 'Sangat Teruk';
  }
}

