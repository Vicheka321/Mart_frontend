// // lib/screens/notification/notification_screen.dart

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mart_frontend/screens/theme/app_theme.dart';
// import 'package:provider/provider.dart';
// import 'package:get/get.dart';
// import '../../models/notification_model.dart';


// class NotificationScreen extends StatefulWidget {
//   const NotificationScreen({super.key});

//   @override
//   State<NotificationScreen> createState() => _NotificationScreenState();
// }

// class _NotificationScreenState extends State<NotificationScreen> {
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_onScroll);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<NotificationProvider>().loadFirstPage();
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _onScroll() {
//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent - 200) {
//       context.read<NotificationProvider>().loadNextPage();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors ?? AppColors.light();
//     final provider = context.watch<NotificationProvider>();

//     return Scaffold(
//       backgroundColor: colors.background,
//       appBar: _buildAppBar(colors, provider),
//       body: SafeArea(
//         top: false,
//         child: RefreshIndicator(
//           color: colors.primary,
//           backgroundColor: colors.surface,
//           onRefresh: provider.refresh,
//           child: _buildBody(colors, provider),
//         ),
//       ),
//     );
//   }

//   PreferredSizeWidget _buildAppBar(
//     AppColors colors,
//     NotificationProvider provider,
//   ) {
//     return AppBar(
//       backgroundColor: colors.surface,
//       elevation: 0,
//       surfaceTintColor: Colors.transparent,
//       titleSpacing: 0,
//       leading: IconButton(
//         icon: Icon(
//           Icons.arrow_back_ios_new_rounded,
//           size: 20,
//           color: colors.textPrimary,
//         ),
//         onPressed: () => Get.back(),
//       ),
//       title: Text(
//         'notifications'.tr,
//         style: TextStyle(
//           color: colors.textPrimary,
//           fontWeight: FontWeight.w700,
//           fontSize: 18,
//         ),
//       ),
//       actions: [
//         if (provider.hasUnread)
//           TextButton(
//             onPressed: () {
//               HapticFeedback.selectionClick();
//               provider.markAllAsRead();
//             },
//             child: Text(
//               'mark_all_read'.tr,
//               style: TextStyle(
//                 color: colors.primary,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 13,
//               ),
//             ),
//           ),
//         const SizedBox(width: 8),
//       ],
//     );
//   }

//   Widget _buildBody(AppColors colors, NotificationProvider provider) {
//     if (provider.isLoading && provider.items.isEmpty) {
//       return _buildSkeletonList(colors);
//     }

//     if (provider.error != null && provider.items.isEmpty) {
//       return _buildErrorState(colors, provider);
//     }

//     if (provider.items.isEmpty) {
//       return _buildEmptyState(colors);
//     }

//     return ListView.builder(
//       controller: _scrollController,
//       physics: const AlwaysScrollableScrollPhysics(
//         parent: BouncingScrollPhysics(),
//       ),
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
//       itemCount: provider.items.length + (provider.hasMore ? 1 : 0),
//       itemBuilder: (context, index) {
//         if (index >= provider.items.length) {
//           return _buildLoadMoreIndicator(colors, provider);
//         }

//         final notification = provider.items[index];
//         return _StaggeredEntry(
//           index: index,
//           child: _NotificationTile(
//             notification: notification,
//             colors: colors,
//             onTap: () => _handleTap(notification, provider),
//           ),
//         );
//       },
//     );
//   }

//   void _handleTap(AppNotification notification, NotificationProvider provider) {
//     HapticFeedback.lightImpact();
//     provider.markAsRead(notification);

//     // Optional deep-link routing based on notification.type / notification.data
//     // e.g. if (notification.type == 'order') Get.toNamed('/orders/${notification.data?['order_id']}');
//   }

//   Widget _buildLoadMoreIndicator(
//     AppColors colors,
//     NotificationProvider provider,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 20),
//       child: Center(
//         child: SizedBox(
//           width: 22,
//           height: 22,
//           child: CircularProgressIndicator(
//             strokeWidth: 2.2,
//             color: colors.primary,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSkeletonList(AppColors colors) {
//     return ListView.builder(
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
//       itemCount: 6,
//       itemBuilder: (context, index) => _SkeletonTile(colors: colors),
//     );
//   }

//   Widget _buildEmptyState(AppColors colors) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(
//             parent: BouncingScrollPhysics(),
//           ),
//           child: ConstrainedBox(
//             constraints: BoxConstraints(minHeight: constraints.maxHeight),
//             child: Center(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 40),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       width: 96,
//                       height: 96,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         gradient: LinearGradient(
//                           colors: [
//                             colors.primary.withOpacity(0.15),
//                             colors.secondary.withOpacity(0.10),
//                           ],
//                         ),
//                       ),
//                       child: Icon(
//                         Icons.notifications_none_rounded,
//                         size: 44,
//                         color: colors.primary,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     Text(
//                       'no_notifications_title'.tr,
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                         color: colors.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       'no_notifications_subtitle'.tr,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: colors.textSecondary,
//                         height: 1.4,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildErrorState(AppColors colors, NotificationProvider provider) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(
//             parent: BouncingScrollPhysics(),
//           ),
//           child: ConstrainedBox(
//             constraints: BoxConstraints(minHeight: constraints.maxHeight),
//             child: Center(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 40),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.wifi_off_rounded,
//                       size: 40,
//                       color: colors.textSecondary,
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       provider.error ?? 'something_went_wrong'.tr,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: colors.textSecondary),
//                     ),
//                     const SizedBox(height: 16),
//                     TextButton(
//                       onPressed: provider.loadFirstPage,
//                       child: Text(
//                         'retry'.tr,
//                         style: TextStyle(
//                           color: colors.primary,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// /// Wraps each list item in the same staggered fade + slide entrance used
// /// across the rest of mart_frontend (Home, Orders, Favorites, etc.).
// class _StaggeredEntry extends StatefulWidget {
//   final int index;
//   final Widget child;

