// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';
// import '../../providers/cart_provider.dart';
// import '../../services/api_service.dart';
// import '../../translations/catalog_translation.dart';
// import '../../services/wishlist_service.dart';
// import '../../widgets/skeleton_loader.dart';
// import '../theme/app_theme.dart';

// // ─────────────────────────────────────────────────────────────
// // DESIGN TOKENS  — identical contract to home_screen &
// //                  product_list_screen  (_T)
// // ─────────────────────────────────────────────────────────────

// abstract class _T {
//   // ── 8-pt spacing scale ─────────────────────────────────────
//   static const double sp2 = 2;
//   static const double sp4 = 4;
//   static const double sp6 = 6;
//   static const double sp8 = 8;
//   static const double sp10 = 10;
//   static const double sp12 = 12;
//   static const double sp14 = 14;
//   static const double sp16 = 16;
//   static const double sp20 = 20;
//   static const double sp24 = 24;
//   static const double sp28 = 28;
//   static const double sp32 = 32;
//   static const double sp40 = 40;
//   static const double sp48 = 48;

//   // ── Border radius ───────────────────────────────────────────
//   static const double radiusSm = 10;
//   static const double radiusMd = 14;
//   static const double radiusLg = 18;
//   static const double radiusXl = 24;
//   static const double radiusFull = 999;

//   // ── Shadows ─────────────────────────────────────────────────
//   static List<BoxShadow> shadowSm(Color base) => [
//     BoxShadow(
//       color: base.withOpacity(.06),
//       blurRadius: 8,
//       offset: const Offset(0, 2),
//     ),
//   ];

//   static List<BoxShadow> shadowMd(Color base) => [
//     BoxShadow(
//       color: base.withOpacity(.12),
//       blurRadius: 18,
//       offset: const Offset(0, 6),
//     ),
//   ];

//   static List<BoxShadow> shadowAccent(Color accent) => [
//     BoxShadow(
//       color: accent.withOpacity(.30),
//       blurRadius: 12,
//       offset: const Offset(0, 4),
//     ),
//   ];

//   // ── Typography ──────────────────────────────────────────────
//   static TextStyle displayLg(Color c) => TextStyle(
//     fontSize: 26,
//     fontWeight: FontWeight.w800,
//     color: c,
//     letterSpacing: -.6,
//     height: 1.2,
//   );

//   static TextStyle heading2(Color c) => TextStyle(
//     fontSize: 16,
//     fontWeight: FontWeight.w700,
//     color: c,
//     letterSpacing: -.2,
//   );

//   static TextStyle bodyMd(Color c) =>
//       TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: c);

//   static TextStyle bodySm(Color c) =>
//       TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: c);

//   static TextStyle bodyLg(Color c) => TextStyle(
//     fontSize: 15,
//     fontWeight: FontWeight.w400,
//     color: c,
//     height: 1.65,
//   );

//   static TextStyle priceLg(Color c) => TextStyle(
//     fontSize: 30,
//     fontWeight: FontWeight.w900,
//     color: c,
//     letterSpacing: -1,
//   );

//   static TextStyle priceSm(Color c) => TextStyle(
//     fontSize: 15,
//     fontWeight: FontWeight.w500,
//     color: c,
//     decoration: TextDecoration.lineThrough,
//     decorationColor: c,
//   );

//   static TextStyle label(Color c) => TextStyle(
//     fontSize: 10,
//     fontWeight: FontWeight.w700,
//     color: c,
//     letterSpacing: .4,
//   );

//   static TextStyle sectionLabel(Color c) => TextStyle(
//     fontSize: 14,
//     fontWeight: FontWeight.w700,
//     color: c,
//     letterSpacing: -.1,
//   );

//   static TextStyle buttonText(Color c) => TextStyle(
//     fontSize: 15,
//     fontWeight: FontWeight.w700,
//     color: c,
//     letterSpacing: .1,
//   );
// }

// // ─────────────────────────────────────────────────────────────
// // SHIMMER PRIMITIVE  (shared with home & list screens)
// // ─────────────────────────────────────────────────────────────

// class _Shimmer extends StatefulWidget {
//   final double? width;
//   final double height;
//   final double borderRadius;

//   const _Shimmer({this.width, required this.height, this.borderRadius = 8});

//   @override
//   State<_Shimmer> createState() => _ShimmerState();
// }

// class _ShimmerState extends State<_Shimmer>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _ctrl;
//   late final Animation<double> _anim;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     )..repeat();
//     _anim = Tween<double>(
//       begin: -1.5,
//       end: 1.5,
//     ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final base = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFECEFF4);
//     final highlight = isDark
//         ? const Color(0xFF252525)
//         : const Color(0xFFF8FAFB);

//     return AnimatedBuilder(
//       animation: _anim,
//       builder: (_, __) => Container(
//         width: widget.width,
//         height: widget.height,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(widget.borderRadius),
//           gradient: LinearGradient(
//             begin: Alignment(_anim.value - 1, 0),
//             end: Alignment(_anim.value + 1, 0),
//             colors: [base, highlight, base],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // SKELETON — mirrors the real screen layout exactly
// // ─────────────────────────────────────────────────────────────

// class _DetailSkeleton extends StatelessWidget {
//   const _DetailSkeleton();

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final s = MediaQuery.of(context).size;

//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: CustomScrollView(
//         physics: const NeverScrollableScrollPhysics(),
//         slivers: [
//           // ── Hero image area ───────────────────────────────
//           SliverAppBar(
//             expandedHeight: s.height * .48,
//             pinned: true,
//             elevation: 0,
//             backgroundColor: colors.surface2,
//             automaticallyImplyLeading: false,
//             flexibleSpace: FlexibleSpaceBar(
//               collapseMode: CollapseMode.pin,
//               background: Stack(
//                 children: [
//                   // image placeholder
//                   Positioned.fill(
//                     child: _Shimmer(
//                       width: double.infinity,
//                       height: double.infinity,
//                       borderRadius: 0,
//                     ),
//                   ),
//                   // top bar icons
//                   Positioned(
//                     top: MediaQuery.of(context).padding.top + _T.sp10,
//                     left: _T.sp16,
//                     right: _T.sp16,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: const [
//                         _Shimmer(
//                           width: 42,
//                           height: 42,
//                           borderRadius: _T.radiusMd,
//                         ),
//                         _Shimmer(
//                           width: 42,
//                           height: 42,
//                           borderRadius: _T.radiusMd,
//                         ),
//                       ],
//                     ),
//                   ),
//                   // dot indicators
//                   Positioned(
//                     bottom: _T.sp20,
//                     left: 0,
//                     right: 0,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: List.generate(
//                         3,
//                         (i) => Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: _T.sp4,
//                           ),
//                           child: _Shimmer(
//                             width: i == 0 ? 20 : 7,
//                             height: 7,
//                             borderRadius: _T.radiusFull,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // ── Content area ──────────────────────────────────
//           SliverToBoxAdapter(
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Theme.of(context).scaffoldBackgroundColor,
//                 borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(_T.radiusXl),
//                 ),
//               ),
//               padding: const EdgeInsets.fromLTRB(
//                 _T.sp24,
//                 _T.sp24,
//                 _T.sp24,
//                 _T.sp48,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // drag handle
//                   Center(
//                     child: Container(
//                       width: 40,
//                       height: 4,
//                       margin: const EdgeInsets.only(bottom: _T.sp24),
//                       decoration: BoxDecoration(
//                         color: colors.border,
//                         borderRadius: BorderRadius.circular(_T.radiusFull),
//                       ),
//                     ),
//                   ),

//                   // chips
//                   Row(
//                     children: const [
//                       _Shimmer(
//                         width: 80,
//                         height: 28,
//                         borderRadius: _T.radiusMd,
//                       ),
//                       SizedBox(width: _T.sp8),
//                       _Shimmer(
//                         width: 64,
//                         height: 28,
//                         borderRadius: _T.radiusMd,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: _T.sp16),

//                   // product name
//                   const _Shimmer(
//                     width: double.infinity,
//                     height: 22,
//                     borderRadius: 6,
//                   ),
//                   const SizedBox(height: _T.sp8),
//                   const _Shimmer(width: 200, height: 22, borderRadius: 6),
//                   const SizedBox(height: _T.sp20),

//                   // price
//                   const _Shimmer(width: 130, height: 32, borderRadius: 6),
//                   const SizedBox(height: _T.sp28),

//                   Divider(color: colors.border, height: 1),
//                   const SizedBox(height: _T.sp28),

//                   // description label
//                   const _Shimmer(width: 100, height: 14, borderRadius: 4),
//                   const SizedBox(height: _T.sp14),

//                   // description lines
//                   ...List.generate(
//                     4,
//                     (i) => Padding(
//                       padding: const EdgeInsets.only(bottom: _T.sp8),
//                       child: _Shimmer(
//                         width: i == 3 ? 180 : double.infinity,
//                         height: 13,
//                         borderRadius: 4,
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: _T.sp28),
//                   Divider(color: colors.border, height: 1),
//                   const SizedBox(height: _T.sp28),

