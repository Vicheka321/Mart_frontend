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
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: c,
    height: 1.26,
    letterSpacing: -.4,
  );

  static TextStyle brandCategory(Color c) => TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    color: c,
    letterSpacing: .1,
  );

  static TextStyle priceMain(Color c) => TextStyle(
    fontSize: 26,
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

  static TextStyle sectionTitle(Color c) => TextStyle(
    fontSize: 15.5,
    fontWeight: FontWeight.w700,
    color: c,
    letterSpacing: -.1,
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
// SAFE DYNAMIC FIELD ACCESS
//
// The product model isn't visible here, so optional fields (ratings,
// reviews, etc.) are read defensively: if a field doesn't exist on the
// model yet, the corresponding UI just hides itself instead of crashing.
// ─────────────────────────────────────────────────────────────

T? _tryGet<T>(T Function() getter) {
  try {
    return getter();
  } catch (_) {
    return null;
  }
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
// THUMBNAIL STRIP (image indicators, requirement 1)
// ─────────────────────────────────────────────────────────────

class _ThumbnailStrip extends StatelessWidget {
  final List images;
  final int activeIndex;
  final ValueChanged<int> onTap;
  const _ThumbnailStrip({
    required this.images,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: _T.sp8),
        itemBuilder: (_, i) {
          final active = i == activeIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 52,
              height: 52,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_T.radiusMd),
                border: Border.all(
                  color: active ? colors.accent : colors.border,
                  width: active ? 1.6 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_T.radiusSm),
                child: CachedNetworkImage(
                  imageUrl: images[i] as String,
                  fit: BoxFit.contain,
                  errorWidget: (_, __, ___) =>
                      Icon(Icons.image_outlined, size: 18, color: colors.text3),
                ),
              ),
            ),
          );
        },
      ),
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
// STAR RATING (requirement 3 & 11)
// ─────────────────────────────────────────────────────────────

class _StarRating extends StatelessWidget {
  final double rating;
  final double size;
  const _StarRating({required this.rating, this.size = 14});

  @override
  Widget build(BuildContext context) {
    final clamped = rating.clamp(0, 5).toDouble();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final diff = clamped - i;
        IconData icon;
        if (diff >= 1) {
          icon = Icons.star_rounded;
        } else if (diff > 0) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_border_rounded;
        }
        return Icon(icon, size: size, color: const Color(0xFFFFB020));
      }),
    );
  }
}

