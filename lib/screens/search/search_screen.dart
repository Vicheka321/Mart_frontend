// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../../services/api_service.dart';
// import '../../translations/catalog_translation.dart';
// import '../theme/app_theme.dart';
// import '../product/product_detail_screen.dart';

// // ─────────────────────────────────────────────
// // SEARCH SCREEN
// // ─────────────────────────────────────────────

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController _searchCtrl = TextEditingController();
//   final FocusNode _focusNode = FocusNode();

//   late Future<List<_SearchProduct>> _productsFuture;
//   String _query = '';
//   bool _loading = false;

//   List<String> _recentSearches = [];

//   static const _recentKey = 'recent_searches';
//   static const _maxRecents = 8;

//   // Quick category chips → maps to a search term
//   static const _categories = [
//     (_CategoryChip(
//       label: 'Fruits',
//       icon: Icons.apple_rounded,
//       color: Color(0xFF16A34A),
//     )),
//     (_CategoryChip(
//       label: 'Bakery',
//       icon: Icons.bakery_dining_rounded,
//       color: Color(0xFFEA580C),
//     )),
//     (_CategoryChip(
//       label: 'Drinks',
//       icon: Icons.local_drink_rounded,
//       color: Color(0xFF2563EB),
//     )),
//     (_CategoryChip(
//       label: 'Snacks',
//       icon: Icons.cookie_rounded,
//       color: Color(0xFFDB2777),
//     )),
//   ];

//   static const _trending = [
//     'Instant noodles',
//     'Fresh fruit',
//     'Energy drink',
//     'Coffee',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _productsFuture = _loadProducts();
//     _loadRecents();
//     // Auto-focus the field on entry
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _focusNode.requestFocus();
//     });
//   }

//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     _focusNode.dispose();
//     super.dispose();
//   }

//   // ── Data ────────────────────────────────────
//   Future<List<_SearchProduct>> _loadProducts() async {
//     final results = await Future.wait<List<dynamic>>([
//       ApiService().fetchAllProducts(),
//     ]);

//     final byId = <int, _SearchProduct>{};
//     for (final group in results) {
//       for (final item in group) {
//         final product = _SearchProduct.fromProduct(item);
//         byId[product.id] = product;
//       }
//     }

//     final products = byId.values.toList()
//       ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
//     return products;
//   }

//   List<_SearchProduct> _filter(List<_SearchProduct> products) {
//     final q = _query.trim().toLowerCase();
//     if (q.isEmpty) return const [];

//     return products.where((product) {
//       return product.name.toLowerCase().contains(q) ||
//           product.brandName.toLowerCase().contains(q) ||
//           product.brandName.trCatalog.toLowerCase().contains(q) ||
//           product.categoryName.toLowerCase().contains(q) ||
//           product.description.toLowerCase().contains(q);
//     }).toList();
//   }

//   Future<void> _refresh() async {
//     setState(() => _productsFuture = _loadProducts());
//     await _productsFuture;
//   }

//   // ── Recent searches (persisted) ─────────────
//   Future<void> _loadRecents() async {
//     final prefs = await SharedPreferences.getInstance();
//     final saved = prefs.getStringList(_recentKey) ?? [];
//     if (mounted) setState(() => _recentSearches = saved);
//   }

//   Future<void> _addRecent(String term) async {
//     final trimmed = term.trim();
//     if (trimmed.isEmpty) return;
//     final prefs = await SharedPreferences.getInstance();
//     final updated = [trimmed, ..._recentSearches.where((s) => s != trimmed)];
//     if (updated.length > _maxRecents)
//       updated.removeRange(_maxRecents, updated.length);
//     await prefs.setStringList(_recentKey, updated);
//     if (mounted) setState(() => _recentSearches = updated);
//   }

//   Future<void> _clearRecents() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_recentKey);
//     if (mounted) setState(() => _recentSearches = []);
//   }

//   // ── Search handling ──────────────────────────
//   void _onSubmitted(String value) {
//     _addRecent(value);
//   }

