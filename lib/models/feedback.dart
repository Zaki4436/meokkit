class FeedbackItem {
  final String feedbackId;
  final String matrikNo;
  final String userId;
  final String fullName;
  final String methodId;
  final String methodName;
  final String answer;
  final String description;
  final String date;
  final String time;

  FeedbackItem({
    required this.feedbackId,
    required this.userId,
    String? matrikNo,
    this.fullName = '',
    this.methodId = '',
    this.methodName = '',
    required this.answer,
    this.description = '',
    required this.date,
    required this.time,
  }) : matrikNo = matrikNo ?? userId;

  factory FeedbackItem.fromJson(Map<String, dynamic> json) {
    final rawUserId = json['user_id']?.toString() ?? '';
    final rawMatrikNo = json['matrik_no']?.toString() ?? json['matric_no']?.toString() ?? '';
    final effectiveUserId = rawUserId.isNotEmpty ? rawUserId : rawMatrikNo;
    final effectiveMatrikNo = rawMatrikNo.isNotEmpty ? rawMatrikNo : rawUserId;

    return FeedbackItem(
      feedbackId: json['feedback_id']?.toString() ?? '',
      userId: effectiveUserId,
      matrikNo: effectiveMatrikNo,
      fullName: json['full_name']?.toString() ?? '',
      methodId: json['method_id']?.toString() ?? '',
      methodName: json['method_name']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feedback_id': feedbackId,
      'matrik_no': matrikNo,
      'user_id': userId,
      'full_name': fullName,
      'method_id': methodId,
      'method_name': methodName,
      'answer': answer,
      'description': description,
      'date': date,
      'time': time,
    };
  }
}