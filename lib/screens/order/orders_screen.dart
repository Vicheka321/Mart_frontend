// import 'dart:async';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get_utils/src/extensions/internacionalization.dart';
// import 'package:mart_frontend/checkout/checkout_screen.dart';
// import '../../models/my_orders_model.dart';
// import '../../services/api_service.dart';
// import '../main/main_screen.dart';
// import '../theme/app_theme.dart';

// class _StatusStyle {
//   final String label;
//   final Color color;
//   final Color bgColor;
//   final IconData icon;
//   final int trackingStep; // -1 = cancelled

//   const _StatusStyle({
//     required this.label,
//     required this.color,
//     required this.bgColor,
//     required this.icon,
//     required this.trackingStep,
//   });
// }

// _StatusStyle _statusStyle(String status) {
//   switch (status.toLowerCase().trim()) {
//     case 'pending':
//       return _StatusStyle(
//         label: 'pending'.tr,
//         color: Color(0xFFF59E0B),
//         bgColor: Color(0xFFFEF3C7),
//         icon: Icons.schedule_rounded,
//         trackingStep: 0,
//       );
//     case 'processing':
//       return _StatusStyle(
//         label: 'processing'.tr,
//         color: Color(0xFF8B5CF6),
//         bgColor: Color(0xFFEDE9FE),
//         icon: Icons.inventory_2_outlined,
//         trackingStep: 1,
//       );
//     // case 'shipping':
//     //   return const _StatusStyle(
//     //     label: 'Shipping',
//     //     color: Color(0xFF3B82F6),
//     //     bgColor: Color(0xFFDBEAFE),
//     //     icon: Icons.local_shipping_outlined,
//     //     trackingStep: 2,
//     //   );
//     case 'completed':
//       return _StatusStyle(
//         // label: 'Delivered',
//         label: 'completed'.tr,
//         color: Color(0xFF10B981),
//         bgColor: Color(0xFFD1FAE5),
//         icon: Icons.check_circle_outline_rounded,
//         trackingStep: 3,
//       );
//     case 'cancelled':
//       return _StatusStyle(
//         label: 'cancelled'.tr,
//         color: Color(0xFFEF4444),
//         bgColor: Color(0xFFFEE2E2),
//         icon: Icons.cancel_outlined,
//         trackingStep: -1,
//       );
//     default:
//       return _StatusStyle(
//         label: status,
//         color: const Color(0xFF888888),
//         bgColor: const Color(0xFFF3F3F3),
//         icon: Icons.help_outline_rounded,
//         trackingStep: 0,
//       );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // ORDERS SCREEN
// // ═══════════════════════════════════════════════════════════════

// class OrdersScreen extends StatefulWidget {
//   const OrdersScreen({super.key});

//   @override
//   State<OrdersScreen> createState() => _OrdersScreenState();
// }

// class _OrdersScreenState extends State<OrdersScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   final ApiService _api = ApiService();
//   List<Order> _orders = [];
//   bool _isLoading = true;
//   String? _error;

//   static const _tabDefs = [
//     {'label': 'all', 'filter': null},
//     {'label': 'pending', 'filter': 'pending'},
//     {'label': 'processing', 'filter': 'processing'},
//     {'label': 'completed', 'filter': 'completed'},
//     {'label': 'cancelled', 'filter': 'cancelled'},
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: _tabDefs.length, vsync: this);
//     _loadOrders();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadOrders({bool refresh = false}) async {
//     if (!refresh)
//       setState(() {
//         _isLoading = true;
//         _error = null;
//       });

//     try {
//       final result = await _api.fetchMyOrders();

//       if (mounted) {
//         setState(() {
//           _orders = result.orders;
//           _isLoading = false;
//           _error = null;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _error = e.toString();
//         });
//       }
//     }
//   }

//   List<Order> _filtered(Object? filter) {
//     if (filter == null) return _orders;
//     final f = filter.toString();
//     return _orders.where((o) {
//       final status = o.status.toLowerCase().trim();

//       if (f == 'completed') {
//         return status == 'completed' || status == 'delivered';
//       }

//       return status == f;
//     }).toList();
//   }

//   Future<void> _buyAgain(Order order) async {
//     // HapticFeedback.mediumImpact();

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => CheckoutScreen(
//           fromCart: false,
//           items: order.items.map((item) {
//             return OrderItem(
//               id: item.productId.toString(),
//               name: item.name,
//               imageUrl: item.image,
//               unitPrice: double.parse(item.finalPrice),
//               quantity: item.qty,
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;

//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: NestedScrollView(
//         headerSliverBuilder: (_, __) => [
//           _buildAppBar(colors),
//           _buildTabBar(colors),
//         ],
//         body: _isLoading
//             ? _buildSkeletons(colors)
//             : _error != null
//             ? _empty(context, colors)
//             : TabBarView(
//                 controller: _tabController,
//                 physics: const NeverScrollableScrollPhysics(),
//                 children: _tabDefs.map((tab) {
//                   return _OrderTabView(
//                     orders: _filtered(tab['filter']),
//                     colors: colors,
//                     onRefresh: () => _loadOrders(refresh: true),
//                     onTap: (o) => _openDetail(o),
//                     onReorder: (o) => _buyAgain(o),
//                   );
//                 }).toList(),
//               ),
//       ),
//     );
//   }

//   Widget _buildAppBar(AppColors colors) {
//     return SliverAppBar(
//       pinned: true,
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       elevation: 0,
//       centerTitle: true,
//       scrolledUnderElevation: 0,
//       surfaceTintColor: Colors.transparent,
//       title: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             'my_orders'.tr,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w800,
//               color: colors.text1,
//               letterSpacing: -0.5,
//             ),
//           ),
//           Text(
//             '${_orders.length} ${'orders'.tr}',
//             style: TextStyle(fontSize: 12, color: colors.text3),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTabBar(AppColors colors) {
//     return SliverPersistentHeader(
//       pinned: true,
//       delegate: _TabBarDelegate(
//         color: Theme.of(context).scaffoldBackgroundColor,
//         tabBar: TabBar(
//           controller: _tabController,
//           isScrollable: true,
//           tabAlignment: TabAlignment.start,
//           padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
//           indicator: BoxDecoration(
//             color: colors.accent,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           indicatorSize: TabBarIndicatorSize.tab,
//           labelColor: Colors.white,
//           unselectedLabelColor: colors.text3,
//           labelStyle: const TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w700,
//           ),
//           unselectedLabelStyle: const TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w500,
//           ),
//           dividerColor: Colors.transparent,
//           tabs: _tabDefs
//               .map(
//                 (t) => Tab(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 2),
//                     child: Text(t['label']!.tr),
//                   ),
//                 ),
//               )
//               .toList(),
//         ),
//       ),
//     );
//   }

//   // ── Skeleton list ────────────────────────────────────────────

//   Widget _buildSkeletons(AppColors c) {
//     return ListView.builder(
//       padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
//       itemCount: 4,
//       itemBuilder: (_, __) => _SkeletonOrderCard(colors: c),
//     );
//   }

//   Widget _empty(BuildContext context, AppColors colors) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 96,
//             height: 96,
//             decoration: BoxDecoration(
//               color: colors.surface2,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(Icons.inbox_outlined, size: 44, color: colors.text3),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'No orders here',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w700,
//               color: colors.text1,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'You haven\'t placed any orders\nin this category yet.',
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 14, color: colors.text3, height: 1.5),
//           ),
//           const SizedBox(height: 28),
//           GestureDetector(
//             onTap: () => MainScreen.switchToHome(context),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
//               decoration: BoxDecoration(
//                 color: colors.accent,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(
//                     Icons.shopping_bag_outlined,
//                     color: Colors.white,
//                     size: 18,
//                   ),
//                   SizedBox(width: 8),
//                   Text(
//                     'go_shopping'.tr,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 15,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//   // ── Navigation ───────────────────────────────────────────────

