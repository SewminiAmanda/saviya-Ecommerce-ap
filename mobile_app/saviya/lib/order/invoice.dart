// pages/invoice_page.dart
import 'package:flutter/material.dart';
import '../model/order_item.dart';

class InvoicePage extends StatelessWidget {
  final Map<String, dynamic> order;

  const InvoicePage({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = ((order['items'] as List<dynamic>?) ?? [])
        .map((e) => OrderItem.fromJson(e))
        .toList();

    final total = items.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Invoice")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Order ID: ${order['orderId'] ?? order['id']}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text("No items in this order"))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ListTile(
                          title: Text(item.name),
                          subtitle: Text(
                            "Qty: ${item.quantity} • Rs.${item.price.toStringAsFixed(2)}",
                          ),
                          trailing: Text(
                            "Rs.${(item.quantity * item.price).toStringAsFixed(2)}",
                          ),
                        );
                      },
                    ),
            ),
            const Divider(),
            Text(
              "Total: Rs.${total.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }
}