class _ProductRatingRow extends StatelessWidget {
  final double averageRating;
  final int reviewCount;
  const _ProductRatingRow({
    required this.averageRating,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (reviewCount <= 0) {
      return Row(
        children: [
          _StarRating(rating: 5, size: 15),
          const SizedBox(width: _T.sp8),
          Text(
            'no_reviews_yet'.tr,
            style: TextStyle(fontSize: 12.5, color: colors.text3),
          ),
        ],
      );
    }
    return Row(
      children: [
        _StarRating(rating: averageRating, size: 15),
        const SizedBox(width: _T.sp8),
        Text(
          averageRating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colors.text1,
          ),
        ),
        const SizedBox(width: _T.sp6),
        Text(
          '$reviewCount ${'reviews'.tr}',
          style: TextStyle(fontSize: 12.5, color: colors.text3),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// QUANTITY SELECTOR — tap +/- OR type a value directly.
// ─────────────────────────────────────────────────────────────

class _QuantitySelector extends StatefulWidget {
  final int qty;
  final int maxQty;
  final ValueChanged<int> onChanged;

  const _QuantitySelector({
    required this.qty,
    required this.maxQty,
    required this.onChanged,
  });

  @override
  State<_QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<_QuantitySelector> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.qty}');
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant _QuantitySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only push the parent's value into the field when the user isn't
    // actively typing — otherwise we'd stomp on what they're entering.
    if (!_focusNode.hasFocus &&
        widget.qty != oldWidget.qty &&
        widget.qty.toString() != _controller.text) {
      _controller.text = '${widget.qty}';
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) _commit();
  }

  int _clamp(int v) {
    if (widget.maxQty <= 0) return 1;
    if (v < 1) return 1;
    if (v > widget.maxQty) return widget.maxQty;
    return v;
  }

  // Handles empty input, non-numeric input (already filtered), 0, and
  // out-of-range values safely.
  void _commit() {
    final parsed = int.tryParse(_controller.text.trim());
    final safe = _clamp(parsed ?? widget.qty);
    if ('$safe' != _controller.text) {
      _controller.text = '$safe';
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
    if (safe != widget.qty) widget.onChanged(safe);
  }

  void _increment() {
    if (widget.maxQty <= 0 || widget.qty >= widget.maxQty) return;
    HapticFeedback.selectionClick();
    final next = _clamp(widget.qty + 1);
    _controller.text = '$next';
    widget.onChanged(next);
  }

  void _decrement() {
    if (widget.qty <= 1) return;
    HapticFeedback.selectionClick();
    final next = _clamp(widget.qty - 1);
    _controller.text = '$next';
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final canIncrement = widget.maxQty > 0 && widget.qty < widget.maxQty;
    final canDecrement = widget.qty > 1;
    final enabled = widget.maxQty > 0;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: BorderRadius.circular(_T.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            enabled: enabled && canDecrement,
            onTap: _decrement,
          ),
          SizedBox(
            width: 40,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: enabled,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: _T.qtyNum(colors.text1),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (_) => _commit(),
              onEditingComplete: _commit,
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            enabled: canIncrement,
            onTap: _increment,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: SizedBox(
        width: 38,
        height: 44,
        child: Icon(
          icon,
          size: 16,
          color: enabled ? colors.text1 : colors.text3,
        ),
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
  final double size;
  const _WishlistButton({
    required this.isFavorite,
    required this.onTap,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
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
            size: 19,
            color: isFavorite ? colors.flashText : colors.text2,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ADD TO CART BUTTON
// ─────────────────────────────────────────────────────────────

class _AddToCartButton extends StatelessWidget {
  final bool isInCart;
  final bool loading;
  final bool enabled;
  final VoidCallback onTap;
  const _AddToCartButton({
    required this.isInCart,
    required this.loading,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final active = enabled && !loading;
    return Expanded(
      child: GestureDetector(
        // `loading` guards against double submission; `enabled` covers
        // the out-of-stock case.
        onTap: active ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 50,
          decoration: BoxDecoration(
            color: !enabled
                ? colors.border
                : (loading ? colors.accentLight : colors.accent),
            borderRadius: BorderRadius.circular(_T.radiusLg),
            boxShadow: active ? _T.softShadow(colors.accent, opacity: .28) : [],
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
                        !enabled
                            ? Icons.remove_shopping_cart_outlined
                            : (isInCart
                                  ? Icons.shopping_cart_checkout_rounded
                                  : Icons.shopping_cart_outlined),
                        color: colors.surface,
                        size: 18,
                      ),
                      const SizedBox(width: _T.sp8),
                      Text(
                        !enabled
                            ? 'out_of_stock'.tr
                            : (isInCart ? 'update_cart'.tr : 'add_to_cart'.tr),
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
// STICKY ADD-TO-CART BOTTOM BAR
// ─────────────────────────────────────────────────────────────

class _ProductBottomBar extends StatelessWidget {
  final int qty;
  final int maxQty;
  final double unitPrice;
  final bool isInCart;
  final bool loading;
  final ValueChanged<int> onQtyChanged;
  final VoidCallback onAddToCart;

  const _ProductBottomBar({
    required this.qty,
    required this.maxQty,
    required this.unitPrice,
    required this.isInCart,
    required this.loading,
    required this.onQtyChanged,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final inStock = maxQty > 0;
    final total = unitPrice * qty;

    return Container(
      padding: EdgeInsets.fromLTRB(
        _T.sp20,
        _T.sp14,
        _T.sp20,
        _T.sp14 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          top: BorderSide(color: colors.border.withOpacity(.5), width: .6),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (inStock)
                _QuantitySelector(
                  qty: qty,
                  maxQty: maxQty,
                  onChanged: onQtyChanged,
                )
              else
                const SizedBox.shrink(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'total'.tr,
                    style: TextStyle(fontSize: 11, color: colors.text3),
                  ),
                  const SizedBox(height: 2),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    child: Text(
                      '\$${total.toStringAsFixed(2)}',
                      key: ValueKey(total),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: colors.text1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: _T.sp12),
          Row(
            children: [
              _AddToCartButton(
                isInCart: isInCart,
                loading: loading,
                enabled: inStock,
                onTap: onAddToCart,
              ),
            ],
          ),
        ],
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
// CUSTOMER REVIEWS (requirement 11)
// ─────────────────────────────────────────────────────────────

class _ReviewTile extends StatelessWidget {
  final dynamic review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final name =
        _tryGet<String>(() => review.customerName as String) ??
        _tryGet<String>(() => review.userName as String) ??
        'anonymous'.tr;
    final avatarUrl =
        _tryGet<String>(() => review.avatarUrl as String) ??
        _tryGet<String>(() => review.userAvatar as String);
    final rating = _tryGet<num>(() => review.rating as num)?.toDouble() ?? 0.0;
    final text =
        _tryGet<String>(() => review.comment as String) ??
        _tryGet<String>(() => review.reviewText as String) ??
        '';
    final date =
        _tryGet<String>(() => review.formattedDate as String) ??
        _tryGet<DateTime>(() => review.createdAt as DateTime)?.let(
          (d) =>
              '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: _T.sp16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: colors.surface2,
            backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                ? CachedNetworkImageProvider(avatarUrl)
                : null,
            child: (avatarUrl == null || avatarUrl.isEmpty)
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.text2,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: _T.sp10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.text1,
                        ),
                      ),
                    ),
                    if (date != null)
                      Text(
                        date,
                        style: TextStyle(fontSize: 11, color: colors.text3),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                _StarRating(rating: rating, size: 12),
                if (text.isNotEmpty) ...[
                  const SizedBox(height: _T.sp6),
                  Text(text, style: _T.bodyText(colors.text2)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Small helper so the null-aware chain above reads cleanly.
extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}

class _ProductReviewsSection extends StatefulWidget {
  final double averageRating;
  final int reviewCount;
  final List reviews;
  const _ProductReviewsSection({
    required this.averageRating,
    required this.reviewCount,
    required this.reviews,
  });

  @override
  State<_ProductReviewsSection> createState() => _ProductReviewsSectionState();
}

class _ProductReviewsSectionState extends State<_ProductReviewsSection> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // No review model/data wired up yet — hide the section rather than
    // showing an empty shell.
    if (widget.reviewCount <= 0 && widget.reviews.isEmpty) {
      return const SizedBox.shrink();
    }

    final visible = _showAll ? widget.reviews : widget.reviews.take(3).toList();
    final hasMore = widget.reviews.length > 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('customer_reviews'.tr, style: _T.sectionTitle(colors.text1)),
        const SizedBox(height: _T.sp10),
        _ProductRatingRow(
          averageRating: widget.averageRating,
          reviewCount: widget.reviewCount,
        ),
        if (visible.isNotEmpty) ...[
          const SizedBox(height: _T.sp16),
          ...visible.map((r) => _ReviewTile(review: r)),
          if (hasMore)
            GestureDetector(
              onTap: () => setState(() => _showAll = !_showAll),
              child: Text(
                _showAll ? 'show_less'.tr : 'see_all_reviews'.tr,
                style: TextStyle(
                  fontSize: 12.5,
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
// SKELETON / LOADING STATES
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
                    const _Shimmer(
                      width: 110,
                      height: 26,
                      borderRadius: _T.radiusSm,
                    ),
                    const SizedBox(height: _T.sp24),
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
                  ],
                ),
              ),
            ),
            // bottom bar placeholder
            Container(
              padding: const EdgeInsets.fromLTRB(
                _T.sp20,
                _T.sp14,
                _T.sp20,
                _T.sp14,
              ),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colors.border.withOpacity(.4),
                    width: .6,
                  ),
                ),
              ),
              child: const _Shimmer(height: 50, borderRadius: _T.radiusLg),
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
    _refreshProduct();
    _loadFavorite();
    _loadCartQty();
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

  Future<void> _refreshProduct() async {
    setState(() {
      productFuture = ApiService().fetchProduct(widget.productId);
    });
  }

  Future<void> _handleCart(dynamic p, int stockQty) async {
    if (stockQty <= 0 || cartLoading) return;

    final loggedIn = await ApiService().isLoggedIn();

    if (!loggedIn) {
      Get.to(() => const LoginScreen());
      return;
    }
    setState(() => cartLoading = true);

    try {
      // Always send the exact selected quantity — never re-add on top of
      // what's already in the cart.
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('SocketException')
                ? 'No internet connection.'
                : 'Something went wrong. Please try again.',
          ),
        ),
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
      if (!mounted) return;

      setState(() {
        isFavorite = oldValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update favorite.')),
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

  void _onQtyChanged(int value) {
    setState(() => qty = value);
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

  // requirement 1: image gallery
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
                placeholder: (_, __) => const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
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

  // requirement 2: product header (name + favorite)
  Widget _buildProductHeader(BuildContext context, dynamic p) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(p.name as String, style: _T.productName(colors.text1)),
        ),
        const SizedBox(width: _T.sp10),
        _WishlistButton(
          isFavorite: isFavorite,
          onTap: _toggleFavorite,
          size: 42,
        ),
      ],
    );
  }

  // requirement 2: brand / category
  Widget _buildBrandCategoryRow(BuildContext context, dynamic p) {
    final colors = context.colors;
    final brand = _tryGet<String>(() => p.brandName as String) ?? '';
    final category = _tryGet<String>(() => p.categoryName as String) ?? '';
    if (brand.isEmpty && category.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: _T.sp8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (brand.isNotEmpty)
          Text(brand.trCatalog, style: _T.brandCategory(colors.text2)),
        if (brand.isNotEmpty && category.isNotEmpty)
          Container(
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              color: colors.text3,
              shape: BoxShape.circle,
            ),
          ),
        if (category.isNotEmpty)
          Text(category, style: _T.brandCategory(colors.text3)),
      ],
    );
  }

  // requirement 4: price section
  Widget _buildPriceSection(
    BuildContext context,
    dynamic p,
    bool hasDiscount,
    String? discountPct,
  ) {
    final colors = context.colors;
    return Row(
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
            ),
            child: Text(
              discountPct ?? '',
              style: _T.discountTag(colors.flashText),
            ),
          ),
        ],
      ],
    );
  }

  // requirement 6: stock info
  Widget _buildStockRow(BuildContext context, int stockQty) {
    final colors = context.colors;
    String label;
    Color bg, fg;
    IconData icon;

    if (stockQty <= 0) {
      label = 'out_of_stock'.tr;
      bg = colors.flashBg;
      fg = colors.flashText;
      icon = Icons.cancel_outlined;
    } else if (stockQty <= 5) {
      label = '${'only'.tr} $stockQty ${'left'.tr}';
      bg = colors.flashBg;
      fg = colors.flashText;
      icon = Icons.warning_amber_rounded;
    } else {
      label = '${'in_stock'.tr}: $stockQty';
      bg = colors.accentLight;
      fg = colors.accent;
      icon = Icons.check_circle_outline_rounded;
    }

    return _Chip(
      label: label,
      bg: bg,
      textColor: fg,
      borderColor: bg,
      icon: icon,
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

  // ── main scrollable content, shared by mobile & tablet ──
  Widget _buildContent(
    BuildContext context, {
    required dynamic p,
    required bool hasDiscount,
    required String? discountPct,
    required int stockQty,
    required double avgRating,
    required int reviewCount,
    required List reviews,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductHeader(context, p),
        const SizedBox(height: _T.sp6),
        _buildBrandCategoryRow(context, p),
        const SizedBox(height: _T.sp12),
        _ProductRatingRow(averageRating: avgRating, reviewCount: reviewCount),
        const SizedBox(height: _T.sp14),
        _buildPriceSection(context, p, hasDiscount, discountPct),
        const SizedBox(height: _T.sp12),
        _buildStockRow(context, stockQty),
        const SizedBox(height: _T.sp20),
        _buildDescriptionSection(context, p),
        const SizedBox(height: _T.sp20),
        _buildThinDivider(context),
        const SizedBox(height: _T.sp20),
        _ProductReviewsSection(
          averageRating: avgRating,
          reviewCount: reviewCount,
          reviews: reviews,
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
    required double avgRating,
    required int reviewCount,
    required List reviews,
  }) {
    final colors = context.colors;
    final mq = MediaQuery.of(context);
    final hPad = mq.size.width < 360 ? _T.sp14 : _T.sp20;
    final galleryHeight = (mq.size.height * .42).clamp(280.0, 440.0);

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
              padding: EdgeInsets.fromLTRB(hPad, _T.sp24, hPad, _T.sp24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (images.length > 1) ...[
                    _ThumbnailStrip(
                      images: images,
                      activeIndex: imageIndex,
                      onTap: (i) => setState(() => imageIndex = i),
                    ),
                    const SizedBox(height: _T.sp16),
                  ],
                  _buildContent(
                    context,
                    p: p,
                    hasDiscount: hasDiscount,
                    discountPct: discountPct,
                    stockQty: stockQty,
                    avgRating: avgRating,
                    reviewCount: reviewCount,
                    reviews: reviews,
                  ),
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
    required double avgRating,
    required int reviewCount,
    required List reviews,
  }) {
    final colors = context.colors;
    final mq = MediaQuery.of(context);

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: _buildGalleryStack(
            context,
            images: images,
            safeArea: mq.padding,
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            color: colors.background,
            child: SafeArea(
              left: false,
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
                    if (images.length > 1) ...[
                      _ThumbnailStrip(
                        images: images,
                        activeIndex: imageIndex,
                        onTap: (i) => setState(() => imageIndex = i),
                      ),
                      const SizedBox(height: _T.sp16),
                    ],
                    _buildContent(
                      context,
                      p: p,
                      hasDiscount: hasDiscount,
                      discountPct: discountPct,
                      stockQty: stockQty,
                      avgRating: avgRating,
                      reviewCount: reviewCount,
                      reviews: reviews,
                    ),
                  ],
                ),
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
      resizeToAvoidBottomInset: true,
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
          final salePrice = double.tryParse(p.salePrice.toString()) ?? 0;

          final discount = p.discount;

          final hasDiscount =
              discount != null &&
              discount.discountValue > 0 &&
              salePrice > finalPrice;

          String? discountLabel;
          if (hasDiscount) {
            final type = discount.discountType.trim().toLowerCase();
            final value = discount.discountValue;

            if (type == 'percentage' || type == 'percent') {
              discountLabel = '-${value % 1 == 0 ? value.toInt() : value}%';
            } else if (type == 'fixed' || type == 'amount') {
              discountLabel = '-\$${value % 1 == 0 ? value.toInt() : value}';
            }
          }

          final stockQty = (p.quantity as int?) ?? 0;

          // requirement 3 & 11: rating / reviews — read defensively since
          // the model shape for these isn't known here.
          final avgRating =
              _tryGet<num>(() => p.averageRating as num)?.toDouble() ?? 0.0;
          final reviewCount = _tryGet<int>(() => p.reviewCount as int) ?? 0;
          final reviews = _tryGet<List>(() => p.reviews as List) ?? [];

          // Quantity can never exceed what's currently in stock, even if
          // it was set (e.g. from the cart) before stock changed.
          if (qty > stockQty && stockQty > 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => qty = stockQty);
            });
          }

          return FadeTransition(
            opacity: _fade,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth >= _T.tabletBreakpoint;
                return Column(
                  children: [
                    Expanded(
                      child: isTablet
                          ? _buildTabletLayout(
                              context,
                              p: p,
                              images: images,
                              hasDiscount: hasDiscount,
                              discountPct: discountLabel,
                              stockQty: stockQty,
                              avgRating: avgRating,
                              reviewCount: reviewCount,
                              reviews: reviews,
                            )
                          : _buildMobileLayout(
                              context,
                              p: p,
                              images: images,
                              hasDiscount: hasDiscount,
                              discountPct: discountLabel,
                              stockQty: stockQty,
                              avgRating: avgRating,
                              reviewCount: reviewCount,
                              reviews: reviews,
                            ),
                    ),
                    _ProductBottomBar(
                      qty: qty.clamp(1, stockQty > 0 ? stockQty : 1),
                      maxQty: stockQty,
                      unitPrice: finalPrice,
                      isInCart: isInCart,
                      loading: cartLoading,
                      onQtyChanged: _onQtyChanged,
                      onAddToCart: () => _handleCart(p, stockQty),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
