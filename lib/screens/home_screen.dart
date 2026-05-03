import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mart_frontend/screens/categories_screen.dart'
    hide ProductListScreen;
import 'package:mart_frontend/screens/theme/app_theme.dart';
import 'package:mart_frontend/widgets/product_by_category.dart';
import '../auth/login_register_screen.dart';
import '../models/bannersModel.dart';
import '../models/categoriesModel.dart';
import '../models/productsModel.dart';
import '../services/api_service.dart';
import '../widgets/categories_bottom_sheet.dart';
import '../widgets/floating_cart_bar.dart';
import '../widgets/product_detail_screen.dart';
import '../widgets/product_list_screen.dart';

// ─────────────────────────────────────────────
// SKELETON SHIMMER WIDGET
// ─────────────────────────────────────────────

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
  late AnimationController _ctrl;
  late Animation<double> _anim;

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
    final base = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8);
    final highlight = isDark
        ? const Color(0xFF3D3D3D)
        : const Color(0xFFF5F5F5);

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

// ─────────────────────────────────────────────
// SKELETON: BANNER
// ─────────────────────────────────────────────

class _BannerSkeleton extends StatelessWidget {
  const _BannerSkeleton();

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.shortestSide;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: s * .04),
      child: Column(
        children: [
          _Shimmer(
            width: double.infinity,
            height: s * .42,
            borderRadius: s * .045,
          ),
          SizedBox(height: s * .02),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (i) => Padding(
                padding: EdgeInsets.symmetric(horizontal: s * .008),
                child: _Shimmer(
                  width: i == 0 ? s * .045 : s * .015,
                  height: s * .015,
                  borderRadius: s * .015,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SKELETON: CATEGORY ROW
// ─────────────────────────────────────────────

class _CategoryRowSkeleton extends StatelessWidget {
  const _CategoryRowSkeleton();

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.shortestSide;
    final tileSize = s * 0.16;
    final spacing = s * 0.025;

    return SizedBox(
      height: tileSize + 25,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: s * .04),
        itemCount: 6,
        separatorBuilder: (_, __) => SizedBox(width: spacing),
        itemBuilder: (_, __) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Shimmer(width: tileSize, height: tileSize, borderRadius: 16),
            SizedBox(height: spacing * 0.5),
            _Shimmer(width: tileSize * 0.7, height: s * .025, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SKELETON: PRODUCT GRID (2 cards)
// ─────────────────────────────────────────────

class _ProductGridSkeleton extends StatelessWidget {
  const _ProductGridSkeleton();

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.shortestSide;
    final radius = s * .04;
    final imageHeight = s * .42;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: s * .035),
      child: Row(
        children: List.generate(
          2,
          (_) => Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: s * .015),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image placeholder
                    _Shimmer(
                      width: double.infinity,
                      height: imageHeight,
                      borderRadius: radius,
                    ),
                    SizedBox(height: s * .015),
                    // Title
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: s * .025),
                      child: _Shimmer(
                        width: double.infinity,
                        height: s * .032,
                        borderRadius: 4,
                      ),
                    ),
                    SizedBox(height: s * .01),
                    // Price row
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        s * .025,
                        0,
                        s * .025,
                        s * .025,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _Shimmer(
                            width: s * .1,
                            height: s * .03,
                            borderRadius: 4,
                          ),
                          _Shimmer(
                            width: s * .072,
                            height: s * .072,
                            borderRadius: s * .072,
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
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SKELETON: RECOMMENDED ROW
// ─────────────────────────────────────────────

class _RecommendedRowSkeleton extends StatelessWidget {
  const _RecommendedRowSkeleton();

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.shortestSide;
    final cardWidth = s * .30;
    final imageSize = cardWidth * .85;
    final radius = s * .04;

    return SizedBox(
      height: imageSize + s * .16,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: s * .04),
        itemCount: 5,
        separatorBuilder: (_, __) => SizedBox(width: s * .025),
        itemBuilder: (_, __) => Container(
          width: cardWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Shimmer(
                width: cardWidth,
                height: imageSize,
                borderRadius: radius,
              ),
              SizedBox(height: s * .01),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: s * .028),
                child: _Shimmer(
                  width: cardWidth * .7,
                  height: s * .03,
                  borderRadius: 4,
                ),
              ),
              SizedBox(height: s * .008),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: s * .028),
                child: _Shimmer(
                  width: cardWidth * .45,
                  height: s * .028,
                  borderRadius: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HOME SCREEN
// ─────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategory = 0;
  int _bannerIndex = 0;
  late Timer _flashTimer;
  int _flashSeconds = 2 * 3600 + 45 * 60 + 30;

  final _bannerController = PageController();
  late Future<List<BannersModel>> _bannersFuture;
  late Future<List<CategoriesModel>> _categoriesFuture;
  late Future<List<BestSellerModel>> _bestSellerFuture;
  late Future<List<NewArrivalsModel>> _newArrivalsFuture;
  late Future<List<RecommendedModel>> _recommendedFuture;

  @override
  void initState() {
    super.initState();
    _bannersFuture = ApiService().fetchBanners();
    _categoriesFuture = ApiService().fetchCategories();
    _bestSellerFuture = ApiService().fetchBestSellers();
    _newArrivalsFuture = ApiService().fetchNewArrivals();
    _recommendedFuture = ApiService().fetchRecommended();

    _flashTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      setState(() {
        _flashSeconds = _flashSeconds > 0 ? _flashSeconds - 1 : 3 * 3600;
      });
    });
  }

  @override
  void dispose() {
    _flashTimer.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _bannersFuture = ApiService().fetchBanners();
      _categoriesFuture = ApiService().fetchCategories();
      _bestSellerFuture = ApiService().fetchBestSellers();
      _newArrivalsFuture = ApiService().fetchNewArrivals();
      _recommendedFuture = ApiService().fetchRecommended();
    });

    await Future.wait([
      _bannersFuture,
      _categoriesFuture,
      _bestSellerFuture,
      _newArrivalsFuture,
      _recommendedFuture,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          slivers: [
            // ── Sticky Header + Search ──────────────────────────────
            SliverAppBar(
              pinned: true,
              floating: false,
              expandedHeight: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(30),
                child: _StickyHeader(colors: colors),
              ),
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // ── 2. Banner ───────────────────────────────────────
                  FutureBuilder<List<BannersModel>>(
                    future: _bannersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const _BannerSkeleton();
                      }

                      if (snapshot.hasError || !snapshot.hasData) {
                        return const _BannerSkeleton();
                      }

                      return _BannerSection(
                        controller: _bannerController,
                        currentIndex: _bannerIndex,
                        onPageChanged: (i) {
                          setState(() => _bannerIndex = i);
                        },
                        colors: colors,
                        banners: snapshot.data!,
                      );
                    },
                  ),

                  // ── 3. Categories ───────────────────────────────────
                  _SectionHeader(
                    title: 'Categories',
                    onTap: () {
                      openCategoryBottomSheet(context);
                    },
                    colors: colors,
                  ),
                  FutureBuilder<List<CategoriesModel>>(
                    future: _categoriesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const _CategoryRowSkeleton();
                      }

                      if (snapshot.hasError) {
                        return const _CategoryRowSkeleton();
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const _CategoryRowSkeleton();
                      }

                      return _CategoryRow(
                        selected: _selectedCategory,
                        categories: snapshot.data!,
                        colors: colors,
                        onSelect: (id, name) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryProductsScreen(
                                categoryId: id,
                                categoryName: name,
                               
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  // ── 4. Best Sellers ─────────────────────────────────
                  _SectionHeader(
                    title: '🔥 Best Sellers',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductListScreen(
                            title: "Best Sellers",
                            fetch: ApiService().fetchAllBestSellers,
                          ),
                        ),
                      );
                    },
                    colors: colors,
                  ),
                  FutureBuilder<List<BestSellerModel>>(
                    future: _bestSellerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const _ProductGridSkeleton();
                      }

                      if (snapshot.hasError) {
                        return const _ProductGridSkeleton();
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const _ProductGridSkeleton();
                      }

                      return _ProductGrid(
                        products: snapshot.data!,
                        tag: 'Best Seller',
                        tagColor: Colors.red,
                        colors: colors,
                      );
                    },
                  ),

                  // ── 5. New Arrivals ─────────────────────────────────
                  _SectionHeader(
                    title: '🆕 New Arrivals',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductListScreen(
                            title: "New Arrivals",
                            fetch: ApiService().fetchAllNewArrivals,
                          ),
                        ),
                      );
                    },
                    colors: colors,
                  ),
                  FutureBuilder<List<NewArrivalsModel>>(
                    future: _newArrivalsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const _ProductGridSkeleton();
                      }

                      if (snapshot.hasError) {
                        return const _ProductGridSkeleton();
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const _ProductGridSkeleton();
                      }

                      return _ProductGrid(
                        products: snapshot.data!,
                        tag: 'New Arrivals',
                        tagColor: Colors.blue,
                        colors: colors,
                      );
                    },
                  ),

                  // ── 6. Recommended ──────────────────────────────────
                  _SectionHeader(
                    title: 'for you',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductListScreen(
                            title: "Recommended",
                            fetch: ApiService().fetchAllRecommended,
                          ),
                        ),
                      );
                    },
                    colors: colors,
                  ),
                  FutureBuilder<List<RecommendedModel>>(
                    future: _recommendedFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const _RecommendedRowSkeleton();
                      }

                      if (snapshot.hasError) {
                        return const _RecommendedRowSkeleton();
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const _RecommendedRowSkeleton();
                      }

                      return _RecommendedRow(
                        products: snapshot.data!,
                        tag: 'Recommended',
                        tagColor: Colors.green,
                        colors: colors,
                      );
                    },
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height * .11),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 1. STICKY HEADER
// ─────────────────────────────────────────────
class _StickyHeader extends StatelessWidget {
  final AppColors colors;

