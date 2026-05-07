import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../checkoput/checkout_screen.dart';
import '../../providers/cart_provider.dart';

class CartBottomSheet extends StatefulWidget {
  const CartBottomSheet({super.key});

  @override
  State<CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends State<CartBottomSheet> {
  final Set<int> selectedItems = {};

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>().cart;

    if (cart == null || cart.items.isEmpty) {
      return const SizedBox();
    }

    final allSelected = selectedItems.length == cart.items.length;

    // double total = 0;
    // for (var item in cart.items) {
    //   if (selectedItems.contains(item.productId)) {
    //     total += item.product.finalPrice * item.qty;
    //   }
    // }

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),

              /// Drag indicator
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 16),

              /// SELECT ALL
              ListTile(
                leading: Checkbox(
                  value: allSelected,
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        selectedItems.addAll(
                          cart.items.map((e) => e.productId),
                        );
                      } else {
                        selectedItems.clear();
                      }
                    });
                  },
                ),
                title: const Text("Select All"),
              ),

              /// LIST
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: cart.items.length,
                  itemBuilder: (_, i) {
                    final item = cart.items[i];
                    final selected = selectedItems.contains(item.productId);

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? Colors.orange
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: selected,
                            onChanged: (_) {
                              setState(() {
                                if (selected) {
                                  selectedItems.remove(item.productId);
                                } else {
                                  selectedItems.add(item.productId);
                                }
                              });
                            },
                          ),

                          /// IMAGE
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.images.first,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(width: 10),

                          /// NAME + PRICE
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "\$${item.price}",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),

                          /// QTY
                          Text("x${item.qty}"),
                        ],
                      ),
                    );
                  },
                ),
              ),

              /// TOTAL + BUTTON
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Total: \$test",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: selectedItems.isEmpty
                          ? null
                          : () {
                              Navigator.pop(context); // close bottom sheet

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CheckoutScreen(),
                                ),
                              );
                            },
                      child: const Text("Checkout"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
