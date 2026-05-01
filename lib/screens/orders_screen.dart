import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ═══════════════════════════════════════════════════════════════
// ENTRY POINT
// ═══════════════════════════════════════════════════════════════

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Orders',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F5F3),
        fontFamily: 'SF Pro Display',
      ),
      home: const OrdersScreen(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MODELS
// ═══════════════════════════════════════════════════════════════

enum OrderStatus { pending, processing, shipping, delivered, cancelled }

extension OrderStatusExt on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:     return 'Pending';
      case OrderStatus.processing:  return 'Processing';
      case OrderStatus.shipping:    return 'Shipping';
      case OrderStatus.delivered:   return 'Delivered';
      case OrderStatus.cancelled:   return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:     return const Color(0xFFF59E0B);
      case OrderStatus.processing:  return const Color(0xFF8B5CF6);
      case OrderStatus.shipping:    return const Color(0xFF3B82F6);
      case OrderStatus.delivered:   return const Color(0xFF10B981);
      case OrderStatus.cancelled:   return const Color(0xFFEF4444);
    }
  }

  Color get bgColor {
    switch (this) {
      case OrderStatus.pending:     return const Color(0xFFFEF3C7);
      case OrderStatus.processing:  return const Color(0xFFEDE9FE);
      case OrderStatus.shipping:    return const Color(0xFFDBEAFE);
      case OrderStatus.delivered:   return const Color(0xFFD1FAE5);
      case OrderStatus.cancelled:   return const Color(0xFFFEE2E2);
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pending:     return Icons.schedule_rounded;
      case OrderStatus.processing:  return Icons.inventory_2_outlined;
      case OrderStatus.shipping:    return Icons.local_shipping_outlined;
      case OrderStatus.delivered:   return Icons.check_circle_outline_rounded;
      case OrderStatus.cancelled:   return Icons.cancel_outlined;
    }
  }

  // Tracking step index (0-based), -1 for cancelled
  int get trackingStep {
    switch (this) {
      case OrderStatus.pending:     return 0;
      case OrderStatus.processing:  return 1;
      case OrderStatus.shipping:    return 2;
      case OrderStatus.delivered:   return 3;
      case OrderStatus.cancelled:   return -1;
    }
  }
}

class OrderProduct {
  final String name;
  final String imageUrl;
  final int quantity;
  final double price;
  final String brand;

  const OrderProduct({
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.price,
    required this.brand,
  });
}

class OrderModel {
  final String id;
  final DateTime date;
  final OrderStatus status;
  final List<OrderProduct> products;
  final double total;
  final String address;
  final String paymentMethod;
  final String estimatedDelivery;

  const OrderModel({
    required this.id,
    required this.date,
    required this.status,
    required this.products,
    required this.total,
    required this.address,
    required this.paymentMethod,
    required this.estimatedDelivery,
  });
}

// ═══════════════════════════════════════════════════════════════
// FAKE DATA
// ═══════════════════════════════════════════════════════════════

