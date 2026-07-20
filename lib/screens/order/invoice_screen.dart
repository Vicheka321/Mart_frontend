import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mart_frontend/providers/cart_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import 'package:mart_frontend/models/order_detail_model.dart';
import 'package:mart_frontend/services/api_service.dart';
import 'package:mart_frontend/screens/theme/app_theme.dart';
import 'package:mart_frontend/screens/main/main_screen.dart';

// ════════════════════════════════════════════════════════════════
// INVOICE ACCENT PALETTE (fixed, independent of app theme)
// ════════════════════════════════════════════════════════════════

class _S {
  static const ink = Color(0xFF111827); // near-black text
  static const line = Color(0xFFE5E7EB); // rule lines
  static const paper = Color(0xFFFFFFFF); // document background
  static const muted = Color(0xFF6B7280); // secondary text
  static const green = Color(0xFF16A34A);
  static const greenBg = Color(0xFFF0FDF4);
  static const amber = Color(0xFFB45309);
  static const amberBg = Color(0xFFFFFBEB);
  static const red = Color(0xFFB91C1C);
  static const redBg = Color(0xFFFEF2F2);
}

// ════════════════════════════════════════════════════════════════
// FORMATTING HELPERS
// ════════════════════════════════════════════════════════════════

String _formatDate(String raw) {
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  final local = parsed.toLocal();
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour >= 12 ? 'PM' : 'AM';
  return '${months[local.month - 1]} ${local.day}, ${local.year} · $hour12:$minute $period';
}

String _paymentMethodLabel(String method) {
  switch (method.toLowerCase()) {
    case 'khqr':
      return 'KHQR';
    case 'aba':
      return 'ABA Pay';
    case 'cash':
    case 'cod':
      return 'Cash on Delivery';
    case 'card':
      return 'Credit / Debit Card';
    default:
      return method;
  }
}

class _StatusPalette {
  final Color fg;
  final Color bg;
  const _StatusPalette(this.fg, this.bg);
}

_StatusPalette _statusColors(String status) {
  switch (status.toLowerCase()) {
    case 'paid':
    case 'delivered':
    case 'completed':
      return const _StatusPalette(_S.green, _S.greenBg);
    case 'pending':
    case 'unpaid':
      return const _StatusPalette(_S.amber, _S.amberBg);
    case 'cancelled':
    case 'failed':
      return const _StatusPalette(_S.red, _S.redBg);
    default:
      return const _StatusPalette(_S.muted, Color(0xFFF3F4F6));
  }
}

// ════════════════════════════════════════════════════════════════
// SCREEN
// ════════════════════════════════════════════════════════════════

class InvoiceScreen extends StatefulWidget {
  final int orderId;
  const InvoiceScreen({super.key, required this.orderId});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  Data? _order;
  bool _loading = true;
  String? _error;
  bool _processingAction = false;

