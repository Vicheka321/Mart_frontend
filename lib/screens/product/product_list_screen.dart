// import 'package:flutter/material.dart';
// import '../theme/app_theme.dart';
// import '../../services/api_service.dart';
// import 'product_detail_screen.dart';

// class ProductListScreen extends StatefulWidget {
//   final String title;
//   final Future<List<dynamic>> Function() fetch;

//   const ProductListScreen({
//     super.key,
//     required this.title,
//     required this.fetch,
//   });

//   @override
//   State<ProductListScreen> createState() => _ProductListScreenState();
// }

// class _ProductListScreenState extends State<ProductListScreen> {
//   late Future<List<dynamic>> _future;

//   @override
//   void initState() {
//     super.initState();
//     _future = widget.fetch();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             _Header(title: widget.title),

//             Expanded(
//               child: FutureBuilder<List<dynamic>>(
//                 future: _future,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const _LoadingState();
//                   }

//                   if (snapshot.hasError) {
//                     return const Center(child: Text("Error"));
//                   }

//                   final products = snapshot.data ?? [];

//                   return ListView.builder(
//                     padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
//                     itemCount: products.length,
//                     itemBuilder: (context, index) {
//                       return _ProductCardList(
//                         product: products[index],
//                         index: index,
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ////////////////////////////////////////////////////////////
// /// HEADER (same style as code 1)
// ////////////////////////////////////////////////////////////
// class _Header extends StatelessWidget {
//   final String title;

//   const _Header({required this.title});

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final s = MediaQuery.of(context).size.shortestSide;

