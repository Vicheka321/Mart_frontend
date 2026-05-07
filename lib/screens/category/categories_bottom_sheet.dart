// import 'package:flutter/material.dart';
// import 'package:mart_frontend/screens/category/product_by_category.dart';
// import '../../models/categories_model.dart';
// import '../../services/api_service.dart';
// import '../theme/app_theme.dart';

// ////////////////////////////////////////////////////////////
// /// OPEN FUNCTION
// ////////////////////////////////////////////////////////////
// void openCategoryBottomSheet(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (_) => const CategoryBottomSheet(),
//   );
// }

// ////////////////////////////////////////////////////////////
// /// MAIN BOTTOM SHEET
// ////////////////////////////////////////////////////////////
// class CategoryBottomSheet extends StatefulWidget {
//   const CategoryBottomSheet({super.key});

//   @override
//   State<CategoryBottomSheet> createState() => _CategoryBottomSheetState();
// }

// class _CategoryBottomSheetState extends State<CategoryBottomSheet> {
//   late Future<List<CategoriesModel>> _future;

//   @override
//   void initState() {
//     super.initState();
//     _future = ApiService().fetchCategories();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final size = MediaQuery.of(context).size;
//     final s = size.shortestSide;

//     /// 🔥 RESPONSIVE GRID COUNT
//     final crossAxisCount = size.width > 600 ? 3 : 2;

//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       height: size.height * 0.7,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// HANDLE
//           Center(
//             child: Container(
//               margin: const EdgeInsets.symmetric(vertical: 8),
//               width: 36,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(99),
//               ),
//             ),
//           ),

//           /// HEADER
//           Padding(
//             padding: EdgeInsets.fromLTRB(s * 0.05, 0, s * 0.03, 0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Categories",
//                   style: TextStyle(
//                     fontSize: s * 0.052,
//                     fontWeight: FontWeight.w700,
//                     color: colors.text1,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   "Browse all departments",
//                   style: TextStyle(fontSize: s * 0.032, color: colors.text3),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 16),

//           /// GRID
//           Expanded(
//             child: FutureBuilder<List<CategoriesModel>>(
//               future: _future,
//               builder: (context, snapshot) {
//                 /// 🔥 SKELETON LOADING
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return _SkeletonGrid(crossAxisCount: crossAxisCount);
//                 }

//                 if (snapshot.hasError) {
//                   return Center(child: Text(snapshot.error.toString()));
//                 }

//                 final categories = snapshot.data ?? [];

//                 return GridView.builder(
//                   padding: EdgeInsets.symmetric(horizontal: s * 0.04),
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: crossAxisCount,
//                     crossAxisSpacing: s * 0.03,
//                     mainAxisSpacing: s * 0.03,
//                     childAspectRatio: 0.95,
//                   ),
//                   itemCount: categories.length,
//                   itemBuilder: (context, index) {
//                     return _CategoryCard(category: categories[index]);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// ////////////////////////////////////////////////////////////
// /// CATEGORY CARD
// ////////////////////////////////////////////////////////////
// class _CategoryCard extends StatelessWidget {
//   final CategoriesModel category;
//   const _CategoryCard({required this.category});

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final s = MediaQuery.of(context).size.shortestSide;

//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => CategoryProductsScreen(
//               categoryId: category.id,
//               categoryName: category.name,

