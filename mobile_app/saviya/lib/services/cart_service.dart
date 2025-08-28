import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class CartService with ChangeNotifier {
  static const String baseUrl = 'http://10.0.2.2:8080/api/cart';

  List<CartItem> _cartItems = [];
  bool _isLoading = false;

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get total => _cartItems.fold(0, (sum, item) => sum + item.subtotal);

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Fetch cart
  Future<void> fetchCart() async {
    _setLoading(true);
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception("No token found");

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Backend returns cart object with items array
        final items = data['items'] as List<dynamic>? ?? [];
        _cartItems = items.map((item) => CartItem.fromJson(item)).toList();
        notifyListeners();
} else {
        throw Exception('Failed to fetch cart: ${response.statusCode}');
      }
    } catch (e) {
      print('Fetch cart error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Add product
  Future<bool> addToCart(int productId, int quantity) async {
    _setLoading(true);
    try {
      final token = await AuthService.getToken();
      final userId = await AuthService.getUserId();
      if (token == null || userId == null)
        throw Exception("No token or userId");

      final response = await http.post(
        Uri.parse("$baseUrl/items"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "userId": userId,
          "productId": productId,
          "quantity": quantity,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchCart();
        return true;
      }
      return false;
    } catch (e) {
      print('Add to cart error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update cart item
  Future<bool> updateCartItem(int itemId, int quantity) async {
    _setLoading(true);
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception("No token found");

      final response = await http.put(
        Uri.parse("$baseUrl/items/$itemId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"quantity": quantity}),
      );

      if (response.statusCode == 200) {
        await fetchCart();
        return true;
      }
      return false;
    } catch (e) {
      print('Update cart item error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Remove item
  Future<bool> removeFromCart(int itemId) async {
    _setLoading(true);
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception("No token found");

      final response = await http.delete(
        Uri.parse("$baseUrl/items/$itemId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        await fetchCart();
        return true;
      }
      return false;
    } catch (e) {
      print('Remove cart item error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Clear cart
  Future<bool> clearCart() async {
    _setLoading(true);
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception("No token found");

      final response = await http.delete(
        Uri.parse("$baseUrl/clear"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        _cartItems.clear();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Clear cart error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}

/// Cart item model
class CartItem {
  final int id;
  final int productId;
  final int quantity;
  final double price;
  final String name;
  final String? imageUrl;

  CartItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.name,
    this.imageUrl,
  });

  double get subtotal => price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    double parsePrice(dynamic value) {
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    final productJson = json['product'] ?? {};
    return CartItem(
      id: json['id'] ?? json['cartItemId'] ?? 0,
      productId:
          json['productId'] ?? json['product_id'] ?? productJson['id'] ?? 0,
      quantity: json['quantity'] ?? 1,
      price: parsePrice(
        json['price'] ?? json['unitPrice'] ?? productJson['price'],
      ),
      name: json['name'] ?? productJson['productName'] ?? 'Unknown Product',
      imageUrl:
          json['imageUrl'] ?? productJson['image'] ?? productJson['image_url'],
    );
  }
}