//                   // quantity row
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: const [
//                       _Shimmer(width: 80, height: 14, borderRadius: 4),
//                       _Shimmer(
//                         width: 110,
//                         height: 42,
//                         borderRadius: _T.radiusMd,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: _T.sp32),

//                   // CTA button
//                   const _Shimmer(
//                     width: double.infinity,
//                     height: 56,
//                     borderRadius: _T.radiusLg,
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

// // ─────────────────────────────────────────────────────────────
// // ERROR STATE
// // ─────────────────────────────────────────────────────────────

// class _ErrorState extends StatelessWidget {
//   const _ErrorState();

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;

//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(_T.sp32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: colors.flashBg,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.wifi_off_rounded,
//                 size: 36,
//                 color: colors.flashText,
//               ),
//             ),
//             const SizedBox(height: _T.sp16),
//             Text('failed_to_load_product'.tr, style: _T.heading2(colors.text2)),
//             const SizedBox(height: _T.sp6),
//             Text('please_try_again'.tr, style: _T.bodySm(colors.text3)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // OVERLAY BUTTON  (back / favourite — on hero image)
// // ─────────────────────────────────────────────────────────────

// class _OverlayButton extends StatelessWidget {
//   final Widget child;
//   final VoidCallback onTap;

//   const _OverlayButton({required this.child, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 42,
//         height: 42,
//         decoration: BoxDecoration(
//           color: Colors.black.withOpacity(.32),
//           borderRadius: BorderRadius.circular(_T.radiusMd),
//           border: Border.all(color: Colors.white.withOpacity(.15), width: .8),
//         ),
//         child: child,
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // DOT INDICATOR  (same pill style as home_screen banner)
// // ─────────────────────────────────────────────────────────────

// class _DotIndicator extends StatelessWidget {
//   final int count;
//   final int activeIndex;

//   const _DotIndicator({required this.count, required this.activeIndex});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(count, (i) {
//         final active = i == activeIndex;
//         return AnimatedContainer(
//           duration: const Duration(milliseconds: 250),
//           margin: const EdgeInsets.symmetric(horizontal: _T.sp4),
//           width: active ? 20 : 7,
//           height: 7,
//           decoration: BoxDecoration(
//             color: active ? Colors.white : Colors.white.withOpacity(.45),
//             borderRadius: BorderRadius.circular(_T.radiusFull),
//           ),
//         );
//       }),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // DISCOUNT BADGE  (reuses _Badge contract from home_screen)
// // ─────────────────────────────────────────────────────────────

// class _DiscountBadge extends StatelessWidget {
//   final String label;
//   final AppColors colors;

//   const _DiscountBadge({required this.label, required this.colors});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: _T.sp12,
//         vertical: _T.sp6,
//       ),
//       decoration: BoxDecoration(
//         color: colors.flashText,
//         borderRadius: BorderRadius.circular(_T.radiusFull),
//         boxShadow: [
//           BoxShadow(
//             color: colors.flashText.withOpacity(.35),
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Text(label, style: _T.label(Colors.white)),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // META CHIP  (category / brand — using accentLight bg)
// // ─────────────────────────────────────────────────────────────

// class _MetaChip extends StatelessWidget {
//   final String label;
//   final AppColors colors;

//   const _MetaChip({required this.label, required this.colors});

//   @override
//   Widget build(BuildContext context) {
//     if (label.isEmpty) return const SizedBox.shrink();
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: _T.sp12,
//         vertical: _T.sp6,
//       ),
//       decoration: BoxDecoration(
//         color: colors.surface2,
//         borderRadius: BorderRadius.circular(_T.radiusMd),
//         border: Border.all(color: colors.border, width: .8),
//       ),
//       child: Text(label.toUpperCase(), style: _T.label(colors.text2)),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // QUANTITY SELECTOR
// // ─────────────────────────────────────────────────────────────

// class _QuantitySelector extends StatelessWidget {
//   final int qty;
//   final AppColors colors;
//   final VoidCallback onDecrement;
//   final VoidCallback onIncrement;

//   const _QuantitySelector({
//     required this.qty,
//     required this.colors,
//     required this.onDecrement,
//     required this.onIncrement,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 42,
//       decoration: BoxDecoration(
//         color: colors.surface2,
//         borderRadius: BorderRadius.circular(_T.radiusMd),
//         border: Border.all(color: colors.border, width: .8),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _QtyIconBtn(
//             icon: Icons.remove_rounded,
//             onTap: qty > 1 ? onDecrement : null,
//             colors: colors,
//           ),
//           AnimatedSwitcher(
//             duration: const Duration(milliseconds: 180),
//             transitionBuilder: (child, anim) =>
//                 ScaleTransition(scale: anim, child: child),
//             child: SizedBox(
//               key: ValueKey(qty),
//               width: 32,
//               child: Text(
//                 '$qty',
//                 textAlign: TextAlign.center,
//                 style: _T.heading2(colors.text1),
//               ),
//             ),
//           ),
//           _QtyIconBtn(
//             icon: Icons.add_rounded,
//             onTap: onIncrement,
//             colors: colors,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _QtyIconBtn extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback? onTap;
//   final AppColors colors;

//   const _QtyIconBtn({required this.icon, required this.colors, this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(
//           horizontal: _T.sp12,
//           vertical: _T.sp10,
//         ),
//         child: Icon(
//           icon,
//           size: 18,
//           color: onTap != null ? colors.accent : colors.text3,
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // ADD TO CART  /  UPDATE CART  BUTTON
// // ─────────────────────────────────────────────────────────────

// class _CartButton extends StatelessWidget {
//   final bool isInCart;
//   final bool loading;
//   final String price;
//   final AppColors colors;
//   final VoidCallback onTap;

//   const _CartButton({
//     required this.isInCart,
//     required this.loading,
//     required this.price,
//     required this.colors,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: 56,
//       child: GestureDetector(
//         onTap: loading ? null : onTap,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           decoration: BoxDecoration(
//             color: loading ? colors.accent.withOpacity(.75) : colors.accent,
//             borderRadius: BorderRadius.circular(_T.radiusLg),
//             boxShadow: loading
//                 ? []
//                 : [
//                     BoxShadow(
//                       color: colors.accent.withOpacity(.30),
//                       blurRadius: 14,
//                       offset: const Offset(0, 5),
//                     ),
//                   ],
//           ),
//           child: Center(
//             child: loading
//                 ? const SkeletonBox(
//                     width: 92,
//                     height: 12,
//                     borderRadius: BorderRadius.all(Radius.circular(6)),
//                     baseColor: Colors.white54,
//                     highlightColor: Colors.white,
//                   )
//                 : Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         isInCart
//                             ? Icons.shopping_cart_checkout_rounded
//                             : Icons.shopping_bag_outlined,
//                         color: Colors.white,
//                         size: 18,
//                       ),
//                       const SizedBox(width: _T.sp10),
//                       Text(
//                         isInCart
//                             ? 'Update Cart · \$$price'
//                             : 'Add to Cart · \$$price',
//                         style: _T.buttonText(Colors.white),
//                       ),
//                     ],
//                   ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // SECTION DIVIDER  (thin, theme-aware)
// // ─────────────────────────────────────────────────────────────

// class _Divider extends StatelessWidget {
//   const _Divider();

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     return Divider(color: colors.border, height: 1, thickness: .8);
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // INFO CHIP  (brand / stock / discount badges)
// // ─────────────────────────────────────────────────────────────

// class _InfoChip extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final Color bg;

//   const _InfoChip({
//     required this.icon,
//     required this.label,
//     required this.color,
//     required this.bg,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(_T.radiusSm),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 13, color: color),
//           const SizedBox(width: 5),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // ACCORDION ROW  (Description / Quantity expandable sections)
// // ─────────────────────────────────────────────────────────────

// class _AccordionRow extends StatefulWidget {
//   final String title;
//   final Widget child;
//   final AppColors colors;

//   const _AccordionRow({
//     required this.title,
//     required this.child,
//     required this.colors,
//   });

//   @override
//   State<_AccordionRow> createState() => _AccordionRowState();
// }

// class _AccordionRowState extends State<_AccordionRow>
//     with SingleTickerProviderStateMixin {
//   bool _open = false;
//   late final AnimationController _ctrl;
//   late final Animation<double> _anim;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 260),
//     );
//     _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final c = widget.colors;
//     return Column(
//       children: [
//         Divider(height: 1, color: c.border.withValues(alpha: 0.5)),
//         GestureDetector(
//           behavior: HitTestBehavior.opaque,
//           onTap: () {
//             setState(() => _open = !_open);
//             _open ? _ctrl.forward() : _ctrl.reverse();
//           },
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   widget.title,
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                     color: c.text1,
//                   ),
//                 ),
//                 AnimatedRotation(
//                   turns: _open ? 0.5 : 0,
//                   duration: const Duration(milliseconds: 260),
//                   child: Icon(
//                     Icons.keyboard_arrow_down_rounded,
//                     color: c.text3,
//                     size: 22,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         SizeTransition(sizeFactor: _anim, child: widget.child),
//       ],
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // EXPANDABLE DESCRIPTION  (ReadMore / Show less)
// // ─────────────────────────────────────────────────────────────

// class _ExpandableDescription extends StatefulWidget {
//   final String text;
//   final AppColors colors;

//   const _ExpandableDescription({required this.text, required this.colors});

//   @override
//   State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
// }

// class _ExpandableDescriptionState extends State<_ExpandableDescription> {
//   bool _expanded = false;
//   static const int _maxLines = 3;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         AnimatedCrossFade(
//           duration: const Duration(milliseconds: 250),
//           crossFadeState: _expanded
//               ? CrossFadeState.showSecond
//               : CrossFadeState.showFirst,
//           firstChild: Text(
//             widget.text,
//             maxLines: _maxLines,
//             overflow: TextOverflow.ellipsis,
//             style: TextStyle(
//               fontSize: 14,
//               height: 1.65,
//               color: widget.colors.text2,
//             ),
//           ),
//           secondChild: Text(
//             widget.text,
//             style: TextStyle(
//               fontSize: 14,
//               height: 1.65,
//               color: widget.colors.text2,
//             ),
//           ),
//         ),
//         if (widget.text.length > 120) ...[
//           const SizedBox(height: 4),
//           GestureDetector(
//             onTap: () => setState(() => _expanded = !_expanded),
//             child: Text(
//               _expanded ? 'show_less'.tr : 'read_more'.tr,
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 color: const Color(0xFF2E7D32),
//               ),
//             ),
//           ),
//         ],
//       ],
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // PRODUCT DETAIL SCREEN
// // ─────────────────────────────────────────────────────────────

// class ProductDetailScreen extends StatefulWidget {
//   final int productId;

//   const ProductDetailScreen({super.key, required this.productId});

//   @override
//   State<ProductDetailScreen> createState() => _ProductDetailScreenState();
// }

// class _ProductDetailScreenState extends State<ProductDetailScreen>
//     with TickerProviderStateMixin {
//   late Future<dynamic> productFuture;

//   int qty = 1;
//   int cartQty = 0;
//   bool isInCart = false;
//   bool cartLoading = false;
//   bool isFavorite = false;
//   int imageIndex = 0;

//   late AnimationController _favCtrl;
//   late Animation<double> _favScale;
//   late AnimationController _fadeCtrl;
//   late Animation<double> _fade;

//   @override
//   void initState() {
//     super.initState();
//     productFuture = ApiService().fetchProduct(widget.productId);
//     _loadCartQty();
//     _loadFavorite();

//     // favourite bounce
//     _favCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     _favScale = TweenSequence([
//       TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
//       TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
//     ]).animate(CurvedAnimation(parent: _favCtrl, curve: Curves.easeInOut));

//     // content fade-in
//     _fadeCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 480),
//     );
//     _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
//     _fadeCtrl.forward();
//   }

//   @override
//   void dispose() {
//     _favCtrl.dispose();
//     _fadeCtrl.dispose();
//     super.dispose();
//   }

//   // ── Cart logic (unchanged) ──────────────────────────────────

//   Future<void> _loadCartQty() async {
//     try {
//       final q = await ApiService().getCartQuantity(productId: widget.productId);
//       if (mounted) {
//         setState(() {
//           cartQty = q;
//           qty = q > 0 ? q : 1;
//           isInCart = q > 0;
//         });
//       }
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
//       if (mounted) {
//         setState(() {
//           isInCart = true;
//           cartQty = qty;
//         });
//         // Refresh CartProvider so FloatingCartBar appears immediately
//         context.read<CartProvider>().fetchCart();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(isInCart ? 'cart_updated'.tr : 'added_to_cart'.tr),
//             duration: const Duration(milliseconds: 900),
//           ),
//         );
//       }
//     } catch (_) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('something_went_wrong'.tr)));
//       }
//     } finally {
//       if (mounted) setState(() => cartLoading = false);
//     }
//   }

//   Future<void> _loadFavorite() async {
//     final saved = await WishlistService().isFavorite(widget.productId);
//     if (mounted) setState(() => isFavorite = saved);
//   }

//   Future<void> _toggleFavourite() async {
//     HapticFeedback.lightImpact();
//     final saved = await WishlistService().toggle(widget.productId);
//     if (mounted) setState(() => isFavorite = saved);
//     _favCtrl.forward(from: 0);
//   }

//   // ── Build ───────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final mq = MediaQuery.of(context);
//     final s = mq.size;

//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//         elevation: 0,
//         surfaceTintColor: Colors.transparent,
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back_ios_new_rounded,
//             size: 18,
//             color: colors.text1,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           'detail'.tr,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w700,
//             color: colors.text1,
//           ),
//         ),
//         centerTitle: true,
//         actions: [
//           ScaleTransition(
//             scale: _favScale,
//             child: IconButton(
//               icon: AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 250),
//                 transitionBuilder: (child, anim) =>
//                     ScaleTransition(scale: anim, child: child),
//                 child: Icon(
//                   isFavorite
//                       ? Icons.favorite_rounded
//                       : Icons.favorite_border_rounded,
//                   key: ValueKey(isFavorite),
//                   color: isFavorite ? colors.flashText : colors.text2,
//                   size: 22,
//                 ),
//               ),
//               onPressed: _toggleFavourite,
//             ),
//           ),
//         ],
//       ),
//       body: FutureBuilder(
//         future: productFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting ||
//               !snapshot.hasData) {
//             return const _DetailSkeleton();
//           }
//           if (snapshot.hasError) {
//             return const SafeArea(child: _ErrorState());
//           }

//           final p = snapshot.data;
//           final images = (p.images as List?) ?? [];

//           return FadeTransition(
//             opacity: _fade,
//             child: SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               child: Column(
//                 children: [
//                   // ── Hero image card ─────────────────────────
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(24),
//                       child: Container(
//                         height: s.height * .42,
//                         color: colors.surface2,
//                         child: Stack(
//                           fit: StackFit.expand,
//                           children: [
//                             if (images.isNotEmpty)
//                               PageView.builder(
//                                 itemCount: images.length,
//                                 onPageChanged: (i) =>
//                                     setState(() => imageIndex = i),
//                                 itemBuilder: (_, i) => Image.network(
//                                   images[i] as String,
//                                   fit: BoxFit.cover,
//                                   width: double.infinity,
//                                   height: double.infinity,
//                                   errorBuilder: (_, __, ___) => Icon(
//                                     Icons.image_outlined,
//                                     size: 56,
//                                     color: colors.text3,
//                                   ),
//                                 ),
//                               )
//                             else
//                               Icon(
//                                 Icons.image_outlined,
//                                 size: 56,
//                                 color: colors.text3,
//                               ),
//                             if (p.discount != null)
//                               Positioned(
//                                 top: _T.sp12,
//                                 left: _T.sp12,
//                                 child: _DiscountBadge(
//                                   label: p.discount.toString(),
//                                   colors: colors,
//                                 ),
//                               ),
//                             if (images.length > 1)
//                               Positioned(
//                                 bottom: _T.sp12,
//                                 left: 0,
//                                 right: 0,
//                                 child: _DotIndicator(
//                                   count: images.length,
//                                   activeIndex: imageIndex,
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),