//   void _openDetail(Order order) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
//     );
//   }

//   void _showReorderSnack(Order order) {
//     // HapticFeedback.mediumImpact();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('${order.items.length} item(s) added to cart!'),
//         backgroundColor: context.colors.accent,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         action: SnackBarAction(
//           label: 'View Cart',
//           textColor: Colors.white,
//           onPressed: () {},
//         ),
//       ),
//     );
//   }
// }

// // ─── Tab Bar Delegate ─────────────────────────────────────────

// class _TabBarDelegate extends SliverPersistentHeaderDelegate {
//   final TabBar tabBar;
//   final Color color;
//   const _TabBarDelegate({required this.tabBar, required this.color});

//   @override
//   double get minExtent => tabBar.preferredSize.height + 10;
//   @override
//   double get maxExtent => tabBar.preferredSize.height + 10;

//   @override
//   Widget build(_, double shrink, bool overlaps) =>
//       Container(color: color, alignment: Alignment.centerLeft, child: tabBar);

//   @override
//   bool shouldRebuild(_TabBarDelegate old) =>
//       old.tabBar != tabBar || old.color != color;
// }

// // ═══════════════════════════════════════════════════════════════
// // ORDER TAB VIEW
// // ═══════════════════════════════════════════════════════════════

// class _OrderTabView extends StatelessWidget {
//   final List<Order> orders;
//   final AppColors colors;
//   final Future<void> Function() onRefresh;
//   final void Function(Order) onTap;
//   final void Function(Order) onReorder;

//   const _OrderTabView({
//     required this.orders,
//     required this.colors,
//     required this.onRefresh,
//     required this.onTap,
//     required this.onReorder,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (orders.isEmpty) return _emptyState(context);

//     return RefreshIndicator(
//       onRefresh: onRefresh,
//       color: colors.accent,
//       child: ListView.builder(
//         padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
//         itemCount: orders.length,
//         itemBuilder: (_, i) => _OrderCard(
//           order: orders[i],
//           colors: colors,
//           onTap: () => onTap(orders[i]),
//           onReorder: () => onReorder(orders[i]),
//         ),
//       ),
//     );
//   }

//   Widget _emptyState(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 96,
//             height: 96,
//             decoration: BoxDecoration(
//               color: colors.surface2,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(Icons.inbox_outlined, size: 44, color: colors.text3),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'No orders here',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w700,
//               color: colors.text1,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'You haven\'t placed any orders\nin this category yet.',
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 14, color: colors.text3, height: 1.5),
//           ),
//           const SizedBox(height: 28),
//           GestureDetector(
//             onTap: () => MainScreen.switchToHome(context),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
//               decoration: BoxDecoration(
//                 color: colors.accent,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(
//                     Icons.shopping_bag_outlined,
//                     color: Colors.white,
//                     size: 18,
//                   ),
//                   SizedBox(width: 8),
//                   Text(
//                     'go_shopping'.tr,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 15,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // ORDER CARD
// // ═══════════════════════════════════════════════════════════════

// class _OrderCard extends StatefulWidget {
//   final Order order;
//   final AppColors colors;
//   final VoidCallback onTap;
//   final VoidCallback onReorder;

//   const _OrderCard({
//     required this.order,
//     required this.colors,
//     required this.onTap,
//     required this.onReorder,
//   });

//   @override
//   State<_OrderCard> createState() => _OrderCardState();
// }

// class _OrderCardState extends State<_OrderCard>
//     with SingleTickerProviderStateMixin {
//   bool _expanded = false;
//   late final AnimationController _ctrl;
//   late final Animation<double> _anim;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 280),
//     );
//     _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   void _toggle() {
//     // HapticFeedback.selectionClick();
//     setState(() => _expanded = !_expanded);
//     _expanded ? _ctrl.forward() : _ctrl.reverse();
//   }

//   String _fmtDate(String raw) {
//     try {
//       final d = DateTime.parse(raw);
//       const m = [
//         '',
//         'Jan',
//         'Feb',
//         'Mar',
//         'Apr',
//         'May',
//         'Jun',
//         'Jul',
//         'Aug',
//         'Sep',
//         'Oct',
//         'Nov',
//         'Dec',
//       ];
//       return '${m[d.month]} ${d.day}, ${d.year}';
//     } catch (_) {
//       return raw;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final order = widget.order;
//     final c = widget.colors;
//     final style = _statusStyle(order.status);
//     final first = order.items.isNotEmpty ? order.items.first : null;
//     final isCancelled = order.status.toLowerCase() == 'cancelled';
//     final isDelivered = order.status.toLowerCase() == 'completed';

//     return GestureDetector(
//       onTap: widget.onTap,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 14),
//         decoration: BoxDecoration(
//           color: c.cardBg,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: c.border.withOpacity(0.15)),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.04),
//               blurRadius: 16,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Header ─────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 14, 14, 0),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           '#${order.id}',
//                           style: TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w700,
//                             color: c.text1,
//                             letterSpacing: -0.2,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           _fmtDate(order.createdAt),
//                           style: TextStyle(fontSize: 11, color: c.text3),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Status chip
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 5,
//                     ),
//                     decoration: BoxDecoration(
//                       color: style.bgColor,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(style.icon, size: 12, color: style.color),
//                         const SizedBox(width: 4),
//                         Text(
//                           style.label,
//                           style: TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w700,
//                             color: style.color,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 12),
//             Divider(height: 1, color: c.border.withOpacity(0.15)),
//             const SizedBox(height: 12),

