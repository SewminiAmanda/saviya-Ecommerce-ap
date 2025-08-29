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
    const mainColor = Color(0xFFF39C12);

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
                  return Center(
                    child: Text(
                      "cart_empty".tr(),
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: cartService.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartService.cartItems[index];
                    return Card(
                      elevation: 3,
                      shadowColor: mainColor.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Rs. ${item.price.toStringAsFixed(2)} / unit",
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: mainColor.withOpacity(0.1),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    color: mainColor,
                                    onPressed: () {
                                      if (item.quantity > 1) {
                                        cartService.updateCartItem(
                                          item.id,
                                          item.quantity - 1,
                                        );
                                      }
                                    },
                                  ),
                                  Text(
                                    item.quantity.toString(),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    color: mainColor,
                                    onPressed: () {
                                      cartService.updateCartItem(
                                        item.id,
                                        item.quantity + 1,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.redAccent,
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.1),
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 5),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white, // fill white
                      side: const BorderSide(
                        color: mainColor,
                        width: 2,
                      ), // orange border
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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

                            if (!mounted) return;

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
                              color: mainColor, // progress color orange
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "place_order".tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              color: mainColor, // text color orange
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
