// import 'dart:io';
// import 'dart:typed_data';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:mart_frontend/providers/cart_provider.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:screenshot/screenshot.dart';
// import 'package:share_plus/share_plus.dart';

// import 'package:mart_frontend/models/order_detail_model.dart';
// import 'package:mart_frontend/services/api_service.dart';
// import 'package:mart_frontend/screens/theme/app_theme.dart';
// import 'package:mart_frontend/screens/main/main_screen.dart';

// // ════════════════════════════════════════════════════════════════
// // SUCCESS-SPECIFIC ACCENTS (always green, independent of theme)
// // ════════════════════════════════════════════════════════════════

// class _Success {
//   static const green = Color(0xFF2563EB);
//   static const greenDark = Color(0xFF2563EB);
//   static const greenLight = Color(0xFFE7F7ED);
//   static const amber = Color(0xFFF59E0B);
//   static const amberLight = Color(0xFFFEF3DD);
// }

// // ════════════════════════════════════════════════════════════════
// // FORMATTING HELPERS
// // ════════════════════════════════════════════════════════════════

// String _formatDate(String raw) {
//   final parsed = DateTime.tryParse(raw);
//   if (parsed == null) return raw;
//   final local = parsed.toLocal();
//   const months = [
//     'Jan',
//     'Feb',
//     'Mar',
//     'Apr',
//     'May',
//     'Jun',
//     'Jul',
//     'Aug',
//     'Sep',
//     'Oct',
//     'Nov',
//     'Dec',
//   ];
//   final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
//   final minute = local.minute.toString().padLeft(2, '0');
//   final period = local.hour >= 12 ? 'PM' : 'AM';
//   return '${months[local.month - 1]} ${local.day} · $hour12:$minute $period';
// }

// String _formatAmount(String raw) {
//   final value = double.tryParse(raw) ?? 0.0;
//   return value.toStringAsFixed(2);
// }

// String _paymentMethodLabel(String method) {
//   switch (method.toLowerCase()) {
//     case 'khqr':
//       return 'KHQR';
//     case 'aba':
//       return 'ABA Pay';
//     case 'cash':
//     case 'cod':
//       return 'Cash on Delivery';
//     case 'card':
//       return 'Credit / Debit Card';
//     default:
//       return method;
//   }
// }

// class _StatusPalette {
//   final Color fg;
//   final Color bg;
//   const _StatusPalette(this.fg, this.bg);
// }

// _StatusPalette _statusColors(String status, AppColors c) {
//   switch (status.toLowerCase()) {
//     case 'paid':
//     case 'delivered':
//     case 'completed':
//       return const _StatusPalette(_Success.greenDark, _Success.greenLight);
//     case 'pending':
//     case 'unpaid':
//       return const _StatusPalette(_Success.amber, _Success.amberLight);
//     case 'cancelled':
//     case 'failed':
//       return _StatusPalette(c.flashText, c.flashBg);
//     default:
//       return _StatusPalette(c.text2, c.surface2);
//   }
// }

// // ════════════════════════════════════════════════════════════════
// // SCREEN
// // ════════════════════════════════════════════════════════════════

// class OrderSuccessScreen extends StatefulWidget {
//   final int orderId;
//   const OrderSuccessScreen({super.key, required this.orderId});

//   @override
//   State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
// }

// class _OrderSuccessScreenState extends State<OrderSuccessScreen>
//     with TickerProviderStateMixin {
//   Data? _order;
//   bool _loading = true;
//   String? _error;
//   bool _processingAction = false;

//   final ScreenshotController _receiptController = ScreenshotController();

//   late final AnimationController _checkCtrl;
//   late final AnimationController _ringCtrl;
//   late final AnimationController _contentCtrl;

//   @override
//   void initState() {
//     super.initState();
//     _checkCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 850),
//     );
//     _ringCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1400),
//     );
//     _contentCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );
//     _fetchOrder();
//   }

//   @override
//   void dispose() {
//     _checkCtrl.dispose();
//     _ringCtrl.dispose();
//     _contentCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchOrder() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//     try {
//       final result = await ApiService().getOrderDetail(widget.orderId);
//       if (!mounted) return;
//       setState(() {
//         _order = result.data;
//         _loading = false;
//       });
//       _checkCtrl.forward(from: 0);
//       _ringCtrl.forward(from: 0);
//       await Future.delayed(const Duration(milliseconds: 250));
//       if (!mounted) return;
//       _contentCtrl.forward(from: 0);
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _error = e.toString().replaceFirst('Exception: ', '');
//         _loading = false;
//       });
//     }
//   }

//   void _showSnack(String message, {bool isError = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message, style: const TextStyle(color: Colors.white)),
//         backgroundColor: isError ? const Color(0xFFEF4444) : _Success.greenDark,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.all(12),
//       ),
//     );
//   }

//   Future<Uint8List?> _captureReceipt() async {
//     try {
//       return await _receiptController.capture(pixelRatio: 3);
//     } catch (e) {
//       debugPrint('Receipt capture failed: $e');
//       return null;
//     }
//   }

