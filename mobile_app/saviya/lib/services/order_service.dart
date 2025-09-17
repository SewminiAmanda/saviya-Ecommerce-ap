import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'cart_service.dart';

class OrderService with ChangeNotifier {
  static const String baseUrl = 'http://10.0.2.2:8080/api/orders';
  bool _isPlacing = false;

  bool get isPlacing => _isPlacing;

  
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
  } // Fetch buyer orders

  Future<List<Map<String, dynamic>>> getBuyerOrders() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception("No token");

      final response = await http.get(
        Uri.parse("$baseUrl/buyer"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> ordersList = jsonDecode(response.body);

        
        return ordersList.map<Map<String, dynamic>>((order) {
          return {
            "orderId": order['orderId'],
            "userId": order['userId'],
            "sellerId": order['sellerId'],
            "status": order['status'],
            "paymentStatus": order['paymentStatus'],
            "totalAmount": order['totalAmount'],
            "buyer": order['buyer'],
            "seller": order['seller'],
            "items": List<Map<String, dynamic>>.from(order['items']),
          };
        }).toList();
      }

      debugPrint("getBuyerOrders failed: ${response.body}");
      return [];
    } catch (e) {
      debugPrint("getBuyerOrders error: $e");
      return [];
    }
  }

  // Fetch seller/received orders in structured format
  Future<List<Map<String, dynamic>>> getReceivedOrders() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception("No token");

      final response = await http.get(
        Uri.parse("$baseUrl/seller"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> ordersList = jsonDecode(response.body);

        return ordersList.map<Map<String, dynamic>>((order) {
          return {
            "orderId": order['orderId'],
            "userId": order['userId'], // buyer id
            "sellerId": order['sellerId'],
            "status": order['status'],
            "paymentStatus": order['paymentStatus'],
            "totalAmount": order['totalAmount'],
            "buyer": order['buyer'],
            "seller": order['seller'],
            "items": List<Map<String, dynamic>>.from(order['items']),
          };
        }).toList();
      }

      debugPrint("getReceivedOrders failed: ${response.body}");
      return [];
    } catch (e) {
      debugPrint("getReceivedOrders error: $e");
      return [];
    }
  }

  Future<bool> updateOrderStatus(int orderId, String status) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/$orderId/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': status}),
      );

      debugPrint(
        'Update status response: ${response.statusCode} ${response.body}',
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('updateOrderStatus error: $e');
      return false;
    }
  }


}
