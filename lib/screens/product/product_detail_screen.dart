import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mart_frontend/auth/login_screen.dart';
import 'package:mart_frontend/providers/ProductDetailProvider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../translations/catalog_translation.dart';
import '../../services/wishlist_service.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────────────────────

abstract class _T {
  static const double sp4 = 4;
  static const double sp6 = 6;
  static const double sp8 = 8;
  static const double sp10 = 10;
  static const double sp12 = 12;
  static const double sp14 = 14;
  static const double sp16 = 16;
  static const double sp20 = 20;
  static const double sp24 = 24;
  static const double sp32 = 32;

  static const double radiusSm = 6;
  static const double radiusMd = 10;
  static const double radiusLg = 14;
  static const double radiusFull = 999;

  static TextStyle productName(Color c) => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: c,
    height: 1.3,
    letterSpacing: -.2,
  );

  static TextStyle priceMain(Color c) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: c,
    letterSpacing: -.4,
  );

  static TextStyle priceOld(Color c) => TextStyle(
    fontSize: 13,
    color: c,
    decoration: TextDecoration.lineThrough,
    decorationColor: c,
  );

  static TextStyle sectionLabel(Color c) =>
      TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: c);

  static TextStyle bodyText(Color c) =>
      TextStyle(fontSize: 13, color: c, height: 1.65);

  static TextStyle chipLabel(Color c) =>
      TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: c);

  static TextStyle qtyNum(Color c) =>
      TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c);

  static TextStyle ctaLabel(Color c) => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: c,
    letterSpacing: .2,
  );

  static TextStyle discountTag(Color c) =>
      TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c);
}

// ─────────────────────────────────────────────────────────────
// SHIMMER
// ─────────────────────────────────────────────────────────────