//             // ── First item ──────────────────────────────────
//             if (first != null)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   children: [
//                     // Image
//                     Container(
//                       width: 72,
//                       height: 72,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: c.border, width: .5),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(8),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(12),
//                           child: Image.network(
//                             first.image,
//                             fit: BoxFit.contain,
//                             errorBuilder: (_, __, ___) =>
//                                 Icon(Icons.image_outlined, color: c.text3),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             first.name,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w600,
//                               color: c.text1,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Row(
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 7,
//                                   vertical: 2,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: c.surface,
//                                   borderRadius: BorderRadius.circular(6),
//                                 ),
//                                 child: Text(
//                                   'Qty: ${first.qty}',
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     color: c.text2,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                               if (order.items.length > 1) ...[
//                                 const SizedBox(width: 6),
//                                 Text(
//                                   '+${order.items.length - 1} more',
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     color: c.text3,
//                                   ),
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     Text(
//                       '\$${order.total}',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w800,
//                         color: c.text1,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//             const SizedBox(height: 12),

//             // ── Expandable extra items ──────────────────────
//             if (order.items.length > 1) ...[
//               SizeTransition(
//                 sizeFactor: _anim,
//                 child: Column(
//                   children: [
//                     Divider(height: 1, color: c.surface2),
//                     ...order.items
//                         .skip(1)
//                         .map(
//                           (item) => Padding(
//                             padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
//                             child: Row(
//                               children: [
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(8),
//                                   child: Image.network(
//                                     item.image,
//                                     width: 44,
//                                     height: 44,
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (_, __, ___) => Container(
//                                       width: 44,
//                                       height: 44,
//                                       color: c.surface2,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 10),
//                                 Expanded(
//                                   child: Text(
//                                     item.name,
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w500,
//                                       color: c.text2,
//                                     ),
//                                   ),
//                                 ),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: [
//                                     Text(
//                                       '\$${item.finalPrice}',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.w600,
//                                         color: c.text1,
//                                       ),
//                                     ),
//                                     if (item.price != item.finalPrice)
//                                       Text(
//                                         '\$${item.price}',
//                                         style: TextStyle(
//                                           fontSize: 10,
//                                           color: c.text3,
//                                           decoration:
//                                               TextDecoration.lineThrough,
//                                         ),
//                                       ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                     const SizedBox(height: 10),
//                   ],
//                 ),
//               ),
//               GestureDetector(
//                 onTap: _toggle,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Row(
//                     children: [
//                       Text(
//                         _expanded ? 'show_less'.tr : 'show_all_items'.tr,
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                           color: c.text2,
//                         ),
//                       ),
//                       AnimatedRotation(
//                         turns: _expanded ? 0.5 : 0,
//                         duration: const Duration(milliseconds: 280),
//                         child: Icon(
//                           Icons.keyboard_arrow_down_rounded,
//                           size: 16,
//                           color: c.text2,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],

//             const SizedBox(height: 14),
//             Divider(height: 1, color: c.border.withOpacity(0.15)),

//             // ── Action buttons ──────────────────────────────
//             Padding(
//               padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
//               child: Row(
//                 children: [
//                   if (!isCancelled && !isDelivered) ...[
//                     Expanded(
//                       child: _CardButton(
//                         label: 'track_order'.tr,
//                         icon: Icons.local_shipping_outlined,
//                         isPrimary: true,
//                         colors: c,
//                         onTap: widget.onTap,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                   ],
//                   Expanded(
//                     child: _CardButton(
//                       label: isDelivered ? 'buy_again'.tr : 'details'.tr,
//                       icon: isDelivered
//                           ? Icons.refresh_rounded
//                           : Icons.receipt_long_outlined,
//                       isPrimary: isDelivered,
//                       colors: c,
//                       onTap: isDelivered ? widget.onReorder : widget.onTap,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─── Card Button ─────────────────────────────────────────────

// class _CardButton extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final bool isPrimary;
//   final AppColors colors;
//   final VoidCallback onTap;

//   const _CardButton({
//     required this.label,
//     required this.icon,
//     required this.isPrimary,
//     required this.colors,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         decoration: BoxDecoration(
//           color: isPrimary ? colors.accent : colors.surface,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               size: 15,
//               color: isPrimary ? Colors.white : colors.text2,
//             ),
//             const SizedBox(width: 6),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w700,
//                 color: isPrimary ? Colors.white : colors.text2,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // SKELETON ORDER CARD  (uses AppColors)
// // ═══════════════════════════════════════════════════════════════

// class _SkeletonOrderCard extends StatefulWidget {
//   final AppColors colors;
//   const _SkeletonOrderCard({required this.colors});

//   @override
//   State<_SkeletonOrderCard> createState() => _SkeletonOrderCardState();
// }

// class _SkeletonOrderCardState extends State<_SkeletonOrderCard>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _ctrl;
//   late final Animation<double> _anim;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1100),
//     )..repeat(reverse: true);
//     _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   Widget _box(double w, double h, {double r = 8}) {
//     final c = widget.colors;
//     return AnimatedBuilder(
//       animation: _anim,
//       builder: (_, __) => Container(
//         width: w,
//         height: h,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(r),
//           color: Color.lerp(c.surface, c.surface2, _anim.value),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final c = widget.colors;
//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: c.cardBg,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: c.border.withOpacity(0.12)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header row
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [_box(110, 14), _box(72, 26, r: 13)],
//           ),
//           const SizedBox(height: 6),
//           _box(70, 10),
//           const SizedBox(height: 18),

//           // Product row
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _box(64, 64, r: 12),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _box(double.infinity, 13),
//                     const SizedBox(height: 7),
//                     _box(90, 10),
//                     const SizedBox(height: 7),
//                     _box(50, 10),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 12),
//               _box(48, 18, r: 6),
//             ],
//           ),
//           const SizedBox(height: 18),

//           // Action buttons
//           Row(
//             children: [
//               Expanded(child: _box(double.infinity, 38, r: 12)),
//               const SizedBox(width: 8),
//               Expanded(child: _box(double.infinity, 38, r: 12)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // ORDER DETAIL SCREEN
// // ═══════════════════════════════════════════════════════════════

// class OrderDetailScreen extends StatefulWidget {
//   final Order order;
//   const OrderDetailScreen({super.key, required this.order});

//   @override
//   State<OrderDetailScreen> createState() => _OrderDetailScreenState();
// }

// class _OrderDetailScreenState extends State<OrderDetailScreen>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _ctrl;
//   late final Animation<double> _fade;
//   late final Animation<Offset> _slide;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 480),
//     );
//     _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
//     _slide = Tween<Offset>(
//       begin: const Offset(0, 0.06),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
//     _ctrl.forward();
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final c = context.colors;
//     final order = widget.order;
//     final style = _statusStyle(order.status);
//     final isCancelled = order.status.toLowerCase() == 'cancelled';

//     return Scaffold(
//       backgroundColor: c.background,
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//         elevation: 0,
//         scrolledUnderElevation: 0,
//         surfaceTintColor: Colors.transparent,

//         leading: GestureDetector(
//           onTap: () => Navigator.pop(context),
//           child: Container(
//             margin: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: c.cardBg,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: c.border.withOpacity(0.2)),
//             ),
//             child: Icon(CupertinoIcons.back, size: 16, color: c.text2),
//           ),
//         ),
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               '#${order.id}',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//                 color: c.text1,
//               ),
//             ),
//             Text(
//               '${order.items.length} item(s)',
//               style: TextStyle(
//                 fontSize: 11,
//                 color: c.text3,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 16),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: style.bgColor,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Text(
//                 style.label,
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w700,
//                   color: style.color,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: FadeTransition(
//         opacity: _fade,
//         child: SlideTransition(
//           position: _slide,
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Tracking timeline
//                 if (!isCancelled) ...[
//                   _Section(
//                     title: 'order_tracking'.tr,
//                     icon: Icons.route_rounded,
//                     colors: c,
//                     child: _TrackingTimeline(order: order, colors: c),
//                   ),
//                   const SizedBox(height: 14),
//                 ],

//                 // Items
//                 _Section(
//                   title: 'items_ordered'.tr,
//                   icon: CupertinoIcons.shopping_cart,
//                   colors: c,
//                   child: _DetailItemsList(order: order, colors: c),
//                 ),
//                 const SizedBox(height: 14),

//                 // Address
//                 _Section(
//                   title: 'delivery_address'.tr,
//                   icon: CupertinoIcons.location_solid,
//                   colors: c,
//                   child: _AddressRow(order: order, colors: c),
//                 ),
//                 const SizedBox(height: 14),

//                 // Payment
//                 _Section(
//                   title: 'payment_method'.tr,
//                   icon: CupertinoIcons.creditcard,
//                   colors: c,
//                   child: _PaymentRow(order: order, colors: c),
//                 ),
//                 const SizedBox(height: 14),

//                 // Price summary
//                 _Section(
//                   title: 'order_summary'.tr,
//                   icon: CupertinoIcons.doc_text_fill,
//                   colors: c,
//                   child: _PriceSummary(order: order, colors: c),
//                 ),
//                 const SizedBox(height: 24),

//                 // CTA
//                 _DetailActions(order: order, colors: c),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─── Section wrapper ──────────────────────────────────────────

// class _Section extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final AppColors colors;
//   final Widget child;

//   const _Section({
//     required this.title,
//     required this.icon,
//     required this.colors,
//     required this.child,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final c = colors;
//     return Container(
//       decoration: BoxDecoration(
//         color: c.cardBg,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: c.border.withOpacity(0.12)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 12,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
//             child: Row(
//               children: [
//                 Container(
//                   width: 30,
//                   height: 30,
//                   decoration: BoxDecoration(
//                     color: c.surface,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(icon, size: 16, color: c.text2),
//                 ),
//                 const SizedBox(width: 10),
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w700,
//                     color: c.text1,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Divider(height: 1, color: c.border.withOpacity(0.12)),
//           Padding(padding: const EdgeInsets.all(16), child: child),
//         ],
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // TRACKING TIMELINE
// // ═══════════════════════════════════════════════════════════════

// class _TrackingTimeline extends StatelessWidget {
//   final Order order;
//   final AppColors colors;
//   _TrackingTimeline({required this.order, required this.colors});

//   final _steps = [
//     (
//       label: 'order_placed'.tr,
//       icon: CupertinoIcons.shopping_cart,
//       sub: 'Confirmed',
//     ),
//     (
//       label: 'packed'.tr,
//       icon: CupertinoIcons.archivebox,
//       sub: 'Being prepared',
//     ),
//     // (label: 'Shipped', icon: Icons.local_shipping_outlined, sub: 'On the way'),
//     (
//       label: 'delivered'.tr,
//       icon: CupertinoIcons.check_mark_circled,
//       sub: 'Completed',
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final currentStep = _statusStyle(order.status).trackingStep;
//     final c = colors;

//     return Column(
//       children: List.generate(_steps.length, (i) {
//         final isDone = i < currentStep;
//         final isCurrent = i == currentStep;
//         final isLast = i == _steps.length - 1;
//         final step = _steps[i];

//         return IntrinsicHeight(
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Timeline column
//               SizedBox(
//                 width: 36,
//                 child: Column(
//                   children: [
//                     Container(
//                       width: 36,
//                       height: 36,
//                       decoration: BoxDecoration(
//                         color: isDone ? c.accent : c.surface2,
//                         shape: BoxShape.circle,
//                         boxShadow: isCurrent
//                             ? [
//                                 BoxShadow(
//                                   color: c.accent.withOpacity(0.35),
//                                   blurRadius: 10,
//                                   offset: const Offset(0, 3),
//                                 ),
//                               ]
//                             : null,
//                       ),
//                       child: Icon(
//                         step.icon,
//                         size: 16,
//                         color: isDone ? Colors.white : c.text3,
//                       ),
//                     ),
//                     if (!isLast)
//                       Expanded(
//                         child: Container(
//                           width: 2,
//                           margin: const EdgeInsets.symmetric(vertical: 4),
//                           decoration: BoxDecoration(
//                             color: i < currentStep ? c.accent : c.surface2,
//                             borderRadius: BorderRadius.circular(1),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 14),
//               // Content
//               Expanded(
//                 child: Padding(
//                   padding: EdgeInsets.only(bottom: isLast ? 0 : 22, top: 6),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         step.label,
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: isCurrent
//                               ? FontWeight.w700
//                               : FontWeight.w500,
//                           color: isDone ? c.text1 : c.text3,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         isDone ? step.sub : 'Waiting...',
//                         style: TextStyle(
//                           fontSize: 11,
//                           color: isDone ? c.text3 : c.surface2,
//                         ),
//                       ),
//                       if (isCurrent) ...[
//                         const SizedBox(height: 6),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 3,
//                           ),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFF0FDF4),
//                             borderRadius: BorderRadius.circular(6),
//                             border: Border.all(color: const Color(0xFF86EFAC)),
//                           ),
//                           child: Text(
//                             'current_status'.tr,
//                             style: TextStyle(
//                               fontSize: 10,
//                               color: Color(0xFF16A34A),
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       }),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // DETAIL WIDGETS
// // ═══════════════════════════════════════════════════════════════

// class _DetailItemsList extends StatelessWidget {
//   final Order order;
//   final AppColors colors;
//   const _DetailItemsList({required this.order, required this.colors});

//   @override
//   Widget build(BuildContext context) {
//     final c = colors;
//     return Column(
//       children: order.items.asMap().entries.map((e) {
//         final i = e.key;
//         final item = e.value;
//         final hasDiscount =
//             item.discount != null &&
//             item.discount.toString().isNotEmpty &&
//             item.discount.toString() != 'null' &&
//             item.discount.toString() != '0';

//         return Padding(
//           padding: EdgeInsets.only(bottom: i < order.items.length - 1 ? 14 : 0),
//           child: Row(
//             children: [
//               Container(
//                 width: 72,
//                 height: 72,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: c.border, width: .5),
//                 ),
//                 clipBehavior: Clip.antiAlias,
//                 child: Padding(
//                   padding: const EdgeInsets.all(8),
//                   child: Image.network(
//                     item.image,
//                     fit: BoxFit.contain,
//                     errorBuilder: (_, __, ___) =>
//                         Icon(Icons.image_outlined, color: c.text3),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       item.name,
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                         color: c.text1,
//                       ),
//                     ),
//                     const SizedBox(height: 3),
//                     Text(
//                       'Qty: ${item.qty}',
//                       style: TextStyle(fontSize: 11, color: c.text3),
//                     ),
//                     if (hasDiscount) ...[
//                       const SizedBox(height: 3),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 6,
//                           vertical: 2,
//                         ),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFFEF3C7),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Text(
//                           '${item.discount}% off',
//                           style: const TextStyle(
//                             fontSize: 10,
//                             color: Color(0xFFF59E0B),
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     '\$${item.finalPrice}',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w700,
//                       color: c.text1,
//                     ),
//                   ),
//                   if (item.price != item.finalPrice)
//                     Text(
//                       '\$${item.price}',
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: c.text3,
//                         decoration: TextDecoration.lineThrough,
//                       ),
//                     ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }
// }

// // ─── Address ─────────────────────────────────────────────────

// class _AddressRow extends StatelessWidget {
//   final Order order;
//   final AppColors colors;
//   const _AddressRow({required this.order, required this.colors});

//   @override
//   Widget build(BuildContext context) {
//     final c = colors;
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: c.accentLight,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(Icons.location_on_rounded, size: 20, color: c.accent),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'delivery_address'.tr,
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: c.text3,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 3),
//               Text(
//                 order.address,
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                   color: c.text1,
//                 ),
//               ),
//               const SizedBox(height: 3),
//               Text(order.phone, style: TextStyle(fontSize: 11, color: c.text3)),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ─── Payment ─────────────────────────────────────────────────

