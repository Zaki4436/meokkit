class DassTest {
  final String testId;
  final String userId;
  final String matrikNo;
  final String fullName;
  final String stress;
  final String anzieti;
  final String depression;

  DassTest({
    required this.testId,
    this.userId = '',
    required this.matrikNo,
    required this.fullName,
    required this.stress,
    required this.anzieti,
    required this.depression,
  });

  factory DassTest.fromJson(Map<String, dynamic> json) {
    final rawUserId = json['user_id']?.toString() ?? '';
    final rawMatrikNo = json['matrik_no']?.toString() ?? json['matric_no']?.toString() ?? '';
    return DassTest(
      testId: json['test_id']?.toString() ?? '',
      userId: rawUserId,
      matrikNo: rawMatrikNo.isNotEmpty ? rawMatrikNo : rawUserId,
      fullName: json['full_name']?.toString() ?? '',
      stress: json['stress']?.toString() ?? '',
      anzieti: json['anzieti']?.toString() ?? json['anxiety']?.toString() ?? '',
      depression: json['depression']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'test_id': testId,
      'user_id': userId,
      'matrik_no': matrikNo,
      'full_name': fullName,
      'stress': stress,
      'anzieti': anzieti,
      'depression': depression,
    };
  }
}

