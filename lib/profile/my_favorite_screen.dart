import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mart_frontend/models/myfavorite_model.dart';
import 'package:mart_frontend/screens/cart/floating_cart_bar.dart';
import 'package:mart_frontend/services/api_service.dart';
import 'package:mart_frontend/screens/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'package:mart_frontend/screens/product/product_detail_screen.dart';
// ═══════════════════════════════════════════════════════════════
// THEME SHORTHAND  — null-safe, falls back to a light default
// ═══════════════════════════════════════════════════════════════

extension _CX on BuildContext {
  AppColors get c => Theme.of(this).extension<AppColors>() ?? AppColors.light;
}

// ═══════════════════════════════════════════════════════════════
// MY FAVORITE SCREEN
// ═══════════════════════════════════════════════════════════════

class MyFavoriteScreen extends StatefulWidget {
  const MyFavoriteScreen({super.key});

  @override
  State<MyFavoriteScreen> createState() => _MyFavoriteScreenState();
}

class _MyFavoriteScreenState extends State<MyFavoriteScreen>
    with SingleTickerProviderStateMixin {
  List<MyFavoriteModel> _items = [];
  bool _loading = true;
  String? _error;
  bool _isGrid = true;
  final Set<int> _removing = {};

  late final AnimationController _enterCtrl;
  late final Animation<double> _enterFade;
  late final Animation<Offset> _enterSlide;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _enterFade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _enterSlide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));

    _load();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final raw = await ApiService().getMyFavorites();
      if (!mounted) return;

      // safe parse — skip any null / malformed entries
      final parsed = <MyFavoriteModel>[];
      for (final e in raw) {
        try {
          parsed.add(MyFavoriteModel.fromJson(e as Map<String, dynamic>));
        } catch (_) {}
      }

      setState(() {
        _items = parsed;
        _loading = false;
      });
      _enterCtrl.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _remove(MyFavoriteModel fav) async {
    HapticFeedback.mediumImpact();
    setState(() => _removing.add(fav.id));
    await Future.delayed(const Duration(milliseconds: 320));
    if (!mounted) return;

    final index = _items.indexWhere((i) => i.id == fav.id);
    setState(() {
      if (index != -1) _items.removeAt(index);
      _removing.remove(fav.id);
    });

    try {
      await ApiService().removeFavorite(fav.product.id);
    } catch (e) {
      if (!mounted) return;
      // Roll back: put the item back where it was and let the user know.
      setState(() {
        final restoreIndex = index.clamp(0, _items.length);
        _items.insert(restoreIndex, fav);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not remove favorite. Please try again.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _addToCart(MyFavoriteModel fav) async {
    HapticFeedback.lightImpact();

    try {
      await ApiService().addToCart(productId: fav.product.id, quantity: 1);

      if (!mounted) return;

      await context.read<CartProvider>().fetchCart();

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('${fav.product.name} added to cart'),
      //     behavior: SnackBarBehavior.floating,
      //   ),
      // );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _AppBar(
                  c: c,
                  count: _items.length,
                  isGrid: _isGrid,
                  onToggle: () {
                    HapticFeedback.selectionClick();
                    setState(() => _isGrid = !_isGrid);
                  },
                ),
                Expanded(child: _buildBody(c)),
              ],
            ),
          ),

          const FloatingCartBar(),
        ],
      ),
    );
  }

  // FIX: the skeleton loader previously always rendered as a grid,
  // even when the user had toggled to list view — so refreshing in
  // list mode would flash a mismatched grid skeleton. Now the loader
  // is told which layout to mimic.
  Widget _buildBody(AppColors c) {
    if (_loading) return _Loader(c: c, isGrid: _isGrid);
    if (_error != null) return _ErrorView(c: c, error: _error!, onRetry: _load);
    if (_items.isEmpty) return _EmptyView(c: c);

    return FadeTransition(
      opacity: _enterFade,
      child: SlideTransition(
        position: _enterSlide,
        child: _isGrid ? _buildGrid(c) : _buildList(c),
      ),
    );
  }

  Widget _buildGrid(AppColors c) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((_, i) {
              final fav = _items[i];
              return _GridCard(
                fav: fav,
                c: c,
                removing: _removing.contains(fav.id),
                onRemove: () => _remove(fav),
                onAddToCart: () => _addToCart(fav),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailScreen(productId: fav.product.id),
                    ),
                  );

                  if (mounted) {
                    _load();
                  }
                },
                delay: Duration(milliseconds: i * 45),
              );
            }, childCount: _items.length),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.72,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildList(AppColors c) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final fav = _items[i];
        return _ListCard(
          fav: fav,
          c: c,
          removing: _removing.contains(fav.id),
          onRemove: () => _remove(fav),
          onAddToCart: () => _addToCart(fav),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(productId: fav.product.id),
              ),
            );

            if (mounted) {
              _load();
            }
          },
          delay: Duration(milliseconds: i * 40),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// APP BAR
