import 'dart:async';

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'OrderSuccessScreen.dart';


class KhqrScreen extends StatefulWidget {

  final String qrUrl;
  final String amount;

  /// ✅ MD5 FOR CHECK PAYMENT
  final String md5;

  const KhqrScreen({
    super.key,
    required this.qrUrl,
    required this.amount,
    required this.md5,
  });

  @override
  State<KhqrScreen> createState() =>
      _KhqrScreenState();
}

class _KhqrScreenState
    extends State<KhqrScreen> {

  bool loading = false;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    /// ✅ AUTO CHECK EVERY 1 SECOND
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => checkPayment(),
    );
  }

  @override
  void dispose() {

    /// ✅ STOP TIMER
    timer?.cancel();

    super.dispose();
  }

  /// ✅ CHECK PAYMENT
  Future<void> checkPayment() async {

    if (loading) return;

    try {

      loading = true;

      final res =
          await ApiService().checkPayment(
        widget.md5,
      );

      loading = false;

      /// ✅ SUCCESS
      if (res["success"] == true &&
          res["status"] == "SUCCESS") {

        /// ✅ STOP CHECKING
        timer?.cancel();

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const OrderSuccessScreen(),
          ),
        );
      }

    } catch (e) {

      loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "KHQR Payment",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const SizedBox(height: 20),

            /// ✅ AMOUNT
            Text(
              "\$${widget.amount}",
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            /// ✅ QR IMAGE
            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),

                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: Image.network(
                widget.qrUrl,
                width: 250,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Waiting for payment...",
              style: TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 20),

            const CircularProgressIndicator(),

            const Spacer(),

            TextButton(
              onPressed: () {

                timer?.cancel();

                Navigator.pop(context);
              },

              child: const Text(
                "Cancel",
              ),
            ),
          ],
        ),
      ),
    );
  }
}