  final ScreenshotController _receiptController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _fetchOrder();
  }

  Future<void> _fetchOrder() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ApiService().getOrderDetail(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = result.data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? _S.red : _S.ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  Future<Uint8List?> _captureReceipt() async {
    try {
      return await _receiptController.capture(pixelRatio: 3);
    } catch (e) {
      debugPrint('Receipt capture failed: $e');
      return null;
    }
  }

  Future<void> _downloadReceipt() async {
    if (_processingAction) return;
    setState(() => _processingAction = true);
    final bytes = await _captureReceipt();
    if (bytes == null) {
      _showSnack('Could not generate the invoice image', isError: true);
      if (mounted) setState(() => _processingAction = false);
      return;
    }
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path =
          '${dir.path}/invoice_order_${widget.orderId}_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(path).writeAsBytes(bytes);
      _showSnack('Invoice saved');
    } catch (e) {
      _showSnack('Could not save the invoice', isError: true);
    } finally {
      if (mounted) setState(() => _processingAction = false);
    }
  }

  Future<void> _shareReceipt() async {
    if (_processingAction) return;
    setState(() => _processingAction = true);
    final bytes = await _captureReceipt();
    if (bytes == null) {
      _showSnack('Could not generate the invoice image', isError: true);
      if (mounted) setState(() => _processingAction = false);
      return;
    }
    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/invoice_order_${widget.orderId}.png';
      final file = await File(path).writeAsBytes(bytes);
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Here is my invoice for order #${widget.orderId}');
    } catch (e) {
      _showSnack('Could not share the invoice', isError: true);
    } finally {
      if (mounted) setState(() => _processingAction = false);
    }
  }

  Future<void> _continueShopping() async {
    await context.read<CartProvider>().fetchCart();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final order = _order;
    final error = _error;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: _loading
              ? _SkeletonState(c: c)
              : error != null
              ? _ErrorState(c: c, message: error, onRetry: _fetchOrder)
              : order == null
              ? _SkeletonState(c: c)
              : _SuccessBody(
                  c: c,
                  order: order,
                  receiptController: _receiptController,
                  processingAction: _processingAction,
                  onDownload: _downloadReceipt,
                  onShare: _shareReceipt,
                  onContinue: _continueShopping,
                ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// SUCCESS BODY
// ════════════════════════════════════════════════════════════════

class _SuccessBody extends StatelessWidget {
  final AppColors c;
  final Data order;
  final ScreenshotController receiptController;
  final bool processingAction;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onContinue;

  const _SuccessBody({
    required this.c,
    required this.order,
    required this.receiptController,
    required this.processingAction,
    required this.onDownload,
    required this.onShare,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: _S.greenBg,
          ),
          child: const Icon(Icons.check_rounded, color: _S.green, size: 30),
        ),
        const SizedBox(height: 10),
        Text(
          'Order Confirmed',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: c.text1,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Order #${order.id} placed successfully.',
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12.5, color: c.text2, height: 1.3),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: Screenshot(
            controller: receiptController,
            child: _ReceiptCard(order: order),
          ),
        ),
        const SizedBox(height: 12),
        _ActionRow(
          c: c,
          busy: processingAction,
          onDownload: onDownload,
          onShare: onShare,
        ),
        const SizedBox(height: 10),
        _ContinueButton(onTap: onContinue),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
// RECEIPT / INVOICE CARD — clean document style
// ════════════════════════════════════════════════════════════════

class _ReceiptCard extends StatelessWidget {
  final Data order;
  const _ReceiptCard({required this.order});

  String get _documentLabel {
    final status = order.paymentStatus.toLowerCase();
    if (status == 'unpaid' || status == 'pending') return 'INVOICE';
    return 'RECEIPT';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _S.paper,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _S.line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: _ReceiptHeader(order: order, documentLabel: _documentLabel),
          ),
          const _Rule(),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
            child: _PaymentSection(order: order),
          ),
          const _Rule(),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
            child: _ItemsTableHeader(),
          ),
          Expanded(
            child: order.items.isEmpty
                ? const Center(
                    child: Text(
                      'No items',
                      style: TextStyle(fontSize: 12, color: _S.muted),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
                    itemCount: order.items.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 14, color: _S.line, thickness: 1),
                    itemBuilder: (_, i) => _ProductRow(item: order.items[i]),
                  ),
          ),
          const _Rule(),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
            child: _DeliverySection(order: order),
          ),
          const _Rule(),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
            child: _TotalSection(order: order),
          ),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────

class _ReceiptHeader extends StatelessWidget {
  final Data order;
  final String documentLabel;
  const _ReceiptHeader({required this.order, required this.documentLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Darita Mart',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _S.ink,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Order #${order.id}',
                style: const TextStyle(fontSize: 11.5, color: _S.muted),
              ),
              Text(
                _formatDate(order.createdAt),
                style: const TextStyle(fontSize: 11.5, color: _S.muted),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              documentLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _S.ink,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            _StatusChip(status: order.paymentStatus),
          ],
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.fg.withOpacity(0.25), width: 1),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: colors.fg,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ─── Payment Section ──────────────────────────────────────────

class _PaymentSection extends StatelessWidget {
  final Data order;
  const _PaymentSection({required this.order});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _LabelValue(
            label: 'PAYMENT METHOD',
            value: _paymentMethodLabel(order.paymentMethod),
          ),
        ),
        Expanded(
          child: _LabelValue(
            label: 'PAYMENT STATUS',
            value: order.paymentStatus,
            valueColor: _statusColors(order.paymentStatus).fg,
            alignEnd: true,
          ),
        ),
      ],
    );
  }
}

class _LabelValue extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool alignEnd;

  const _LabelValue({
    required this.label,
    required this.value,
    this.valueColor,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            color: _S.muted,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor ?? _S.ink,
          ),
        ),
      ],
    );
  }
}

// ─── Items Table ──────────────────────────────────────────────

