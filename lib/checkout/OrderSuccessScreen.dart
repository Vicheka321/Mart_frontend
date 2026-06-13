import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mart_frontend/providers/cart_provider.dart';
import 'package:mart_frontend/screens/main/main_screen.dart';
import 'package:provider/provider.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  @override
  void initState() {
    super.initState();

    /// ✅ AUTO GO HOME AFTER 5 SECONDS
    Timer(const Duration(seconds: 5), () {
      if (!mounted) return;

      Navigator.popUntil(context, (route) => route.isFirst);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 120),

            const SizedBox(height: 20),

            const Text(
              "Order Successful",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text("Your order has been placed"),

            const SizedBox(height: 10),

            const Text(
              "Redirecting to home in 5 seconds...",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () async {
                // Navigator.popUntil(
                //   context,
                //   (route) => route.isFirst,
                // );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => MainScreen()),
                );
                await context.read<CartProvider>().fetchCart();
              },

              child: const Text("Back Home"),
            ),
          ],
        ),
      ),
    );
  }
}
