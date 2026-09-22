class MethodLink {
  final String linkId;
  final String methodId;
  final String linkUrl;
  final String linkName;

  MethodLink({
    required this.linkId,
    required this.methodId,
    required this.linkUrl,
    required this.linkName,
  });

  factory MethodLink.fromJson(Map<String, dynamic> json) {
    return MethodLink(
      linkId: json['link_id']?.toString() ?? '',
      methodId: json['method_id']?.toString() ?? '',
      linkUrl: json['link_url']?.toString() ?? '',
      linkName: json['link_name']?.toString() ?? '',
    );
  }
}