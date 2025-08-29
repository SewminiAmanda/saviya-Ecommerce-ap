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
    String productName = '';

    if (json['name'] != null) {
      productName = json['name'];
    } else if (json['product'] != null &&
        json['product']['productName'] != null) {
      productName = json['product']['productName'];
    } else {
      productName = 'Product #${json['productId']}';
    }

    return OrderItem(
      id: json['id'] ?? json['orderItemId'] ?? 0,
      productId: json['productId'],
      name: productName,
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }


}
