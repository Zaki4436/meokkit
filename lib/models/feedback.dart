class FeedbackItem {
  final String feedbackId;
  final String userId;
  final String fullName;
  final String methodId;
  final String methodName;
  final String answer;
  final String date;
  final String time;

  FeedbackItem({
    required this.feedbackId,
    required this.userId,
    this.fullName = '',
    this.methodId = '',
    this.methodName = '',
    required this.answer,
    required this.date,
    required this.time,
  });

  factory FeedbackItem.fromJson(Map<String, dynamic> json) {
    return FeedbackItem(
      feedbackId: json['feedback_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      methodId: json['method_id']?.toString() ?? '',
      methodName: json['method_name']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
    );
  }
}