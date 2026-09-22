class Method {
  final String methodId;
  final String methodName;
  final String description;

  Method({
    required this.methodId,
    required this.methodName,
    required this.description,
  });

  factory Method.fromJson(Map<String, dynamic> json) {
    return Method(
      methodId: json['method_id']?.toString() ?? '',
      methodName: json['method_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}