//                   // ── Content card ────────────────────────────
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: colors.cardBg,
//                         borderRadius: BorderRadius.circular(28),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withValues(alpha: 0.30),
//                             blurRadius: 20,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: Padding(
//                         padding: EdgeInsets.fromLTRB(
//                           _T.sp24,
//                           _T.sp20,
//                           _T.sp24,
//                           mq.padding.bottom + _T.sp24,
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // brand above name
//                             if ((p.brandName as String?)?.isNotEmpty == true)
//                               Text(
//                                 (p.brandName as String).trCatalog,
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w500,
//                                   color: colors.text3,
//                                   letterSpacing: .3,
//                                 ),
//                               ),

//                             const SizedBox(height: _T.sp6),

//                             // product name
//                             Text(
//                               p.name as String,
//                               style: TextStyle(
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.w800,
//                                 color: colors.text1,
//                                 letterSpacing: -.4,
//                                 height: 1.2,
//                               ),
//                             ),

//                             const SizedBox(height: _T.sp14),

//                             // stats row
//                             Row(
//                               children: [
//                                 const Icon(
//                                   Icons.storefront_outlined,
//                                   size: 15,
//                                   color: Color(0xFFE65100),
//                                 ),
//                                 const SizedBox(width: _T.sp4),
//                                 Text(
//                                   (p.brandName as String?)?.isNotEmpty == true
//                                       ? (p.brandName as String).trCatalog
//                                       : '—',
//                                   style: const TextStyle(
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.w600,
//                                     color: Color(0xFF00E676),
//                                   ),
//                                 ),
//                                 const SizedBox(width: _T.sp16),
//                                 Icon(
//                                   Icons.remove_red_eye_outlined,
//                                   size: 15,
//                                   color: colors.text3,
//                                 ),
//                                 const SizedBox(width: _T.sp4),
//                                 Text(
//                                   '${p.quantity ?? 0} in stock',
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.w600,
//                                     color: colors.text2,
//                                   ),
//                                 ),
//                               ],
//                             ),

//                             const SizedBox(height: _T.sp14),