//   Future<void> _downloadReceipt() async {
//     if (_processingAction) return;
//     setState(() => _processingAction = true);

//     final bytes = await _captureReceipt();
//     if (bytes == null) {
//       _showSnack('Could not generate the receipt image', isError: true);
//       if (mounted) setState(() => _processingAction = false);
//       return;
//     }

//     try {
//       final dir = await getApplicationDocumentsDirectory();
//       final path =
//           '${dir.path}/receipt_order_${widget.orderId}_${DateTime.now().millisecondsSinceEpoch}.png';
//       await File(path).writeAsBytes(bytes);
//       _showSnack('Receipt saved');
//     } catch (e) {
//       _showSnack('Could not save the receipt', isError: true);
//     } finally {
//       if (mounted) setState(() => _processingAction = false);
//     }
//   }

//   Future<void> _shareReceipt() async {
//     if (_processingAction) return;
//     setState(() => _processingAction = true);

//     final bytes = await _captureReceipt();
//     if (bytes == null) {
//       _showSnack('Could not generate the receipt image', isError: true);
//       if (mounted) setState(() => _processingAction = false);
//       return;
//     }

//     try {
//       final dir = await getTemporaryDirectory();
//       final path = '${dir.path}/receipt_order_${widget.orderId}.png';
//       final file = await File(path).writeAsBytes(bytes);
//       await Share.shareXFiles([
//         XFile(file.path),
//       ], text: 'Here is my receipt for order #${widget.orderId}');
//     } catch (e) {
//       _showSnack('Could not share the receipt', isError: true);
//     } finally {
//       if (mounted) setState(() => _processingAction = false);
//     }
//   }

//   // void _continueShopping() {

//   //   Navigator.of(context).pushAndRemoveUntil(
//   //     MaterialPageRoute(builder: (_) => const MainScreen()),
//   //     (route) => false,
//   //   );
//   // }

//   Future<void> _continueShopping() async {
//     await context.read<CartProvider>().fetchCart();

//     if (!mounted) return;

//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const MainScreen()),
//       (_) => false,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final c = context.colors;
//     final order = _order;
//     final error = _error;

//     return Scaffold(
//       backgroundColor: c.background,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
//           child: _loading
//               ? _SkeletonState(c: c)
//               : error != null
//               ? _ErrorState(c: c, message: error, onRetry: _fetchOrder)
//               : order == null
//               ? _SkeletonState(c: c)
//               : _SuccessBody(
//                   c: c,
//                   order: order,
//                   receiptController: _receiptController,
//                   checkCtrl: _checkCtrl,
//                   ringCtrl: _ringCtrl,
//                   contentCtrl: _contentCtrl,
//                   processingAction: _processingAction,
//                   onDownload: _downloadReceipt,
//                   onShare: _shareReceipt,
//                   onContinue: _continueShopping,
//                 ),
//         ),
//       ),
//     );
//   }
// }

// // ════════════════════════════════════════════════════════════════
// // SUCCESS BODY — fixed Column, receipt fills remaining space
// // ════════════════════════════════════════════════════════════════

// class _SuccessBody extends StatelessWidget {
//   final AppColors c;
//   final Data order;
//   final ScreenshotController receiptController;
//   final AnimationController checkCtrl;
//   final AnimationController ringCtrl;
//   final AnimationController contentCtrl;
//   final bool processingAction;
//   final VoidCallback onDownload;
//   final VoidCallback onShare;
//   final VoidCallback onContinue;

