import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mart_frontend/auth/login_screen.dart';
import 'package:mart_frontend/models/brands_model.dart';
import 'package:mart_frontend/providers/ProductDetailProvider.dart';
import 'package:mart_frontend/providers/banner_provider.dart';
import 'package:mart_frontend/providers/best_seller_provider.dart';
import 'package:mart_frontend/providers/brands_provider.dart';
import 'package:mart_frontend/providers/category_provider.dart';
import 'package:mart_frontend/providers/new_arrival_provider.dart';
import 'package:mart_frontend/providers/profile_provider.dart';
import 'package:mart_frontend/providers/recommend_provider.dart';
import 'package:mart_frontend/screens/category/categories_screen.dart'
    hide ProductListScreen;
import 'package:mart_frontend/screens/search/search_screen.dart';
import 'package:mart_frontend/screens/theme/app_theme.dart';
import 'package:mart_frontend/screens/category/product_by_category.dart';
import '../../models/banners_model.dart';
import '../../models/categories_model.dart';
import '../../models/products_model.dart';
import '../../models/profile_model.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../category/categories_bottom_sheet.dart';
import '../cart/floating_cart_bar.dart';
import '../product/product_detail_screen.dart';
import '../product/product_list_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategory = 0;
  int _bannerIndex = 0;
  late Timer _flashTimer;

  final _bannerController = PageController();

  late Future<MyProfileModel> _profileFuture;
  late Future<List<BannersModel>> _bannersFuture;
  late Future<List<CategoriesModel>> _categoriesFuture;
  late Future<List<BestSellerModel>> _bestSellerFuture;
  late Future<List<NewArrivalsModel>> _newArrivalsFuture;
  late Future<List<RecommendedModel>> _recommendedFuture;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<CartProvider>().fetchCart();
      await context.read<ProfileProvider>().fetchProfile();

      final bannerProvider = context.read<BannerProvider>();
      final categoryProvider = context.read<CategoryProvider>();
      final bestSellerProvider = context.read<BestSellerProvider>();
      final newArrivalProvider = context.read<NewArrivalsProvider>();
      final brandsProvider = context.read<BrandsProvider>();
      final recommendProvider = context.read<RecommendProvider>();
      final detailProvider = context.read<ProductDetailProvider>();
      unawaited(
        Future.wait([
          bannerProvider.fetchBanners(),
          categoryProvider.fetchCategories(),
          bestSellerProvider.fetchBestSellers(),
          newArrivalProvider.fetchNewArrivals(),
          brandsProvider.fetchBrands(),
          recommendProvider.fetchRecommended(),
        ]),
      );

      // preload product detail
      unawaited(
        Future.wait([
          ...bestSellerProvider.products
              .take(10)
              .map((e) => detailProvider.preload(e.id)),
          ...newArrivalProvider.products
              .take(10)
              .map((e) => detailProvider.preload(e.id)),
          ...recommendProvider.recommended
              .take(10)
              .map((e) => detailProvider.preload(e.id)),
        ]),
      );
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _profileFuture = ApiService().fetchMyProfile();
      _bannersFuture = ApiService().fetchBanners();
      _categoriesFuture = ApiService().fetchCategories();
      _bestSellerFuture = ApiService().fetchBestSellers();
      _newArrivalsFuture = ApiService().fetchNewArrivals();
      _recommendedFuture = ApiService().fetchRecommended();
    });
    await Future.wait([
      _profileFuture,
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
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          RefreshIndicator(
            color: colors.accent,
            backgroundColor: colors.background,
            onRefresh: _refresh,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: false,
                  floating: true,
                  snap: false,

                  elevation: 0,

                  backgroundColor: colors.accent,
                  surfaceTintColor: Colors.transparent,

                  // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  expandedHeight: 0,
                  toolbarHeight: 0,

                  automaticallyImplyLeading: false,

                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(150),

                    child: Consumer<ProfileProvider>(
                      builder: (context, provider, child) {
                        if (provider.profile != null) {
                          return _buildStickyHeader(
                            colors,
                            provider.profile!,
                            context,
                          );
                        }

                        return _buildStickyHeaderSkeleton(colors);
                      },
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AppSectionHeader(
                        title: 'special_offers'.tr,
                        colors: colors,
                      ),
                      const SizedBox(height: _T.sp8),
                      Consumer<BannerProvider>(
                        builder: (context, provider, child) {
                          if (provider.banners.isNotEmpty) {
                            return _BannerSection(
                              controller: _bannerController,
                              currentIndex: _bannerIndex,
                              onPageChanged: (i) {
                                setState(() {
                                  _bannerIndex = i;
                                });
                              },
                              colors: colors,
                              banners: provider.banners,
                            );
                          }

                          return _buildBannerSkeleton(context);
                        },
                      ),

                      // ── Categories ──────────────────────────────────
                      _AppSectionHeader(
                        title: 'categories'.tr,
                        // onTap: () => openCategoryBottomSheet(context),
                        colors: colors,
                      ),

                      Consumer<CategoryProvider>(
                        builder: (context, provider, child) {
                          if (provider.categories.isNotEmpty) {
                            return _buildCategoryRow(
                              categories: provider.categories,
                              colors: colors,
                              onSelect: (id, name) {
                                setState(() {
                                  _selectedCategory = id;
                                });

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CategoryBrandScreen(
                                      initialCategoryId: id,
                                    ),
                                  ),
                                );
                              },
                            );
                          }

                          return _buildCategoryRowSkeleton(colors);
                        },
                      ),

                      // ── Best Sellers ────────────────────────────────
                      _AppSectionHeader(
                        title: 'best_sellers'.tr,
                        // onTap: () => Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (_) => ProductListScreen(
                        //       title: 'best_sellers'.tr,
                        //       fetch: ApiService().fetchAllBestSellers,
                        //     ),
                        //   ),
                        // ),
                        colors: colors,
                      ),
                      Consumer<BestSellerProvider>(
                        builder: (context, provider, child) {
                          if (provider.products.isNotEmpty) {
                            return _ProductGrid(
                              products: provider.products,
                              tag: 'best_seller'.tr,
                              tagColor: Colors.red,
                              colors: colors,
                            );
                          }

                          return _buildProductGridSkeleton(context);
                        },
                      ),

                      _AppSectionHeader(
                        title: 'new_arrivals'.tr,
                        // onTap: () => Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (_) => ProductListScreen(
                        //       title: 'new_arrivals'.tr,
                        //       fetch: ApiService().fetchAllNewArrivals,
                        //     ),
                        //   ),
                        // ),
                        colors: colors,
                      ),
                      Consumer<NewArrivalsProvider>(
                        builder: (context, provider, child) {
                          if (provider.products.isNotEmpty) {
                            return _ProductGrid(
                              products: provider.products,
                              tag: 'new_arrival'.tr,
                              tagColor: colors.accent,
                              colors: colors,
                            );
                          }

                          return _buildProductGridSkeleton(context);
                        },
                      ),

                      // _AppSectionHeader(
                      //   title: 'Shop by Brands',
                      //   colors: colors,
                      // ),
                      // Consumer<BrandsProvider>(
                      //   builder: (context, provider, child) {
                      //     if (provider.brands.isNotEmpty) {
                      //       return buildBrandsSection(
                      //         brands: provider.brands,
                      //         colors: colors,
                      //       );
                      //     }

                      //     return const Center(
                      //       child: CircularProgressIndicator(),
                      //     );
                      //   },
                      // ),

                      // ── New Arrivals ────────────────────────────────

                      // ── Recommended ─────────────────────────────────
                      _AppSectionHeader(
                        title: '✨ ${'for_you'.tr}',
                        // onTap: () => Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (_) => ProductListScreen(
                        //       title: 'recommended'.tr,
                        //       fetch: ApiService().fetchAllRecommended,
                        //     ),
                        //   ),
                        // ),
                        colors: colors,
                      ),
                      Consumer<RecommendProvider>(
                        builder: (context, provider, child) {
                          if (provider.recommended.isNotEmpty) {
                            return _buildRecommendedRow(
                              products: provider.recommended,
                              colors: colors,
                            );
                          }

                          return _buildRecommendedRowSkeleton();
                        },
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * .12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const FloatingCartBar(),
        ],
      ),
    );
  }
}

