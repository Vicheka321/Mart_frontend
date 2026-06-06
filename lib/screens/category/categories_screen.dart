// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter/services.dart';

// import '../../services/api_service.dart';
// import '../../translations/catalog_translation.dart';
// import '../brand/product_by_brand.dart';
// import 'product_by_category.dart';
// import '../search/search_screen.dart';
// import '../theme/app_theme.dart';

// // ═══════════════════════════════════════════════════════════════
// // MODELS
// // ═══════════════════════════════════════════════════════════════

// class CategoryModel {
//   final String id;
//   final String name;
//   final String imageUrl;
//   final String filter;
//   final int productCount;

//   const CategoryModel({
//     required this.id,
//     required this.name,
//     required this.imageUrl,
//     required this.filter,
//     required this.productCount,
//   });
// }

// class BrandModel {
//   final String id;
//   final String name;
//   final String logoUrl;
//   final int productCount;
//   final bool isFeatured;
//   final Color accentColor;

//   const BrandModel({
//     required this.id,
//     required this.name,
//     required this.logoUrl,
//     required this.productCount,
//     this.isFeatured = false,
//     required this.accentColor,
//   });
// }

// class SearchSuggestion {
//   final String text;
//   final bool isProduct;

//   const SearchSuggestion({required this.text, required this.isProduct});
// }
// // ═══════════════════════════════════════════════════════════════
// // MAIN CATEGORIES SCREEN
// // ═══════════════════════════════════════════════════════════════

// class CategoriesScreen extends StatefulWidget {
//   const CategoriesScreen({super.key});

//   @override
//   State<CategoriesScreen> createState() => _CategoriesScreenState();
// }

// class _CategoriesScreenState extends State<CategoriesScreen>
//     with TickerProviderStateMixin {
//   final TextEditingController _searchController = TextEditingController();
//   final FocusNode _searchFocus = FocusNode();

//   List<SearchSuggestion> _suggestions = [];
//   Timer? _debounce;

//   bool _isLoading = true;
//   bool _hasError = false;
//   List<CategoryModel> _categories = [];
//   List<BrandModel> _brands = [];

//   final ScrollController _scrollController = ScrollController();

//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;
//   late AnimationController _brandsAnimController;

//   @override
//   void initState() {
//     super.initState();

//     _fadeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeOut,
//     );

//     _brandsAnimController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );

//     _loadData();
//   }

//   Future<void> _loadData() async {
//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//     });

//     try {
//       final api = ApiService();

//       final brandsRes = await api.fetchBrands();
//       final categoriesRes = await api.fetchCategories();

//       if (!mounted) return;

//       setState(() {
//         // 🔥 map API → UI model
//         _brands = brandsRes
//             .map(
//               (b) => BrandModel(
//                 id: b.id.toString(),
//                 name: b.name,
//                 logoUrl: b.image ?? '',
//                 productCount: 0,
//                 isFeatured: false,
//                 accentColor: Colors.orange,
//               ),
//             )
//             .toList();

//         _categories = categoriesRes
//             .map(
//               (c) => CategoryModel(
//                 id: c.id.toString(),
//                 name: c.name,
//                 imageUrl: c.image,
//                 filter: '',
//                 productCount: 0,
//               ),
//             )
//             .toList();

//         _isLoading = false;
//         _hasError = false;
//       });

//       _fadeController.forward();
//       _brandsAnimController.forward();
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _isLoading = false;
//         _hasError = true;
//       });
//       debugPrint("API ERROR: $e");
//     }
//   }

//   List<CategoryModel> get _filteredCategories {
//     final q = _searchController.text.trim().toLowerCase();
//     if (q.isEmpty) return _categories;
//     return _categories.where((c) {
//       return c.name.toLowerCase().contains(q);
//     }).toList();
//   }

//   void _clearSearch() {
//     _searchController.clear();
//     _searchFocus.unfocus();
//     setState(() => _suggestions = []);
//   }

//   void _applySuggestion(String text) {
//     _searchController.text = text;
//     _searchController.selection = TextSelection.fromPosition(
//       TextPosition(offset: text.length),
//     );
//     _searchFocus.unfocus();
//     setState(() => _suggestions = []);
//   }

