import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class UserService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/users';

  /// Update shipping address
  static Future<bool> updateShippingAddress(int userId, String address) async {
    try {
      final token = await AuthService.getToken();
      print("Token: $token");
      if (token == null) {
        print("Token is null, cannot proceed");
        return false;
      }

      final url = '$baseUrl/change-address';
      print("PUT URL: $url");
      print("Body: ${jsonEncode({"address": address})}");

      final response = await http.put(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"address": address}),
      );

      

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("Update address error: $e");
      return false;
    }
  }

}
