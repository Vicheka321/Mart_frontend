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
      appBar: AppBar(title: const Text("KHQR Payment")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              _KhqrCard(qrUrl: widget.qrUrl, amount: widget.amount),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Waiting for payment...",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Scan the KHQR code to complete your payment.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    timer?.cancel();

                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KhqrCard extends StatelessWidget {
  final String qrUrl;
  final String amount;

  const _KhqrCard({required this.qrUrl, required this.amount});

  @override
  Widget build(BuildContext context) {
    const khqrRed = Color(0xFFE1232E);
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  height: 56,
                  color: khqrRed,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _KhqrMark(),
                      const SizedBox(width: 10),
                      Text(
                        "KHQR",
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Mart",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF111827),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "USD $amount",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: const Color(0xFF111827),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: _DashedDivider(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      qrUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;

                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.qr_code_2,
                            size: 104,
                            color: Color(0xFF6B7280),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KhqrMark extends StatelessWidget {
  const _KhqrMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Positioned(left: 4, top: 4, child: _markSquare()),
          Positioned(right: 4, top: 4, child: _markSquare()),
          Positioned(left: 4, bottom: 4, child: _markSquare()),
          Positioned(
            right: 5,
            bottom: 5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFE1232E),
                borderRadius: BorderRadius.circular(1.5),
              ),
              child: const SizedBox(width: 5, height: 5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _markSquare() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFE1232E),
        borderRadius: BorderRadius.circular(2),
      ),
      child: const SizedBox(width: 8, height: 8),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedDividerPainter(),
      child: const SizedBox(height: 1, width: double.infinity),
    );
  }
}

class _DashedDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 7.0;
    const dashGap = 5.0;
    final paint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 1;

    var startX = 0.0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