abstract class _T {
  // Spacing (8-pt scale)
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

  // Border radius
  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 18;
  static const double radiusXl = 22;
  static const double radiusFull = 999;

  // Elevation / shadow helpers
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
      color: accent.withOpacity(.32),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // Typography
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

  static TextStyle priceLg(Color c) =>
      TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c);

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

  static TextStyle seeAll(Color c) =>
      TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c);
}

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
    final base = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFECEFF4);
    final highlight = isDark
        ? const Color(0xFF252525)
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

class _AppSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final AppColors colors;

  const _AppSectionHeader({
    required this.title,
    required this.colors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 10, 25, _T.sp12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: _T.heading2(colors.text1),
            ),
          ),
          if (onTap != null)
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: _T.sp12,
                  vertical: _T.sp6,
                ),
                child: Text('see_all'.tr, style: _T.seeAll(colors.accent)),
              ),
            ),
        ],
      ),
    );
  }
}

Widget _buildStickyHeader(
  AppColors colors,
  MyProfileModel user,
  BuildContext context,
) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;

      final avatarSize = (width * .11).clamp(42.0, 52.0);
      final iconSize = (width * .10).clamp(40.0, 48.0);
      final searchHeight = (width * .12).clamp(46.0, 52.0);

      final titleSize = (width * .040).clamp(15.0, 18.0);
      final subtitleSize = (width * .028).clamp(10.0, 12.0);

      return SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: avatarSize,
                          height: avatarSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.border,
                              width: 1.2,
                            ),
                          ),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: user.avatar ?? '',
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  Container(color: colors.surface2),
                              errorWidget: (_, __, ___) => Container(
                                color: colors.surface2,
                                child: Icon(Icons.person, color: colors.text3),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${'hi'.tr} ${user.fullName}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textbg1,
                                ),
                              ),

                              const SizedBox(height: 2),

                              Text(
                                'lets_go_shopping'.tr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: subtitleSize,
                                  fontWeight: FontWeight.w500,
                                  color: colors.textbg1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(.12)),
                    ),
                    child: Center(
                      child: Icon(
                        CupertinoIcons.bell,
                        color: colors.textbg1,
                        size: iconSize * .5,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => Get.to(
                        () => const SearchScreen(),
                        transition: Transition.rightToLeftWithFade,
                      ),
                      child: Container(
                        height: searchHeight,
                        decoration: BoxDecoration(
                          color: colors.surface2,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colors.border, width: 1),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),

                            Icon(
                              CupertinoIcons.search,
                              color: colors.text3,
                              size: 20,
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: Text(
                                'search_products'.tr,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colors.text3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SearchScreen()),
                    ),
                    child: Container(
                      width: searchHeight,
                      height: searchHeight,
                      decoration: BoxDecoration(
                        color: colors.surface2,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.border, width: 1),
                      ),
                      child: Center(
                        child: Icon(
                          CupertinoIcons.slider_horizontal_3,
                          color: colors.text2,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildStickyHeaderSkeleton(AppColors colors) {
  return SafeArea(
    bottom: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colors.surface2,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: 120,
                      decoration: BoxDecoration(
                        color: colors.surface2,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      height: 10,
                      width: 90,
                      decoration: BoxDecoration(
                        color: colors.surface2,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.surface2,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: colors.surface2,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.surface2,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

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
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.90);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_pageController.hasClients || widget.banners.isEmpty) return;
      _page = (_page + 1) % widget.banners.length;
      _pageController.animateToPage(
        _page,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.banners.length,
            onPageChanged: (i) {
              _page = i;
              widget.onPageChanged(i);
            },
            itemBuilder: (_, i) => AnimatedScale(
              scale: i == widget.currentIndex ? 1.0 : 0.93,
              duration: const Duration(milliseconds: 300),
              child: _BannerCard(banner: widget.banners[i]),
            ),
          ),
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.banners.length, (i) {
            final active = i == widget.currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? widget.colors.accent : widget.colors.border,
                borderRadius: BorderRadius.circular(100),
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
    final radius = (MediaQuery.of(context).size.width * .03).clamp(10.0, 18.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: banner.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (_, __) => Container(color: Colors.grey.shade200),
        errorWidget: (_, __, ___) => Container(
          color: Colors.grey.shade300,
          child: const Icon(Icons.broken_image, size: 36),
        ),
      ),
    );
  }
}

Widget _buildBannerSkeleton(BuildContext context) {
  final bannerHeight = (MediaQuery.of(context).size.width * 0.45).clamp(
    160.0,
    260.0,
  );

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: _T.sp16),
    child: Column(
      children: [
        _Shimmer(
          width: double.infinity,
          height: bannerHeight,
          borderRadius: _T.radiusXl,
        ),

        const SizedBox(height: _T.sp12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: _T.sp4),
              child: _Shimmer(
                width: i == 0 ? 20 : 7,
                height: 7,
                borderRadius: _T.radiusFull,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildCategoryRow({
  required Function(int, String) onSelect,
  required AppColors colors,
  required List<CategoriesModel> categories,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;

      final chipHeight = (width * .11).clamp(40.0, 50.0);

      final imageSize = (width * .07).clamp(26.0, 32.0);

      final fontSize = (width * .032).clamp(12.0, 14.0);

      final horizontalPadding = (width * .04).clamp(16.0, 25.0);

      return SizedBox(
        height: chipHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final cat = categories[i];

            return GestureDetector(
              onTap: () => onSelect(cat.id, cat.name),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: imageSize * .3,
                  vertical: imageSize * .15,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: imageSize,
                      height: imageSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.surface2,
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: cat.image,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: colors.surface2),
                          errorWidget: (_, __, ___) => Icon(
                            Icons.category_rounded,
                            size: imageSize * .55,
                            color: colors.text3,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: imageSize * .3),

                    Text(
                      cat.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                        color: colors.text1,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

Widget _buildCategoryRowSkeleton(AppColors colors) {
  return SizedBox(
    height: 44,

    child: ListView.separated(
      scrollDirection: Axis.horizontal,

      physics: const BouncingScrollPhysics(),

      padding: const EdgeInsets.symmetric(horizontal: 16),

      itemCount: 6,

      separatorBuilder: (_, __) => const SizedBox(width: 10),

      itemBuilder: (_, __) {
        return Container(
          padding: const EdgeInsets.only(left: 8, right: 14, top: 7, bottom: 7),

          decoration: BoxDecoration(
            color: colors.surface,

            borderRadius: BorderRadius.circular(40),

            border: Border.all(color: colors.border),
          ),

          child: Row(
            mainAxisSize: MainAxisSize.min,

            children: [
              /// ─────────────────────
              /// IMAGE
              /// ─────────────────────
              const _Shimmer(width: 28, height: 28, borderRadius: 100),

              const SizedBox(width: 8),

              /// ─────────────────────
              /// TEXT
              /// ─────────────────────
              const _Shimmer(width: 60, height: 12, borderRadius: 8),
            ],
          ),
        );
      },
    ),
  );
}

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
    final screenWidth = MediaQuery.of(context).size.width;

    final cardWidth = (screenWidth * .36).clamp(130.0, 170.0);

    final gridHeight = cardWidth + 70;

    return SizedBox(
      height: gridHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 25),
        physics: const BouncingScrollPhysics(),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: _T.sp16),
        itemBuilder: (_, i) {
          final p = products[i];

          return SizedBox(
            width: cardWidth,
            child: _ProductCard(
              product: p,
              tagColor: tagColor,
              colors: colors,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(productId: p.id),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final dynamic product;
  final Color tagColor;
  final AppColors colors;
  final VoidCallback onTap;

  const _ProductCard({
    super.key,
    required this.product,
    required this.tagColor,
    required this.colors,
    required this.onTap,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

// class _ProductCardState extends State<_ProductCard> {
//   int _qty = 0;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {});
//     _loadCartQty();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final cart = context.watch<CartProvider>().cart;

//     if (cart != null) {
//       final item = cart.items.where((e) => e.productId == widget.product.id);

//       final newQty = item.isNotEmpty ? item.first.qty : 0;

//       if (newQty != _qty) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted) {
//             setState(() => _qty = newQty);
//           }
//         });
//       }
//     }
//   }

//   Future<void> _loadCartQty() async {
//     try {
//       final qty = await ApiService().getCartQuantity(
//         productId: widget.product.id,
//       );
//       if (mounted) setState(() => _qty = qty);
//       context.read<CartProvider>().fetchCart();
//     } catch (_) {}
//   }

//   Future<void> _setQty(int newQty) async {
//     final prev = _qty;
//     final diff = newQty - prev;

//     setState(() => _qty = newQty);

//     final cartProvider = context.read<CartProvider>();

//     // optimistic update first
//     cartProvider.updateOptimisticQty(
//       diff: diff,
//       price: double.parse(widget.product.finalPrice.toString()),
//     );

//     try {
//       if (newQty <= 0) {
//         await ApiService().removeCart(widget.product.id);

//         cartProvider.removeLocalItem(widget.product.id);
//       } else {
//         await ApiService().updateCart(
//           productId: widget.product.id,
//           quantity: newQty,
//         );
//       }

//       // sync with server
//       await cartProvider.fetchCart();
//     } catch (e) {
//       // rollback optimistic
//       cartProvider.updateOptimisticQty(
//         diff: -diff,
//         price: double.parse(widget.product.finalPrice.toString()),
//       );

//       if (mounted) {
//         setState(() => _qty = prev);
//       }
//     }
//   }

//   // Future<void> _setQty(int newQty) async {
//   //   final prev = _qty;

//   //   final diff = newQty - prev;

//   //   setState(() => _qty = newQty.clamp(0, 999));
//   //   final cartProvider = context.read<CartProvider>();

//   //   cartProvider.updateLocalQty(productId: widget.product.id, qty: newQty);

//   //   if (diff != 0) {
//   //     context.read<CartProvider>().updateOptimisticQty(
//   //       diff: diff,
//   //       price: double.parse(widget.product.finalPrice.toString()),
//   //     );
//   //   }

//   //   try {
//   //     if (newQty <= 0) {
//   //       final cartProvider = context.read<CartProvider>();

//   //       cartProvider.removeLocalItem(widget.product.id);

//   //       unawaited(ApiService().removeCart(widget.product.id));

//   //       return;
//   //     } else {
//   //       ApiService().updateCart(productId: widget.product.id, quantity: newQty);
//   //     }
//   //   } catch (_) {
//   //     // rollback
//   //     context.read<CartProvider>().updateOptimisticQty(
//   //       diff: -diff,
//   //       price: double.parse(widget.product.finalPrice.toString()),
//   //     );

//   //     if (mounted) {
//   //       setState(() => _qty = prev);
//   //     }
//   //   }
//   // }

//   Future<void> _handleAddTap() async {
//     final loggedIn = await ApiService().isLoggedIn();

//     if (!loggedIn) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginScreen()),
//       );
//       return;
//     }

//     final old = _qty;

//     setState(() => _qty = 1);

//     final cartProvider = context.read<CartProvider>();

//     cartProvider.addOptimisticItem(
//       productId: widget.product.id,
//       quantity: 1,
//       image: widget.product.images.first,
//       price: double.parse(widget.product.finalPrice.toString()),
//     );

//     try {
//       await ApiService().addToCart(productId: widget.product.id, quantity: 1);
//     } catch (_) {
//       cartProvider.clearOptimistic();

//       if (mounted) {
//         setState(() => _qty = old);
//       }
//     }
//   }
class _ProductCardState extends State<_ProductCard> {
  int _qty = 0;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadCartQty();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cart = context.watch<CartProvider>().cart;

    if (cart != null) {
      final item = cart.items.where((e) => e.productId == widget.product.id);
      final newQty = item.isNotEmpty ? item.first.qty : 0;

      // ❗ កុំ override ពេលមាន debounce timer កំពុង pending
      // (មានន័យថា user ទើបតែចុច +/- ហើយ API មិនទាន់ឆ្លើយ)
      if (_debounce?.isActive ?? false) return;

      if (newQty != _qty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _qty = newQty);
        });
      }
    }
  }

  Future<void> _loadCartQty() async {
    try {
      final qty = await ApiService().getCartQuantity(
        productId: widget.product.id,
      );
      if (mounted) setState(() => _qty = qty);
    } catch (_) {}
  }

  /// ── Stepper +/- (debounced API call) ──────────────────────
  void _setQty(int newQty) {
    if (newQty < 0) newQty = 0;

    final prev = _qty;
    final diff = newQty - prev;
    if (diff == 0) return;

    final price = double.parse(widget.product.finalPrice.toString());
    final cartProvider = context.read<CartProvider>();

    setState(() => _qty = newQty);
    cartProvider.updateOptimisticQty(diff: diff, price: price);

    if (newQty == 0) {
      cartProvider.removeLocalItem(widget.product.id);
    } else {
      cartProvider.updateLocalQty(productId: widget.product.id, qty: newQty);
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        if (newQty <= 0) {
          await ApiService().removeCart(widget.product.id);
        } else {
          await ApiService().updateCart(
            productId: widget.product.id,
            quantity: newQty,
          );
        }
        // ✅ success → no need to refetch, local state already correct
        cartProvider.clearOptimistic();
      } catch (_) {
        // ❌ fail → resync truth from server
        if (mounted) {
          await cartProvider.fetchCart();
          final item = cartProvider.cart?.items.where(
            (e) => e.productId == widget.product.id,
          );
          final serverQty = (item?.isNotEmpty ?? false) ? item!.first.qty : 0;
          setState(() => _qty = serverQty);
        }
      }
    });
  }

  /// ── Add to cart (first tap) ───────────────────────────────
  Future<void> _handleAddTap() async {
    final loggedIn = await ApiService().isLoggedIn();

    if (!loggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    final old = _qty;
    setState(() => _qty = 1);

    final cartProvider = context.read<CartProvider>();
    final price = double.parse(widget.product.finalPrice.toString());
    final image = widget.product.images.first;

    // 1) UI + floating bar លោតភ្លាម
    cartProvider.addOptimisticItem(
      productId: widget.product.id,
      quantity: 1,
      image: image,
      price: price,
    );

    // 2) API background
    try {
      await ApiService().addToCart(productId: widget.product.id, quantity: 1);
      // ✅ success → sync once to get the real cart item (so +/- stepper works after)
      if (mounted) await cartProvider.fetchCart();
    } catch (_) {
      // ❌ fail → rollback
      cartProvider.clearOptimistic();
      if (mounted) setState(() => _qty = old);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final imageRadius = (screenWidth * .05).clamp(16.0, 20.0);
    final imagePadding = (screenWidth * .03).clamp(10.0, 14.0);

    final nameSize = (screenWidth * .034).clamp(12.0, 14.0);
    final priceSize = (screenWidth * .036).clamp(13.0, 15.0);

    final imageUrl = widget.product.images.isNotEmpty
        ? widget.product.images.first
        : '';

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Product Image ─────────────────────────────
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(imageRadius),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(imagePadding),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, __) =>
                            Center(child: SizedBox(width: 20, height: 20)),
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.image_outlined),
                      ),
                    ),
                  ),
                ),

                // Discount Badge
                if (widget.product.discount != null)
                  Positioned(
                    top: _T.sp8,
                    left: _T.sp8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF7EA),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '-${double.parse(widget.product.discount!.replaceAll('%', '')).toInt()}%',
                        style: const TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                // Cart Button
                Positioned(
                  bottom: _T.sp8,
                  right: _T.sp8,
                  child: _CartStepper(
                    qty: _qty,
                    colors: widget.colors,
                    onAdd: _handleAddTap,
                    onIncrement: () async => _setQty(_qty + 1),
                    onDecrement: () async => _setQty(_qty - 1),
                  ),
                ),
              ],
            ),

            // ── Product Info ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                _T.sp12,
                _T.sp10,
                _T.sp12,
                _T.sp12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _T
                        .bodyMd(widget.colors.text1)
                        .copyWith(
                          fontSize: nameSize,
                          fontWeight: FontWeight.w600,
                        ),
                  ),

                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\$${widget.product.finalPrice}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _T
                            .priceLg(widget.colors.text1)
                            .copyWith(
                              fontSize: priceSize,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(width: 8),

                      if (widget.product.discount != null)
                        Text(
                          '\$${widget.product.salePrice}',
                          style: TextStyle(
                            fontSize: priceSize - 2,
                            color: Colors.grey.shade500,
                            decoration: TextDecoration.lineThrough,
                          ),
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

class _CartStepper extends StatelessWidget {
  final int qty;
  final AppColors colors;
  final Future<void> Function() onAdd;
  final Future<void> Function() onIncrement;
  final Future<void> Function() onDecrement;

  const _CartStepper({
    required this.qty,
    required this.colors,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final btnSize = (screenWidth * .07).clamp(26.0, 32.0);
    final iconSize = (screenWidth * .035).clamp(13.0, 16.0);
    final textSize = (screenWidth * .032).clamp(12.0, 14.0);

    final shadow = [
      BoxShadow(
        color: Colors.black.withOpacity(.13),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];

    // Add Button
    if (qty == 0) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onAdd,
        child: Container(
          width: btnSize,
          height: btnSize,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: shadow,
          ),
          child: Icon(Icons.add, color: Colors.black87, size: iconSize),
        ),
      );
    }

    // Stepper
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      height: btnSize,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_T.radiusFull),
        boxShadow: shadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDecrement,
            child: SizedBox(
              width: btnSize,
              height: btnSize,
              child: Icon(
                qty == 1 ? Icons.delete_outline_rounded : Icons.remove,
                color: Colors.black87,
                size: iconSize,
              ),
            ),
          ),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: SizedBox(
              key: ValueKey(qty),
              width: btnSize * .7,
              child: Text(
                '$qty',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: textSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onIncrement,
            child: SizedBox(
              width: btnSize,
              height: btnSize,
              child: Icon(Icons.add, color: Colors.black87, size: iconSize),
            ),
          ),
        ],
      ),
    );
  }
}

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
    final screenWidth = MediaQuery.of(context).size.width;

    final horizontalPadding = (screenWidth * .02).clamp(6.0, 10.0);

    final verticalPadding = (screenWidth * .01).clamp(3.0, 5.0);

    final fontSize = (screenWidth * .025).clamp(10.0, 12.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(_T.radiusFull),
      ),
      child: Text(
        label,
        style: _T
            .label(textColor)
            .copyWith(fontSize: fontSize, fontWeight: FontWeight.w700),
      ),
    );
  }
}