//     return Padding(
//       padding: EdgeInsets.fromLTRB(s * 0.04, s * 0.03, s * 0.04, s * 0.02),
//       child: SizedBox(
//         height: s * 0.12,
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             Align(
//               alignment: Alignment.centerLeft,
//               child: GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Container(
//                   width: s * 0.11,
//                   height: s * 0.11,
//                   decoration: BoxDecoration(
//                     color: colors.cardBg,
//                     borderRadius: BorderRadius.circular(s * 0.3),
//                   ),
//                   child: Icon(
//                     Icons.arrow_back_ios_new_rounded,
//                     size: s * 0.04,
//                     color: colors.text1,
//                   ),
//                 ),
//               ),
//             ),

//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: s * 0.055,
//                 fontWeight: FontWeight.w700,
//                 color: colors.text1,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ////////////////////////////////////////////////////////////
// /// PRODUCT CARD (NOW SAME AS CODE 1)
// ////////////////////////////////////////////////////////////
// class _ProductCardList extends StatefulWidget {
//   final dynamic product;
//   final int index;

//   const _ProductCardList({required this.product, required this.index});

//   @override
//   State<_ProductCardList> createState() => _ProductCardListState();
// }

// class _ProductCardListState extends State<_ProductCardList>
//     with SingleTickerProviderStateMixin {
//   int _qty = 0;
//   bool _loading = false;

//   late AnimationController _controller;
//   late Animation<Offset> _slide;
//   late Animation<double> _fade;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );

//     _slide = Tween<Offset>(
//       begin: const Offset(0, 0.15),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

//     _fade = Tween<double>(
//       begin: 0,
//       end: 1,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

//     Future.delayed(Duration(milliseconds: widget.index * 60), () {
//       if (mounted) _controller.forward();
//     });

//     _loadCartQty();
//   }

//   Future<void> _loadCartQty() async {
//     try {
//       final qty = await ApiService().getCartQuantity(
//         productId: widget.product.id,
//       );
//       if (mounted) setState(() => _qty = qty);
//     } catch (_) {}
//   }

//   Future<void> _handleAddTap() async {
//     final oldQty = _qty;
//     setState(() => _qty = 1);

//     try {
//       await ApiService().addToCart(productId: widget.product.id, quantity: 1);
//     } catch (_) {
//       setState(() => _qty = oldQty);
//     }
//   }

//   Future<void> _setQty(int newQty) async {
//     final prev = _qty;
//     setState(() => _qty = newQty < 0 ? 0 : newQty);

//     try {
//       if (newQty <= 0) {
//         await ApiService().removeCart(widget.product.id);
//         setState(() => _qty = 0);
//       } else {
//         await ApiService().updateCart(
//           productId: widget.product.id,
//           quantity: newQty,
//         );
//       }
//     } catch (_) {
//       setState(() => _qty = prev);
//     }
//   }

//   bool get _isLowStock => widget.product.quantity < 20;

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final p = widget.product;
//     final colors = context.colors;
//     final s = MediaQuery.of(context).size.shortestSide;

//     /// ✅ EXACT SAME SIZES AS CODE 1
//     final imageSize = s * 0.24;
//     final gap = s * 0.03;
//     final fontTitle = s * 0.035;
//     final fontSmall = s * 0.03;
//     final fontPrice = s * 0.040;
//     final cartSize = s * 0.075;

//     return FadeTransition(
//       opacity: _fade,
//       child: SlideTransition(
//         position: _slide,
//         child: GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => ProductDetailScreen(productId: p.id),
//               ),
//             );
//           },
//           child: Container(
//             margin: EdgeInsets.only(bottom: s * 0.03),
//             padding: EdgeInsets.all(s * 0.025),
//             decoration: BoxDecoration(
//               color: colors.cardBg,
//               borderRadius: BorderRadius.circular(s * 0.04),
//             ),
//             child: Row(
//               children: [
//                 /// IMAGE
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(s * 0.03),
//                   child: p.images.isNotEmpty
//                       ? Image.network(
//                           p.images.first,
//                           width: imageSize,
//                           height: imageSize,
//                           fit: BoxFit.cover,
//                         )
//                       : Container(
//                           width: imageSize,
//                           height: imageSize,
//                           color: colors.surface2,
//                           child: Icon(Icons.image, color: colors.text3),
//                         ),
//                 ),

//                 SizedBox(width: gap),

//                 /// INFO (MATCHED TO CODE 1)
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         p.name,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           fontSize: fontTitle,
//                           fontWeight: FontWeight.w600,
//                           color: colors.text1,
//                         ),
//                       ),

//                       SizedBox(height: s * 0.01),

//                       Row(
//                         children: [
//                           Text(
//                             "${p.categoryName ?? 'Unknown'}",
//                             style: TextStyle(
//                               fontSize: fontSmall,
//                               color: colors.text2,
//                             ),
//                           ),
//                           Text(
//                             " | ",
//                             style: TextStyle(
//                               fontSize: fontSmall,
//                               color: colors.text3,
//                             ),
//                           ),
//                           Expanded(
//                             child: Text(
//                               "${p.brandName ?? 'No Brand'}",
//                               style: TextStyle(
//                                 fontSize: fontSmall,
//                                 color: colors.accent,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),

//                       SizedBox(height: s * 0.01),

//                       Text(
//                         p.description ?? "",
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           fontSize: fontSmall,
//                           color: colors.text3,
//                         ),
//                       ),

//                       SizedBox(height: s * 0.015),

//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Flexible(
//                             child: Row(
//                               children: [
//                                 Text(
//                                   "\$${p.finalPrice}",
//                                   style: TextStyle(
//                                     fontSize: fontPrice,
//                                     color: colors.accent,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 if (p.discount != null) ...[
//                                   SizedBox(width: s * 0.02),
//                                   Text(
//                                     "\$${p.salePrice}",
//                                     style: TextStyle(
//                                       fontSize: fontSmall,
//                                       color: colors.text3,
//                                       decoration: TextDecoration.lineThrough,
//                                     ),
//                                   ),
//                                 ],
//                               ],
//                             ),
//                           ),

//                           _CartStepper(
//                             qty: _qty,
//                             loading: _loading,
//                             s: cartSize,
//                             colors: colors,
//                             onAdd: _handleAddTap,
//                             onIncrement: () => _setQty(_qty + 1),
//                             onDecrement: () => _setQty(_qty - 1),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// ////////////////////////////////////////////////////////////
// /// CART BUTTON
// ////////////////////////////////////////////////////////////
// class _CartStepper extends StatelessWidget {
//   final int qty;
//   final bool loading;
//   final double s;
//   final AppColors colors;
//   final Future<void> Function() onAdd;
//   final Future<void> Function() onIncrement;
//   final Future<void> Function() onDecrement;

//   const _CartStepper({
//     required this.qty,
//     required this.loading,
//     required this.s,
//     required this.colors,
//     required this.onAdd,
//     required this.onIncrement,
//     required this.onDecrement,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final btn = s;

//     if (loading) {
//       return SizedBox(
//         width: btn,
//         height: btn,
//         child: Padding(
//           padding: EdgeInsets.all(btn * 0.25),
//           child: CircularProgressIndicator(
//             strokeWidth: 2,
//             color: colors.accent,
//           ),
//         ),
//       );
//     }

//     if (qty == 0) {
//       return GestureDetector(
//         onTap: onAdd,
//         child: Container(
//           width: btn,
//           height: btn,
//           decoration: BoxDecoration(
//             color: colors.accent,
//             shape: BoxShape.circle,
//           ),
//           child: const Icon(Icons.add, color: Colors.white),
//         ),
//       );
//     }

//     return Container(
//       height: btn,
//       decoration: BoxDecoration(
//         color: colors.accent,
//         borderRadius: BorderRadius.circular(btn / 2),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           GestureDetector(
//             onTap: onDecrement,
//             child: SizedBox(
//               width: btn,
//               height: btn,
//               child: const Icon(Icons.remove, color: Colors.white),
//             ),
//           ),
//           SizedBox(
//             width: btn * 0.7,
//             child: Text(
//               "$qty",
//               textAlign: TextAlign.center,
//               style: const TextStyle(color: Colors.white),
//             ),
//           ),
//           GestureDetector(
//             onTap: onIncrement,
//             child: SizedBox(
//               width: btn,
//               height: btn,
//               child: const Icon(Icons.add, color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _LoadingState extends StatelessWidget {
//   const _LoadingState();

//   @override
//   Widget build(BuildContext context) {
//     final s = MediaQuery.of(context).size.shortestSide;

//     return ListView.builder(
//       padding: EdgeInsets.fromLTRB(s * 0.04, 0, s * 0.04, s * 0.08),
//       itemCount: 6,
//       itemBuilder: (_, __) => const _SkeletonCard(),
//     );
//   }
// }

// class _SkeletonCard extends StatefulWidget {
//   const _SkeletonCard();

//   @override
//   State<_SkeletonCard> createState() => _SkeletonCardState();
// }

// class _SkeletonCardState extends State<_SkeletonCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _shimmer;
//   late Animation<double> _anim;

//   @override
//   void initState() {
//     super.initState();

//     _shimmer = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1100),
//     )..repeat(reverse: true);

//     _anim = CurvedAnimation(parent: _shimmer, curve: Curves.easeInOut);
//   }

//   @override
//   void dispose() {
//     _shimmer.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final s = MediaQuery.of(context).size.shortestSide;

//     // 🔧 responsive sizes
//     final imageSize = s * 0.26;
//     final fontBig = s * 0.04;
//     final fontSmall = s * 0.03;
//     final buttonSize = s * 0.085;

//     return AnimatedBuilder(
//       animation: _anim,
//       builder: (_, __) {
//         final base = Color.lerp(colors.surface2, colors.surface, _anim.value)!;

//         return Container(
//           margin: EdgeInsets.only(bottom: s * 0.03),
//           padding: EdgeInsets.all(s * 0.025),
//           decoration: BoxDecoration(
//             color: colors.cardBg,
//             borderRadius: BorderRadius.circular(s * 0.04),
//             // border: Border.all(color: colors.border),
//           ),
//           child: Row(
//             children: [
//               // 🖼 IMAGE
//               Container(
//                 width: imageSize,
//                 height: imageSize,
//                 decoration: BoxDecoration(
//                   color: base,
//                   borderRadius: BorderRadius.circular(s * 0.03),
//                 ),
//               ),

//               SizedBox(width: s * 0.03),

//               // 📄 TEXT
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Title
//                     Container(
//                       height: fontBig,
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: base,
//                         borderRadius: BorderRadius.circular(s * 0.02),
//                       ),
//                     ),

//                     SizedBox(height: s * 0.015),

//                     // Category + Brand
//                     Container(
//                       height: fontSmall,
//                       width: s * 0.4,
//                       decoration: BoxDecoration(
//                         color: base,
//                         borderRadius: BorderRadius.circular(s * 0.02),
//                       ),
//                     ),

//                     SizedBox(height: s * 0.015),

//                     // Description
//                     Container(
//                       height: fontSmall,
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: base,
//                         borderRadius: BorderRadius.circular(s * 0.02),
//                       ),
//                     ),

//                     SizedBox(height: s * 0.02),

//                     // Price
//                     Container(
//                       height: fontBig,
//                       width: s * 0.25,
//                       decoration: BoxDecoration(
//                         color: base,
//                         borderRadius: BorderRadius.circular(s * 0.02),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               SizedBox(width: s * 0.02),

//               // ➕ BUTTON
//               Container(
//                 width: buttonSize,
//                 height: buttonSize,
//                 decoration: BoxDecoration(
//                   color: base,
//                   borderRadius: BorderRadius.circular(buttonSize * 0.3),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/login_register_screen.dart';
import '../../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../../services/api_service.dart';
import 'product_detail_screen.dart';

// ─────────────────────────────────────────────────────────────
// DESIGN TOKENS  — identical to home_screen.dart  (_T)
// Single source of truth. Never use hard-coded values.
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

  // ── Border radius ───────────────────────────────────────────
  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 18;
  static const double radiusXl = 22;
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
      color: base.withOpacity(.10),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowAccent(Color accent) => [
    BoxShadow(
      color: accent.withOpacity(.30),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // ── Typography ──────────────────────────────────────────────
  static TextStyle heading1(Color c) => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: c,
    letterSpacing: -.4,
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

  static TextStyle caption(Color c) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: c,
    height: 1.4,
  );

  static TextStyle priceLg(Color c) =>
      TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c);

  static TextStyle priceSm(Color c) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: c,
    decoration: TextDecoration.lineThrough,
    decorationColor: c,
  );

  static TextStyle label(Color c) => TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: c,
    letterSpacing: .2,
  );
}