//   void _navigateToProducts(CategoryModel category) {
//     HapticFeedback.lightImpact();

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => CategoryProductsScreen(
//           categoryId: int.parse(category.id),
//           categoryName: category.name,
//         ),
//       ),
//     );
//   }

//   void _navigateToBrand(BrandModel brand) {
//     HapticFeedback.lightImpact();
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => BrandProductsScreen(
//           brandId: int.parse(brand.id),
//           brandName: brand.name,
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _searchFocus.dispose();
//     _debounce?.cancel();
//     _scrollController.dispose();
//     _fadeController.dispose();
//     _brandsAnimController.dispose();
//     super.dispose();
//   }

//   // ═══════════════════════════════════════════════════════════════
//   // BUILD
//   // ═══════════════════════════════════════════════════════════════

//   @override
//   Widget build(BuildContext context) {
//     final filteredCats = _filteredCategories;

//     return Scaffold(
//       extendBody: true,
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: SafeArea(
//         bottom: false,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── 1. Header ──────────────────────────────────────
//             const _Header(),

//             // ── 2. Search Bar ──────────────────────────────────
//             _SearchBar(context),

//             // ── 3. Suggestions OR Main Content ─────────────────
//             if (_suggestions.isNotEmpty)
//               _SuggestionList(
//                 suggestions: _suggestions,
//                 onSelect: _applySuggestion,
//               )
//             else ...[
//               const SizedBox(height: 10),
//               Expanded(
//                 child: _isLoading
//                     ? const _SkeletonScroll()
//                     : _hasError
//                     ? _ErrorState(onRetry: _loadData)
//                     : _MainScroll(
//                         fadeAnimation: _fadeAnimation,
//                         brandsAnimController: _brandsAnimController,
//                         brands: _brands,
//                         filteredCategories: filteredCats,
//                         onNavigateToBrand: _navigateToBrand,
//                         onNavigateToProducts: _navigateToProducts,
//                         onClearSearch: _clearSearch,
//                       ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// Widget _SearchBar(BuildContext context) {
//   return Padding(
//     padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
//     child: GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const SearchScreen()),
//         );
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//         decoration: BoxDecoration(
//           color: Colors.transparent,
//           borderRadius: BorderRadius.circular(18),
//         ),
//         child: Row(
//           children: [
//             const Icon(Icons.search, color: Colors.grey),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 'search_categories_brands_products'.tr,
//                 style: TextStyle(color: Colors.grey[500], fontSize: 14),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }
// // ═══════════════════════════════════════════════════════════════
// // 1. HEADER
// // ═══════════════════════════════════════════════════════════════

// class _Header extends StatelessWidget {
//   const _Header();

//   @override
//   Widget build(BuildContext context) {
//     return const Padding(
//       padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
//       child: Row(mainAxisAlignment: MainAxisAlignment.center, children: []),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // 3. SUGGESTION LIST
// // ═══════════════════════════════════════════════════════════════

// class _SuggestionList extends StatelessWidget {
//   final List<SearchSuggestion> suggestions;
//   final ValueChanged<String> onSelect;

//   const _SuggestionList({required this.suggestions, required this.onSelect});

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;

//     return Container(
//       margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
//       decoration: BoxDecoration(
//         color: colors.cardBg,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: Column(
//           children: suggestions.asMap().entries.map((e) {
//             final index = e.key;
//             final suggestion = e.value;
//             return InkWell(
//               onTap: () => onSelect(suggestion.text),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 13,
//                 ),
//                 decoration: BoxDecoration(
//                   border: index < suggestions.length - 1
//                       ? Border(bottom: BorderSide(color: colors.border))
//                       : null,
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 32,
//                       height: 32,
//                       decoration: BoxDecoration(
//                         color: suggestion.isProduct
//                             ? const Color(0xFFFFF0EB)
//                             : const Color(0xFFE8F5E9),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Icon(
//                         suggestion.isProduct
//                             ? Icons.shopping_bag_outlined
//                             : Icons.category_outlined,
//                         size: 16,
//                         color: suggestion.isProduct
//                             ? const Color(0xFFFF6B35)
//                             : const Color(0xFF4CAF50),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           suggestion.text,
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color: colors.text1,
//                           ),
//                         ),
//                         Text(
//                           suggestion.isProduct
//                               ? 'product'.tr
//                               : 'category_brand'.tr,
//                           style: TextStyle(fontSize: 11, color: colors.text2),
//                         ),
//                       ],
//                     ),
//                     const Spacer(),
//                     Icon(
//                       Icons.north_west_rounded,
//                       size: 14,
//                       color: colors.text3,
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // 4. MAIN SCROLL
// // ═══════════════════════════════════════════════════════════════

// class _MainScroll extends StatelessWidget {
//   final Animation<double> fadeAnimation;
//   final AnimationController brandsAnimController;
//   final List<BrandModel> brands;
//   final List<CategoryModel> filteredCategories;
//   final ValueChanged<BrandModel> onNavigateToBrand;
//   final ValueChanged<CategoryModel> onNavigateToProducts;
//   final VoidCallback onClearSearch;

//   const _MainScroll({
//     required this.fadeAnimation,
//     required this.brandsAnimController,
//     required this.brands,
//     required this.filteredCategories,
//     required this.onNavigateToBrand,
//     required this.onNavigateToProducts,
//     required this.onClearSearch,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;

//     return FadeTransition(
//       opacity: fadeAnimation,
//       child: CustomScrollView(
//         slivers: [
//           // ── Brands ──────────────────────────────────────────
//           SliverToBoxAdapter(
//             child: _BrandsHeader(
//               onTap: brands.isEmpty
//                   ? null
//                   : () => _showBrandsBottomSheet(
//                       context,
//                       brands,
//                       onNavigateToBrand,
//                     ),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: _FeaturedBrandCard(
//               brands: brands,
//               brandsAnimController: brandsAnimController,
//               onTap: onNavigateToBrand,
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: _BrandsRow(
//               brands: brands,
//               brandsAnimController: brandsAnimController,
//               onTap: onNavigateToBrand,
//             ),
//           ),

//           // ── Categories Header ────────────────────────────────
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'all_categories'.tr,
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                       color: colors.text1,
//                       letterSpacing: -0.3,
//                     ),
//                   ),
//                   Text(
//                     '${filteredCategories.length} ${'found'.tr}',
//                     style: TextStyle(fontSize: 13, color: colors.text2),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // ── Category Grid ────────────────────────────────────
//           if (filteredCategories.isEmpty)
//             SliverFillRemaining(child: _EmptyState(onClear: onClearSearch))
//           else
//             SliverPadding(
//               padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
//               sliver: SliverGrid(
//                 delegate: SliverChildBuilderDelegate(
//                   (_, index) => _CategoryCard(
//                     category: filteredCategories[index],
//                     index: index,
//                     onTap: () =>
//                         onNavigateToProducts(filteredCategories[index]),
//                   ),
//                   childCount: filteredCategories.length,
//                 ),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 14,
//                   mainAxisSpacing: 14,
//                   childAspectRatio: 0.82,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // 5. BRANDS HEADER
// // ═══════════════════════════════════════════════════════════════

// class _BrandsHeader extends StatelessWidget {
//   final VoidCallback? onTap;

//   const _BrandsHeader({this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;

//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Text(
//                 'brands'.tr,
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w800,
//                   color: colors.text1,
//                   letterSpacing: -0.3,
//                 ),
//               ),
//             ],
//           ),
//           if (onTap != null)
//             GestureDetector(
//               onTap: onTap,
//               child: Text(
//                 'see_all'.tr,
//                 style: const TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFFFF6B35),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// void _showBrandsBottomSheet(
//   BuildContext context,
//   List<BrandModel> brands,
//   ValueChanged<BrandModel> onSelect,
// ) {
//   final colors = context.colors;

//   showModalBottomSheet(
//     context: context,
//     backgroundColor: colors.cardBg,
//     isScrollControlled: true,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//     ),
//     builder: (sheetContext) {
//       return SafeArea(
//         child: SizedBox(
//           height: MediaQuery.of(sheetContext).size.height * 0.72,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(20, 18, 12, 10),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         'brands'.tr,
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w800,
//                           color: colors.text1,
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () => Navigator.pop(sheetContext),
//                       icon: Icon(Icons.close_rounded, color: colors.text1),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: GridView.builder(
//                   padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
//                   itemCount: brands.length,
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     mainAxisSpacing: 12,
//                     crossAxisSpacing: 12,
//                     childAspectRatio: 1.35,
//                   ),
//                   itemBuilder: (context, index) {
//                     final brand = brands[index];

//                     return GestureDetector(
//                       onTap: () {
//                         Navigator.pop(sheetContext);
//                         onSelect(brand);
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.all(14),
//                         decoration: BoxDecoration(
//                           color: colors.surface,
//                           borderRadius: BorderRadius.circular(18),
//                           border: Border.all(color: colors.border),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               child: Align(
//                                 alignment: Alignment.centerLeft,
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(12),
//                                   child: Image.network(
//                                     brand.logoUrl,
//                                     width: 48,
//                                     height: 48,
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (_, __, ___) => Container(
//                                       width: 48,
//                                       height: 48,
//                                       alignment: Alignment.center,
//                                       decoration: BoxDecoration(
//                                         color: colors.accentLight,
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       child: Text(
//                                         brand.name.isEmpty
//                                             ? '?'
//                                             : brand.name[0].toUpperCase(),
//                                         style: TextStyle(
//                                           color: colors.accent,
//                                           fontWeight: FontWeight.w800,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               brand.name.trCatalog,
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                 color: colors.text1,
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }

// // ═══════════════════════════════════════════════════════════════
// // 6. FEATURED BRAND CARD
// // ═══════════════════════════════════════════════════════════════

// class _FeaturedBrandCard extends StatelessWidget {
//   final List<BrandModel> brands;
//   final AnimationController brandsAnimController;
//   final ValueChanged<BrandModel> onTap;

//   const _FeaturedBrandCard({
//     required this.brands,
//     required this.brandsAnimController,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final featured = brands.where((b) => b.isFeatured).take(1).firstOrNull;
//     if (featured == null) return const SizedBox.shrink();

//     return SlideTransition(
//       position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
//           .animate(
//             CurvedAnimation(
//               parent: brandsAnimController,
//               curve: Curves.easeOutCubic,
//             ),
//           ),
//       child: FadeTransition(
//         opacity: brandsAnimController,
//         child: GestureDetector(
//           onTap: () => onTap(featured),
//           child: Container(
//             margin: const EdgeInsets.symmetric(horizontal: 20),
//             height: 150,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(22),
//               gradient: LinearGradient(
//                 colors: [
//                   featured.accentColor,
//                   featured.accentColor.withOpacity(0.7),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: featured.accentColor.withOpacity(0.4),
//                   blurRadius: 20,
//                   offset: const Offset(0, 8),
//                 ),
//               ],
//             ),
//             child: Stack(
//               children: [
//                 // Background image
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(22),
//                   child: Opacity(
//                     opacity: 0.25,
//                     child: Image.network(
//                       featured.logoUrl,
//                       width: double.infinity,
//                       height: double.infinity,
//                       fit: BoxFit.cover,
//                       errorBuilder: (_, __, ___) => const SizedBox(),
//                     ),
//                   ),
//                 ),
//                 // Decorative circles
//                 Positioned(
//                   right: -20,
//                   top: -20,
//                   child: Container(
//                     width: 120,
//                     height: 120,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.white.withOpacity(0.08),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   right: 20,
//                   bottom: -30,
//                   child: Container(
//                     width: 90,
//                     height: 90,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.white.withOpacity(0.06),
//                     ),
//                   ),
//                 ),
//                 // Content
//                 Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 72,
//                         height: 72,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           shape: BoxShape.circle,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.15),
//                               blurRadius: 12,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: ClipOval(
//                           child: Image.network(
//                             featured.logoUrl,
//                             fit: BoxFit.cover,
//                             errorBuilder: (_, __, ___) => Center(
//                               child: Text(
//                                 featured.name[0],
//                                 style: TextStyle(
//                                   fontSize: 28,
//                                   fontWeight: FontWeight.w800,
//                                   color: featured.accentColor,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                                 vertical: 3,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.2),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: const Text(
//                                 '⭐ Featured Brand',
//                                 style: TextStyle(
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.w700,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               featured.name.trCatalog,
//                               style: const TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.w800,
//                                 color: Colors.white,
//                                 letterSpacing: -0.5,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               '${featured.productCount} products available',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.white.withOpacity(0.8),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Container(
//                         width: 36,
//                         height: 36,
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(
//                           Icons.arrow_forward_ios_rounded,
//                           color: Colors.white,
//                           size: 16,
//                         ),
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

// // ═══════════════════════════════════════════════════════════════
// // 7. BRANDS ROW
// // ═══════════════════════════════════════════════════════════════

// class _BrandsRow extends StatelessWidget {
//   final List<BrandModel> brands;
//   final AnimationController brandsAnimController;
//   final ValueChanged<BrandModel> onTap;

//   const _BrandsRow({
//     required this.brands,
//     required this.brandsAnimController,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final otherBrands = brands.where((b) => !b.isFeatured).toList();

//     return Column(
//       children: [
//         const SizedBox(height: 14),
//         SizedBox(
//           height: 108,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             itemCount: otherBrands.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 12),
//             itemBuilder: (_, index) {
//               final delay = (index * 80).clamp(0, 400);
//               return AnimatedBuilder(
//                 animation: brandsAnimController,
//                 builder: (_, child) {
//                   final progress = Curves.easeOutCubic.transform(
//                     (brandsAnimController.value - delay / 1000).clamp(0.0, 1.0),
//                   );
//                   return Opacity(
//                     opacity: progress,
//                     child: Transform.translate(
//                       offset: Offset(0, 20 * (1 - progress)),
//                       child: child,
//                     ),
//                   );
//                 },
//                 child: _BrandCard(
//                   brand: otherBrands[index],
//                   onTap: () => onTap(otherBrands[index]),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // 8. EMPTY STATE
// // ═══════════════════════════════════════════════════════════════

// class _EmptyState extends StatelessWidget {
//   final VoidCallback onClear;

//   const _EmptyState({required this.onClear});

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;

//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 90,
//             height: 90,
//             decoration: BoxDecoration(
//               color: const Color(0xFFFF6B35).withOpacity(0.08),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.search_off_rounded,
//               size: 40,
//               color: Color(0xFFFF6B35),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'no_products_found'.tr,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//               color: colors.text1,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'try_adjusting_search'.tr,
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 14, color: colors.text2, height: 1.5),
//           ),
//           const SizedBox(height: 24),
//           GestureDetector(
//             onTap: onClear,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFFF6B35),
//                 borderRadius: BorderRadius.circular(14),
//                 boxShadow: [
//                   BoxShadow(
//                     color: const Color(0xFFFF6B35).withOpacity(0.35),
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Text(
//                 'clear_filters'.tr,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // 9. ERROR STATE
// // ═══════════════════════════════════════════════════════════════

// class _ErrorState extends StatelessWidget {
//   final VoidCallback onRetry;
//   const _ErrorState({required this.onRetry});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey[400]),
//             const SizedBox(height: 16),
//             Text(
//               'Connection failed',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: Theme.of(context).textTheme.bodyLarge?.color,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Could not load categories. Please check your connection and try again.',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 14, color: Colors.grey[500]),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: onRetry,
//               icon: const Icon(Icons.refresh_rounded, size: 18),
//               label: const Text('Retry'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black87,
//                 foregroundColor: Colors.white,
//                 elevation: 0,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 24,
//                   vertical: 12,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // 10. SKELETON SCROLL
// // ═══════════════════════════════════════════════════════════════

// class _SkeletonScroll extends StatelessWidget {
//   const _SkeletonScroll();

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           const SizedBox(height: 16),
//           const _SkeletonBox(
//             width: double.infinity,
//             height: 150,
//             margin: EdgeInsets.symmetric(horizontal: 20),
//             radius: 22,
//           ),
//           const SizedBox(height: 14),
//           SizedBox(
//             height: 108,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               itemCount: 5,
//               itemBuilder: (_, __) => const Padding(
//                 padding: EdgeInsets.only(right: 12),
//                 child: _SkeletonBrandCard(),
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: 14,
//               mainAxisSpacing: 14,
//               childAspectRatio: 0.82,
//             ),
//             itemCount: 6,
//             itemBuilder: (_, __) => const _SkeletonCard(),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // BRAND CARD (Small horizontal)
// // ═══════════════════════════════════════════════════════════════

// class _BrandCard extends StatefulWidget {
//   final BrandModel brand;
//   final VoidCallback onTap;

//   const _BrandCard({required this.brand, required this.onTap});

//   @override
//   State<_BrandCard> createState() => _BrandCardState();
// }

// class _BrandCardState extends State<_BrandCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _press;

//   @override
//   void initState() {
//     super.initState();
//     _press = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 100),
//       reverseDuration: const Duration(milliseconds: 180),
//     );
//   }

//   @override
//   void dispose() {
//     _press.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final b = widget.brand;
//     final colors = context.colors;

//     return GestureDetector(
//       onTapDown: (_) => _press.forward(),
//       onTapUp: (_) async {
//         await _press.reverse();
//         widget.onTap();
//       },
//       onTapCancel: () => _press.reverse(),
//       child: AnimatedBuilder(
//         animation: _press,
//         builder: (_, child) =>
//             Transform.scale(scale: 1.0 - (_press.value * 0.04), child: child),
//         child: Container(
//           width: 88,
//           decoration: BoxDecoration(
//             color: colors.cardBg,
//             borderRadius: BorderRadius.circular(18),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.06),
//                 blurRadius: 12,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 52,
//                 height: 52,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: b.accentColor.withOpacity(0.1),
//                   border: Border.all(
//                     color: b.accentColor.withOpacity(0.2),
//                     width: 1.5,
//                   ),
//                 ),
//                 child: ClipOval(
//                   child: Image.network(
//                     b.logoUrl,
//                     fit: BoxFit.cover,
//                     errorBuilder: (_, __, ___) => Center(
//                       child: Text(
//                         b.name[0],
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.w800,
//                           color: b.accentColor,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 b.name.trCatalog,
//                 style: TextStyle(
//                   fontSize: 11,
//                   fontWeight: FontWeight.w700,
//                   color: colors.text1,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//               // Text(
//               //   '${b.productCount} items',
//               //   style: TextStyle(fontSize: 9, color: colors.text2),
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // CATEGORY CARD
// // ═══════════════════════════════════════════════════════════════

// class _CategoryCard extends StatefulWidget {
//   final CategoryModel category;
//   final int index;
//   final VoidCallback onTap;

//   const _CategoryCard({
//     required this.category,
//     required this.index,
//     required this.onTap,
//   });

//   @override
//   State<_CategoryCard> createState() => _CategoryCardState();
// }

// class _CategoryCardState extends State<_CategoryCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _pressController;
//   late Animation<double> _scaleAnim;

//   @override
//   void initState() {
//     super.initState();
//     _pressController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 120),
//       reverseDuration: const Duration(milliseconds: 200),
//     );
//     _scaleAnim = Tween<double>(
//       begin: 1.0,
//       end: 0.95,
//     ).animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut));
//   }

//   @override
//   void dispose() {
//     _pressController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapDown: (_) => _pressController.forward(),
//       onTapUp: (_) async {
//         await _pressController.reverse();
//         widget.onTap();
//       },
//       onTapCancel: () => _pressController.reverse(),
//       child: ScaleTransition(
//         scale: _scaleAnim,
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.10),
//                 blurRadius: 16,
//                 offset: const Offset(0, 6),
//               ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(20),
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 Image.network(
//                   widget.category.imageUrl,
//                   fit: BoxFit.cover,
//                   loadingBuilder: (_, child, progress) {
//                     if (progress == null) return child;
//                     return Container(color: Colors.grey.shade200);
//                   },
//                   errorBuilder: (_, __, ___) =>
//                       Container(color: Colors.grey.shade200),
//                 ),
//                 const DecoratedBox(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                         Colors.transparent,
//                         Color(0x26000000),
//                         Color(0xB8000000),
//                       ],
//                       stops: [0.35, 0.6, 1.0],
//                     ),
//                   ),
//                 ),

//                 Positioned(
//                   left: 12,
//                   right: 12,
//                   bottom: 12,
//                   child: Text(
//                     widget.category.name,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w800,
//                       color: Colors.white,
//                       letterSpacing: -0.3,
//                       shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
//                     ),
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

// // ═══════════════════════════════════════════════════════════════
// // SKELETON WIDGETS
// // ═══════════════════════════════════════════════════════════════

// class _SkeletonCard extends StatefulWidget {
//   const _SkeletonCard();

//   @override
//   State<_SkeletonCard> createState() => _SkeletonCardState();
// }

// class _SkeletonCardState extends State<_SkeletonCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
//   late Animation<double> _anim;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     )..repeat(reverse: true);
//     _anim = Tween<double>(
//       begin: 0.3,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _anim,
//       builder: (_, __) => Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color.lerp(
//                 const Color(0xFFE8E4DF),
//                 const Color(0xFFF5F2EE),
//                 _anim.value,
//               )!,
//               Color.lerp(
//                 const Color(0xFFF5F2EE),
//                 const Color(0xFFE8E4DF),
//                 _anim.value,
//               )!,
//             ],
//           ),
//         ),
//         child: Stack(
//           children: [
//             Positioned(
//               top: 10,
//               right: 10,
//               child: Container(
//                 width: 55,
//                 height: 20,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.5),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//             Positioned(
//               left: 12,
//               right: 60,
//               bottom: 14,
//               child: Container(
//                 height: 16,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.5),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _SkeletonBrandCard extends StatefulWidget {
//   const _SkeletonBrandCard();

//   @override
//   State<_SkeletonBrandCard> createState() => _SkeletonBrandCardState();
// }

// class _SkeletonBrandCardState extends State<_SkeletonBrandCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
//   late Animation<double> _anim;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1100),
//     )..repeat(reverse: true);
//     _anim = Tween<double>(
//       begin: 0.3,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   Widget _box(double w, double h, {double r = 8}) => AnimatedBuilder(
//     animation: _anim,
//     builder: (_, __) => Container(
//       width: w,
//       height: h,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(r),
//         color: Color.lerp(
//           const Color(0xFFE8E4DF),
//           const Color(0xFFF5F2EE),
//           _anim.value,
//         ),
//       ),
//     ),
//   );

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 88,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           _box(52, 52, r: 26),
//           const SizedBox(height: 6),
//           _box(55, 10),
//           const SizedBox(height: 4),
//           _box(40, 8),
//         ],
//       ),
//     );
//   }
// }

// class _SkeletonBox extends StatefulWidget {
//   final double width;
//   final double height;
//   final EdgeInsets? margin;
//   final double radius;

//   const _SkeletonBox({
//     required this.width,
//     required this.height,
//     this.margin,
//     this.radius = 12,
//   });

//   @override
//   State<_SkeletonBox> createState() => _SkeletonBoxState();
// }

// class _SkeletonBoxState extends State<_SkeletonBox>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
//   late Animation<double> _anim;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1100),
//     )..repeat(reverse: true);
//     _anim = Tween<double>(
//       begin: 0.3,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _anim,
//       builder: (_, __) => Container(
//         width: widget.width,
//         height: widget.height,
//         margin: widget.margin,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(widget.radius),
//           gradient: LinearGradient(
//             colors: [
//               Color.lerp(
//                 const Color(0xFFE8E4DF),
//                 const Color(0xFFF5F2EE),
//                 _anim.value,
//               )!,
//               Color.lerp(
//                 const Color(0xFFF5F2EE),
//                 const Color(0xFFE8E4DF),
//                 _anim.value,
//               )!,
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // BRAND SCREEN
// // ═══════════════════════════════════════════════════════════════

// class BrandScreen extends StatelessWidget {
//   final BrandModel brand;
//   const BrandScreen({super.key, required this.brand});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F5F0),
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             expandedHeight: 200,
//             pinned: true,
//             backgroundColor: brand.accentColor,
//             leading: GestureDetector(
//               onTap: () => Navigator.pop(context),
//               child: Container(
//                 margin: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.arrow_back_ios_new_rounded,
//                   color: Colors.white,
//                   size: 18,
//                 ),
//               ),
//             ),
//             flexibleSpace: FlexibleSpaceBar(
//               background: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   DecoratedBox(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           brand.accentColor,
//                           brand.accentColor.withOpacity(0.7),
//                         ],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     right: -30,
//                     top: -30,
//                     child: Container(
//                       width: 160,
//                       height: 160,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.white.withOpacity(0.07),
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 80,
//                           height: 80,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.15),
//                                 blurRadius: 16,
//                               ),
//                             ],
//                           ),
//                           child: ClipOval(
//                             child: Image.network(
//                               brand.logoUrl,
//                               fit: BoxFit.cover,
//                               errorBuilder: (_, __, ___) => Center(
//                                 child: Text(
//                                   brand.name[0],
//                                   style: TextStyle(
//                                     fontSize: 32,
//                                     fontWeight: FontWeight.w800,
//                                     color: brand.accentColor,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               brand.name.trCatalog,
//                               style: const TextStyle(
//                                 fontSize: 26,
//                                 fontWeight: FontWeight.w800,
//                                 color: Colors.white,
//                                 letterSpacing: -0.5,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               '${brand.productCount} products',
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 color: Colors.white.withOpacity(0.8),
//                               ),
//                             ),
//                             if (brand.isFeatured)
//                               Container(
//                                 margin: const EdgeInsets.only(top: 6),
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 8,
//                                   vertical: 3,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.2),
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: const Text(
//                                   '⭐ Featured',
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.w700,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(40),
//                 child: Column(
//                   children: [
//                     Icon(
//                       Icons.storefront_outlined,
//                       size: 48,
//                       color: Colors.grey.shade300,
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       '${brand.name} products go here',
//                       style: TextStyle(
//                         fontSize: 15,
//                         color: Colors.grey.shade500,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // PRODUCT LIST SCREEN
// // ═══════════════════════════════════════════════════════════════

// class ProductListScreen extends StatelessWidget {
//   final CategoryModel category;
//   const ProductListScreen({super.key, required this.category});

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;

//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back_ios_new_rounded,
//             color: colors.text1,
//             size: 20,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           category.name,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w800,
//             color: colors.text1,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(20),
//               child: Image.network(
//                 category.imageUrl,
//                 width: 80,
//                 height: 80,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               '${category.productCount} products in ${category.name}',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: colors.text2,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Product list UI goes here',
//               style: TextStyle(fontSize: 13, color: colors.text3),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // ENTRY POINT
// // ═══════════════════════════════════════════════════════════════

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:mart_frontend/models/brands_with_products.dart' as brand_model;
// import 'package:mart_frontend/models/categories_with_products_model.dart'
//     as cat_model;
// import 'package:mart_frontend/screens/product/product_detail_screen.dart';
// import 'package:mart_frontend/screens/theme/app_theme.dart';
// import '../../services/api_service.dart';

// // ═══════════════════════════════════════════════════════════════
// // EXTENSION — replaces all hardcoded colors with context.colors.*
// //
// // HOW TO WIRE THIS UP:
// //   If your project already has an AppColors extension on BuildContext,
// //   delete this block and import your own extension instead.
// //   This extension mirrors your existing AppColors interface exactly
// //   so the rest of the file needs zero changes.
// // ═══════════════════════════════════════════════════════════════

// // ═══════════════════════════════════════════════════════════════
// // CONSTANTS — layout only (no colors)
// // ═══════════════════════════════════════════════════════════════

// const double _kSidebarWidth = 96;
// const double _kSidebarItemH = 80;
// const double _kProductImageSz = 66;
// const double _kScrollThreshold =
//     120; // px from top to consider a section "active"

// // ═══════════════════════════════════════════════════════════════
// // SCREEN
// // ═══════════════════════════════════════════════════════════════

// class CategoryBrandScreen extends StatefulWidget {
//   const CategoryBrandScreen({super.key});

//   @override
//   State<CategoryBrandScreen> createState() => _CategoryBrandScreenState();
// }

// class _CategoryBrandScreenState extends State<CategoryBrandScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final ApiService _api = ApiService();

//   bool _loadingCats = true;
//   bool _loadingBrands = true;
//   bool _errorCats = false;
//   bool _errorBrands = false;

//   List<cat_model.CategoriesWithProductsModel> _categories = [];
//   List<brand_model.BrandsWithProductsModel> _brands = [];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _loadCategories();
//     _loadBrands();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadCategories() async {
//     setState(() {
//       _loadingCats = true;
//       _errorCats = false;
//     });
//     try {
//       final data = await _api.fetchCategoriesWithProducts();
//       if (!mounted) return;
//       setState(() {
//         _categories = data;
//         _loadingCats = false;
//       });
//     } catch (_) {
//       if (!mounted) return;
//       setState(() {
//         _loadingCats = false;
//         _errorCats = true;
//       });
//     }
//   }

//   Future<void> _loadBrands() async {
//     setState(() {
//       _loadingBrands = true;
//       _errorBrands = false;
//     });
//     try {
//       final data = await _api.fetchBrandsWithProducts();
//       if (!mounted) return;
//       setState(() {
//         _brands = data;
//         _loadingBrands = false;
//       });
//     } catch (_) {
//       if (!mounted) return;
//       setState(() {
//         _loadingBrands = false;
//         _errorBrands = true;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: context.colors.background,
//       appBar: _AppBar(onSearch: _openSearch),
//       body: Column(
//         children: [
//           _TabBar(controller: _tabController),
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               physics: const NeverScrollableScrollPhysics(),
//               children: [
//                 // Products tab
//                 _loadingCats
//                     ? const _SkeletonSplitView()
//                     : _errorCats
//                     ? _ErrorState(onRetry: _loadCategories)
//                     : _categories.isEmpty
//                     ? const _EmptyState(message: 'No categories found')
//                     : _CategoriesTab(categories: _categories),

//                 // Brands tab
//                 _loadingBrands
//                     ? const _BrandSkeleton()
//                     : _errorBrands
//                     ? _ErrorState(onRetry: _loadBrands)
//                     : _brands.isEmpty
//                     ? const _EmptyState(message: 'No brands found')
//                     : _BrandsTab(brands: _brands),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _openSearch() {
//     // Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // APP BAR
// // ═══════════════════════════════════════════════════════════════

// class _AppBar extends StatelessWidget implements PreferredSizeWidget {
//   final VoidCallback onSearch;
//   const _AppBar({required this.onSearch});

//   @override
//   Size get preferredSize => const Size.fromHeight(52);

//   @override
//   Widget build(BuildContext context) {
//     final c = context.colors;
//     return AppBar(
//       backgroundColor: c.background,
//       elevation: 0,
//       centerTitle: true,
//       title: Text(
//         'Category',
//         style: TextStyle(
//           fontSize: 17,
//           fontWeight: FontWeight.w600,
//           color: c.text1,
//         ),
//       ),
//       actions: [
//         GestureDetector(
//           onTap: onSearch,
//           child: Container(
//             margin: const EdgeInsets.only(right: 14),
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: c.surface2,
//               border: Border.all(color: c.border, width: 0.5),
//             ),
//             child: Icon(Icons.search_rounded, size: 18, color: c.text2),
//           ),
//         ),
//       ],
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(0.5),
//         child: Container(height: 0.5, color: c.border),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // TAB BAR
// // ═══════════════════════════════════════════════════════════════

// class _TabBar extends StatelessWidget {
//   final TabController controller;
//   const _TabBar({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     final c = context.colors;
//     return Container(
//       decoration: BoxDecoration(
//         border: Border(bottom: BorderSide(color: c.border, width: 0.5)),
//       ),
//       child: TabBar(
//         controller: controller,
//         indicatorColor: c.accent,
//         indicatorWeight: 2,
//         labelColor: c.accent,
//         unselectedLabelColor: c.text3,
//         labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//         unselectedLabelStyle: const TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.w400,
//         ),
//         tabs: const [
//           Tab(text: 'Products'),
//           Tab(text: 'Brand'),
//         ],
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // SCROLL SYNC MIXIN
// //
// // Shared logic for both CategoriesTab and BrandsTab.
// // Pre-calculates section offsets so animateTo() is reliable even
// // with 100+ categories, replacing the flaky Scrollable.ensureVisible.
// // ═══════════════════════════════════════════════════════════════

// mixin _ScrollSyncMixin<T extends StatefulWidget> on State<T> {
//   // ── abstract API ────────────────────────────────────────────
//   int get itemCount;
//   double sectionHeight(int index); // full pixel height of section[index]

//   // ── controllers ─────────────────────────────────────────────
//   final ScrollController sidebarCtrl = ScrollController();
//   final ScrollController contentCtrl = ScrollController();

//   // ── state ───────────────────────────────────────────────────
//   int activeIndex = 0;
//   bool _programmatic = false;
//   Timer? _lockTimer;

//   // ── precomputed offsets ─────────────────────────────────────
//   // offsets[i] = total scroll distance to reach section i's top
//   List<double> _offsets = [];

//   void buildOffsets() {
//     _offsets = List.generate(itemCount, (i) {
//       double sum = 0;
//       for (int j = 0; j < i; j++) sum += sectionHeight(j);
//       return sum;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       buildOffsets();
//       contentCtrl.addListener(_onContentScroll);
//     });
//   }

//   @override
//   void dispose() {
//     sidebarCtrl.dispose();
//     contentCtrl.dispose();
//     _lockTimer?.cancel();
//     super.dispose();
//   }

//   // ── content scroll → update sidebar ─────────────────────────
//   void _onContentScroll() {
//     if (_programmatic) return;
//     final scrollTop = contentCtrl.offset;

//     // Find last section whose offset is ≤ scrollTop + threshold
//     int found = 0;
//     for (int i = 0; i < _offsets.length; i++) {
//       if (_offsets[i] <= scrollTop + _kScrollThreshold) found = i;
//     }

//     if ((found - activeIndex).abs() >= 1) {
//       setState(() {
//         activeIndex = found;
//       });
//     }
//   }

//   // ── sidebar → smooth scroll content ─────────────────────────
//   void onSidebarTap(int index) {
//     if (index == activeIndex) return;
//     HapticFeedback.lightImpact();
//     setState(() => activeIndex = index);
//     _scrollSidebar(index);

//     _programmatic = true;
//     _lockTimer?.cancel();

//     if (_offsets.isEmpty) buildOffsets();
//     final target = _offsets.isNotEmpty
//         ? _offsets[index].clamp(0.0, contentCtrl.position.maxScrollExtent)
//         : 0.0;

//     contentCtrl.animateTo(
//       target,
//       duration: const Duration(milliseconds: 700),
//       curve: Curves.easeOutCubic,
//     );

//     // Release lock slightly after animation ends so fast taps still work
//     _lockTimer = Timer(const Duration(milliseconds: 800), () {
//       _programmatic = false;
//     });
//   }

//   // ── keep active sidebar item visible ────────────────────────
//   void _scrollSidebar(int index) {
//     if (!sidebarCtrl.hasClients) return;
//     final center = _kSidebarItemH * index + _kSidebarItemH / 2;
//     final viewport = sidebarCtrl.position.viewportDimension;
//     final target = (center - viewport / 2).clamp(
//       0.0,
//       sidebarCtrl.position.maxScrollExtent,
//     );
//     sidebarCtrl.animateTo(
//       target,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeOut,
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // CATEGORIES TAB
// // ═══════════════════════════════════════════════════════════════

// class _CategoriesTab extends StatefulWidget {
//   final List<cat_model.CategoriesWithProductsModel> categories;
//   const _CategoriesTab({required this.categories});

//   @override
//   State<_CategoriesTab> createState() => _CategoriesTabState();
// }

// class _CategoriesTabState extends State<_CategoriesTab>
//     with _ScrollSyncMixin<_CategoriesTab> {
//   // ── section height calculation ──────────────────────────────
//   // Header row: 14(top) + 8(bottom) + 20(icon) = ~52px
//   // Each product tile: 10+10 padding + 66px image ≈ 86px
//   // Gap container: 8px
//   static const double _headerH = 52;
//   static const double _tileH = 86;
//   static const double _gapH = 8;

//   @override
//   int get itemCount => widget.categories.length;

//   @override
//   double sectionHeight(int index) {
//     final productCount = widget.categories[index].products.length;
//     return _headerH + (productCount * _tileH) + _gapH;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         // LEFT SIDEBAR
//         _Sidebar(
//           categories: widget.categories,
//           activeIndex: activeIndex,
//           controller: sidebarCtrl,
//           onTap: onSidebarTap,
//         ),
//         Container(width: 0.5, color: context.colors.border),
//         // RIGHT CONTENT
//         Expanded(
//           child: ListView.builder(
//             controller: contentCtrl,
//             itemCount: widget.categories.length,
//             itemBuilder: (_, i) =>
//                 _CategorySection(category: widget.categories[i]),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // SIDEBAR
// // ═══════════════════════════════════════════════════════════════

// class _Sidebar extends StatelessWidget {
//   final List<cat_model.CategoriesWithProductsModel> categories;
//   final int activeIndex;
//   final ScrollController controller;
//   final ValueChanged<int> onTap;

//   const _Sidebar({
//     required this.categories,
//     required this.activeIndex,
//     required this.controller,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: _kSidebarWidth,
//       color: context.colors.surface2,
//       child: ListView.builder(
//         controller: controller,
//         itemCount: categories.length,
//         itemBuilder: (_, i) => _SidebarItem(
//           category: categories[i],
//           isActive: i == activeIndex,
//           onTap: () => onTap(i),
//         ),
//       ),
//     );
//   }
// }

// class _SidebarItem extends StatelessWidget {
//   final cat_model.CategoriesWithProductsModel category;
//   final bool isActive;
//   final VoidCallback onTap;

//   const _SidebarItem({
//     required this.category,
//     required this.isActive,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final c = context.colors;
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOutCubic,
//         height: _kSidebarItemH,
//         decoration: BoxDecoration(
//           color: isActive ? c.background : Colors.transparent,
//           border: Border(
//             left: BorderSide(
//               color: isActive ? c.accent : Colors.transparent,
//               width: 2.5,
//             ),
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(9),
//               child: CachedNetworkImage(
//                 imageUrl: category.image,
//                 width: 38,
//                 height: 38,
//                 fit: BoxFit.cover,
//                 placeholder: (_, __) => _imgPlaceholder(38, context),
//                 errorWidget: (_, __, ___) =>
//                     _imgFallback(category.name, 38, context, radius: 9),
//               ),
//             ),
//             const SizedBox(height: 5),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 5),
//               child: Text(
//                 category.name,
//                 maxLines: 2,
//                 textAlign: TextAlign.center,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   fontSize: 9.5,
//                   height: 1.25,
//                   fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
//                   color: isActive ? c.accent : c.text3,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // CATEGORY SECTION
// // ═══════════════════════════════════════════════════════════════

// class _CategorySection extends StatelessWidget {
//   final cat_model.CategoriesWithProductsModel category;
//   const _CategorySection({required this.category});

//   @override
//   Widget build(BuildContext context) {
//     final c = context.colors;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Header
//         Padding(
//           padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
//           child: Row(
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(5),
//                 child: CachedNetworkImage(
//                   imageUrl: category.image,
//                   width: 20,
//                   height: 20,
//                   fit: BoxFit.cover,
//                   placeholder: (_, __) => _imgPlaceholder(20, context),
//                   errorWidget: (_, __, ___) =>
//                       _imgFallback(category.name, 20, context, radius: 5),
//                 ),
//               ),
//               const SizedBox(width: 7),
//               Expanded(
//                 child: Text(
//                   category.name.toUpperCase(),
//                   style: TextStyle(
//                     fontSize: 12.5,
//                     fontWeight: FontWeight.w800,
//                     letterSpacing: 0.4,
//                     color: c.text1,
//                   ),
//                 ),
//               ),
//               Text(
//                 '${category.products.length}',
//                 style: TextStyle(fontSize: 11, color: c.text3),
//               ),
//             ],
//           ),
//         ),

//         // Products
//         ...category.products.map((p) => _ProductTile(product: p)),

//         // Section gap
//         Container(height: 8, color: c.surface2),
//       ],
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // PRODUCT TILE  — with scale-on-tap + Hero image
// // ═══════════════════════════════════════════════════════════════

// class _ProductTile extends StatefulWidget {
//   final cat_model.Product product;
//   const _ProductTile({required this.product});

//   @override
//   State<_ProductTile> createState() => _ProductTileState();
// }

// class _ProductTileState extends State<_ProductTile>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _scaleCtrl;
//   late Animation<double> _scaleAnim;

//   bool get _inStock => widget.product.status && widget.product.quantity > 0;
//   double get _price => double.tryParse(widget.product.salePrice) ?? 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _scaleCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 120),
//       reverseDuration: const Duration(milliseconds: 200),
//       value: 1.0,
//     );
//     _scaleAnim = Tween<double>(
//       begin: 1.0,
//       end: 0.97,
//     ).animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut));
//   }

//   @override
//   void dispose() {
//     _scaleCtrl.dispose();
//     super.dispose();
//   }

//   void _onTapDown(TapDownDetails _) => _scaleCtrl.forward();
//   void _onTapCancel() => _scaleCtrl.reverse();

//   void _onTap() {
//     HapticFeedback.lightImpact();
//     _scaleCtrl.reverse();
//     Navigator.push(
//       context,
//       _smoothRoute(ProductDetailScreen(productId: widget.product.id)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final c = context.colors;
//     return GestureDetector(
//       onTapDown: _onTapDown,
//       onTapCancel: _onTapCancel,
//       onTap: _onTap,
//       child: ScaleTransition(
//         scale: _scaleAnim,
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//           decoration: BoxDecoration(
//             border: Border(top: BorderSide(color: c.border, width: 0.5)),
//           ),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Info
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       widget.product.name,
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w400,
//                         height: 1.3,
//                         color: c.text1,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     _UnitBadge(unit: widget.product.unit.name.toLowerCase()),
//                     const SizedBox(height: 5),
//                     Row(
//                       children: [
//                         Text(
//                           '\$${_price.toStringAsFixed(2)}',
//                           style: TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w600,
//                             color: c.text1,
//                           ),
//                         ),
//                         const SizedBox(width: 7),
//                         Container(
//                           width: 6,
//                           height: 6,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: _inStock ? c.flashText : c.text3,
//                           ),
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           _inStock
//                               ? 'In stock (${widget.product.quantity})'
//                               : 'Out of stock',
//                           style: TextStyle(
//                             fontSize: 10,
//                             color: _inStock ? c.flashText : c.text3,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 10),
//               // Image with Hero
//               Stack(
//                 children: [
//                   Hero(
//                     tag: 'product-img-${widget.product.id}',
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: CachedNetworkImage(
//                         imageUrl: widget.product.firstImage.imageUrl,
//                         width: _kProductImageSz,
//                         height: _kProductImageSz,
//                         fit: BoxFit.cover,
//                         placeholder: (_, __) =>
//                             _imgPlaceholder(_kProductImageSz, context),
//                         errorWidget: (_, __, ___) => _imgFallback(
//                           widget.product.name,
//                           _kProductImageSz,
//                           context,
//                           radius: 10,
//                         ),
//                       ),
//                     ),
//                   ),
//                   if (!_inStock)
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: Container(
//                         width: _kProductImageSz,
//                         height: _kProductImageSz,
//                         color: c.background.withOpacity(0.5),
//                       ),
//                     ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // BRANDS TAB  — identical scroll-sync pattern via mixin
// // ═══════════════════════════════════════════════════════════════

// class _BrandsTab extends StatefulWidget {
//   final List<brand_model.BrandsWithProductsModel> brands;
//   const _BrandsTab({required this.brands});

//   @override
//   State<_BrandsTab> createState() => _BrandsTabState();
// }

// class _BrandsTabState extends State<_BrandsTab>
//     with _ScrollSyncMixin<_BrandsTab> {
//   static const double _headerH = 52;
//   static const double _tileH = 86;
//   static const double _gapH = 8;

//   @override
//   int get itemCount => widget.brands.length;

//   @override
//   double sectionHeight(int index) {
//     final productCount = widget.brands[index].products.length;
//     return _headerH + (productCount * _tileH) + _gapH;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         _BrandSidebar(
//           brands: widget.brands,
//           activeIndex: activeIndex,
//           controller: sidebarCtrl,
//           onTap: onSidebarTap,
//         ),
//         Container(width: 0.5, color: context.colors.border),
//         Expanded(
//           child: ListView.builder(
//             controller: contentCtrl,
//             itemCount: widget.brands.length,
//             itemBuilder: (_, i) => _BrandSection(brand: widget.brands[i]),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // BRAND SIDEBAR
// // ═══════════════════════════════════════════════════════════════

// class _BrandSidebar extends StatelessWidget {
//   final List<brand_model.BrandsWithProductsModel> brands;
//   final int activeIndex;
//   final ScrollController controller;
//   final ValueChanged<int> onTap;

//   const _BrandSidebar({
//     required this.brands,
//     required this.activeIndex,
//     required this.controller,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: _kSidebarWidth,
//       color: context.colors.surface2,
//       child: ListView.builder(
//         controller: controller,
//         itemCount: brands.length,
//         itemBuilder: (_, i) => _BrandSidebarItem(
//           brand: brands[i],
//           isActive: i == activeIndex,
//           onTap: () => onTap(i),
//         ),
//       ),
//     );
//   }
// }

// class _BrandSidebarItem extends StatelessWidget {
//   final brand_model.BrandsWithProductsModel brand;
//   final bool isActive;
//   final VoidCallback onTap;

//   const _BrandSidebarItem({
//     required this.brand,
//     required this.isActive,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final c = context.colors;
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         curve: Curves.easeOutCubic,
//         height: _kSidebarItemH,
//         decoration: BoxDecoration(
//           color: isActive ? c.background : Colors.transparent,
//           border: Border(
//             left: BorderSide(
//               color: isActive ? c.accent : Colors.transparent,
//               width: 2.5,
//             ),
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ClipOval(
//               child: CachedNetworkImage(
//                 imageUrl: brand.image,
//                 width: 38,
//                 height: 38,
//                 fit: BoxFit.cover,
//                 placeholder: (_, __) => _imgPlaceholder(38, context),
//                 errorWidget: (_, __, ___) =>
//                     _brandInitialCircle(brand.name, 38, context),
//               ),
//             ),
//             const SizedBox(height: 5),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 5),
//               child: Text(
//                 brand.name,
//                 maxLines: 2,
//                 textAlign: TextAlign.center,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   fontSize: 9.5,
//                   height: 1.25,
//                   fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
//                   color: isActive ? c.accent : c.text3,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // BRAND SECTION
// // ═══════════════════════════════════════════════════════════════

// class _BrandSection extends StatelessWidget {
//   final brand_model.BrandsWithProductsModel brand;
//   const _BrandSection({required this.brand});

//   @override
//   Widget build(BuildContext context) {
//     final c = context.colors;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
//           child: Row(
//             children: [
//               ClipOval(
//                 child: CachedNetworkImage(
//                   imageUrl: brand.image,
//                   width: 22,
//                   height: 22,
//                   fit: BoxFit.cover,
//                   placeholder: (_, __) => _imgPlaceholder(22, context),
//                   errorWidget: (_, __, ___) =>
//                       _brandInitialCircle(brand.name, 22, context),
//                 ),
//               ),
//               const SizedBox(width: 7),
//               Expanded(
//                 child: Text(
//                   brand.name.toUpperCase(),
//                   style: TextStyle(
//                     fontSize: 12.5,
//                     fontWeight: FontWeight.w800,
//                     letterSpacing: 0.4,
//                     color: c.text1,
//                   ),
//                 ),
//               ),
//               Text(
//                 '${brand.products.length}',
//                 style: TextStyle(fontSize: 11, color: c.text3),
//               ),
//             ],
//           ),
//         ),
//         ...brand.products.map((p) => _BrandProductTile(product: p)),
//         Container(height: 8, color: c.surface2),
//       ],
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // BRAND PRODUCT TILE  — same scale + Hero pattern
// // ═══════════════════════════════════════════════════════════════

// class _BrandProductTile extends StatefulWidget {
//   final brand_model.Product product;
//   const _BrandProductTile({required this.product});

//   @override
//   State<_BrandProductTile> createState() => _BrandProductTileState();
// }

// class _BrandProductTileState extends State<_BrandProductTile>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _scaleCtrl;
//   late Animation<double> _scaleAnim;

//   bool get _inStock => widget.product.status && widget.product.quantity > 0;
//   double get _price => double.tryParse(widget.product.salePrice) ?? 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _scaleCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 120),
//       reverseDuration: const Duration(milliseconds: 200),
//       value: 1.0,
//     );
//     _scaleAnim = Tween<double>(
//       begin: 1.0,
//       end: 0.97,
//     ).animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut));
//   }

//   @override
//   void dispose() {
//     _scaleCtrl.dispose();
//     super.dispose();
//   }

//   void _onTapDown(TapDownDetails _) => _scaleCtrl.forward();
//   void _onTapCancel() => _scaleCtrl.reverse();

//   void _onTap() {
//     HapticFeedback.lightImpact();
//     _scaleCtrl.reverse();
//     Navigator.push(
//       context,
//       _smoothRoute(ProductDetailScreen(productId: widget.product.id)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final c = context.colors;
//     return GestureDetector(
//       onTapDown: _onTapDown,
//       onTapCancel: _onTapCancel,
//       onTap: _onTap,
//       child: ScaleTransition(
//         scale: _scaleAnim,
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//           decoration: BoxDecoration(
//             border: Border(top: BorderSide(color: c.border, width: 0.5)),
//           ),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       widget.product.name,
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w400,
//                         height: 1.3,
//                         color: c.text1,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     _UnitBadge(unit: widget.product.unit.name.toLowerCase()),
//                     const SizedBox(height: 5),
//                     Row(
//                       children: [
//                         Text(
//                           '\$${_price.toStringAsFixed(2)}',
//                           style: TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w600,
//                             color: c.text1,
//                           ),
//                         ),
//                         const SizedBox(width: 7),
//                         Container(
//                           width: 6,
//                           height: 6,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: _inStock ? c.flashText : c.text3,
//                           ),
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           _inStock
//                               ? 'In stock (${widget.product.quantity})'
//                               : 'Out of stock',
//                           style: TextStyle(
//                             fontSize: 10,
//                             color: _inStock ? c.flashText : c.text3,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Stack(
//                 children: [
//                   Hero(
//                     tag: 'brand-product-img-${widget.product.id}',
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: CachedNetworkImage(
//                         imageUrl: widget.product.firstImage.imageUrl,
//                         width: _kProductImageSz,
//                         height: _kProductImageSz,
//                         fit: BoxFit.cover,
//                         placeholder: (_, __) =>
//                             _imgPlaceholder(_kProductImageSz, context),
//                         errorWidget: (_, __, ___) => _imgFallback(
//                           widget.product.name,
//                           _kProductImageSz,
//                           context,
//                           radius: 10,
//                         ),
//                       ),
//                     ),
//                   ),
//                   if (!_inStock)
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: Container(
//                         width: _kProductImageSz,
//                         height: _kProductImageSz,
//                         color: c.background.withOpacity(0.5),
//                       ),
//                     ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // NAVIGATION HELPER
// // Smooth fade+slide route, same as original but extracted once.
// // In ProductDetailScreen, wrap your product image with:
// //   Hero(tag: 'product-img-$productId', child: ...)
// // ═══════════════════════════════════════════════════════════════

// PageRoute<T> _smoothRoute<T>(Widget page) => PageRouteBuilder<T>(
//   transitionDuration: const Duration(milliseconds: 350),
//   pageBuilder: (_, __, ___) => page,
//   transitionsBuilder: (_, animation, __, child) => FadeTransition(
//     opacity: animation,
//     child: SlideTransition(
//       position: Tween<Offset>(
//         begin: const Offset(0.08, 0),
//         end: Offset.zero,
//       ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
//       child: child,
//     ),
//   ),
// );

// // ═══════════════════════════════════════════════════════════════
// // SHARED WIDGETS
// // ═══════════════════════════════════════════════════════════════

// class _UnitBadge extends StatelessWidget {
//   final String unit;
//   const _UnitBadge({required this.unit});

//   @override
//   Widget build(BuildContext context) {
//     final c = context.colors;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//       decoration: BoxDecoration(
//         color: c.cardBg,
//         borderRadius: BorderRadius.circular(4),
//         border: Border.all(color: c.border, width: 0.5),
//       ),
//       child: Text(unit, style: TextStyle(fontSize: 10, color: c.text3)),
//     );
//   }
// }

// Widget _imgPlaceholder(double size, BuildContext context) =>
//     Container(width: size, height: size, color: context.colors.cardBg);

// Widget _imgFallback(
//   String name,
//   double size,
//   BuildContext context, {
//   double radius = 8,
// }) {
//   final c = context.colors;
//   return Container(
//     width: size,
//     height: size,
//     decoration: BoxDecoration(
//       color: c.accentLight,
//       borderRadius: BorderRadius.circular(radius),
//     ),
//     alignment: Alignment.center,
//     child: Text(
//       name.isNotEmpty ? name[0].toUpperCase() : '?',
//       style: TextStyle(
//         color: c.accent,
//         fontWeight: FontWeight.w700,
//         fontSize: size * 0.4,
//       ),
//     ),
//   );
// }

// Widget _brandInitialCircle(String name, double size, BuildContext context) {
//   final c = context.colors;
//   return Container(
//     width: size,
//     height: size,
//     decoration: BoxDecoration(shape: BoxShape.circle, color: c.accentLight),
//     alignment: Alignment.center,
//     child: Text(
//       name.isNotEmpty ? name[0].toUpperCase() : '?',
//       style: TextStyle(
//         color: c.accent,
//         fontWeight: FontWeight.w700,
//         fontSize: size * 0.4,
//       ),
//     ),
//   );
// }

// // ═══════════════════════════════════════════════════════════════
// // ERROR STATE
// // ═══════════════════════════════════════════════════════════════

// class _ErrorState extends StatelessWidget {
//   final VoidCallback onRetry;
//   const _ErrorState({required this.onRetry});

//   @override
//   Widget build(BuildContext context) {
//     final c = context.colors;
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.wifi_off_rounded, size: 52, color: c.text3),
//             const SizedBox(height: 14),
//             Text(
//               'Connection failed',
//               style: TextStyle(
//                 fontSize: 17,
//                 fontWeight: FontWeight.w700,
//                 color: c.text1,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               'Could not load data. Please check your connection.',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 13, color: c.text2),
//             ),
//             const SizedBox(height: 22),
//             TextButton.icon(
//               onPressed: onRetry,
//               icon: const Icon(Icons.refresh_rounded, size: 17),
//               label: const Text('Retry'),
//               style: TextButton.styleFrom(foregroundColor: c.accent),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // EMPTY STATE
// // ═══════════════════════════════════════════════════════════════

// class _EmptyState extends StatelessWidget {
//   final String message;
//   const _EmptyState({required this.message});

//   @override
//   Widget build(BuildContext context) {
//     final c = context.colors;
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.inbox_rounded, size: 52, color: c.text3),
//           const SizedBox(height: 12),
//           Text(message, style: TextStyle(fontSize: 15, color: c.text2)),
//         ],
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // SKELETON  (unchanged structure, now uses context.colors)
// // ═══════════════════════════════════════════════════════════════

// class _SkeletonSplitView extends StatelessWidget {
//   const _SkeletonSplitView();

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           width: _kSidebarWidth,
//           color: context.colors.surface2,
//           child: ListView.builder(
//             itemCount: 8,
//             itemBuilder: (_, __) => const _SidebarSkeletonItem(),
//           ),
//         ),
//         Container(width: 0.5, color: context.colors.border),
//         Expanded(
//           child: ListView.builder(
//             itemCount: 6,
//             itemBuilder: (_, __) => const _ProductSkeletonItem(),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _SidebarSkeletonItem extends StatelessWidget {
//   const _SidebarSkeletonItem();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: _kSidebarItemH,
//       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
//       child: Column(
//         children: [
//           _Shimmer(width: 38, height: 38, radius: 9),
//           const SizedBox(height: 5),
//           _Shimmer(width: 60, height: 8, radius: 4),
//         ],
//       ),
//     );
//   }
// }

// class _ProductSkeletonItem extends StatelessWidget {
//   const _ProductSkeletonItem();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       decoration: BoxDecoration(
//         border: Border(
//           top: BorderSide(color: context.colors.border, width: 0.5),
//         ),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _Shimmer(width: double.infinity, height: 13, radius: 4),
//                 const SizedBox(height: 6),
//                 _Shimmer(width: 60, height: 11, radius: 4),
//                 const SizedBox(height: 6),
//                 _Shimmer(width: 80, height: 11, radius: 4),
//               ],
//             ),
//           ),
//           const SizedBox(width: 10),
//           _Shimmer(
//             width: _kProductImageSz,
//             height: _kProductImageSz,
//             radius: 10,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _BrandSkeleton extends StatelessWidget {
//   const _BrandSkeleton();

//   @override
//   Widget build(BuildContext context) => const _SkeletonSplitView();
// }

// // ═══════════════════════════════════════════════════════════════
// // SHIMMER
// // ═══════════════════════════════════════════════════════════════

// class _Shimmer extends StatefulWidget {
//   final double width;
//   final double height;
//   final double radius;

//   const _Shimmer({
//     required this.width,
//     required this.height,
//     required this.radius,
//   });

//   @override
//   State<_Shimmer> createState() => _ShimmerState();
// }

// class _ShimmerState extends State<_Shimmer>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
//   late Animation<double> _anim;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1100),
//     )..repeat(reverse: true);
//     _anim = Tween<double>(
//       begin: 0.4,
//       end: 1.0,
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
//     return AnimatedBuilder(
//       animation: _anim,
//       builder: (_, __) => Container(
//         width: widget.width,
//         height: widget.height,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(widget.radius),
//           color: Color.lerp(
//             isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E4DF),
//             isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F2EE),
//             _anim.value,
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mart_frontend/models/brands_with_products.dart' as brand_model;
import 'package:mart_frontend/models/categories_with_products_model.dart'
    as cat_model;
import 'package:mart_frontend/screens/product/product_detail_screen.dart';
import 'package:mart_frontend/screens/search/search_screen.dart';
import 'package:mart_frontend/screens/theme/app_theme.dart';
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
  final ApiService _api = ApiService();

  bool _loadingCats = true;
  bool _loadingBrands = true;
  bool _errorCats = false;
  bool _errorBrands = false;

  List<cat_model.CategoriesWithProductsModel> _categories = [];
  List<brand_model.BrandsWithProductsModel> _brands = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCategories();
    _loadBrands();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _loadingCats = true;
      _errorCats = false;
    });
    try {
      final data = await _api.fetchCategoriesWithProducts();
      if (!mounted) return;
      setState(() {
        _categories = data;
        _loadingCats = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingCats = false;
        _errorCats = true;
      });
    }
    
  }

  Future<void> _loadBrands() async {
    setState(() {
      _loadingBrands = true;
      _errorBrands = false;
    });
    try {
      final data = await _api.fetchBrandsWithProducts();
      if (!mounted) return;
      setState(() {
        _brands = data;
        _loadingBrands = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingBrands = false;
        _errorBrands = true;
      });
    }
  }

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
                _loadingCats
                    ? const _SkeletonSplitView()
                    : _errorCats
                    ? _ErrorState(onRetry: _loadCategories)
                    : _categories.isEmpty
                    ? const _EmptyState(message: 'No categories found')
                    : _CategoriesTab(categories: _categories),
                _loadingBrands
                    ? const _BrandSkeleton()
                    : _errorBrands
                    ? _ErrorState(onRetry: _loadBrands)
                    : _brands.isEmpty
                    ? const _EmptyState(message: 'No brands found')
                    : _BrandsTab(brands: _brands),
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
        'Category',
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
        tabs: const [
          Tab(text: 'Products'),
          Tab(text: 'Brand'),
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
    HapticFeedback.lightImpact();

    // Update notifier immediately for instant visual feedback
    activeNotifier.value = index;
    _activeOverlap = double.maxFinite; // lock hysteresis until scroll settles
    _scrollSidebarTo(index);

    // Lock the listener while animateTo runs
    _programmatic = true;
    _lockTimer?.cancel();

    if (_offsets.isEmpty) _buildOffsets();
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
  const _CategoriesTab({required this.categories});

  @override
  State<_CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<_CategoriesTab>
    with _ScrollSyncMixin<_CategoriesTab> {
  @override
  int get itemCount => widget.categories.length;

  @override
  double sectionHeight(int index) {
    final n = widget.categories[index].products.length;
    return _kSecHeaderH + n * _kSecTileH + _kSecGapH;
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
    HapticFeedback.lightImpact();
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
          margin: const EdgeInsets.all(12),
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
                        Text(
                          '\$${_price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: c.text1,
                          ),
                        ),

                        // const SizedBox(width: 4),
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
    HapticFeedback.lightImpact();
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
          margin: const EdgeInsets.all(12),
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
                          '\$${_price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: c.text1,
                          ),
                        ),

                        // const SizedBox(width: 4),
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
