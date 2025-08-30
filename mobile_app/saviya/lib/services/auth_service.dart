import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _userIdKey = 'user_id';
  static const String _tokenKey = 'auth_token';

  static Future<void> saveLoginData(Map<String, dynamic> response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, response['user']['userid']);
    await prefs.setString(_tokenKey, response['token']);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return null;
    }
    return token;
  }
}
