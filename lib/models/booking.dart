class Booking {
  final String bookingId;
  final String userId;
  final String matrikNo;
  final String email;
  final String fullName;
  final String noIc;
  final String gender;
  final String race;
  final String aliran;
  final String praktikum;
  final String noPhone;
  final String jenisPerkhidmatan;
  final String isu;
  final String tarikh;
  final String masa;

  Booking({
    required this.bookingId,
    this.userId = '',
    required this.matrikNo,
    required this.email,
    required this.fullName,
    required this.noIc,
    this.gender = '',
    this.race = '',
    this.aliran = '',
    required this.praktikum,
    required this.noPhone,
    this.jenisPerkhidmatan = '',
    this.isu = '',
    this.tarikh = '',
    this.masa = '',
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final rawUserId = json['user_id']?.toString() ?? '';
    final rawMatrikNo = json['matrik_no']?.toString() ?? json['matric_no']?.toString() ?? '';
    return Booking(
      bookingId: json['booking_id']?.toString() ?? '',
      userId: rawUserId,
      matrikNo: rawMatrikNo.isNotEmpty ? rawMatrikNo : rawUserId,
      email: json['email']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      noIc: json['no_ic']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      race: json['race']?.toString() ?? '',
      aliran: json['aliran']?.toString() ?? '',
      praktikum: json['praktikum']?.toString() ?? '',
      noPhone: json['no_phone']?.toString() ?? '',
      jenisPerkhidmatan: json['jenis_perkhidmatan']?.toString() ?? '',
      isu: json['isu']?.toString() ?? '',
      tarikh: json['tarikh']?.toString() ?? '',
      masa: json['masa']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'user_id': userId,
      'matrik_no': matrikNo,
      'email': email,
      'full_name': fullName,
      'no_ic': noIc,
      'gender': gender,
      'race': race,
      'aliran': aliran,
      'praktikum': praktikum,
      'no_phone': noPhone,
      'jenis_perkhidmatan': jenisPerkhidmatan,
      'isu': isu,
      'tarikh': tarikh,
      'masa': masa,
    };
  }
}

