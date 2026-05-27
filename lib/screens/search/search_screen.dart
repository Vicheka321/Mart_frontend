import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/api_service.dart';
import '../../translations/catalog_translation.dart';
import '../../widgets/skeleton_loader.dart';
import '../product/product_detail_screen.dart';
import '../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<_SearchProduct>> _productsFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<_SearchProduct>> _loadProducts() async {
    final results = await Future.wait<List<dynamic>>([
      ApiService().fetchAllBestSellers(),
      ApiService().fetchAllNewArrivals(),
      ApiService().fetchAllRecommended(),
    ]);

    final byId = <int, _SearchProduct>{};
    for (final group in results) {
      for (final item in group) {
        final product = _SearchProduct.fromProduct(item);
        byId[product.id] = product;
      }
    }

    final products = byId.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return products;
  }

  List<_SearchProduct> _filter(List<_SearchProduct> products) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return products;

    return products.where((product) {
      return product.name.toLowerCase().contains(q) ||
          product.brandName.toLowerCase().contains(q) ||
          product.brandName.trCatalog.toLowerCase().contains(q) ||
          product.categoryName.toLowerCase().contains(q) ||
          product.description.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _refresh() async {
    setState(() => _productsFuture = _loadProducts());
    await _productsFuture;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: colors.text1,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('search_products'.tr),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: TextStyle(color: colors.text1),
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'search_hint'.tr,
                hintStyle: TextStyle(color: colors.text3),
                prefixIcon: Icon(Icons.search_rounded, color: colors.text2),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(Icons.close_rounded, color: colors.text2),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                filled: true,
                fillColor: colors.cardBg,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: colors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: colors.accent, width: 1.4),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<_SearchProduct>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SkeletonList(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 32),
                  );
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
                    itemCount: products.length,
                    itemBuilder: (_, index) => _SearchProductCard(
                      product: products[index],
                      colors: colors,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchProduct {
  final int id;
  final String name;
  final String description;
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

class _SearchProductCard extends StatelessWidget {
  final _SearchProduct product;
  final AppColors colors;

  const _SearchProductCard({required this.product, required this.colors});

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.images.isNotEmpty ? product.images.first : null;
    final hasDiscount =
        product.discount != null && product.discount!.isNotEmpty;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: product.id),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.18
                    : 0.05,
              ),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
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
                      errorBuilder: (context, error, stackTrace) =>
                          _ImageFallback(colors: colors),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.text1,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    [
                      product.brandName.trCatalog,
                      product.categoryName,
                    ].where((text) => text.trim().isNotEmpty).join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.text2, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        '\$${product.finalPrice}',
                        style: TextStyle(
                          color: colors.accent,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 8),
                        Text(
                          '\$${product.salePrice}',
                          style: TextStyle(
                            color: colors.text3,
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.text3),
          ],
        ),
      ),
    );
  }
}

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
          const SizedBox(height: 120),
          Icon(icon, size: 58, color: colors.text3),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.text1,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.text2, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
