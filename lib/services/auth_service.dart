import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String userKey = 'loggedInUser';

  // Save user session
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      userKey,
      jsonEncode(user.toJson()),
    );
  }

  // Get logged-in user
  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    final userData = prefs.getString(userKey);

    if (userData == null) {
      return null;
    }

    try {
      final json = jsonDecode(userData);

      return User.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  // Check login
  static Future<bool> isLoggedIn() async {
    final user = await getUser();

    return user != null;
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(userKey);
  }
}