// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import '../services/api_service.dart';
// // import '../screens/theme/app_theme.dart';

// // class ProductDetailScreen extends StatefulWidget {
// //   final int productId;

// //   const ProductDetailScreen({super.key, required this.productId});

// //   @override
// //   State<ProductDetailScreen> createState() => _ProductDetailScreenState();
// // }

// // class _ProductDetailScreenState extends State<ProductDetailScreen>
// //     with TickerProviderStateMixin {
// //   late Future<dynamic> productFuture;

// //   int qty = 1;
// //   int imageIndex = 0;
// //   bool isFavorite = false;

// //   late AnimationController _favoriteController;
// //   late AnimationController _fadeController;
// //   late AnimationController _shimmerController;
// //   late Animation<double> _favoriteScale;
// //   late Animation<double> _fadeAnimation;
// //   late Animation<double> _shimmerAnimation;

// //   @override
// //   void initState() {
// //     super.initState();
// //     productFuture = ApiService().fetchProduct(widget.productId);

// //     _favoriteController = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 300),
// //     );
// //     _favoriteScale =
// //         TweenSequence([
// //           TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
// //           TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
// //         ]).animate(
// //           CurvedAnimation(parent: _favoriteController, curve: Curves.easeInOut),
// //         );

// //     _fadeController = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 500),
// //     );
// //     _fadeAnimation = CurvedAnimation(
// //       parent: _fadeController,
// //       curve: Curves.easeOut,
// //     );
// //     _fadeController.forward();

// //     // Shimmer controller for skeleton
// //     _shimmerController = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 1400),
// //     )..repeat();
// //     _shimmerAnimation = Tween<double>(begin: -1.5, end: 1.5).animate(
// //       CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _favoriteController.dispose();
// //     _fadeController.dispose();
// //     _shimmerController.dispose();
// //     super.dispose();
// //   }

// //   void _toggleFavorite() {
// //     HapticFeedback.lightImpact();
// //     setState(() => isFavorite = !isFavorite);
// //     _favoriteController.forward(from: 0);
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final colors = context.colors;
// //     final s = MediaQuery.of(context).size.shortestSide;
// //     final theme = Theme.of(context);

// //     return Scaffold(
// //       backgroundColor: theme.scaffoldBackgroundColor,
// //       body: FutureBuilder(
// //         future: productFuture,
// //         builder: (context, snapshot) {
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             return _buildSkeleton(context, colors, s, theme);
// //           }

// //           if (snapshot.hasError) {
// //             return _buildError();
// //           }

// //           final p = snapshot.data;
// //           final images = p.images ?? [];

// //           return FadeTransition(
// //             opacity: _fadeAnimation,
// //             child: CustomScrollView(
// //               physics: const BouncingScrollPhysics(),
// //               slivers: [
// //                 // ── Hero Image SliverAppBar ──────────────────────────
// //                 SliverAppBar(
// //                   expandedHeight: s * 0.74,
// //                   pinned: true,
// //                   elevation: 0,
// //                   backgroundColor: Colors.transparent,
// //                   systemOverlayStyle: SystemUiOverlayStyle.light,
// //                   automaticallyImplyLeading: false,

// //                   flexibleSpace: FlexibleSpaceBar(
// //                     collapseMode: CollapseMode.pin,
// //                     background: Stack(
// //                       fit: StackFit.expand,
// //                       children: [
// //                         // Image carousel
// //                         PageView.builder(
// //                           itemCount: images.length,
// //                           onPageChanged: (i) => setState(() => imageIndex = i),
// //                           itemBuilder: (_, i) => Image.network(
// //                             images[i],
// //                             fit: BoxFit.cover,
// //                             width: double.infinity,
// //                           ),
// //                         ),

// //                         // Gradient overlay (bottom fade)
// //                         Positioned(
// //                           bottom: 0,
// //                           left: 0,
// //                           right: 0,
// //                           height: 120,
// //                           child: DecoratedBox(
// //                             decoration: BoxDecoration(
// //                               gradient: LinearGradient(
// //                                 begin: Alignment.topCenter,
// //                                 end: Alignment.bottomCenter,
// //                                 colors: [
// //                                   Colors.transparent,
// //                                   Colors.black.withOpacity(0.45),
// //                                 ],
// //                               ),
// //                             ),
// //                           ),
// //                         ),

// //                         // Gradient overlay (top — for icons)
// //                         Positioned(
// //                           top: 0,
// //                           left: 0,
// //                           right: 0,
// //                           height: 140,
// //                           child: DecoratedBox(
// //                             decoration: BoxDecoration(
// //                               gradient: LinearGradient(
// //                                 begin: Alignment.topCenter,
// //                                 end: Alignment.bottomCenter,
// //                                 colors: [
// //                                   Colors.black.withOpacity(0.38),
// //                                   Colors.transparent,
// //                                 ],
// //                               ),
// //                             ),
// //                           ),
// //                         ),

// //                         // Discount badge
// //                         if (p.discount != null)
// //                           Positioned(
// //                             top: MediaQuery.of(context).padding.top + 60,
// //                             left: 20,
// //                             child: _DiscountBadge(label: p.discount),
// //                           ),

// //                         // Dot indicators
// //                         if (images.length > 1)
// //                           Positioned(
// //                             bottom: 22,
// //                             left: 0,
// //                             right: 0,
// //                             child: _DotIndicator(
// //                               count: images.length,
// //                               activeIndex: imageIndex,
// //                               activeColor: Colors.white,
// //                             ),
// //                           ),
// //                       ],
// //                     ),
// //                   ),

// //                   leading: SafeArea(
// //                     child: Padding(
// //                       padding: const EdgeInsets.only(left: 16, top: 8),
// //                       child: _CircleButton(
// //                         onTap: () => Navigator.pop(context),
// //                         child: const Icon(
// //                           Icons.arrow_back_ios_new_rounded,
// //                           color: Colors.white,
// //                           size: 18,
// //                         ),
// //                       ),
// //                     ),
// //                   ),

// //                   actions: [
// //                     SafeArea(
// //                       child: Padding(
// //                         padding: const EdgeInsets.only(right: 16, top: 8),
// //                         child: ScaleTransition(
// //                           scale: _favoriteScale,
// //                           child: _CircleButton(
// //                             onTap: _toggleFavorite,
// //                             child: AnimatedSwitcher(
// //                               duration: const Duration(milliseconds: 250),
// //                               transitionBuilder: (child, anim) =>
// //                                   ScaleTransition(scale: anim, child: child),
// //                               child: Icon(
// //                                 isFavorite
// //                                     ? Icons.favorite_rounded
// //                                     : Icons.favorite_border_rounded,
// //                                 key: ValueKey(isFavorite),
// //                                 color: isFavorite
// //                                     ? const Color(0xFFFF4C6A)
// //                                     : Colors.white,
// //                                 size: 20,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),

