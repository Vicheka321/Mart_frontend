import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ═══════════════════════════════════════════════════════════════
// MODELS
// ═══════════════════════════════════════════════════════════════

class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;
  final String filter;
  final int productCount;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.filter,
    required this.productCount,
  });
}

class BrandModel {
  final String id;
  final String name;
  final String logoUrl;
  final int productCount;
  final bool isFeatured;
  final Color accentColor;

  const BrandModel({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.productCount,
    this.isFeatured = false,
    required this.accentColor,
  });
}

class SearchSuggestion {
  final String text;
  final bool isProduct;

  const SearchSuggestion({required this.text, required this.isProduct});
}

// ═══════════════════════════════════════════════════════════════
// FAKE DATA
// ═══════════════════════════════════════════════════════════════

final List<CategoryModel> kCategories = [
  CategoryModel(
    id: '1',
    name: 'Burgers',
    imageUrl:
        'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
    filter: 'food',
    productCount: 12,
  ),
  CategoryModel(
    id: '2',
    name: 'Pizza',
    imageUrl:
        'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',
    filter: 'food',
    productCount: 8,
  ),
  CategoryModel(
    id: '3',
    name: 'Sushi',
    imageUrl:
        'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=400',
    filter: 'food',
    productCount: 15,
  ),
  CategoryModel(
    id: '4',
    name: 'Coffee',
    imageUrl:
        'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',
    filter: 'drink',
    productCount: 20,
  ),
  CategoryModel(
    id: '5',
    name: 'Smoothies',
    imageUrl: 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=400',
    filter: 'drink',
    productCount: 10,
  ),
  CategoryModel(
    id: '6',
    name: 'Pasta',
    imageUrl:
        'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?w=400',
    filter: 'food',
    productCount: 7,
  ),
  CategoryModel(
    id: '7',
    name: 'Salads',
    imageUrl:
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
    filter: 'food',
    productCount: 9,
  ),
  CategoryModel(
    id: '8',
    name: 'Juices',
    imageUrl:
        'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400',
    filter: 'drink',
    productCount: 14,
  ),
  CategoryModel(
    id: '9',
    name: 'Desserts',
    imageUrl:
        'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',
    filter: 'other',
    productCount: 18,
  ),
];

final List<BrandModel> kBrands = [
  BrandModel(
    id: 'b1',
    name: 'Starbucks',
    logoUrl:
        'https://images.unsplash.com/photo-1572119865084-43c285814d63?w=200',
    productCount: 34,
    isFeatured: true,
    accentColor: Color(0xFF00704A),
  ),
  BrandModel(
    id: 'b2',
    name: 'McDonald\'s',
    logoUrl:
        'https://images.unsplash.com/photo-1619881585040-d01a8e95f40f?w=200',
    productCount: 28,
    isFeatured: true,
    accentColor: Color(0xFFDA291C),
  ),
  BrandModel(
    id: 'b3',
    name: 'Shake Shack',
    logoUrl:
        'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=200',
    productCount: 19,
    isFeatured: false,
    accentColor: Color(0xFF6DB33F),
  ),
  BrandModel(
    id: 'b4',
    name: 'Nobu',
    logoUrl:
        'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=200',
    productCount: 22,
    isFeatured: true,
    accentColor: Color(0xFF1A1A2E),
  ),
  BrandModel(
    id: 'b5',
    name: 'Jamba',
    logoUrl: 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=200',
    productCount: 15,
    isFeatured: false,
    accentColor: Color(0xFFFF6B35),
  ),
  BrandModel(
    id: 'b6',
    name: 'Sweetgreen',
    logoUrl:
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=200',
    productCount: 11,
    isFeatured: false,
    accentColor: Color(0xFF4A7C59),
  ),
];

final List<String> kAllSuggestions = [
  'Burgers',
  'Pizza',
  'Sushi',
  'Coffee',
  'Smoothies',
  'Pasta',
  'Salads',
  'Juices',
  'Desserts',
  'Cheese Burger',
  'Pepperoni Pizza',
  'Iced Latte',
  'Mango Smoothie',
  'Caesar Salad',
  'Tiramisu',
  'Starbucks',
  'McDonald\'s',
  'Shake Shack',
  'Nobu',
];