class _ItemsTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          flex: 5,
          child: Text(
            'ITEM',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: _S.muted,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'QTY',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: _S.muted,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            'AMOUNT',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: _S.muted,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductRow extends StatelessWidget {
  final Item item;
  const _ProductRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final unitPrice = double.tryParse(item.price) ?? 0.0;
    final lineTotal = (unitPrice * item.qty).toStringAsFixed(2);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: item.image,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(width: 32, height: 32, color: _S.line),
                  errorWidget: (_, __, ___) => Container(
                    width: 32,
                    height: 32,
                    color: const Color(0xFFF3F4F6),
                    alignment: Alignment.center,
                    child: Text(
                      item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: _S.muted,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _S.ink,
                      ),
                    ),
                    Text(
                      '\$${item.price}',
                      style: const TextStyle(fontSize: 10.5, color: _S.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            '${item.qty}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: _S.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            '\$$lineTotal',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: _S.ink,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Delivery Section ─────────────────────────────────────────

class _DeliverySection extends StatelessWidget {
  final Data order;
  const _DeliverySection({required this.order});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _LabelValue(label: 'DELIVER TO', value: order.address),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _LabelValue(
            label: 'CONTACT',
            value: order.phone,
            alignEnd: true,
          ),
        ),
      ],
    );
  }
}

// ─── Total Section ────────────────────────────────────────────

class _TotalSection extends StatelessWidget {
  final Data order;
  const _TotalSection({required this.order});

  Widget _row(
    String label,
    String value, {
    bool bold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: bold ? 14 : 12,
              color: bold ? _S.ink : _S.muted,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 15 : 12,
              color: valueColor ?? (bold ? _S.ink : _S.ink),
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final promoDiscount = double.tryParse(order.promotionDiscount) ?? 0.0;
    final couponDiscount = double.tryParse(order.couponDiscount) ?? 0.0;
    final grandTotal = double.tryParse(order.total) ?? 0.0;

    final subtotal = order.items.fold(0.0, (sum, item) {
      return sum + (double.tryParse(item.price) ?? 0.0) * item.qty;
    });

    return Column(
      children: [
        _row('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
        if (promoDiscount > 0)
          _row(
            'Promotion',
            '-\$${promoDiscount.toStringAsFixed(2)}',
            valueColor: _S.green,
          ),
        if (couponDiscount > 0)
          _row(
            order.couponCode != null
                ? 'Coupon (${order.couponCode})'
                : 'Coupon',
            '-\$${couponDiscount.toStringAsFixed(2)}',
            valueColor: _S.green,
          ),
        const SizedBox(height: 4),
        const _Rule(),
        const SizedBox(height: 8),
        _row('Total Amount', '\$${grandTotal.toStringAsFixed(2)}', bold: true),
      ],
    );
  }
}

// ─── Rule (solid divider) ─────────────────────────────────────

class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: _S.line);
  }
}

// ════════════════════════════════════════════════════════════════
// ACTION BUTTONS — Download / Share
// ════════════════════════════════════════════════════════════════

class _ActionRow extends StatelessWidget {
  final AppColors c;
  final bool busy;
  final VoidCallback onDownload;
  final VoidCallback onShare;

  const _ActionRow({
    required this.c,
    required this.busy,
    required this.onDownload,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _OutlinedAction(
            c: c,
            icon: Icons.download_rounded,
            label: 'Download',
            busy: busy,
            onTap: onDownload,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _OutlinedAction(
            c: c,
            icon: Icons.share_rounded,
            label: 'Share',
            busy: busy,
            onTap: onShare,
          ),
        ),
      ],
    );
  }
}

class _OutlinedAction extends StatelessWidget {
  final AppColors c;
  final IconData icon;
  final String label;
  final bool busy;
  final VoidCallback onTap;

  const _OutlinedAction({
    required this.c,
    required this.icon,
    required this.label,
    required this.busy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: c.cardBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: busy ? null : onTap,
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.border, width: 1.2),
          ),
          alignment: Alignment.center,
          child: busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _S.ink,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 16, color: c.text1),
                    const SizedBox(width: 7),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: c.text1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// CONTINUE SHOPPING BUTTON
// ════════════════════════════════════════════════════════════════

class _ContinueButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ContinueButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _S.ink,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: const SizedBox(
          width: double.infinity,
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.storefront_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Continue Shopping',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// LOADING SKELETON (static, no animation)
// ════════════════════════════════════════════════════════════════

class _SkeletonState extends StatelessWidget {
  final AppColors c;
  const _SkeletonState({required this.c});

  Widget _bar({double? width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(shape: BoxShape.circle, color: c.surface2),
        ),
        const SizedBox(height: 16),
        _bar(width: 160, height: 16),
        const SizedBox(height: 8),
        _bar(width: 200, height: 12),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: c.surface2,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _bar(height: 46)),
            const SizedBox(width: 10),
            Expanded(child: _bar(height: 46)),
          ],
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
// ERROR STATE
// ════════════════════════════════════════════════════════════════

class _ErrorState extends StatelessWidget {
  final AppColors c;
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.c,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: c.flashBg,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off_rounded, color: c.flashText, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load your order',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: c.text1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: c.text2, height: 1.5),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
