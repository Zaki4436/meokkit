import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_messages.dart';

class ApiService {
  static const String baseUrl =
      'https://script.google.com/macros/s/AKfycbyz6OD3gjN7D8tEKTwJzGssuPopRk48fXbeXXsOzQ-fcTPyDB-piD_7s6F8M9MPAohJoA/exec';

  // =========================
  // POST REQUEST
  // =========================

  static Future<Map<String, dynamic>> post(
    Map<String, dynamic> data,
  ) async {
    try {
      var response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'text/plain;charset=utf-8',
        },
        body: jsonEncode(data),
      );

      // Google Apps Script redirects responses with 302 to an echo URL
      int redirectCount = 0;
      while ((response.statusCode >= 301 && response.statusCode <= 308) &&
          response.headers.containsKey('location') &&
          redirectCount < 5) {
        final redirectUrl = response.headers['location']!;
        response = await http.get(Uri.parse(redirectUrl));
        redirectCount++;
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          if (decoded['success'] != true) {
            final error = decoded['error'];
            if (decoded['message'] == null ||
                decoded['message'].toString().isEmpty) {
              decoded['message'] = AppMessages.getErrorMessage(error);
            }
          }
          return decoded;
        }
        return {
          'success': false,
          'error': 'SERVER_ERROR',
          'message': AppMessages.getErrorMessage('SERVER_ERROR'),
        };
      } else {
        return {
          'success': false,
          'error': 'SERVER_ERROR',
          'message': AppMessages.getErrorMessage('SERVER_ERROR'),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'CONNECTION_ERROR',
        'message': AppMessages.getErrorMessage('CONNECTION_ERROR'),
      };
    }
  }

  // =========================
  // GET REQUEST
  // =========================

  static Future<Map<String, dynamic>> get(
    String action, {
    Map<String, String>? params,
  }) async {
    try {
      final queryParameters = {
        'action': action,
        ...?params,
      };

      final uri = Uri.parse(baseUrl).replace(
        queryParameters: queryParameters,
      );

      var response = await http.get(uri);

      // Google Apps Script redirects responses with 302 to an echo URL
      int redirectCount = 0;
      while ((response.statusCode >= 301 && response.statusCode <= 308) &&
          response.headers.containsKey('location') &&
          redirectCount < 5) {
        final redirectUrl = response.headers['location']!;
        response = await http.get(Uri.parse(redirectUrl));
        redirectCount++;
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          if (decoded['success'] != true) {
            final error = decoded['error'];
            if (decoded['message'] == null ||
                decoded['message'].toString().isEmpty) {
              decoded['message'] = AppMessages.getErrorMessage(error);
            }
          }
          return decoded;
        }
        return {
          'success': false,
          'error': 'SERVER_ERROR',
          'message': AppMessages.getErrorMessage('SERVER_ERROR'),
        };
      } else {
        return {
          'success': false,
          'error': 'SERVER_ERROR',
          'message': AppMessages.getErrorMessage('SERVER_ERROR'),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'CONNECTION_ERROR',
        'message': AppMessages.getErrorMessage('CONNECTION_ERROR'),
      };
    }
  }

  // =========================
  // BOOKING HELPERS
  // =========================

  static Future<Map<String, dynamic>> saveBooking({
    String? userId,
    required String matrikNo,
    required String email,
    required String noIc,
    required String praktikum,
    required String noPhone,
    String? fullName,
    String? gender,
    String? race,
    String? aliran,
    String? jenisPerkhidmatan,
    String? isu,
    String? tarikh,
    String? masa,
  }) async {
    return await post({
      'action': 'saveBooking',
      'user_id': userId ?? matrikNo,
      'matrik_no': matrikNo,
      'email': email,
      'full_name': fullName ?? '',
      'no_ic': noIc,
      'gender': gender ?? '',
      'race': race ?? '',
      'aliran': aliran ?? '',
      'praktikum': praktikum,
      'no_phone': noPhone,
      'jenis_perkhidmatan': jenisPerkhidmatan ?? '',
      'isu': isu ?? '',
      'tarikh': tarikh ?? '',
      'masa': masa ?? '',
    });
  }

  static Future<Map<String, dynamic>> getBookings(String matrikNo, {String? userId}) async {
    return await get('getBooking', params: {
      'user_id': userId ?? matrikNo,
      'matrik_no': matrikNo,
    });
  }

  // =========================
  // DASS TEST HELPERS
  // =========================

  static Future<Map<String, dynamic>> saveDassTest({
    String? userId,
    required String matrikNo,
    required String stress,
    required String anzieti,
    required String depression,
    String? fullName,
  }) async {
    return await post({
      'action': 'saveDassTest',
      'user_id': userId ?? matrikNo,
      'matrik_no': matrikNo,
      'full_name': fullName ?? '',
      'stress': stress,
      'anzieti': anzieti,
      'anxiety': anzieti,
      'depression': depression,
    });
  }

  static Future<Map<String, dynamic>> getDassHistory(String matrikNo, {String? userId}) async {
    return await get('getDassTest', params: {
      'user_id': userId ?? matrikNo,
      'matrik_no': matrikNo,
    });
  }
}