//             ),
//           ),
//         );
//       },
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: Stack(
//           children: [
//             /// IMAGE
//             Positioned.fill(
//               child: Image.network(category.image, fit: BoxFit.cover),
//             ),

//             /// GRADIENT
//             Positioned.fill(
//               child: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.bottomCenter,
//                     end: Alignment.topCenter,
//                     colors: [Colors.black.withOpacity(0.7), Colors.transparent],
//                   ),
//                 ),
//               ),
//             ),

//             /// TEXT
//             Positioned(
//               left: s * 0.03,
//               right: s * 0.03,
//               bottom: s * 0.03,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     category.name,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontSize: s * 0.038,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Text(
//                         "Shop now",
//                         style: TextStyle(
//                           fontSize: s * 0.028,
//                           color: Colors.white70,
//                         ),
//                       ),
//                       SizedBox(width: s * 0.01),
//                       Icon(
//                         Icons.arrow_forward_rounded,
//                         size: s * 0.028,
//                         color: Colors.white70,
//                       ),
//                     ],
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

// ////////////////////////////////////////////////////////////
// /// SKELETON GRID
// ////////////////////////////////////////////////////////////
// class _SkeletonGrid extends StatelessWidget {
//   final int crossAxisCount;
//   const _SkeletonGrid({required this.crossAxisCount});

//   @override
//   Widget build(BuildContext context) {
//     final s = MediaQuery.of(context).size.shortestSide;

//     return GridView.builder(
//       padding: EdgeInsets.symmetric(horizontal: s * 0.04),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: crossAxisCount,
//         crossAxisSpacing: s * 0.03,
//         mainAxisSpacing: s * 0.03,
//         childAspectRatio: 0.95,
//       ),
//       itemCount: 6,
//       itemBuilder: (_, __) => const _SkeletonCard(),
//     );
//   }
// }

// ////////////////////////////////////////////////////////////
// /// SKELETON CARD (SHIMMER)
// ////////////////////////////////////////////////////////////
// class _SkeletonCard extends StatefulWidget {
//   const _SkeletonCard();

//   @override
//   State<_SkeletonCard> createState() => _SkeletonCardState();
// }

// class _SkeletonCardState extends State<_SkeletonCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1000),
//     )..repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;

//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (_, __) {
//         final color = Color.lerp(
//           colors.surface2,
//           colors.surface,
//           _controller.value,
//         )!;

//         return Container(
//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(16),
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:mart_frontend/screens/category/product_by_category.dart';
import '../../models/categories_model.dart';
import '../../services/api_service.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────
// DESIGN TOKENS  — identical contract to all previous screens
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

  static TextStyle label(Color c) => TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: c,
    letterSpacing: .3,
  );
}

// ─────────────────────────────────────────────────────────────
// SHIMMER PRIMITIVE  (shared across all screens)
// ─────────────────────────────────────────────────────────────

class _Shimmer extends StatefulWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const _Shimmer({this.width, this.height, this.borderRadius = 8});

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
// SKELETON GRID
// Mirrors the real grid layout — same count, spacing, aspect
// ─────────────────────────────────────────────────────────────

class _SkeletonGrid extends StatelessWidget {
  final int crossAxisCount;

  const _SkeletonGrid({required this.crossAxisCount});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(_T.sp16, _T.sp4, _T.sp16, _T.sp32),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: _T.sp12,
        mainAxisSpacing: _T.sp12,
        childAspectRatio: .9,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const _SkeletonCategoryCard(),
    );
  }
}

// Skeleton card — matches _CategoryCard structure exactly
class _SkeletonCategoryCard extends StatelessWidget {
  const _SkeletonCategoryCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(_T.radiusLg),
        border: Border.all(color: colors.border, width: .8),
        boxShadow: _T.shadowSm(Colors.black),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // image shimmer fills card
          Positioned.fill(child: _Shimmer(borderRadius: _T.radiusLg)),

          // bottom text strip
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(_T.sp12),
              decoration: BoxDecoration(
                color: colors.cardBg,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(_T.radiusLg),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _Shimmer(width: double.infinity, height: 12, borderRadius: 4),
                  SizedBox(height: _T.sp6),
                  _Shimmer(width: 60, height: 10, borderRadius: 4),
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
// CATEGORY CARD
// ─────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final CategoriesModel category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryProductsScreen(
            categoryId: category.id,
            categoryName: category.name,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius: BorderRadius.circular(_T.radiusLg),
          border: Border.all(color: colors.border, width: .8),
          boxShadow: _T.shadowSm(Colors.black),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // ── Full-bleed image ─────────────────────────────
            Positioned.fill(
              child: Image.network(
                category.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: colors.surface2,
                  child: Icon(
                    Icons.category_outlined,
                    size: 36,
                    color: colors.text3,
                  ),
                ),
              ),
            ),

