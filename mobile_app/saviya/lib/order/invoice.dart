import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/order_item.dart';

class InvoicePage extends StatelessWidget {
  final Map<String, dynamic> order;

  const InvoicePage({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items =
        ((order['items'] ?? order['OrderItems']) as List<dynamic>?)
            ?.map((e) => OrderItem.fromJson(e))
            .toList() ??
        [];

    final total = items.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    final orderDate = order['createdAt'] != null
        ? DateFormat(
            'yyyy-MM-dd – kk:mm',
          ).format(DateTime.parse(order['createdAt']))
        : 'Unknown';

    final buyer = order['buyer'];
    final seller = order['seller'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Invoice"),
        backgroundColor: Colors.deepOrange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Order Header ---
            Card(
              color: Colors.deepOrange.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order ID: ${order['orderId'] ?? order['id']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text("Date: $orderDate"),
                    const SizedBox(height: 4),
                    Text("Status: ${order['status'] ?? 'Pending'}"),
                  ],
                ),
              ),
            ),

           
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (buyer != null)
                  Expanded(
                    child: Card(
                      margin: const EdgeInsets.only(right: 8, bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Buyer Details",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Divider(),
                            Text(
                              "Name: ${buyer['first_name'] ?? ''} ${buyer['last_name'] ?? ''}",
                            ),
                            Text("Address: ${buyer['address'] ?? ''}"),
                            Text("Email: ${buyer['email'] ?? ''}"),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (seller != null)
                  Expanded(
                    child: Card(
                      margin: const EdgeInsets.only(left: 8, bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Seller Details",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Divider(),
                            Text(
                              "Name: ${seller['first_name'] ?? ''} ${seller['last_name'] ?? ''}",
                            ),
                            Text("Email: ${seller['email'] ?? ''}"),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Order Items",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Divider(),
                    DataTable(
                      columnSpacing: 12,
                      headingRowColor: MaterialStateProperty.all(
                        Colors.deepOrange.shade50,
                      ),
                      columns: const [
                        DataColumn(label: Text('Product')),
                        DataColumn(label: Text('Qty')),
                        DataColumn(label: Text('Price')),
                        DataColumn(label: Text('Total')),
                      ],
                      rows: items
                          .map(
                            (item) => DataRow(
                              cells: [
                                DataCell(Text(item.name)),
                                DataCell(Text(item.quantity.toString())),
                                DataCell(
                                  Text("Rs.${item.price.toStringAsFixed(2)}"),
                                ),
                                DataCell(
                                  Text(
                                    "Rs.${(item.price * item.quantity).toStringAsFixed(2)}",
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),

           
            Card(
              color: Colors.deepOrange.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Total: Rs.${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
