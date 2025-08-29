import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'cart_service.dart';

class OrderService with ChangeNotifier {
  static const String baseUrl = 'http://10.0.2.2:8080/api/orders';
  bool _isPlacing = false;

  bool get isPlacing => _isPlacing;

  // Return the created order instead of bool
  Future<Map<String, dynamic>?> placeOrder(List<CartItem> items) async {
    _isPlacing = true;
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      final userId = await AuthService.getUserId();
      if (token == null || userId == null) throw Exception("No token/userId");

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "userId": userId,
          "items": items
              .map(
                (item) => {
                  "productId": item.productId,
                  "quantity": item.quantity,
                  "price": item.price,
                },
              )
              .toList(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final orderData = jsonDecode(response.body);
        debugPrint('order body: ${response.body}');
        return orderData['order']; 
      }

      debugPrint("Place order failed: ${response.body}");
      return null;
    } catch (e) {
      debugPrint("Place order error: $e");
      return null;
    } finally {
      _isPlacing = false;
      notifyListeners();
    }
  }
}
