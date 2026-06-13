// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// // ═══════════════════════════════════════════════════════════════
// // ENTRY POINT
// // ═══════════════════════════════════════════════════════════════

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Orders',
//       theme: ThemeData(
//         useMaterial3: true,
//         scaffoldBackgroundColor: const Color(0xFFF6F5F3),
//         fontFamily: 'SF Pro Display',
//       ),
//       home: const OrdersScreen(),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // MODELS
// // ═══════════════════════════════════════════════════════════════

// enum OrderStatus { pending, processing, shipping, delivered, cancelled }

// extension OrderStatusExt on OrderStatus {
//   String get label {
//     switch (this) {
//       case OrderStatus.pending:
//         return 'Pending';
//       case OrderStatus.processing:
//         return 'Processing';
//       case OrderStatus.shipping:
//         return 'Shipping';
//       case OrderStatus.delivered:
//         return 'Delivered';
//       case OrderStatus.cancelled:
//         return 'Cancelled';
//     }
//   }

//   Color get color {
//     switch (this) {
//       case OrderStatus.pending:
//         return const Color(0xFFF59E0B);
//       case OrderStatus.processing:
//         return const Color(0xFF8B5CF6);
//       case OrderStatus.shipping:
//         return const Color(0xFF3B82F6);
//       case OrderStatus.delivered:
//         return const Color(0xFF10B981);
//       case OrderStatus.cancelled:
//         return const Color(0xFFEF4444);
//     }
//   }

//   Color get bgColor {
//     switch (this) {
//       case OrderStatus.pending:
//         return const Color(0xFFFEF3C7);
//       case OrderStatus.processing:
//         return const Color(0xFFEDE9FE);
//       case OrderStatus.shipping:
//         return const Color(0xFFDBEAFE);
//       case OrderStatus.delivered:
//         return const Color(0xFFD1FAE5);
//       case OrderStatus.cancelled:
//         return const Color(0xFFFEE2E2);
//     }
//   }

//   IconData get icon {
//     switch (this) {
//       case OrderStatus.pending:
//         return Icons.schedule_rounded;
//       case OrderStatus.processing:
//         return Icons.inventory_2_outlined;
//       case OrderStatus.shipping:
//         return Icons.local_shipping_outlined;
//       case OrderStatus.delivered:
//         return Icons.check_circle_outline_rounded;
//       case OrderStatus.cancelled:
//         return Icons.cancel_outlined;
//     }
//   }

//   // Tracking step index (0-based), -1 for cancelled
//   int get trackingStep {
//     switch (this) {
//       case OrderStatus.pending:
//         return 0;
//       case OrderStatus.processing:
//         return 1;
//       case OrderStatus.shipping:
//         return 2;
//       case OrderStatus.delivered:
//         return 3;
//       case OrderStatus.cancelled:
//         return -1;
//     }
//   }
// }

// class OrderProduct {
//   final String name;
//   final String imageUrl;
//   final int quantity;
//   final double price;
//   final String brand;

//   const OrderProduct({
//     required this.name,
//     required this.imageUrl,
//     required this.quantity,
//     required this.price,
//     required this.brand,
//   });
// }

// class OrderModel {
//   final String id;
//   final DateTime date;
//   final OrderStatus status;
//   final List<OrderProduct> products;
//   final double total;
//   final String address;
//   final String paymentMethod;
//   final String estimatedDelivery;

//   const OrderModel({
//     required this.id,
//     required this.date,
//     required this.status,
//     required this.products,
//     required this.total,
//     required this.address,
//     required this.paymentMethod,
//     required this.estimatedDelivery,
//   });
// }

// // ═══════════════════════════════════════════════════════════════
// // FAKE DATA
// // ═══════════════════════════════════════════════════════════════

// final List<OrderModel> kOrders = [
//   OrderModel(
//     id: 'ORD-2024-8821',
//     date: DateTime(2024, 12, 18),
//     status: OrderStatus.shipping,
//     products: const [
//       OrderProduct(
//         name: 'Pro Headphones X1',
//         brand: 'SoundCore',
//         imageUrl:
//             'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=200',
//         quantity: 1,
//         price: 129.00,
//       ),
//       OrderProduct(
//         name: 'USB-C Cable 2m',
//         brand: 'Anker',
//         imageUrl:
//             'https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=200',
//         quantity: 2,
//         price: 12.50,
//       ),
//     ],
//     total: 154.00,
//     address: '123 Street, Phnom Penh, Cambodia',
//     paymentMethod: 'Visa •••• 4242',
//     estimatedDelivery: 'Dec 20, 2024',
//   ),
//   OrderModel(
//     id: 'ORD-2024-7743',
//     date: DateTime(2024, 12, 15),
//     status: OrderStatus.delivered,
//     products: const [
//       OrderProduct(
//         name: 'Nike Air Max 270',
//         brand: 'Nike',
//         imageUrl:
//             'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=200',
//         quantity: 1,
//         price: 145.00,
//       ),
//     ],
//     total: 145.00,
//     address: '45 Norodom Blvd, Phnom Penh',
//     paymentMethod: 'Cash on Delivery',
//     estimatedDelivery: 'Dec 17, 2024',
//   ),
//   OrderModel(
//     id: 'ORD-2024-6651',
//     date: DateTime(2024, 12, 20),
//     status: OrderStatus.pending,
//     products: const [
//       OrderProduct(
//         name: 'Leather Crossbody Bag',
//         brand: 'Coach',
//         imageUrl:
//             'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=200',
//         quantity: 1,
//         price: 89.00,
//       ),
//       OrderProduct(
//         name: 'Silver Bracelet',
//         brand: 'Tiffany',
//         imageUrl:
//             'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=200',
//         quantity: 1,
//         price: 55.00,
//       ),
//     ],
//     total: 144.00,
//     address: '78 Russian Blvd, Phnom Penh',
//     paymentMethod: 'MasterCard •••• 8831',
//     estimatedDelivery: 'Dec 25, 2024',
//   ),
//   OrderModel(
//     id: 'ORD-2024-5529',
//     date: DateTime(2024, 12, 10),
//     status: OrderStatus.cancelled,
//     products: const [
//       OrderProduct(
//         name: 'Smart Watch Series 9',
//         brand: 'Apple',
//         imageUrl:
//             'https://images.unsplash.com/photo-1434493789847-2f02dc6ca35d?w=200',
//         quantity: 1,
//         price: 399.00,
//       ),
//     ],
//     total: 399.00,
//     address: '12 Kampuchea Krom, PP',
//     paymentMethod: 'Visa •••• 1122',
//     estimatedDelivery: 'Dec 13, 2024',
//   ),
//   OrderModel(
//     id: 'ORD-2024-4418',
//     date: DateTime(2024, 12, 5),
//     status: OrderStatus.processing,
//     products: const [
//       OrderProduct(
//         name: 'Laptop Stand Pro',
//         brand: 'Rain Design',
//         imageUrl:
//             'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=200',
//         quantity: 1,
//         price: 65.00,
//       ),
//       OrderProduct(
//         name: 'Mechanical Keyboard',
//         brand: 'Keychron',
//         imageUrl:
//             'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=200',
//         quantity: 1,
//         price: 110.00,
//       ),
//     ],
//     total: 175.00,
//     address: '90 Toul Kork, Phnom Penh',
//     paymentMethod: 'Cash on Delivery',
//     estimatedDelivery: 'Dec 22, 2024',
//   ),
// ];

// // ═══════════════════════════════════════════════════════════════
// // ORDERS SCREEN (Main with Tabs)
// // ═══════════════════════════════════════════════════════════════

// class OrdersScreen extends StatefulWidget {
//   const OrdersScreen({super.key});
//   @override
//   State<OrdersScreen> createState() => _OrdersScreenState();
// }

// class _OrdersScreenState extends State<OrdersScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   bool _isLoading = true;
//   List<OrderModel> _orders = [];

//   final List<Map<String, dynamic>> _tabs = [
//     {'label': 'All', 'filter': null},
//     {'label': 'Pending', 'filter': OrderStatus.pending},
//     {'label': 'Shipping', 'filter': OrderStatus.shipping},
//     {'label': 'Delivered', 'filter': OrderStatus.delivered},
//     {'label': 'Cancelled', 'filter': OrderStatus.cancelled},
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: _tabs.length, vsync: this);
//     _loadOrders();
//   }

//   Future<void> _loadOrders({bool refresh = false}) async {
//     if (!refresh) setState(() => _isLoading = true);
//     await Future.delayed(Duration(milliseconds: refresh ? 800 : 1200));
//     if (mounted)
//       setState(() {
//         _orders = kOrders;
//         _isLoading = false;
//       });
//   }

//   List<OrderModel> _filteredOrders(OrderStatus? filter) {
//     if (filter == null) return _orders;
//     return _orders.where((o) => o.status == filter).toList();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F5F3),
//       body: NestedScrollView(
//         headerSliverBuilder: (_, __) => [_buildAppBar(), _buildTabBar()],
//         body: _isLoading
//             ? _buildSkeletonList()
//             : TabBarView(
//                 controller: _tabController,
//                 children: _tabs.map((tab) {
//                   final filtered = _filteredOrders(
//                     tab['filter'] as OrderStatus?,
//                   );
//                   return _OrderTabView(
//                     orders: filtered,
//                     onRefresh: () => _loadOrders(refresh: true),
//                     onOrderTap: (order) => _openDetail(order),
//                     onReorder: (order) => _showReorderSnack(order),
//                   );
//                 }).toList(),
//               ),
//       ),
//     );
//   }

