import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://script.google.com/macros/s/AKfycbxVcqxQgGhjucuTdLgYtsLOnGgzdOV_GPHkFk8Mu4YIU_5j2LDvfOVjFgZSa16rnF1pcg/exec';

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
          'Content-Type': 'application/json',
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