// ─────────────────────────────────────────────────────────────
// SHIMMER PRIMITIVE  (shared with home_screen)
// ─────────────────────────────────────────────────────────────

class _Shimmer extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _Shimmer({
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

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
// SKELETON CARD  (matches _ProductCardList layout exactly)
// ─────────────────────────────────────────────────────────────

class _SkeletonProductCard extends StatelessWidget {
  const _SkeletonProductCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: _T.sp12),
      padding: const EdgeInsets.all(_T.sp12),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(_T.radiusLg),
        border: Border.all(color: colors.border, width: .8),
        boxShadow: _T.shadowSm(Colors.black),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // image
          _Shimmer(width: 90, height: 90, borderRadius: _T.radiusMd),
          const SizedBox(width: _T.sp12),

          // text block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _Shimmer(width: double.infinity, height: 13, borderRadius: 4),
                SizedBox(height: _T.sp8),
                _Shimmer(width: 140, height: 11, borderRadius: 4),
                SizedBox(height: _T.sp6),
                _Shimmer(width: double.infinity, height: 11, borderRadius: 4),
                SizedBox(height: _T.sp12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _Shimmer(width: 60, height: 14, borderRadius: 4),
                    _Shimmer(
                      width: 32,
                      height: 32,
                      borderRadius: _T.radiusFull,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// LOADING STATE  — 7 skeleton cards
// ─────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(_T.sp16, _T.sp4, _T.sp16, _T.sp32),
      itemCount: 7,
      itemBuilder: (_, __) => const _SkeletonProductCard(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// BADGE  (reused from home_screen — discount label)
// ─────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const _Badge({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: _T.sp8, vertical: _T.sp4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(_T.radiusFull),
      ),
      child: Text(label, style: _T.label(textColor)),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// BACK BUTTON  (reused AppBar pattern from home_screen)
// ─────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  final AppColors colors;

  const _BackButton({required this.colors});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius: BorderRadius.circular(_T.radiusMd),
          border: Border.all(color: colors.border, width: .8),
          boxShadow: _T.shadowSm(Colors.black),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: colors.text1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String title;

  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(_T.sp20, _T.sp14, _T.sp20, _T.sp14),
      child: Row(
        children: [
          _BackButton(colors: colors),
          const SizedBox(width: _T.sp16),
          Expanded(
            child: Text(
              title,
              style: _T.heading2(colors.text1),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CART STEPPER  (identical sizing contract to home_screen)
// ─────────────────────────────────────────────────────────────

class _CartStepper extends StatelessWidget {
  final int qty;
  final bool loading;
  final AppColors colors;
  final Future<void> Function() onAdd;
  final Future<void> Function() onIncrement;
  final Future<void> Function() onDecrement;

  const _CartStepper({
    required this.qty,
    required this.loading,
    required this.colors,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    const btnSize = 32.0;

    if (loading) {
      return SizedBox(
        width: btnSize,
        height: btnSize,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colors.accent,
          ),
        ),
      );
    }

    // ── Add button ────────────────────────────────────────────
    if (qty == 0) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onAdd,
        child: Container(
          width: btnSize,
          height: btnSize,
          decoration: BoxDecoration(
            color: colors.accent,
            shape: BoxShape.circle,
            boxShadow: _T.shadowAccent(colors.accent),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 16),
        ),
      );
    }

    // ── Stepper ───────────────────────────────────────────────
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      height: btnSize,
      decoration: BoxDecoration(
        color: colors.accent,
        borderRadius: BorderRadius.circular(_T.radiusFull),
        boxShadow: _T.shadowAccent(colors.accent),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDecrement,
            child: const SizedBox(
              width: btnSize,
              height: btnSize,
              child: Icon(Icons.remove, color: Colors.white, size: 14),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: SizedBox(
              key: ValueKey(qty),
              width: 22,
              child: Text(
                '$qty',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onIncrement,
            child: const SizedBox(
              width: btnSize,
              height: btnSize,
              child: Icon(Icons.add, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PRODUCT CARD  (horizontal list item)
// ─────────────────────────────────────────────────────────────

class _ProductCardList extends StatefulWidget {
  final dynamic product;
  final int index;

  const _ProductCardList({required this.product, required this.index});

  @override
  State<_ProductCardList> createState() => _ProductCardListState();
}

class _ProductCardListState extends State<_ProductCardList>
    with SingleTickerProviderStateMixin {
  int _qty = 0;
  bool _loading = false;

  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 55), () {
      if (mounted) _ctrl.forward();
    });

    _loadCartQty();
  }

  Future<void> _loadCartQty() async {
    final loggedIn = await ApiService().isLoggedIn();
    if (!loggedIn) {
      showAuthBottomSheet(context);
      return;
    }

    try {
      final qty = await ApiService().getCartQuantity(
        productId: widget.product.id,
      );

      if (mounted) setState(() => _qty = qty);
    } catch (_) {}
  }

  Future<void> _handleAddTap() async {
    final loggedIn = await ApiService().isLoggedIn();
    if (!loggedIn) {
      showAuthBottomSheet(context);
      return;
    }
    final old = _qty;
    setState(() => _qty = 1);
    try {
      await ApiService().addToCart(productId: widget.product.id, quantity: 1);
    } catch (_) {
      if (mounted) setState(() => _qty = old);
    }
  }

  Future<void> _setQty(int newQty) async {
    final loggedIn = await ApiService().isLoggedIn();
    if (!loggedIn) {
      showAuthBottomSheet(context);
      return;
    }
    final prev = _qty;
    setState(() => _qty = newQty < 0 ? 0 : newQty);
    try {
      if (newQty <= 0) {
        await ApiService().removeCart(widget.product.id);
        if (mounted) setState(() => _qty = 0);
      } else {
        await ApiService().updateCart(
          productId: widget.product.id,
          quantity: newQty,
        );
      }
    } catch (_) {
      if (mounted) setState(() => _qty = prev);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final colors = context.colors;

    // ── Responsive image size ──────────────────────────────────
    final s = MediaQuery.of(context).size.shortestSide;
    final imageSize = (s * 0.22).clamp(76.0, 110.0);

    final imageUrl = (p.images as List).isNotEmpty
        ? (p.images as List).first as String
        : null;

    final hasDiscount = p.discount != null;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(productId: p.id),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: _T.sp12),
            decoration: BoxDecoration(
              color: colors.cardBg,
              borderRadius: BorderRadius.circular(_T.radiusLg),
              border: Border.all(color: colors.border, width: .8),
              boxShadow: _T.shadowSm(Colors.black),
            ),
            child: Padding(
              padding: const EdgeInsets.all(_T.sp12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Product Image ─────────────────────────────
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(_T.radiusMd),
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl,
                                width: imageSize,
                                height: imageSize,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _ImagePlaceholder(
                                  size: imageSize,
                                  colors: colors,
                                ),
                              )
                            : _ImagePlaceholder(
                                size: imageSize,
                                colors: colors,
                              ),
                      ),

                      // discount badge — top-left
                      if (hasDiscount)
                        Positioned(
                          top: _T.sp6,
                          left: _T.sp6,
                          child: _Badge(
                            label: '-${_parseDiscount(p.discount!)}%',
                            bgColor: colors.flashText,
                            textColor: Colors.white,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(width: _T.sp12),

                  // ── Product Info ──────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // name
                        Text(
                          p.name as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _T.bodyMd(colors.text1),
                        ),

                        const SizedBox(height: _T.sp6),

                        // category | brand
                        Row(
                          children: [
                            Text(
                              p.categoryName ?? 'Unknown',
                              style: _T.bodySm(colors.text2),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: _T.sp4,
                              ),
                              child: Text('·', style: _T.bodySm(colors.text3)),
                            ),
                            Expanded(
                              child: Text(
                                p.brandName ?? 'No Brand',
                                style: _T.bodySm(colors.accent),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: _T.sp4),

                        // description
                        if ((p.description as String?)?.isNotEmpty == true)
                          Text(
                            p.description as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _T.caption(colors.text3),
                          ),

                        const SizedBox(height: _T.sp10),

                        // price row + cart
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // prices
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (hasDiscount)
                                    Text(
                                      '\$${p.salePrice}',
                                      style: _T.priceSm(colors.text3),
                                    ),
                                  Text(
                                    '\$${p.finalPrice}',
                                    style: _T.priceLg(colors.accent),
                                  ),
                                ],
                              ),
                            ),

                            // cart stepper
                            _CartStepper(
                              qty: _qty,
                              loading: _loading,
                              colors: colors,
                              onAdd: _handleAddTap,
                              onIncrement: () => _setQty(_qty + 1),
                              onDecrement: () => _setQty(_qty - 1),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Safely parses discount string — handles "15%", "15", or numeric
  String _parseDiscount(dynamic discount) {
    if (discount == null) return '';
    final raw = discount.toString().replaceAll('%', '').trim();
    final d = double.tryParse(raw);
    return d != null ? d.toInt().toString() : raw;
  }
}

// ─────────────────────────────────────────────────────────────
// IMAGE PLACEHOLDER
// ─────────────────────────────────────────────────────────────

class _ImagePlaceholder extends StatelessWidget {
  final double size;
  final AppColors colors;

  const _ImagePlaceholder({required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: BorderRadius.circular(_T.radiusMd),
      ),
      child: Icon(Icons.image_outlined, size: size * .35, color: colors.text3),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colors.surface2,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inbox_outlined, size: 36, color: colors.text3),
          ),
          const SizedBox(height: _T.sp16),
          Text('No products found', style: _T.bodyMd(colors.text2)),
          const SizedBox(height: _T.sp6),
          Text('Check back later', style: _T.bodySm(colors.text3)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ERROR STATE
// ─────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String? error;
  const _ErrorState({this.error});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
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
          Text('Something went wrong', style: _T.bodyMd(colors.text2)),
          const SizedBox(height: _T.sp6),
          if (error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error!,
                style: _T.bodySm(colors.flashText),
                textAlign: TextAlign.center,
              ),
            )
          else
            Text('Please try again later', style: _T.bodySm(colors.text3)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PRODUCT LIST SCREEN
// ─────────────────────────────────────────────────────────────

class ProductListScreen extends StatefulWidget {
  final String title;
  final Future<List> Function() fetch;

  const ProductListScreen({
    super.key,
    required this.title,
    required this.fetch,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List> _future;

  // Wraps the fetch — model handles null fields with fallback defaults.
  Future<List> _safeFetch() async {
    return await widget.fetch();
  }

  @override
  void initState() {
    super.initState();
    _future = _safeFetch();
  }

  Future<void> _refresh() async {
    setState(() => _future = _safeFetch());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Sticky Header ─────────────────────────────────
            _Header(title: widget.title),

            // ── Content ───────────────────────────────────────
            Expanded(
              child: FutureBuilder<List>(
                future: _future,
                builder: (context, snapshot) {
                  // Loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _LoadingState();
                  }

                  // Error
                  if (snapshot.hasError) {
                    return _ErrorState(error: snapshot.error.toString());
                  }

                  final products = snapshot.data ?? [];

                  // Empty
                  if (products.isEmpty) {
                    return const _EmptyState();
                  }

                  // List
                  return RefreshIndicator(
                    color: context.colors.accent,
                    backgroundColor: context.colors.cardBg,
                    onRefresh: _refresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        _T.sp16,
                        _T.sp4,
                        _T.sp16,
                        _T.sp32,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, i) =>
                          _ProductCardList(product: products[i], index: i),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
