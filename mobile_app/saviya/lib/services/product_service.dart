import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class ProductService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/product';

  // Create product
  static Future<bool> addProduct(Map<String, dynamic> productData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(productData),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Failed to add product: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error in ProductService.addProduct: $e');
      return false;
    }
  }

  // Get all products of a user
  static Future<List<dynamic>> getUserProducts({int? userId}) async {
    try {
      final token = await AuthService.getToken();
      final url = userId != null
          ? "$baseUrl/user/$userId"
          : "$baseUrl/user"; // adjust according to backend
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      print("my products: ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data['products'];
      } else {
        throw Exception("Failed to load products: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error fetching products: $e");
    }
  }

  // Get all categories
  static Future<List<dynamic>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/categories'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['categories'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error in ProductService.getCategories: $e');
      return [];
    }
  }
}
