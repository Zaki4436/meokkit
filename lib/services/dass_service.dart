import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils/dass_calculator.dart';

/// Backend Service for DASS-21 API interactions and data persistence
class DassService {
  /// Save DASS test calculation result to the database for the current logged-in user.
  static Future<Map<String, dynamic>> saveResult(
    DassCalculationResult result,
  ) async {
    final user = await AuthService.getUser();
    if (user == null) {
      return {
        'success': false,
        'message': 'Pengguna tidak ditemui. Sila log masuk semula.',
      };
    }

    try {
      return await ApiService.saveDassTest(
        userId: user.userId,
        matrikNo: user.matrikNo,
        fullName: user.fullName,
        stress: result.stressLevel,
        anzieti: result.anxietyLevel,
        depression: result.depressionLevel,
      );
    } catch (e) {
      return {
        'success': false,
        'message': 'Ralat sambungan: $e',
      };
    }
  }

  /// Retrieve DASS test history for a user.
  static Future<Map<String, dynamic>> getHistory(
    String matrikNo, {
    String? userId,
  }) async {
    try {
      return await ApiService.getDassHistory(matrikNo, userId: userId);
    } catch (e) {
      return {
        'success': false,
        'message': 'Ralat sambungan: $e',
      };
    }
  }
}