//   void _onChanged(String value) {
//     setState(() {
//       _query = value;
//       _loading = value.trim().isNotEmpty;
//     });
//     // Debounce loading flag off slightly so skeleton briefly shows
//     if (value.trim().isNotEmpty) {
//       Future.delayed(const Duration(milliseconds: 280), () {
//         if (mounted && _searchCtrl.text == value) {
//           setState(() => _loading = false);
//         }
//       });
//     }
//   }

//   void _selectTerm(String term) {
//     _searchCtrl.text = term;
//     setState(() {
//       _query = term;
//       _loading = true;
//     });
//     _addRecent(term);
//     Future.delayed(const Duration(milliseconds: 280), () {
//       if (mounted) setState(() => _loading = false);
//     });
//   }

//   void _clearQuery() {
//     _searchCtrl.clear();
//     setState(() {
//       _query = '';
//       _loading = false;
//     });
//     _focusNode.requestFocus();
//   }

//   // ── Build ─────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final isSearching = _query.trim().isNotEmpty;

//     return Scaffold(
//       backgroundColor: colors.background,
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildSearchBar(colors, isSearching),
//             Expanded(
//               child: isSearching
//                   ? _buildResults(colors)
//                   : _buildDiscover(colors),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Search bar ────────────────────────────────
//   Widget _buildSearchBar(AppColors colors, bool isSearching) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
//       child: Row(
//         children: [
//           Expanded(
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 180),
//               decoration: BoxDecoration(
//                 color: colors.cardBg,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(
//                   color: _focusNode.hasFocus ? colors.accent : colors.border,
//                   width: _focusNode.hasFocus ? 1.5 : 1,
//                 ),
//               ),
//               child: TextField(
//                 controller: _searchCtrl,
//                 focusNode: _focusNode,
//                 autofocus: true,
//                 style: TextStyle(fontSize: 14, color: colors.text1),
//                 onChanged: _onChanged,
//                 onSubmitted: _onSubmitted,
//                 onTap: () => setState(() {}),
//                 decoration: InputDecoration(
//                   hintText: 'search_hint'.tr,
//                   hintStyle: TextStyle(color: colors.text3, fontSize: 14),
//                   prefixIcon: Icon(
//                     Icons.search_rounded,
//                     size: 22,
//                     color: colors.text2,
//                   ),
//                   suffixIcon: _query.isEmpty
//                       ? null
//                       : GestureDetector(
//                           onTap: _clearQuery,
//                           child: Container(
//                             margin: const EdgeInsets.all(12),
//                             width: 20,
//                             height: 20,
//                             decoration: BoxDecoration(
//                               color: colors.surface2,
//                               shape: BoxShape.circle,
//                             ),
//                             child: Icon(
//                               Icons.close_rounded,
//                               size: 12,
//                               color: colors.text2,
//                             ),
//                           ),
//                         ),
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.symmetric(vertical: 14),
//                 ),
//               ),
//             ),
//           ),
//           // Cancel link — appears once focused/typing
//           AnimatedSize(
//             duration: const Duration(milliseconds: 180),
//             curve: Curves.easeOut,
//             child: (isSearching || _focusNode.hasFocus)
//                 ? Padding(
//                     padding: const EdgeInsets.only(left: 10),
//                     child: GestureDetector(
//                       onTap: () {
//                         _clearQuery();
//                         _focusNode.unfocus();
//                         Navigator.maybePop(context);
//                       },
//                       child: Text(
//                         'cancel'.tr,
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: colors.accent,
//                         ),
//                       ),
//                     ),
//                   )
//                 : const SizedBox.shrink(),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Discover content (no query) ──────────────
//   Widget _buildDiscover(AppColors colors) {
//     return ListView(
//       padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
//       children: [
//         if (_recentSearches.isNotEmpty) ...[
//           _SectionHeader(
//             title: 'recent_searches'.tr,
//             colors: colors,
//             trailing: GestureDetector(
//               onTap: _clearRecents,
//               child: Text(
//                 'clear'.tr,
//                 style: TextStyle(
//                   fontSize: 11,
//                   fontWeight: FontWeight.w600,
//                   color: colors.accent,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: _recentSearches
//                 .map(
//                   (term) => _Chip(
//                     label: term,
//                     icon: Icons.access_time_rounded,
//                     colors: colors,
//                     onTap: () => _selectTerm(term),
//                   ),
//                 )
//                 .toList(),
//           ),
//           const SizedBox(height: 22),
//         ],

