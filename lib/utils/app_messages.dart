class AppMessages {
  // ==========================================
  // ERROR CODES TO USER-FRIENDLY BM MESSAGES
  // ==========================================
  static String getErrorMessage(
    dynamic error, {
    String defaultMessage = 'Operasi tidak berjaya. Sila cuba lagi.',
  }) {
    if (error == null) return defaultMessage;
    final code = error.toString().trim();

    switch (code) {
      // Login & Auth
      case 'INVALID_CREDENTIALS':
        return 'No. Matrik atau kata laluan tidak sah.';
      case 'MATRIK_REQUIRED':
        return 'Sila masukkan No. Matrik anda.';
      case 'REQUIRED_FIELDS':
        return 'Sila lengkapkan semua maklumat yang diperlukan.';

      // Register & Edit Profile
      case 'MATRIK_EXISTS':
        return 'No. Matrik ini telah digunakan oleh pengguna lain.';

      // Forgot Password
      case 'SAME_PASSWORD':
        return 'Kata laluan baharu tidak boleh sama dengan kata laluan semasa.';
      case 'USER_NOT_MATCH':
        return 'Nama penuh dan No. Matrik tidak sepadan.';

      // Profile & Account
      case 'USER_NOT_FOUND':
        return 'Pengguna tidak ditemui dalam sistem.';
      case 'INCOMPLETE_DATA':
        return 'Maklumat yang dimasukkan tidak lengkap.';
      case 'IMAGE_REQUIRED':
        return 'Sila pilih gambar terlebih dahulu.';
      case 'INVALID_FILE_TYPE':
        return 'Hanya fail gambar sahaja yang dibenarkan.';
      case 'UPLOAD_FAILED':
        return 'Gagal memuat naik gambar profil. Sila cuba lagi.';
      case 'DELETE_FAILED':
        return 'Gagal memadam akaun. Sila cuba lagi.';

      // Server & Network
      case 'SERVER_ERROR':
        return 'Ralat pada pelayan. Sila cuba sebentar lagi.';
      case 'CONNECTION_ERROR':
        return 'Ralat sambungan rangkaian. Sila pastikan anda mempunyai capaian internet.';
      case 'NO_ACTION':
      case 'UNKNOWN_ACTION':
        return 'Tindakan sistem tidak sah.';

      default:
        return defaultMessage;
    }
  }

  // ==========================================
  // SUCCESS MESSAGES
  // ==========================================
  static const String registerSuccess =
      'Akaun anda telah berjaya didaftarkan. Sila log masuk untuk meneruskan.';
  static const String loginSuccess = 'Log masuk berjaya.';
  static const String passwordResetSuccess =
      'Kata laluan anda telah berjaya ditetapkan semula. Sila log masuk dengan kata laluan baharu.';
  static const String profileUpdatedSuccess = 'Profil berjaya dikemaskini.';
  static const String profileImageSuccess = 'Gambar profil berjaya dikemaskini.';
  static const String feedbackSuccess =
      'Maklum balas anda telah berjaya dihantar! Terima kasih.';
  static const String bookingSuccess =
      'Tempahan sesi kaunseling telah berjaya dihantar.';
  static const String dassSuccess = 'Keputusan ujian DASS berjaya disimpan.';
  static const String accountDeletedSuccess = 'Akaun anda telah berjaya dipadam.';
}

