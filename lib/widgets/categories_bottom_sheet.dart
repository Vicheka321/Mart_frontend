import 'package:flutter/material.dart';
import 'package:mart_frontend/widgets/product_by_category_brand.dart';
import '../models/categoriesModel.dart';
import '../services/api_service.dart';
import '../screens/theme/app_theme.dart';

////////////////////////////////////////////////////////////
/// OPEN FUNCTION
////////////////////////////////////////////////////////////
void openCategoryBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const CategoryBottomSheet(),
  );
}

////////////////////////////////////////////////////////////
/// MAIN BOTTOM SHEET
////////////////////////////////////////////////////////////
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
    final size = MediaQuery.of(context).size;
    final s = size.shortestSide;

    /// 🔥 RESPONSIVE GRID COUNT
    final crossAxisCount = size.width > 600 ? 3 : 2;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      height: size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HANDLE
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),

          /// HEADER
          Padding(
            padding: EdgeInsets.fromLTRB(s * 0.05, 0, s * 0.03, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Categories",
                  style: TextStyle(
                    fontSize: s * 0.052,
                    fontWeight: FontWeight.w700,
                    color: colors.text1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Browse all departments",
                  style: TextStyle(fontSize: s * 0.032, color: colors.text3),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// GRID
          Expanded(
            child: FutureBuilder<List<CategoriesModel>>(
              future: _future,
              builder: (context, snapshot) {
                /// 🔥 SKELETON LOADING
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _SkeletonGrid(crossAxisCount: crossAxisCount);
                }

                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                final categories = snapshot.data ?? [];

                return GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: s * 0.04),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: s * 0.03,
                    mainAxisSpacing: s * 0.03,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return _CategoryCard(category: categories[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// CATEGORY CARD
////////////////////////////////////////////////////////////
class _CategoryCard extends StatelessWidget {
  final CategoriesModel category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = MediaQuery.of(context).size.shortestSide;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryProductsScreen(
              categoryId: category.id,
              categoryName: category.name,
              colors: colors,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            /// IMAGE
            Positioned.fill(
              child: Image.network(category.image, fit: BoxFit.cover),
            ),

            /// GRADIENT
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
              ),
            ),

            /// TEXT
            Positioned(
              left: s * 0.03,
              right: s * 0.03,
              bottom: s * 0.03,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: s * 0.038,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "Shop now",
                        style: TextStyle(
                          fontSize: s * 0.028,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(width: s * 0.01),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: s * 0.028,
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

////////////////////////////////////////////////////////////
/// SKELETON GRID
////////////////////////////////////////////////////////////
class _SkeletonGrid extends StatelessWidget {
  final int crossAxisCount;
  const _SkeletonGrid({required this.crossAxisCount});

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.shortestSide;

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: s * 0.04),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: s * 0.03,
        mainAxisSpacing: s * 0.03,
        childAspectRatio: 0.95,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const _SkeletonCard(),
    );
  }
}

////////////////////////////////////////////////////////////
/// SKELETON CARD (SHIMMER)
////////////////////////////////////////////////////////////
class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final color = Color.lerp(
          colors.surface2,
          colors.surface,
          _controller.value,
        )!;

        return Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}
