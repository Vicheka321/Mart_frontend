import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:mart_frontend/models/brands_with_products.dart' as brand_model;
import 'package:mart_frontend/models/categories_with_products_model.dart'
    as cat_model;
import 'package:mart_frontend/providers/brands_products_provider.dart';
import 'package:mart_frontend/providers/category__products_provider.dart';
import 'package:mart_frontend/screens/product/product_detail_screen.dart';
import 'package:mart_frontend/screens/search/search_screen.dart';
import 'package:mart_frontend/screens/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';

const double _kSidebarWidth = 96;
const double _kSidebarItemH = 80;
const double _kProductImageSz = 66;
const double _kSecHeaderH = 52.0;
const double _kSecTileH = 86.0;
const double _kSecGapH = 8.0;

const double _kActivationRatio = 0.45;

// ═══════════════════════════════════════════════════════════════
// SCREEN
// ═══════════════════════════════════════════════════════════════

class CategoryBrandScreen extends StatefulWidget {
  final int? initialCategoryId;
  const CategoryBrandScreen({super.key, this.initialCategoryId});
  @override
  State<CategoryBrandScreen> createState() => _CategoryBrandScreenState();
}

class _CategoryBrandScreenState extends State<CategoryBrandScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // final ApiService _api = ApiService();

  // bool _loadingCats = true;
  // bool _loadingBrands = true;
  // bool _errorCats = false;
  // bool _errorBrands = false;

  // List<cat_model.CategoriesWithProductsModel> _categories = [];
  // List<brand_model.BrandsWithProductsModel> _brands = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriesWithProductsProvider>().init();
      context.read<BrandsWithProductsProvider>().init();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Future<void> _loadCategories() async {
  //   setState(() {
  //     _loadingCats = true;
  //     _errorCats = false;
  //   });
  //   try {
  //     final data = await _api.fetchCategoriesWithProducts();
  //     if (!mounted) return;
  //     setState(() {
  //       _categories = data;
  //       _loadingCats = false;
  //     });
  //   } catch (_) {
  //     if (!mounted) return;
  //     setState(() {
  //       _loadingCats = false;
  //       _errorCats = true;
  //     });
  //   }
  // }

  // Future<void> _loadBrands() async {
  //   setState(() {
  //     _loadingBrands = true;
  //     _errorBrands = false;
  //   });
  //   try {
  //     final data = await _api.fetchBrandsWithProducts();
  //     if (!mounted) return;
  //     setState(() {
  //       _brands = data;
  //       _loadingBrands = false;
  //     });
  //   } catch (_) {
  //     if (!mounted) return;
  //     setState(() {
  //       _loadingBrands = false;
  //       _errorBrands = true;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: _AppBar(onSearch: _openSearch),
      body: Column(
        children: [
          _TabBar(controller: _tabController),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Consumer<CategoriesWithProductsProvider>(
                  builder: (_, provider, __) {
                    if (provider.categories.isEmpty) {
                      return const _SkeletonSplitView();
                    }

                    return _CategoriesTab(
                      categories: provider.categories,
                      initialCategoryId: widget.initialCategoryId,
                    );
                  },
                ),
                Consumer<BrandsWithProductsProvider>(
                  builder: (_, provider, __) {
                    if (provider.brands.isEmpty) {
                      return const _BrandSkeleton();
                    }

                    return _BrandsTab(brands: provider.brands);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// APP BAR
// ═══════════════════════════════════════════════════════════════

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSearch;
  const _AppBar({required this.onSearch});

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppBar(
      backgroundColor: c.background,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'category'.tr,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: c.text1,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: onSearch,
          child: Container(
            margin: const EdgeInsets.only(right: 14),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.surface2,
              border: Border.all(color: c.border, width: 0.5),
            ),
            child: Icon(CupertinoIcons.search, size: 18, color: c.text2),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: c.border),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB BAR
// ═══════════════════════════════════════════════════════════════

class _TabBar extends StatelessWidget {
  final TabController controller;
  const _TabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.border, width: 0.5)),
      ),
      child: TabBar(
        controller: controller,
        indicatorColor: c.accent,
        indicatorWeight: 2,
        labelColor: c.accent,
        unselectedLabelColor: c.text3,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        tabs: [
          Tab(text: 'products'.tr),
          Tab(text: 'brand'.tr),
        ],
      ),
    );
  }
}