//         _SectionHeader(title: 'trending_now'.tr, colors: colors),
//         const SizedBox(height: 10),
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: _trending
//               .map(
//                 (term) => _Chip(
//                   label: term,
//                   icon: Icons.local_fire_department_rounded,
//                   colors: colors,
//                   highlighted: true,
//                   onTap: () => _selectTerm(term),
//                 ),
//               )
//               .toList(),
//         ),
//         const SizedBox(height: 22),

//         _SectionHeader(title: 'browse_categories'.tr, colors: colors),
//         const SizedBox(height: 12),
//         GridView.count(
//           crossAxisCount: 4,
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           mainAxisSpacing: 12,
//           crossAxisSpacing: 10,
//           childAspectRatio: 0.85,
//           children: _categories
//               .map(
//                 (cat) => _CategoryItem(
//                   chip: cat,
//                   colors: colors,
//                   onTap: () => _selectTerm(cat.label),
//                 ),
//               )
//               .toList(),
//         ),
//       ],
//     );
//   }

//   // ── Search results ────────────────────────────
//   Widget _buildResults(AppColors colors) {
//     if (_loading) {
//       return _SearchSkeleton(colors: colors);
//     }

//     return FutureBuilder<List<_SearchProduct>>(
//       future: _productsFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return _SearchSkeleton(colors: colors);
//         }

//         if (snapshot.hasError) {
//           return _SearchMessage(
//             icon: Icons.cloud_off_rounded,
//             title: 'could_not_load_products'.tr,
//             subtitle: 'pull_to_try_again'.tr,
//             colors: colors,
//             onRefresh: _refresh,
//           );
//         }

//         final products = _filter(snapshot.data ?? []);
//         if (products.isEmpty) {
//           return _SearchMessage(
//             icon: Icons.search_off_rounded,
//             title: 'no_products_found'.tr,
//             subtitle: 'try_different_search'.tr,
//             colors: colors,
//             onRefresh: _refresh,
//           );
//         }

//         return RefreshIndicator(
//           color: colors.accent,
//           backgroundColor: colors.cardBg,
//           onRefresh: _refresh,
//           child: ListView.builder(
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
//             itemCount: products.length + 1,
//             itemBuilder: (_, index) {
//               if (index == 0) {
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 10),
//                   child: Text(
//                     '${products.length} ${products.length == 1 ? 'result'.tr : 'results'.tr}',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: colors.text2,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 );
//               }
//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child: _SearchProductCard(
//                   product: products[index - 1],
//                   colors: colors,
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // SECTION HEADER
// // ─────────────────────────────────────────────

// class _SectionHeader extends StatelessWidget {
//   final String label1 = '';
//   final String title;
//   final AppColors colors;
//   final Widget? trailing;

//   const _SectionHeader({
//     required this.title,
//     required this.colors,
//     this.trailing,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           title.toUpperCase(),
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w700,
//             color: colors.text3,
//             letterSpacing: 0.6,
//           ),
//         ),
//         if (trailing != null) trailing!,
//       ],
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // CHIP  (recent / trending)
// // ─────────────────────────────────────────────

// class _Chip extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final AppColors colors;
//   final bool highlighted;
//   final VoidCallback onTap;

//   const _Chip({
//     required this.label,
//     required this.icon,
//     required this.colors,
//     this.highlighted = false,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final bg = highlighted ? colors.accentLight : colors.cardBg;
//     final border = highlighted ? colors.accentLight : colors.border;
//     final fg = highlighted ? colors.accent : colors.text1;
//     final iconColor = highlighted ? colors.accent : colors.text3;