// ═══════════════════════════════════════════════════════════════

class _AppBar extends StatelessWidget {
  final AppColors c;
  final int count;
  final bool isGrid;
  final VoidCallback onToggle;

  const _AppBar({
    required this.c,
    required this.count,
    required this.isGrid,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      decoration: BoxDecoration(
        color: c.background,
        border: Border(bottom: BorderSide(color: c.border, width: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            // FIX: Navigator.pop(context) would throw if this screen is
            // ever the root route (nothing to pop back to). Guard with
            // canPop so tapping back is always safe.
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: c.border, width: 1),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 15,
                color: c.text2,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Favorites',
                  style: TextStyle(
                    color: c.text1,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                if (count > 0)
                  Text(
                    '$count saved item${count == 1 ? '' : 's'}',
                    style: TextStyle(
                      color: c.text3,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: c.border, width: 1),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
                  key: ValueKey(isGrid),
                  size: 18,
                  color: c.text2,
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
// HELPERS
// ═══════════════════════════════════════════════════════════════

/// Safe price display — never crashes on empty/null strings
String _displayPrice(Product p) {
  final sale = double.tryParse(p.salePrice) ?? 0.0;
  if (p.finalPrice > 0 && p.finalPrice < sale) {
    return '\$${p.finalPrice}';
  }
  return '\$${sale.toStringAsFixed(2)}';
}

String? _strikePrice(Product p) {
  final sale = double.tryParse(p.salePrice) ?? 0.0;
  if (p.finalPrice > 0 && p.finalPrice < sale) {
    return '\$${sale.toStringAsFixed(2)}';
  }
  return null;
}

double _discountPct(Product p) => double.tryParse(p.discountValue ?? '') ?? 0.0;

bool _inStock(Product p) => p.status && p.quantity > 0;

// ═══════════════════════════════════════════════════════════════
// GRID CARD
// ═══════════════════════════════════════════════════════════════

class _GridCard extends StatefulWidget {
  final MyFavoriteModel fav;
  final AppColors c;
  final bool removing;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;
  final Duration delay;
  final VoidCallback onTap;

  const _GridCard({
    required this.fav,
    required this.c,
    required this.removing,
    required this.onRemove,
    required this.onAddToCart,
    required this.delay,
    required this.onTap,
  });

  @override
  State<_GridCard> createState() => _GridCardState();
}

class _GridCardState extends State<_GridCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.fav.product;
    final c = widget.c;
    final pct = _discountPct(p);
    final strike = _strikePrice(p);
    final inStock = _inStock(p);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: AnimatedOpacity(
          opacity: widget.removing ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 280),
          child: AnimatedScale(
            scale: widget.removing ? 0.88 : 1.0,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInCubic,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onTap();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: c.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: c.border, width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // image zone
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: p.firstImage.imageUrl,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(height: 150, color: c.surface2),
                            errorWidget: (_, __, ___) => Container(
                              height: 150,
                              color: c.accentLight,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.image_outlined,
                                size: 36,
                                color: c.accent,
                              ),
                            ),
                          ),
                        ),
                        if (pct > 0)
                          Positioned(
                            top: 10,
                            left: 10,
                            child: _DiscountBadge(
                              pct: pct,
                              type: p.discountType,
                            ),
                          ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: _HeartBtn(c: c, onTap: widget.onRemove),
                        ),
                        if (!inStock)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                              child: Container(
                                color: Colors.black.withOpacity(0.45),
                                alignment: Alignment.center,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.75),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Out of Stock',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    // info
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: c.text1,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _UnitBadge(c: c, unit: p.unit),
                            const Spacer(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (strike != null)
                                        Text(
                                          strike,
                                          style: TextStyle(
                                            color: c.text3,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            decoration:
                                                TextDecoration.lineThrough,
                                            decorationColor: c.text3,
                                          ),
                                        ),
                                      Text(
                                        _displayPrice(p),
                                        style: TextStyle(
                                          color: c.accent,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (inStock)
                                  _MiniCartBtn(c: c, onTap: widget.onAddToCart),
                              ],
                            ),
                          ],
                        ),
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

// ═══════════════════════════════════════════════════════════════
// LIST CARD
// ═══════════════════════════════════════════════════════════════

class _ListCard extends StatefulWidget {
  final MyFavoriteModel fav;
  final AppColors c;
  final bool removing;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;
  final Duration delay;
  final VoidCallback onTap;

  const _ListCard({
    required this.fav,
    required this.c,
    required this.removing,
    required this.onRemove,
    required this.onAddToCart,
    required this.delay,
    required this.onTap,
  });

  @override
  State<_ListCard> createState() => _ListCardState();
}

class _ListCardState extends State<_ListCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0.04, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.fav.product;
    final c = widget.c;
    final pct = _discountPct(p);
    final strike = _strikePrice(p);
    final inStock = _inStock(p);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: AnimatedOpacity(
          opacity: widget.removing ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 280),
          child: AnimatedScale(
            scale: widget.removing ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 280),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onTap();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: c.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: c.border, width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(20),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: p.firstImage.imageUrl,
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              width: 110,
                              height: 110,
                              color: c.surface2,
                            ),
                            errorWidget: (_, __, ___) => Container(
                              width: 110,
                              height: 110,
                              color: c.accentLight,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.image_outlined,
                                size: 30,
                                color: c.accent,
                              ),
                            ),
                          ),
                        ),
                        if (!inStock)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(20),
                              ),
                              child: Container(
                                color: Colors.black.withOpacity(0.45),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Out of\nStock',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (pct > 0)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: _DiscountBadge(
                              pct: pct,
                              type: p.discountType,
                            ),
                          ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    p.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: c.text1,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                _HeartBtn(c: c, onTap: widget.onRemove),
                              ],
                            ),
                            const SizedBox(height: 6),
                            _UnitBadge(c: c, unit: p.unit),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: inStock
                                        ? const Color(0xFF22C55E)
                                        : c.text3,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  inStock
                                      ? 'In stock (${p.quantity})'
                                      : 'Out of stock',
                                  style: TextStyle(
                                    color: inStock
                                        ? const Color(0xFF22C55E)
                                        : c.text3,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (strike != null)
                                      Text(
                                        strike,
                                        style: TextStyle(
                                          color: c.text3,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          decorationColor: c.text3,
                                        ),
                                      ),
                                    Text(
                                      _displayPrice(p),
                                      style: TextStyle(
                                        color: c.accent,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                if (inStock)
                                  _AddToCartBtn(
                                    c: c,
                                    onTap: widget.onAddToCart,
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
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HEART BUTTON
// ═══════════════════════════════════════════════════════════════

class _HeartBtn extends StatefulWidget {
  final AppColors c;
  final VoidCallback onTap;
  const _HeartBtn({required this.c, required this.onTap});

  @override
  State<_HeartBtn> createState() => _HeartBtnState();
}

class _HeartBtnState extends State<_HeartBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween(
      begin: 1.0,
      end: 0.78,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFFF3B30).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.favorite_rounded,
            color: Color(0xFFFF3B30),
            size: 17,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MINI CART BUTTON
// ═══════════════════════════════════════════════════════════════

class _MiniCartBtn extends StatefulWidget {
  final AppColors c;
  final VoidCallback onTap;
  const _MiniCartBtn({required this.c, required this.onTap});

  @override
  State<_MiniCartBtn> createState() => _MiniCartBtnState();
}

class _MiniCartBtnState extends State<_MiniCartBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _scale = Tween(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: c.accent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: c.accent.withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.add_shopping_cart_rounded,
            color: Colors.white,
            size: 17,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ADD TO CART BUTTON
// ═══════════════════════════════════════════════════════════════

class _AddToCartBtn extends StatefulWidget {
  final AppColors c;
  final VoidCallback onTap;
  const _AddToCartBtn({required this.c, required this.onTap});

  @override
  State<_AddToCartBtn> createState() => _AddToCartBtnState();
}

class _AddToCartBtnState extends State<_AddToCartBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _scale = Tween(
      begin: 1.0,
      end: 0.93,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: c.accent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: c.accent.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_shopping_cart_rounded,
                color: Colors.white,
                size: 15,
              ),
              SizedBox(width: 6),
              Text(
                'Add to Cart',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DISCOUNT BADGE
// ═══════════════════════════════════════════════════════════════

// FIX: `type` is now nullable to match Product.discountType (String?)
// in the updated model, where discount_type can legitimately be null
// in the API response. Falls back to a generic "-N" label when the
// type isn't specified, instead of crashing on null.toLowerCase().
class _DiscountBadge extends StatelessWidget {
  final double pct;
  final String? type;
  const _DiscountBadge({required this.pct, required this.type});

  @override
  Widget build(BuildContext context) {
    final label = type?.toLowerCase() == 'percent'
        ? '-${pct.toStringAsFixed(0)}%'
        : '-\$${pct.toStringAsFixed(0)}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFF3B30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// UNIT BADGE
// ═══════════════════════════════════════════════════════════════

class _UnitBadge extends StatelessWidget {
  final AppColors c;
  final String unit;
  const _UnitBadge({required this.c, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c.border, width: 0.5),
      ),
      child: Text(
        unit.toLowerCase(),
        style: TextStyle(
          color: c.text3,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SKELETON LOADER
// ═══════════════════════════════════════════════════════════════

// FIX: now aware of the current view mode so the loading skeleton
// matches whatever layout (grid or list) the user is currently on.
class _Loader extends StatelessWidget {
  final AppColors c;
  final bool isGrid;
  const _Loader({required this.c, required this.isGrid});

  @override
  Widget build(BuildContext context) {
    if (!isGrid) {
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => _SkeletonCard(c: c, isGrid: false),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      itemCount: 6,
      itemBuilder: (_, i) => _SkeletonCard(c: c, isGrid: true),
    );
  }
}

class _SkeletonCard extends StatefulWidget {
  final AppColors c;
  final bool isGrid;
  const _SkeletonCard({required this.c, this.isGrid = true});

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
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final bg = Color.lerp(c.surface, c.surface2, _anim.value)!;

        Widget bar({double? width, double height = 13}) {
          return Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(6),
            ),
          );
        }

        final infoColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            bar(),
            const SizedBox(height: 6),
            bar(width: 80),
            const SizedBox(height: 10),
            bar(width: 60, height: 16),
          ],
        );

        if (!widget.isGrid) {
          // List-mode skeleton: thumbnail on the left, text lines on the right.
          return Container(
            decoration: BoxDecoration(
              color: c.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.border, width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(20),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: infoColumn,
                  ),
                ),
              ],
            ),
          );
        }

        // Grid-mode skeleton.
        return Container(
          decoration: BoxDecoration(
            color: c.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: c.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
              ),
              Padding(padding: const EdgeInsets.all(10), child: infoColumn),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ERROR VIEW
// ═══════════════════════════════════════════════════════════════

class _ErrorView extends StatelessWidget {
  final AppColors c;
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({
    required this.c,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: c.surface2,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off_rounded, size: 34, color: c.text3),
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load favorites',
              style: TextStyle(
                color: c.text1,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: c.text3, fontSize: 13),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: c.accent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: c.accent.withOpacity(0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.white, size: 17),
                    SizedBox(width: 7),
                    Text(
                      'Try Again',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// EMPTY VIEW
// ═══════════════════════════════════════════════════════════════

class _EmptyView extends StatelessWidget {
  final AppColors c;
  const _EmptyView({required this.c});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFFF3B30).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 46,
                color: Color(0xFFFF3B30),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Favorites Yet',
              style: TextStyle(
                color: c.text1,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the heart icon on any product\nto save it here for later.',
              textAlign: TextAlign.center,
              style: TextStyle(color: c.text3, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: c.accent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: c.accent.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Text(
                  'Start Shopping',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
