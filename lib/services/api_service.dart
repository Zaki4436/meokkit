import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://script.google.com/macros/s/AKfycbzlxa9X_Wv9CQWfKUiSVlSJRFFy2QoJVPTvSyw88ip_eZP9maxpb3hyycnEimcx5iTq9w/exec';

  // =========================
  // POST REQUEST
  // =========================

  static Future<Map<String, dynamic>> post(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message':
              'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
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

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message':
              'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
}