// class _PaymentRow extends StatelessWidget {
//   final Order order;
//   final AppColors colors;
//   const _PaymentRow({required this.order, required this.colors});

//   bool get _isCash => order.paymentMethod.toUpperCase().contains('cash');

//   @override
//   Widget build(BuildContext context) {
//     final c = colors;
//     final isPaid = order.paymentStatus.toUpperCase().contains('paid');
//     final statusLabel = order.paymentStatus.isNotEmpty
//         ? order.paymentStatus[0].toUpperCase() +
//               order.paymentStatus.substring(1)
//         : order.paymentStatus;

//     return Row(
//       children: [
//         Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: _isCash ? const Color(0xFFFEF3C7) : c.accentLight,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(
//             _isCash ? Icons.payments_outlined : Icons.credit_card_rounded,
//             size: 20,
//             color: _isCash ? const Color(0xFFF59E0B) : c.accent,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'payment_method'.tr,
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: c.text3,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 3),
//               Text(
//                 order.paymentMethod.toUpperCase(),
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                   color: c.text1,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//           decoration: BoxDecoration(
//             color: isPaid ? const Color(0xFFF0FDF4) : Colors.green,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Text(
//             statusLabel,
//             style: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w700,
//               color: isPaid ? const Color(0xFF16A34A) : Colors.white,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ─── Price Summary ────────────────────────────────────────────