//                             // category + price row
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 if ((p.categoryName as String?)?.isNotEmpty ==
//                                     true)
//                                   Text(
//                                     p.categoryName as String,
//                                     style: TextStyle(
//                                       fontSize: 13,
//                                       color: colors.text3,
//                                     ),
//                                   )
//                                 else
//                                   const SizedBox.shrink(),
//                                 Row(
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: [
//                                     if (p.discount != null) ...[
//                                       Text(
//                                         '\$${p.salePrice}',
//                                         style: TextStyle(
//                                           fontSize: 13,
//                                           color: colors.text3,
//                                           decoration:
//                                               TextDecoration.lineThrough,
//                                           decorationColor: colors.text3,
//                                         ),
//                                       ),
//                                       const SizedBox(width: _T.sp6),
//                                     ],
//                                     Text(
//                                       '\$${p.finalPrice}',
//                                       style: TextStyle(
//                                         fontSize: 22,
//                                         fontWeight: FontWeight.w900,
//                                         color: colors.text1,
//                                         letterSpacing: -.5,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),

//                             const SizedBox(height: _T.sp16),

//                             // Description accordion
//                             _AccordionRow(
//                               title: 'description'.tr,
//                               colors: colors,
//                               child: Padding(
//                                 padding: const EdgeInsets.only(
//                                   top: _T.sp10,
//                                   bottom: _T.sp4,
//                                 ),
//                                 child: Text(
//                                   (p.description as String?) ?? '',
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     height: 1.65,
//                                     color: colors.text2,
//                                   ),
//                                 ),
//                               ),
//                             ),

//                             // Quantity accordion
//                             _AccordionRow(
//                               title: 'quantity'.tr,
//                               colors: colors,
//                               child: Padding(
//                                 padding: const EdgeInsets.only(
//                                   top: _T.sp12,
//                                   bottom: _T.sp4,
//                                 ),
//                                 child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Container(
//                                       decoration: BoxDecoration(
//                                         border: Border.all(
//                                           color: colors.border,
//                                         ),
//                                         borderRadius: BorderRadius.circular(14),
//                                       ),
//                                       child: Row(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           GestureDetector(
//                                             onTap: () => setState(() => qty++),
//                                             child: Padding(
//                                               padding: const EdgeInsets.all(12),
//                                               child: Icon(
//                                                 Icons.add_rounded,
//                                                 size: 18,
//                                                 color: colors.text2,
//                                               ),
//                                             ),
//                                           ),
//                                           AnimatedSwitcher(
//                                             duration: const Duration(
//                                               milliseconds: 180,
//                                             ),
//                                             transitionBuilder: (child, anim) =>
//                                                 ScaleTransition(
//                                                   scale: anim,
//                                                   child: child,
//                                                 ),
//                                             child: SizedBox(
//                                               key: ValueKey(qty),
//                                               width: 28,
//                                               child: Text(
//                                                 '$qty',
//                                                 textAlign: TextAlign.center,
//                                                 style: const TextStyle(
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.w700,
//                                                   color: Color(0xFFE65100),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                           GestureDetector(
//                                             onTap: qty > 1
//                                                 ? () => setState(() => qty--)
//                                                 : null,
//                                             child: Padding(
//                                               padding: const EdgeInsets.all(12),
//                                               child: Icon(
//                                                 Icons.remove_rounded,
//                                                 size: 18,
//                                                 color: qty > 1
//                                                     ? colors.text2
//                                                     : colors.text3,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.end,
//                                       children: [
//                                         Text(
//                                           'total'.tr,
//                                           style: TextStyle(
//                                             fontSize: 11,
//                                             color: colors.text3,
//                                           ),
//                                         ),
//                                         Text(
//                                           '\$${((double.tryParse(p.finalPrice.toString()) ?? 0) * qty).toStringAsFixed(2)}',
//                                           style: TextStyle(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.w800,
//                                             color: colors.text1,
//                                             letterSpacing: -.4,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),

//                             const SizedBox(height: _T.sp20),

//                             // Add to Cart button
//                             GestureDetector(
//                               onTap: cartLoading ? null : () => _handleCart(p),
//                               child: AnimatedContainer(
//                                 duration: const Duration(milliseconds: 200),
//                                 height: 52,
//                                 decoration: BoxDecoration(
//                                   color: cartLoading
//                                       ? const Color.fromARGB(
//                                           255,
//                                           0,
//                                           230,
//                                           119,
//                                         ).withValues(alpha: 0.6)
//                                       : const Color.fromARGB(
//                                           255,
//                                           0,
//                                           230,
//                                           119,
//                                         ).withValues(alpha: 0.6),
//                                   borderRadius: BorderRadius.circular(16),
//                                   boxShadow: cartLoading
//                                       ? []
//                                       : [
//                                           BoxShadow(
//                                             color: const Color(
//                                               0xFF00FF00,
//                                             ).withValues(alpha: 0.08),
//                                             blurRadius: 9,
//                                             offset: const Offset(0, 4),
//                                           ),
//                                         ],
//                                 ),
//                                 child: Center(
//                                   child: cartLoading
//                                       ? const SkeletonBox(
//                                           width: 92,
//                                           height: 12,
//                                           borderRadius: BorderRadius.all(
//                                             Radius.circular(6),
//                                           ),
//                                           baseColor: Colors.white54,
//                                           highlightColor: Colors.white,
//                                         )
//                                       : Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             Text(
//                                               isInCart
//                                                   ? 'update_cart'.tr
//                                                   : 'add_to_cart'.tr,
//                                               style: const TextStyle(
//                                                 fontSize: 15,
//                                                 fontWeight: FontWeight.w700,
//                                                 color: Colors.white,
//                                                 letterSpacing: .2,
//                                               ),
//                                             ),
//                                             const SizedBox(width: _T.sp8),
//                                             const Icon(
//                                               Icons.arrow_forward_rounded,
//                                               color: Colors.white,
//                                               size: 18,
//                                             ),
//                                           ],
//                                         ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';
// import '../../providers/cart_provider.dart';
// import '../../services/api_service.dart';
// import '../../translations/catalog_translation.dart';
// import '../../services/wishlist_service.dart';
// import '../../widgets/skeleton_loader.dart';
// import '../theme/app_theme.dart';

// // ─────────────────────────────────────────────────────────────
// // DESIGN TOKENS
// // ─────────────────────────────────────────────────────────────

// abstract class _T {
//   static const double sp4 = 4;
//   static const double sp6 = 6;
//   static const double sp8 = 8;
//   static const double sp10 = 10;
//   static const double sp12 = 12;
//   static const double sp14 = 14;
//   static const double sp16 = 16;
//   static const double sp18 = 18;
//   static const double sp20 = 20;
//   static const double sp22 = 22;
//   static const double sp24 = 24;
//   static const double sp28 = 28;
//   static const double sp32 = 32;
//   static const double sp40 = 40;
//   static const double sp48 = 48;

//   static const double radiusSm = 8;
//   static const double radiusMd = 12;
//   static const double radiusLg = 16;
//   static const double radiusXl = 22;
//   static const double radiusCard = 28;
//   static const double radiusFull = 999;

//   // ── Typography ──────────────────────────────────────────────
//   static TextStyle displayName(Color c) => TextStyle(
//     fontSize: 22,
//     fontWeight: FontWeight.w800,
//     color: c,
//     letterSpacing: -.4,
//     height: 1.2,
//   );

//   static TextStyle priceMain(Color c) => TextStyle(
//     fontSize: 28,
//     fontWeight: FontWeight.w800,
//     color: c,
//     letterSpacing: -.8,
//   );

//   static TextStyle priceOld(Color c) => TextStyle(
//     fontSize: 13,
//     fontWeight: FontWeight.w400,
//     color: c,
//     decoration: TextDecoration.lineThrough,
//     decorationColor: c,
//   );

//   static TextStyle accordTitle(Color c) => TextStyle(
//     fontSize: 14,
//     fontWeight: FontWeight.w600,
//     color: c,
//     letterSpacing: -.1,
//   );

//   static TextStyle bodyText(Color c) => TextStyle(
//     fontSize: 12,
//     fontWeight: FontWeight.w400,
//     color: c,
//     height: 1.7,
//   );

//   static TextStyle metaText(Color c) =>
//       TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: c);

//   static TextStyle chipLabel(Color c) => TextStyle(
//     fontSize: 10,
//     fontWeight: FontWeight.w600,
//     color: c,
//     letterSpacing: .8,
//   );

//   static TextStyle qtyNum(Color c) =>
//       TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c);

//   static TextStyle totalVal(Color c) => TextStyle(
//     fontSize: 17,
//     fontWeight: FontWeight.w700,
//     color: c,
//     letterSpacing: -.3,
//   );

//   static TextStyle totalLbl(Color c) => TextStyle(
//     fontSize: 10,
//     fontWeight: FontWeight.w500,
//     color: c,
//     letterSpacing: .5,
//   );

//   static TextStyle ctaText(Color c) => TextStyle(
//     fontSize: 14,
//     fontWeight: FontWeight.w700,
//     color: c,
//     letterSpacing: .3,
//   );

//   static TextStyle saveTag(Color c) =>
//       TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c);

//   static TextStyle readMore(Color c) =>
//       TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c);
// }

// // ─────────────────────────────────────────────────────────────
// // SHIMMER
// // ─────────────────────────────────────────────────────────────

// class _Shimmer extends StatefulWidget {
//   final double? width;
//   final double height;
//   final double borderRadius;

//   const _Shimmer({this.width, required this.height, this.borderRadius = 8});

//   @override
//   State<_Shimmer> createState() => _ShimmerState();
// }

// class _ShimmerState extends State<_Shimmer>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _ctrl;
//   late final Animation<double> _anim;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     )..repeat();
//     _anim = Tween<double>(
//       begin: -1.5,
//       end: 1.5,
//     ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final base = isDark ? colors.surface : colors.surface2;
//     final highlight = isDark ? colors.surface2 : colors.background;

//     return AnimatedBuilder(
//       animation: _anim,
//       builder: (_, __) => Container(
//         width: widget.width,
//         height: widget.height,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(widget.borderRadius),
//           gradient: LinearGradient(
//             begin: Alignment(_anim.value - 1, 0),
//             end: Alignment(_anim.value + 1, 0),
//             colors: [base, highlight, base],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // SKELETON
// // ─────────────────────────────────────────────────────────────

// class _DetailSkeleton extends StatelessWidget {
//   const _DetailSkeleton();

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final mq = MediaQuery.of(context);

//     return Scaffold(
//       backgroundColor: colors.background,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const NeverScrollableScrollPhysics(),
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: _T.sp16,
//                   vertical: _T.sp12,
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: const [
//                     _Shimmer(width: 38, height: 38, borderRadius: _T.radiusMd),
//                     _Shimmer(width: 70, height: 18, borderRadius: 6),
//                     _Shimmer(width: 38, height: 38, borderRadius: _T.radiusMd),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: _T.sp16),
//                 child: _Shimmer(
//                   width: double.infinity,
//                   height: mq.size.height * .42,
//                   borderRadius: _T.radiusCard,
//                 ),
//               ),
//               const SizedBox(height: _T.sp12),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: _T.sp16),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: colors.cardBg,
//                     borderRadius: BorderRadius.circular(_T.radiusCard),
//                     border: Border.all(color: colors.border, width: .5),
//                   ),
//                   padding: const EdgeInsets.all(_T.sp20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: const [
//                           _Shimmer(
//                             width: 80,
//                             height: 24,
//                             borderRadius: _T.radiusSm,
//                           ),
//                           SizedBox(width: _T.sp8),
//                           _Shimmer(
//                             width: 60,
//                             height: 24,
//                             borderRadius: _T.radiusSm,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: _T.sp12),
//                       const _Shimmer(
//                         width: double.infinity,
//                         height: 22,
//                         borderRadius: 6,
//                       ),
//                       const SizedBox(height: _T.sp6),
//                       const _Shimmer(width: 180, height: 22, borderRadius: 6),
//                       const SizedBox(height: _T.sp16),
//                       Row(
//                         children: const [
//                           _Shimmer(width: 110, height: 13, borderRadius: 4),
//                           SizedBox(width: _T.sp16),
//                           _Shimmer(width: 90, height: 13, borderRadius: 4),
//                         ],
//                       ),
//                       const SizedBox(height: _T.sp16),
//                       const _Shimmer(
//                         width: double.infinity,
//                         height: .5,
//                         borderRadius: 0,
//                       ),
//                       const SizedBox(height: _T.sp16),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: const [
//                           _Shimmer(width: 120, height: 30, borderRadius: 6),
//                           _Shimmer(
//                             width: 80,
//                             height: 28,
//                             borderRadius: _T.radiusFull,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: _T.sp24),
//                       const _Shimmer(
//                         width: double.infinity,
//                         height: .5,
//                         borderRadius: 0,
//                       ),
//                       const SizedBox(height: _T.sp16),
//                       ...List.generate(
//                         3,
//                         (i) => Padding(
//                           padding: const EdgeInsets.only(bottom: _T.sp8),
//                           child: _Shimmer(
//                             width: i == 2 ? 160 : double.infinity,
//                             height: 12,
//                             borderRadius: 4,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: _T.sp24),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: const [
//                           _Shimmer(width: 70, height: 14, borderRadius: 4),
//                           _Shimmer(
//                             width: 120,
//                             height: 40,
//                             borderRadius: _T.radiusMd,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: _T.sp24),
//                       Row(
//                         children: const [
//                           _Shimmer(
//                             width: 50,
//                             height: 50,
//                             borderRadius: _T.radiusLg,
//                           ),
//                           SizedBox(width: _T.sp10),
//                           Expanded(
//                             child: _Shimmer(
//                               height: 50,
//                               borderRadius: _T.radiusLg,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // ERROR STATE
// // ─────────────────────────────────────────────────────────────

// class _ErrorState extends StatelessWidget {
//   const _ErrorState();

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(_T.sp32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 72,
//               height: 72,
//               decoration: BoxDecoration(
//                 color: colors.flashBg,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.wifi_off_rounded,
//                 size: 32,
//                 color: colors.flashText,
//               ),
//             ),
//             const SizedBox(height: _T.sp16),
//             Text(
//               'failed_to_load_product'.tr,
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w600,
//                 color: colors.text2,
//               ),
//             ),
//             const SizedBox(height: _T.sp6),
//             Text(
//               'please_try_again'.tr,
//               style: TextStyle(fontSize: 12, color: colors.text3),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // OVERLAY BUTTON  (on hero image)
// // ─────────────────────────────────────────────────────────────

// class _OverlayButton extends StatelessWidget {
//   final Widget child;
//   final VoidCallback onTap;
//   final bool isDark;

//   const _OverlayButton({
//     required this.child,
//     required this.onTap,
//     this.isDark = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 38,
//         height: 38,
//         decoration: BoxDecoration(
//           color: isDark
//               ? Colors.black.withOpacity(.55)
//               : Colors.white.withOpacity(.82),
//           borderRadius: BorderRadius.circular(_T.radiusMd),
//           border: Border.all(
//             color: isDark
//                 ? Colors.white.withOpacity(.1)
//                 : Colors.black.withOpacity(.06),
//             width: .5,
//           ),
//         ),
//         child: child,
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // DOT INDICATOR
// // ─────────────────────────────────────────────────────────────

// class _DotIndicator extends StatelessWidget {
//   final int count;
//   final int activeIndex;
//   final bool isDark;

//   const _DotIndicator({
//     required this.count,
//     required this.activeIndex,
//     this.isDark = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: List.generate(count, (i) {
//         final active = i == activeIndex;
//         return AnimatedContainer(
//           duration: const Duration(milliseconds: 250),
//           margin: const EdgeInsets.symmetric(horizontal: 3),
//           width: active ? 18 : 6,
//           height: 6,
//           decoration: BoxDecoration(
//             color: active
//                 ? (isDark ? Colors.white : const Color(0xFF333333))
//                 : (isDark
//                       ? Colors.white.withOpacity(.3)
//                       : Colors.black.withOpacity(.2)),
//             borderRadius: BorderRadius.circular(_T.radiusFull),
//           ),
//         );
//       }),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // BRAND / CATEGORY CHIP  — uses AppColors tokens
// // ─────────────────────────────────────────────────────────────

// class _LabelChip extends StatelessWidget {
//   final String label;
//   final Color bg;
//   final Color textColor;

//   const _LabelChip({
//     required this.label,
//     required this.bg,
//     required this.textColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (label.isEmpty) return const SizedBox.shrink();
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: _T.sp10,
//         vertical: _T.sp6,
//       ),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(_T.radiusSm),
//         border: Border.all(color: textColor.withOpacity(.15), width: .5),
//       ),
//       child: Text(label.toUpperCase(), style: _T.chipLabel(textColor)),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // THIN DIVIDER  — uses AppColors.border
// // ─────────────────────────────────────────────────────────────

// class _SheetDivider extends StatelessWidget {
//   const _SheetDivider();

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     return Divider(color: colors.border, height: 1, thickness: .5);
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // ACCORDION ROW  — uses AppColors tokens
// // ─────────────────────────────────────────────────────────────

// class _AccordionRow extends StatefulWidget {
//   final String title;
//   final Widget child;

//   const _AccordionRow({required this.title, required this.child});

//   @override
//   State<_AccordionRow> createState() => _AccordionRowState();
// }

// class _AccordionRowState extends State<_AccordionRow>
//     with SingleTickerProviderStateMixin {
//   bool _open = false;
//   late final AnimationController _ctrl;
//   late final Animation<double> _anim;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 260),
//     );
//     _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;

//     return Column(
//       children: [
//         Divider(color: colors.border, height: 1, thickness: .5),
//         GestureDetector(
//           behavior: HitTestBehavior.opaque,
//           onTap: () {
//             setState(() => _open = !_open);
//             _open ? _ctrl.forward() : _ctrl.reverse();
//           },
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: _T.sp14),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(widget.title, style: _T.accordTitle(colors.text1)),
//                 AnimatedRotation(
//                   turns: _open ? .5 : 0,
//                   duration: const Duration(milliseconds: 260),
//                   child: Icon(
//                     Icons.keyboard_arrow_down_rounded,
//                     color: colors.text3,
//                     size: 20,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         SizeTransition(sizeFactor: _anim, child: widget.child),
//       ],
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // EXPANDABLE DESCRIPTION  — uses AppColors tokens
// // ─────────────────────────────────────────────────────────────

// class _ExpandableDescription extends StatefulWidget {
//   final String text;
//   const _ExpandableDescription({required this.text});

//   @override
//   State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
// }

// class _ExpandableDescriptionState extends State<_ExpandableDescription> {
//   bool _expanded = false;

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         AnimatedCrossFade(
//           duration: const Duration(milliseconds: 250),
//           crossFadeState: _expanded
//               ? CrossFadeState.showSecond
//               : CrossFadeState.showFirst,
//           firstChild: Text(
//             widget.text,
//             maxLines: 3,
//             overflow: TextOverflow.ellipsis,
//             style: _T.bodyText(colors.text2),
//           ),
//           secondChild: Text(widget.text, style: _T.bodyText(colors.text2)),
//         ),
//         if (widget.text.length > 120) ...[
//           const SizedBox(height: _T.sp6),
//           GestureDetector(
//             onTap: () => setState(() => _expanded = !_expanded),
//             child: Text(
//               _expanded ? 'show_less'.tr : 'read_more'.tr,
//               style: _T.readMore(colors.accent),
//             ),
//           ),
//         ],
//       ],
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // QUANTITY STEPPER  — uses AppColors tokens
// // ─────────────────────────────────────────────────────────────

// class _QuantityStepper extends StatelessWidget {
//   final int qty;
//   final VoidCallback onDecrement;
//   final VoidCallback onIncrement;

//   const _QuantityStepper({
//     required this.qty,
//     required this.onDecrement,
//     required this.onIncrement,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;

//     return Container(
//       height: 40,
//       decoration: BoxDecoration(
//         color: colors.surface2,
//         borderRadius: BorderRadius.circular(_T.radiusMd),
//         border: Border.all(color: colors.border, width: .5),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           GestureDetector(
//             onTap: onIncrement,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: _T.sp12,
//                 vertical: _T.sp10,
//               ),
//               child: Icon(Icons.add_rounded, size: 16, color: colors.text2),
//             ),
//           ),
//           Container(width: 1, height: 40, color: colors.border),
//           AnimatedSwitcher(
//             duration: const Duration(milliseconds: 180),
//             transitionBuilder: (child, anim) =>
//                 ScaleTransition(scale: anim, child: child),
//             child: SizedBox(
//               key: ValueKey(qty),
//               width: 34,
//               child: Text(
//                 '$qty',
//                 textAlign: TextAlign.center,
//                 style: _T.qtyNum(colors.text1),
//               ),
//             ),
//           ),
//           Container(width: 1, height: 40, color: colors.border),
//           GestureDetector(
//             onTap: qty > 1 ? onDecrement : null,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: _T.sp12,
//                 vertical: _T.sp10,
//               ),
//               child: Icon(
//                 Icons.remove_rounded,
//                 size: 16,
//                 color: qty > 1 ? colors.text2 : colors.border,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // WISHLIST BUTTON  — uses AppColors.flashBg / flashText / accent
// // ─────────────────────────────────────────────────────────────

// class _WishlistButton extends StatelessWidget {
//   final bool isFavorite;
//   final VoidCallback onTap;

//   const _WishlistButton({required this.isFavorite, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;

//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 50,
//         height: 50,
//         decoration: BoxDecoration(
//           color: colors.flashBg,
//           borderRadius: BorderRadius.circular(_T.radiusLg),
//           border: Border.all(color: colors.flashBorder, width: .5),
//         ),
//         child: AnimatedSwitcher(
//           duration: const Duration(milliseconds: 250),
//           transitionBuilder: (child, anim) =>
//               ScaleTransition(scale: anim, child: child),
//           child: Icon(
//             isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
//             key: ValueKey(isFavorite),
//             color: colors.flashText,
//             size: 20,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // CART BUTTON  — uses AppColors.accent / text1 / surface
// // ─────────────────────────────────────────────────────────────

// class _CartButton extends StatelessWidget {
//   final bool isInCart;
//   final bool loading;
//   final String price;
//   final VoidCallback onTap;

//   const _CartButton({
//     required this.isInCart,
//     required this.loading,
//     required this.price,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     // button bg = accent; label on it = surface (white/near-white)
//     final bg = colors.accent;
//     final fg = colors.surface;

//     return Expanded(
//       child: GestureDetector(
//         onTap: loading ? null : onTap,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           height: 50,
//           decoration: BoxDecoration(
//             color: loading ? bg.withOpacity(.65) : bg,
//             borderRadius: BorderRadius.circular(_T.radiusLg),
//           ),
//           child: Center(
//             child: loading
//                 ? SkeletonBox(
//                     width: 88,
//                     height: 12,
//                     borderRadius: const BorderRadius.all(Radius.circular(6)),
//                     baseColor: fg.withOpacity(.3),
//                     highlightColor: fg.withOpacity(.6),
//                   )
//                 : Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         isInCart
//                             ? Icons.shopping_cart_checkout_rounded
//                             : Icons.shopping_bag_outlined,
//                         color: fg,
//                         size: 18,
//                       ),
//                       const SizedBox(width: _T.sp8),
//                       Text(
//                         isInCart
//                             ? '${'update_cart'.tr} · \$$price'
//                             : '${'add_to_cart'.tr} · \$$price',
//                         style: _T.ctaText(fg),
//                       ),
//                     ],
//                   ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // STOCK BADGE  — uses AppColors tokens
// // ─────────────────────────────────────────────────────────────

// class _StockBadge extends StatelessWidget {
//   final int qty;
//   const _StockBadge({required this.qty});

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final inStock = qty > 0;

//     // green tint when in stock, flash (red) when out
//     final bg = inStock ? colors.accentLight : colors.flashBg;
//     final text = inStock ? colors.accent : colors.flashText;

//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: _T.sp10,
//         vertical: _T.sp4,
//       ),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(_T.radiusFull),
//         border: Border.all(color: text.withOpacity(.25), width: .5),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 6,
//             height: 6,
//             decoration: BoxDecoration(color: text, shape: BoxShape.circle),
//           ),
//           const SizedBox(width: _T.sp4),
//           Text(
//             inStock ? '$qty ${'in_stock'.tr}' : 'out_of_stock'.tr,
//             style: _T.chipLabel(text),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // PRODUCT DETAIL SCREEN
// // ─────────────────────────────────────────────────────────────

// class ProductDetailScreen extends StatefulWidget {
//   final int productId;

//   const ProductDetailScreen({super.key, required this.productId});

//   @override
//   State<ProductDetailScreen> createState() => _ProductDetailScreenState();
// }

// class _ProductDetailScreenState extends State<ProductDetailScreen>
//     with TickerProviderStateMixin {
//   late Future<dynamic> productFuture;

//   int qty = 1;
//   int cartQty = 0;
//   bool isInCart = false;
//   bool cartLoading = false;
//   bool isFavorite = false;
//   int imageIndex = 0;

//   late AnimationController _favCtrl;
//   late Animation<double> _favScale;
//   late AnimationController _fadeCtrl;
//   late Animation<double> _fade;

//   @override
//   void initState() {
//     super.initState();
//     productFuture = ApiService().fetchProduct(widget.productId);
//     _loadCartQty();
//     _loadFavorite();

//     _favCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     _favScale = TweenSequence([
//       TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
//       TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
//     ]).animate(CurvedAnimation(parent: _favCtrl, curve: Curves.easeInOut));

//     _fadeCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 480),
//     );
//     _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
//     _fadeCtrl.forward();
//   }

//   @override
//   void dispose() {
//     _favCtrl.dispose();
//     _fadeCtrl.dispose();
//     super.dispose();
//   }

//   // ── Cart ───────────────────────────────────────────────────

//   Future<void> _loadCartQty() async {
//     try {
//       final q = await ApiService().getCartQuantity(productId: widget.productId);
//       if (mounted) {
//         setState(() {
//           cartQty = q;
//           qty = q > 0 ? q : 1;
//           isInCart = q > 0;
//         });
//       }
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
//       if (mounted) {
//         setState(() {
//           isInCart = true;
//           cartQty = qty;
//         });
//         context.read<CartProvider>().fetchCart();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(isInCart ? 'cart_updated'.tr : 'added_to_cart'.tr),
//             duration: const Duration(milliseconds: 900),
//           ),
//         );
//       }
//     } catch (_) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('something_went_wrong'.tr)));
//       }
//     } finally {
//       if (mounted) setState(() => cartLoading = false);
//     }
//   }

//   // ── Wishlist ───────────────────────────────────────────────

//   Future<void> _loadFavorite() async {
//     final saved = await WishlistService().isFavorite(widget.productId);
//     if (mounted) setState(() => isFavorite = saved);
//   }

//   Future<void> _toggleFavourite() async {
//     HapticFeedback.lightImpact();
//     final saved = await WishlistService().toggle(widget.productId);
//     if (mounted) setState(() => isFavorite = saved);
//     _favCtrl.forward(from: 0);
//   }

//   // ── Build ──────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final mq = MediaQuery.of(context);
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: colors.background,

//       // ── App bar ──────────────────────────────────────────
//       appBar: AppBar(
//         backgroundColor: colors.background,
//         elevation: 0,
//         surfaceTintColor: Colors.transparent,
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back_ios_new_rounded,
//             size: 16,
//             color: colors.text1,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           'detail'.tr,
//           style: TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w700,
//             color: colors.text1,
//           ),
//         ),
//         centerTitle: true,
//         actions: [
//           ScaleTransition(
//             scale: _favScale,
//             child: IconButton(
//               icon: AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 250),
//                 transitionBuilder: (child, anim) =>
//                     ScaleTransition(scale: anim, child: child),
//                 child: Icon(
//                   isFavorite
//                       ? Icons.favorite_rounded
//                       : Icons.favorite_border_rounded,
//                   key: ValueKey(isFavorite),
//                   color: isFavorite ? colors.flashText : colors.text2,
//                   size: 20,
//                 ),
//               ),
//               onPressed: _toggleFavourite,
//             ),
//           ),
//         ],
//       ),

//       body: FutureBuilder(
//         future: productFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting ||
//               !snapshot.hasData) {
//             return const _DetailSkeleton();
//           }
//           if (snapshot.hasError) {
//             return const SafeArea(child: _ErrorState());
//           }

//           final p = snapshot.data;
//           final images = (p.images as List?) ?? [];
//           final finalPrice = (double.tryParse(p.finalPrice.toString()) ?? 0);
//           final totalStr = (finalPrice * qty).toStringAsFixed(2);

//           return FadeTransition(
//             opacity: _fade,
//             child: SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // ── Hero image card ─────────────────────
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(
//                       _T.sp16,
//                       _T.sp8,
//                       _T.sp16,
//                       0,
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(_T.radiusCard),
//                       child: Container(
//                         height: mq.size.height * .42,
//                         color: colors.surface2,
//                         child: Stack(
//                           fit: StackFit.expand,
//                           children: [
//                             // ── images ──
//                             if (images.isNotEmpty)
//                               PageView.builder(
//                                 itemCount: images.length,
//                                 onPageChanged: (i) =>
//                                     setState(() => imageIndex = i),
//                                 itemBuilder: (_, i) => Image.network(
//                                   images[i] as String,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (_, __, ___) => Icon(
//                                     Icons.image_outlined,
//                                     size: 48,
//                                     color: colors.text3,
//                                   ),
//                                 ),
//                               )
//                             else
//                               Center(
//                                 child: Icon(
//                                   Icons.image_outlined,
//                                   size: 48,
//                                   color: colors.text3,
//                                 ),
//                               ),

//                             // ── top controls ──
//                             Positioned(
//                               top: _T.sp14,
//                               left: _T.sp14,
//                               right: _T.sp14,
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   _OverlayButton(
//                                     isDark: isDark,
//                                     onTap: () => Navigator.pop(context),
//                                     child: Icon(
//                                       Icons.arrow_back_ios_new_rounded,
//                                       size: 15,
//                                       color: isDark
//                                           ? Colors.white70
//                                           : colors.text1,
//                                     ),
//                                   ),
//                                   if (images.length > 1)
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: _T.sp12,
//                                         vertical: _T.sp6,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: Colors.black.withOpacity(.42),
//                                         borderRadius: BorderRadius.circular(
//                                           _T.radiusFull,
//                                         ),
//                                       ),
//                                       child: Text(
//                                         '${imageIndex + 1} / ${images.length}',
//                                         style: const TextStyle(
//                                           fontSize: 11,
//                                           fontWeight: FontWeight.w500,
//                                           color: Colors.white,
//                                           letterSpacing: .5,
//                                         ),
//                                       ),
//                                     )
//                                   else
//                                     const SizedBox.shrink(),
//                                   _OverlayButton(
//                                     isDark: isDark,
//                                     onTap: _toggleFavourite,
//                                     child: Icon(
//                                       isFavorite
//                                           ? Icons.favorite_rounded
//                                           : Icons.favorite_border_rounded,
//                                       size: 16,
//                                       color: isFavorite
//                                           ? colors.flashText
//                                           : (isDark
//                                                 ? Colors.white70
//                                                 : colors.text1),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             // ── discount badge ──
//                             if (p.discount != null)
//                               Positioned(
//                                 bottom: _T.sp14,
//                                 left: _T.sp14,
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: _T.sp10,
//                                     vertical: _T.sp6,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: colors.flashText,
//                                     borderRadius: BorderRadius.circular(
//                                       _T.radiusSm,
//                                     ),
//                                   ),
//                                   child: Text(
//                                     p.discount.toString(),
//                                     style: const TextStyle(
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.w700,
//                                       color: Colors.white,
//                                       letterSpacing: .6,
//                                     ),
//                                   ),
//                                 ),
//                               ),

//                             // ── dot indicators ──
//                             if (images.length > 1)
//                               Positioned(
//                                 bottom: _T.sp16,
//                                 right: _T.sp16,
//                                 child: _DotIndicator(
//                                   count: images.length,
//                                   activeIndex: imageIndex,
//                                   isDark: isDark,
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: _T.sp12),

//                   // ── Content card ────────────────────────
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(
//                       _T.sp16,
//                       0,
//                       _T.sp16,
//                       _T.sp24,
//                     ),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: colors.cardBg,
//                         borderRadius: BorderRadius.circular(_T.radiusCard),
//                         border: Border.all(color: colors.border, width: .5),
//                       ),
//                       padding: EdgeInsets.fromLTRB(
//                         _T.sp20,
//                         _T.sp20,
//                         _T.sp20,
//                         mq.padding.bottom + _T.sp20,
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // ── Brand + category + stock ──
//                           Row(
//                             children: [
//                               if ((p.brandName as String?)?.isNotEmpty ==
//                                   true) ...[
//                                 _LabelChip(
//                                   label: (p.brandName as String).trCatalog,
//                                   bg: colors.bginfo,
//                                   textColor: colors.text2,
//                                 ),
//                                 const SizedBox(width: _T.sp8),
//                               ],
//                               if ((p.categoryName as String?)?.isNotEmpty ==
//                                   true) ...[
//                                 _LabelChip(
//                                   label: p.categoryName as String,
//                                   bg: colors.accentLight,
//                                   textColor: colors.accent,
//                                 ),
//                                 const SizedBox(width: _T.sp8),
//                               ],
//                               const Spacer(),
//                               _StockBadge(qty: (p.quantity as int?) ?? 0),
//                             ],
//                           ),

//                           const SizedBox(height: _T.sp10),

//                           // ── Product name ──
//                           Text(
//                             p.name as String,
//                             style: _T.displayName(colors.text1),
//                           ),

//                           const SizedBox(height: _T.sp10),

//                           // ── Meta row (brand store) ──
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.storefront_outlined,
//                                 size: 14,
//                                 color: colors.accent,
//                               ),
//                               const SizedBox(width: _T.sp4),
//                               Text(
//                                 (p.brandName as String?)?.isNotEmpty == true
//                                     ? (p.brandName as String).trCatalog
//                                     : '—',
//                                 style: _T.metaText(colors.accent),
//                               ),
//                               const SizedBox(width: _T.sp14),
//                               Icon(
//                                 Icons.remove_red_eye_outlined,
//                                 size: 14,
//                                 color: colors.text3,
//                               ),
//                               const SizedBox(width: _T.sp4),
//                               Text(
//                                 '${p.quantity ?? 0} ${'in_stock'.tr}',
//                                 style: _T.metaText(colors.text3),
//                               ),
//                             ],
//                           ),

//                           const SizedBox(height: _T.sp16),
//                           const _SheetDivider(),
//                           const SizedBox(height: _T.sp16),

//                           // ── Price row ──
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Row(
//                                 crossAxisAlignment: CrossAxisAlignment.baseline,
//                                 textBaseline: TextBaseline.alphabetic,
//                                 children: [
//                                   Text(
//                                     '\$${p.finalPrice}',
//                                     style: _T.priceMain(colors.text1),
//                                   ),
//                                   if (p.discount != null) ...[
//                                     const SizedBox(width: _T.sp8),
//                                     Text(
//                                       '\$${p.salePrice}',
//                                       style: _T.priceOld(colors.text3),
//                                     ),
//                                   ],
//                                 ],
//                               ),
//                               if (p.discount != null)
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: _T.sp12,
//                                     vertical: _T.sp6,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: colors.flashBg,
//                                     borderRadius: BorderRadius.circular(
//                                       _T.radiusFull,
//                                     ),
//                                     border: Border.all(
//                                       color: colors.flashBorder,
//                                       width: .5,
//                                     ),
//                                   ),
//                                   child: Text(
//                                     'save \$${((double.tryParse(p.salePrice.toString()) ?? 0) - finalPrice).abs().toStringAsFixed(0)}',
//                                     style: _T.saveTag(colors.flashText),
//                                   ),
//                                 ),
//                             ],
//                           ),

//                           // ── Description accordion ──
//                           _AccordionRow(
//                             title: 'description'.tr,
//                             child: Padding(
//                               padding: const EdgeInsets.only(bottom: _T.sp12),
//                               child: _ExpandableDescription(
//                                 text: (p.description as String?) ?? '',
//                               ),
//                             ),
//                           ),

//                           // ── Quantity accordion ──
//                           _AccordionRow(
//                             title: 'quantity'.tr,
//                             child: Padding(
//                               padding: const EdgeInsets.only(
//                                 top: _T.sp4,
//                                 bottom: _T.sp12,
//                               ),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   _QuantityStepper(
//                                     qty: qty,
//                                     onIncrement: () => setState(() => qty++),
//                                     onDecrement: () {
//                                       if (qty > 1) {
//                                         setState(() => qty--);
//                                       }
//                                     },
//                                   ),
//                                   Column(
//                                     crossAxisAlignment: CrossAxisAlignment.end,
//                                     children: [
//                                       Text(
//                                         'total'.tr.toUpperCase(),
//                                         style: _T.totalLbl(colors.text3),
//                                       ),
//                                       const SizedBox(height: 2),
//                                       Text(
//                                         '\$$totalStr',
//                                         style: _T.totalVal(colors.text1),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: _T.sp20),

//                           // ── CTA row ──
//                           Row(
//                             children: [
//                               _WishlistButton(
//                                 isFavorite: isFavorite,
//                                 onTap: _toggleFavourite,
//                               ),
//                               const SizedBox(width: _T.sp10),
//                               _CartButton(
//                                 isInCart: isInCart,
//                                 loading: cartLoading,
//                                 price: p.finalPrice.toString(),
//                                 onTap: () => _handleCart(p),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mart_frontend/providers/ProductDetailProvider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../translations/catalog_translation.dart';
import '../../services/wishlist_service.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────────────────────

abstract class _T {
  static const double sp4 = 4;
  static const double sp6 = 6;
  static const double sp8 = 8;
  static const double sp10 = 10;
  static const double sp12 = 12;
  static const double sp14 = 14;
  static const double sp16 = 16;
  static const double sp20 = 20;
  static const double sp24 = 24;
  static const double sp32 = 32;

  static const double radiusSm = 6;
  static const double radiusMd = 10;
  static const double radiusLg = 14;
  static const double radiusFull = 999;

  static TextStyle productName(Color c) => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: c,
    height: 1.3,
    letterSpacing: -.2,
  );

  static TextStyle priceMain(Color c) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: c,
    letterSpacing: -.4,
  );

  static TextStyle priceOld(Color c) => TextStyle(
    fontSize: 13,
    color: c,
    decoration: TextDecoration.lineThrough,
    decorationColor: c,
  );

  static TextStyle sectionLabel(Color c) =>
      TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: c);

  static TextStyle bodyText(Color c) =>
      TextStyle(fontSize: 13, color: c, height: 1.65);

  static TextStyle chipLabel(Color c) =>
      TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: c);

  static TextStyle qtyNum(Color c) =>
      TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c);

  static TextStyle ctaLabel(Color c) => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: c,
    letterSpacing: .2,
  );

  static TextStyle discountTag(Color c) =>
      TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c);
}