//   const _SuccessBody({
//     required this.c,
//     required this.order,
//     required this.receiptController,
//     required this.checkCtrl,
//     required this.ringCtrl,
//     required this.contentCtrl,
//     required this.processingAction,
//     required this.onDownload,
//     required this.onShare,
//     required this.onContinue,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _SuccessCheck(checkCtrl: checkCtrl, ringCtrl: ringCtrl),
//         const SizedBox(height: 12),
//         _Reveal(
//           controller: contentCtrl,
//           interval: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
//           child: Column(
//             children: [
//               Text(
//                 'Order Confirmed',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w800,
//                   color: c.text1,
//                   letterSpacing: -0.3,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 'Order #${order.id} placed successfully.',
//                 textAlign: TextAlign.center,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(fontSize: 12.5, color: c.text2, height: 1.3),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 14),
//         Expanded(
//           child: _Reveal(
//             controller: contentCtrl,
//             interval: const Interval(0.15, 0.75, curve: Curves.easeOutCubic),
//             child: Screenshot(
//               controller: receiptController,
//               child: _ReceiptCard(c: c, order: order),
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         _Reveal(
//           controller: contentCtrl,
//           interval: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
//           child: _ActionRow(
//             c: c,
//             busy: processingAction,
//             onDownload: onDownload,
//             onShare: onShare,
//           ),
//         ),
//         const SizedBox(height: 10),
//         _Reveal(
//           controller: contentCtrl,
//           interval: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
//           child: _ContinueButton(onTap: onContinue),
//         ),
//       ],
//     );
//   }
// }

// // ── reusable fade + slide-up reveal wrapper ────────────────────

// class _Reveal extends StatelessWidget {
//   final AnimationController controller;
//   final Interval interval;
//   final Widget child;

//   const _Reveal({
//     required this.controller,
//     required this.interval,
//     required this.child,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final animation = CurvedAnimation(parent: controller, curve: interval);
//     return AnimatedBuilder(
//       animation: animation,
//       builder: (context, _) {
//         final value = animation.value.clamp(0.0, 1.0);
//         return Opacity(
//           opacity: value,
//           child: Transform.translate(
//             offset: Offset(0, (1 - value) * 14),
//             child: child,
//           ),
//         );
//       },
//     );
//   }
// }

// // ════════════════════════════════════════════════════════════════
// // SUCCESS CHECK ANIMATION (compact — sized to save vertical space)
// // ════════════════════════════════════════════════════════════════

// class _SuccessCheck extends StatelessWidget {
//   final AnimationController checkCtrl;
//   final AnimationController ringCtrl;

//   const _SuccessCheck({required this.checkCtrl, required this.ringCtrl});

//   @override
//   Widget build(BuildContext context) {
//     final badgeScale = CurvedAnimation(
//       parent: checkCtrl,
//       curve: const Interval(0.1, 0.7, curve: Curves.elasticOut),
//     );
//     final iconFade = CurvedAnimation(
//       parent: checkCtrl,
//       curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
//     );
//     final burst = CurvedAnimation(
//       parent: ringCtrl,
//       curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
//     );

//     return SizedBox(
//       width: 92,
//       height: 92,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           AnimatedBuilder(
//             animation: burst,
//             builder: (context, _) => Opacity(
//               opacity: (1 - burst.value).clamp(0.0, 1.0) * 0.55,
//               child: Transform.scale(
//                 scale: 0.55 + burst.value * 0.8,
//                 child: Container(
//                   width: 92,
//                   height: 92,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: _Success.green.withOpacity(0.15),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           AnimatedBuilder(
//             animation: badgeScale,
//             builder: (context, _) => Transform.scale(
//               scale: badgeScale.value.clamp(0.0, 1.25),
//               child: Container(
//                 width: 64,
//                 height: 64,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: const LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [_Success.green, _Success.greenDark],
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: _Success.green.withOpacity(0.35),
//                       blurRadius: 20,
//                       offset: const Offset(0, 8),
//                     ),
//                   ],
//                 ),
//                 child: AnimatedBuilder(
//                   animation: iconFade,
//                   builder: (context, _) => Opacity(
//                     opacity: iconFade.value.clamp(0.0, 1.0),
//                     child: const Icon(
//                       Icons.check_rounded,
//                       color: Colors.white,
//                       size: 32,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ════════════════════════════════════════════════════════════════
// // RECEIPT CARD — fixed sections + internally scrollable item list
// // ════════════════════════════════════════════════════════════════

// class _ReceiptCard extends StatelessWidget {
//   final AppColors c;
//   final Data order;
//   const _ReceiptCard({required this.c, required this.order});

//   String get _documentLabel {
//     final status = order.paymentStatus.toLowerCase();
//     if (status == 'unpaid' || status == 'pending') return 'Invoice';
//     return 'Receipt';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       clipBehavior: Clip.antiAlias,
//       decoration: BoxDecoration(
//         color: c.cardBg,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 24,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _ReceiptHeader(c: c, order: order, documentLabel: _documentLabel),
//           _DashedDivider(c: c),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
//             child: _PaymentSection(c: c, order: order),
//           ),
//           _DashedDivider(c: c),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
//             child: _SectionTitle(c: c, text: 'Items (${order.items.length})'),
//           ),
//           Expanded(
//             child: order.items.isEmpty
//                 ? Center(
//                     child: Text(
//                       'No items',
//                       style: TextStyle(fontSize: 12, color: c.text3),
//                     ),
//                   )
//                 : ListView.builder(
//                     padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
//                     itemCount: order.items.length,
//                     itemBuilder: (context, index) =>
//                         _ProductTile(c: c, item: order.items[index]),
//                   ),
//           ),
//           _DashedDivider(c: c),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
//             child: _DeliverySection(c: c, order: order),
//           ),
//           _DashedDivider(c: c),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
//             child: _TotalSection(c: c, order: order),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ReceiptHeader extends StatelessWidget {
//   final AppColors c;
//   final Data order;
//   final String documentLabel;
//   const _ReceiptHeader({
//     required this.c,
//     required this.order,
//     required this.documentLabel,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
//       decoration: const BoxDecoration(
//         color: _Success.greenLight,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 38,
//             height: 38,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               documentLabel == 'Invoice'
//                   ? Icons.receipt_outlined
//                   : Icons.receipt_long_rounded,
//               color: _Success.green,
//               size: 19,
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   documentLabel,
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w800,
//                     color: c.text1,
//                   ),
//                 ),
//                 const SizedBox(height: 1),
//                 Text(
//                   '#${order.id} · ${_formatDate(order.createdAt)}',
//                   style: TextStyle(fontSize: 11, color: c.text2),
//                 ),
//               ],
//             ),
//           ),
//           _StatusChip(c: c, status: order.paymentStatus),
//         ],
//       ),
//     );
//   }
// }

// class _StatusChip extends StatelessWidget {
//   final AppColors c;
//   final String status;
//   const _StatusChip({required this.c, required this.status});

//   @override
//   Widget build(BuildContext context) {
//     final colors = _statusColors(status, c);
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
//       decoration: BoxDecoration(
//         color: colors.bg,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         status.toUpperCase(),
//         style: TextStyle(
//           color: colors.fg,
//           fontSize: 9.5,
//           fontWeight: FontWeight.w800,
//           letterSpacing: 0.4,
//         ),
//       ),
//     );
//   }
// }

// class _SectionTitle extends StatelessWidget {
//   final AppColors c;
//   final String text;
//   const _SectionTitle({required this.c, required this.text});

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       text.toUpperCase(),
//       style: TextStyle(
//         fontSize: 10.5,
//         fontWeight: FontWeight.w800,
//         color: c.text3,
//         letterSpacing: 0.6,
//       ),
//     );
//   }
// }

// class _PaymentSection extends StatelessWidget {
//   final AppColors c;
//   final Data order;
//   const _PaymentSection({required this.c, required this.order});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: _InfoTile(
//             c: c,
//             icon: Icons.payment_rounded,
//             label: 'Method',
//             value: _paymentMethodLabel(order.paymentMethod),
//           ),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: _InfoTile(
//             c: c,
//             icon: Icons.verified_outlined,
//             label: 'Status',
//             value: order.paymentStatus,
//             valueColor: _statusColors(order.paymentStatus, c).fg,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _InfoTile extends StatelessWidget {
//   final AppColors c;
//   final IconData icon;
//   final String label;
//   final String value;
//   final Color? valueColor;

//   const _InfoTile({
//     required this.c,
//     required this.icon,
//     required this.label,
//     required this.value,
//     this.valueColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: c.surface2,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, size: 15, color: _Success.green),
//           const SizedBox(width: 7),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 9.5,
//                     color: c.text3,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 1),
//                 Text(
//                   value,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     fontSize: 12.5,
//                     fontWeight: FontWeight.w700,
//                     color: valueColor ?? c.text1,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ProductTile extends StatelessWidget {
//   final AppColors c;
//   final Item item;
//   const _ProductTile({required this.c, required this.item});

//   double get _unitPrice => double.tryParse(item.price) ?? 0.0;

//   @override
//   Widget build(BuildContext context) {
//     final lineTotal = (_unitPrice * item.qty).toStringAsFixed(2);
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: CachedNetworkImage(
//               imageUrl: item.image,
//               width: 42,
//               height: 42,
//               fit: BoxFit.cover,
//               placeholder: (context, url) =>
//                   Container(width: 42, height: 42, color: c.surface2),
//               errorWidget: (context, url, error) => Container(
//                 width: 42,
//                 height: 42,
//                 color: _Success.greenLight,
//                 alignment: Alignment.center,
//                 child: Text(
//                   item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
//                   style: const TextStyle(
//                     color: _Success.green,
//                     fontWeight: FontWeight.w800,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item.name,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     fontSize: 12.5,
//                     fontWeight: FontWeight.w600,
//                     color: c.text1,
//                   ),
//                 ),
//                 const SizedBox(height: 1),
//                 Text(
//                   'Qty ${item.qty} · \$${item.price} each',
//                   style: TextStyle(fontSize: 10.5, color: c.text3),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 8),
//           Text(
//             '\$$lineTotal',
//             style: TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w800,
//               color: c.text1,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _DeliverySection extends StatelessWidget {
//   final AppColors c;
//   final Data order;
//   const _DeliverySection({required this.c, required this.order});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _DetailRow(
//           c: c,
//           icon: Icons.location_on_rounded,
//           label: 'Delivery address',
//           value: order.address,
//         ),
//         const SizedBox(height: 8),
//         _DetailRow(
//           c: c,
//           icon: Icons.phone_rounded,
//           label: 'Contact number',
//           value: order.phone,
//         ),
//       ],
//     );
//   }
// }

// class _DetailRow extends StatelessWidget {
//   final AppColors c;
//   final IconData icon;
//   final String label;
//   final String value;

//   const _DetailRow({
//     required this.c,
//     required this.icon,
//     required this.label,
//     required this.value,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           width: 28,
//           height: 28,
//           decoration: BoxDecoration(
//             color: _Success.greenLight,
//             borderRadius: BorderRadius.circular(9),
//           ),
//           child: Icon(icon, size: 14, color: _Success.green),
//         ),
//         const SizedBox(width: 9),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 10,
//                   color: c.text3,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 1),
//               Text(
//                 value,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   fontSize: 12.5,
//                   color: c.text1,
//                   fontWeight: FontWeight.w600,
//                   height: 1.3,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _TotalSection extends StatelessWidget {
//   final AppColors c;
//   final Data order;
//   const _TotalSection({required this.c, required this.order});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           'Total Amount',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w700,
//             color: c.text1,
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               colors: [_Success.green, _Success.greenDark],
//             ),
//             borderRadius: BorderRadius.circular(13),
//             boxShadow: [
//               BoxShadow(
//                 color: _Success.green.withOpacity(0.3),
//                 blurRadius: 12,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           child: Text(
//             '\$${_formatAmount(order.total)}',
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 16,
//               fontWeight: FontWeight.w800,
//               letterSpacing: -0.2,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _DashedDivider extends StatelessWidget {
//   final AppColors c;
//   const _DashedDivider({required this.c});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           const dashWidth = 6.0;
//           const gap = 4.0;
//           final count = (constraints.maxWidth / (dashWidth + gap)).floor();
//           return SizedBox(
//             height: 1,
//             child: Row(
//               children: List.generate(
//                 count,
//                 (index) => Padding(
//                   padding: const EdgeInsets.only(right: gap),
//                   child: Container(
//                     width: dashWidth,
//                     height: 1,
//                     color: c.border,
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// // ════════════════════════════════════════════════════════════════
// // ACTION BUTTONS — Download / Share
// // ════════════════════════════════════════════════════════════════

// class _ActionRow extends StatelessWidget {
//   final AppColors c;
//   final bool busy;
//   final VoidCallback onDownload;
//   final VoidCallback onShare;

//   const _ActionRow({
//     required this.c,
//     required this.busy,
//     required this.onDownload,
//     required this.onShare,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: _OutlinedAction(
//             c: c,
//             icon: Icons.download_rounded,
//             label: 'Download',
//             busy: busy,
//             onTap: onDownload,
//           ),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: _OutlinedAction(
//             c: c,
//             icon: Icons.share_rounded,
//             label: 'Share',
//             busy: busy,
//             onTap: onShare,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _OutlinedAction extends StatelessWidget {
//   final AppColors c;
//   final IconData icon;
//   final String label;
//   final bool busy;
//   final VoidCallback onTap;

//   const _OutlinedAction({
//     required this.c,
//     required this.icon,
//     required this.label,
//     required this.busy,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: c.cardBg,
//       borderRadius: BorderRadius.circular(14),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(14),
//         onTap: busy ? null : onTap,
//         child: Container(
//           height: 46,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(color: c.border, width: 1.2),
//           ),
//           alignment: Alignment.center,
//           child: busy
//               ? SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: _Success.green,
//                   ),
//                 )
//               : Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(icon, size: 16, color: c.text1),
//                     const SizedBox(width: 7),
//                     Text(
//                       label,
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w700,
//                         color: c.text1,
//                       ),
//                     ),
//                   ],
//                 ),
//         ),
//       ),
//     );
//   }
// }

// // ════════════════════════════════════════════════════════════════
// // CONTINUE SHOPPING BUTTON
// // ════════════════════════════════════════════════════════════════

// class _ContinueButton extends StatelessWidget {
//   final VoidCallback onTap;
//   const _ContinueButton({required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       borderRadius: BorderRadius.circular(16),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16),
//         onTap: onTap,
//         child: Container(
//           width: double.infinity,
//           height: 50,
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               colors: [_Success.green, _Success.greenDark],
//             ),
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: _Success.green.withOpacity(0.35),
//                 blurRadius: 18,
//                 offset: const Offset(0, 8),
//               ),
//             ],
//           ),
//           child: const Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.storefront_rounded, color: Colors.white, size: 18),
//               SizedBox(width: 8),
//               Text(
//                 'Continue Shopping',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 15,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ════════════════════════════════════════════════════════════════
// // LOADING SKELETON
// // ════════════════════════════════════════════════════════════════

// class _SkeletonState extends StatefulWidget {
//   final AppColors c;
//   const _SkeletonState({required this.c});

//   @override
//   State<_SkeletonState> createState() => _SkeletonStateState();
// }

// class _SkeletonStateState extends State<_SkeletonState>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _pulseCtrl;

//   @override
//   void initState() {
//     super.initState();
//     _pulseCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1100),
//     )..repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _pulseCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final c = widget.c;
//     return AnimatedBuilder(
//       animation: _pulseCtrl,
//       builder: (context, _) {
//         final opacity = 0.4 + _pulseCtrl.value * 0.3;
//         return Opacity(
//           opacity: opacity,
//           child: Column(
//             children: [
//               Container(
//                 width: 64,
//                 height: 64,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: c.surface2,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               _bar(c, width: 160, height: 18),
//               const SizedBox(height: 8),
//               _bar(c, width: 200, height: 12),
//               const SizedBox(height: 16),
//               Expanded(
//                 child: Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: c.surface2,
//                     borderRadius: BorderRadius.circular(24),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Expanded(child: _bar(c, height: 46)),
//                   const SizedBox(width: 10),
//                   Expanded(child: _bar(c, height: 46)),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _bar(AppColors c, {double? width, required double height}) {
//     return Container(
//       width: width,
//       height: height,
//       decoration: BoxDecoration(
//         color: c.surface2,
//         borderRadius: BorderRadius.circular(10),
//       ),
//     );
//   }
// }

// // ════════════════════════════════════════════════════════════════
// // ERROR STATE
// // ════════════════════════════════════════════════════════════════

// class _ErrorState extends StatelessWidget {
//   final AppColors c;
//   final String message;
//   final VoidCallback onRetry;

//   const _ErrorState({
//     required this.c,
//     required this.message,
//     required this.onRetry,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 64,
//               height: 64,
//               decoration: BoxDecoration(
//                 color: c.flashBg,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(Icons.wifi_off_rounded, color: c.flashText, size: 28),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Could not load your order',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//                 color: c.text1,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               message,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 13, color: c.text2, height: 1.5),
//             ),
//             const SizedBox(height: 20),
//             SizedBox(
//               width: double.infinity,
//               height: 48,
//               child: ElevatedButton(
//                 onPressed: onRetry,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: c.accent,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                 ),
//                 child: const Text(
//                   'Retry',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
// SUCCESS-SPECIFIC ACCENTS (always blue-green, independent of theme)
// ════════════════════════════════════════════════════════════════

class _S {
  static const green = Color(0xFF2563EB);
  static const greenDark = Color(0xFF1D4ED8);
  static const greenLight = Color(0xFFEFF6FF);
  static const amber = Color(0xFFF59E0B);
  static const amberLight = Color(0xFFFEF3DD);
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
  return '${months[local.month - 1]} ${local.day} · $hour12:$minute $period';
}

String _formatAmount(String raw) {
  final value = double.tryParse(raw) ?? 0.0;
  return value.toStringAsFixed(2);
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

_StatusPalette _statusColors(String status, AppColors c) {
  switch (status.toLowerCase()) {
    case 'paid':
    case 'delivered':
    case 'completed':
      return const _StatusPalette(_S.green, _S.greenLight);
    case 'pending':
    case 'unpaid':
      return const _StatusPalette(_S.amber, _S.amberLight);
    case 'cancelled':
    case 'failed':
      return _StatusPalette(c.flashText, c.flashBg);
    default:
      return _StatusPalette(c.text2, c.surface2);
  }
}

// ════════════════════════════════════════════════════════════════
// SCREEN
// ════════════════════════════════════════════════════════════════

class OrderSuccessScreen extends StatefulWidget {
  final int orderId;
  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with TickerProviderStateMixin {
  Data? _order;
  bool _loading = true;
  String? _error;
  bool _processingAction = false;

  final ScreenshotController _receiptController = ScreenshotController();

  late final AnimationController _checkCtrl;
  late final AnimationController _ringCtrl;
  late final AnimationController _contentCtrl;

  @override
  void initState() {
    super.initState();
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fetchOrder();
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    _ringCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
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
      _checkCtrl.forward(from: 0);
      _ringCtrl.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      _contentCtrl.forward(from: 0);
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
        backgroundColor: isError ? const Color(0xFFEF4444) : _S.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      _showSnack('Could not generate the receipt image', isError: true);
      if (mounted) setState(() => _processingAction = false);
      return;
    }
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path =
          '${dir.path}/receipt_order_${widget.orderId}_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(path).writeAsBytes(bytes);
      _showSnack('Receipt saved');
    } catch (e) {
      _showSnack('Could not save the receipt', isError: true);
    } finally {
      if (mounted) setState(() => _processingAction = false);
    }
  }

  Future<void> _shareReceipt() async {
    if (_processingAction) return;
    setState(() => _processingAction = true);
    final bytes = await _captureReceipt();
    if (bytes == null) {
      _showSnack('Could not generate the receipt image', isError: true);
      if (mounted) setState(() => _processingAction = false);
      return;
    }
    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/receipt_order_${widget.orderId}.png';
      final file = await File(path).writeAsBytes(bytes);
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Here is my receipt for order #${widget.orderId}');
    } catch (e) {
      _showSnack('Could not share the receipt', isError: true);
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
                  checkCtrl: _checkCtrl,
                  ringCtrl: _ringCtrl,
                  contentCtrl: _contentCtrl,
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
  final AnimationController checkCtrl;
  final AnimationController ringCtrl;
  final AnimationController contentCtrl;
  final bool processingAction;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onContinue;

  const _SuccessBody({
    required this.c,
    required this.order,
    required this.receiptController,
    required this.checkCtrl,
    required this.ringCtrl,
    required this.contentCtrl,
    required this.processingAction,
    required this.onDownload,
    required this.onShare,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SuccessCheck(checkCtrl: checkCtrl, ringCtrl: ringCtrl),
        const SizedBox(height: 12),
        _Reveal(
          controller: contentCtrl,
          interval: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          child: Column(
            children: [
              Text(
                'Order Confirmed',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: c.text1,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Order #${order.id} placed successfully.',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.5, color: c.text2, height: 1.3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: _Reveal(
            controller: contentCtrl,
            interval: const Interval(0.15, 0.75, curve: Curves.easeOutCubic),
            child: Screenshot(
              controller: receiptController,
              child: _ReceiptCard(c: c, order: order),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _Reveal(
          controller: contentCtrl,
          interval: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
          child: _ActionRow(
            c: c,
            busy: processingAction,
            onDownload: onDownload,
            onShare: onShare,
          ),
        ),
        const SizedBox(height: 10),
        _Reveal(
          controller: contentCtrl,
          interval: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
          child: _ContinueButton(onTap: onContinue),
        ),
      ],
    );
  }
}

// ── Fade + slide-up reveal wrapper ────────────────────────────

class _Reveal extends StatelessWidget {
  final AnimationController controller;
  final Interval interval;
  final Widget child;

  const _Reveal({
    required this.controller,
    required this.interval,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(parent: controller, curve: interval);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final value = animation.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 14),
            child: child,
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════
// SUCCESS CHECK ANIMATION
// ════════════════════════════════════════════════════════════════

class _SuccessCheck extends StatelessWidget {
  final AnimationController checkCtrl;
  final AnimationController ringCtrl;

  const _SuccessCheck({required this.checkCtrl, required this.ringCtrl});

  @override
  Widget build(BuildContext context) {
    final badgeScale = CurvedAnimation(
      parent: checkCtrl,
      curve: const Interval(0.1, 0.7, curve: Curves.elasticOut),
    );
    final iconFade = CurvedAnimation(
      parent: checkCtrl,
      curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
    );
    final burst = CurvedAnimation(
      parent: ringCtrl,
      curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
    );

    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: burst,
            builder: (_, __) => Opacity(
              opacity: (1 - burst.value).clamp(0.0, 1.0) * 0.55,
              child: Transform.scale(
                scale: 0.55 + burst.value * 0.8,
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _S.green.withOpacity(0.15),
                  ),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: badgeScale,
            builder: (_, __) => Transform.scale(
              scale: badgeScale.value.clamp(0.0, 1.25),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_S.green, _S.greenDark],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _S.green.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: AnimatedBuilder(
                  animation: iconFade,
                  builder: (_, __) => Opacity(
                    opacity: iconFade.value.clamp(0.0, 1.0),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// RECEIPT CARD
// ════════════════════════════════════════════════════════════════

class _ReceiptCard extends StatelessWidget {
  final AppColors c;
  final Data order;
  const _ReceiptCard({required this.c, required this.order});

  String get _documentLabel {
    final status = order.paymentStatus.toLowerCase();
    if (status == 'unpaid' || status == 'pending') return 'Invoice';
    return 'Receipt';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReceiptHeader(c: c, order: order, documentLabel: _documentLabel),
          _DashedDivider(c: c),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: _PaymentSection(c: c, order: order),
          ),
          _DashedDivider(c: c),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
            child: _SectionTitle(c: c, text: 'Items (${order.items.length})'),
          ),
          Expanded(
            child: order.items.isEmpty
                ? Center(
                    child: Text(
                      'No items',
                      style: TextStyle(fontSize: 12, color: c.text3),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    itemCount: order.items.length,
                    itemBuilder: (_, i) =>
                        _ProductTile(c: c, item: order.items[i]),
                  ),
          ),
          _DashedDivider(c: c),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: _DeliverySection(c: c, order: order),
          ),
          _DashedDivider(c: c),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: _TotalSection(c: c, order: order),
          ),
        ],
      ),
    );
  }
}

// ─── Receipt Header ───────────────────────────────────────────

class _ReceiptHeader extends StatelessWidget {
  final AppColors c;
  final Data order;
  final String documentLabel;
  const _ReceiptHeader({
    required this.c,
    required this.order,
    required this.documentLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: const BoxDecoration(
        color: _S.greenLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              documentLabel == 'Invoice'
                  ? Icons.receipt_outlined
                  : Icons.receipt_long_rounded,
              color: _S.green,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  documentLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: c.text1,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '#${order.id} · ${_formatDate(order.createdAt)}',
                  style: TextStyle(fontSize: 11, color: c.text2),
                ),
              ],
            ),
          ),
          _StatusChip(c: c, status: order.paymentStatus),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final AppColors c;
  final String status;
  const _StatusChip({required this.c, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors(status, c);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(20),
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

class _SectionTitle extends StatelessWidget {
  final AppColors c;
  final String text;
  const _SectionTitle({required this.c, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        color: c.text3,
        letterSpacing: 0.6,
      ),
    );
  }
}

// ─── Payment Section ──────────────────────────────────────────

class _PaymentSection extends StatelessWidget {
  final AppColors c;
  final Data order;
  const _PaymentSection({required this.c, required this.order});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InfoTile(
            c: c,
            icon: Icons.payment_rounded,
            label: 'Method',
            value: _paymentMethodLabel(order.paymentMethod),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _InfoTile(
            c: c,
            icon: Icons.verified_outlined,
            label: 'Status',
            value: order.paymentStatus,
            valueColor: _statusColors(order.paymentStatus, c).fg,
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final AppColors c;
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoTile({
    required this.c,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: _S.green),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9.5,
                    color: c.text3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? c.text1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Product Tile ─────────────────────────────────────────────

class _ProductTile extends StatelessWidget {
  final AppColors c;
  final Item item;
  const _ProductTile({required this.c, required this.item});

  @override
  Widget build(BuildContext context) {
    final unitPrice = double.tryParse(item.price) ?? 0.0;
    final lineTotal = (unitPrice * item.qty).toStringAsFixed(2);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: item.image,
              width: 42,
              height: 42,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(width: 42, height: 42, color: c.surface2),
              errorWidget: (_, __, ___) => Container(
                width: 42,
                height: 42,
                color: _S.greenLight,
                alignment: Alignment.center,
                child: Text(
                  item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: _S.green,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: c.text1,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Qty ${item.qty} · \$${item.price} each',
                  style: TextStyle(fontSize: 10.5, color: c.text3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '\$$lineTotal',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: c.text1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Delivery Section ─────────────────────────────────────────

class _DeliverySection extends StatelessWidget {
  final AppColors c;
  final Data order;
  const _DeliverySection({required this.c, required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DetailRow(
          c: c,
          icon: Icons.location_on_rounded,
          label: 'Delivery address',
          value: order.address,
        ),
        const SizedBox(height: 8),
        _DetailRow(
          c: c,
          icon: Icons.phone_rounded,
          label: 'Contact number',
          value: order.phone,
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final AppColors c;
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.c,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _S.greenLight,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 14, color: _S.green),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: c.text3,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  color: c.text1,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Total Section ────────────────────────────────────────────

class _TotalSection extends StatelessWidget {
  final AppColors c;
  final Data order;
  const _TotalSection({required this.c, required this.order});

  Widget _row(
    AppColors c,
    String label,
    String value, {
    bool bold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: bold ? 14 : 12,
              color: bold ? c.text1 : c.text3,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 14 : 12,
              color: valueColor ?? (bold ? c.text1 : c.text2),
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
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

    // Reconstruct subtotal before discounts
    final subtotal = order.items.fold(0.0, (sum, item) {
      return sum + (double.tryParse(item.price) ?? 0.0) * item.qty;
    });

    return Column(
      children: [
        _row(c, 'Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
        if (promoDiscount > 0)
          _row(
            c,
            'Promotion',
            '-\$${promoDiscount.toStringAsFixed(2)}',
            valueColor: const Color(0xFF10B981),
          ),
        if (couponDiscount > 0)
          _row(
            c,
            order.couponCode != null
                ? 'Coupon (${order.couponCode})'
                : 'Coupon',
            '-\$${couponDiscount.toStringAsFixed(2)}',
            valueColor: const Color(0xFF10B981),
          ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Amount',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: c.text1,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_S.green, _S.greenDark],
                ),
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color: _S.green.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                '\$${grandTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Dashed Divider ───────────────────────────────────────────

class _DashedDivider extends StatelessWidget {
  final AppColors c;
  const _DashedDivider({required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (_, constraints) {
          const dashWidth = 6.0;
          const gap = 4.0;
          final count = (constraints.maxWidth / (dashWidth + gap)).floor();
          return SizedBox(
            height: 1,
            child: Row(
              children: List.generate(
                count,
                (i) => Padding(
                  padding: const EdgeInsets.only(right: gap),
                  child: Container(
                    width: dashWidth,
                    height: 1,
                    color: c.border,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
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
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: busy ? null : onTap,
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.border, width: 1.2),
          ),
          alignment: Alignment.center,
          child: busy
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _S.green,
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
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_S.green, _S.greenDark]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _S.green.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
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
// LOADING SKELETON
// ════════════════════════════════════════════════════════════════

class _SkeletonState extends StatefulWidget {
  final AppColors c;
  const _SkeletonState({required this.c});

  @override
  State<_SkeletonState> createState() => _SkeletonStateState();
}

class _SkeletonStateState extends State<_SkeletonState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Widget _bar(AppColors c, {double? width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, __) {
        final opacity = 0.4 + _pulseCtrl.value * 0.3;
        return Opacity(
          opacity: opacity,
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.surface2,
                ),
              ),
              const SizedBox(height: 16),
              _bar(c, width: 160, height: 18),
              const SizedBox(height: 8),
              _bar(c, width: 200, height: 12),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: c.surface2,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _bar(c, height: 46)),
                  const SizedBox(width: 10),
                  Expanded(child: _bar(c, height: 46)),
                ],
              ),
            ],
          ),
        );
      },
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
