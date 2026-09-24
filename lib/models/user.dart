class User {
  final String userId;
  final String fullName;
  final String role;
  final String username;
  final String profilePicture;

  User({
    required this.userId,
    required this.fullName,
    required this.role,
    required this.username,
    this.profilePicture = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      profilePicture: json['user_image']?.toString() ??
          json['profile_picture']?.toString() ??
          json['profile_image']?.toString() ??
          json['image_url']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'role': role,
      'username': username,
      'profile_picture': profilePicture,
      'user_image': profilePicture,
    };
  }

  User copyWith({
    String? userId,
    String? fullName,
    String? role,
    String? username,
    String? profilePicture,
  }) {
    return User(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      username: username ?? this.username,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }
}