final List<OrderModel> kOrders = [
  OrderModel(
    id: 'ORD-2024-8821',
    date: DateTime(2024, 12, 18),
    status: OrderStatus.shipping,
    products: const [
      OrderProduct(
        name: 'Pro Headphones X1',
        brand: 'SoundCore',
        imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=200',
        quantity: 1,
        price: 129.00,
      ),
      OrderProduct(
        name: 'USB-C Cable 2m',
        brand: 'Anker',
        imageUrl: 'https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=200',
        quantity: 2,
        price: 12.50,
      ),
    ],
    total: 154.00,
    address: '123 Street, Phnom Penh, Cambodia',
    paymentMethod: 'Visa •••• 4242',
    estimatedDelivery: 'Dec 20, 2024',
  ),
  OrderModel(
    id: 'ORD-2024-7743',
    date: DateTime(2024, 12, 15),
    status: OrderStatus.delivered,
    products: const [
      OrderProduct(
        name: 'Nike Air Max 270',
        brand: 'Nike',
        imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=200',
        quantity: 1,
        price: 145.00,
      ),
    ],
    total: 145.00,
    address: '45 Norodom Blvd, Phnom Penh',
    paymentMethod: 'Cash on Delivery',
    estimatedDelivery: 'Dec 17, 2024',
  ),
  OrderModel(
    id: 'ORD-2024-6651',
    date: DateTime(2024, 12, 20),
    status: OrderStatus.pending,
    products: const [
      OrderProduct(
        name: 'Leather Crossbody Bag',
        brand: 'Coach',
        imageUrl: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=200',
        quantity: 1,
        price: 89.00,
      ),
      OrderProduct(
        name: 'Silver Bracelet',
        brand: 'Tiffany',
        imageUrl: 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=200',
        quantity: 1,
        price: 55.00,
      ),
    ],
    total: 144.00,
    address: '78 Russian Blvd, Phnom Penh',
    paymentMethod: 'MasterCard •••• 8831',
    estimatedDelivery: 'Dec 25, 2024',
  ),
  OrderModel(
    id: 'ORD-2024-5529',
    date: DateTime(2024, 12, 10),
    status: OrderStatus.cancelled,
    products: const [
      OrderProduct(
        name: 'Smart Watch Series 9',
        brand: 'Apple',
        imageUrl: 'https://images.unsplash.com/photo-1434493789847-2f02dc6ca35d?w=200',
        quantity: 1,
        price: 399.00,
      ),
    ],
    total: 399.00,
    address: '12 Kampuchea Krom, PP',
    paymentMethod: 'Visa •••• 1122',
    estimatedDelivery: 'Dec 13, 2024',
  ),
  OrderModel(
    id: 'ORD-2024-4418',
    date: DateTime(2024, 12, 5),
    status: OrderStatus.processing,
    products: const [
      OrderProduct(
        name: 'Laptop Stand Pro',
        brand: 'Rain Design',
        imageUrl: 'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=200',
        quantity: 1,
        price: 65.00,
      ),
      OrderProduct(
        name: 'Mechanical Keyboard',
        brand: 'Keychron',
        imageUrl: 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=200',
        quantity: 1,
        price: 110.00,
      ),
    ],
    total: 175.00,
    address: '90 Toul Kork, Phnom Penh',
    paymentMethod: 'Cash on Delivery',
    estimatedDelivery: 'Dec 22, 2024',
  ),
];

// ═══════════════════════════════════════════════════════════════
// ORDERS SCREEN (Main with Tabs)
// ═══════════════════════════════════════════════════════════════

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<OrderModel> _orders = [];

  final List<Map<String, dynamic>> _tabs = [
    {'label': 'All',       'filter': null},
    {'label': 'Pending',   'filter': OrderStatus.pending},
    {'label': 'Shipping',  'filter': OrderStatus.shipping},
    {'label': 'Delivered', 'filter': OrderStatus.delivered},
    {'label': 'Cancelled', 'filter': OrderStatus.cancelled},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadOrders();
  }

  Future<void> _loadOrders({bool refresh = false}) async {
    if (!refresh) setState(() => _isLoading = true);
    await Future.delayed(Duration(milliseconds: refresh ? 800 : 1200));
    if (mounted) setState(() { _orders = kOrders; _isLoading = false; });
  }

  List<OrderModel> _filteredOrders(OrderStatus? filter) {
    if (filter == null) return _orders;
    return _orders.where((o) => o.status == filter).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5F3),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          _buildAppBar(),
          _buildTabBar(),
        ],
        body: _isLoading
            ? _buildSkeletonList()
            : TabBarView(
                controller: _tabController,
                children: _tabs.map((tab) {
                  final filtered = _filteredOrders(
                      tab['filter'] as OrderStatus?);
                  return _OrderTabView(
                    orders: filtered,
                    onRefresh: () => _loadOrders(refresh: true),
                    onOrderTap: (order) => _openDetail(order),
                    onReorder: (order) => _showReorderSnack(order),
                  );
                }).toList(),
              ),
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFFF6F5F3),
      elevation: 0,
      expandedHeight: 0,
      flexibleSpace: const FlexibleSpaceBar(),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Orders',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111111),
              letterSpacing: -0.5,
            ),
          ),
          Text(
            '${_orders.length} orders total',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF888888),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E5E5)),
          ),
          child: IconButton(
            icon: const Icon(Icons.search_rounded,
                color: Color(0xFF444444), size: 20),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  // ── Tab Bar ──────────────────────────────────────────────────
  Widget _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          indicator: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(12),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF888888),
          labelStyle: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500),
          dividerColor: Colors.transparent,
          tabs: _tabs
              .map((t) => Tab(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(t['label'] as String),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  // ── Skeleton ─────────────────────────────────────────────────
  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: 4,
      itemBuilder: (_, __) => const _SkeletonOrderCard(),
    );
  }

  void _openDetail(OrderModel order) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, __, ___) => OrderDetailScreen(order: order),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      ),
    );
  }

  void _showReorderSnack(OrderModel order) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${order.products.length} item(s) added to cart!'),
        backgroundColor: const Color(0xFF111111),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: const Color(0xFFF59E0B),
          onPressed: () {},
        ),
      ),
    );
  }
}