mixin _ScrollSyncMixin<T extends StatefulWidget> on State<T> {
  // ── subclass API ────────────────────────────────────────────
  int get itemCount;
  double sectionHeight(int index);

  // ── controllers ─────────────────────────────────────────────
  final ScrollController sidebarCtrl = ScrollController();
  final ScrollController contentCtrl = ScrollController();

  // ── ValueNotifier: only the 2 affected sidebar items rebuild ─
  final ValueNotifier<int> activeNotifier = ValueNotifier<int>(0);

  // ── pre-computed section top offsets ────────────────────────
  // Built once after first frame; rebuilt if item list changes.
  final List<double> _offsets = [];

  // ── frame-throttle flag (fix #2) ────────────────────────────
  bool _frameScheduled = false;

  // ── programmatic-scroll lock (prevents listener re-entry) ───
  bool _programmatic = false;
  Timer? _lockTimer;

  // ── sidebar debounce flag (fix #4) ──────────────────────────
  bool _sidebarScrollPending = false;

  // ── hysteresis state (fix #3) ───────────────────────────────
  // Stores the overlap of the currently-active section so we only
  // switch when a new section's overlap beats it by _kHysteresisPx.
  double _activeOverlap = 0;
  static const double _kHysteresisPx = 15.0;

  // ────────────────────────────────────────────────────────────

  void _buildOffsets() {
    _offsets.clear();
    double sum = 0;
    for (int i = 0; i < itemCount; i++) {
      _offsets.add(sum);
      sum += sectionHeight(i);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buildOffsets();
      contentCtrl.addListener(_onContentScrollRaw);
    });
  }

  @override
  void dispose() {
    activeNotifier.dispose();
    sidebarCtrl.dispose();
    contentCtrl.dispose();
    _lockTimer?.cancel();
    super.dispose();
  }

  void _onContentScrollRaw() {
    if (_programmatic || _frameScheduled) return;
    _frameScheduled = true;
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      _frameScheduled = false;
      if (mounted && !_programmatic) _evaluateActiveSection();
    });
  }

  void _evaluateActiveSection() {
    if (!contentCtrl.hasClients || _offsets.isEmpty) return;

    final scrollTop = contentCtrl.offset;
    final viewportH = contentCtrl.position.viewportDimension;
    final viewBottom = scrollTop + viewportH;

    final activationLine = scrollTop + viewportH * _kActivationRatio;

    int bestIndex = activeNotifier.value;
    double bestOverlap = _activeOverlap;

    for (int i = 0; i < _offsets.length; i++) {
      final secTop = _offsets[i];
      final secBottom = (i + 1 < _offsets.length)
          ? _offsets[i + 1]
          : _offsets[i] + sectionHeight(i);

      if (secBottom < activationLine) continue;

      if (secTop > viewBottom) break;
      final visTop = secTop < activationLine ? activationLine : secTop;
      final visBottom = secBottom > viewBottom ? viewBottom : secBottom;
      final overlap = (visBottom - visTop).clamp(0.0, viewportH);
      if (overlap > bestOverlap + _kHysteresisPx) {
        bestOverlap = overlap;
        bestIndex = i;
      }
    }

    if (bestIndex != activeNotifier.value) {
      _activeOverlap = bestOverlap;
      activeNotifier.value = bestIndex;
      _scheduleSidebarScroll(bestIndex);
    }
  }

  void _scheduleSidebarScroll(int index) {
    if (_sidebarScrollPending) return;
    _sidebarScrollPending = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _sidebarScrollPending = false;
      _scrollSidebarTo(index);
    });
  }

  void _scrollSidebarTo(int index) {
    if (!sidebarCtrl.hasClients) return;
    final center = _kSidebarItemH * index + _kSidebarItemH / 2;
    final viewport = sidebarCtrl.position.viewportDimension;
    final target = (center - viewport / 2).clamp(
      0.0,
      sidebarCtrl.position.maxScrollExtent,
    );
    sidebarCtrl.animateTo(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  // ── SIDEBAR TAP: smooth scroll to section ───────────────────
  void onSidebarTap(int index) {
    if (index == activeNotifier.value) return;
    // HapticFeedback.lightImpact();

    // Update notifier immediately for instant visual feedback
    activeNotifier.value = index;
    _activeOverlap = double.maxFinite; // lock hysteresis until scroll settles
    _scrollSidebarTo(index);

    // Lock the listener while animateTo runs
    _programmatic = true;
    _lockTimer?.cancel();

    if (_offsets.isEmpty) {
      _buildOffsets();
    }
    if (_offsets.isNotEmpty && contentCtrl.hasClients) {
      final target = _offsets[index].clamp(
        0.0,
        contentCtrl.position.maxScrollExtent,
      );
      contentCtrl.animateTo(
        target,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    }

    // Release lock after animation + a small buffer
    _lockTimer = Timer(const Duration(milliseconds: 700), () {
      _programmatic = false;
      _activeOverlap = 0; // re-enable hysteresis for user scrolling
    });
  }
}

// ═══════════════════════════════════════════════════════════════
// CATEGORIES TAB
// ═══════════════════════════════════════════════════════════════

class _CategoriesTab extends StatefulWidget {
  final List<cat_model.CategoriesWithProductsModel> categories;
  final int? initialCategoryId;
  const _CategoriesTab({required this.categories, this.initialCategoryId});

  @override
  State<_CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<_CategoriesTab>
    with _ScrollSyncMixin<_CategoriesTab> {
  @override
  int get itemCount => widget.categories.length;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _jumpToInitialCategory();
    });
  }

  @override
  @override
  double sectionHeight(int index) {
    final n = widget.categories[index].products.length;
    return _kSecHeaderH + n * _kSecTileH + _kSecGapH;
  }

  void _jumpToInitialCategory() {
    if (widget.initialCategoryId == null) return;

    final index = widget.categories.indexWhere(
      (e) => e.id == widget.initialCategoryId,
    );

    if (index < 0) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      onSidebarTap(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Sidebar(
          categories: widget.categories,
          activeNotifier: activeNotifier,
          controller: sidebarCtrl,
          onTap: onSidebarTap,
        ),
        Container(width: 0.5, color: context.colors.border),
        Expanded(
          child: ListView.builder(
            controller: contentCtrl,
            itemCount: widget.categories.length,
            itemBuilder: (_, i) =>
                _CategorySection(category: widget.categories[i]),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SIDEBAR  — StatelessWidget; passes ValueNotifier down
// ═══════════════════════════════════════════════════════════════

class _Sidebar extends StatelessWidget {
  final List<cat_model.CategoriesWithProductsModel> categories;
  final ValueNotifier<int> activeNotifier;
  final ScrollController controller;
  final ValueChanged<int> onTap;

  const _Sidebar({
    required this.categories,
    required this.activeNotifier,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kSidebarWidth,
      color: context.colors.surface2,
      child: ListView.builder(
        controller: controller,
        itemCount: categories.length,
        itemBuilder: (_, i) => _SidebarItem(
          category: categories[i],
          index: i,
          activeNotifier: activeNotifier,
          onTap: () => onTap(i),
        ),
      ),
    );
  }
}

// ── _SidebarItem: uses ValueListenableBuilder so ONLY this widget
//   rebuilds when its own active state changes (FIX #5).
class _SidebarItem extends StatelessWidget {
  final cat_model.CategoriesWithProductsModel category;
  final int index;
  final ValueNotifier<int> activeNotifier;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.category,
    required this.index,
    required this.activeNotifier,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ValueListenableBuilder<int>(
      valueListenable: activeNotifier,
      builder: (_, active, __) {
        final isActive = index == active;
        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: _kSidebarItemH,
            decoration: BoxDecoration(
              // Animate background: surface2 → background
              color: isActive ? c.background : c.surface2,
              border: Border(
                left: BorderSide(
                  color: isActive ? c.accent : Colors.transparent,
                  width: 2.5,
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: CachedNetworkImage(
                    imageUrl: category.image,
                    width: 38,
                    height: 38,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _imgPlaceholder(38, context),
                    errorWidget: (_, __, ___) =>
                        _imgFallback(category.name, 38, context, radius: 9),
                  ),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    category.name,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      height: 1.25,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                      color: isActive ? c.accent : c.text3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CATEGORY SECTION  (unchanged layout)
// ═══════════════════════════════════════════════════════════════

class _CategorySection extends StatelessWidget {
  final cat_model.CategoriesWithProductsModel category;
  const _CategorySection({required this.category});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: CachedNetworkImage(
                  imageUrl: category.image,
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _imgPlaceholder(20, context),
                  errorWidget: (_, __, ___) =>
                      _imgFallback(category.name, 20, context, radius: 5),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  category.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: c.text1,
                  ),
                ),
              ),
              Text(
                '${category.products.length}',
                style: TextStyle(fontSize: 11, color: c.text3),
              ),
            ],
          ),
        ),
        ...category.products.map((p) => _ProductTile(product: p)),
        Container(height: _kSecGapH, color: c.surface2),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PRODUCT TILE  (scale-on-tap + Hero — unchanged from prev turn)
// ═══════════════════════════════════════════════════════════════

class _ProductTile extends StatefulWidget {
  final cat_model.Product product;
  const _ProductTile({required this.product});

  @override
  State<_ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<_ProductTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  bool get _inStock => widget.product.quantity > 0;
  double get _price => double.tryParse(widget.product.salePrice) ?? 0;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 180),
      value: 1.0,
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _scaleCtrl.forward();
  void _onTapCancel() => _scaleCtrl.reverse();
  void _onTap() {
    // HapticFeedback.selectionClick();
    _scaleCtrl.reverse();
    Navigator.push(
      context,
      _smoothRoute(ProductDetailScreen(productId: widget.product.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapCancel: _onTapCancel,
      onTap: _onTap,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: c.border, width: 0.5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                        color: c.text1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // _UnitBadge(unit: widget.product.unit.name.toLowerCase()),
                    // const SizedBox(height: 5),
                    Row(
                      children: [
                        // Final price
                        Text(
                          '\$${widget.product.finalPrice}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: c.text1,
                          ),
                        ),

                        if (widget.product.discount != null) ...[
                          const SizedBox(width: 8),

                          // Original price
                          Text(
                            '\$${widget.product.salePrice}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Discount badge
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
                              '-${widget.product.discount!.display}',
                              style: const TextStyle(
                                color: Color(0xFF2563EB),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],

                        // const SizedBox(width: 8),

                        // Text(
                        //   _inStock
                        //       ? 'In stock (${widget.product.quantity})'
                        //       : 'Out of stock',
                        //   style: TextStyle(
                        //     fontSize: 10,
                        //     color: _inStock ? c.flashText : c.text3,
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Stack(
                children: [
                  Hero(
                    tag: 'product-img-${widget.product.id}',
                    child: Container(
                      width: _kProductImageSz,
                      height: _kProductImageSz,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.colors.border,
                          width: .5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: widget.product.firstImage.imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (_, __) =>
                              _imgPlaceholder(_kProductImageSz, context),
                          errorWidget: (_, __, ___) => _imgFallback(
                            widget.product.name,
                            _kProductImageSz,
                            context,
                            radius: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!_inStock)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: _kProductImageSz,
                        height: _kProductImageSz,
                        color: c.background.withOpacity(0.5),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BRANDS TAB  — identical mixin usage
// ═══════════════════════════════════════════════════════════════

class _BrandsTab extends StatefulWidget {
  final List<brand_model.BrandsWithProductsModel> brands;
  const _BrandsTab({required this.brands});

  @override
  State<_BrandsTab> createState() => _BrandsTabState();
}

class _BrandsTabState extends State<_BrandsTab>
    with _ScrollSyncMixin<_BrandsTab> {
  @override
  int get itemCount => widget.brands.length;

  @override
  double sectionHeight(int index) {
    final n = widget.brands[index].products.length;
    return _kSecHeaderH + n * _kSecTileH + _kSecGapH;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _BrandSidebar(
          brands: widget.brands,
          activeNotifier: activeNotifier,
          controller: sidebarCtrl,
          onTap: onSidebarTap,
        ),
        Container(width: 0.5, color: context.colors.border),
        Expanded(
          child: ListView.builder(
            controller: contentCtrl,
            itemCount: widget.brands.length,
            itemBuilder: (_, i) => _BrandSection(brand: widget.brands[i]),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BRAND SIDEBAR
// ═══════════════════════════════════════════════════════════════

class _BrandSidebar extends StatelessWidget {
  final List<brand_model.BrandsWithProductsModel> brands;
  final ValueNotifier<int> activeNotifier;
  final ScrollController controller;
  final ValueChanged<int> onTap;

  const _BrandSidebar({
    required this.brands,
    required this.activeNotifier,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kSidebarWidth,
      color: context.colors.surface2,
      child: ListView.builder(
        controller: controller,
        itemCount: brands.length,
        itemBuilder: (_, i) => _BrandSidebarItem(
          brand: brands[i],
          index: i,
          activeNotifier: activeNotifier,
          onTap: () => onTap(i),
        ),
      ),
    );
  }
}

class _BrandSidebarItem extends StatelessWidget {
  final brand_model.BrandsWithProductsModel brand;
  final int index;
  final ValueNotifier<int> activeNotifier;
  final VoidCallback onTap;

  const _BrandSidebarItem({
    required this.brand,
    required this.index,
    required this.activeNotifier,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ValueListenableBuilder<int>(
      valueListenable: activeNotifier,
      builder: (_, active, __) {
        final isActive = index == active;
        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: _kSidebarItemH,
            decoration: BoxDecoration(
              color: isActive ? c.background : c.surface2,
              border: Border(
                left: BorderSide(
                  color: isActive ? c.accent : Colors.transparent,
                  width: 2.5,
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: brand.image,
                    width: 38,
                    height: 38,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _imgPlaceholder(38, context),
                    errorWidget: (_, __, ___) =>
                        _brandInitialCircle(brand.name, 38, context),
                  ),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    brand.name,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      height: 1.25,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                      color: isActive ? c.accent : c.text3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BRAND SECTION
// ═══════════════════════════════════════════════════════════════

class _BrandSection extends StatelessWidget {
  final brand_model.BrandsWithProductsModel brand;
  const _BrandSection({required this.brand});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
          child: Row(
            children: [
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: brand.image,
                  width: 22,
                  height: 22,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _imgPlaceholder(22, context),
                  errorWidget: (_, __, ___) =>
                      _brandInitialCircle(brand.name, 22, context),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  brand.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: c.text1,
                  ),
                ),
              ),
              Text(
                '${brand.products.length}',
                style: TextStyle(fontSize: 11, color: c.text3),
              ),
            ],
          ),
        ),
        ...brand.products.map((p) => _BrandProductTile(product: p)),
        Container(height: _kSecGapH, color: c.surface2),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BRAND PRODUCT TILE  (scale + Hero)
// ═══════════════════════════════════════════════════════════════

class _BrandProductTile extends StatefulWidget {
  final brand_model.Product product;
  const _BrandProductTile({required this.product});

  @override
  State<_BrandProductTile> createState() => _BrandProductTileState();
}

class _BrandProductTileState extends State<_BrandProductTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  bool get _inStock => widget.product.status && widget.product.quantity > 0;
  double get _price => double.tryParse(widget.product.salePrice) ?? 0;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 180),
      value: 1.0,
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _scaleCtrl.forward();
  void _onTapCancel() => _scaleCtrl.reverse();
  void _onTap() {
    // HapticFeedback.selectionClick();
    _scaleCtrl.reverse();
    Navigator.push(
      context,
      _smoothRoute(ProductDetailScreen(productId: widget.product.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapCancel: _onTapCancel,
      onTap: _onTap,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: c.border, width: 0.5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                        color: c.text1,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // _UnitBadge(unit: widget.product.unit.name.toLowerCase()),
                    // const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          '\$${widget.product.finalPrice}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: c.text1,
                          ),
                        ),

                        if (widget.product.discount != null) ...[
                          const SizedBox(width: 8),

                          Text(
                            '\$${widget.product.salePrice}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),

                          const SizedBox(width: 8),

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
                              '-${widget.product.discount!.display}',
                              style: const TextStyle(
                                color: Color(0xFF2563EB),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Stack(
                children: [
                  Hero(
                    tag: 'brand-product-img-${widget.product.id}',
                    child: Container(
                      width: _kProductImageSz,
                      height: _kProductImageSz,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: c.border, width: .5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: widget.product.firstImage.imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (_, __) =>
                              _imgPlaceholder(_kProductImageSz, context),
                          errorWidget: (_, __, ___) => _imgFallback(
                            widget.product.name,
                            _kProductImageSz,
                            context,
                            radius: 8,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!_inStock)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: _kProductImageSz,
                        height: _kProductImageSz,
                        color: c.background.withOpacity(0.5),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// NAVIGATION HELPER
// ═══════════════════════════════════════════════════════════════

PageRoute<T> _smoothRoute<T>(Widget page) => PageRouteBuilder<T>(
  transitionDuration: const Duration(milliseconds: 350),
  pageBuilder: (_, __, ___) => page,
  transitionsBuilder: (_, animation, __, child) => FadeTransition(
    opacity: animation,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.08, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
  ),
);

// ═══════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════

class _UnitBadge extends StatelessWidget {
  final String unit;
  const _UnitBadge({required this.unit});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c.cardBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: c.border, width: 0.5),
      ),
      child: Text(unit, style: TextStyle(fontSize: 10, color: c.text3)),
    );
  }
}

Widget _imgPlaceholder(double size, BuildContext context) =>
    Container(width: size, height: size, color: context.colors.cardBg);

Widget _imgFallback(
  String name,
  double size,
  BuildContext context, {
  double radius = 8,
}) {
  final c = context.colors;
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: c.accentLight,
      borderRadius: BorderRadius.circular(radius),
    ),
    alignment: Alignment.center,
    child: Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
      style: TextStyle(
        color: c.accent,
        fontWeight: FontWeight.w700,
        fontSize: size * 0.4,
      ),
    ),
  );
}

Widget _brandInitialCircle(String name, double size, BuildContext context) {
  final c = context.colors;
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: c.accentLight),
    alignment: Alignment.center,
    child: Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
      style: TextStyle(
        color: c.accent,
        fontWeight: FontWeight.w700,
        fontSize: size * 0.4,
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
// ERROR / EMPTY STATES
// ═══════════════════════════════════════════════════════════════

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 52, color: c.text3),
            const SizedBox(height: 14),
            Text(
              'Connection failed',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: c.text1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Could not load data. Please check your connection.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: c.text2),
            ),
            const SizedBox(height: 22),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 17),
              label: const Text('Retry'),
              style: TextButton.styleFrom(foregroundColor: c.accent),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 52, color: c.text3),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(fontSize: 15, color: c.text2)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SKELETON
// ═══════════════════════════════════════════════════════════════

class _SkeletonSplitView extends StatelessWidget {
  const _SkeletonSplitView();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: _kSidebarWidth,
          color: context.colors.surface2,
          child: ListView.builder(
            itemCount: 8,
            itemBuilder: (_, __) => const _SidebarSkeletonItem(),
          ),
        ),
        Container(width: 0.5, color: context.colors.border),
        Expanded(
          child: ListView.builder(
            itemCount: 6,
            itemBuilder: (_, __) => const _ProductSkeletonItem(),
          ),
        ),
      ],
    );
  }
}

class _SidebarSkeletonItem extends StatelessWidget {
  const _SidebarSkeletonItem();
  @override
  Widget build(BuildContext context) => Container(
    height: _kSidebarItemH,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
    child: Column(
      children: [
        _Shimmer(width: 38, height: 38, radius: 9),
        const SizedBox(height: 5),
        _Shimmer(width: 60, height: 8, radius: 4),
      ],
    ),
  );
}

class _ProductSkeletonItem extends StatelessWidget {
  const _ProductSkeletonItem();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: context.colors.border, width: 0.5)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Shimmer(width: double.infinity, height: 13, radius: 4),
              const SizedBox(height: 6),
              _Shimmer(width: 60, height: 11, radius: 4),
              const SizedBox(height: 6),
              _Shimmer(width: 80, height: 11, radius: 4),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _Shimmer(width: _kProductImageSz, height: _kProductImageSz, radius: 10),
      ],
    ),
  );
}

class _BrandSkeleton extends StatelessWidget {
  const _BrandSkeleton();
  @override
  Widget build(BuildContext context) => const _SkeletonSplitView();
}

// ═══════════════════════════════════════════════════════════════
// SHIMMER
// ═══════════════════════════════════════════════════════════════

class _Shimmer extends StatefulWidget {
  final double width, height, radius;
  const _Shimmer({
    required this.width,
    required this.height,
    required this.radius,
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
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.4,
      end: 1.0,
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
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          color: Color.lerp(
            isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E4DF),
            isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F2EE),
            _anim.value,
          ),
        ),
      ),
    );
  }
}