// //                 // ── Content ─────────────────────────────────────────
// //                 SliverToBoxAdapter(
// //                   child: Container(
// //                     decoration: BoxDecoration(
// //                       color: theme.scaffoldBackgroundColor,
// //                       borderRadius: const BorderRadius.vertical(
// //                         top: Radius.circular(28),
// //                       ),
// //                     ),
// //                     child: Padding(
// //                       padding: EdgeInsets.fromLTRB(
// //                         s * .055,
// //                         s * .055,
// //                         s * .055,
// //                         0,
// //                       ),
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           // Drag handle
// //                           Center(
// //                             child: Container(
// //                               width: 40,
// //                               height: 4,
// //                               margin: const EdgeInsets.only(bottom: 24),
// //                               decoration: BoxDecoration(
// //                                 color: colors.text3.withOpacity(0.25),
// //                                 borderRadius: BorderRadius.circular(2),
// //                               ),
// //                             ),
// //                           ),

// //                           // Category + Brand chips
// //                           Row(
// //                             children: [
// //                               _Chip(
// //                                 label: p.categoryName ?? "",
// //                                 colors: colors,
// //                               ),
// //                               const SizedBox(width: 8),
// //                               _Chip(label: p.brandName ?? "", colors: colors),
// //                             ],
// //                           ),

// //                           const SizedBox(height: 14),

// //                           // Product name
// //                           Text(
// //                             p.name,
// //                             style: const TextStyle(
// //                               fontSize: 26,
// //                               fontWeight: FontWeight.w800,
// //                               letterSpacing: -0.5,
// //                               height: 1.2,
// //                             ),
// //                           ),

// //                           const SizedBox(height: 16),

// //                           // Price row
// //                           Row(
// //                             crossAxisAlignment: CrossAxisAlignment.end,
// //                             children: [
// //                               Text(
// //                                 "\$${p.finalPrice}",
// //                                 style: TextStyle(
// //                                   fontSize: 30,
// //                                   fontWeight: FontWeight.w900,
// //                                   color: colors.accent,
// //                                   letterSpacing: -1,
// //                                 ),
// //                               ),
// //                               if (p.discount != null) ...[
// //                                 const SizedBox(width: 10),
// //                                 Padding(
// //                                   padding: const EdgeInsets.only(bottom: 3),
// //                                   child: Text(
// //                                     "\$${p.salePrice}",
// //                                     style: TextStyle(
// //                                       fontSize: 16,
// //                                       decoration: TextDecoration.lineThrough,
// //                                       color: colors.text3,
// //                                       fontWeight: FontWeight.w500,
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ],
// //                             ],
// //                           ),

// //                           const SizedBox(height: 28),

// //                           Divider(
// //                             color: colors.text3.withOpacity(0.12),
// //                             height: 1,
// //                           ),

// //                           const SizedBox(height: 28),

// //                           // Description
// //                           const Text(
// //                             "Description",
// //                             style: TextStyle(
// //                               fontSize: 17,
// //                               fontWeight: FontWeight.w700,
// //                               letterSpacing: -0.2,
// //                             ),
// //                           ),

// //                           const SizedBox(height: 10),

// //                           Text(
// //                             p.description ?? "",
// //                             style: TextStyle(
// //                               height: 1.65,
// //                               fontSize: 14.5,
// //                               color: colors.text3,
// //                             ),
// //                           ),

// //                           const SizedBox(height: 32),

// //                           Divider(
// //                             color: colors.text3.withOpacity(0.12),
// //                             height: 1,
// //                           ),

// //                           const SizedBox(height: 28),