//   const _StaggeredEntry({required this.index, required this.child});

//   @override
//   State<_StaggeredEntry> createState() => _StaggeredEntryState();
// }

// class _StaggeredEntryState extends State<_StaggeredEntry>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;
//   late final Animation<double> _fade;
//   late final Animation<Offset> _slide;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 420),
//     );

//     _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
//     _slide = Tween<Offset>(
//       begin: const Offset(0, 0.08),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

//     final delay = Duration(milliseconds: 40 * widget.index.clamp(0, 8));
//     Future.delayed(delay, () {
//       if (mounted) _controller.forward();
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _fade,
//       child: SlideTransition(position: _slide, child: widget.child),
//     );
//   }
// }

// class _NotificationTile extends StatefulWidget {
//   final AppNotification notification;
//   final AppColors colors;
//   final VoidCallback onTap;

//   const _NotificationTile({
//     required this.notification,
//     required this.colors,
//     required this.onTap,
//   });

//   @override
//   State<_NotificationTile> createState() => _NotificationTileState();
// }

// class _NotificationTileState extends State<_NotificationTile> {
//   double _scale = 1.0;

//   void _onTapDown(_) => setState(() => _scale = 0.98);
//   void _onTapCancel() => setState(() => _scale = 1.0);
//   void _onTapUp(_) => setState(() => _scale = 1.0);

//   IconData _iconForType(String? type) {
//     switch (type) {
//       case 'order':
//         return Icons.shopping_bag_rounded;
//       case 'promo':
//         return Icons.local_offer_rounded;
//       case 'payment':
//         return Icons.qr_code_rounded;
//       default:
//         return Icons.notifications_rounded;
//     }
//   }

//   String _timeAgo(DateTime date) {
//     final diff = DateTime.now().difference(date);
//     if (diff.inSeconds < 60) return 'just_now'.tr;
//     if (diff.inMinutes < 60) return '${diff.inMinutes}m';
//     if (diff.inHours < 24) return '${diff.inHours}h';
//     if (diff.inDays < 7) return '${diff.inDays}d';
//     return '${date.day}/${date.month}/${date.year}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final n = widget.notification;
//     final colors = widget.colors;
//     final isUnread = !n.isRead;

//     return GestureDetector(
//       onTapDown: _onTapDown,
//       onTapCancel: _onTapCancel,
//       onTapUp: _onTapUp,
//       onTap: widget.onTap,
//       child: AnimatedScale(
//         scale: _scale,
//         duration: const Duration(milliseconds: 120),
//         curve: Curves.easeOut,
//         child: Container(
//           margin: const EdgeInsets.only(bottom: 12),
//           decoration: BoxDecoration(
//             color: colors.surface,
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(
//               color: isUnread
//                   ? colors.primary.withOpacity(0.18)
//                   : colors.border,
//               width: 1,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.03),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Unread accent bar
//               Container(
//                 width: 4,
//                 height: 74,
//                 margin: const EdgeInsets.only(left: 2),
//                 decoration: BoxDecoration(
//                   color: isUnread ? colors.primary : Colors.transparent,
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(4),
//                     bottomLeft: Radius.circular(4),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(14),
//                 child: Container(
//                   width: 44,
//                   height: 44,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [colors.primary, colors.secondary],
//                     ),
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: Icon(
//                     _iconForType(n.type),
//                     color: Colors.white,
//                     size: 21,
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.only(
//                     top: 14,
//                     right: 14,
//                     bottom: 14,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               n.title,
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                 fontSize: 14.5,
//                                 fontWeight: isUnread
//                                     ? FontWeight.w700
//                                     : FontWeight.w600,
//                                 color: colors.textPrimary,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             _timeAgo(n.createdAt),
//                             style: TextStyle(
//                               fontSize: 11,
//                               color: colors.textSecondary,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         n.body,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           fontSize: 12.5,
//                           color: colors.textSecondary,
//                           height: 1.35,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               if (isUnread)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 16, right: 14),
//                   child: Container(
//                     width: 8,
//                     height: 8,
//                     decoration: BoxDecoration(
//                       color: colors.primary,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// Simple pulsing placeholder shown while the first page loads.
// class _SkeletonTile extends StatefulWidget {
//   final AppColors colors;
//   const _SkeletonTile({required this.colors});

//   @override
//   State<_SkeletonTile> createState() => _SkeletonTileState();
// }

// class _SkeletonTileState extends State<_SkeletonTile>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller = AnimationController(
//     vsync: this,
//     duration: const Duration(milliseconds: 900),
//   )..repeat(reverse: true);

//   late final Animation<double> _opacity = Tween<double>(
//     begin: 0.5,
//     end: 1.0,
//   ).animate(_controller);

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = widget.colors;
//     return FadeTransition(
//       opacity: _opacity,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         height: 90,
//         decoration: BoxDecoration(
//           color: colors.surface,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: colors.border),
//         ),
//         child: Row(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(14),
//               child: Container(
//                 width: 44,
//                 height: 44,
//                 decoration: BoxDecoration(
//                   color: colors.border,
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.only(right: 14),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: double.infinity,
//                       height: 12,
//                       decoration: BoxDecoration(
//                         color: colors.border,
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Container(
//                       width: 160,
//                       height: 10,
//                       decoration: BoxDecoration(
//                         color: colors.border,
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