  const _StickyHeader({required this.colors});

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.shortestSide;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.fromLTRB(s * .045, s * .025, s * .045, s * .028),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning 👋',
                  style: TextStyle(
                    fontSize: s * .048,
                    fontWeight: FontWeight.w700,
                    color: colors.text1,
                    height: 1.15,
                    letterSpacing: -.3,
                  ),
                ),

                SizedBox(height: s * .012),

                Text(
                  'Find what you love today',
                  style: TextStyle(
                    fontSize: s * .031,
                    fontWeight: FontWeight.w500,
                    color: colors.text2,
                  ),
                ),
              ],
            ),
          ),

          _HeaderActionButton(
            icon: 'lib/icons/search.png',
            colors: colors,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CategoriesScreen()),
              );
            },
          ),

          SizedBox(width: s * .025),

          _HeaderActionButton(
            icon: 'lib/icons/notification.png',
            colors: colors,
            showBadge: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final String icon;
  final AppColors colors;
  final bool showBadge;
  final VoidCallback onTap;

  const _HeaderActionButton({
    required this.icon,
    required this.colors,
    required this.onTap,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.shortestSide;
    final size = s * .105;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            padding: EdgeInsets.all(s * .024),
            decoration: BoxDecoration(
              color: colors.cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.border.withOpacity(.12)),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                  color: Colors.black.withOpacity(.04),
                ),
              ],
            ),
            child: Image.asset(icon, color: colors.text1),
          ),

          if (showBadge)
            Positioned(
              right: -1,
              top: -1,
              child: Container(
                width: s * .028,
                height: s * .028,
                decoration: BoxDecoration(
                  color: colors.flashText,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.cardBg, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
// ─────────────────────────────────────────────
// 2. BANNER
// ─────────────────────────────────────────────

class _BannerSection extends StatefulWidget {
  final PageController controller;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final AppColors colors;
  final List<BannersModel> banners;

  const _BannerSection({
    required this.controller,
    required this.currentIndex,
    required this.onPageChanged,
    required this.colors,
    required this.banners,
  });

  @override
  State<_BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends State<_BannerSection> {
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!widget.controller.hasClients || widget.banners.isEmpty) return;
      _page++;
      if (_page >= widget.banners.length) _page = 0;
      widget.controller.animateToPage(
        _page,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.shortestSide;
    final bannerHeight = s * .42;

    return Column(
      children: [
        SizedBox(
          height: bannerHeight,
          child: PageView.builder(
            controller: widget.controller,
            itemCount: widget.banners.length,
            onPageChanged: (index) {
              _page = index;
              widget.onPageChanged(index);
            },
            itemBuilder: (_, i) => Padding(
              padding: EdgeInsets.symmetric(horizontal: s * .04),
              child: _BannerCard(banner: widget.banners[i]),
            ),
          ),
        ),
        SizedBox(height: s * .02),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.banners.length, (i) {
            final on = i == widget.currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.symmetric(horizontal: s * .008),
              width: on ? s * .045 : s * .015,
              height: s * .015,
              decoration: BoxDecoration(
                color: on ? widget.colors.accent : widget.colors.border,
                borderRadius: BorderRadius.circular(s * .015),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final BannersModel banner;
  const _BannerCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.shortestSide;
    final radius = s * .045;

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              banner.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(color: Colors.grey.shade200);
              },
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade300,
                child: Icon(Icons.broken_image, size: s * .12),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),
          Positioned(
            left: s * .05,
            bottom: s * .05,
            child: SizedBox(width: s * .55),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final AppColors colors;

  const _SectionHeader({required this.title, this.onTap, required this.colors});

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.shortestSide;
    return Padding(
      padding: EdgeInsets.fromLTRB(s * 0.04, s * 0.04, s * 0.04, s * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: s * 0.040,
                fontWeight: FontWeight.w700,
                color: colors.text1,
              ),
            ),
          ),
          if (onTap != null) ...[
            SizedBox(width: s * 0.02),
            GestureDetector(
              onTap: onTap,
              child: Text(
                'See All',
                style: TextStyle(
                  fontSize: s * 0.030,
                  color: colors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 3. CATEGORIES
// ─────────────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  final int selected;
  final Function(int, String) onSelect;
  final AppColors colors;
  final List<CategoriesModel> categories;

  const _CategoryRow({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.colors,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final shortest = screen.shortestSide;
    final tileSize = shortest * 0.16;
    final textSize = shortest * 0.03;
    final spacing = shortest * 0.025;
    final horizontalPadding = shortest * 0.04;

    return SizedBox(
      height: tileSize + 25,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: spacing),
        itemBuilder: (_, i) {
          return GestureDetector(
            onTap: () => onSelect(categories[i].id, categories[i].name),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: tileSize,
                  height: tileSize,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      categories[i].image,
                      fit: BoxFit.cover,
                      width: 64,
                      height: 64,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(
                          Icons.category_outlined,
                          size: 28,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: spacing * 0.5),
                Text(
                  categories[i].name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: FontWeight.w500,
                    color: colors.text2,
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

// ─────────────────────────────────────────────
// 4 & 5. PRODUCT GRID
// ─────────────────────────────────────────────

class _ProductGrid extends StatelessWidget {
  final List<dynamic> products;
  final String tag;
  final Color tagColor;
  final AppColors colors;

  const _ProductGrid({
    super.key,
    required this.products,
    required this.tag,
    required this.tagColor,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.shortestSide;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: s * .035),
      child: Row(
        children: products.take(2).map((p) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: s * .030),
              child: _ProductCard(
                product: p,
                tag: tag,
                tagColor: tagColor,
                colors: colors,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(productId: p.id),
                    ),
                  );
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final dynamic product;
  final String tag;
  final Color tagColor;
  final AppColors colors;
  final VoidCallback onTap;

  const _ProductCard({
    super.key,
    required this.product,
    required this.tag,
    required this.tagColor,
    required this.colors,
    required this.onTap,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  int _qty = 0;

  @override
  void initState() {
    super.initState();
    _loadCartQty();
  }

  // ── Load existing cart quantity on init ──────────────────────
  Future<void> _loadCartQty() async {
    try {
      final qty = await ApiService().getCartQuantity(
        productId: widget.product.id,
      );
      if (mounted) setState(() => _qty = qty);
    } catch (_) {
      // silently ignore — default stays 0
    }
  }

  // ── Unified cart updater with optimistic UI + rollback ───────
  Future<void> _setQty(int newQty) async {
    final prev = _qty;
    setState(() {
      _qty = newQty < 0 ? 0 : newQty;
    });

    try {
      if (newQty <= 0) {
        // Remove from cart entirely
        await ApiService().removeCart(widget.product.id);
        if (mounted) setState(() => _qty = 0);
      } else {
        await ApiService().updateCart(
          productId: widget.product.id,
          quantity: newQty,
        );
      }
    } catch (e) {
      // Rollback on failure
      if (mounted) {
        setState(() => _qty = prev);
        ScaffoldMessenger.of(context).clearSnackBars();
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Failed to update cart. Try again.')),
        // );
      }
    } finally {}
  }

  // ── First "add" tap — checks login first ────────────────────

  Future<void> _handleAddTap() async {
    final loggedIn = await ApiService().isLoggedIn();

    if (!loggedIn) {
      showAuthBottomSheet(context);
      return;
    }

    final oldQty = _qty;

    setState(() {
      _qty = 1;
    });

    try {
      await ApiService().addToCart(productId: widget.product.id, quantity: 1);

      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text("Added to cart")));
    } catch (e) {
      // rollback
      if (mounted) {
        setState(() {
          _qty = oldQty;
        });
      }

      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(const SnackBar(content: Text("Failed add cart")));
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final shortest = MediaQuery.of(context).size.shortestSide;
    final radius = shortest * .025;
    final imageHeight = shortest * .35;
    final titleSize = shortest * .031;
    final smallText = shortest * .026;
    final priceSize = shortest * .033;

    final imageUrl = widget.product.images.isNotEmpty
        ? widget.product.images.first
        : null;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: widget.colors.cardBg,
          borderRadius: BorderRadius.circular(radius),
          // border: Border.all(color: widget.colors.border, width: .5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Product Image ──────────────────────────────────
            Stack(
              children: [
                Container(
                  height: imageHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: widget.colors.surface2,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(radius),
                    ),
                  ),
                  child: imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(radius),
                          ),
                          child: Image.network(imageUrl, fit: BoxFit.cover),
                        )
                      : Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: shortest * .1,
                          ),
                        ),
                ),
                if (widget.product.discount != null)
                  Positioned(
                    top: shortest * .03,
                    left: shortest * .03,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: shortest * .015,
                        vertical: shortest * .006,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "-${double.parse(widget.product.discount!.replaceAll('%', '')).toInt()}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // ── Product Info + Cart Controls ───────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(shortest * .025),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(radius),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: shortest * .005),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // ── Price ────────────────────────────────
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: smallText * 1.4,
                              child: widget.product.discount != null
                                  ? Text(
                                      "\$${widget.product.salePrice}",
                                      style: TextStyle(
                                        fontSize: smallText,
                                        decoration: TextDecoration.lineThrough,
                                        color: widget.colors.text3,
                                      ),
                                    )
                                  : null,
                            ),
                            Text(
                              "\$${widget.product.finalPrice}",
                              style: TextStyle(
                                fontSize: priceSize,
                                fontWeight: FontWeight.w700,
                                color: widget.colors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: shortest * .02),

                      // ── Cart Stepper ─────────────────────────
                      _CartStepper(
                        qty: _qty,
                        loading: false,
                        s: shortest,
                        colors: widget.colors,
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
    );
  }
}

// ─────────────────────────────────────────────
// CART STEPPER WIDGET
// ─────────────────────────────────────────────

class _CartStepper extends StatelessWidget {
  final int qty;
  final bool loading;
  final double s;
  final AppColors colors;
  final Future<void> Function() onAdd; // ✅ was VoidCallback
  final Future<void> Function() onIncrement; // ✅ was VoidCallback
  final Future<void> Function() onDecrement; // ✅ was VoidCallback

  const _CartStepper({
    required this.qty,
    required this.loading,
    required this.s,
    required this.colors,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final btnSize = s * .072;

    if (loading) {
      return SizedBox(
        width: btnSize,
        height: btnSize,
        child: Padding(
          padding: EdgeInsets.all(s * .012),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colors.accent,
          ),
        ),
      );
    }

    if (qty == 0) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onAdd, // ✅ Future<void> Function() is directly usable as onTap
        child: Container(
          width: btnSize,
          height: btnSize,
          decoration: BoxDecoration(
            color: colors.accent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors.accent.withOpacity(.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 18),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      height: btnSize,
      decoration: BoxDecoration(
        color: colors.accent,
        borderRadius: BorderRadius.circular(btnSize / 2),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withOpacity(.30),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDecrement, // ✅
            child: SizedBox(
              width: btnSize,
              height: btnSize,
              child: const Icon(Icons.remove, color: Colors.white, size: 16),
            ),
          ),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: SizedBox(
              key: ValueKey(qty),
              width: s * .048,
              child: Text(
                "$qty",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: s * .033,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onIncrement, // ✅
            child: SizedBox(
              width: btnSize,
              height: btnSize,
              child: const Icon(Icons.add, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 7. RECOMMENDED
// ─────────────────────────────────────────────

class _RecommendedRow extends StatefulWidget {
  final AppColors colors;
  final List<RecommendedModel> products;
  final String tag;
  final Color tagColor;

  const _RecommendedRow({
    super.key,
    required this.colors,
    required this.products,
    required this.tag,
    required this.tagColor,
  });

  @override
  State<_RecommendedRow> createState() => _RecommendedRowState();
}

class _RecommendedRowState extends State<_RecommendedRow> {
  final Map<int, bool> _favs = {};

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.shortestSide;
    final cardWidth = s * .30;
    final imageSize = cardWidth * .85;
    final radius = s * .025;

    return SizedBox(
      height: imageSize + s * .16,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: s * .04),
        itemCount: widget.products.length,
        separatorBuilder: (_, __) => SizedBox(width: s * .025),
        itemBuilder: (_, i) {
          final item = widget.products[i];
          final imageUrl = item.images.isNotEmpty ? item.images.first : null;
          _favs.putIfAbsent(i, () => false);

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(productId: item.id),
                ),
              );
            },
            child: Container(
              width: cardWidth,
              decoration: BoxDecoration(
                color: widget.colors.cardBg,
                borderRadius: BorderRadius.circular(radius),
                // border: Border.all(color: widget.colors.border, width: .5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(radius),
                        ),
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl,
                                width: double.infinity,
                                height: imageSize,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => SizedBox(
                                  height: imageSize,
                                  child: const Center(child: Icon(Icons.image)),
                                ),
                              )
                            : SizedBox(
                                height: imageSize,
                                child: const Center(child: Icon(Icons.image)),
                              ),
                      ),
                      if (item.discount != null)
                        Positioned(
                          top: s * .02,
                          left: s * .02,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: s * .018,
                              vertical: s * .005,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              item.discount!,
                              style: TextStyle(
                                fontSize: s * .022,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: s * .01,
                        right: s * .01,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _favs[i] = !(_favs[i] ?? false);
                            });
                          },
                          // child: SizedBox(
                          //   width: s * .076,
                          //   height: s * .076,
                          //   child: Icon(
                          //     _favs[i] == true
                          //         ? Icons.favorite
                          //         : Icons.favorite_border,
                          //     color: _favs[i] == true
                          //         ? Colors.red
                          //         : widget.colors.text1,
                          //   ),
                          // ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(
                        s * .028,
                        s * .022,
                        s * .028,
                        s * .024,
                      ),
                      decoration: BoxDecoration(
                        // color: widget.colors.bginfo,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(radius),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: s * .034,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: s * .006),
                          Row(
                            children: [
                              Text(
                                "\$${item.finalPrice}",
                                style: TextStyle(
                                  fontSize: s * .036,
                                  fontWeight: FontWeight.w700,
                                  color: widget.colors.accent,
                                ),
                              ),
                              const Spacer(),
                              if (item.discount != null)
                                Text(
                                  "\$${item.salePrice}",
                                  style: TextStyle(
                                    fontSize: s * .031,
                                    decoration: TextDecoration.lineThrough,
                                    color: widget.colors.text3,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
