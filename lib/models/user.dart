class User {
  final String userId;
  final String matrikNo;
  final String fullName;
  final String username;
  final String profilePicture;

  User({
    required this.userId,
    String? matrikNo,
    required this.fullName,
    String? username,
    this.profilePicture = '',
  })  : matrikNo = (matrikNo != null && matrikNo.isNotEmpty) ? matrikNo : userId,
        username = (username != null && username.isNotEmpty)
            ? username
            : ((matrikNo != null && matrikNo.isNotEmpty) ? matrikNo : userId);

  factory User.fromJson(Map<String, dynamic> json) {
    final rawUserId = json['user_id']?.toString() ?? '';
    final rawMatrikNo = json['matrik_no']?.toString() ?? '';
    final effectiveUserId = rawUserId.isNotEmpty ? rawUserId : rawMatrikNo;
    final effectiveMatrikNo = rawMatrikNo.isNotEmpty ? rawMatrikNo : rawUserId;

    return User(
      userId: effectiveUserId,
      matrikNo: effectiveMatrikNo,
      fullName: json['full_name']?.toString() ?? '',
      username: json['username']?.toString() ?? effectiveMatrikNo,
      profilePicture: json['user_image']?.toString() ??
          json['profile_picture']?.toString() ??
          json['profile_image']?.toString() ??
          json['image_url']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matrik_no': matrikNo,
      'user_id': userId,
      'full_name': fullName,
      'username': username,
      'profile_picture': profilePicture,
      'user_image': profilePicture,
    };
  }

  User copyWith({
    String? userId,
    String? matrikNo,
    String? fullName,
    String? username,
    String? profilePicture,
  }) {
    final newId = userId ?? matrikNo ?? this.userId;
    return User(
      userId: newId,
      matrikNo: matrikNo ?? userId ?? this.matrikNo,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }
}