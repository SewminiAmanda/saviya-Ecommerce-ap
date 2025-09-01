import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';
import '../model/review_model.dart';

final supabase = Supabase.instance.client;

class ProductService {
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  /// Upload image to Supabase and get public URL
  static Future<String> uploadImage(File file) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      print('[DEBUG] Uploading file: ${file.path}');
      print('[DEBUG] Generated file name: $fileName');

      final res = await supabase.storage
          .from('products')
          .upload(fileName, file);
      print('[DEBUG] Supabase upload response: $res');

      if (res.isEmpty) {
        print('[ERROR] Upload response is empty!');
        throw Exception('Upload failed');
      }

      final publicUrl = supabase.storage
          .from('products')
          .getPublicUrl(fileName);
      print('[DEBUG] Public URL: $publicUrl');

      return publicUrl;
    } catch (e, stackTrace) {
      print('[ERROR] Failed to upload image: $e');
      print(stackTrace);
      rethrow;
    }
  }

  /// Add a product to backend
  static Future<bool> addProduct(Map<String, dynamic> productData) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/product/create'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
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
          ? "$baseUrl/product/user/$userId"
          : "$baseUrl/product/user"; // adjust according to backend
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

  static Future<void> addReview({
    required int productId,
    required int rating,
    required String comment,
  }) async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse("$baseUrl/reviews"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "productId": productId,
        "rating": rating,
        "comment": comment,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to submit review: ${response.body}");
    }
  }

  Future<List<Review>> getReviews(int productId) async {
    final response = await http.get(Uri.parse('$baseUrl/reviews/$productId'));
    debugPrint("reviews ${response.body}");
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Review.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reviews');
    }
  }
}