// class _PriceSummary extends StatelessWidget {
//   final Order order;
//   final AppColors colors;
//   const _PriceSummary({required this.order, required this.colors});

//   Widget _row(
//     AppColors c,
//     String label,
//     String value, {
//     bool bold = false,
//     Color? valueColor,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 13,
//               color: bold ? c.text1 : c.text3,
//               fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 13,
//               fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
//               color: valueColor ?? (bold ? c.text1 : c.text2),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final c = colors;
//     final subtotal = order.items.fold(0.0, (sum, item) {
//       final price = double.tryParse(item.finalPrice.toString()) ?? 0.0;
//       return sum + price * item.qty;
//     });
//     final grandTotal = double.tryParse(order.total.toString()) ?? subtotal;
//     final shipping = grandTotal - subtotal;

//     return Column(
//       children: [
//         // _row(c, 'subtotal'.tr, '\$${subtotal.toStringAsFixed(2)}'),
//         // if (shipping > 0.001)
//         // _row(c, 'shipping'.tr, '\$${shipping.toStringAsFixed(2)}'),
//         // Divider(height: 16, color: c.border.withValues(alpha: 0.15)),
//         _row(c, 'total'.tr, '\$${grandTotal.toStringAsFixed(2)}', bold: true),
//       ],
//     );
//   }
// }

// // ─── Detail CTA Buttons ───────────────────────────────────────

// class _DetailActions extends StatelessWidget {
//   final Order order;
//   final AppColors colors;
//   const _DetailActions({required this.order, required this.colors});

//   @override
//   Widget build(BuildContext context) {
//     final c = colors;
//     final status = order.status.toLowerCase();

//     return Column(
//       children: [
//         if (status == 'completed')
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: () {
//                 // HapticFeedback.mediumImpact();
//                 Navigator.pop(context);
//               },
//               icon: const Icon(Icons.refresh_rounded, size: 18),
//               label: const Text(
//                 'Buy Again',
//                 style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: c.accent,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 elevation: 0,
//               ),
//             ),
//           ),
//         // if (status == 'pending')
//         //   SizedBox(
//         //     width: double.infinity,
//         //     child: OutlinedButton.icon(
//         //       onPressed: () {},
//         //       icon: const Icon(
//         //         Icons.cancel_outlined,
//         //         size: 18,
//         //         color: Color(0xFFEF4444),
//         //       ),
//         //       label: const Text(
//         //         'Cancel Order',
//         //         style: TextStyle(
//         //           color: Color(0xFFEF4444),
//         //           fontWeight: FontWeight.w700,
//         //           fontSize: 15,
//         //         ),
//         //       ),
//         //       style: OutlinedButton.styleFrom(
//         //         padding: const EdgeInsets.symmetric(vertical: 16),
//         //         side: const BorderSide(color: Color(0xFFEF4444)),
//         //         shape: RoundedRectangleBorder(
//         //           borderRadius: BorderRadius.circular(16),
//         //         ),
//         //       ),
//         //     ),
//         //   ),
//         if (status == 'shipping')
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: () {},
//               icon: const Icon(Icons.local_shipping_outlined, size: 18),
//               label: const Text(
//                 'Live Tracking',
//                 style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF3B82F6),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 elevation: 0,
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }

import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import '../../models/my_orders_model.dart';
import '../../services/api_service.dart';
import '../main/main_screen.dart';
import '../theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════
// STATUS STYLE HELPER
// ═══════════════════════════════════════════════════════════════

class _StatusStyle {
  final String label;
  final Color color;
  final Color bgColor;
  final IconData icon;
  final int trackingStep; // -1 = cancelled

  const _StatusStyle({
    required this.label,
    required this.color,
    required this.bgColor,
    required this.icon,
    required this.trackingStep,
  });
}

_StatusStyle _statusStyle(String status) {
  switch (status.toLowerCase().trim()) {
    case 'pending':
      return _StatusStyle(
        label: 'pending'.tr,
        color: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFFEF3C7),
        icon: Icons.schedule_rounded,
        trackingStep: 0,
      );
    case 'processing':
      return _StatusStyle(
        label: 'processing'.tr,
        color: const Color(0xFF8B5CF6),
        bgColor: const Color(0xFFEDE9FE),
        icon: Icons.inventory_2_outlined,
        trackingStep: 1,
      );
    case 'shipping':
      return _StatusStyle(
        label: 'shipping'.tr,
        color: const Color(0xFF3B82F6),
        bgColor: const Color(0xFFDBEAFE),
        icon: Icons.local_shipping_outlined,
        trackingStep: 2,
      );
    case 'completed':
    case 'delivered':
      return _StatusStyle(
        label: 'completed'.tr,
        color: const Color(0xFF10B981),
        bgColor: const Color(0xFFD1FAE5),
        icon: Icons.check_circle_outline_rounded,
        trackingStep: 3,
      );
    case 'cancelled':
      return _StatusStyle(
        label: 'cancelled'.tr,
        color: const Color(0xFFEF4444),
        bgColor: const Color(0xFFFEE2E2),
        icon: Icons.cancel_outlined,
        trackingStep: -1,
      );
    default:
      return _StatusStyle(
        label: status,
        color: const Color(0xFF888888),
        bgColor: const Color(0xFFF3F3F3),
        icon: Icons.help_outline_rounded,
        trackingStep: 0,
      );
  }
}