// ─────────────────────────────────────────────────────────────
// SHIMMER
// ─────────────────────────────────────────────────────────────

class _Shimmer extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;
  const _Shimmer({this.width, required this.height, this.borderRadius = 6});

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
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? colors.surface : colors.surface2;
    final highlight = isDark ? colors.surface2 : colors.background;
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
// SKELETON
// ─────────────────────────────────────────────────────────────

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mq = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          // image area — full width, no padding
          _Shimmer(
            width: double.infinity,
            height: mq.size.height * .44,
            borderRadius: 0,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                _T.sp16,
                _T.sp16,
                _T.sp16,
                _T.sp16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // chips
                  Row(
                    children: const [
                      _Shimmer(
                        width: 80,
                        height: 24,
                        borderRadius: _T.radiusFull,
                      ),
                      SizedBox(width: _T.sp8),
                      _Shimmer(
                        width: 60,
                        height: 24,
                        borderRadius: _T.radiusFull,
                      ),
                      SizedBox(width: _T.sp8),
                      _Shimmer(
                        width: 70,
                        height: 24,
                        borderRadius: _T.radiusFull,
                      ),
                    ],
                  ),
                  const SizedBox(height: _T.sp12),
                  const _Shimmer(
                    width: double.infinity,
                    height: 20,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: _T.sp6),
                  const _Shimmer(width: 160, height: 20, borderRadius: 4),
                  const SizedBox(height: _T.sp10),
                  const _Shimmer(width: 100, height: 26, borderRadius: 4),
                  const SizedBox(height: _T.sp20),
                  const _Shimmer(width: 60, height: 12, borderRadius: 3),
                  const SizedBox(height: _T.sp8),
                  ...List.generate(
                    3,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: _T.sp6),
                      child: _Shimmer(
                        width: i == 2 ? 140 : double.infinity,
                        height: 13,
                        borderRadius: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: _T.sp20),
                  const _Shimmer(
                    width: double.infinity,
                    height: .5,
                    borderRadius: 0,
                  ),
                  const SizedBox(height: _T.sp14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _Shimmer(width: 60, height: 14, borderRadius: 4),
                      _Shimmer(
                        width: 110,
                        height: 38,
                        borderRadius: _T.radiusMd,
                      ),
                    ],
                  ),
                  const SizedBox(height: _T.sp20),
                  const _Shimmer(
                    width: double.infinity,
                    height: .5,
                    borderRadius: 0,
                  ),
                  const SizedBox(height: _T.sp14),
                  Row(
                    children: const [
                      _Shimmer(
                        width: 48,
                        height: 48,
                        borderRadius: _T.radiusLg,
                      ),
                      SizedBox(width: _T.sp10),
                      Expanded(
                        child: _Shimmer(height: 48, borderRadius: _T.radiusLg),
                      ),
                    ],
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
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.flashBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 28,
                color: colors.flashText,
              ),
            ),
            const SizedBox(height: _T.sp16),
            Text(
              'failed_to_load_product'.tr,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.text2,
              ),
            ),
            const SizedBox(height: _T.sp6),
            Text(
              'please_try_again'.tr,
              style: TextStyle(fontSize: 12, color: colors.text3),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// DOT INDICATOR
// ─────────────────────────────────────────────────────────────

class _DotIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;
  const _DotIndicator({required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? colors.text1 : colors.border,
            borderRadius: BorderRadius.circular(_T.radiusFull),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CHIP
// ─────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color textColor;
  final Color borderColor;
  final IconData? icon;

  const _Chip({
    required this.label,
    required this.bg,
    required this.textColor,
    required this.borderColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _T.sp10,
        vertical: _T.sp4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(_T.radiusFull),
        border: Border.all(color: borderColor, width: .8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: textColor),
            const SizedBox(width: 3),
          ],
          Text(label, style: _T.chipLabel(textColor)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// QUANTITY STEPPER
// ─────────────────────────────────────────────────────────────

class _QuantityStepper extends StatelessWidget {
  final int qty;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityStepper({
    required this.qty,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(_T.radiusMd),
        border: Border.all(color: colors.border, width: .8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: qty > 1 ? onDecrement : null,
            child: SizedBox(
              width: 38,
              height: 38,
              child: Icon(
                Icons.remove_rounded,
                size: 15,
                color: qty > 1 ? colors.text1 : colors.border,
              ),
            ),
          ),
          Container(width: .8, height: 22, color: colors.border),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: SizedBox(
              key: ValueKey(qty),
              width: 34,
              child: Text(
                '$qty',
                textAlign: TextAlign.center,
                style: _T.qtyNum(colors.text1),
              ),
            ),
          ),
          Container(width: .8, height: 22, color: colors.border),
          GestureDetector(
            onTap: onIncrement,
            child: SizedBox(
              width: 38,
              height: 38,
              child: Icon(Icons.add_rounded, size: 15, color: colors.text1),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// WISHLIST BUTTON
// ─────────────────────────────────────────────────────────────

class _WishlistButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  const _WishlistButton({required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius: BorderRadius.circular(_T.radiusLg),
          border: Border.all(color: colors.border, width: .8),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            key: ValueKey(isFavorite),
            size: 20,
            color: isFavorite ? colors.flashText : colors.text2,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CART BUTTON
// ─────────────────────────────────────────────────────────────

class _CartButton extends StatelessWidget {
  final bool isInCart;
  final bool loading;
  final VoidCallback onTap;
  const _CartButton({
    required this.isInCart,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: GestureDetector(
        onTap: loading ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 50,
          decoration: BoxDecoration(
            color: loading ? colors.accentLight : colors.accent,
            borderRadius: BorderRadius.circular(_T.radiusLg),
          ),
          child: Center(
            child: loading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.accent,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isInCart
                            ? Icons.shopping_cart_checkout_rounded
                            : Icons.shopping_cart_outlined,
                        color: colors.surface,
                        size: 18,
                      ),
                      const SizedBox(width: _T.sp8),
                      Text(
                        isInCart ? 'update_cart'.tr : 'add_to_cart'.tr,
                        style: _T.ctaLabel(colors.surface),
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
// EXPANDABLE DESCRIPTION
// ─────────────────────────────────────────────────────────────

class _ExpandableDesc extends StatefulWidget {
  final String text;
  const _ExpandableDesc({required this.text});
  @override
  State<_ExpandableDesc> createState() => _ExpandableDescState();
}

class _ExpandableDescState extends State<_ExpandableDesc> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final long = widget.text.length > 130;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: Text(
            widget.text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: _T.bodyText(colors.text2),
          ),
          secondChild: Text(widget.text, style: _T.bodyText(colors.text2)),
        ),
        if (long) ...[
          const SizedBox(height: _T.sp4),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded ? 'show_less'.tr : 'read_more'.tr,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.accent,
              ),
            ),
          ),
        ],
      ],
    );
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

  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    productFuture = context.read<ProductDetailProvider>().getOrFetch(
      widget.productId,
    );
    _loadCartQty();
    _loadFavorite();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCartQty() async {
    try {
      final q = await ApiService().getCartQuantity(productId: widget.productId);
      if (mounted)
        setState(() {
          cartQty = q;
          qty = q > 0 ? q : 1;
          isInCart = q > 0;
        });
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
        context.read<CartProvider>().fetchCart();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isInCart ? 'cart_updated'.tr : 'added_to_cart'.tr),
            duration: const Duration(milliseconds: 900),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('something_went_wrong'.tr)));
      }
    } finally {
      if (mounted) setState(() => cartLoading = false);
    }
  }

  Future<void> _loadFavorite() async {
    final saved = await WishlistService().isFavorite(widget.productId);
    if (mounted) setState(() => isFavorite = saved);
  }

  Future<void> _toggleFavourite() async {
    HapticFeedback.lightImpact();
    final saved = await WishlistService().toggle(widget.productId);
    if (mounted) setState(() => isFavorite = saved);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mq = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: FutureBuilder(
        future: productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return const _DetailSkeleton();
          }
          if (snapshot.hasError) {
            return const SafeArea(child: _ErrorState());
          }

          final p = snapshot.data;
          final images = (p.images as List?) ?? [];
          final finalPrice = double.tryParse(p.finalPrice.toString()) ?? 0;
          final salePrice = double.tryParse(p.salePrice?.toString() ?? '') ?? 0;
          final hasDiscount = p.discount != null && salePrice > finalPrice;
          final discountPct = hasDiscount
              ? '-${(((salePrice - finalPrice) / salePrice) * 100).round()}%'
              : null;
          final stockQty = (p.quantity as int?) ?? 0;
          final inStock = stockQty > 0;

          return FadeTransition(
            opacity: _fade,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── SliverAppBar — image fills top, floats
                //    back & wishlist buttons over it ─────────
                SliverAppBar(
                  backgroundColor: Colors.white,
                  expandedHeight: mq.size.height * .44,
                  pinned: false,
                  floating: false,
                  automaticallyImplyLeading: false,
                  surfaceTintColor: Colors.transparent,

                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // ── images ──
                        if (images.isNotEmpty)
                          PageView.builder(
                            itemCount: images.length,
                            onPageChanged: (i) =>
                                setState(() => imageIndex = i),
                            itemBuilder: (_, i) => Container(
                              margin: const EdgeInsets.fromLTRB(24, 80, 24, 40),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: CachedNetworkImage(
                                  imageUrl: images[i] as String,
                                  fit: BoxFit.contain,
                                  errorWidget: (_, __, ___) => Icon(
                                    Icons.image_outlined,
                                    size: 56,
                                    color: colors.text3,
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 56,
                              color: colors.text3,
                            ),
                          ),

                        // ── back button (top-left) ──
                        Positioned(
                          top: mq.padding.top + _T.sp10,
                          left: _T.sp16,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: colors.cardBg.withOpacity(.88),
                                borderRadius: BorderRadius.circular(
                                  _T.radiusMd,
                                ),
                                border: Border.all(
                                  color: colors.border,
                                  width: .5,
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 14,
                                color: colors.text1,
                              ),
                            ),
                          ),
                        ),

                        // ── wishlist button (top-right) ──
                        Positioned(
                          top: mq.padding.top + _T.sp10,
                          right: _T.sp16,
                          child: GestureDetector(
                            onTap: _toggleFavourite,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: colors.cardBg.withOpacity(.88),
                                borderRadius: BorderRadius.circular(
                                  _T.radiusMd,
                                ),
                                border: Border.all(
                                  color: colors.border,
                                  width: .5,
                                ),
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                transitionBuilder: (c, a) =>
                                    ScaleTransition(scale: a, child: c),
                                child: Icon(
                                  isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  key: ValueKey(isFavorite),
                                  size: 16,
                                  color: isFavorite
                                      ? colors.flashText
                                      : colors.text2,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ── dot indicators (bottom-center) ──
                        if (images.length > 1)
                          Positioned(
                            bottom: _T.sp14,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: _DotIndicator(
                                count: images.length,
                                activeIndex: imageIndex,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ── Content ────────────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    color: colors.background,
                    padding: EdgeInsets.fromLTRB(
                      _T.sp16,
                      _T.sp16,
                      _T.sp16,
                      mq.padding.bottom + _T.sp24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Chips row ──────────────────────────────────
                        Wrap(
                          spacing: _T.sp6,
                          runSpacing: _T.sp6,
                          children: [
                            if ((p.categoryName as String?)?.isNotEmpty == true)
                              _Chip(
                                label: p.categoryName as String,
                                bg: colors.bginfo,
                                textColor: colors.text2,
                                borderColor: colors.border,
                                icon: Icons.sell_outlined,
                              ),
                            if ((p.brandName as String?)?.isNotEmpty == true)
                              _Chip(
                                label: (p.brandName as String).trCatalog,
                                bg: colors.bginfo,
                                textColor: colors.text2,
                                borderColor: colors.border,
                                icon: Icons.storefront_outlined,
                              ),
                            _Chip(
                              label: inStock
                                  ? '${'in_stock'.tr} · $stockQty'
                                  : 'out_of_stock'.tr,
                              bg: inStock ? colors.accentLight : colors.flashBg,
                              textColor: inStock
                                  ? colors.accent
                                  : colors.flashText,
                              borderColor: inStock
                                  ? colors.accent.withOpacity(.25)
                                  : colors.flashBorder,
                              icon: inStock
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.cancel_outlined,
                            ),
                          ],
                        ),

                        const SizedBox(height: _T.sp14),

                        // ── Name ───────────────────────────────────────
                        Text(
                          p.name as String,
                          style: _T.productName(colors.text1),
                        ),

                        const SizedBox(height: _T.sp10),

                        // ── Price ──────────────────────────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '\$${p.finalPrice}',
                              style: _T.priceMain(colors.text1),
                            ),
                            if (hasDiscount) ...[
                              const SizedBox(width: _T.sp8),
                              Text(
                                '\$${p.salePrice}',
                                style: _T.priceOld(colors.text3),
                              ),
                              const SizedBox(width: _T.sp8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: _T.sp8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.flashBg,
                                  borderRadius: BorderRadius.circular(
                                    _T.radiusFull,
                                  ),
                                  border: Border.all(
                                    color: colors.flashBorder,
                                    width: .5,
                                  ),
                                ),
                                child: Text(
                                  discountPct!,
                                  style: _T.discountTag(colors.flashText),
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: _T.sp20),

                        // ── Description ────────────────────────────────
                        Text(
                          'description'.tr,
                          style: _T.sectionLabel(colors.text3),
                        ),
                        const SizedBox(height: _T.sp6),
                        _ExpandableDesc(text: (p.description as String?) ?? ''),

                        const SizedBox(height: _T.sp20),
                        Divider(color: colors.border, height: 1, thickness: .5),
                        const SizedBox(height: _T.sp14),

                        // ── Quantity ───────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'quantity'.tr,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: colors.text1,
                              ),
                            ),
                            _QuantityStepper(
                              qty: qty,
                              onIncrement: () => setState(() => qty++),
                              onDecrement: () {
                                if (qty > 1) setState(() => qty--);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: _T.sp20),
                        Divider(color: colors.border, height: 1, thickness: .5),
                        const SizedBox(height: _T.sp14),

                        // ── CTA ────────────────────────────────────────
                        Row(
                          children: [
                            _WishlistButton(
                              isFavorite: isFavorite,
                              onTap: _toggleFavourite,
                            ),
                            const SizedBox(width: _T.sp10),
                            _CartButton(
                              isInCart: isInCart,
                              loading: cartLoading,

                              onTap: () => _handleCart(p),
                            ),
                          ],
                        ),
                      ],
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