Widget _buildProductGridSkeleton(BuildContext context) {
  final cardWidth = (MediaQuery.of(context).size.width * .36).clamp(
    130.0,
    170.0,
  );

  return SizedBox(
    height: cardWidth + 70,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      itemCount: 2,
      separatorBuilder: (_, __) => const SizedBox(width: 16),
      itemBuilder: (_, __) {
        return SizedBox(
          width: cardWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: _Shimmer(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 20,
                ),
              ),

              const SizedBox(height: 10),

              const _Shimmer(width: 100, height: 14, borderRadius: 4),

              const SizedBox(height: 6),

              const _Shimmer(width: 60, height: 14, borderRadius: 4),
            ],
          ),
        );
      },
    ),
  );
}

Widget _buildRecommendedRow({
  required List<RecommendedModel> products,
  required AppColors colors,
}) {
  return ListView.separated(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.symmetric(horizontal: 25),
    itemCount: products.length,
    separatorBuilder: (_, __) =>
        Divider(color: Colors.transparent, height: 0, thickness: .8),
    itemBuilder: (context, i) {
      final item = products[i];
      final imageUrl = item.images.isNotEmpty ? item.images.first : null;

      final screenWidth = MediaQuery.of(context).size.width;

      final imageSize = (screenWidth * 0.25).clamp(110.0, 140.0);

      final titleSize = (screenWidth * 0.040).clamp(14.0, 16.0);

      final subTitleSize = (screenWidth * 0.030).clamp(11.0, 12.0);

      final priceSize = (screenWidth * 0.035).clamp(13.0, 14.0);

      final discountIconSize = (screenWidth * 0.06).clamp(22.0, 26.0);

      return GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: item.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: _T.sp10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Image ────────────────────────────
              Container(
                width: imageSize,
                height: imageSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                clipBehavior: Clip.antiAlias,
                child: CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.contain,
                  imageBuilder: (context, imageProvider) {
                    return Container(
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                  placeholder: (_, __) =>
                      const Center(child: SizedBox(width: 20, height: 20)),
                  errorWidget: (_, __, ___) =>
                      Icon(Icons.image_outlined, color: colors.text3),
                ),
              ),

              const SizedBox(width: _T.sp12),

              // ── Info ─────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w700,
                              color: colors.text1,
                              letterSpacing: -.2,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: _T.sp4),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${item.category} | ${item.brand}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: subTitleSize,
                              fontWeight: FontWeight.w500,
                              color: colors.text2,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: _T.sp4),

                    Row(
                      children: [
                        const SizedBox(width: 4),
                        Text(
                          '\$${item.finalPrice ?? item.salePrice}',
                          style: TextStyle(
                            fontSize: priceSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),

                        if (item.discount != null)
                          Text(
                            '\$${item.salePrice}',
                            style: TextStyle(
                              fontSize: priceSize - 2,
                              color: Colors.grey.shade500,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),

                        const SizedBox(width: 8),

                        if (item.discount != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF7EA),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '-${item.discount}',
                              style: const TextStyle(
                                color: Color(0xFF4CAF50),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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
    },
  );
}

Widget _buildRecommendedRowSkeleton() {
  return LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;

      final imageSize = (width * 0.30).clamp(110.0, 140.0);

      final titleWidth = (imageSize * .75).clamp(80.0, 100.0);

      final priceWidth = (imageSize * .45).clamp(50.0, 60.0);

      return SizedBox(
        height: imageSize + 60,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: _T.sp16),
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(width: _T.sp12),
          itemBuilder: (_, __) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Shimmer(width: imageSize, height: imageSize, borderRadius: 20),

              const SizedBox(height: _T.sp8),

              _Shimmer(width: titleWidth, height: 12, borderRadius: 4),

              const SizedBox(height: _T.sp6),

              _Shimmer(width: priceWidth, height: 12, borderRadius: 4),
            ],
          ),
        ),
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────
// PRODUCT GRID  (2-column)
// ─────────────────────────────────────────────────────────────

// class _ProductGrid extends StatelessWidget {
//   final List<dynamic> products;
//   final String tag;
//   final Color tagColor;
//   final AppColors colors;

//   const _ProductGrid({
//     super.key,
//     required this.products,
//     required this.tag,
//     required this.tagColor,
//     required this.colors,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: _T.sp12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: products.take(2).map((p) {
//           return Expanded(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: _T.sp6),
//               child: _ProductCard(
//                 product: p,
//                 tagColor: tagColor,
//                 colors: colors,
//                 onTap: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => ProductDetailScreen(productId: p.id),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }

// class _ProductGrid extends StatelessWidget {
//   final List<dynamic> products;
//   final String tag;
//   final Color tagColor;
//   final AppColors colors;

//   const _ProductGrid({
//     super.key,
//     required this.products,
//     required this.tag,
//     required this.tagColor,
//     required this.colors,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 235,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 25),
//         physics: const BouncingScrollPhysics(),
//         itemCount: products.length,
//         separatorBuilder: (_, __) => const SizedBox(width: _T.sp16),
//         itemBuilder: (_, i) {
//           final p = products[i];
//           return SizedBox(
//             width: 150,
//             child: _ProductCard(
//               product: p,
//               tagColor: tagColor,
//               colors: colors,
//               onTap: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => ProductDetailScreen(productId: p.id),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class _ProductCard extends StatefulWidget {
//   final dynamic product;
//   final Color tagColor;
//   final AppColors colors;
//   final VoidCallback onTap;

//   const _ProductCard({
//     super.key,
//     required this.product,
//     required this.tagColor,
//     required this.colors,
//     required this.onTap,
//   });

//   @override
//   State<_ProductCard> createState() => _ProductCardState();
// }

// class _ProductCardState extends State<_ProductCard> {
//   int _qty = 0;

//   @override
//   void initState() {
//     super.initState();
//     _loadCartQty();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // Re-check cart qty when CartProvider changes (e.g. item deleted from cart screen)
//     final cart = context.watch<CartProvider>().cart;
//     if (cart != null) {
//       final item = cart.items.where((e) => e.productId == widget.product.id);
//       final newQty = item.isNotEmpty ? item.first.qty : 0;
//       if (newQty != _qty) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted) setState(() => _qty = newQty);
//         });
//       }
//     }
//   }

//   Future<void> _loadCartQty() async {
//     try {
//       final qty = await ApiService().getCartQuantity(
//         productId: widget.product.id,
//       );
//       if (mounted) setState(() => _qty = qty);
//       context.read<CartProvider>().fetchCart();
//     } catch (_) {}
//   }

//   Future<void> _setQty(int newQty) async {
//     final prev = _qty;
//     setState(() => _qty = newQty < 0 ? 0 : newQty);
//     try {
//       if (newQty <= 0) {
//         await ApiService().removeCart(widget.product.id);
//         if (mounted) setState(() => _qty = 0);
//         context.read<CartProvider>().fetchCart();
//       } else {
//         await ApiService().updateCart(
//           productId: widget.product.id,
//           quantity: newQty,
//         );
//         context.read<CartProvider>().fetchCart();
//       }
//     } catch (_) {
//       if (mounted) setState(() => _qty = prev);
//     }
//   }

//   // Future<void> _handleAddTap() async {
//   //   final loggedIn = await ApiService().isLoggedIn();
//   //   if (!loggedIn) {
//   //     showAuthBottomSheet(context);
//   //     return;
//   //   }
//   //   final old = _qty;
//   //   setState(() => _qty = 1);
//   //   try {
//   //     await ApiService().addToCart(productId: widget.product.id, quantity: 1);
//   //     context.read<CartProvider>().fetchCart();
//   //   } catch (_) {
//   //     if (mounted) setState(() => _qty = old);
//   //   }
//   // }

//   Future<void> _handleAddTap() async {
//     final loggedIn = await ApiService().isLoggedIn();

//     if (!loggedIn) {
//       showAuthBottomSheet(context);
//       return;
//     }

//     final old = _qty;

//     setState(() => _qty = 1);

//     final cartProvider = context.read<CartProvider>();

//     // Update Floating Cart immediately
//     cartProvider.addOptimisticItem();

//     try {
//       await ApiService().addToCart(productId: widget.product.id, quantity: 1);

//       await cartProvider.fetchCart();
//     } catch (_) {
//       // rollback
//       cartProvider.rollbackOptimisticItem();

//       if (mounted) {
//         setState(() => _qty = old);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final imageUrl = widget.product.images.isNotEmpty
//         ? widget.product.images.first
//         : null;

//     return GestureDetector(
//       onTap: widget.onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           // color: widget.colors.cardBg,
//           color: Theme.of(context).scaffoldBackgroundColor,
//           borderRadius: BorderRadius.circular(1),
//           // border: Border.all(color: widget.colors.border, width: .8),
//           // boxShadow: _T.shadowSm(Colors.black),
//         ),
//         clipBehavior: Clip.antiAlias,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Image ────────────────────────────────────────
//             Stack(
//               children: [
//                 AspectRatio(
//                   aspectRatio: 1,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(12),
//                       child: CachedNetworkImage(
//                         imageUrl: imageUrl,
//                         fit: BoxFit.contain,
//                       ),
//                     ),
//                   ),
//                 ),
//                 // discount badge
//                 if (widget.product.discount != null)
//                   Positioned(
//                     top: _T.sp8,
//                     left: _T.sp8,
//                     child: _Badge(
//                       label:
//                           '-${double.parse(widget.product.discount!.replaceAll('%', '')).toInt()}%',
//                       bgColor: widget.colors.flashText,
//                       textColor: Colors.white,
//                     ),
//                   ),
//               ],
//             ),

//             // ── Info ─────────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.all(_T.sp12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.product.name,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: _T.bodyMd(widget.colors.text1),
//                   ),
//                   const SizedBox(height: _T.sp8),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             if (widget.product.discount != null)
//                               Text(
//                                 '\$${widget.product.salePrice}',
//                                 style: _T.priceSm(widget.colors.text3),
//                               ),
//                             Text(
//                               '\$${widget.product.finalPrice}',
//                               style: _T.priceLg(widget.colors.accent),
//                             ),
//                           ],
//                         ),
//                       ),
//                       _CartStepper(
//                         qty: _qty,
//                         colors: widget.colors,
//                         onAdd: _handleAddTap,
//                         onIncrement: () => _setQty(_qty + 1),
//                         onDecrement: () => _setQty(_qty - 1),
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

// class _ProductGrid extends StatelessWidget {
//   final List<dynamic> products;
//   final String tag;
//   final Color tagColor;
//   final AppColors colors;

//   const _ProductGrid({
//     super.key,
//     required this.products,
//     required this.tag,
//     required this.tagColor,
//     required this.colors,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 205,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 25),
//         physics: const BouncingScrollPhysics(),
//         itemCount: products.length,
//         separatorBuilder: (_, __) => const SizedBox(width: _T.sp16),
//         itemBuilder: (_, i) {
//           final p = products[i];
//           return SizedBox(
//             width: 140,
//             child: _ProductCard(
//               product: p,
//               tagColor: tagColor,
//               colors: colors,
//               onTap: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => ProductDetailScreen(productId: p.id),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class _ProductCard extends StatelessWidget {
//   final dynamic product;
//   final Color tagColor;
//   final AppColors colors;
//   final VoidCallback onTap;

//   const _ProductCard({
//     super.key,
//     required this.product,
//     required this.tagColor,
//     required this.colors,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final imageUrl = product.images.isNotEmpty ? product.images.first : null;

//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Theme.of(context).scaffoldBackgroundColor,
//           borderRadius: BorderRadius.circular(1),
//         ),
//         clipBehavior: Clip.antiAlias,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Image + overlaid price badge ────────────────
//             Stack(
//               children: [
//                 AspectRatio(
//                   aspectRatio: 1,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(12),
//                       child: CachedNetworkImage(
//                         imageUrl: imageUrl,
//                         fit: BoxFit.contain,
//                       ),
//                     ),
//                   ),
//                 ),

//                 // discount badge — top left
//                 if (product.discount != null)
//                   Positioned(
//                     top: _T.sp8,
//                     left: _T.sp8,
//                     child: _Badge(
//                       label:
//                           '-${double.parse(product.discount!.replaceAll('%', '')).toInt()}%',
//                       bgColor: colors.flashText,
//                       textColor: Colors.white,
//                     ),
//                   ),

//                 // price badge — bottom left
//                 Positioned(
//                   bottom: _T.sp8,
//                   left: _T.sp8,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 5,
//                     ),
//                     decoration: BoxDecoration(
//                       color: colors.accent,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.baseline,
//                       textBaseline: TextBaseline.alphabetic,
//                       children: [
//                         if (product.discount != null) ...[
//                           Text(
//                             '\$${product.salePrice}',
//                             style: TextStyle(
//                               fontSize: 10,
//                               fontWeight: FontWeight.w400,
//                               color: Colors.white.withOpacity(.65),
//                               decoration: TextDecoration.lineThrough,
//                               decorationColor: Colors.white.withOpacity(.65),
//                             ),
//                           ),
//                           const SizedBox(width: 4),
//                         ],
//                         Text(
//                           '\$${product.finalPrice}',
//                           style: const TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w700,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             // ── Name ───────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.fromLTRB(
//                 _T.sp12,
//                 _T.sp10,
//                 _T.sp12,
//                 _T.sp12,
//               ),
//               child: Text(
//                 product.name,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: _T.bodyMd(colors.text1).copyWith(fontSize: 12),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ─────────────────────────────────────────────────────────────
// CART STEPPER
// ─────────────────────────────────────────────────────────────

// class _CartStepper extends StatelessWidget {
//   final int qty;
//   final AppColors colors;
//   final Future<void> Function() onAdd;
//   final Future<void> Function() onIncrement;
//   final Future<void> Function() onDecrement;

//   const _CartStepper({
//     required this.qty,
//     required this.colors,
//     required this.onAdd,
//     required this.onIncrement,
//     required this.onDecrement,
//   });

//   @override
//   Widget build(BuildContext context) {
//     const btnSize = 32.0;

//     // ── Add button (qty == 0) ─────────────────────────────────
//     if (qty == 0) {
//       return GestureDetector(
//         behavior: HitTestBehavior.opaque,
//         onTap: onAdd,
//         child: Container(
//           width: btnSize,
//           height: btnSize,
//           decoration: BoxDecoration(
//             color: colors.accent,
//             shape: BoxShape.circle,
//             boxShadow: _T.shadowAccent(colors.accent),
//           ),
//           child: const Icon(Icons.add, color: Colors.white, size: 16),
//         ),
//       );
//     }

//     // ── Stepper (qty > 0) ─────────────────────────────────────
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       curve: Curves.easeOutCubic,
//       height: btnSize,
//       decoration: BoxDecoration(
//         color: colors.accent,
//         borderRadius: BorderRadius.circular(_T.radiusFull),
//         boxShadow: _T.shadowAccent(colors.accent),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           GestureDetector(
//             behavior: HitTestBehavior.opaque,
//             onTap: onDecrement,
//             child: const SizedBox(
//               width: btnSize,
//               height: btnSize,
//               child: Icon(Icons.remove, color: Colors.white, size: 14),
//             ),
//           ),
//           AnimatedSwitcher(
//             duration: const Duration(milliseconds: 150),
//             transitionBuilder: (child, anim) =>
//                 ScaleTransition(scale: anim, child: child),
//             child: SizedBox(
//               key: ValueKey(qty),
//               width: 22,
//               child: Text(
//                 '$qty',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 13,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ),
//           GestureDetector(
//             behavior: HitTestBehavior.opaque,
//             onTap: onIncrement,
//             child: const SizedBox(
//               width: btnSize,
//               height: btnSize,
//               child: Icon(Icons.add, color: Colors.white, size: 14),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// ─────────────────────────────────────────────────────────────
// RECOMMENDED ROW
// ─────────────────────────────────────────────────────────────