// ─── Tab Bar Delegate ─────────────────────────────────────────
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height + 8;
  @override
  double get maxExtent => tabBar.preferredSize.height + 8;

  @override
  Widget build(_, double shrink, bool overlaps) {
    return Container(
      color: const Color(0xFFF6F5F3),
      alignment: Alignment.centerLeft,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) => old.tabBar != tabBar;
}

// ═══════════════════════════════════════════════════════════════
// ORDER TAB VIEW (List + Pull to Refresh + Empty State)
// ═══════════════════════════════════════════════════════════════

class _OrderTabView extends StatelessWidget {
  final List<OrderModel> orders;
  final Future<void> Function() onRefresh;
  final void Function(OrderModel) onOrderTap;
  final void Function(OrderModel) onReorder;

  const _OrderTabView({
    required this.orders,
    required this.onRefresh,
    required this.onOrderTap,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) return _buildEmptyState(context);

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: const Color(0xFF111111),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: orders.length,
        itemBuilder: (_, i) => OrderCard(
          order: orders[i],
          onTap: () => onOrderTap(orders[i]),
          onReorder: () => onReorder(orders[i]),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEDEB),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inbox_outlined,
                size: 44, color: Color(0xFFAAAAAA)),
          ),
          const SizedBox(height: 20),
          const Text(
            'No orders yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Looks like you haven\'t placed\nany orders in this category.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14,
                color: Color(0xFF888888),
                height: 1.5),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag_outlined,
                      color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Go Shopping',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15),
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

