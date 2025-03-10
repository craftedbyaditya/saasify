import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _keyEmail = 'email';
  static const String _keyPassword = 'password';
  static const String _keyIsLoggedIn = 'is_logged_in';

  // Save Login Details
  Future<void> saveLoginDetails({required String email, required String password}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPassword, password); // Consider encrypting passwords in production
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  // Get Login Details
  Future<Map<String, String>?> getLoginDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_keyEmail);
    final password = prefs.getString(_keyPassword);

    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  // Check if User is Logged In
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Clear Login Details
  Future<void> clearLoginDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPassword);
    await prefs.setBool(_keyIsLoggedIn, false);
  }
}