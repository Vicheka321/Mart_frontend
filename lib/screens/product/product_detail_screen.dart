import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mart_frontend/auth/login_screen.dart';
import 'package:mart_frontend/providers/ProductDetailProvider.dart';
import 'package:mart_frontend/screens/cart/cart_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../translations/catalog_translation.dart';
// import '../../services/wishlist_service.dart';
import '../theme/app_theme.dart';
import 'dart:ui';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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

  static const double radiusSm = 8;
  static const double radiusMd = 14;
  static const double radiusLg = 18;
  static const double radiusXl = 26;
  static const double radiusFull = 999;

  // Layout switches to a side-by-side view at/above this width.
  static const double tabletBreakpoint = 720;

  // Soft, premium elevation — used sparingly on floating surfaces only.
  static List<BoxShadow> cardShadow(Color tint, {double opacity = .06}) => [
    BoxShadow(
      color: tint.withOpacity(opacity),
      blurRadius: 24,
      offset: const Offset(0, 10),
      spreadRadius: -6,
    ),
  ];

  static List<BoxShadow> softShadow(Color tint, {double opacity = .08}) => [
    BoxShadow(
      color: tint.withOpacity(opacity),
      blurRadius: 14,
      offset: const Offset(0, 4),
      spreadRadius: -4,
    ),
  ];

  static TextStyle productName(Color c) => TextStyle(
    fontSize: 23,
    fontWeight: FontWeight.w700,
    color: c,
    height: 1.28,
    letterSpacing: -.4,
  );

  static TextStyle priceMain(Color c) => TextStyle(
    fontSize: 27,
    fontWeight: FontWeight.w800,
    color: c,
    letterSpacing: -.6,
  );

  static TextStyle priceOld(Color c) => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: c,
    decoration: TextDecoration.lineThrough,
    decorationColor: c,
  );

  static TextStyle sectionLabel(Color c) => TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w700,
    color: c,
    letterSpacing: .6,
  );

  static TextStyle bodyText(Color c) =>
      TextStyle(fontSize: 13.5, color: c, height: 1.7, letterSpacing: .1);

  static TextStyle chipLabel(Color c) =>
      TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c);

  static TextStyle qtyNum(Color c) =>
      TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c);

  static TextStyle ctaLabel(Color c) => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: c,
    letterSpacing: .1,
  );

  static TextStyle discountTag(Color c) =>
      TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c);
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
        horizontal: _T.sp12,
        vertical: _T.sp6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(_T.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
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
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: BorderRadius.circular(_T.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: qty > 1 ? onDecrement : null,
            child: SizedBox(
              width: 36,
              height: 40,
              child: Icon(
                Icons.remove_rounded,
                size: 16,
                color: qty > 1 ? colors.text1 : colors.text3,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: SizedBox(
              key: ValueKey(qty),
              width: 30,
              child: Text(
                '$qty',
                textAlign: TextAlign.center,
                style: _T.qtyNum(colors.text1),
              ),
            ),
          ),
          GestureDetector(
            onTap: onIncrement,
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: colors.cardBg,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_rounded, size: 16, color: colors.text1),
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
          boxShadow: _T.softShadow(colors.text1, opacity: .05),
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
            boxShadow: loading
                ? []
                : _T.softShadow(colors.accent, opacity: .28),
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
// LOADING OVERLAY
// ─────────────────────────────────────────────────────────────

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          color: Colors.black.withOpacity(.28),
          child: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  left: 16,
                  top: 10,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: _T.softShadow(Colors.black, opacity: .12),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, size: 16),
                      ),
                    ),
                  ),
                ),

                Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutBack,
                    builder: (context, t, child) => Opacity(
                      opacity: t.clamp(0, 1),
                      child: Transform.scale(
                        scale: .9 + (.1 * t),
                        child: child,
                      ),
                    ),
                    child: Container(
                      width: 190,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 32,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.96),
                        borderRadius: BorderRadius.circular(_T.radiusXl),
                        border: Border.all(
                          color: Colors.white.withOpacity(.6),
                          width: 1,
                        ),
                        boxShadow: _T.cardShadow(Colors.black, opacity: .16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 76,
                            height: 76,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 76,
                                  height: 76,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        const Color(
                                          0xff2563EB,
                                        ).withOpacity(.14),
                                        const Color(0xff2563EB).withOpacity(0),
                                      ],
                                    ),
                                  ),
                                ),
                                LoadingAnimationWidget.hexagonDots(
                                  color: const Color(0xff2563EB),
                                  size: 52,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "Loading product",
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: .1,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "just a moment",
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: .1,
                              color: const Color(0xFF1F2937).withOpacity(.5),
                            ),
                          ),
                        ],
                      ),
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

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mq = MediaQuery.of(context);
    final galleryHeight = (mq.size.height * .46).clamp(300.0, 480.0);

    return Container(
      color: colors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── gallery placeholder + small inline loader ──
            SizedBox(
              height: galleryHeight,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _Shimmer(height: galleryHeight, borderRadius: 0),

                  Positioned(
                    left: _T.sp16,
                    top: _T.sp10,
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.9),
                        shape: BoxShape.circle,
                        boxShadow: _T.softShadow(Colors.black, opacity: .08),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 16),
                    ),
                  ),

                  Center(
                    child: LoadingAnimationWidget.hexagonDots(
                      color: const Color(0xFF2563EB),
                      size: 60,
                    ),
                  ),
                ],
              ),
            ),

            // ── content placeholders ──
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  _T.sp20,
                  _T.sp24,
                  _T.sp20,
                  _T.sp24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // chips
                    Row(
                      children: const [
                        _Shimmer(
                          width: 92,
                          height: 26,
                          borderRadius: _T.radiusFull,
                        ),
                        SizedBox(width: _T.sp8),
                        _Shimmer(
                          width: 74,
                          height: 26,
                          borderRadius: _T.radiusFull,
                        ),
                      ],
                    ),

                    const SizedBox(height: _T.sp16),

                    // title (two lines)
                    const _Shimmer(
                      width: double.infinity,
                      height: 20,
                      borderRadius: _T.radiusSm,
                    ),
                    const SizedBox(height: _T.sp8),
                    const _Shimmer(
                      width: 170,
                      height: 20,
                      borderRadius: _T.radiusSm,
                    ),

                    const SizedBox(height: _T.sp14),

                    // price
                    const _Shimmer(
                      width: 110,
                      height: 26,
                      borderRadius: _T.radiusSm,
                    ),

                    const SizedBox(height: _T.sp24),

                    // description label + lines
                    const _Shimmer(
                      width: 80,
                      height: 11,
                      borderRadius: _T.radiusSm,
                    ),
                    const SizedBox(height: _T.sp10),
                    const _Shimmer(
                      width: double.infinity,
                      height: 12,
                      borderRadius: _T.radiusSm,
                    ),
                    const SizedBox(height: _T.sp6),
                    const _Shimmer(
                      width: double.infinity,
                      height: 12,
                      borderRadius: _T.radiusSm,
                    ),
                    const SizedBox(height: _T.sp6),
                    const _Shimmer(
                      width: 210,
                      height: 12,
                      borderRadius: _T.radiusSm,
                    ),

                    const SizedBox(height: _T.sp24),
                    Divider(color: colors.border.withOpacity(.4), height: 1),
                    const SizedBox(height: _T.sp16),

                    // quantity row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        _Shimmer(
                          width: 64,
                          height: 15,
                          borderRadius: _T.radiusSm,
                        ),
                        _Shimmer(
                          width: 108,
                          height: 40,
                          borderRadius: _T.radiusFull,
                        ),
                      ],
                    ),

                    const SizedBox(height: _T.sp16),
                    Divider(color: colors.border.withOpacity(.4), height: 1),
                    const SizedBox(height: _T.sp16),

                    // CTA row
                    Row(
                      children: [
                        const _Shimmer(
                          width: 50,
                          height: 50,
                          borderRadius: _T.radiusLg,
                        ),
                        const SizedBox(width: _T.sp10),
                        Expanded(
                          child: const _Shimmer(
                            height: 50,
                            borderRadius: _T.radiusLg,
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
  bool _pageLoading = true;

  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    productFuture = context.read<ProductDetailProvider>().getOrFetch(
      widget.productId,
    );
    _loadEverything();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final cart = context.watch<CartProvider>().cart;

    if (cart == null) return;

    final item = cart.items.where((e) => e.productId == widget.productId);

    final newQty = item.isNotEmpty ? item.first.qty : 0;

    if (newQty != cartQty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        setState(() {
          cartQty = newQty;
          qty = newQty > 0 ? newQty : 1;
          isInCart = newQty > 0;
        });
      });
    }
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
    final loggedIn = await ApiService().isLoggedIn();

    if (!loggedIn) {
      Get.to(() => const LoginScreen());
      return;
    }
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
        await context.read<CartProvider>().fetchCart();

        if (!mounted) return;

        setState(() {
          isInCart = true;
          cartQty = qty;
        });
      }
      Get.snackbar(
        "Success",
        "Cart updated successfully",
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        borderRadius: 16,
        backgroundColor: Get.theme.cardColor,
        colorText: Get.theme.textTheme.bodyLarge?.color,
        icon: const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF34C759), // Green
        ),
        boxShadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
        duration: const Duration(seconds: 2),
        isDismissible: true,
        forwardAnimationCurve: Curves.easeOutCubic,
      );
    } catch (e) {
      Get.snackbar(
        'Stock',
        e.toString().contains('SocketException')
            ? 'No internet connection.'
            : 'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        borderRadius: 16,
        backgroundColor: Get.theme.cardColor,
        colorText: Get.theme.textTheme.bodyLarge?.color,
        icon: const Icon(Icons.error_outline_rounded, color: Color(0xFFFF3B30)),
        boxShadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
        duration: const Duration(seconds: 3),
        isDismissible: true,
        forwardAnimationCurve: Curves.easeOutCubic,
      );
    } finally {
      if (mounted) {
        setState(() => cartLoading = false);
      }
    }
  }

  Future<void> _loadFavorite() async {
    final loggedIn = await ApiService().isLoggedIn();

    if (!loggedIn) return;

    try {
      final favorite = await ApiService().isFavorite(widget.productId);

      if (!mounted) return;

      setState(() {
        isFavorite = favorite;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _loadEverything() async {
    try {
      await Future.wait([
        context.read<ProductDetailProvider>().getOrFetch(widget.productId),
        _loadFavorite(),
        _loadCartQty(),
      ]);
    } finally {
      if (mounted) {
        setState(() {
          _pageLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final loggedIn = await ApiService().isLoggedIn();

    if (!loggedIn) {
      Get.to(() => const LoginScreen());
      return;
    }

    HapticFeedback.lightImpact();

    final oldValue = isFavorite;

    // Update UI immediately
    setState(() {
      isFavorite = !oldValue;
    });

    try {
      if (oldValue) {
        await ApiService().removeFavorite(widget.productId);
      } else {
        await ApiService().addFavorite(widget.productId);
      }
    } catch (e) {
      // Rollback if API failed
      if (!mounted) return;

      setState(() {
        isFavorite = oldValue;
      });

      Get.snackbar(
        "Favorite",
        "Unable to update favorite.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _openCart() async {
    final provider = context.read<CartProvider>();

    if (provider.cart == null) {
      await provider.fetchCart();
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CartBottomSheet(),
    );
  }

  // ── shared UI builders (reused by both mobile & tablet layouts) ──

  Widget _buildCircleIconButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.92),
            shape: BoxShape.circle,
            boxShadow: _T.softShadow(Colors.black, opacity: .1),
          ),
          child: Icon(icon, size: 15, color: colors.text1),
        ),
      ),
    );
  }

  Widget _buildCartIconButton(BuildContext context) {
    final colors = context.colors;
    final cartProvider = context.watch<CartProvider>();
    final hasCart = cartProvider.itemCount > 0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openCart,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.92),
                  shape: BoxShape.circle,
                  boxShadow: _T.softShadow(Colors.black, opacity: .1),
                ),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  size: 21,
                  color: colors.accent,
                ),
              ),
              // Cart dot — shown only when the cart has items.
              if (hasCart)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.6),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryStack(
    BuildContext context, {
    required List images,
    required EdgeInsets safeArea,
  }) {
    final colors = context.colors;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (images.isNotEmpty)
          PageView.builder(
            itemCount: images.length,
            onPageChanged: (i) => setState(() => imageIndex = i),
            itemBuilder: (_, i) => Container(
              color: Colors.white,
              padding: const EdgeInsets.all(30),
              child: CachedNetworkImage(
                imageUrl: images[i] as String,
                fit: BoxFit.contain,
                errorWidget: (_, __, ___) =>
                    Icon(Icons.image_outlined, size: 56, color: colors.text3),
              ),
            ),
          )
        else
          Container(
            color: Colors.white,
            child: Center(
              child: Icon(Icons.image_outlined, size: 56, color: colors.text3),
            ),
          ),

        // soft scrim so the rounded content sheet reads cleanly on overlap
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 100,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0),
                    Colors.white.withOpacity(.85),
                  ],
                ),
              ),
            ),
          ),
        ),

        Positioned(
          top: safeArea.top + _T.sp10,
          left: _T.sp16,
          child: _buildCircleIconButton(
            context,
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
        ),

        Positioned(
          top: safeArea.top + _T.sp10,
          right: _T.sp16,
          child: _buildCartIconButton(context),
        ),

        if (images.length > 1)
          Positioned(
            bottom: _T.sp16,
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
    );
  }

  Widget _buildChipsRow(
    BuildContext context,
    dynamic p,
    bool inStock,
    int stockQty,
  ) {
    final colors = context.colors;
    return Wrap(
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
          label: inStock ? '${'in_stock'.tr} · $stockQty' : 'out_of_stock'.tr,
          bg: inStock ? colors.accentLight : colors.flashBg,
          textColor: inStock ? colors.accent : colors.flashText,
          borderColor: inStock
              ? colors.accent.withOpacity(.25)
              : colors.flashBorder,
          icon: inStock
              ? Icons.check_circle_outline_rounded
              : Icons.cancel_outlined,
        ),
      ],
    );
  }

  Widget _buildTitleAndPrice(
    BuildContext context,
    dynamic p,
    bool hasDiscount,
    String? discountPct,
  ) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(p.name as String, style: _T.productName(colors.text1)),
        const SizedBox(height: _T.sp10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('\$${p.finalPrice}', style: _T.priceMain(colors.text1)),
            if (hasDiscount) ...[
              const SizedBox(width: _T.sp8),
              Text('\$${p.salePrice}', style: _T.priceOld(colors.text3)),
              const SizedBox(width: _T.sp8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: _T.sp8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: colors.flashBg,
                  borderRadius: BorderRadius.circular(_T.radiusFull),
                  border: Border.all(color: colors.flashBorder, width: .5),
                ),
                child: Text(
                  discountPct!,
                  style: _T.discountTag(colors.flashText),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(BuildContext context, dynamic p) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('description'.tr, style: _T.sectionLabel(colors.text3)),
        const SizedBox(height: _T.sp6),
        _ExpandableDesc(text: (p.description as String?) ?? ''),
      ],
    );
  }

  Widget _buildThinDivider(BuildContext context) {
    final colors = context.colors;
    return Divider(
      color: colors.border.withOpacity(.5),
      height: 1,
      thickness: .6,
    );
  }

  Widget _buildQuantityRow(BuildContext context, int stockQty) {
    final colors = context.colors;
    return Row(
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
          onIncrement: () {
            if (qty >= stockQty) {
              Get.snackbar(
                'Out of Stock',
                'Only $stockQty item(s) available.',
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                borderRadius: 16,
                backgroundColor: Get.theme.cardColor,
                colorText: Get.theme.textTheme.bodyLarge?.color,
                icon: const Icon(
                  Icons.inventory_2_outlined,
                  color: Color(0xFFFF9500),
                ),
                boxShadows: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
                duration: const Duration(seconds: 3),
                isDismissible: true,
                forwardAnimationCurve: Curves.easeOutCubic,
              );

              return;
            }

            setState(() => qty++);
          },
          onDecrement: () {
            if (qty > 1) {
              setState(() => qty--);
            }
          },
        ),
      ],
    );
  }

  Widget _buildCtaRow(BuildContext context, dynamic p, int stockQty) {
    return Row(
      children: [
        _WishlistButton(isFavorite: isFavorite, onTap: _toggleFavorite),
        const SizedBox(width: _T.sp10),
        if (stockQty <= 0)
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  "OUT OF STOCK",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        else
          _CartButton(
            isInCart: isInCart,
            loading: cartLoading,
            onTap: () => _handleCart(p),
          ),
      ],
    );
  }

  // ── mobile: full-bleed gallery + rounded overlapping sheet ──

  Widget _buildMobileLayout(
    BuildContext context, {
    required dynamic p,
    required List images,
    required bool hasDiscount,
    required String? discountPct,
    required int stockQty,
    required bool inStock,
  }) {
    final colors = context.colors;
    final mq = MediaQuery.of(context);
    final hPad = mq.size.width < 360 ? _T.sp14 : _T.sp20;
    final galleryHeight = (mq.size.height * .46).clamp(300.0, 480.0);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.white,
          expandedHeight: galleryHeight,
          pinned: false,
          floating: false,
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background: _buildGalleryStack(
              context,
              images: images,
              safeArea: mq.padding,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -_T.sp20),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(_T.radiusXl),
                  topRight: Radius.circular(_T.radiusXl),
                ),
                boxShadow: _T.cardShadow(Colors.black, opacity: .04),
              ),
              padding: EdgeInsets.fromLTRB(
                hPad,
                _T.sp24,
                hPad,
                mq.padding.bottom + _T.sp24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChipsRow(context, p, inStock, stockQty),
                  const SizedBox(height: _T.sp14),
                  _buildTitleAndPrice(context, p, hasDiscount, discountPct),
                  const SizedBox(height: _T.sp20),
                  _buildDescriptionSection(context, p),
                  const SizedBox(height: _T.sp20),
                  _buildThinDivider(context),
                  const SizedBox(height: _T.sp14),
                  _buildQuantityRow(context, stockQty),
                  const SizedBox(height: _T.sp20),
                  _buildThinDivider(context),
                  const SizedBox(height: _T.sp14),
                  _buildCtaRow(context, p, stockQty),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── tablet / wide screens: side-by-side gallery + details panel ──

  Widget _buildTabletLayout(
    BuildContext context, {
    required dynamic p,
    required List images,
    required bool hasDiscount,
    required String? discountPct,
    required int stockQty,
    required bool inStock,
  }) {
    final colors = context.colors;
    final mq = MediaQuery.of(context);

    return Row(
      children: [
        // Left — full-height gallery panel.
        Expanded(
          flex: 5,
          child: _buildGalleryStack(
            context,
            images: images,
            safeArea: mq.padding,
          ),
        ),

        // Right — scrollable details, CTA pinned to the bottom.
        Expanded(
          flex: 4,
          child: Container(
            color: colors.background,
            child: SafeArea(
              left: false,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        _T.sp32,
                        _T.sp32,
                        _T.sp32,
                        _T.sp20,
                      ),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildChipsRow(context, p, inStock, stockQty),
                          const SizedBox(height: _T.sp16),
                          _buildTitleAndPrice(
                            context,
                            p,
                            hasDiscount,
                            discountPct,
                          ),
                          const SizedBox(height: _T.sp24),
                          _buildDescriptionSection(context, p),
                          const SizedBox(height: _T.sp24),
                          _buildThinDivider(context),
                          const SizedBox(height: _T.sp16),
                          _buildQuantityRow(context, stockQty),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      _T.sp32,
                      _T.sp16,
                      _T.sp32,
                      _T.sp20,
                    ),
                    decoration: BoxDecoration(
                      color: colors.background,
                      border: Border(
                        top: BorderSide(
                          color: colors.border.withOpacity(.5),
                          width: .6,
                        ),
                      ),
                    ),
                    child: _buildCtaRow(context, p, stockQty),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth >= _T.tabletBreakpoint;
                return isTablet
                    ? _buildTabletLayout(
                        context,
                        p: p,
                        images: images,
                        hasDiscount: hasDiscount,
                        discountPct: discountPct,
                        stockQty: stockQty,
                        inStock: inStock,
                      )
                    : _buildMobileLayout(
                        context,
                        p: p,
                        images: images,
                        hasDiscount: hasDiscount,
                        discountPct: discountPct,
                        stockQty: stockQty,
                        inStock: inStock,
                      );
              },
            ),
          );
        },
      ),
    );
  }
}
