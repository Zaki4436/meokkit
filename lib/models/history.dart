class EmotionHistory {
  final String checkId;
  final String matrikNo;
  final String userId;
  final String fullName;
  final String answer;
  final String date;
  final String time;

  EmotionHistory({
    required this.checkId,
    required this.userId,
    String? matrikNo,
    this.fullName = '',
    required this.answer,
    required this.date,
    required this.time,
  }) : matrikNo = matrikNo ?? userId;

  factory EmotionHistory.fromJson(Map<String, dynamic> json) {
    final rawUserId = json['user_id']?.toString() ?? '';
    final rawMatrikNo = json['matrik_no']?.toString() ?? json['matric_no']?.toString() ?? '';
    final effectiveUserId = rawUserId.isNotEmpty ? rawUserId : rawMatrikNo;
    final effectiveMatrikNo = rawMatrikNo.isNotEmpty ? rawMatrikNo : rawUserId;

    return EmotionHistory(
      checkId: json['check_id']?.toString() ?? '',
      userId: effectiveUserId,
      matrikNo: effectiveMatrikNo,
      fullName: json['full_name']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'check_id': checkId,
      'matrik_no': matrikNo,
      'user_id': userId,
      'full_name': fullName,
      'answer': answer,
      'date': date,
      'time': time,
    };
  }
}

class ActivityHistory {
  final String activityId;
  final String matrikNo;
  final String userId;
  final String fullName;
  final String methodId;
  final String methodName;
  final String date;
  final String time;

  ActivityHistory({
    required this.activityId,
    required this.userId,
    String? matrikNo,
    this.fullName = '',
    required this.methodId,
    required this.methodName,
    required this.date,
    required this.time,
  }) : matrikNo = matrikNo ?? userId;

  factory ActivityHistory.fromJson(Map<String, dynamic> json) {
    final rawUserId = json['user_id']?.toString() ?? '';
    final rawMatrikNo = json['matrik_no']?.toString() ?? json['matric_no']?.toString() ?? '';
    final effectiveUserId = rawUserId.isNotEmpty ? rawUserId : rawMatrikNo;
    final effectiveMatrikNo = rawMatrikNo.isNotEmpty ? rawMatrikNo : rawUserId;

    return ActivityHistory(
      activityId: json['activity_id']?.toString() ?? '',
      userId: effectiveUserId,
      matrikNo: effectiveMatrikNo,
      fullName: json['full_name']?.toString() ?? '',
      methodId: json['method_id']?.toString() ?? '',
      methodName: json['method_name']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_id': activityId,
      'matrik_no': matrikNo,
      'user_id': userId,
      'full_name': fullName,
      'method_id': methodId,
      'method_name': methodName,
      'date': date,
      'time': time,
    };
  }
}
