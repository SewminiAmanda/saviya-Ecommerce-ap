/// Cart Item model
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

    return CartItem(
      id: json['id'] ?? json['cartItemId'] ?? 0,
      productId: json['productId'] ?? json['product_id'] ?? 0,
      quantity: json['quantity'] ?? 1,
      price: parsePrice(json['price'] ?? json['unitPrice']),
      name:
          json['name'] ??
          json['productName'] ??
          json['product']?['productName'] ??
          'Unknown Product',
      imageUrl:
          json['imageUrl'] ??
          json['image_url'] ??
          json['product']?['image'] ??
          json['productImage'],
    );
  }
}