//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
//         decoration: BoxDecoration(
//           color: bg,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: border),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 13, color: iconColor),
//             const SizedBox(width: 6),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12.5,
//                 fontWeight: FontWeight.w600,
//                 color: fg,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // CATEGORY ITEM
// // ─────────────────────────────────────────────

// class _CategoryChip {
//   final String label;
//   final IconData icon;
//   final Color color;
//   const _CategoryChip({
//     required this.label,
//     required this.icon,
//     required this.color,
//   });
// }

// class _CategoryItem extends StatelessWidget {
//   final _CategoryChip chip;
//   final AppColors colors;
//   final VoidCallback onTap;

//   const _CategoryItem({
//     required this.chip,
//     required this.colors,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Container(
//             width: 52,
//             height: 52,
//             decoration: BoxDecoration(
//               color: colors.cardBg,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: colors.border),
//             ),
//             child: Icon(chip.icon, size: 24, color: chip.color),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             chip.label,
//             textAlign: TextAlign.center,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w600,
//               color: colors.text1,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // SEARCH SKELETON
// // ─────────────────────────────────────────────

// class _SearchSkeleton extends StatefulWidget {
//   final AppColors colors;
//   const _SearchSkeleton({required this.colors});

//   @override
//   State<_SearchSkeleton> createState() => _SearchSkeletonState();
// }

// class _SearchSkeletonState extends State<_SearchSkeleton>
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
//     _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
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
//       builder: (_, __) {
//         final base = Color.lerp(
//           widget.colors.surface2,
//           widget.colors.border,
//           _anim.value,
//         )!;
//         return ListView.builder(
//           padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
//           itemCount: 5,
//           itemBuilder: (_, __) => Container(
//             margin: const EdgeInsets.only(bottom: 12),
//             height: 102,
//             decoration: BoxDecoration(
//               color: base,
//               borderRadius: BorderRadius.circular(18),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // PRODUCT MODEL
// // ─────────────────────────────────────────────

// class _SearchProduct {
//   final int id;
//   final String name;
//   final String description;
//   final String quantity;
//   final String salePrice;
//   final String finalPrice;
//   final String? discount;
//   final String categoryName;
//   final String brandName;
//   final List<String> images;

//   const _SearchProduct({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.quantity,
//     required this.salePrice,
//     required this.finalPrice,
//     required this.discount,
//     required this.categoryName,
//     required this.brandName,
//     required this.images,
//   });

//   factory _SearchProduct.fromProduct(dynamic product) {
//     return _SearchProduct(
//       id: product.id as int,
//       name: product.name?.toString() ?? '',
//       description: product.description?.toString() ?? '',
//       salePrice: product.salePrice?.toString() ?? '0.00',
//       finalPrice: product.finalPrice?.toString() ?? '0.00',
//       discount: product.discount?.toString(),
//       categoryName: product.categoryName?.toString() ?? '',
//       brandName: product.brandName?.toString() ?? '',
//       images: product.images is List
//           ? List<String>.from((product.images as List).map((e) => e.toString()))
//           : const [],
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // PRODUCT CARD
// // ─────────────────────────────────────────────

// class _SearchProductCard extends StatelessWidget {
//   final _SearchProduct product;
//   final AppColors colors;
//   const _SearchProductCard({required this.product, required this.colors});

//   @override
//   Widget build(BuildContext context) {
//     final imageUrl = product.images.isNotEmpty ? product.images.first : null;
//     final hasDiscount =
//         product.discount != null && product.discount!.isNotEmpty;
//     final isOutOfStock = product. == 0;

