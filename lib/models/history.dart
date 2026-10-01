class EmotionHistory {
  final String checkId;
  final String userId;
  final String fullName;
  final String answer;
  final String date;
  final String time;

  EmotionHistory({
    required this.checkId,
    required this.userId,
    this.fullName = '',
    required this.answer,
    required this.date,
    required this.time,
  });

  factory EmotionHistory.fromJson(Map<String, dynamic> json) {
    return EmotionHistory(
      checkId: json['check_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
    );
  }
}

class ActivityHistory {
  final String activityId;
  final String userId;
  final String fullName;
  final String methodId;
  final String methodName;
  final String date;
  final String time;

  ActivityHistory({
    required this.activityId,
    required this.userId,
    this.fullName = '',
    required this.methodId,
    required this.methodName,
    required this.date,
    required this.time,
  });

  factory ActivityHistory.fromJson(Map<String, dynamic> json) {
    return ActivityHistory(
      activityId: json['activity_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      methodId: json['method_id']?.toString() ?? '',
      methodName: json['method_name']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
    );
  }
}