            // ── Bottom gradient scrim ────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 80,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(.72), Colors.transparent],
                  ),
                ),
              ),
            ),

            // ── Name + cta ───────────────────────────────────
            Positioned(
              left: _T.sp12,
              right: _T.sp12,
              bottom: _T.sp12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _T.bodyMd(Colors.white),
                  ),
                  const SizedBox(height: _T.sp4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Shop now', style: _T.bodySm(Colors.white70)),
                      const SizedBox(width: _T.sp4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 11,
                        color: Colors.white70,
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
}

// ─────────────────────────────────────────────────────────────
// ERROR STATE  (matches list & detail screens)
// ─────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
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
          const SizedBox(height: _T.sp12),
          Text('Could not load categories', style: _T.bodyMd(colors.text2)),
          const SizedBox(height: _T.sp4),
          Text(
            message,
            style: _T.bodySm(colors.text3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// OPEN FUNCTION
// ─────────────────────────────────────────────────────────────

void openCategoryBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const CategoryBottomSheet(),
  );
}

// ─────────────────────────────────────────────────────────────
// CATEGORY BOTTOM SHEET
// ─────────────────────────────────────────────────────────────

class CategoryBottomSheet extends StatefulWidget {
  const CategoryBottomSheet({super.key});

  @override
  State<CategoryBottomSheet> createState() => _CategoryBottomSheetState();
}

class _CategoryBottomSheetState extends State<CategoryBottomSheet> {
  late Future<List<CategoriesModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService().fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mq = MediaQuery.of(context);
    final size = mq.size;

    // ── Responsive column count ─────────────────────────────
    final crossAxisCount = size.width > 600 ? 3 : 2;

    return Container(
      height: size.height * .76,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(_T.radiusXl),
        ),
        // subtle top shadow to lift sheet off content below
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Drag handle ───────────────────────────────────
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: _T.sp12, bottom: _T.sp8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(_T.radiusFull),
              ),
            ),
          ),

          // ── Header ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              _T.sp20,
              _T.sp8,
              _T.sp20,
              _T.sp4,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Categories', style: _T.heading1(colors.text1)),
                      const SizedBox(height: _T.sp4),
                      Text(
                        'Browse all departments',
                        style: _T.bodySm(colors.text3),
                      ),
                    ],
                  ),
                ),

                // close button — same style as _IconButton in home
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colors.surface2,
                      borderRadius: BorderRadius.circular(_T.radiusMd),
                      border: Border.all(color: colors.border, width: .8),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: colors.text2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: _T.sp16),

          // thin divider — same _Divider pattern as detail screen
          Divider(
            color: colors.border,
            height: 1,
            thickness: .8,
            indent: _T.sp20,
            endIndent: _T.sp20,
          ),

          const SizedBox(height: _T.sp4),

          // ── Grid ─────────────────────────────────────────
          Expanded(
            child: FutureBuilder<List<CategoriesModel>>(
              future: _future,
              builder: (context, snapshot) {
                // Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _SkeletonGrid(crossAxisCount: crossAxisCount);
                }

                // Error
                if (snapshot.hasError) {
                  return _ErrorState(message: snapshot.error.toString());
                }

                final categories = snapshot.data ?? [];

                // Empty
                if (categories.isEmpty) {
                  return Center(
                    child: Text(
                      'No categories available',
                      style: _T.bodyMd(colors.text3),
                    ),
                  );
                }

                // Grid
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    _T.sp16,
                    _T.sp12,
                    _T.sp16,
                    _T.sp32,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: _T.sp12,
                    mainAxisSpacing: _T.sp12,
                    childAspectRatio: .9,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (_, i) => _CategoryCard(category: categories[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
