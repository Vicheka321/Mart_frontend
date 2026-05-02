import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class FloatingCartBar extends StatelessWidget {
  const FloatingCartBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final s = MediaQuery.of(context).size.shortestSide;

    if (cart.cart == null || cart.cart!.items.isEmpty) {
      return const SizedBox();
    }

    final itemCount = cart.itemCount;
    final total = cart.cart!.totalPrice;

    return Positioned(
      bottom: s * 0.04,
      left: s * 0.04,
      right: s * 0.04,
      child: GestureDetector(
        onTap: () {
          // 👉 next step: open bottom sheet
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: s * 0.04,
            vertical: s * 0.03,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFEDEDED),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // 🛒 ICON
              Container(
                padding: EdgeInsets.all(s * 0.025),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.orange,
                  size: s * 0.06,
                ),
              ),

              SizedBox(width: s * 0.03),

              // 📝 TEXT
              Expanded(
                child: Text(
                  "View Cart ($itemCount items)",
                  style: TextStyle(
                    fontSize: s * 0.04,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),

              // 💲 TOTAL PRICE
              Text(
                "\$${total.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: s * 0.045,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