// //                           // Quantity row
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                             children: [
// //                               const Text(
// //                                 "Quantity",
// //                                 style: TextStyle(
// //                                   fontSize: 17,
// //                                   fontWeight: FontWeight.w700,
// //                                   letterSpacing: -0.2,
// //                                 ),
// //                               ),
// //                               _QuantitySelector(
// //                                 qty: qty,
// //                                 accent: colors.accent,
// //                                 surface: colors.surface,
// //                                 onDecrement: () {
// //                                   if (qty > 1) setState(() => qty--);
// //                                 },
// //                                 onIncrement: () => setState(() => qty++),
// //                               ),
// //                             ],
// //                           ),

// //                           const SizedBox(height: 36),

// //                           _AddToCartButton(accent: colors.accent),

// //                           SizedBox(
// //                             height: MediaQuery.of(context).padding.bottom + 32,
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   // ── SKELETON ────────────────────────────────────────────────────────────────

// //   Widget _buildSkeleton(
// //     BuildContext context,
// //     dynamic colors,
// //     double s,
// //     ThemeData theme,
// //   ) {
// //     return AnimatedBuilder(
// //       animation: _shimmerAnimation,
// //       builder: (context, _) {
// //         return CustomScrollView(
// //           physics: const NeverScrollableScrollPhysics(),
// //           slivers: [
// //             // ── Skeleton Hero ──
// //             SliverAppBar(
// //               expandedHeight: s * 0.74,
// //               pinned: true,
// //               elevation: 0,
// //               backgroundColor: Colors.transparent,
// //               automaticallyImplyLeading: false,
// //               flexibleSpace: FlexibleSpaceBar(
// //                 collapseMode: CollapseMode.pin,
// //                 background: Stack(
// //                   fit: StackFit.expand,
// //                   children: [
// //                     // Shimmer image placeholder
// //                     _SkeletonBox(
// //                       shimmer: _shimmerAnimation.value,
// //                       colors: colors,
// //                       borderRadius: 0,
// //                     ),

// //                     // Top bar placeholder
// //                     Positioned(
// //                       top: MediaQuery.of(context).padding.top + 8,
// //                       left: 16,
// //                       right: 16,
// //                       child: Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           _SkeletonCircle(
// //                             size: 40,
// //                             shimmer: _shimmerAnimation.value,
// //                             colors: colors,
// //                           ),
// //                           _SkeletonCircle(
// //                             size: 40,
// //                             shimmer: _shimmerAnimation.value,
// //                             colors: colors,
// //                           ),
// //                         ],
// //                       ),
// //                     ),

// //                     // Dot indicators placeholder
// //                     Positioned(
// //                       bottom: 22,
// //                       left: 0,
// //                       right: 0,
// //                       child: Row(
// //                         mainAxisAlignment: MainAxisAlignment.center,
// //                         children: List.generate(3, (i) {
// //                           return AnimatedContainer(
// //                             duration: Duration.zero,
// //                             margin: const EdgeInsets.symmetric(horizontal: 3.5),
// //                             width: i == 0 ? 20 : 7,
// //                             height: 7,
// //                             decoration: BoxDecoration(
// //                               color: Colors.white.withOpacity(
// //                                 i == 0 ? 0.5 : 0.2,
// //                               ),
// //                               borderRadius: BorderRadius.circular(4),
// //                             ),
// //                           );
// //                         }),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),

// //             // ── Skeleton Content ──
// //             SliverToBoxAdapter(
// //               child: Container(
// //                 decoration: BoxDecoration(
// //                   color: theme.scaffoldBackgroundColor,
// //                   borderRadius: const BorderRadius.vertical(
// //                     top: Radius.circular(28),
// //                   ),
// //                 ),
// //                 padding: EdgeInsets.fromLTRB(s * .055, s * .055, s * .055, 0),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     // Drag handle
// //                     Center(
// //                       child: Container(
// //                         width: 40,
// //                         height: 4,
// //                         margin: const EdgeInsets.only(bottom: 24),
// //                         decoration: BoxDecoration(
// //                           color: colors.text3.withOpacity(0.15),
// //                           borderRadius: BorderRadius.circular(2),
// //                         ),
// //                       ),
// //                     ),

// //                     // Category + Brand chips
// //                     Row(
// //                       children: [
// //                         _SkeletonBox(
// //                           shimmer: _shimmerAnimation.value,
// //                           colors: colors,
// //                           width: 90,
// //                           height: 30,
// //                           borderRadius: 8,
// //                         ),
// //                         const SizedBox(width: 8),
// //                         _SkeletonBox(
// //                           shimmer: _shimmerAnimation.value,
// //                           colors: colors,
// //                           width: 70,
// //                           height: 30,
// //                           borderRadius: 8,
// //                         ),
// //                       ],
// //                     ),

// //                     const SizedBox(height: 18),

// //                     // Product name — 2 lines
// //                     _SkeletonBox(
// //                       shimmer: _shimmerAnimation.value,
// //                       colors: colors,
// //                       width: double.infinity,
// //                       height: 22,
// //                       borderRadius: 6,
// //                     ),
// //                     const SizedBox(height: 8),
// //                     _SkeletonBox(
// //                       shimmer: _shimmerAnimation.value,
// //                       colors: colors,
// //                       width: 200,
// //                       height: 22,
// //                       borderRadius: 6,
// //                     ),

// //                     const SizedBox(height: 20),

// //                     // Price
// //                     _SkeletonBox(
// //                       shimmer: _shimmerAnimation.value,
// //                       colors: colors,
// //                       width: 120,
// //                       height: 32,
// //                       borderRadius: 6,
// //                     ),

// //                     const SizedBox(height: 28),

// //                     Divider(color: colors.text3.withOpacity(0.10), height: 1),

// //                     const SizedBox(height: 28),

// //                     // Description label
// //                     _SkeletonBox(
// //                       shimmer: _shimmerAnimation.value,
// //                       colors: colors,
// //                       width: 100,
// //                       height: 17,
// //                       borderRadius: 4,
// //                     ),

// //                     const SizedBox(height: 14),

// //                     // Description lines
// //                     ...[1.0, 1.0, 1.0, 0.65].map(
// //                       (w) => Padding(
// //                         padding: const EdgeInsets.only(bottom: 8),
// //                         child: _SkeletonBox(
// //                           shimmer: _shimmerAnimation.value,
// //                           colors: colors,
// //                           width: w == 1.0
// //                               ? double.infinity
// //                               : MediaQuery.of(context).size.width * w * 0.75,
// //                           height: 13,
// //                           borderRadius: 4,
// //                         ),
// //                       ),
// //                     ),

// //                     const SizedBox(height: 24),

// //                     Divider(color: colors.text3.withOpacity(0.10), height: 1),

// //                     const SizedBox(height: 28),

// //                     // Quantity row
// //                     Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                       children: [
// //                         _SkeletonBox(
// //                           shimmer: _shimmerAnimation.value,
// //                           colors: colors,
// //                           width: 90,
// //                           height: 17,
// //                           borderRadius: 4,
// //                         ),
// //                         _SkeletonBox(
// //                           shimmer: _shimmerAnimation.value,
// //                           colors: colors,
// //                           width: 110,
// //                           height: 42,
// //                           borderRadius: 14,
// //                         ),
// //                       ],
// //                     ),

// //                     const SizedBox(height: 36),

// //                     // Add to cart button
// //                     _SkeletonBox(
// //                       shimmer: _shimmerAnimation.value,
// //                       colors: colors,
// //                       width: double.infinity,
// //                       height: 56,
// //                       borderRadius: 16,
// //                     ),

// //                     SizedBox(
// //                       height: MediaQuery.of(context).padding.bottom + 32,
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildError() {
// //     return const Center(
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
// //           SizedBox(height: 12),
// //           Text(
// //             "Failed to load product",
// //             style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // ── Skeleton Primitives ──────────────────────────────────────────────────────

// // class _SkeletonBox extends StatelessWidget {
// //   final double shimmer;
// //   final dynamic colors;
// //   final double? width;
// //   final double? height;
// //   final double borderRadius;

// //   const _SkeletonBox({
// //     required this.shimmer,
// //     required this.colors,
// //     this.width,
// //     this.height,
// //     this.borderRadius = 8,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     final isDark = Theme.of(context).brightness == Brightness.dark;
// //     final base = isDark ? const Color(0xFF1E1E24) : const Color(0xFFEEEEEE);
// //     final highlight = isDark
// //         ? const Color(0xFF2C2C36)
// //         : const Color(0xFFFAFAFA);

// //     return ClipRRect(
// //       borderRadius: BorderRadius.circular(borderRadius),
// //       child: SizedBox(
// //         width: width,
// //         height: height ?? 16,
// //         child: AnimatedBuilder(
// //           animation: AlwaysStoppedAnimation(shimmer),
// //           builder: (_, __) => CustomPaint(
// //             painter: _ShimmerPainter(
// //               shimmer: shimmer,
// //               base: base,
// //               highlight: highlight,
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class _SkeletonCircle extends StatelessWidget {
// //   final double size;
// //   final double shimmer;
// //   final dynamic colors;

// //   const _SkeletonCircle({
// //     required this.size,
// //     required this.shimmer,
// //     required this.colors,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     final isDark = Theme.of(context).brightness == Brightness.dark;
// //     final base = isDark
// //         ? Colors.white.withOpacity(0.12)
// //         : Colors.black.withOpacity(0.10);
// //     final highlight = isDark
// //         ? Colors.white.withOpacity(0.22)
// //         : Colors.black.withOpacity(0.04);

// //     return ClipOval(
// //       child: SizedBox(
// //         width: size,
// //         height: size,
// //         child: CustomPaint(
// //           painter: _ShimmerPainter(
// //             shimmer: shimmer,
// //             base: base,
// //             highlight: highlight,
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class _ShimmerPainter extends CustomPainter {
// //   final double shimmer;
// //   final Color base;
// //   final Color highlight;

// //   const _ShimmerPainter({
// //     required this.shimmer,
// //     required this.base,
// //     required this.highlight,
// //   });

// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     final rect = Offset.zero & size;
// //     final gradient = LinearGradient(
// //       begin: Alignment.centerLeft,
// //       end: Alignment.centerRight,
// //       colors: [base, highlight, base],
// //       stops: const [0.0, 0.5, 1.0],
// //       transform: _SlideGradient(shimmer),
// //     );
// //     canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
// //   }

// //   @override
// //   bool shouldRepaint(_ShimmerPainter old) =>
// //       old.shimmer != shimmer || old.base != base || old.highlight != highlight;
// // }

// // class _SlideGradient implements GradientTransform {
// //   final double slide;
// //   const _SlideGradient(this.slide);

// //   @override
// //   Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
// //     return Matrix4.translationValues(bounds.width * slide, 0, 0);
// //   }
// // }

// // // ── Sub-widgets ──────────────────────────────────────────────────────────────

// // class _CircleButton extends StatelessWidget {
// //   final VoidCallback onTap;
// //   final Widget child;

// //   const _CircleButton({required this.onTap, required this.child});

// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         width: 40,
// //         height: 40,
// //         decoration: BoxDecoration(
// //           color: Colors.black.withOpacity(0.3),
// //           shape: BoxShape.circle,
// //           border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
// //         ),
// //         child: Center(child: child),
// //       ),
// //     );
// //   }
// // }

// // class _DiscountBadge extends StatelessWidget {
// //   final String label;

// //   const _DiscountBadge({required this.label});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //       decoration: BoxDecoration(
// //         color: const Color(0xFFFF4C6A),
// //         borderRadius: BorderRadius.circular(24),
// //         boxShadow: [
// //           BoxShadow(
// //             color: const Color(0xFFFF4C6A).withOpacity(0.35),
// //             blurRadius: 8,
// //             offset: const Offset(0, 3),
// //           ),
// //         ],
// //       ),
// //       child: Text(
// //         label,
// //         style: const TextStyle(
// //           color: Colors.white,
// //           fontWeight: FontWeight.w700,
// //           fontSize: 13,
// //           letterSpacing: 0.2,
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class _DotIndicator extends StatelessWidget {
// //   final int count;
// //   final int activeIndex;
// //   final Color activeColor;

// //   const _DotIndicator({
// //     required this.count,
// //     required this.activeIndex,
// //     required this.activeColor,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.center,
// //       children: List.generate(count, (i) {
// //         final isActive = i == activeIndex;
// //         return AnimatedContainer(
// //           duration: const Duration(milliseconds: 280),
// //           curve: Curves.easeInOut,
// //           margin: const EdgeInsets.symmetric(horizontal: 3.5),
// //           width: isActive ? 20 : 7,
// //           height: 7,
// //           decoration: BoxDecoration(
// //             color: isActive ? activeColor : activeColor.withOpacity(0.4),
// //             borderRadius: BorderRadius.circular(4),
// //           ),
// //         );
// //       }),
// //     );
// //   }
// // }

// // class _Chip extends StatelessWidget {
// //   final String label;
// //   final dynamic colors;

// //   const _Chip({required this.label, required this.colors});

// //   @override
// //   Widget build(BuildContext context) {
// //     if (label.isEmpty) return const SizedBox.shrink();
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //       decoration: BoxDecoration(
// //         color: colors.surface,
// //         borderRadius: BorderRadius.circular(8),
// //       ),
// //       child: Text(
// //         label,
// //         style: TextStyle(
// //           fontSize: 13,
// //           fontWeight: FontWeight.w600,
// //           color: colors.text3,
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class _QuantitySelector extends StatelessWidget {
// //   final int qty;
// //   final Color accent;
// //   final Color surface;
// //   final VoidCallback onDecrement;
// //   final VoidCallback onIncrement;

// //   const _QuantitySelector({
// //     required this.qty,
// //     required this.accent,
// //     required this.surface,
// //     required this.onDecrement,
// //     required this.onIncrement,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: surface,
// //         borderRadius: BorderRadius.circular(14),
// //       ),
// //       child: Row(
// //         children: [
// //           _QtyButton(
// //             icon: Icons.remove_rounded,
// //             onTap: onDecrement,
// //             enabled: qty > 1,
// //             accent: accent,
// //           ),
// //           AnimatedSwitcher(
// //             duration: const Duration(milliseconds: 180),
// //             transitionBuilder: (child, anim) =>
// //                 ScaleTransition(scale: anim, child: child),
// //             child: Text(
// //               "$qty",
// //               key: ValueKey(qty),
// //               style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
// //             ),
// //           ),
// //           _QtyButton(
// //             icon: Icons.add_rounded,
// //             onTap: onIncrement,
// //             enabled: true,
// //             accent: accent,
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class _QtyButton extends StatelessWidget {
// //   final IconData icon;
// //   final VoidCallback onTap;
// //   final bool enabled;
// //   final Color accent;

// //   const _QtyButton({
// //     required this.icon,
// //     required this.onTap,
// //     required this.enabled,
// //     required this.accent,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: enabled ? onTap : null,
// //       child: Padding(
// //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// //         child: Icon(
// //           icon,
// //           size: 20,
// //           color: enabled ? accent : accent.withOpacity(0.3),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class _AddToCartButton extends StatelessWidget {
// //   final Color accent;

// //   const _AddToCartButton({required this.accent});

// //   @override
// //   Widget build(BuildContext context) {
// //     return SizedBox(
// //       width: double.infinity,
// //       height: 56,
// //       child: ElevatedButton(
// //         onPressed: () {},
// //         style: ElevatedButton.styleFrom(
// //           backgroundColor: accent,
// //           foregroundColor: Colors.white,
// //           elevation: 0,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(16),
// //           ),
// //           shadowColor: accent.withOpacity(0.4),
// //         ),
// //         child: const Row(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(Icons.shopping_bag_outlined, size: 20),
// //             SizedBox(width: 10),
// //             Text(
// //               "Add to Cart",
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.w700,
// //                 letterSpacing: 0.3,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import '../../services/api_service.dart';
// import '../theme/app_theme.dart';

// class ProductDetailScreen extends StatefulWidget {
//   final int productId;

//   const ProductDetailScreen({super.key, required this.productId});

//   @override
//   State<ProductDetailScreen> createState() => _ProductDetailScreenState();
// }

// class _ProductDetailScreenState extends State<ProductDetailScreen>
//     with SingleTickerProviderStateMixin {
//   late Future<dynamic> productFuture;

//   int qty = 1;
//   int cartQty = 0;
//   bool isInCart = false;
//   bool cartLoading = false;
//   bool fav = false;

//   late AnimationController _shimmer;

//   @override
//   void initState() {
//     super.initState();
//     productFuture = ApiService().fetchProduct(widget.productId);
//     _loadCartQty();

//     _shimmer = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1000),
//     )..repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _shimmer.dispose();
//     super.dispose();
//   }

//   ////////////////////////////////////////////
//   /// CART LOGIC
//   ////////////////////////////////////////////

//   Future<void> _loadCartQty() async {
//     try {
//       final q = await ApiService().getCartQuantity(productId: widget.productId);

//       setState(() {
//         cartQty = q;
//         qty = q > 0 ? q : 1;
//         isInCart = q > 0;
//       });
//     } catch (_) {}
//   }

//   Future<void> _handleCart(dynamic p) async {
//     setState(() => cartLoading = true);

//     try {
//       if (isInCart) {
//         await ApiService().updateCart(
//           productId: widget.productId,
//           quantity: qty,
//         );
//       } else {
//         await ApiService().addToCart(
//           productId: widget.productId,
//           quantity: qty,
//         );
//       }

//       setState(() {
//         isInCart = true;
//         cartQty = qty;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(isInCart ? "Cart updated" : "Added to cart"),
//           duration: const Duration(milliseconds: 900),
//         ),
//       );
//     } catch (_) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Error")));
//     } finally {
//       setState(() => cartLoading = false);
//     }
//   }

//   ////////////////////////////////////////////
//   /// BUILD
//   ////////////////////////////////////////////

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final s = MediaQuery.of(context).size.shortestSide;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       body: FutureBuilder(
//         future: productFuture,
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return _Skeleton(shimmer: _shimmer);
//           }

//           final p = snapshot.data;
//           final images = p.images ?? [];

//           return Stack(
//             children: [
//               /// IMAGE
//               Positioned.fill(
//                 child: Image.network(
//                   images.isNotEmpty ? images.first : "",
//                   fit: BoxFit.cover,
//                 ),
//               ),

//               /// TOP BUTTONS
//               Positioned(
//                 top: MediaQuery.of(context).padding.top + 10,
//                 left: 16,
//                 child: _CircleBtn(
//                   icon: Icons.arrow_back_ios_new,
//                   onTap: () => Navigator.pop(context),
//                 ),
//               ),

//               Positioned(
//                 top: MediaQuery.of(context).padding.top + 10,
//                 right: 16,
//                 child: _CircleBtn(
//                   icon: fav ? Icons.favorite : Icons.favorite_border,
//                   onTap: () => setState(() => fav = !fav),
//                 ),
//               ),

//               /// CONTENT
//               Column(
//                 children: [
//                   SizedBox(height: MediaQuery.of(context).size.height * 0.45),

//                   Expanded(
//                     child: Stack(
//                       children: [
//                         /// CARD
//                         Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: const BorderRadius.vertical(
//                               top: Radius.circular(32),
//                             ),
//                           ),
//                           padding: EdgeInsets.fromLTRB(
//                             s * .05,
//                             s * .05,
//                             s * .05,
//                             s * .25,
//                           ),
//                           child: SingleChildScrollView(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Center(
//                                   child: Container(
//                                     width: 40,
//                                     height: 4,
//                                     margin: const EdgeInsets.only(bottom: 20),
//                                     decoration: BoxDecoration(
//                                       color: Colors.grey.shade300,
//                                       borderRadius: BorderRadius.circular(2),
//                                     ),
//                                   ),
//                                 ),

//                                 Row(
//                                   children: [
//                                     _Tag(label: p.categoryName ?? ""),
//                                     const SizedBox(width: 6),
//                                     _Tag(label: p.brandName ?? ""),
//                                   ],
//                                 ),

//                                 const SizedBox(height: 12),

//                                 Text(
//                                   p.name,
//                                   style: const TextStyle(
//                                     fontSize: 22,
//                                     fontWeight: FontWeight.w800,
//                                   ),
//                                 ),

//                                 const SizedBox(height: 8),

//                                 Row(
//                                   children: const [
//                                     Icon(
//                                       Icons.star,
//                                       size: 16,
//                                       color: Colors.orange,
//                                     ),
//                                     SizedBox(width: 4),
//                                     Text("4.8"),
//                                     SizedBox(width: 6),
//                                     Text("2,341 reviews"),
//                                   ],
//                                 ),

//                                 const SizedBox(height: 16),

//                                 Row(
//                                   children: [
//                                     Text(
//                                       "\$${p.salePrice}",
//                                       style: const TextStyle(
//                                         decoration: TextDecoration.lineThrough,
//                                         color: Colors.grey,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Text(
//                                       "\$${p.finalPrice}",
//                                       style: const TextStyle(
//                                         fontSize: 26,
//                                         fontWeight: FontWeight.w800,
//                                         color: Color(0xFF4CAF50),
//                                       ),
//                                     ),
//                                   ],
//                                 ),

//                                 const SizedBox(height: 20),

//                                 const Text(
//                                   "ABOUT THIS PRODUCT",
//                                   style: TextStyle(fontWeight: FontWeight.w700),
//                                 ),

//                                 const SizedBox(height: 10),

//                                 Text(
//                                   p.description ?? "",
//                                   style: const TextStyle(height: 1.6),
//                                 ),

//                                 const SizedBox(height: 20),

//                                 Wrap(
//                                   spacing: 10,
//                                   children: const [
//                                     _FeatureChip("50ml", "VOLUME"),
//                                     _FeatureChip("Oil-free", "FORMULA"),
//                                     _FeatureChip("All", "SKIN"),
//                                     _FeatureChip("Japan", "ORIGIN"),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),

//                         /// BOTTOM BAR
//                         Positioned(
//                           bottom: 0,
//                           left: 0,
//                           right: 0,
//                           child: Container(
//                             padding: EdgeInsets.fromLTRB(
//                               16,
//                               10,
//                               16,
//                               MediaQuery.of(context).padding.bottom + 10,
//                             ),
//                             color: Colors.white,
//                             child: Row(
//                               children: [
//                                 _QtyBtn(
//                                   icon: Icons.remove,
//                                   onTap: () {
//                                     if (qty > 1) setState(() => qty--);
//                                   },
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 10,
//                                   ),
//                                   child: Text("$qty"),
//                                 ),
//                                 _QtyBtn(
//                                   icon: Icons.add,
//                                   onTap: () => setState(() => qty++),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: ElevatedButton(
//                                     onPressed: cartLoading
//                                         ? null
//                                         : () => _handleCart(p),
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: const Color(0xFF4CAF50),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(16),
//                                       ),
//                                     ),
//                                     child: cartLoading
//                                         ? const CircularProgressIndicator(
//                                             color: Colors.white,
//                                           )
//                                         : Text(
//                                             isInCart
//                                                 ? "Update cart — \$${p.finalPrice}"
//                                                 : "Add to bag — \$${p.finalPrice}",
//                                           ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// ////////////////////////////////////////////////////////////
// /// SMALL WIDGETS
// ////////////////////////////////////////////////////////////

// class _CircleBtn extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;

//   const _CircleBtn({required this.icon, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           color: Colors.black.withOpacity(0.3),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(icon, color: Colors.white, size: 18),
//       ),
//     );
//   }
// }

// class _Tag extends StatelessWidget {
//   final String label;
//   const _Tag({required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.grey.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Text(label.toUpperCase(), style: const TextStyle(fontSize: 10)),
//     );
//   }
// }

// class _FeatureChip extends StatelessWidget {
//   final String t;
//   final String s;
//   const _FeatureChip(this.t, this.s);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.grey.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         children: [
//           Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
//           Text(s, style: const TextStyle(fontSize: 10)),
//         ],
//       ),
//     );
//   }
// }

// class _QtyBtn extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;

//   const _QtyBtn({required this.icon, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 34,
//         height: 34,
//         decoration: BoxDecoration(
//           color: Colors.grey.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Icon(icon, size: 16),
//       ),
//     );
//   }
// }

// ////////////////////////////////////////////////////////////
// /// SKELETON
// ////////////////////////////////////////////////////////////

// class _Skeleton extends StatelessWidget {
//   final AnimationController shimmer;
//   const _Skeleton({required this.shimmer});

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: shimmer,
//       builder: (_, __) {
//         final color = Color.lerp(
//           Colors.grey.shade300,
//           Colors.grey.shade100,
//           shimmer.value,
//         )!;

//         return Container(color: color);
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────
// DESIGN TOKENS  — identical contract to home_screen &
//                  product_list_screen  (_T)
// ─────────────────────────────────────────────────────────────

abstract class _T {
  // ── 8-pt spacing scale ─────────────────────────────────────
  static const double sp2 = 2;
  static const double sp4 = 4;
  static const double sp6 = 6;
  static const double sp8 = 8;
  static const double sp10 = 10;
  static const double sp12 = 12;
  static const double sp14 = 14;
  static const double sp16 = 16;
  static const double sp20 = 20;
  static const double sp24 = 24;
  static const double sp28 = 28;
  static const double sp32 = 32;
  static const double sp40 = 40;
  static const double sp48 = 48;

  // ── Border radius ───────────────────────────────────────────
  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 18;
  static const double radiusXl = 24;
  static const double radiusFull = 999;

  // ── Shadows ─────────────────────────────────────────────────
  static List<BoxShadow> shadowSm(Color base) => [
    BoxShadow(
      color: base.withOpacity(.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowMd(Color base) => [
    BoxShadow(
      color: base.withOpacity(.12),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> shadowAccent(Color accent) => [
    BoxShadow(
      color: accent.withOpacity(.30),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // ── Typography ──────────────────────────────────────────────
  static TextStyle displayLg(Color c) => TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: c,
    letterSpacing: -.6,
    height: 1.2,
  );

  static TextStyle heading2(Color c) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: c,
    letterSpacing: -.2,
  );

  static TextStyle bodyMd(Color c) =>
      TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: c);

  static TextStyle bodySm(Color c) =>
      TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: c);

  static TextStyle bodyLg(Color c) => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: c,
    height: 1.65,
  );

  static TextStyle priceLg(Color c) => TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w900,
    color: c,
    letterSpacing: -1,
  );

  static TextStyle priceSm(Color c) => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: c,
    decoration: TextDecoration.lineThrough,
    decorationColor: c,
  );

  static TextStyle label(Color c) => TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: c,
    letterSpacing: .4,
  );

  static TextStyle sectionLabel(Color c) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: c,
    letterSpacing: -.1,
  );

  static TextStyle buttonText(Color c) => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: c,
    letterSpacing: .1,
  );
}

// ─────────────────────────────────────────────────────────────
// SHIMMER PRIMITIVE  (shared with home & list screens)
// ─────────────────────────────────────────────────────────────

class _Shimmer extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const _Shimmer({this.width, required this.height, this.borderRadius = 8});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(
      begin: -1.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF1E2A3A) : const Color(0xFFECEFF4);
    final highlight = isDark
        ? const Color(0xFF2A3A4E)
        : const Color(0xFFF8FAFB);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value + 1, 0),
            colors: [base, highlight, base],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SKELETON — mirrors the real screen layout exactly
// ─────────────────────────────────────────────────────────────

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          // ── Hero image area ───────────────────────────────
          SliverAppBar(
            expandedHeight: s.height * .48,
            pinned: true,
            elevation: 0,
            backgroundColor: colors.surface2,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Stack(
                children: [
                  // image placeholder
                  Positioned.fill(
                    child: _Shimmer(
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: 0,
                    ),
                  ),
                  // top bar icons
                  Positioned(
                    top: MediaQuery.of(context).padding.top + _T.sp10,
                    left: _T.sp16,
                    right: _T.sp16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        _Shimmer(
                          width: 42,
                          height: 42,
                          borderRadius: _T.radiusMd,
                        ),
                        _Shimmer(
                          width: 42,
                          height: 42,
                          borderRadius: _T.radiusMd,
                        ),
                      ],
                    ),
                  ),
                  // dot indicators
                  Positioned(
                    bottom: _T.sp20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (i) => Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: _T.sp4,
                          ),
                          child: _Shimmer(
                            width: i == 0 ? 20 : 7,
                            height: 7,
                            borderRadius: _T.radiusFull,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content area ──────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(_T.radiusXl),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(
                _T.sp24,
                _T.sp24,
                _T.sp24,
                _T.sp48,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: _T.sp24),
                      decoration: BoxDecoration(
                        color: colors.border,
                        borderRadius: BorderRadius.circular(_T.radiusFull),
                      ),
                    ),
                  ),

                  // chips
                  Row(
                    children: const [
                      _Shimmer(
                        width: 80,
                        height: 28,
                        borderRadius: _T.radiusMd,
                      ),
                      SizedBox(width: _T.sp8),
                      _Shimmer(
                        width: 64,
                        height: 28,
                        borderRadius: _T.radiusMd,
                      ),
                    ],
                  ),
                  const SizedBox(height: _T.sp16),

                  // product name
                  const _Shimmer(
                    width: double.infinity,
                    height: 22,
                    borderRadius: 6,
                  ),
                  const SizedBox(height: _T.sp8),
                  const _Shimmer(width: 200, height: 22, borderRadius: 6),
                  const SizedBox(height: _T.sp20),

                  // price
                  const _Shimmer(width: 130, height: 32, borderRadius: 6),
                  const SizedBox(height: _T.sp28),

                  Divider(color: colors.border, height: 1),
                  const SizedBox(height: _T.sp28),

                  // description label
                  const _Shimmer(width: 100, height: 14, borderRadius: 4),
                  const SizedBox(height: _T.sp14),

                  // description lines
                  ...List.generate(
                    4,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: _T.sp8),
                      child: _Shimmer(
                        width: i == 3 ? 180 : double.infinity,
                        height: 13,
                        borderRadius: 4,
                      ),
                    ),
                  ),

                  const SizedBox(height: _T.sp28),
                  Divider(color: colors.border, height: 1),
                  const SizedBox(height: _T.sp28),

                  // quantity row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _Shimmer(width: 80, height: 14, borderRadius: 4),
                      _Shimmer(
                        width: 110,
                        height: 42,
                        borderRadius: _T.radiusMd,
                      ),
                    ],
                  ),
                  const SizedBox(height: _T.sp32),

                  // CTA button
                  const _Shimmer(
                    width: double.infinity,
                    height: 56,
                    borderRadius: _T.radiusLg,
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

// ─────────────────────────────────────────────────────────────
// ERROR STATE
// ─────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(_T.sp32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.flashBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 36,
                color: colors.flashText,
              ),
            ),
            const SizedBox(height: _T.sp16),
            Text('Failed to load product', style: _T.heading2(colors.text2)),
            const SizedBox(height: _T.sp6),
            Text('Please try again', style: _T.bodySm(colors.text3)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// OVERLAY BUTTON  (back / favourite — on hero image)
// ─────────────────────────────────────────────────────────────

class _OverlayButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _OverlayButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.32),
          borderRadius: BorderRadius.circular(_T.radiusMd),
          border: Border.all(color: Colors.white.withOpacity(.15), width: .8),
        ),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// DOT INDICATOR  (same pill style as home_screen banner)