//   // ── App Bar ──────────────────────────────────────────────────
//   Widget _buildAppBar() {
//     return SliverAppBar(
//       pinned: true,
//       backgroundColor: const Color(0xFFF6F5F3),
//       elevation: 0,
//       expandedHeight: 0,
//       flexibleSpace: const FlexibleSpaceBar(),
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'My Orders',
//             style: TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.w800,
//               color: Color(0xFF111111),
//               letterSpacing: -0.5,
//             ),
//           ),
//           Text(
//             '${_orders.length} orders total',
//             style: const TextStyle(
//               fontSize: 12,
//               color: Color(0xFF888888),
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         Container(
//           margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: const Color(0xFFE5E5E5)),
//           ),
//           child: IconButton(
//             icon: const Icon(
//               Icons.search_rounded,
//               color: Color(0xFF444444),
//               size: 20,
//             ),
//             onPressed: () {},
//           ),
//         ),
//       ],
//     );
//   }

//   // ── Tab Bar ──────────────────────────────────────────────────
//   Widget _buildTabBar() {
//     return SliverPersistentHeader(
//       pinned: true,
//       delegate: _TabBarDelegate(
//         TabBar(
//           controller: _tabController,
//           isScrollable: true,
//           tabAlignment: TabAlignment.start,
//           padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
//           indicator: BoxDecoration(
//             color: const Color(0xFF111111),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           indicatorSize: TabBarIndicatorSize.tab,
//           labelColor: Colors.white,
//           unselectedLabelColor: const Color(0xFF888888),
//           labelStyle: const TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//           ),
//           unselectedLabelStyle: const TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w500,
//           ),
//           dividerColor: Colors.transparent,
//           tabs: _tabs
//               .map(
//                 (t) => Tab(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 4),
//                     child: Text(t['label'] as String),
//                   ),
//                 ),
//               )
//               .toList(),
//         ),
//       ),
//     );
//   }

//   // ── Skeleton ─────────────────────────────────────────────────
//   Widget _buildSkeletonList() {
//     return ListView.builder(
//       padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
//       itemCount: 4,
//       itemBuilder: (_, __) => const _SkeletonOrderCard(),
//     );
//   }

//   void _openDetail(OrderModel order) {
//     Navigator.push(
//       context,
//       PageRouteBuilder(
//         transitionDuration: const Duration(milliseconds: 320),
//         pageBuilder: (_, __, ___) => OrderDetailScreen(order: order),
//         transitionsBuilder: (_, anim, __, child) => FadeTransition(
//           opacity: anim,
//           child: SlideTransition(
//             position:
//                 Tween<Offset>(
//                   begin: const Offset(0.04, 0),
//                   end: Offset.zero,
//                 ).animate(
//                   CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
//                 ),
//             child: child,
//           ),
//         ),
//       ),
//     );
//   }

//   void _showReorderSnack(OrderModel order) {
//     HapticFeedback.mediumImpact();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('${order.products.length} item(s) added to cart!'),
//         backgroundColor: const Color(0xFF111111),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         action: SnackBarAction(
//           label: 'View Cart',
//           textColor: const Color(0xFFF59E0B),
//           onPressed: () {},
//         ),
//       ),
//     );
//   }
// }

// // ─── Tab Bar Delegate ─────────────────────────────────────────
// class _TabBarDelegate extends SliverPersistentHeaderDelegate {
//   final TabBar tabBar;
//   const _TabBarDelegate(this.tabBar);

//   @override
//   double get minExtent => tabBar.preferredSize.height + 8;
//   @override
//   double get maxExtent => tabBar.preferredSize.height + 8;

//   @override
//   Widget build(_, double shrink, bool overlaps) {
//     return Container(
//       color: const Color(0xFFF6F5F3),
//       alignment: Alignment.centerLeft,
//       child: tabBar,
//     );
//   }

//   @override
//   bool shouldRebuild(_TabBarDelegate old) => old.tabBar != tabBar;
// }

// // ═══════════════════════════════════════════════════════════════
// // ORDER TAB VIEW (List + Pull to Refresh + Empty State)
// // ═══════════════════════════════════════════════════════════════

// class _OrderTabView extends StatelessWidget {
//   final List<OrderModel> orders;
//   final Future<void> Function() onRefresh;
//   final void Function(OrderModel) onOrderTap;
//   final void Function(OrderModel) onReorder;

//   const _OrderTabView({
//     required this.orders,
//     required this.onRefresh,
//     required this.onOrderTap,
//     required this.onReorder,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (orders.isEmpty) return _buildEmptyState(context);

//     return RefreshIndicator(
//       onRefresh: onRefresh,
//       color: const Color(0xFF111111),
//       child: ListView.builder(
//         padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
//         itemCount: orders.length,
//         itemBuilder: (_, i) => OrderCard(
//           order: orders[i],
//           onTap: () => onOrderTap(orders[i]),
//           onReorder: () => onReorder(orders[i]),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 96,
//             height: 96,
//             decoration: BoxDecoration(
//               color: const Color(0xFFEEEDEB),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.inbox_outlined,
//               size: 44,
//               color: Color(0xFFAAAAAA),
//             ),
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             'No orders yet',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w700,
//               color: Color(0xFF222222),
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Looks like you haven\'t placed\nany orders in this category.',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 14,
//               color: Color(0xFF888888),
//               height: 1.5,
//             ),
//           ),
//           const SizedBox(height: 28),
//           GestureDetector(
//             onTap: () {},
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF111111),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: const Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(
//                     Icons.shopping_bag_outlined,
//                     color: Colors.white,
//                     size: 18,
//                   ),
//                   SizedBox(width: 8),
//                   Text(
//                     'Go Shopping',
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

// class OrderCard extends StatefulWidget {
//   final OrderModel order;
//   final VoidCallback onTap;
//   final VoidCallback onReorder;

//   const OrderCard({
//     super.key,
//     required this.order,
//     required this.onTap,
//     required this.onReorder,
//   });

//   @override
//   State<OrderCard> createState() => _OrderCardState();
// }

// class _OrderCardState extends State<OrderCard>
//     with SingleTickerProviderStateMixin {
//   bool _expanded = false;
//   late AnimationController _expandController;
//   late Animation<double> _expandAnim;

//   @override
//   void initState() {
//     super.initState();
//     _expandController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 280),
//     );
//     _expandAnim = CurvedAnimation(
//       parent: _expandController,
//       curve: Curves.easeOutCubic,
//     );
//   }

//   @override
//   void dispose() {
//     _expandController.dispose();
//     super.dispose();
//   }

//   void _toggleExpand() {
//     HapticFeedback.selectionClick();
//     setState(() => _expanded = !_expanded);
//     _expanded ? _expandController.forward() : _expandController.reverse();
//   }

//   String _formatDate(DateTime d) =>
//       '${_monthName(d.month)} ${d.day}, ${d.year}';

//   String _monthName(int m) => [
//     '',
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
//   ][m];

//   @override
//   Widget build(BuildContext context) {
//     final order = widget.order;
//     final status = order.status;
//     final mainProduct = order.products.first;

//     return GestureDetector(
//       onTap: widget.onTap,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 16,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Header ───────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 14, 14, 0),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           order.id,
//                           style: const TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w700,
//                             color: Color(0xFF222222),
//                             letterSpacing: -0.2,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           _formatDate(order.date),
//                           style: const TextStyle(
//                             fontSize: 11,
//                             color: Color(0xFFAAAAAA),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Status Chip
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 5,
//                     ),
//                     decoration: BoxDecoration(
//                       color: status.bgColor,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(status.icon, size: 12, color: status.color),
//                         const SizedBox(width: 4),
//                         Text(
//                           status.label,
//                           style: TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w700,
//                             color: status.color,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 12),
//             const Divider(height: 1, color: Color(0xFFF0F0F0)),
//             const SizedBox(height: 12),

//             // ── Product Row ───────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 children: [
//                   // Product image
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Image.network(
//                       mainProduct.imageUrl,
//                       width: 64,
//                       height: 64,
//                       fit: BoxFit.cover,
//                       errorBuilder: (_, __, ___) => Container(
//                         width: 64,
//                         height: 64,
//                         color: const Color(0xFFF0F0F0),
//                         child: const Icon(
//                           Icons.image_outlined,
//                           color: Color(0xFFCCCCCC),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           mainProduct.name,
//                           style: const TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFF222222),
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           mainProduct.brand,
//                           style: const TextStyle(
//                             fontSize: 11,
//                             color: Color(0xFFAAAAAA),
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 7,
//                                 vertical: 2,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFFF3F3F3),
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: Text(
//                                 'Qty: ${mainProduct.quantity}',
//                                 style: const TextStyle(
//                                   fontSize: 10,
//                                   color: Color(0xFF666666),
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                             if (order.products.length > 1) ...[
//                               const SizedBox(width: 6),
//                               Text(
//                                 '+${order.products.length - 1} more',
//                                 style: const TextStyle(
//                                   fontSize: 10,
//                                   color: Color(0xFFAAAAAA),
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   Text(
//                     '\$${order.total.toStringAsFixed(2)}',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w800,
//                       color: Color(0xFF111111),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 12),

//             // ── Expand: All products ──────────────────────────
//             if (order.products.length > 1) ...[
//               SizeTransition(
//                 sizeFactor: _expandAnim,
//                 child: Column(
//                   children: [
//                     const Divider(height: 1, color: Color(0xFFF5F5F5)),
//                     ...order.products
//                         .skip(1)
//                         .map(
//                           (p) => Padding(
//                             padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
//                             child: Row(
//                               children: [
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(8),
//                                   child: Image.network(
//                                     p.imageUrl,
//                                     width: 44,
//                                     height: 44,
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (_, __, ___) => Container(
//                                       width: 44,
//                                       height: 44,
//                                       color: const Color(0xFFF0F0F0),
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 10),
//                                 Expanded(
//                                   child: Text(
//                                     p.name,
//                                     style: const TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w500,
//                                       color: Color(0xFF444444),
//                                     ),
//                                   ),
//                                 ),
//                                 Text(
//                                   '\$${p.price.toStringAsFixed(2)}',
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w600,
//                                     color: Color(0xFF222222),
//                                   ),
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
//                 onTap: _toggleExpand,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Row(
//                     children: [
//                       Text(
//                         _expanded ? 'Show less' : 'Show all items',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF666666),
//                         ),
//                       ),
//                       AnimatedRotation(
//                         turns: _expanded ? 0.5 : 0,
//                         duration: const Duration(milliseconds: 280),
//                         child: const Icon(
//                           Icons.keyboard_arrow_down_rounded,
//                           size: 16,
//                           color: Color(0xFF666666),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],

//             const SizedBox(height: 14),
//             const Divider(height: 1, color: Color(0xFFF0F0F0)),

//             // ── Bottom Actions ────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
//               child: Row(
//                 children: [
//                   // Track button
//                   if (status != OrderStatus.cancelled &&
//                       status != OrderStatus.delivered)
//                     Expanded(
//                       child: _ActionButton(
//                         label: 'Track Order',
//                         icon: Icons.local_shipping_outlined,
//                         isPrimary: true,
//                         onTap: widget.onTap,
//                       ),
//                     ),

//                   if (status != OrderStatus.cancelled &&
//                       status != OrderStatus.delivered)
//                     const SizedBox(width: 8),

//                   // Re-order / Details
//                   Expanded(
//                     child: _ActionButton(
//                       label: status == OrderStatus.delivered
//                           ? 'Buy Again'
//                           : 'Details',
//                       icon: status == OrderStatus.delivered
//                           ? Icons.refresh_rounded
//                           : Icons.receipt_long_outlined,
//                       isPrimary: status == OrderStatus.delivered,
//                       onTap: status == OrderStatus.delivered
//                           ? widget.onReorder
//                           : widget.onTap,
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

// // ─── Action Button ────────────────────────────────────────────
// class _ActionButton extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final bool isPrimary;
//   final VoidCallback onTap;

//   const _ActionButton({
//     required this.label,
//     required this.icon,
//     required this.isPrimary,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         decoration: BoxDecoration(
//           color: isPrimary ? const Color(0xFF111111) : const Color(0xFFF4F4F4),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               size: 15,
//               color: isPrimary ? Colors.white : const Color(0xFF444444),
//             ),
//             const SizedBox(width: 6),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w700,
//                 color: isPrimary ? Colors.white : const Color(0xFF444444),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // SKELETON ORDER CARD
// // ═══════════════════════════════════════════════════════════════

// class _SkeletonOrderCard extends StatefulWidget {
//   const _SkeletonOrderCard();
//   @override
//   State<_SkeletonOrderCard> createState() => _SkeletonOrderCardState();
// }

// class _SkeletonOrderCardState extends State<_SkeletonOrderCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
//   late Animation<double> _anim;

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

//   Widget _box(double w, double h, {double r = 8}) => AnimatedBuilder(
//     animation: _anim,
//     builder: (_, __) => Container(
//       width: w,
//       height: h,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(r),
//         color: Color.lerp(
//           const Color(0xFFEEEEEE),
//           const Color(0xFFF8F8F8),
//           _anim.value,
//         ),
//       ),
//     ),
//   );

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [_box(120, 14), _box(70, 24, r: 12)],
//           ),
//           const SizedBox(height: 6),
//           _box(80, 10),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               _box(64, 64, r: 12),
//               const SizedBox(width: 12),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _box(140, 13),
//                   const SizedBox(height: 6),
//                   _box(80, 10),
//                   const SizedBox(height: 6),
//                   _box(50, 10),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
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
//   final OrderModel order;
//   const OrderDetailScreen({super.key, required this.order});

//   @override
//   State<OrderDetailScreen> createState() => _OrderDetailScreenState();
// }

// class _OrderDetailScreenState extends State<OrderDetailScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animController;
//   late Animation<double> _fadeAnim;
//   late Animation<Offset> _slideAnim;

//   @override
//   void initState() {
//     super.initState();
//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
//     _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
//         .animate(
//           CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
//         );
//     _animController.forward();
//   }

//   @override
//   void dispose() {
//     _animController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final order = widget.order;
//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F5F3),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFF6F5F3),
//         elevation: 0,
//         leading: GestureDetector(
//           onTap: () => Navigator.pop(context),
//           child: Container(
//             margin: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: const Color(0xFFE5E5E5)),
//             ),
//             child: const Icon(
//               Icons.arrow_back_ios_new_rounded,
//               size: 16,
//               color: Color(0xFF333333),
//             ),
//           ),
//         ),
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               order.id,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//                 color: Color(0xFF111111),
//               ),
//             ),
//             Text(
//               '${order.products.length} item(s)',
//               style: const TextStyle(
//                 fontSize: 11,
//                 color: Color(0xFFAAAAAA),
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
//                 color: order.status.bgColor,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Text(
//                 order.status.label,
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w700,
//                   color: order.status.color,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: FadeTransition(
//         opacity: _fadeAnim,
//         child: SlideTransition(
//           position: _slideAnim,
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // ── Tracking Timeline ─────────────────────────
//                 if (order.status != OrderStatus.cancelled) ...[
//                   _buildSection(
//                     'Order Tracking',
//                     Icons.route_rounded,
//                     child: _OrderTracking(order: order),
//                   ),
//                   const SizedBox(height: 14),
//                 ],

//                 // ── Products ──────────────────────────────────
//                 _buildSection(
//                   'Items Ordered',
//                   Icons.shopping_bag_outlined,
//                   child: _ProductsList(order: order),
//                 ),
//                 const SizedBox(height: 14),

//                 // ── Delivery Address ──────────────────────────
//                 _buildSection(
//                   'Delivery Address',
//                   Icons.location_on_outlined,
//                   child: _AddressCard(order: order),
//                 ),
//                 const SizedBox(height: 14),

//                 // ── Payment ───────────────────────────────────
//                 _buildSection(
//                   'Payment',
//                   Icons.payment_rounded,
//                   child: _PaymentCard(order: order),
//                 ),
//                 const SizedBox(height: 14),

//                 // ── Price Summary ─────────────────────────────
//                 _buildSection(
//                   'Order Summary',
//                   Icons.receipt_outlined,
//                   child: _PriceSummary(order: order),
//                 ),
//                 const SizedBox(height: 24),

//                 // ── CTA Buttons ───────────────────────────────
//                 _buildDetailActions(context, order),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSection(String title, IconData icon, {required Widget child}) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
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
//                     color: const Color(0xFFF3F3F3),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(icon, size: 16, color: const Color(0xFF555555)),
//                 ),
//                 const SizedBox(width: 10),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF222222),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const Divider(height: 1, color: Color(0xFFF5F5F5)),
//           Padding(padding: const EdgeInsets.all(16), child: child),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailActions(BuildContext context, OrderModel order) {
//     return Column(
//       children: [
//         if (order.status == OrderStatus.delivered)
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: () {
//                 HapticFeedback.mediumImpact();
//                 Navigator.pop(context);
//               },
//               icon: const Icon(Icons.refresh_rounded, size: 18),
//               label: const Text(
//                 'Buy Again',
//                 style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF111111),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 elevation: 0,
//               ),
//             ),
//           ),
//         if (order.status == OrderStatus.pending) ...[
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton.icon(
//               onPressed: () {},
//               icon: const Icon(
//                 Icons.cancel_outlined,
//                 size: 18,
//                 color: Color(0xFFEF4444),
//               ),
//               label: const Text(
//                 'Cancel Order',
//                 style: TextStyle(
//                   color: Color(0xFFEF4444),
//                   fontWeight: FontWeight.w700,
//                   fontSize: 15,
//                 ),
//               ),
//               style: OutlinedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 side: const BorderSide(color: Color(0xFFEF4444)),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//               ),
//             ),
//           ),
//         ],
//         if (order.status == OrderStatus.shipping) ...[
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
//         ],
//       ],
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // ORDER TRACKING TIMELINE
// // ═══════════════════════════════════════════════════════════════

// class _OrderTracking extends StatelessWidget {
//   final OrderModel order;
//   const _OrderTracking({required this.order});

//   static const _steps = [
//     _TrackStep(
//       label: 'Order Placed',
//       icon: Icons.shopping_cart_checkout_rounded,
//       time: 'Dec 18, 10:00 AM',
//     ),
//     _TrackStep(
//       label: 'Packed',
//       icon: Icons.inventory_2_outlined,
//       time: 'Dec 18, 3:45 PM',
//     ),
//     _TrackStep(
//       label: 'Shipped',
//       icon: Icons.local_shipping_outlined,
//       time: 'Dec 19, 8:30 AM',
//     ),
//     _TrackStep(
//       label: 'Delivered',
//       icon: Icons.check_circle_outline_rounded,
//       time: 'Dec 20',
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final currentStep = order.status.trackingStep;

//     return Column(
//       children: List.generate(_steps.length, (i) {
//         final isDone = i <= currentStep;
//         final isCurrent = i == currentStep;
//         final isLast = i == _steps.length - 1;

//         return IntrinsicHeight(
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Timeline column
//               SizedBox(
//                 width: 32,
//                 child: Column(
//                   children: [
//                     // Circle
//                     Container(
//                       width: 32,
//                       height: 32,
//                       decoration: BoxDecoration(
//                         color: isDone
//                             ? const Color(0xFF111111)
//                             : const Color(0xFFF0F0F0),
//                         shape: BoxShape.circle,
//                         border: isCurrent
//                             ? Border.all(
//                                 color: const Color(0xFF111111),
//                                 width: 2,
//                               )
//                             : null,
//                         boxShadow: isCurrent
//                             ? [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.15),
//                                   blurRadius: 8,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ]
//                             : null,
//                       ),
//                       child: Icon(
//                         _steps[i].icon,
//                         size: 15,
//                         color: isDone ? Colors.white : const Color(0xFFCCCCCC),
//                       ),
//                     ),
//                     // Line
//                     if (!isLast)
//                       Expanded(
//                         child: Container(
//                           width: 2,
//                           margin: const EdgeInsets.symmetric(vertical: 3),
//                           decoration: BoxDecoration(
//                             color: i < currentStep
//                                 ? const Color(0xFF111111)
//                                 : const Color(0xFFEEEEEE),
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
//                   padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 6),
//                       Text(
//                         _steps[i].label,
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: isCurrent
//                               ? FontWeight.w700
//                               : FontWeight.w500,
//                           color: isDone
//                               ? const Color(0xFF111111)
//                               : const Color(0xFFCCCCCC),
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         isDone ? _steps[i].time : 'Waiting...',
//                         style: TextStyle(
//                           fontSize: 11,
//                           color: isDone
//                               ? const Color(0xFF888888)
//                               : const Color(0xFFDDDDDD),
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
//                           child: const Text(
//                             '● Current status',
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

// class _TrackStep {
//   final String label, time;
//   final IconData icon;
//   const _TrackStep({
//     required this.label,
//     required this.time,
//     required this.icon,
//   });
// }

// // ═══════════════════════════════════════════════════════════════
// // DETAIL WIDGETS
// // ═══════════════════════════════════════════════════════════════

// class _ProductsList extends StatelessWidget {
//   final OrderModel order;
//   const _ProductsList({required this.order});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: order.products.asMap().entries.map((e) {
//         final i = e.key;
//         final p = e.value;
//         return Padding(
//           padding: EdgeInsets.only(
//             bottom: i < order.products.length - 1 ? 14 : 0,
//           ),
//           child: Row(
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(10),
//                 child: Image.network(
//                   p.imageUrl,
//                   width: 56,
//                   height: 56,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => Container(
//                     width: 56,
//                     height: 56,
//                     color: const Color(0xFFF0F0F0),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       p.name,
//                       style: const TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF222222),
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       p.brand,
//                       style: const TextStyle(
//                         fontSize: 11,
//                         color: Color(0xFFAAAAAA),
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Qty: ${p.quantity}',
//                       style: const TextStyle(
//                         fontSize: 11,
//                         color: Color(0xFF777777),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Text(
//                 '\$${p.price.toStringAsFixed(2)}',
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xFF111111),
//                 ),
//               ),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }
// }

// class _AddressCard extends StatelessWidget {
//   final OrderModel order;
//   const _AddressCard({required this.order});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: const Color(0xFFDBEAFE),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: const Icon(
//             Icons.location_on_rounded,
//             size: 20,
//             color: Color(0xFF3B82F6),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Delivery Address',
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: Color(0xFFAAAAAA),
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 order.address,
//                 style: const TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF222222),
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 'Est. delivery: ${order.estimatedDelivery}',
//                 style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _PaymentCard extends StatelessWidget {
//   final OrderModel order;
//   const _PaymentCard({required this.order});

//   bool get _isCash => order.paymentMethod.toLowerCase().contains('cash');

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: _isCash ? const Color(0xFFFEF3C7) : const Color(0xFFEDE9FE),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(
//             _isCash ? Icons.payments_outlined : Icons.credit_card_rounded,
//             size: 20,
//             color: _isCash ? const Color(0xFFF59E0B) : const Color(0xFF8B5CF6),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Payment Method',
//               style: TextStyle(
//                 fontSize: 11,
//                 color: Color(0xFFAAAAAA),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               order.paymentMethod,
//               style: const TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF222222),
//               ),
//             ),
//           ],
//         ),
//         const Spacer(),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//           decoration: BoxDecoration(
//             color: const Color(0xFFF0FDF4),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: const Text(
//             'Paid',
//             style: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w700,
//               color: Color(0xFF16A34A),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _PriceSummary extends StatelessWidget {
//   final OrderModel order;
//   const _PriceSummary({required this.order});

//   Widget _row(
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
//               color: bold ? const Color(0xFF111111) : const Color(0xFF888888),
//               fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 13,
//               fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
//               color:
//                   valueColor ??
//                   (bold ? const Color(0xFF111111) : const Color(0xFF444444)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final subtotal = order.products.fold(
//       0.0,
//       (sum, p) => sum + p.price * p.quantity,
//     );
//     const shipping = 5.00;
//     final total = subtotal + shipping;

//     return Column(
//       children: [
//         _row('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
//         _row('Shipping', '\$$shipping'),
//         const Divider(height: 16, color: Color(0xFFF0F0F0)),
//         _row(
//           'Total',
//           '\$${total.toStringAsFixed(2)}',
//           bold: true,
//           valueColor: const Color(0xFF111111),
//         ),
//       ],
//     );
//   }
// }

// ========================================

// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// // ═══════════════════════════════════════════════════════════════
// // ENTRY POINT
// // ═══════════════════════════════════════════════════════════════

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Orders',
//       theme: ThemeData(
//         useMaterial3: true,
//         scaffoldBackgroundColor: const Color(0xFFF6F5F3),
//         fontFamily: 'SF Pro Display',
//       ),
//       home: const OrdersScreen(),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // API MODELS  (your MyOrdersModel / Order / Item)
// // ═══════════════════════════════════════════════════════════════

// MyOrdersModel myOrdersModelFromJson(String str) =>
//     MyOrdersModel.fromJson(json.decode(str));

// class MyOrdersModel {
//   List<Order> orders;
//   MyOrdersModel({required this.orders});

//   factory MyOrdersModel.fromJson(Map<String, dynamic> json) => MyOrdersModel(
//         orders:
//             List<Order>.from(json["orders"].map((x) => Order.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "orders": List<dynamic>.from(orders.map((x) => x.toJson())),
//       };
// }

// class Order {
//   int id;
//   String status;
//   String total;
//   String paymentMethod;
//   String paymentStatus;
//   String phone;
//   String address;
//   String createdAt;
//   List<Item> items;

//   Order({
//     required this.id,
//     required this.status,
//     required this.total,
//     required this.paymentMethod,
//     required this.paymentStatus,
//     required this.phone,
//     required this.address,
//     required this.createdAt,
//     required this.items,
//   });

//   factory Order.fromJson(Map<String, dynamic> json) => Order(
//         id: json["id"],
//         status: json["status"],
//         total: json["total"],
//         paymentMethod: json["payment_method"],
//         paymentStatus: json["payment_status"],
//         phone: json["phone"],
//         address: json["address"],
//         createdAt: json["created_at"],
//         items:
//             List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "status": status,
//         "total": total,
//         "payment_method": paymentMethod,
//         "payment_status": paymentStatus,
//         "phone": phone,
//         "address": address,
//         "created_at": createdAt,
//         "items": List<dynamic>.from(items.map((x) => x.toJson())),
//       };
// }

// class Item {
//   String name;
//   int qty;
//   String price;
//   String finalPrice;
//   dynamic discount;
//   String image;

//   Item({
//     required this.name,
//     required this.qty,
//     required this.price,
//     required this.finalPrice,
//     required this.discount,
//     required this.image,
//   });

//   factory Item.fromJson(Map<String, dynamic> json) => Item(
//         name: json["name"],
//         qty: json["qty"],
//         price: json["price"],
//         finalPrice: json["final_price"],
//         discount: json["discount"],
//         image: json["image"],
//       );

//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "qty": qty,
//         "price": price,
//         "final_price": finalPrice,
//         "discount": discount,
//         "image": image,
//       };
// }

// // ═══════════════════════════════════════════════════════════════
// // SERVICE
// // ═══════════════════════════════════════════════════════════════

// class OrdersService {
//   static const String baseUrl = 'http://10.0.2.2:8000/api';

//   Future<MyOrdersModel> fetchMyOrders() async {
//     // ✅ Get token BEFORE request
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString("token");

//     final response = await http.get(
//       Uri.parse('$baseUrl/orders'),
//       headers: {
//         'Accept': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );

//     if (response.statusCode == 200) {
//       return myOrdersModelFromJson(response.body);
//     } else {
//       throw Exception('Failed to load orders: ${response.body}');
//     }
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // STATUS HELPERS  (maps your API "status" string → UI)
// // ═══════════════════════════════════════════════════════════════

// // Expected API status strings (adjust to match your backend):
// //   "pending" | "processing" | "shipping" | "delivered" | "cancelled"

// class StatusStyle {
//   final String label;
//   final Color color;
//   final Color bgColor;
//   final IconData icon;
//   final int trackingStep; // -1 = cancelled

//   const StatusStyle({
//     required this.label,
//     required this.color,
//     required this.bgColor,
//     required this.icon,
//     required this.trackingStep,
//   });
// }

// StatusStyle statusStyle(String status) {
//   switch (status.toLowerCase()) {
//     case 'pending':
//       return const StatusStyle(
//         label: 'Pending',
//         color: Color(0xFFF59E0B),
//         bgColor: Color(0xFFFEF3C7),
//         icon: Icons.schedule_rounded,
//         trackingStep: 0,
//       );
//     case 'processing':
//       return const StatusStyle(
//         label: 'Processing',
//         color: Color(0xFF8B5CF6),
//         bgColor: Color(0xFFEDE9FE),
//         icon: Icons.inventory_2_outlined,
//         trackingStep: 1,
//       );
//     case 'shipping':
//       return const StatusStyle(
//         label: 'Shipping',
//         color: Color(0xFF3B82F6),
//         bgColor: Color(0xFFDBEAFE),
//         icon: Icons.local_shipping_outlined,
//         trackingStep: 2,
//       );
//     case 'delivered':
//       return const StatusStyle(
//         label: 'Delivered',
//         color: Color(0xFF10B981),
//         bgColor: Color(0xFFD1FAE5),
//         icon: Icons.check_circle_outline_rounded,
//         trackingStep: 3,
//       );
//     case 'cancelled':
//       return const StatusStyle(
//         label: 'Cancelled',
//         color: Color(0xFFEF4444),
//         bgColor: Color(0xFFFEE2E2),
//         icon: Icons.cancel_outlined,
//         trackingStep: -1,
//       );
//     default:
//       return StatusStyle(
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
//   bool _isLoading = true;
//   String? _error;
//   List<Order> _orders = [];

//   // ⚠️ Provide your real auth token here
//   final String _token = 'YOUR_AUTH_TOKEN';
//   final OrdersService _service = OrdersService();

//   final List<Map<String, dynamic>> _tabs = [
//     {'label': 'All', 'filter': null},
//     {'label': 'Pending', 'filter': 'pending'},
//     {'label': 'Shipping', 'filter': 'shipping'},
//     {'label': 'Delivered', 'filter': 'delivered'},
//     {'label': 'Cancelled', 'filter': 'cancelled'},
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: _tabs.length, vsync: this);
//     _loadOrders();
//   }

//   Future<void> _loadOrders({bool refresh = false}) async {
//     if (!refresh) setState(() { _isLoading = true; _error = null; });
//     try {
//       final result = await _service.fetchMyOrders();
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

//   List<Order> _filteredOrders(String? filter) {
//     if (filter == null) return _orders;
//     return _orders
//         .where((o) => o.status.toLowerCase() == filter.toLowerCase())
//         .toList();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F5F3),
//       body: NestedScrollView(
//         headerSliverBuilder: (_, __) => [_buildAppBar(), _buildTabBar()],
//         body: _isLoading
//             ? _buildSkeletonList()
//             : _error != null
//                 ? _buildErrorState()
//                 : TabBarView(
//                     controller: _tabController,
//                     children: _tabs.map((tab) {
//                       final filtered =
//                           _filteredOrders(tab['filter'] as String?);
//                       return _OrderTabView(
//                         orders: filtered,
//                         onRefresh: () => _loadOrders(refresh: true),
//                         onOrderTap: (order) => _openDetail(order),
//                         onReorder: (order) => _showReorderSnack(order),
//                       );
//                     }).toList(),
//                   ),
//       ),
//     );
//   }

//   Widget _buildAppBar() {
//     return SliverAppBar(
//       pinned: true,
//       backgroundColor: const Color(0xFFF6F5F3),
//       elevation: 0,
//       expandedHeight: 0,
//       flexibleSpace: const FlexibleSpaceBar(),
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'My Orders',
//             style: TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.w800,
//               color: Color(0xFF111111),
//               letterSpacing: -0.5,
//             ),
//           ),
//           Text(
//             '${_orders.length} orders total',
//             style: const TextStyle(
//               fontSize: 12,
//               color: Color(0xFF888888),
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         Container(
//           margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: const Color(0xFFE5E5E5)),
//           ),
//           child: IconButton(
//             icon: const Icon(Icons.search_rounded,
//                 color: Color(0xFF444444), size: 20),
//             onPressed: () {},
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTabBar() {
//     return SliverPersistentHeader(
//       pinned: true,
//       delegate: _TabBarDelegate(
//         TabBar(
//           controller: _tabController,
//           isScrollable: true,
//           tabAlignment: TabAlignment.start,
//           padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
//           indicator: BoxDecoration(
//             color: const Color(0xFF111111),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           indicatorSize: TabBarIndicatorSize.tab,
//           labelColor: Colors.white,
//           unselectedLabelColor: const Color(0xFF888888),
//           labelStyle:
//               const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
//           unselectedLabelStyle:
//               const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
//           dividerColor: Colors.transparent,
//           tabs: _tabs
//               .map((t) => Tab(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 4),
//                       child: Text(t['label'] as String),
//                     ),
//                   ))
//               .toList(),
//         ),
//       ),
//     );
//   }

//   Widget _buildSkeletonList() {
//     return ListView.builder(
//       padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
//       itemCount: 4,
//       itemBuilder: (_, __) => const _SkeletonOrderCard(),
//     );
//   }

//   Widget _buildErrorState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.wifi_off_rounded,
//                 size: 56, color: Color(0xFFCCCCCC)),
//             const SizedBox(height: 16),
//             const Text(
//               'Failed to load orders',
//               style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xFF222222)),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               _error ?? '',
//               textAlign: TextAlign.center,
//               style:
//                   const TextStyle(fontSize: 12, color: Color(0xFF888888)),
//             ),
//             const SizedBox(height: 24),
//             GestureDetector(
//               onTap: _loadOrders,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 28, vertical: 14),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF111111),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: const Text(
//                   'Retry',
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 15),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _openDetail(Order order) {
//     Navigator.push(
//       context,
//       PageRouteBuilder(
//         transitionDuration: const Duration(milliseconds: 320),
//         pageBuilder: (_, __, ___) => OrderDetailScreen(order: order),
//         transitionsBuilder: (_, anim, __, child) => FadeTransition(
//           opacity: anim,
//           child: SlideTransition(
//             position: Tween<Offset>(
//               begin: const Offset(0.04, 0),
//               end: Offset.zero,
//             ).animate(
//                 CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
//             child: child,
//           ),
//         ),
//       ),
//     );
//   }

//   void _showReorderSnack(Order order) {
//     HapticFeedback.mediumImpact();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('${order.items.length} item(s) added to cart!'),
//         backgroundColor: const Color(0xFF111111),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         action: SnackBarAction(
//           label: 'View Cart',
//           textColor: const Color(0xFFF59E0B),
//           onPressed: () {},
//         ),
//       ),
//     );
//   }
// }

// // ─── Tab Bar Delegate ─────────────────────────────────────────
// class _TabBarDelegate extends SliverPersistentHeaderDelegate {
//   final TabBar tabBar;
//   const _TabBarDelegate(this.tabBar);

//   @override
//   double get minExtent => tabBar.preferredSize.height + 8;
//   @override
//   double get maxExtent => tabBar.preferredSize.height + 8;

//   @override
//   Widget build(_, double shrink, bool overlaps) {
//     return Container(
//       color: const Color(0xFFF6F5F3),
//       alignment: Alignment.centerLeft,
//       child: tabBar,
//     );
//   }

//   @override
//   bool shouldRebuild(_TabBarDelegate old) => old.tabBar != tabBar;
// }

// // ═══════════════════════════════════════════════════════════════
// // ORDER TAB VIEW
// // ═══════════════════════════════════════════════════════════════

// class _OrderTabView extends StatelessWidget {
//   final List<Order> orders;
//   final Future<void> Function() onRefresh;
//   final void Function(Order) onOrderTap;
//   final void Function(Order) onReorder;

//   const _OrderTabView({
//     required this.orders,
//     required this.onRefresh,
//     required this.onOrderTap,
//     required this.onReorder,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (orders.isEmpty) return _buildEmptyState(context);

//     return RefreshIndicator(
//       onRefresh: onRefresh,
//       color: const Color(0xFF111111),
//       child: ListView.builder(
//         padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
//         itemCount: orders.length,
//         itemBuilder: (_, i) => OrderCard(
//           order: orders[i],
//           onTap: () => onOrderTap(orders[i]),
//           onReorder: () => onReorder(orders[i]),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 96,
//             height: 96,
//             decoration: const BoxDecoration(
//               color: Color(0xFFEEEDEB),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(Icons.inbox_outlined,
//                 size: 44, color: Color(0xFFAAAAAA)),
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             'No orders yet',
//             style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w700,
//                 color: Color(0xFF222222)),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Looks like you haven\'t placed\nany orders in this category.',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//                 fontSize: 14, color: Color(0xFF888888), height: 1.5),
//           ),
//           const SizedBox(height: 28),
//           GestureDetector(
//             onTap: () {},
//             child: Container(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF111111),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: const Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.shopping_bag_outlined,
//                       color: Colors.white, size: 18),
//                   SizedBox(width: 8),
//                   Text(
//                     'Go Shopping',
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 15),
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
// // ORDER CARD  (uses Order + Item from API)
// // ═══════════════════════════════════════════════════════════════

// class OrderCard extends StatefulWidget {
//   final Order order;
//   final VoidCallback onTap;
//   final VoidCallback onReorder;

//   const OrderCard({
//     super.key,
//     required this.order,
//     required this.onTap,
//     required this.onReorder,
//   });

//   @override
//   State<OrderCard> createState() => _OrderCardState();
// }

// class _OrderCardState extends State<OrderCard>
//     with SingleTickerProviderStateMixin {
//   bool _expanded = false;
//   late AnimationController _expandController;
//   late Animation<double> _expandAnim;

//   @override
//   void initState() {
//     super.initState();
//     _expandController = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 280));
//     _expandAnim = CurvedAnimation(
//         parent: _expandController, curve: Curves.easeOutCubic);
//   }

//   @override
//   void dispose() {
//     _expandController.dispose();
//     super.dispose();
//   }

//   void _toggleExpand() {
//     HapticFeedback.selectionClick();
//     setState(() => _expanded = !_expanded);
//     _expanded
//         ? _expandController.forward()
//         : _expandController.reverse();
//   }

//   /// Parses "2024-12-18T10:00:00.000Z" or "2024-12-18 10:00:00" → "Dec 18, 2024"
//   String _formatDate(String raw) {
//     try {
//       final d = DateTime.parse(raw);
//       const months = [
//         '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//         'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
//       ];
//       return '${months[d.month]} ${d.day}, ${d.year}';
//     } catch (_) {
//       return raw; // fall back to raw string if parsing fails
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final order = widget.order;
//     final style = statusStyle(order.status);
//     final mainItem = order.items.isNotEmpty ? order.items.first : null;

//     return GestureDetector(
//       onTap: widget.onTap,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
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
//                           style: const TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w700,
//                             color: Color(0xFF222222),
//                             letterSpacing: -0.2,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           _formatDate(order.createdAt),
//                           style: const TextStyle(
//                               fontSize: 11, color: Color(0xFFAAAAAA)),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Status chip
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 10, vertical: 5),
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
//             const Divider(height: 1, color: Color(0xFFF0F0F0)),
//             const SizedBox(height: 12),

//             // ── First product row ───────────────────────────
//             if (mainItem != null)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   children: [
//                     // Product image (from API "image" field)
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Image.network(
//                         mainItem.image,
//                         width: 64,
//                         height: 64,
//                         fit: BoxFit.cover,
//                         errorBuilder: (_, __, ___) => Container(
//                           width: 64,
//                           height: 64,
//                           color: const Color(0xFFF0F0F0),
//                           child: const Icon(Icons.image_outlined,
//                               color: Color(0xFFCCCCCC)),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             mainItem.name,
//                             style: const TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w600,
//                               color: Color(0xFF222222),
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 4),
//                           Row(
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 7, vertical: 2),
//                                 decoration: BoxDecoration(
//                                   color: const Color(0xFFF3F3F3),
//                                   borderRadius: BorderRadius.circular(6),
//                                 ),
//                                 child: Text(
//                                   'Qty: ${mainItem.qty}',
//                                   style: const TextStyle(
//                                     fontSize: 10,
//                                     color: Color(0xFF666666),
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                               if (order.items.length > 1) ...[
//                                 const SizedBox(width: 6),
//                                 Text(
//                                   '+${order.items.length - 1} more',
//                                   style: const TextStyle(
//                                       fontSize: 10,
//                                       color: Color(0xFFAAAAAA)),
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     // Use order.total from API
//                     Text(
//                       '\$${order.total}',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w800,
//                         color: Color(0xFF111111),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//             const SizedBox(height: 12),

//             // ── Expandable extra items ─────────────────────
//             if (order.items.length > 1) ...[
//               SizeTransition(
//                 sizeFactor: _expandAnim,
//                 child: Column(
//                   children: [
//                     const Divider(height: 1, color: Color(0xFFF5F5F5)),
//                     ...order.items.skip(1).map(
//                           (item) => Padding(
//                             padding:
//                                 const EdgeInsets.fromLTRB(16, 10, 16, 0),
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
//                                       color: const Color(0xFFF0F0F0),
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 10),
//                                 Expanded(
//                                   child: Text(
//                                     item.name,
//                                     style: const TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w500,
//                                       color: Color(0xFF444444),
//                                     ),
//                                   ),
//                                 ),
//                                 Text(
//                                   '\$${item.finalPrice}',
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w600,
//                                     color: Color(0xFF222222),
//                                   ),
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
//                 onTap: _toggleExpand,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Row(
//                     children: [
//                       Text(
//                         _expanded ? 'Show less' : 'Show all items',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF666666),
//                         ),
//                       ),
//                       AnimatedRotation(
//                         turns: _expanded ? 0.5 : 0,
//                         duration: const Duration(milliseconds: 280),
//                         child: const Icon(
//                           Icons.keyboard_arrow_down_rounded,
//                           size: 16,
//                           color: Color(0xFF666666),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],

//             const SizedBox(height: 14),
//             const Divider(height: 1, color: Color(0xFFF0F0F0)),

//             // ── Bottom actions ─────────────────────────────
//             Padding(
//               padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
//               child: Row(
//                 children: [
//                   if (order.status.toLowerCase() != 'cancelled' &&
//                       order.status.toLowerCase() != 'delivered')
//                     Expanded(
//                       child: _ActionButton(
//                         label: 'Track Order',
//                         icon: Icons.local_shipping_outlined,
//                         isPrimary: true,
//                         onTap: widget.onTap,
//                       ),
//                     ),
//                   if (order.status.toLowerCase() != 'cancelled' &&
//                       order.status.toLowerCase() != 'delivered')
//                     const SizedBox(width: 8),
//                   Expanded(
//                     child: _ActionButton(
//                       label: order.status.toLowerCase() == 'delivered'
//                           ? 'Buy Again'
//                           : 'Details',
//                       icon: order.status.toLowerCase() == 'delivered'
//                           ? Icons.refresh_rounded
//                           : Icons.receipt_long_outlined,
//                       isPrimary:
//                           order.status.toLowerCase() == 'delivered',
//                       onTap: order.status.toLowerCase() == 'delivered'
//                           ? widget.onReorder
//                           : widget.onTap,
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

// // ─── Action Button ────────────────────────────────────────────
// class _ActionButton extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final bool isPrimary;
//   final VoidCallback onTap;

//   const _ActionButton({
//     required this.label,
//     required this.icon,
//     required this.isPrimary,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         decoration: BoxDecoration(
//           color:
//               isPrimary ? const Color(0xFF111111) : const Color(0xFFF4F4F4),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon,
//                 size: 15,
//                 color:
//                     isPrimary ? Colors.white : const Color(0xFF444444)),
//             const SizedBox(width: 6),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w700,
//                 color:
//                     isPrimary ? Colors.white : const Color(0xFF444444),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // SKELETON CARD
// // ═══════════════════════════════════════════════════════════════

// class _SkeletonOrderCard extends StatefulWidget {
//   const _SkeletonOrderCard();
//   @override
//   State<_SkeletonOrderCard> createState() => _SkeletonOrderCardState();
// }

// class _SkeletonOrderCardState extends State<_SkeletonOrderCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
//   late Animation<double> _anim;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 1100))
//       ..repeat(reverse: true);
//     _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   Widget _box(double w, double h, {double r = 8}) => AnimatedBuilder(
//         animation: _anim,
//         builder: (_, __) => Container(
//           width: w,
//           height: h,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(r),
//             color: Color.lerp(
//               const Color(0xFFEEEEEE),
//               const Color(0xFFF8F8F8),
//               _anim.value,
//             ),
//           ),
//         ),
//       );

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//           color: Colors.white, borderRadius: BorderRadius.circular(20)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [_box(120, 14), _box(70, 24, r: 12)],
//           ),
//           const SizedBox(height: 6),
//           _box(80, 10),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               _box(64, 64, r: 12),
//               const SizedBox(width: 12),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _box(140, 13),
//                   const SizedBox(height: 6),
//                   _box(80, 10),
//                   const SizedBox(height: 6),
//                   _box(50, 10),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
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
// // ORDER DETAIL SCREEN  (uses Order + Item from API)
// // ═══════════════════════════════════════════════════════════════

// class OrderDetailScreen extends StatefulWidget {
//   final Order order;
//   const OrderDetailScreen({super.key, required this.order});

//   @override
//   State<OrderDetailScreen> createState() => _OrderDetailScreenState();
// }

// class _OrderDetailScreenState extends State<OrderDetailScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animController;
//   late Animation<double> _fadeAnim;
//   late Animation<Offset> _slideAnim;

//   @override
//   void initState() {
//     super.initState();
//     _animController = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 500));
//     _fadeAnim =
//         CurvedAnimation(parent: _animController, curve: Curves.easeOut);
//     _slideAnim =
//         Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
//       CurvedAnimation(
//           parent: _animController, curve: Curves.easeOutCubic),
//     );
//     _animController.forward();
//   }

//   @override
//   void dispose() {
//     _animController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final order = widget.order;
//     final style = statusStyle(order.status);

//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F5F3),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFF6F5F3),
//         elevation: 0,
//         leading: GestureDetector(
//           onTap: () => Navigator.pop(context),
//           child: Container(
//             margin: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: const Color(0xFFE5E5E5)),
//             ),
//             child: const Icon(Icons.arrow_back_ios_new_rounded,
//                 size: 16, color: Color(0xFF333333)),
//           ),
//         ),
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               '#${order.id}',
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//                 color: Color(0xFF111111),
//               ),
//             ),
//             Text(
//               '${order.items.length} item(s)',
//               style: const TextStyle(
//                   fontSize: 11,
//                   color: Color(0xFFAAAAAA),
//                   fontWeight: FontWeight.w400),
//             ),
//           ],
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 16),
//             child: Container(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: style.bgColor,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Text(
//                 style.label,
//                 style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w700,
//                     color: style.color),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: FadeTransition(
//         opacity: _fadeAnim,
//         child: SlideTransition(
//           position: _slideAnim,
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Tracking (hide for cancelled)
//                 if (order.status.toLowerCase() != 'cancelled') ...[
//                   _buildSection('Order Tracking', Icons.route_rounded,
//                       child: _OrderTracking(order: order)),
//                   const SizedBox(height: 14),
//                 ],

//                 _buildSection('Items Ordered', Icons.shopping_bag_outlined,
//                     child: _ItemsList(order: order)),
//                 const SizedBox(height: 14),

//                 _buildSection(
//                     'Delivery Address', Icons.location_on_outlined,
//                     child: _AddressCard(order: order)),
//                 const SizedBox(height: 14),

//                 _buildSection('Payment', Icons.payment_rounded,
//                     child: _PaymentCard(order: order)),
//                 const SizedBox(height: 14),

//                 _buildSection('Order Summary', Icons.receipt_outlined,
//                     child: _PriceSummary(order: order)),
//                 const SizedBox(height: 24),

//                 _buildDetailActions(context, order),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSection(String title, IconData icon,
//       {required Widget child}) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
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
//                     color: const Color(0xFFF3F3F3),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child:
//                       Icon(icon, size: 16, color: const Color(0xFF555555)),
//                 ),
//                 const SizedBox(width: 10),
//                 Text(title,
//                     style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF222222))),
//               ],
//             ),
//           ),
//           const Divider(height: 1, color: Color(0xFFF5F5F5)),
//           Padding(padding: const EdgeInsets.all(16), child: child),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailActions(BuildContext context, Order order) {
//     return Column(
//       children: [
//         if (order.status.toLowerCase() == 'delivered')
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: () {
//                 HapticFeedback.mediumImpact();
//                 Navigator.pop(context);
//               },
//               icon: const Icon(Icons.refresh_rounded, size: 18),
//               label: const Text('Buy Again',
//                   style: TextStyle(
//                       fontSize: 15, fontWeight: FontWeight.w700)),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF111111),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16)),
//                 elevation: 0,
//               ),
//             ),
//           ),
//         if (order.status.toLowerCase() == 'pending')
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton.icon(
//               onPressed: () {},
//               icon: const Icon(Icons.cancel_outlined,
//                   size: 18, color: Color(0xFFEF4444)),
//               label: const Text('Cancel Order',
//                   style: TextStyle(
//                       color: Color(0xFFEF4444),
//                       fontWeight: FontWeight.w700,
//                       fontSize: 15)),
//               style: OutlinedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 side: const BorderSide(color: Color(0xFFEF4444)),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16)),
//               ),
//             ),
//           ),
//         if (order.status.toLowerCase() == 'shipping')
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: () {},
//               icon: const Icon(Icons.local_shipping_outlined, size: 18),
//               label: const Text('Live Tracking',
//                   style: TextStyle(
//                       fontSize: 15, fontWeight: FontWeight.w700)),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF3B82F6),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16)),
//                 elevation: 0,
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // ORDER TRACKING TIMELINE  (uses Order.status string)
// // ═══════════════════════════════════════════════════════════════

// class _OrderTracking extends StatelessWidget {
//   final Order order;
//   const _OrderTracking({required this.order});

//   static const _steps = [
//     _TrackStep(
//         label: 'Order Placed',
//         icon: Icons.shopping_cart_checkout_rounded,
//         time: 'Placed'),
//     _TrackStep(
//         label: 'Packed',
//         icon: Icons.inventory_2_outlined,
//         time: 'Processing'),
//     _TrackStep(
//         label: 'Shipped',
//         icon: Icons.local_shipping_outlined,
//         time: 'On the way'),
//     _TrackStep(
//         label: 'Delivered',
//         icon: Icons.check_circle_outline_rounded,
//         time: 'Delivered'),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final currentStep = statusStyle(order.status).trackingStep;

//     return Column(
//       children: List.generate(_steps.length, (i) {
//         final isDone = i <= currentStep;
//         final isCurrent = i == currentStep;
//         final isLast = i == _steps.length - 1;

//         return IntrinsicHeight(
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(
//                 width: 32,
//                 child: Column(
//                   children: [
//                     Container(
//                       width: 32,
//                       height: 32,
//                       decoration: BoxDecoration(
//                         color: isDone
//                             ? const Color(0xFF111111)
//                             : const Color(0xFFF0F0F0),
//                         shape: BoxShape.circle,
//                         border: isCurrent
//                             ? Border.all(
//                                 color: const Color(0xFF111111), width: 2)
//                             : null,
//                         boxShadow: isCurrent
//                             ? [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.15),
//                                   blurRadius: 8,
//                                   offset: const Offset(0, 2),
//                                 )
//                               ]
//                             : null,
//                       ),
//                       child: Icon(_steps[i].icon,
//                           size: 15,
//                           color: isDone
//                               ? Colors.white
//                               : const Color(0xFFCCCCCC)),
//                     ),
//                     if (!isLast)
//                       Expanded(
//                         child: Container(
//                           width: 2,
//                           margin: const EdgeInsets.symmetric(vertical: 3),
//                           decoration: BoxDecoration(
//                             color: i < currentStep
//                                 ? const Color(0xFF111111)
//                                 : const Color(0xFFEEEEEE),
//                             borderRadius: BorderRadius.circular(1),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Padding(
//                   padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 6),
//                       Text(
//                         _steps[i].label,
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: isCurrent
//                               ? FontWeight.w700
//                               : FontWeight.w500,
//                           color: isDone
//                               ? const Color(0xFF111111)
//                               : const Color(0xFFCCCCCC),
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         isDone ? _steps[i].time : 'Waiting...',
//                         style: TextStyle(
//                           fontSize: 11,
//                           color: isDone
//                               ? const Color(0xFF888888)
//                               : const Color(0xFFDDDDDD),
//                         ),
//                       ),
//                       if (isCurrent) ...[
//                         const SizedBox(height: 6),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8, vertical: 3),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFF0FDF4),
//                             borderRadius: BorderRadius.circular(6),
//                             border:
//                                 Border.all(color: const Color(0xFF86EFAC)),
//                           ),
//                           child: const Text(
//                             '● Current status',
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

// class _TrackStep {
//   final String label, time;
//   final IconData icon;
//   const _TrackStep(
//       {required this.label, required this.time, required this.icon});
// }

// // ═══════════════════════════════════════════════════════════════
// // DETAIL WIDGETS  (use Order / Item from API)
// // ═══════════════════════════════════════════════════════════════

// class _ItemsList extends StatelessWidget {
//   final Order order;
//   const _ItemsList({required this.order});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: order.items.asMap().entries.map((e) {
//         final i = e.key;
//         final item = e.value;
//         return Padding(
//           padding: EdgeInsets.only(
//               bottom: i < order.items.length - 1 ? 14 : 0),
//           child: Row(
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(10),
//                 child: Image.network(
//                   item.image,
//                   width: 56,
//                   height: 56,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => Container(
//                     width: 56,
//                     height: 56,
//                     color: const Color(0xFFF0F0F0),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(item.name,
//                         style: const TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFF222222))),
//                     const SizedBox(height: 4),
//                     Text('Qty: ${item.qty}',
//                         style: const TextStyle(
//                             fontSize: 11, color: Color(0xFF777777))),
//                     // Show discount badge if present
//                     if (item.discount != null &&
//                         item.discount.toString().isNotEmpty &&
//                         item.discount.toString() != 'null') ...[
//                       const SizedBox(height: 2),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 6, vertical: 2),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFFEF3C7),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Text(
//                           '${item.discount}% off',
//                           style: const TextStyle(
//                               fontSize: 10,
//                               color: Color(0xFFF59E0B),
//                               fontWeight: FontWeight.w600),
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
//                     style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF111111)),
//                   ),
//                   if (item.price != item.finalPrice)
//                     Text(
//                       '\$${item.price}',
//                       style: const TextStyle(
//                         fontSize: 11,
//                         color: Color(0xFFAAAAAA),
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

// class _AddressCard extends StatelessWidget {
//   final Order order;
//   const _AddressCard({required this.order});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: const Color(0xFFDBEAFE),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: const Icon(Icons.location_on_rounded,
//               size: 20, color: Color(0xFF3B82F6)),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('Delivery Address',
//                   style: TextStyle(
//                       fontSize: 11,
//                       color: Color(0xFFAAAAAA),
//                       fontWeight: FontWeight.w500)),
//               const SizedBox(height: 2),
//               Text(order.address,
//                   style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF222222))),
//               const SizedBox(height: 2),
//               // Show phone from API
//               Text(order.phone,
//                   style: const TextStyle(
//                       fontSize: 11, color: Color(0xFF888888))),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _PaymentCard extends StatelessWidget {
//   final Order order;
//   const _PaymentCard({required this.order});

//   bool get _isCash =>
//       order.paymentMethod.toLowerCase().contains('cash');

//   @override
//   Widget build(BuildContext context) {
//     // paymentStatus from API e.g. "paid" / "unpaid"
//     final isPaid =
//         order.paymentStatus.toLowerCase().contains('paid');

//     return Row(
//       children: [
//         Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: _isCash
//                 ? const Color(0xFFFEF3C7)
//                 : const Color(0xFFEDE9FE),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(
//             _isCash
//                 ? Icons.payments_outlined
//                 : Icons.credit_card_rounded,
//             size: 20,
//             color: _isCash
//                 ? const Color(0xFFF59E0B)
//                 : const Color(0xFF8B5CF6),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Payment Method',
//                 style: TextStyle(
//                     fontSize: 11,
//                     color: Color(0xFFAAAAAA),
//                     fontWeight: FontWeight.w500)),
//             const SizedBox(height: 2),
//             Text(order.paymentMethod,
//                 style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF222222))),
//           ],
//         ),
//         const Spacer(),
//         Container(
//           padding:
//               const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//           decoration: BoxDecoration(
//             color: isPaid
//                 ? const Color(0xFFF0FDF4)
//                 : const Color(0xFFFEF3C7),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Text(
//             // Capitalize first letter
//             order.paymentStatus.isNotEmpty
//                 ? order.paymentStatus[0].toUpperCase() +
//                     order.paymentStatus.substring(1)
//                 : order.paymentStatus,
//             style: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w700,
//               color: isPaid
//                   ? const Color(0xFF16A34A)
//                   : const Color(0xFFF59E0B),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _PriceSummary extends StatelessWidget {
//   final Order order;
//   const _PriceSummary({required this.order});

//   Widget _row(String label, String value,
//       {bool bold = false, Color? valueColor}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label,
//               style: TextStyle(
//                 fontSize: 13,
//                 color: bold
//                     ? const Color(0xFF111111)
//                     : const Color(0xFF888888),
//                 fontWeight:
//                     bold ? FontWeight.w700 : FontWeight.w400,
//               )),
//           Text(value,
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight:
//                     bold ? FontWeight.w800 : FontWeight.w500,
//                 color: valueColor ??
//                     (bold
//                         ? const Color(0xFF111111)
//                         : const Color(0xFF444444)),
//               )),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Compute subtotal from items using finalPrice
//     final subtotal = order.items.fold(
//       0.0,
//       (sum, item) =>
//           sum + (double.tryParse(item.finalPrice) ?? 0) * item.qty,
//     );
//     final grandTotal = double.tryParse(order.total) ?? subtotal;
//     final shipping = grandTotal - subtotal;

//     return Column(
//       children: [
//         _row('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
//         if (shipping > 0)
//           _row('Shipping', '\$${shipping.toStringAsFixed(2)}'),
//         const Divider(height: 16, color: Color(0xFFF0F0F0)),
//         _row('Total', '\$${order.total}',
//             bold: true, valueColor: const Color(0xFF111111)),
//       ],
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:mart_frontend/checkout/checkout_screen.dart';
import '../../models/my_orders_model.dart';
import '../../services/api_service.dart';
import '../main/main_screen.dart';
import '../theme/app_theme.dart';

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
        color: Color(0xFFF59E0B),
        bgColor: Color(0xFFFEF3C7),
        icon: Icons.schedule_rounded,
        trackingStep: 0,
      );
    case 'processing':
      return _StatusStyle(
        label: 'processing'.tr,
        color: Color(0xFF8B5CF6),
        bgColor: Color(0xFFEDE9FE),
        icon: Icons.inventory_2_outlined,
        trackingStep: 1,
      );
    // case 'shipping':
    //   return const _StatusStyle(
    //     label: 'Shipping',
    //     color: Color(0xFF3B82F6),
    //     bgColor: Color(0xFFDBEAFE),
    //     icon: Icons.local_shipping_outlined,
    //     trackingStep: 2,
    //   );
    case 'completed':
      return _StatusStyle(
        // label: 'Delivered',
        label: 'completed'.tr,
        color: Color(0xFF10B981),
        bgColor: Color(0xFFD1FAE5),
        icon: Icons.check_circle_outline_rounded,
        trackingStep: 3,
      );
    case 'cancelled':
      return _StatusStyle(
        label: 'cancelled'.tr,
        color: Color(0xFFEF4444),
        bgColor: Color(0xFFFEE2E2),
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
    if (!refresh)
      setState(() {
        _isLoading = true;
        _error = null;
      });

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
    final f = filter.toString();
    return _orders.where((o) {
      final status = o.status.toLowerCase().trim();

      if (f == 'completed') {
        return status == 'completed' || status == 'delivered';
      }

      return status == f;
    }).toList();
  }

  Future<void> _buyAgain(Order order) async {
    // HapticFeedback.mediumImpact();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          fromCart: false,
          items: order.items.map((item) {
            return OrderItem(
              id: item.productId.toString(),
              name: item.name,
              imageUrl: item.image,
              unitPrice: double.parse(item.finalPrice),
              quantity: item.qty,
            );
          }).toList(),
        ),
      ),
    );
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
            ? _empty(context, colors)
            : TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: _tabDefs.map((tab) {
                  return _OrderTabView(
                    orders: _filtered(tab['filter']),
                    colors: colors,
                    onRefresh: () => _loadOrders(refresh: true),
                    onTap: (o) => _openDetail(o),
                    onReorder: (o) => _buyAgain(o),
                  );
                }).toList(),
              ),
      ),
    );
  }

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
              fontSize: 22,
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
          tabs: _tabDefs
              .map(
                (t) => Tab(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(t['label']!.tr),
                  ),
                ),
              )
              .toList(),
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

  Widget _empty(BuildContext context, AppColors colors) {
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
            'You haven\'t placed any orders\nin this category yet.',
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
                  Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'go_shopping'.tr,
                    style: TextStyle(
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
  // ── Navigation ───────────────────────────────────────────────

  void _openDetail(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
    );
  }

  void _showReorderSnack(Order order) {
    // HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${order.items.length} item(s) added to cart!'),
        backgroundColor: context.colors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () {},
        ),
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
            'You haven\'t placed any orders\nin this category yet.',
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
                  Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'go_shopping'.tr,
                    style: TextStyle(
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
    // HapticFeedback.selectionClick();
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
    final isDelivered = order.status.toLowerCase() == 'completed';

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
                    // Image
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
// SKELETON ORDER CARD  (uses AppColors)
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
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_box(110, 14), _box(72, 26, r: 13)],
          ),
          const SizedBox(height: 6),
          _box(70, 10),
          const SizedBox(height: 18),

          // Product row
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

          // Action buttons
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
  _TrackingTimeline({required this.order, required this.colors});

  final _steps = [
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
    // (label: 'Shipped', icon: Icons.local_shipping_outlined, sub: 'On the way'),
    (
      label: 'delivered'.tr,
      icon: CupertinoIcons.check_mark_circled,
      sub: 'Completed',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentStep = _statusStyle(order.status).trackingStep;
    final c = colors;

    return Column(
      children: List.generate(_steps.length, (i) {
        final isDone = i < currentStep;
        final isCurrent = i == currentStep;
        final isLast = i == _steps.length - 1;
        final step = _steps[i];

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
                        color: isDone ? c.accent : c.surface2,
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
                        color: isDone ? Colors.white : c.text3,
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
                          color: isDone ? c.text1 : c.text3,
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
                            style: TextStyle(
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
        final hasDiscount =
            item.discount != null &&
            item.discount.toString().isNotEmpty &&
            item.discount.toString() != 'null' &&
            item.discount.toString() != '0';

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

  bool get _isCash => order.paymentMethod.toUpperCase().contains('cash');

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final isPaid = order.paymentStatus.toUpperCase().contains('paid');
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
            color: isPaid ? const Color(0xFFF0FDF4) : Colors.green,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            statusLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isPaid ? const Color(0xFF16A34A) : Colors.white,
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
              color: valueColor ?? (bold ? c.text1 : c.text2),
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
      final price = double.tryParse(item.finalPrice.toString()) ?? 0.0;
      return sum + price * item.qty;
    });
    final grandTotal = double.tryParse(order.total.toString()) ?? subtotal;
    final shipping = grandTotal - subtotal;

    return Column(
      children: [
        // _row(c, 'subtotal'.tr, '\$${subtotal.toStringAsFixed(2)}'),
        // if (shipping > 0.001)
        // _row(c, 'shipping'.tr, '\$${shipping.toStringAsFixed(2)}'),
        // Divider(height: 16, color: c.border.withValues(alpha: 0.15)),
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
        if (status == 'completed')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // HapticFeedback.mediumImpact();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'Buy Again',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
        // if (status == 'pending')
        //   SizedBox(
        //     width: double.infinity,
        //     child: OutlinedButton.icon(
        //       onPressed: () {},
        //       icon: const Icon(
        //         Icons.cancel_outlined,
        //         size: 18,
        //         color: Color(0xFFEF4444),
        //       ),
        //       label: const Text(
        //         'Cancel Order',
        //         style: TextStyle(
        //           color: Color(0xFFEF4444),
        //           fontWeight: FontWeight.w700,
        //           fontSize: 15,
        //         ),
        //       ),
        //       style: OutlinedButton.styleFrom(
        //         padding: const EdgeInsets.symmetric(vertical: 16),
        //         side: const BorderSide(color: Color(0xFFEF4444)),
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(16),
        //         ),
        //       ),
        //     ),
        //   ),
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