class OrderCard extends StatefulWidget {
  final OrderModel order;
  final VoidCallback onTap;
  final VoidCallback onReorder;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
    required this.onReorder,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _expandController;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _expandAnim = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    HapticFeedback.selectionClick();
    setState(() => _expanded = !_expanded);
    _expanded
        ? _expandController.forward()
        : _expandController.reverse();
  }

  String _formatDate(DateTime d) =>
      '${_monthName(d.month)} ${d.day}, ${d.year}';

  String _monthName(int m) => [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final status = order.status;
    final mainProduct = order.products.first;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 14, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.id,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF222222),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(order.date),
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFFAAAAAA)),
                        ),
                      ],
                    ),
                  ),
                  // Status Chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: status.bgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(status.icon,
                            size: 12, color: status.color),
                        const SizedBox(width: 4),
                        Text(
                          status.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: status.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 12),

            // ── Product Row ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Product image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      mainProduct.imageUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 64,
                        height: 64,
                        color: const Color(0xFFF0F0F0),
                        child: const Icon(Icons.image_outlined,
                            color: Color(0xFFCCCCCC)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mainProduct.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF222222),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          mainProduct.brand,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFFAAAAAA)),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F3F3),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Qty: ${mainProduct.quantity}',
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF666666),
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            if (order.products.length > 1) ...[
                              const SizedBox(width: 6),
                              Text(
                                '+${order.products.length - 1} more',
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFFAAAAAA)),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111111),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Expand: All products ──────────────────────────
            if (order.products.length > 1) ...[
              SizeTransition(
                sizeFactor: _expandAnim,
                child: Column(
                  children: [
                    const Divider(height: 1, color: Color(0xFFF5F5F5)),
                    ...order.products.skip(1).map((p) => Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 10, 16, 0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  p.imageUrl,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 44,
                                    height: 44,
                                    color: const Color(0xFFF0F0F0),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(p.name,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF444444))),
                              ),
                              Text(
                                '\$${p.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF222222)),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _toggleExpand,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        _expanded ? 'Show less' : 'Show all items',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF666666),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 280),
                        child: const Icon(Icons.keyboard_arrow_down_rounded,
                            size: 16, color: Color(0xFF666666)),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),

            // ── Bottom Actions ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                children: [
                  // Track button
                  if (status != OrderStatus.cancelled &&
                      status != OrderStatus.delivered)
                    Expanded(
                      child: _ActionButton(
                        label: 'Track Order',
                        icon: Icons.local_shipping_outlined,
                        isPrimary: true,
                        onTap: widget.onTap,
                      ),
                    ),

                  if (status != OrderStatus.cancelled &&
                      status != OrderStatus.delivered)
                    const SizedBox(width: 8),

                  // Re-order / Details
                  Expanded(
                    child: _ActionButton(
                      label: status == OrderStatus.delivered
                          ? 'Buy Again'
                          : 'Details',
                      icon: status == OrderStatus.delivered
                          ? Icons.refresh_rounded
                          : Icons.receipt_long_outlined,
                      isPrimary:
                          status == OrderStatus.delivered,
                      onTap: status == OrderStatus.delivered
                          ? widget.onReorder
                          : widget.onTap,
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

// ─── Action Button ────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF111111) : const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 15,
                color: isPrimary
                    ? Colors.white
                    : const Color(0xFF444444)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isPrimary ? Colors.white : const Color(0xFF444444),
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
  const _SkeletonOrderCard();
  @override
  State<_SkeletonOrderCard> createState() => _SkeletonOrderCardState();
}

class _SkeletonOrderCardState extends State<_SkeletonOrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _box(double w, double h, {double r = 8}) => AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r),
            color: Color.lerp(const Color(0xFFEEEEEE),
                const Color(0xFFF8F8F8), _anim.value),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_box(120, 14), _box(70, 24, r: 12)],
          ),
          const SizedBox(height: 6),
          _box(80, 10),
          const SizedBox(height: 16),
          Row(
            children: [
              _box(64, 64, r: 12),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(140, 13),
                  const SizedBox(height: 6),
                  _box(80, 10),
                  const SizedBox(height: 6),
                  _box(50, 10),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
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
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
        parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F5F3),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E5E5)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: Color(0xFF333333)),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.id,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111111),
              ),
            ),
            Text(
              '${order.products.length} item(s)',
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFAAAAAA),
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: order.status.bgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                order.status.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: order.status.color,
                ),
              ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Tracking Timeline ─────────────────────────
                if (order.status != OrderStatus.cancelled) ...[
                  _buildSection(
                    'Order Tracking',
                    Icons.route_rounded,
                    child: _OrderTracking(order: order),
                  ),
                  const SizedBox(height: 14),
                ],

                // ── Products ──────────────────────────────────
                _buildSection(
                  'Items Ordered',
                  Icons.shopping_bag_outlined,
                  child: _ProductsList(order: order),
                ),
                const SizedBox(height: 14),

                // ── Delivery Address ──────────────────────────
                _buildSection(
                  'Delivery Address',
                  Icons.location_on_outlined,
                  child: _AddressCard(order: order),
                ),
                const SizedBox(height: 14),

                // ── Payment ───────────────────────────────────
                _buildSection(
                  'Payment',
                  Icons.payment_rounded,
                  child: _PaymentCard(order: order),
                ),
                const SizedBox(height: 14),

                // ── Price Summary ─────────────────────────────
                _buildSection(
                  'Order Summary',
                  Icons.receipt_outlined,
                  child: _PriceSummary(order: order),
                ),
                const SizedBox(height: 24),

                // ── CTA Buttons ───────────────────────────────
                _buildDetailActions(context, order),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon,
      {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon,
                      size: 16, color: const Color(0xFF555555)),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF222222),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF5F5F5)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailActions(BuildContext context, OrderModel order) {
    return Column(
      children: [
        if (order.status == OrderStatus.delivered)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Buy Again',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF111111),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
        if (order.status == OrderStatus.pending) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.cancel_outlined,
                  size: 18, color: Color(0xFFEF4444)),
              label: const Text('Cancel Order',
                  style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFFEF4444)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
        if (order.status == OrderStatus.shipping) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.local_shipping_outlined,
                  size: 18),
              label: const Text('Live Tracking',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ORDER TRACKING TIMELINE
// ═══════════════════════════════════════════════════════════════

class _OrderTracking extends StatelessWidget {
  final OrderModel order;
  const _OrderTracking({required this.order});

  static const _steps = [
    _TrackStep(
      label: 'Order Placed',
      icon: Icons.shopping_cart_checkout_rounded,
      time: 'Dec 18, 10:00 AM',
    ),
    _TrackStep(
      label: 'Packed',
      icon: Icons.inventory_2_outlined,
      time: 'Dec 18, 3:45 PM',
    ),
    _TrackStep(
      label: 'Shipped',
      icon: Icons.local_shipping_outlined,
      time: 'Dec 19, 8:30 AM',
    ),
    _TrackStep(
      label: 'Delivered',
      icon: Icons.check_circle_outline_rounded,
      time: 'Dec 20',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentStep = order.status.trackingStep;

    return Column(
      children: List.generate(_steps.length, (i) {
        final isDone = i <= currentStep;
        final isCurrent = i == currentStep;
        final isLast = i == _steps.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline column
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    // Circle
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDone
                            ? const Color(0xFF111111)
                            : const Color(0xFFF0F0F0),
                        shape: BoxShape.circle,
                        border: isCurrent
                            ? Border.all(
                                color: const Color(0xFF111111), width: 2)
                            : null,
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Icon(
                        _steps[i].icon,
                        size: 15,
                        color: isDone
                            ? Colors.white
                            : const Color(0xFFCCCCCC),
                      ),
                    ),
                    // Line
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          decoration: BoxDecoration(
                            color: i < currentStep
                                ? const Color(0xFF111111)
                                : const Color(0xFFEEEEEE),
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
                  padding: EdgeInsets.only(
                      bottom: isLast ? 0 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        _steps[i].label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isCurrent
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isDone
                              ? const Color(0xFF111111)
                              : const Color(0xFFCCCCCC),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isDone ? _steps[i].time : 'Waiting...',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDone
                              ? const Color(0xFF888888)
                              : const Color(0xFFDDDDDD),
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: const Color(0xFF86EFAC)),
                          ),
                          child: const Text(
                            '● Current status',
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

class _TrackStep {
  final String label, time;
  final IconData icon;
  const _TrackStep(
      {required this.label, required this.time, required this.icon});
}

// ═══════════════════════════════════════════════════════════════
// DETAIL WIDGETS
// ═══════════════════════════════════════════════════════════════

class _ProductsList extends StatelessWidget {
  final OrderModel order;
  const _ProductsList({required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: order.products.asMap().entries.map((e) {
        final i = e.key;
        final p = e.value;
        return Padding(
          padding: EdgeInsets.only(
              bottom: i < order.products.length - 1 ? 14 : 0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  p.imageUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 56,
                    height: 56,
                    color: const Color(0xFFF0F0F0),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF222222))),
                    const SizedBox(height: 2),
                    Text(p.brand,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFFAAAAAA))),
                    const SizedBox(height: 4),
                    Text('Qty: ${p.quantity}',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF777777))),
                  ],
                ),
              ),
              Text(
                '\$${p.price.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final OrderModel order;
  const _AddressCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.location_on_rounded,
              size: 20, color: Color(0xFF3B82F6)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Delivery Address',
                  style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFAAAAAA),
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(order.address,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF222222))),
              const SizedBox(height: 2),
              Text('Est. delivery: ${order.estimatedDelivery}',
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF888888))),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final OrderModel order;
  const _PaymentCard({required this.order});

  bool get _isCash =>
      order.paymentMethod.toLowerCase().contains('cash');

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _isCash
                ? const Color(0xFFFEF3C7)
                : const Color(0xFFEDE9FE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _isCash
                ? Icons.payments_outlined
                : Icons.credit_card_rounded,
            size: 20,
            color: _isCash
                ? const Color(0xFFF59E0B)
                : const Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Method',
                style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFAAAAAA),
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(order.paymentMethod,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF222222))),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('Paid',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF16A34A))),
        ),
      ],
    );
  }
}

class _PriceSummary extends StatelessWidget {
  final OrderModel order;
  const _PriceSummary({required this.order});

  Widget _row(String label, String value,
      {bool bold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: bold
                      ? const Color(0xFF111111)
                      : const Color(0xFF888888),
                  fontWeight:
                      bold ? FontWeight.w700 : FontWeight.w400)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      bold ? FontWeight.w800 : FontWeight.w500,
                  color: valueColor ??
                      (bold
                          ? const Color(0xFF111111)
                          : const Color(0xFF444444)))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = order.products.fold(
        0.0, (sum, p) => sum + p.price * p.quantity);
    const shipping = 5.00;
    final total = subtotal + shipping;

    return Column(
      children: [
        _row('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
        _row('Shipping', '\$$shipping'),
        const Divider(height: 16, color: Color(0xFFF0F0F0)),
        _row('Total', '\$${total.toStringAsFixed(2)}',
            bold: true,
            valueColor: const Color(0xFF111111)),
      ],
    );
  }
}