class _Shimmer extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;
  const _Shimmer({this.width, required this.height, this.borderRadius = 6});

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
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? colors.surface : colors.surface2;
    final highlight = isDark ? colors.surface2 : colors.background;
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
// SKELETON
// ─────────────────────────────────────────────────────────────

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mq = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          // image area — full width, no padding
          _Shimmer(
            width: double.infinity,
            height: mq.size.height * .44,
            borderRadius: 0,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                _T.sp16,
                _T.sp16,
                _T.sp16,
                _T.sp16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // chips
                  Row(
                    children: const [
                      _Shimmer(
                        width: 80,
                        height: 24,
                        borderRadius: _T.radiusFull,
                      ),
                      SizedBox(width: _T.sp8),
                      _Shimmer(
                        width: 60,
                        height: 24,
                        borderRadius: _T.radiusFull,
                      ),
                      SizedBox(width: _T.sp8),
                      _Shimmer(
                        width: 70,
                        height: 24,
                        borderRadius: _T.radiusFull,
                      ),
                    ],
                  ),
                  const SizedBox(height: _T.sp12),
                  const _Shimmer(
                    width: double.infinity,
                    height: 20,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: _T.sp6),
                  const _Shimmer(width: 160, height: 20, borderRadius: 4),
                  const SizedBox(height: _T.sp10),
                  const _Shimmer(width: 100, height: 26, borderRadius: 4),
                  const SizedBox(height: _T.sp20),
                  const _Shimmer(width: 60, height: 12, borderRadius: 3),
                  const SizedBox(height: _T.sp8),
                  ...List.generate(
                    3,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: _T.sp6),
                      child: _Shimmer(
                        width: i == 2 ? 140 : double.infinity,
                        height: 13,
                        borderRadius: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: _T.sp20),
                  const _Shimmer(
                    width: double.infinity,
                    height: .5,
                    borderRadius: 0,
                  ),
                  const SizedBox(height: _T.sp14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _Shimmer(width: 60, height: 14, borderRadius: 4),
                      _Shimmer(
                        width: 110,
                        height: 38,
                        borderRadius: _T.radiusMd,
                      ),
                    ],
                  ),
                  const SizedBox(height: _T.sp20),
                  const _Shimmer(
                    width: double.infinity,
                    height: .5,
                    borderRadius: 0,
                  ),
                  const SizedBox(height: _T.sp14),
                  Row(
                    children: const [
                      _Shimmer(
                        width: 48,
                        height: 48,
                        borderRadius: _T.radiusLg,
                      ),
                      SizedBox(width: _T.sp10),
                      Expanded(
                        child: _Shimmer(height: 48, borderRadius: _T.radiusLg),
                      ),
                    ],
                  ),
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
// ERROR STATE
// ─────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState();
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(_T.sp32),
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
            const SizedBox(height: _T.sp16),
            Text(
              'failed_to_load_product'.tr,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.text2,
              ),
            ),
            const SizedBox(height: _T.sp6),
            Text(
              'please_try_again'.tr,
              style: TextStyle(fontSize: 12, color: colors.text3),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// DOT INDICATOR
// ─────────────────────────────────────────────────────────────

class _DotIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;
  const _DotIndicator({required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? colors.text1 : colors.border,
            borderRadius: BorderRadius.circular(_T.radiusFull),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CHIP
// ─────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color textColor;
  final Color borderColor;
  final IconData? icon;

  const _Chip({
    required this.label,
    required this.bg,
    required this.textColor,
    required this.borderColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _T.sp10,
        vertical: _T.sp4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(_T.radiusFull),
        border: Border.all(color: borderColor, width: .8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: textColor),
            const SizedBox(width: 3),
          ],
          Text(label, style: _T.chipLabel(textColor)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// QUANTITY STEPPER
// ─────────────────────────────────────────────────────────────

class _QuantityStepper extends StatelessWidget {
  final int qty;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityStepper({
    required this.qty,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(_T.radiusMd),
        border: Border.all(color: colors.border, width: .8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: qty > 1 ? onDecrement : null,
            child: SizedBox(
              width: 38,
              height: 38,
              child: Icon(
                Icons.remove_rounded,
                size: 15,
                color: qty > 1 ? colors.text1 : colors.border,
              ),
            ),
          ),
          Container(width: .8, height: 22, color: colors.border),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: SizedBox(
              key: ValueKey(qty),
              width: 34,
              child: Text(
                '$qty',
                textAlign: TextAlign.center,
                style: _T.qtyNum(colors.text1),
              ),
            ),
          ),
          Container(width: .8, height: 22, color: colors.border),
          GestureDetector(
            onTap: onIncrement,
            child: SizedBox(
              width: 38,
              height: 38,
              child: Icon(Icons.add_rounded, size: 15, color: colors.text1),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// WISHLIST BUTTON
// ─────────────────────────────────────────────────────────────

class _WishlistButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  const _WishlistButton({required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius: BorderRadius.circular(_T.radiusLg),
          border: Border.all(color: colors.border, width: .8),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            key: ValueKey(isFavorite),
            size: 20,
            color: isFavorite ? colors.flashText : colors.text2,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CART BUTTON
// ─────────────────────────────────────────────────────────────

class _CartButton extends StatelessWidget {
  final bool isInCart;
  final bool loading;
  final VoidCallback onTap;
  const _CartButton({
    required this.isInCart,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: GestureDetector(
        onTap: loading ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 50,
          decoration: BoxDecoration(
            color: loading ? colors.accentLight : colors.accent,
            borderRadius: BorderRadius.circular(_T.radiusLg),
          ),
          child: Center(
            child: loading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.accent,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isInCart
                            ? Icons.shopping_cart_checkout_rounded
                            : Icons.shopping_cart_outlined,
                        color: colors.surface,
                        size: 18,
                      ),
                      const SizedBox(width: _T.sp8),
                      Text(
                        isInCart ? 'update_cart'.tr : 'add_to_cart'.tr,
                        style: _T.ctaLabel(colors.surface),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// EXPANDABLE DESCRIPTION
// ─────────────────────────────────────────────────────────────

class _ExpandableDesc extends StatefulWidget {
  final String text;
  const _ExpandableDesc({required this.text});
  @override
  State<_ExpandableDesc> createState() => _ExpandableDescState();
}

class _ExpandableDescState extends State<_ExpandableDesc> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final long = widget.text.length > 130;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: Text(
            widget.text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: _T.bodyText(colors.text2),
          ),
          secondChild: Text(widget.text, style: _T.bodyText(colors.text2)),
        ),
        if (long) ...[
          const SizedBox(height: _T.sp4),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded ? 'show_less'.tr : 'read_more'.tr,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.accent,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PRODUCT DETAIL SCREEN
// ─────────────────────────────────────────────────────────────

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  late Future<dynamic> productFuture;

  int qty = 1;
  int cartQty = 0;
  bool isInCart = false;
  bool cartLoading = false;
  bool isFavorite = false;
  int imageIndex = 0;

  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    productFuture = context.read<ProductDetailProvider>().getOrFetch(
      widget.productId,
    );
    _loadCartQty();
    _loadFavorite();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCartQty() async {
    try {
      final q = await ApiService().getCartQuantity(productId: widget.productId);
      if (mounted)
        setState(() {
          cartQty = q;
          qty = q > 0 ? q : 1;
          isInCart = q > 0;
        });
    } catch (_) {}
  }

  Future<void> _handleCart(dynamic p) async {
    final loggedIn = await _checkLogin();

    if (!loggedIn) return;

    setState(() => cartLoading = true);

    try {
      if (isInCart) {
        await ApiService().updateCart(
          productId: widget.productId,
          quantity: qty,
        );
      } else {
        await ApiService().addToCart(
          productId: widget.productId,
          quantity: qty,
        );
      }

      if (mounted) {
        context.read<CartProvider>().fetchCart();

        Navigator.of(context).popUntil((route) => route.isFirst);

        Future.delayed(const Duration(milliseconds: 300), () {
          context.read<CartProvider>().fetchCart();
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() => cartLoading = false);
      }
    }
  }

  // Future<void> _handleCart(dynamic p) async {
  //   setState(() => cartLoading = true);
  //   try {
  //     if (isInCart) {
  //       await ApiService().updateCart(
  //         productId: widget.productId,
  //         quantity: qty,
  //       );
  //     } else {
  //       await ApiService().addToCart(
  //         productId: widget.productId,
  //         quantity: qty,
  //       );
  //     }
  //     if (mounted) {
  //       setState(() {
  //         isInCart = true;
  //         cartQty = qty;
  //       });
  //       context.read<CartProvider>().fetchCart();
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(isInCart ? 'cart_updated'.tr : 'added_to_cart'.tr),
  //           duration: const Duration(milliseconds: 900),
  //         ),
  //       );
  //     }
  //   } catch (_) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text('something_went_wrong'.tr)));
  //     }
  //   } finally {
  //     if (mounted) setState(() => cartLoading = false);
  //   }
  // }

  Future<void> _loadFavorite() async {
    final saved = await WishlistService().isFavorite(widget.productId);
    if (mounted) setState(() => isFavorite = saved);
  }

  Future<void> _toggleFavourite() async {
    final loggedIn = await _checkLogin();

    if (!loggedIn) return;

    HapticFeedback.lightImpact();

    final saved = await WishlistService().toggle(widget.productId);

    if (mounted) {
      setState(() => isFavorite = saved);
    }

    _fadeCtrl.forward(from: 0);
  }

  Future<bool> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      if (!mounted) return false;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );

      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mq = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: FutureBuilder(
        future: productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return const _DetailSkeleton();
          }
          if (snapshot.hasError) {
            return const SafeArea(child: _ErrorState());
          }

          final p = snapshot.data;
          final images = (p.images as List?) ?? [];
          final finalPrice = double.tryParse(p.finalPrice.toString()) ?? 0;
          final salePrice = double.tryParse(p.salePrice?.toString() ?? '') ?? 0;
          final hasDiscount = p.discount != null && salePrice > finalPrice;
          final discountPct = hasDiscount
              ? '-${(((salePrice - finalPrice) / salePrice) * 100).round()}%'
              : null;
          final stockQty = (p.quantity as int?) ?? 0;
          final inStock = stockQty > 0;

          return FadeTransition(
            opacity: _fade,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── SliverAppBar — image fills top, floats
                //    back & wishlist buttons over it ─────────
                SliverAppBar(
                  backgroundColor: Colors.white,
                  expandedHeight: mq.size.height * .44,
                  pinned: false,
                  floating: false,
                  automaticallyImplyLeading: false,
                  surfaceTintColor: Colors.transparent,

                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // ── images ──
                        if (images.isNotEmpty)
                          PageView.builder(
                            itemCount: images.length,
                            onPageChanged: (i) =>
                                setState(() => imageIndex = i),
                            itemBuilder: (_, i) => Container(
                              margin: const EdgeInsets.fromLTRB(24, 80, 24, 40),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: CachedNetworkImage(
                                  imageUrl: images[i] as String,
                                  fit: BoxFit.contain,
                                  errorWidget: (_, __, ___) => Icon(
                                    Icons.image_outlined,
                                    size: 56,
                                    color: colors.text3,
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 56,
                              color: colors.text3,
                            ),
                          ),

                        // ── back button (top-left) ──
                        Positioned(
                          top: mq.padding.top + _T.sp10,
                          left: _T.sp16,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: colors.cardBg.withOpacity(.88),
                                borderRadius: BorderRadius.circular(
                                  _T.radiusMd,
                                ),
                                border: Border.all(
                                  color: colors.border,
                                  width: .5,
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 14,
                                color: colors.text1,
                              ),
                            ),
                          ),
                        ),

                        // ── wishlist button (top-right) ──
                        Positioned(
                          top: mq.padding.top + _T.sp10,
                          right: _T.sp16,
                          child: GestureDetector(
                            onTap: _toggleFavourite,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: colors.cardBg.withOpacity(.88),
                                borderRadius: BorderRadius.circular(
                                  _T.radiusMd,
                                ),
                                border: Border.all(
                                  color: colors.border,
                                  width: .5,
                                ),
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                transitionBuilder: (c, a) =>
                                    ScaleTransition(scale: a, child: c),
                                child: Icon(
                                  isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  key: ValueKey(isFavorite),
                                  size: 16,
                                  color: isFavorite
                                      ? colors.flashText
                                      : colors.text2,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ── dot indicators (bottom-center) ──
                        if (images.length > 1)
                          Positioned(
                            bottom: _T.sp14,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: _DotIndicator(
                                count: images.length,
                                activeIndex: imageIndex,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ── Content ────────────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    color: colors.background,
                    padding: EdgeInsets.fromLTRB(
                      _T.sp16,
                      _T.sp16,
                      _T.sp16,
                      mq.padding.bottom + _T.sp24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Chips row ──────────────────────────────────
                        Wrap(
                          spacing: _T.sp6,
                          runSpacing: _T.sp6,
                          children: [
                            if ((p.categoryName as String?)?.isNotEmpty == true)
                              _Chip(
                                label: p.categoryName as String,
                                bg: colors.bginfo,
                                textColor: colors.text2,
                                borderColor: colors.border,
                                icon: Icons.sell_outlined,
                              ),
                            if ((p.brandName as String?)?.isNotEmpty == true)
                              _Chip(
                                label: (p.brandName as String).trCatalog,
                                bg: colors.bginfo,
                                textColor: colors.text2,
                                borderColor: colors.border,
                                icon: Icons.storefront_outlined,
                              ),
                            _Chip(
                              label: inStock
                                  ? '${'in_stock'.tr} · $stockQty'
                                  : 'out_of_stock'.tr,
                              bg: inStock ? colors.accentLight : colors.flashBg,
                              textColor: inStock
                                  ? colors.accent
                                  : colors.flashText,
                              borderColor: inStock
                                  ? colors.accent.withOpacity(.25)
                                  : colors.flashBorder,
                              icon: inStock
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.cancel_outlined,
                            ),
                          ],
                        ),

                        const SizedBox(height: _T.sp14),

                        // ── Name ───────────────────────────────────────
                        Text(
                          p.name as String,
                          style: _T.productName(colors.text1),
                        ),

                        const SizedBox(height: _T.sp10),

                        // ── Price ──────────────────────────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '\$${p.finalPrice}',
                              style: _T.priceMain(colors.text1),
                            ),
                            if (hasDiscount) ...[
                              const SizedBox(width: _T.sp8),
                              Text(
                                '\$${p.salePrice}',
                                style: _T.priceOld(colors.text3),
                              ),
                              const SizedBox(width: _T.sp8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: _T.sp8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.flashBg,
                                  borderRadius: BorderRadius.circular(
                                    _T.radiusFull,
                                  ),
                                  border: Border.all(
                                    color: colors.flashBorder,
                                    width: .5,
                                  ),
                                ),
                                child: Text(
                                  discountPct!,
                                  style: _T.discountTag(colors.flashText),
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: _T.sp20),

                        // ── Description ────────────────────────────────
                        Text(
                          'description'.tr,
                          style: _T.sectionLabel(colors.text3),
                        ),
                        const SizedBox(height: _T.sp6),
                        _ExpandableDesc(text: (p.description as String?) ?? ''),

                        const SizedBox(height: _T.sp20),
                        Divider(color: colors.border, height: 1, thickness: .5),
                        const SizedBox(height: _T.sp14),

                        // ── Quantity ───────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'quantity'.tr,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: colors.text1,
                              ),
                            ),
                            _QuantityStepper(
                              qty: qty,
                              onIncrement: () => setState(() => qty++),
                              onDecrement: () {
                                if (qty > 1) setState(() => qty--);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: _T.sp20),
                        Divider(color: colors.border, height: 1, thickness: .5),
                        const SizedBox(height: _T.sp14),

                        // ── CTA ────────────────────────────────────────
                        Row(
                          children: [
                            _WishlistButton(
                              isFavorite: isFavorite,
                              onTap: _toggleFavourite,
                            ),
                            const SizedBox(width: _T.sp10),
                            _CartButton(
                              isInCart: isInCart,
                              loading: cartLoading,

                              onTap: () => _handleCart(p),
                            ),
                          ],
                        ),
                      ],
                    ),
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
