class InformationModel {
  final String infoId;
  final String infoName;
  final String infoDescription;

  InformationModel({
    required this.infoId,
    required this.infoName,
    required this.infoDescription,
  });

  factory InformationModel.fromJson(Map<String, dynamic> json) {
    return InformationModel(
      infoId: json['info_id']?.toString() ??
          json['id']?.toString() ??
          '',
      infoName: json['info_name']?.toString() ??
          json['name']?.toString() ??
          json['title']?.toString() ??
          '',
      infoDescription: json['info_description']?.toString() ??
          json['description']?.toString() ??
          json['content']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'info_id': infoId,
      'info_name': infoName,
      'info_description': infoDescription,
    };
  }
}

