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

// lib/screens/notification/notification_screen.dart
//
// Everything the Notification screen needs in one file:
// AppBar (title + unread badge + mark-all-as-read), list with
// loading/empty/error states, pull-to-refresh, pagination, and the
// notification card widget itself.
//
// Depends only on your existing:
//   - models/notification_model.dart      (AppNotification, NotificationPage)
//   - providers/notification_provider.dart (NotificationProvider)
//   - theme/app_colors.dart                (AppColors, context.colors)

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';


import '../../models/notification_model.dart'; // adjust import path
import '../../providers/notification_provider.dart';
import '../theme/app_theme.dart'; // adjust import path

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NotificationProvider>().fetchNotifications(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final provider = context.read<NotificationProvider>();

    // Guard: never fire a second request while one is in flight, and
    // never fire once there are no more pages.
    if (provider.isLoadingMore || !provider.hasMore) return;

    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      provider.loadMore();
    }
  }

  Future<void> _handleTap(
    AppNotification notification,
    NotificationProvider provider,
  ) async {
    if (!notification.isRead) {
      await provider.markAsRead(notification.id);
      if (!mounted) return;
    }
    // Optional deep-link routing based on notification.type / notification.data
    // e.g. if (notification.type == 'order') Get.toNamed('/orders/${notification.data?['order_id']}');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(colors),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return _buildLoadingState(colors);
          }

          if (provider.error != null && provider.notifications.isEmpty) {
            return _buildErrorState(colors, provider);
          }

          if (provider.notifications.isEmpty) {
            return _buildEmptyState(colors, provider);
          }

          return RefreshIndicator(
            color: colors.accent,
            backgroundColor: colors.surface,
            onRefresh: () => provider.fetchNotifications(refresh: true),
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount:
                  provider.notifications.length + (provider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= provider.notifications.length) {
                  return _buildFooter(colors, provider);
                }

                final item = provider.notifications[index];
                return _NotificationItem(
                  notification: item,
                  onTap: () => _handleTap(item, provider),
                );
              },
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppColors colors) {
    return AppBar(
      backgroundColor: colors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      foregroundColor: colors.text1,
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: colors.text1,
        ),
        onPressed: () => Get.back(),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'notifications'.tr,
            style: TextStyle(
              color: colors.text1,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 8),
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.unreadCount == 0) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${provider.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            final enabled = provider.unreadCount > 0;
            return TextButton(
              onPressed: enabled ? provider.markAllAsRead : null,
              child: Text(
                'mark_all_read'.tr,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: enabled ? colors.accent : colors.text3,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLoadingState(AppColors colors) {
    return Center(
      child: LoadingAnimationWidget.staggeredDotsWave(
        color: colors.accent,
        size: 42,
      ),
    );
  }

  Widget _buildEmptyState(AppColors colors, NotificationProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          color: colors.accent,
          backgroundColor: colors.surface,
          onRefresh: () => provider.fetchNotifications(refresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.bgicon,
                        ),
                        child: Icon(
                          Icons.notifications_none_rounded,
                          size: 44,
                          color: colors.accent,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'no_notifications_title'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colors.text1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'no_notifications_subtitle'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.text3,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(AppColors colors, NotificationProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi_off_rounded, size: 40, color: colors.text3),
                    const SizedBox(height: 16),
                    Text(
                      provider.error ?? 'something_went_wrong'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.text2),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          provider.fetchNotifications(refresh: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text('retry'.tr),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter(AppColors colors, NotificationProvider provider) {
    if (provider.isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: colors.accent,
            size: 28,
          ),
        ),
      );
    }

    // Inline "load more failed" state — list already has items loaded,
    // so we don't blow away the whole screen, just offer a retry here.
    if (provider.error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: TextButton(
            onPressed: () {
              provider.clearError();
              provider.loadMore();
            },
            child: Text('tap_to_retry'.tr),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

// ============================================================================
// NOTIFICATION ITEM WIDGET (kept private to this file, on purpose)
// ============================================================================

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isUnread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread
              ? colors.accentLight.withOpacity(0.35)
              : colors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread ? colors.accent.withOpacity(0.25) : colors.border,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(colors, notification.type, isUnread),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            color: colors.text1,
                            fontWeight: isUnread
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isUnread) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body.isNotEmpty ? notification.body : '—',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: isUnread ? colors.text2 : colors.text3,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (notification.imageUrl != null &&
                      notification.imageUrl!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: notification.imageUrl!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(height: 120, color: colors.surface2),
                        errorWidget: (context, url, error) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTypeBadge(colors, notification.type),
                      const Spacer(),
                      Text(
                        _timeAgo(notification.createdAt),
                        style: TextStyle(fontSize: 11, color: colors.text3),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(AppColors colors, String? type, bool isUnread) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: isUnread ? colors.accent.withOpacity(0.12) : colors.bgicon,
        shape: BoxShape.circle,
      ),
      child: Icon(
        _iconForType(type),
        size: 20,
        color: isUnread ? colors.accent : colors.text3,
      ),
    );
  }

  Widget _buildTypeBadge(AppColors colors, String? type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _labelForType(type),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: colors.text2,
        ),
      ),
    );
  }

  static IconData _iconForType(String? type) {
    switch (type) {
      case 'promotion':
        return Icons.local_offer;
      case 'order':
        return Icons.shopping_bag;
      case 'payment':
        return Icons.payment;
      case 'delivery':
        return Icons.local_shipping;
      default:
        return Icons.notifications;
    }
  }

  static String _labelForType(String? type) {
    switch (type) {
      case 'promotion':
        return 'Promotion';
      case 'order':
        return 'Order';
      case 'payment':
        return 'Payment';
      case 'delivery':
        return 'Delivery';
      default:
        return 'General';
    }
  }

  static String _timeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.isNegative || diff.inSeconds < 60) {
      return 'Just now';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} ${diff.inHours == 1 ? 'hour' : 'hours'} ago';
    }
    if (diff.inDays == 1) {
      return 'Yesterday';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    }

    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year}';
  }
}