// ═══════════════════════════════════════════════════════════════
// MAIN CATEGORIES SCREEN
// ═══════════════════════════════════════════════════════════════

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isSearchActive = false;
  List<SearchSuggestion> _suggestions = [];
  Timer? _debounce;

  bool _isLoading = true;
  List<CategoryModel> _categories = [];
  List<BrandModel> _brands = [];

  final ScrollController _scrollController = ScrollController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _brandsAnimController;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _brandsAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _searchController.addListener(_onSearchChanged);
    _searchFocus.addListener(() {
      setState(() => _isSearchActive = _searchFocus.hasFocus);
    });

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) {
      setState(() {
        _categories = kCategories;
        _brands = kBrands;
        _isLoading = false;
      });
      _fadeController.forward();
      await Future.delayed(const Duration(milliseconds: 100));
      _brandsAnimController.forward();
    }
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      final q = _searchController.text.trim().toLowerCase();
      if (q.isEmpty) {
        setState(() => _suggestions = []);
        return;
      }
      final results = kAllSuggestions
          .where((s) => s.toLowerCase().contains(q))
          .map(
            (s) => SearchSuggestion(
              text: s,
              isProduct:
                  !kCategories.any(
                    (c) => c.name.toLowerCase() == s.toLowerCase(),
                  ) &&
                  !kBrands.any((b) => b.name.toLowerCase() == s.toLowerCase()),
            ),
          )
          .take(6)
          .toList();
      setState(() => _suggestions = results);
    });
  }

  List<CategoryModel> get _filteredCategories {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _categories;
    return _categories.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocus.unfocus();
    setState(() => _suggestions = []);
  }

  void _applySuggestion(String text) {
    _searchController.text = text;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
    _searchFocus.unfocus();
    setState(() => _suggestions = []);
  }

  void _navigateToProducts(CategoryModel category) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => ProductListScreen(category: category),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          ),
        ),
      ),
    );
  }

  void _navigateToBrand(BrandModel brand) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => BrandScreen(brand: brand),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _debounce?.cancel();
    _scrollController.dispose();
    _fadeController.dispose();
    _brandsAnimController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final filteredCats = _filteredCategories;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Header ──────────────────────────────────────
            const _Header(),

            // ── 2. Search Bar ──────────────────────────────────
            _SearchBar(
              controller: _searchController,
              focusNode: _searchFocus,
              isActive: _isSearchActive,
              onClear: _clearSearch,
            ),

            // ── 3. Suggestions OR Main Content ─────────────────
            if (_suggestions.isNotEmpty)
              _SuggestionList(
                suggestions: _suggestions,
                onSelect: _applySuggestion,
              )
            else ...[
              const SizedBox(height: 10),
              Expanded(
                child: _isLoading
                    ? const _SkeletonScroll()
                    : _MainScroll(
                        fadeAnimation: _fadeAnimation,
                        brandsAnimController: _brandsAnimController,
                        brands: _brands,
                        filteredCategories: filteredCats,
                        onNavigateToBrand: _navigateToBrand,
                        onNavigateToProducts: _navigateToProducts,
                        onClearSearch: _clearSearch,
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 1. HEADER
// ═══════════════════════════════════════════════════════════════

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 2. SEARCH BAR
// ═══════════════════════════════════════════════════════════════

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isActive;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.isActive,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withOpacity(0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
          border: Border.all(
            color: isActive
                ? const Color(0xFFFF6B35).withOpacity(0.5)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A1A),
          ),
          decoration: InputDecoration(
            hintText: 'Search categories, brands & products...',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(
                Icons.search_rounded,
                color: isActive
                    ? const Color(0xFFFF6B35)
                    : Colors.grey.shade400,
                size: 22,
              ),
            ),
            suffixIcon: controller.text.isNotEmpty
                ? GestureDetector(
                    onTap: onClear,
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 4,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 3. SUGGESTION LIST
// ═══════════════════════════════════════════════════════════════

class _SuggestionList extends StatelessWidget {
  final List<SearchSuggestion> suggestions;
  final ValueChanged<String> onSelect;

  const _SuggestionList({required this.suggestions, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: suggestions.asMap().entries.map((e) {
            final index = e.key;
            final suggestion = e.value;
            return InkWell(
              onTap: () => onSelect(suggestion.text),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  border: index < suggestions.length - 1
                      ? Border(bottom: BorderSide(color: Colors.grey.shade100))
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: suggestion.isProduct
                            ? const Color(0xFFFFF0EB)
                            : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        suggestion.isProduct
                            ? Icons.shopping_bag_outlined
                            : Icons.category_outlined,
                        size: 16,
                        color: suggestion.isProduct
                            ? const Color(0xFFFF6B35)
                            : const Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          suggestion.text,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        Text(
                          suggestion.isProduct ? 'Product' : 'Category / Brand',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Icon(
                      Icons.north_west_rounded,
                      size: 14,
                      color: Colors.grey.shade300,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 4. MAIN SCROLL
// ═══════════════════════════════════════════════════════════════

class _MainScroll extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final AnimationController brandsAnimController;
  final List<BrandModel> brands;
  final List<CategoryModel> filteredCategories;
  final ValueChanged<BrandModel> onNavigateToBrand;
  final ValueChanged<CategoryModel> onNavigateToProducts;
  final VoidCallback onClearSearch;

  const _MainScroll({
    required this.fadeAnimation,
    required this.brandsAnimController,
    required this.brands,
    required this.filteredCategories,
    required this.onNavigateToBrand,
    required this.onNavigateToProducts,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: CustomScrollView(
        slivers: [
          // ── Brands ──────────────────────────────────────────
          const SliverToBoxAdapter(child: _BrandsHeader()),
          SliverToBoxAdapter(
            child: _FeaturedBrandCard(
              brands: brands,
              brandsAnimController: brandsAnimController,
              onTap: onNavigateToBrand,
            ),
          ),
          SliverToBoxAdapter(
            child: _BrandsRow(
              brands: brands,
              brandsAnimController: brandsAnimController,
              onTap: onNavigateToBrand,
            ),
          ),

          // ── Categories Header ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'All Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    '${filteredCategories.length} found',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ),

          // ── Category Grid ────────────────────────────────────
          if (filteredCategories.isEmpty)
            SliverFillRemaining(child: _EmptyState(onClear: onClearSearch))
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, index) => _CategoryCard(
                    category: filteredCategories[index],
                    index: index,
                    onTap: () =>
                        onNavigateToProducts(filteredCategories[index]),
                  ),
                  childCount: filteredCategories.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.82,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 5. BRANDS HEADER
// ═══════════════════════════════════════════════════════════════

class _BrandsHeader extends StatelessWidget {
  const _BrandsHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                'Brands',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {},
            child: const Text(
              'See all',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF6B35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 6. FEATURED BRAND CARD
// ═══════════════════════════════════════════════════════════════

class _FeaturedBrandCard extends StatelessWidget {
  final List<BrandModel> brands;
  final AnimationController brandsAnimController;
  final ValueChanged<BrandModel> onTap;

  const _FeaturedBrandCard({
    required this.brands,
    required this.brandsAnimController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final featured = brands.where((b) => b.isFeatured).take(1).firstOrNull;
    if (featured == null) return const SizedBox.shrink();

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: brandsAnimController,
              curve: Curves.easeOutCubic,
            ),
          ),
      child: FadeTransition(
        opacity: brandsAnimController,
        child: GestureDetector(
          onTap: () => onTap(featured),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                colors: [
                  featured.accentColor,
                  featured.accentColor.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: featured.accentColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background image
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Opacity(
                    opacity: 0.25,
                    child: Image.network(
                      featured.logoUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),
                ),
                // Decorative circles
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: -30,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            featured.logoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                featured.name[0],
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: featured.accentColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '⭐ Featured Brand',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              featured.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${featured.productCount} products available',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 7. BRANDS ROW
// ═══════════════════════════════════════════════════════════════

class _BrandsRow extends StatelessWidget {
  final List<BrandModel> brands;
  final AnimationController brandsAnimController;
  final ValueChanged<BrandModel> onTap;

  const _BrandsRow({
    required this.brands,
    required this.brandsAnimController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final otherBrands = brands.skip(1).toList();

    return Column(
      children: [
        const SizedBox(height: 14),
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: otherBrands.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final delay = (index * 80).clamp(0, 400);
              return AnimatedBuilder(
                animation: brandsAnimController,
                builder: (_, child) {
                  final progress = Curves.easeOutCubic.transform(
                    (brandsAnimController.value - delay / 1000).clamp(0.0, 1.0),
                  );
                  return Opacity(
                    opacity: progress,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - progress)),
                      child: child,
                    ),
                  );
                },
                child: _BrandCard(
                  brand: otherBrands[index],
                  onTap: () => onTap(otherBrands[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 8. EMPTY STATE
// ═══════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final VoidCallback onClear;

  const _EmptyState({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 40,
              color: Color(0xFFFF6B35),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No categories found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search\nor filter selection',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onClear,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'Clear filters',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 9. SKELETON SCROLL
// ═══════════════════════════════════════════════════════════════

class _SkeletonScroll extends StatelessWidget {
  const _SkeletonScroll();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          const _SkeletonBox(
            width: double.infinity,
            height: 150,
            margin: EdgeInsets.symmetric(horizontal: 20),
            radius: 22,
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 108,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 5,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.only(right: 12),
                child: _SkeletonBrandCard(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.82,
            ),
            itemCount: 6,
            itemBuilder: (_, __) => const _SkeletonCard(),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BRAND CARD (Small horizontal)
// ═══════════════════════════════════════════════════════════════

class _BrandCard extends StatefulWidget {
  final BrandModel brand;
  final VoidCallback onTap;

  const _BrandCard({required this.brand, required this.onTap});

  @override
  State<_BrandCard> createState() => _BrandCardState();
}

class _BrandCardState extends State<_BrandCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.brand;
    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) async {
        await _press.reverse();
        widget.onTap();
      },
      onTapCancel: () => _press.reverse(),
      child: AnimatedBuilder(
        animation: _press,
        builder: (_, child) =>
            Transform.scale(scale: 1.0 - (_press.value * 0.04), child: child),
        child: Container(
          width: 88,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: b.accentColor.withOpacity(0.1),
                  border: Border.all(
                    color: b.accentColor.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: Image.network(
                    b.logoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        b.name[0],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: b.accentColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                b.name,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${b.productCount} items',
                style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CATEGORY CARD
// ═══════════════════════════════════════════════════════════════

class _CategoryCard extends StatefulWidget {
  final CategoryModel category;
  final int index;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.index,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) async {
        await _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  widget.category.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(color: Colors.grey.shade200);
                  },
                  errorBuilder: (_, __, ___) =>
                      Container(color: Colors.grey.shade200),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0x26000000),
                        Color(0xB8000000),
                      ],
                      stops: [0.35, 0.6, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.category.productCount} items',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Text(
                    widget.category.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SKELETON WIDGETS
// ═══════════════════════════════════════════════════════════════

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.3,
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
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(
                const Color(0xFFE8E4DF),
                const Color(0xFFF5F2EE),
                _anim.value,
              )!,
              Color.lerp(
                const Color(0xFFF5F2EE),
                const Color(0xFFE8E4DF),
                _anim.value,
              )!,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 55,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 60,
              bottom: 14,
              child: Container(
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBrandCard extends StatefulWidget {
  const _SkeletonBrandCard();

  @override
  State<_SkeletonBrandCard> createState() => _SkeletonBrandCardState();
}

class _SkeletonBrandCardState extends State<_SkeletonBrandCard>
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
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _box(double w, double h, {double r = 8}) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        color: Color.lerp(
          const Color(0xFFE8E4DF),
          const Color(0xFFF5F2EE),
          _anim.value,
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _box(52, 52, r: 26),
          const SizedBox(height: 6),
          _box(55, 10),
          const SizedBox(height: 4),
          _box(40, 8),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final EdgeInsets? margin;
  final double radius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.margin,
    this.radius = 12,
  });

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
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
      begin: 0.3,
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
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            colors: [
              Color.lerp(
                const Color(0xFFE8E4DF),
                const Color(0xFFF5F2EE),
                _anim.value,
              )!,
              Color.lerp(
                const Color(0xFFF5F2EE),
                const Color(0xFFE8E4DF),
                _anim.value,
              )!,
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BRAND SCREEN
// ═══════════════════════════════════════════════════════════════

class BrandScreen extends StatelessWidget {
  final BrandModel brand;
  const BrandScreen({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: brand.accentColor,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          brand.accentColor,
                          brand.accentColor.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -30,
                    top: -30,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.07),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              brand.logoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  brand.name[0],
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: brand.accentColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              brand.name,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${brand.productCount} products',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            if (brand.isFeatured)
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  '⭐ Featured',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
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
          ),
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.storefront_outlined,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${brand.name} products go here',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PRODUCT LIST SCREEN
// ═══════════════════════════════════════════════════════════════

class ProductListScreen extends StatelessWidget {
  final CategoryModel category;
  const ProductListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1A1A1A),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                category.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${category.productCount} products in ${category.name}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF555555),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Product list UI goes here',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ENTRY POINT
// ═══════════════════════════════════════════════════════════════

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CategoriesScreen(),
      title: 'Categories',
    ),
  );
}
