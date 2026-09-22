class User {
  final String userId;
  final String fullName;
  final String role;
  final String username;

  User({
    required this.userId,
    required this.fullName,
    required this.role,
    required this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'role': role,
      'username': username,
    };
  }
}