//     return GestureDetector(
//       onTap: isOutOfStock
//           ? null
//           : () => Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => ProductDetailScreen(productId: product.id),
//               ),
//             ),
//       child: Opacity(
//         opacity: isOutOfStock ? 0.55 : 1.0,
//         child: Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: colors.cardBg,
//             borderRadius: BorderRadius.circular(18),
//           ),
//           child: Row(
//             children: [
//               // ── Image ─────────────────────────────
//               Stack(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(14),
//                     child: imageUrl == null
//                         ? _ImageFallback(colors: colors)
//                         : Image.network(
//                             imageUrl,
//                             width: 78,
//                             height: 78,
//                             fit: BoxFit.cover,
//                             errorBuilder: (_, __, ___) =>
//                                 _ImageFallback(colors: colors),
//                           ),
//                   ),
//                   if (isOutOfStock)
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(14),
//                       child: Container(
//                         width: 78,
//                         height: 78,
//                         color: Colors.black.withValues(alpha: 0.38),
//                         alignment: Alignment.center,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 6,
//                             vertical: 3,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.black.withValues(alpha: 0.55),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: const Text(
//                             'Out of stock',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 9,
//                               fontWeight: FontWeight.w600,
//                               letterSpacing: 0.2,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),

//               const SizedBox(width: 12),

//               // ── Body ──────────────────────────────
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       product.name,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         color: colors.text1,
//                         fontSize: 14.5,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     const SizedBox(height: 3),
//                     Text(
//                       [
//                         product.brandName.trCatalog,
//                         product.categoryName,
//                       ].where((t) => t.trim().isNotEmpty).join(' · '),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(color: colors.text2, fontSize: 11.5),
//                     ),
//                     const SizedBox(height: 8),

