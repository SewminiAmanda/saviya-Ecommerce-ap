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
  static Future<List<dynamic>> getUserProducts() async {
    print("it hits here 1");

    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse("$baseUrl/user"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("product, ${response.body}");
      print("$token");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['products'] != null) {
          print(data['products']);
          return data['products'];
        }
      }
      return [];
    } catch (e) {
      print('Error in ProductService.getUserProducts: $e');
      return [];
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