// ─────────────────────────────────────────────────────────────

class _DotIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;

  const _DotIndicator({required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: _T.sp4),
          width: active ? 20 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white.withOpacity(.45),
            borderRadius: BorderRadius.circular(_T.radiusFull),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// DISCOUNT BADGE  (reuses _Badge contract from home_screen)
// ─────────────────────────────────────────────────────────────

class _DiscountBadge extends StatelessWidget {
  final String label;
  final AppColors colors;

  const _DiscountBadge({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _T.sp12,
        vertical: _T.sp6,
      ),
      decoration: BoxDecoration(
        color: colors.flashText,
        borderRadius: BorderRadius.circular(_T.radiusFull),
        boxShadow: [
          BoxShadow(
            color: colors.flashText.withOpacity(.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(label, style: _T.label(Colors.white)),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// META CHIP  (category / brand — using accentLight bg)
// ─────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final String label;
  final AppColors colors;

  const _MetaChip({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _T.sp12,
        vertical: _T.sp6,
      ),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: BorderRadius.circular(_T.radiusMd),
        border: Border.all(color: colors.border, width: .8),
      ),
      child: Text(label.toUpperCase(), style: _T.label(colors.text2)),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// QUANTITY SELECTOR
// ─────────────────────────────────────────────────────────────

class _QuantitySelector extends StatelessWidget {
  final int qty;
  final AppColors colors;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantitySelector({
    required this.qty,
    required this.colors,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: BorderRadius.circular(_T.radiusMd),
        border: Border.all(color: colors.border, width: .8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyIconBtn(
            icon: Icons.remove_rounded,
            onTap: qty > 1 ? onDecrement : null,
            colors: colors,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: SizedBox(
              key: ValueKey(qty),
              width: 32,
              child: Text(
                '$qty',
                textAlign: TextAlign.center,
                style: _T.heading2(colors.text1),
              ),
            ),
          ),
          _QtyIconBtn(
            icon: Icons.add_rounded,
            onTap: onIncrement,
            colors: colors,
          ),
        ],
      ),
    );
  }
}

class _QtyIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final AppColors colors;

  const _QtyIconBtn({required this.icon, required this.colors, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _T.sp12,
          vertical: _T.sp10,
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? colors.accent : colors.text3,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ADD TO CART  /  UPDATE CART  BUTTON
// ─────────────────────────────────────────────────────────────

class _CartButton extends StatelessWidget {
  final bool isInCart;
  final bool loading;
  final String price;
  final AppColors colors;
  final VoidCallback onTap;

  const _CartButton({
    required this.isInCart,
    required this.loading,
    required this.price,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: GestureDetector(
        onTap: loading ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: loading ? colors.accent.withOpacity(.75) : colors.accent,
            borderRadius: BorderRadius.circular(_T.radiusLg),
            boxShadow: loading
                ? []
                : [
                    BoxShadow(
                      color: colors.accent.withOpacity(.30),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Center(
            child: loading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white.withOpacity(.9),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isInCart
                            ? Icons.shopping_cart_checkout_rounded
                            : Icons.shopping_bag_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: _T.sp10),
                      Text(
                        isInCart
                            ? 'Update Cart · \$$price'
                            : 'Add to Cart · \$$price',
                        style: _T.buttonText(Colors.white),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SECTION DIVIDER  (thin, theme-aware)
// ─────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Divider(color: colors.border, height: 1, thickness: .8);
  }
}

// ─────────────────────────────────────────────────────────────
// PRODUCT DETAIL SCREEN
// ─────────────────────────────────────────────────────────────

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  late Future<dynamic> productFuture;

  int qty = 1;
  int cartQty = 0;
  bool isInCart = false;
  bool cartLoading = false;
  bool isFavorite = false;
  int imageIndex = 0;

  late AnimationController _favCtrl;
  late Animation<double> _favScale;
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    productFuture = ApiService().fetchProduct(widget.productId);
    _loadCartQty();

    // favourite bounce
    _favCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _favScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _favCtrl, curve: Curves.easeInOut));

    // content fade-in
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _favCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Cart logic (unchanged) ──────────────────────────────────

  Future<void> _loadCartQty() async {
    try {
      final q = await ApiService().getCartQuantity(productId: widget.productId);
      if (mounted) {
        setState(() {
          cartQty = q;
          qty = q > 0 ? q : 1;
          isInCart = q > 0;
        });
      }
    } catch (_) {}
  }

  Future<void> _handleCart(dynamic p) async {
    setState(() => cartLoading = true);
    try {
      if (isInCart) {
        await ApiService().updateCart(
          productId: widget.productId,
          quantity: qty,
        );
      } else {
        await ApiService().addToCart(
          productId: widget.productId,
          quantity: qty,
        );
      }
      if (mounted) {
        setState(() {
          isInCart = true;
          cartQty = qty;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isInCart ? 'Cart updated' : 'Added to cart'),
            duration: const Duration(milliseconds: 900),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Something went wrong')));
      }
    } finally {
      if (mounted) setState(() => cartLoading = false);
    }
  }

  void _toggleFavourite() {
    HapticFeedback.lightImpact();
    setState(() => isFavorite = !isFavorite);
    _favCtrl.forward(from: 0);
  }

  // ── Build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mq = MediaQuery.of(context);
    final s = mq.size;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FutureBuilder(
        future: productFuture,
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return const _DetailSkeleton();
          }

          // Error
          if (snapshot.hasError) {
            return Scaffold(body: SafeArea(child: const _ErrorState()));
          }

          final p = snapshot.data;
          final images = (p.images as List?) ?? [];

          return FadeTransition(
            opacity: _fade,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Hero SliverAppBar ───────────────────────────
                SliverAppBar(
                  expandedHeight: s.height * .48,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: colors.surface2,
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                  automaticallyImplyLeading: false,

                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // ── Image carousel ──────────────────────
                        if (images.isNotEmpty)
                          PageView.builder(
                            itemCount: images.length,
                            onPageChanged: (i) =>
                                setState(() => imageIndex = i),
                            itemBuilder: (_, i) => Image.network(
                              images[i] as String,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: colors.surface2,
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 48,
                                  color: colors.text3,
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            color: colors.surface2,
                            child: Icon(
                              Icons.image_outlined,
                              size: 56,
                              color: colors.text3,
                            ),
                          ),

                        // top gradient (for icon legibility)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 160,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(.40),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),

                        // bottom gradient (sheet pull)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 130,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(.38),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // discount badge
                        if (p.discount != null)
                          Positioned(
                            top: mq.padding.top + 60,
                            left: _T.sp20,
                            child: _DiscountBadge(
                              label: p.discount.toString(),
                              colors: colors,
                            ),
                          ),

                        // dot indicators
                        if (images.length > 1)
                          Positioned(
                            bottom: _T.sp20,
                            left: 0,
                            right: 0,
                            child: _DotIndicator(
                              count: images.length,
                              activeIndex: imageIndex,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ── Back button ─────────────────────────────
                  leading: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: _T.sp16,
                        top: _T.sp8,
                      ),
                      child: _OverlayButton(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),

                  // ── Favourite button ────────────────────────
                  actions: [
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: _T.sp16,
                          top: _T.sp8,
                        ),
                        child: ScaleTransition(
                          scale: _favScale,
                          child: _OverlayButton(
                            onTap: _toggleFavourite,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                key: ValueKey(isFavorite),
                                color: isFavorite
                                    ? colors.flashText
                                    : Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Content sheet ───────────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(_T.radiusXl),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        _T.sp24,
                        _T.sp24,
                        _T.sp24,
                        mq.padding.bottom + _T.sp32,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // drag handle
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: _T.sp24),
                              decoration: BoxDecoration(
                                color: colors.border,
                                borderRadius: BorderRadius.circular(
                                  _T.radiusFull,
                                ),
                              ),
                            ),
                          ),

                          // ── Category + Brand chips ────────────
                          Wrap(
                            spacing: _T.sp8,
                            runSpacing: _T.sp8,
                            children: [
                              if ((p.categoryName as String?)?.isNotEmpty ==
                                  true)
                                _MetaChip(
                                  label: p.categoryName as String,
                                  colors: colors,
                                ),
                              if ((p.brandName as String?)?.isNotEmpty == true)
                                _MetaChip(
                                  label: p.brandName as String,
                                  colors: colors,
                                ),
                            ],
                          ),

                          const SizedBox(height: _T.sp14),

                          // ── Product name ──────────────────────
                          Text(
                            p.name as String,
                            style: _T.displayLg(colors.text1),
                          ),

                          const SizedBox(height: _T.sp16),

                          // ── Price row ─────────────────────────
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${p.finalPrice}',
                                style: _T.priceLg(colors.accent),
                              ),
                              if (p.discount != null) ...[
                                const SizedBox(width: _T.sp10),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: _T.sp4,
                                  ),
                                  child: Text(
                                    '\$${p.salePrice}',
                                    style: _T.priceSm(colors.text3),
                                  ),
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: _T.sp28),
                          const _Divider(),
                          const SizedBox(height: _T.sp28),

                          // ── Description ───────────────────────
                          Text(
                            'Description',
                            style: _T.sectionLabel(colors.text1),
                          ),
                          const SizedBox(height: _T.sp10),
                          Text(
                            (p.description as String?) ?? '',
                            style: _T.bodyLg(colors.text2),
                          ),

                          const SizedBox(height: _T.sp28),
                          const _Divider(),
                          const SizedBox(height: _T.sp28),

                          // ── Quantity row ──────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Quantity',
                                style: _T.sectionLabel(colors.text1),
                              ),
                              _QuantitySelector(
                                qty: qty,
                                colors: colors,
                                onDecrement: () {
                                  if (qty > 1) setState(() => qty--);
                                },
                                onIncrement: () => setState(() => qty++),
                              ),
                            ],
                          ),

                          const SizedBox(height: _T.sp32),

                          // ── CTA button ────────────────────────
                          _CartButton(
                            isInCart: isInCart,
                            loading: cartLoading,
                            price: p.finalPrice.toString(),
                            colors: colors,
                            onTap: () => _handleCart(p),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