//                     // ── Pricing row ──────────────────
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Text(
//                           '\$${product.finalPrice}',
//                           style: TextStyle(
//                             color: isOutOfStock ? colors.text3 : colors.accent,
//                             fontSize: 15,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                         if (hasDiscount) ...[
//                           const SizedBox(width: 6),
//                           Text(
//                             '\$${product.salePrice}',
//                             style: TextStyle(
//                               color: colors.text3,
//                               fontSize: 11.5,
//                               decoration: TextDecoration.lineThrough,
//                             ),
//                           ),
//                           const SizedBox(width: 6),
//                           _DiscountBadge(discount: product.discount!),
//                         ],
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               // ── Chevron ───────────────────────────
//               if (!isOutOfStock)
//                 Icon(
//                   Icons.chevron_right_rounded,
//                   color: colors.text3,
//                   size: 20,
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // DISCOUNT BADGE
// // ─────────────────────────────────────────────

// class _DiscountBadge extends StatelessWidget {
//   final String discount;
//   const _DiscountBadge({required this.discount});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
//       decoration: BoxDecoration(
//         color: const Color(0xFFE8F5E9),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         '−$discount%',
//         style: const TextStyle(
//           fontSize: 10.5,
//           fontWeight: FontWeight.w600,
//           color: Color(0xFF2E7D32),
//         ),
//       ),
//     );
//   }
// }

// class _ImageFallback extends StatelessWidget {
//   final AppColors colors;
//   const _ImageFallback({required this.colors});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 78,
//       height: 78,
//       color: colors.surface2,
//       child: Icon(Icons.image_outlined, color: colors.text3),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // MESSAGE  (error / no results)
// // ─────────────────────────────────────────────

// class _SearchMessage extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final AppColors colors;
//   final Future<void> Function() onRefresh;

//   const _SearchMessage({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.colors,
//     required this.onRefresh,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return RefreshIndicator(
//       color: colors.accent,
//       backgroundColor: colors.cardBg,
//       onRefresh: onRefresh,
//       child: ListView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         children: [
//           const SizedBox(height: 90),
//           Center(
//             child: Container(
//               width: 72,
//               height: 72,
//               decoration: BoxDecoration(
//                 color: colors.surface2,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, size: 32, color: colors.text3),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             title,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: colors.text1,
//               fontSize: 16,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             subtitle,
//             textAlign: TextAlign.center,
//             style: TextStyle(color: colors.text2, fontSize: 12.5),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_service.dart';
import '../../translations/catalog_translation.dart';
import '../theme/app_theme.dart';
import '../product/product_detail_screen.dart';

// ─────────────────────────────────────────────
// SEARCH SCREEN
// ─────────────────────────────────────────────

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late Future<List<_SearchProduct>> _productsFuture;
  String _query = '';
  bool _loading = false;

  List<String> _recentSearches = [];

  static const _recentKey = 'recent_searches';
  static const _maxRecents = 8;

  static const _categories = [
    _CategoryChip(
      label: 'Fruits',
      icon: Icons.apple_rounded,
      color: Color(0xFF16A34A),
    ),
    _CategoryChip(
      label: 'Bakery',
      icon: Icons.bakery_dining_rounded,
      color: Color(0xFFEA580C),
    ),
    _CategoryChip(
      label: 'Drinks',
      icon: Icons.local_drink_rounded,
      color: Color(0xFF2563EB),
    ),
    _CategoryChip(
      label: 'Snacks',
      icon: Icons.cookie_rounded,
      color: Color(0xFFDB2777),
    ),
  ];

  static const _trending = [
    'Instant noodles',
    'Fresh fruit',
    'Energy drink',
    'Coffee',
  ];

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
    _loadRecents();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Data ────────────────────────────────────

  Future<List<_SearchProduct>> _loadProducts() async {
    final results = await Future.wait<List<dynamic>>([
      ApiService().fetchAllProducts(),
    ]);

    final byId = <int, _SearchProduct>{};
    for (final group in results) {
      for (final item in group) {
        final product = _SearchProduct.fromProduct(item);
        byId[product.id] = product;
      }
    }

    return byId.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  List<_SearchProduct> _filter(List<_SearchProduct> products) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return products.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.brandName.toLowerCase().contains(q) ||
          p.brandName.trCatalog.toLowerCase().contains(q) ||
          p.categoryName.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _refresh() async {
    setState(() => _productsFuture = _loadProducts());
    await _productsFuture;
  }

  // ── Recent searches ──────────────────────────

  Future<void> _loadRecents() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_recentKey) ?? [];
    if (mounted) setState(() => _recentSearches = saved);
  }

  Future<void> _addRecent(String term) async {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final updated = [trimmed, ..._recentSearches.where((s) => s != trimmed)];
    if (updated.length > _maxRecents)
      updated.removeRange(_maxRecents, updated.length);
    await prefs.setStringList(_recentKey, updated);
    if (mounted) setState(() => _recentSearches = updated);
  }

  Future<void> _clearRecents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentKey);
    if (mounted) setState(() => _recentSearches = []);
  }

  // ── Search handling ──────────────────────────

  void _onSubmitted(String value) => _addRecent(value);

  void _onChanged(String value) {
    setState(() {
      _query = value;
      _loading = value.trim().isNotEmpty;
    });
    if (value.trim().isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 280), () {
        if (mounted && _searchCtrl.text == value) {
          setState(() => _loading = false);
        }
      });
    }
  }

  void _selectTerm(String term) {
    _searchCtrl.text = term;
    setState(() {
      _query = term;
      _loading = true;
    });
    _addRecent(term);
    Future.delayed(const Duration(milliseconds: 280), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  void _clearQuery() {
    _searchCtrl.clear();
    setState(() {
      _query = '';
      _loading = false;
    });
    _focusNode.requestFocus();
  }

  // ── Build ────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isSearching = _query.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(colors, isSearching),
            Expanded(
              child: isSearching
                  ? _buildResults(colors)
                  : _buildDiscover(colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(AppColors colors, bool isSearching) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: colors.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _focusNode.hasFocus ? colors.accent : colors.border,
                  width: _focusNode.hasFocus ? 1.5 : 1,
                ),
              ),
              child: TextField(
                controller: _searchCtrl,
                focusNode: _focusNode,
                autofocus: true,
                style: TextStyle(fontSize: 14, color: colors.text1),
                onChanged: _onChanged,
                onSubmitted: _onSubmitted,
                onTap: () => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'search_hint'.tr,
                  hintStyle: TextStyle(color: colors.text3, fontSize: 14),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 22,
                    color: colors.text2,
                  ),
                  suffixIcon: _query.isEmpty
                      ? null
                      : GestureDetector(
                          onTap: _clearQuery,
                          child: Container(
                            margin: const EdgeInsets.all(12),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: colors.surface2,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 12,
                              color: colors.text2,
                            ),
                          ),
                        ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: (isSearching || _focusNode.hasFocus)
                ? Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: GestureDetector(
                      onTap: () {
                        _clearQuery();
                        _focusNode.unfocus();
                        Navigator.maybePop(context);
                      },
                      child: Text(
                        'cancel'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.accent,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscover(AppColors colors) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        if (_recentSearches.isNotEmpty) ...[
          _SectionHeader(
            title: 'recent_searches'.tr,
            colors: colors,
            trailing: GestureDetector(
              onTap: _clearRecents,
              child: Text(
                'clear'.tr,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colors.accent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches
                .map(
                  (term) => _Chip(
                    label: term,
                    icon: Icons.access_time_rounded,
                    colors: colors,
                    onTap: () => _selectTerm(term),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 22),
        ],
        _SectionHeader(title: 'trending_now'.tr, colors: colors),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _trending
              .map(
                (term) => _Chip(
                  label: term,
                  icon: Icons.local_fire_department_rounded,
                  colors: colors,
                  highlighted: true,
                  onTap: () => _selectTerm(term),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 22),
        _SectionHeader(title: 'browse_categories'.tr, colors: colors),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 10,
          childAspectRatio: 0.85,
          children: _categories
              .map(
                (cat) => _CategoryItem(
                  chip: cat,
                  colors: colors,
                  onTap: () => _selectTerm(cat.label),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildResults(AppColors colors) {
    if (_loading) return _SearchSkeleton(colors: colors);

    return FutureBuilder<List<_SearchProduct>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _SearchSkeleton(colors: colors);
        }
        if (snapshot.hasError) {
          return _SearchMessage(
            icon: Icons.cloud_off_rounded,
            title: 'could_not_load_products'.tr,
            subtitle: 'pull_to_try_again'.tr,
            colors: colors,
            onRefresh: _refresh,
          );
        }
        final products = _filter(snapshot.data ?? []);
        if (products.isEmpty) {
          return _SearchMessage(
            icon: Icons.search_off_rounded,
            title: 'no_products_found'.tr,
            subtitle: 'try_different_search'.tr,
            colors: colors,
            onRefresh: _refresh,
          );
        }
        return RefreshIndicator(
          color: colors.accent,
          backgroundColor: colors.cardBg,
          onRefresh: _refresh,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            itemCount: products.length + 1,
            itemBuilder: (_, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    '${products.length} ${products.length == 1 ? 'result'.tr : 'results'.tr}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.text2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SearchProductCard(
                  product: products[index - 1],
                  colors: colors,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final AppColors colors;
  final Widget? trailing;

  const _SectionHeader({
    required this.title,
    required this.colors,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: colors.text3,
            letterSpacing: 0.6,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ─────────────────────────────────────────────
// CHIP  (recent / trending)
// ─────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final AppColors colors;
  final bool highlighted;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.icon,
    required this.colors,
    this.highlighted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = highlighted ? colors.accentLight : colors.cardBg;
    final border = highlighted ? colors.accentLight : colors.border;
    final fg = highlighted ? colors.accent : colors.text1;
    final iconColor = highlighted ? colors.accent : colors.text3;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CATEGORY CHIP / ITEM
// ─────────────────────────────────────────────

class _CategoryChip {
  final String label;
  final IconData icon;
  final Color color;
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.color,
  });
}

class _CategoryItem extends StatelessWidget {
  final _CategoryChip chip;
  final AppColors colors;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.chip,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border),
            ),
            child: Icon(chip.icon, size: 24, color: chip.color),
          ),
          const SizedBox(height: 6),
          Text(
            chip.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colors.text1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SEARCH SKELETON
// ─────────────────────────────────────────────

class _SearchSkeleton extends StatefulWidget {
  final AppColors colors;
  const _SearchSkeleton({required this.colors});

  @override
  State<_SearchSkeleton> createState() => _SearchSkeletonState();
}

class _SearchSkeletonState extends State<_SearchSkeleton>
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
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
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
      builder: (_, __) {
        final base = Color.lerp(
          widget.colors.surface2,
          widget.colors.border,
          _anim.value,
        )!;
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          itemCount: 5,
          itemBuilder: (_, __) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 102,
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// PRODUCT MODEL  ← fixes: quantity is int, fromProduct maps it
// ─────────────────────────────────────────────

class _SearchProduct {
  final int id;
  final String name;
  final String description;
  final int quantity; // ← int, not String
  final String salePrice;
  final String finalPrice;
  final String? discount;
  final String categoryName;
  final String brandName;
  final List<String> images;

  const _SearchProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.salePrice,
    required this.finalPrice,
    required this.discount,
    required this.categoryName,
    required this.brandName,
    required this.images,
  });

  factory _SearchProduct.fromProduct(dynamic product) {
    return _SearchProduct(
      id: product.id as int,
      name: product.name?.toString() ?? '',
      description: product.description?.toString() ?? '',
      quantity: (product.quantity as num?)?.toInt() ?? 0, // ← mapped here
      salePrice: product.salePrice?.toString() ?? '0.00',
      finalPrice: product.finalPrice?.toString() ?? '0.00',
      discount: product.discount?.toString(),
      categoryName: product.categoryName?.toString() ?? '',
      brandName: product.brandName?.toString() ?? '',
      images: product.images is List
          ? List<String>.from((product.images as List).map((e) => e.toString()))
          : const [],
    );
  }
}

// ─────────────────────────────────────────────
// PRODUCT CARD
// ─────────────────────────────────────────────

class _SearchProductCard extends StatelessWidget {
  final _SearchProduct product;
  final AppColors colors;
  const _SearchProductCard({required this.product, required this.colors});

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.images.isNotEmpty ? product.images.first : null;
    final hasDiscount =
        product.discount != null && product.discount!.isNotEmpty;
    final isOutOfStock = product.quantity == 0; // ← now works correctly

    return GestureDetector(
      onTap: isOutOfStock
          ? null
          : () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(productId: product.id),
              ),
            ),
      child: Opacity(
        opacity: isOutOfStock ? 0.55 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.cardBg,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              // ── Image ───────────────────────
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: imageUrl == null
                        ? _ImageFallback(colors: colors)
                        : Image.network(
                            imageUrl,
                            width: 78,
                            height: 78,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _ImageFallback(colors: colors),
                          ),
                  ),
                  if (isOutOfStock)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 78,
                        height: 78,
                        color: Colors.black.withValues(alpha: 0.38),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Out of stock',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 12),

              // ── Body ────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.text1,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        product.brandName.trCatalog,
                        product.categoryName,
                      ].where((t) => t.trim().isNotEmpty).join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.text2, fontSize: 11.5),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '\$${product.finalPrice}',
                          style: TextStyle(
                            color: isOutOfStock ? colors.text3 : colors.accent,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(width: 6),
                          Text(
                            '\$${product.salePrice}',
                            style: TextStyle(
                              color: colors.text3,
                              fontSize: 11.5,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 6),
                          _DiscountBadge(discount: product.discount!),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // ── Chevron ─────────────────────
              if (!isOutOfStock)
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.text3,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DISCOUNT BADGE
// ─────────────────────────────────────────────

class _DiscountBadge extends StatelessWidget {
  final String discount;
  const _DiscountBadge({required this.discount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '−$discount%',
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2E7D32),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// IMAGE FALLBACK
// ─────────────────────────────────────────────

class _ImageFallback extends StatelessWidget {
  final AppColors colors;
  const _ImageFallback({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
      color: colors.surface2,
      child: Icon(Icons.image_outlined, color: colors.text3),
    );
  }
}

// ─────────────────────────────────────────────
// MESSAGE  (error / no results)
// ─────────────────────────────────────────────

class _SearchMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final AppColors colors;
  final Future<void> Function() onRefresh;

  const _SearchMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: colors.accent,
      backgroundColor: colors.cardBg,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 90),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors.surface2,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: colors.text3),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.text1,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.text2, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