// ═══════════════════════════════════════════════════════════════
// ORDERS SCREEN
// ═══════════════════════════════════════════════════════════════

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final ApiService _api = ApiService();
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _error;

  static const _tabDefs = [
    {'label': 'all', 'filter': null},
    {'label': 'pending', 'filter': 'pending'},
    {'label': 'processing', 'filter': 'processing'},
    {'label': 'completed', 'filter': 'completed'},
    {'label': 'cancelled', 'filter': 'cancelled'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabDefs.length, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders({bool refresh = false}) async {
    if (!refresh) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final result = await _api.fetchMyOrders();
      if (mounted) {
        setState(() {
          _orders = result.orders;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  List<Order> _filtered(Object? filter) {
    if (filter == null) return _orders;
    final f = filter.toString().toLowerCase();
    return _orders.where((o) {
      final status = o.status.toLowerCase().trim();
      if (f == 'completed') {
        return status == 'completed' || status == 'delivered';
      }
      return status == f;
    }).toList();
  }

  void _openDetail(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
    );
  }

  void _buyAgain(Order order) {
    HapticFeedback.mediumImpact();
    // Navigate to checkout with order items — wire up to your CheckoutScreen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => CheckoutScreen(
    //       fromCart: false,
    //       items: order.items.map((item) => OrderItem(
    //         id: item.productId?.toString() ?? '',
    //         name: item.name,
    //         imageUrl: item.image,
    //         unitPrice: double.parse(item.finalPrice),
    //         quantity: item.qty,
    //       )).toList(),
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          _buildAppBar(colors),
          _buildTabBar(colors),
        ],
        body: _isLoading
            ? _buildSkeletons(colors)
            : _error != null
            ? _buildEmpty(context, colors)
            : TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: _tabDefs.map((tab) {
                  return _OrderTabView(
                    orders: _filtered(tab['filter']),
                    colors: colors,
                    onRefresh: () => _loadOrders(refresh: true),
                    onTap: _openDetail,
                    onReorder: _buyAgain,
                  );
                }).toList(),
              ),
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────

  Widget _buildAppBar(AppColors colors) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'my_orders'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colors.text1,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            '${_orders.length} ${'orders'.tr}',
            style: TextStyle(fontSize: 12, color: colors.text3),
          ),
        ],
      ),
    );
  }

  // ── Tab Bar ──────────────────────────────────────────────────

  Widget _buildTabBar(AppColors colors) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        color: Theme.of(context).scaffoldBackgroundColor,
        tabBar: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          indicator: BoxDecoration(
            color: colors.accent,
            borderRadius: BorderRadius.circular(12),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: colors.text3,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          dividerColor: Colors.transparent,
          tabs: _tabDefs.map((t) {
            return Tab(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(t['label']!.toString().tr),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Skeleton list ────────────────────────────────────────────

  Widget _buildSkeletons(AppColors c) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: 4,
      itemBuilder: (_, __) => _SkeletonOrderCard(colors: c),
    );
  }

  // ── Empty / Error ────────────────────────────────────────────

  Widget _buildEmpty(BuildContext context, AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: colors.surface2,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inbox_outlined, size: 44, color: colors.text3),
          ),
          const SizedBox(height: 20),
          Text(
            'No orders here',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colors.text1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You haven't placed any orders\nin this category yet.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: colors.text3, height: 1.5),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => MainScreen.switchToHome(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: colors.accent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'go_shopping'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
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

// ─── Tab Bar Delegate ─────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color color;

  const _TabBarDelegate({required this.tabBar, required this.color});

  @override
  double get minExtent => tabBar.preferredSize.height + 10;

  @override
  double get maxExtent => tabBar.preferredSize.height + 10;

  @override
  Widget build(_, double shrink, bool overlaps) =>
      Container(color: color, alignment: Alignment.centerLeft, child: tabBar);

  @override
  bool shouldRebuild(_TabBarDelegate old) =>
      old.tabBar != tabBar || old.color != color;
}

// ═══════════════════════════════════════════════════════════════
// ORDER TAB VIEW
// ═══════════════════════════════════════════════════════════════

class _OrderTabView extends StatelessWidget {
  final List<Order> orders;
  final AppColors colors;
  final Future<void> Function() onRefresh;
  final void Function(Order) onTap;
  final void Function(Order) onReorder;

  const _OrderTabView({
    required this.orders,
    required this.colors,
    required this.onRefresh,
    required this.onTap,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) return _emptyState(context);

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: colors.accent,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: orders.length,
        itemBuilder: (_, i) => _OrderCard(
          order: orders[i],
          colors: colors,
          onTap: () => onTap(orders[i]),
          onReorder: () => onReorder(orders[i]),
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: colors.surface2,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inbox_outlined, size: 44, color: colors.text3),
          ),
          const SizedBox(height: 20),
          Text(
            'No orders here',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colors.text1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You haven't placed any orders\nin this category yet.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: colors.text3, height: 1.5),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => MainScreen.switchToHome(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: colors.accent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'go_shopping'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
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

// ═══════════════════════════════════════════════════════════════
// ORDER CARD
// ═══════════════════════════════════════════════════════════════

class _OrderCard extends StatefulWidget {
  final Order order;
  final AppColors colors;
  final VoidCallback onTap;
  final VoidCallback onReorder;
  

  const _OrderCard({
    required this.order,
    required this.colors,
    required this.onTap,
    required this.onReorder,
  });

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.selectionClick();
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  String _fmtDate(String raw) {
    try {
      final d = DateTime.parse(raw);
      const m = [
        '',
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
      return '${m[d.month]} ${d.day}, ${d.year}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final c = widget.colors;
    final style = _statusStyle(order.status);
    final first = order.items.isNotEmpty ? order.items.first : null;
    final isCancelled = order.status.toLowerCase() == 'cancelled';
    final isDelivered =
        order.status.toLowerCase() == 'completed' ||
        order.status.toLowerCase() == 'delivered';

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: c.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.border.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 14, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${order.id}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: c.text1,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _fmtDate(order.createdAt),
                          style: TextStyle(fontSize: 11, color: c.text3),
                        ),
                      ],
                    ),
                  ),
                  // Status chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: style.bgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(style.icon, size: 12, color: style.color),
                        const SizedBox(width: 4),
                        Text(
                          style.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: style.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Divider(height: 1, color: c.border.withOpacity(0.15)),
            const SizedBox(height: 12),

            // ── First item ──────────────────────────────────
            if (first != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: c.border, width: .5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            first.image,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                Icon(Icons.image_outlined, color: c.text3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            first.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: c.text1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: c.surface,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Qty: ${first.qty}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: c.text2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (order.items.length > 1) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '+${order.items.length - 1} more',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: c.text3,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${order.total}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: c.text1,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // ── Expandable extra items ──────────────────────
            if (order.items.length > 1) ...[
              SizeTransition(
                sizeFactor: _anim,
                child: Column(
                  children: [
                    Divider(height: 1, color: c.surface2),
                    ...order.items
                        .skip(1)
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.image,
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 44,
                                      height: 44,
                                      color: c.surface2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: c.text2,
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\$${item.finalPrice}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: c.text1,
                                      ),
                                    ),
                                    if (item.price != item.finalPrice)
                                      Text(
                                        '\$${item.price}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: c.text3,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _toggle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        _expanded ? 'show_less'.tr : 'show_all_items'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: c.text2,
                        ),
                      ),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 280),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: c.text2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 14),
            Divider(height: 1, color: c.border.withOpacity(0.15)),

            // ── Action buttons ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                children: [
                  if (!isCancelled && !isDelivered) ...[
                    Expanded(
                      child: _CardButton(
                        label: 'track_order'.tr,
                        icon: Icons.local_shipping_outlined,
                        isPrimary: true,
                        colors: c,
                        onTap: widget.onTap,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: _CardButton(
                      label: isDelivered ? 'buy_again'.tr : 'details'.tr,
                      icon: isDelivered
                          ? Icons.refresh_rounded
                          : Icons.receipt_long_outlined,
                      isPrimary: isDelivered,
                      colors: c,
                      onTap: isDelivered ? widget.onReorder : widget.onTap,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Card Button ─────────────────────────────────────────────

class _CardButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final AppColors colors;
  final VoidCallback onTap;

  const _CardButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary ? colors.accent : colors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isPrimary ? Colors.white : colors.text2,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isPrimary ? Colors.white : colors.text2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SKELETON ORDER CARD
// ═══════════════════════════════════════════════════════════════

class _SkeletonOrderCard extends StatefulWidget {
  final AppColors colors;
  const _SkeletonOrderCard({required this.colors});

  @override
  State<_SkeletonOrderCard> createState() => _SkeletonOrderCardState();
}

class _SkeletonOrderCardState extends State<_SkeletonOrderCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _box(double w, double h, {double r = 8}) {
    final c = widget.colors;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(r),
          color: Color.lerp(c.surface, c.surface2, _anim.value),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_box(110, 14), _box(72, 26, r: 13)],
          ),
          const SizedBox(height: 6),
          _box(70, 10),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _box(64, 64, r: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(double.infinity, 13),
                    const SizedBox(height: 7),
                    _box(90, 10),
                    const SizedBox(height: 7),
                    _box(50, 10),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _box(48, 18, r: 6),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _box(double.infinity, 38, r: 12)),
              const SizedBox(width: 8),
              Expanded(child: _box(double.infinity, 38, r: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ORDER DETAIL SCREEN
// ═══════════════════════════════════════════════════════════════

class OrderDetailScreen extends StatefulWidget {
  final Order order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final order = widget.order;
    final style = _statusStyle(order.status);
    final isCancelled = order.status.toLowerCase() == 'cancelled';

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: c.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.border.withOpacity(0.2)),
            ),
            child: Icon(CupertinoIcons.back, size: 16, color: c.text2),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '#${order.id}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: c.text1,
              ),
            ),
            Text(
              '${order.items.length} item(s)',
              style: TextStyle(
                fontSize: 11,
                color: c.text3,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: style.bgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                style.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: style.color,
                ),
              ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tracking timeline
                if (!isCancelled) ...[
                  _Section(
                    title: 'order_tracking'.tr,
                    icon: Icons.route_rounded,
                    colors: c,
                    child: _TrackingTimeline(order: order, colors: c),
                  ),
                  const SizedBox(height: 14),
                ],

                // Items
                _Section(
                  title: 'items_ordered'.tr,
                  icon: CupertinoIcons.shopping_cart,
                  colors: c,
                  child: _DetailItemsList(order: order, colors: c),
                ),
                const SizedBox(height: 14),

                // Address
                _Section(
                  title: 'delivery_address'.tr,
                  icon: CupertinoIcons.location_solid,
                  colors: c,
                  child: _AddressRow(order: order, colors: c),
                ),
                const SizedBox(height: 14),

                // Payment
                _Section(
                  title: 'payment_method'.tr,
                  icon: CupertinoIcons.creditcard,
                  colors: c,
                  child: _PaymentRow(order: order, colors: c),
                ),
                const SizedBox(height: 14),

                // Price summary
                _Section(
                  title: 'order_summary'.tr,
                  icon: CupertinoIcons.doc_text_fill,
                  colors: c,
                  child: _PriceSummary(order: order, colors: c),
                ),
                const SizedBox(height: 24),

                // CTA
                _DetailActions(order: order, colors: c),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Section wrapper ──────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final AppColors colors;
  final Widget child;

  const _Section({
    required this.title,
    required this.icon,
    required this.colors,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Container(
      decoration: BoxDecoration(
        color: c.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: c.text2),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: c.text1,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: c.border.withOpacity(0.12)),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TRACKING TIMELINE
// ═══════════════════════════════════════════════════════════════

class _TrackingTimeline extends StatelessWidget {
  final Order order;
  final AppColors colors;

  const _TrackingTimeline({required this.order, required this.colors});

  @override
  Widget build(BuildContext context) {
    final currentStep = _statusStyle(order.status).trackingStep;
    final c = colors;

    final steps = [
      (
        label: 'order_placed'.tr,
        icon: CupertinoIcons.shopping_cart,
        sub: 'Confirmed',
      ),
      (
        label: 'packed'.tr,
        icon: CupertinoIcons.archivebox,
        sub: 'Being prepared',
      ),
      (
        label: 'delivered'.tr,
        icon: CupertinoIcons.check_mark_circled,
        sub: 'Completed',
      ),
    ];

    return Column(
      children: List.generate(steps.length, (i) {
        final isDone = i < currentStep;
        final isCurrent = i == currentStep;
        final isLast = i == steps.length - 1;
        final step = steps[i];

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline column
              SizedBox(
                width: 36,
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDone || isCurrent ? c.accent : c.surface2,
                        shape: BoxShape.circle,
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: c.accent.withOpacity(0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        step.icon,
                        size: 16,
                        color: isDone || isCurrent ? Colors.white : c.text3,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: i < currentStep ? c.accent : c.surface2,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 22, top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isCurrent
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isDone || isCurrent ? c.text1 : c.text3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isDone ? step.sub : 'Waiting...',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDone ? c.text3 : c.surface2,
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          child: Text(
                            'current_status'.tr,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF16A34A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DETAIL WIDGETS
// ═══════════════════════════════════════════════════════════════

class _DetailItemsList extends StatelessWidget {
  final Order order;
  final AppColors colors;
  const _DetailItemsList({required this.order, required this.colors});

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Column(
      children: order.items.asMap().entries.map((e) {
        final i = e.key;
        final item = e.value;
        final pct = double.tryParse(item.discount ?? '') ?? 0.0;
        final hasDiscount = pct > 0;

        return Padding(
          padding: EdgeInsets.only(bottom: i < order.items.length - 1 ? 14 : 0),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: c.border, width: .5),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.network(
                    item.image,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.image_outlined, color: c.text3),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: c.text1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Qty: ${item.qty}',
                      style: TextStyle(fontSize: 11, color: c.text3),
                    ),
                    if (hasDiscount) ...[
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${item.discount}% off',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFFF59E0B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${item.finalPrice}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: c.text1,
                    ),
                  ),
                  if (item.price != item.finalPrice)
                    Text(
                      '\$${item.price}',
                      style: TextStyle(
                        fontSize: 11,
                        color: c.text3,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Address ─────────────────────────────────────────────────

class _AddressRow extends StatelessWidget {
  final Order order;
  final AppColors colors;
  const _AddressRow({required this.order, required this.colors});

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: c.accentLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.location_on_rounded, size: 20, color: c.accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'delivery_address'.tr,
                style: TextStyle(
                  fontSize: 11,
                  color: c.text3,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                order.address,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c.text1,
                ),
              ),
              const SizedBox(height: 3),
              Text(order.phone, style: TextStyle(fontSize: 11, color: c.text3)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Payment ─────────────────────────────────────────────────

class _PaymentRow extends StatelessWidget {
  final Order order;
  final AppColors colors;
  const _PaymentRow({required this.order, required this.colors});

  bool get _isCash => order.paymentMethod.toLowerCase().contains('cash');

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final isPaid =
        order.paymentStatus.toLowerCase().contains('paid') &&
        !order.paymentStatus.toLowerCase().contains('unpaid');
    final statusLabel = order.paymentStatus.isNotEmpty
        ? order.paymentStatus[0].toUpperCase() +
              order.paymentStatus.substring(1)
        : order.paymentStatus;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _isCash ? const Color(0xFFFEF3C7) : c.accentLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _isCash ? Icons.payments_outlined : Icons.credit_card_rounded,
            size: 20,
            color: _isCash ? const Color(0xFFF59E0B) : c.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'payment_method'.tr,
                style: TextStyle(
                  fontSize: 11,
                  color: c.text3,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                order.paymentMethod.toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c.text1,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isPaid ? const Color(0xFFF0FDF4) : const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            statusLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isPaid ? const Color(0xFF16A34A) : const Color(0xFFF59E0B),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Price Summary ────────────────────────────────────────────

class _PriceSummary extends StatelessWidget {
  final Order order;
  final AppColors colors;
  const _PriceSummary({required this.order, required this.colors});

  Widget _row(
    AppColors c,
    String label,
    String value, {
    bool bold = false,
    Color? valueColor,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: bold ? c.text1 : c.text3,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              color:
                  valueColor ??
                  (isDiscount
                      ? const Color(0xFF10B981)
                      : bold
                      ? c.text1
                      : c.text2),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = colors;

    final subtotal = order.items.fold(0.0, (sum, item) {
      final price = double.tryParse(item.price) ?? 0.0;
      return sum + price * item.qty;
    });

    final promoDiscount = double.tryParse(order.promotionDiscount) ?? 0.0;
    final couponDiscount = double.tryParse(order.couponDiscount) ?? 0.0;
    final grandTotal = double.tryParse(order.total) ?? subtotal;

    return Column(
      children: [
        _row(c, 'subtotal'.tr, '\$${subtotal.toStringAsFixed(2)}'),
        if (promoDiscount > 0)
          _row(
            c,
            'promotion'.tr,
            '-\$${promoDiscount.toStringAsFixed(2)}',
            isDiscount: true,
          ),
        if (couponDiscount > 0) ...[
          _row(
            c,
            order.couponCode != null
                ? 'Coupon (${order.couponCode})'
                : 'coupon'.tr,
            '-\$${couponDiscount.toStringAsFixed(2)}',
            isDiscount: true,
          ),
        ],
        Divider(height: 16, color: c.border.withOpacity(0.15)),
        _row(c, 'total'.tr, '\$${grandTotal.toStringAsFixed(2)}', bold: true),
      ],
    );
  }
}

// ─── Detail CTA Buttons ───────────────────────────────────────

class _DetailActions extends StatelessWidget {
  final Order order;
  final AppColors colors;
  const _DetailActions({required this.order, required this.colors});

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final status = order.status.toLowerCase();

    return Column(
      children: [
        if (status == 'completed' || status == 'delivered')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'buy_again'.tr,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: c.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
        if (status == 'shipping')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.local_shipping_outlined, size: 18),
              label: const Text(
                'Live Tracking',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
      ],
    );
  }
}
