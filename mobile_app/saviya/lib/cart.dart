import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import 'components/header.dart';
import '../order/invoice.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartService>(context, listen: false).fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomHeader(),
          Expanded(
            child: Consumer<CartService>(
              builder: (context, cartService, child) {
                if (cartService.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (cartService.cartItems.isEmpty) {
                  return Center(child: Text("cart_empty".tr()));
                }

                return ListView.builder(
                  itemCount: cartService.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartService.cartItems[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(item.name), // variable, don't translate
                        subtitle: Text(
                          '${'qty_price'.tr()}: ${item.quantity} | Rs. ${item.price.toStringAsFixed(2)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                if (item.quantity > 1) {
                                  cartService.updateCartItem(
                                    item.id,
                                    item.quantity - 1,
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                cartService.updateCartItem(
                                  item.id,
                                  item.quantity + 1,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                cartService.removeFromCart(item.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Checkout section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: const Border(top: BorderSide(color: Colors.black12)),
            ),
            child: Consumer2<CartService, OrderService>(
              builder: (context, cartService, orderService, child) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "total_price".tr(
                      args: [cartService.total.toStringAsFixed(2)],
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: orderService.isPlacing
                        ? null
                        : () async {
                            if (cartService.cartItems.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("cart_empty".tr())),
                              );
                              return;
                            }

                            final orderData = await orderService.placeOrder(
                              cartService.cartItems,
                            );

                            if (!mounted)
                              return; // ✅ prevent async context issues

                            if (orderData != null) {
                              cartService.clearCart();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => InvoicePage(order: orderData),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("order_failed".tr())),
                              );
                            }
                          },
                    child: orderService.isPlacing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text("place_order".tr()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
