class OrderItem {
  final int id;
  final int productId;
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      productId: json['productId'],
      name:
          json['name'] ??
          json['productName'] ??
          'Product #${json['productId']}',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }
}
