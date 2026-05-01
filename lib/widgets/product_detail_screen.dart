import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../screens/theme/app_theme.dart';

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
  int imageIndex = 0;
  bool isFavorite = false;

  late AnimationController _favoriteController;
  late AnimationController _fadeController;
  late AnimationController _shimmerController;
  late Animation<double> _favoriteScale;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    productFuture = ApiService().fetchProduct(widget.productId);

    _favoriteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _favoriteScale =
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
        ]).animate(
          CurvedAnimation(parent: _favoriteController, curve: Curves.easeInOut),
        );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    // Shimmer controller for skeleton
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _favoriteController.dispose();
    _fadeController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    HapticFeedback.lightImpact();
    setState(() => isFavorite = !isFavorite);
    _favoriteController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = MediaQuery.of(context).size.shortestSide;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: FutureBuilder(
        future: productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildSkeleton(context, colors, s, theme);
          }

          if (snapshot.hasError) {
            return _buildError();
          }

          final p = snapshot.data;
          final images = p.images ?? [];

          return FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Hero Image SliverAppBar ──────────────────────────
                SliverAppBar(
                  expandedHeight: s * 0.74,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                  automaticallyImplyLeading: false,

                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image carousel
                        PageView.builder(
                          itemCount: images.length,
                          onPageChanged: (i) => setState(() => imageIndex = i),
                          itemBuilder: (_, i) => Image.network(
                            images[i],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),

                        // Gradient overlay (bottom fade)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 120,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.45),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Gradient overlay (top — for icons)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 140,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.38),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Discount badge
                        if (p.discount != null)
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 60,
                            left: 20,
                            child: _DiscountBadge(label: p.discount),
                          ),

                        // Dot indicators
                        if (images.length > 1)
                          Positioned(
                            bottom: 22,
                            left: 0,
                            right: 0,
                            child: _DotIndicator(
                              count: images.length,
                              activeIndex: imageIndex,
                              activeColor: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),

                  leading: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, top: 8),
                      child: _CircleButton(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),

                  actions: [
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16, top: 8),
                        child: ScaleTransition(
                          scale: _favoriteScale,
                          child: _CircleButton(
                            onTap: _toggleFavorite,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                key: ValueKey(isFavorite),
                                color: isFavorite
                                    ? const Color(0xFFFF4C6A)
                                    : Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Content ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        s * .055,
                        s * .055,
                        s * .055,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Drag handle
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(
                                color: colors.text3.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),

                          // Category + Brand chips
                          Row(
                            children: [
                              _Chip(
                                label: p.categoryName ?? "",
                                colors: colors,
                              ),
                              const SizedBox(width: 8),
                              _Chip(label: p.brandName ?? "", colors: colors),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Product name
                          Text(
                            p.name,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Price row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "\$${p.finalPrice}",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: colors.accent,
                                  letterSpacing: -1,
                                ),
                              ),
                              if (p.discount != null) ...[
                                const SizedBox(width: 10),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 3),
                                  child: Text(
                                    "\$${p.salePrice}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      decoration: TextDecoration.lineThrough,
                                      color: colors.text3,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: 28),

                          Divider(
                            color: colors.text3.withOpacity(0.12),
                            height: 1,
                          ),

                          const SizedBox(height: 28),

                          // Description
                          const Text(
                            "Description",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            p.description ?? "",
                            style: TextStyle(
                              height: 1.65,
                              fontSize: 14.5,
                              color: colors.text3,
                            ),
                          ),

                          const SizedBox(height: 32),

                          Divider(
                            color: colors.text3.withOpacity(0.12),
                            height: 1,
                          ),

                          const SizedBox(height: 28),

                          // Quantity row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Quantity",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              _QuantitySelector(
                                qty: qty,
                                accent: colors.accent,
                                surface: colors.surface,
                                onDecrement: () {
                                  if (qty > 1) setState(() => qty--);
                                },
                                onIncrement: () => setState(() => qty++),
                              ),
                            ],
                          ),

                          const SizedBox(height: 36),

                          _AddToCartButton(accent: colors.accent),

                          SizedBox(
                            height: MediaQuery.of(context).padding.bottom + 32,
                          ),
                        ],
                      ),
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

  // ── SKELETON ────────────────────────────────────────────────────────────────

  Widget _buildSkeleton(
    BuildContext context,
    dynamic colors,
    double s,
    ThemeData theme,
  ) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, _) {
        return CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            // ── Skeleton Hero ──
            SliverAppBar(
              expandedHeight: s * 0.74,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Shimmer image placeholder
                    _SkeletonBox(
                      shimmer: _shimmerAnimation.value,
                      colors: colors,
                      borderRadius: 0,
                    ),

                    // Top bar placeholder
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _SkeletonCircle(
                            size: 40,
                            shimmer: _shimmerAnimation.value,
                            colors: colors,
                          ),
                          _SkeletonCircle(
                            size: 40,
                            shimmer: _shimmerAnimation.value,
                            colors: colors,
                          ),
                        ],
                      ),
                    ),

                    // Dot indicators placeholder
                    Positioned(
                      bottom: 22,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (i) {
                          return AnimatedContainer(
                            duration: Duration.zero,
                            margin: const EdgeInsets.symmetric(horizontal: 3.5),
                            width: i == 0 ? 20 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(
                                i == 0 ? 0.5 : 0.2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Skeleton Content ──
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(s * .055, s * .055, s * .055, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: colors.text3.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Category + Brand chips
                    Row(
                      children: [
                        _SkeletonBox(
                          shimmer: _shimmerAnimation.value,
                          colors: colors,
                          width: 90,
                          height: 30,
                          borderRadius: 8,
                        ),
                        const SizedBox(width: 8),
                        _SkeletonBox(
                          shimmer: _shimmerAnimation.value,
                          colors: colors,
                          width: 70,
                          height: 30,
                          borderRadius: 8,
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Product name — 2 lines
                    _SkeletonBox(
                      shimmer: _shimmerAnimation.value,
                      colors: colors,
                      width: double.infinity,
                      height: 22,
                      borderRadius: 6,
                    ),
                    const SizedBox(height: 8),
                    _SkeletonBox(
                      shimmer: _shimmerAnimation.value,
                      colors: colors,
                      width: 200,
                      height: 22,
                      borderRadius: 6,
                    ),

                    const SizedBox(height: 20),

                    // Price
                    _SkeletonBox(
                      shimmer: _shimmerAnimation.value,
                      colors: colors,
                      width: 120,
                      height: 32,
                      borderRadius: 6,
                    ),

                    const SizedBox(height: 28),

                    Divider(color: colors.text3.withOpacity(0.10), height: 1),

                    const SizedBox(height: 28),

                    // Description label
                    _SkeletonBox(
                      shimmer: _shimmerAnimation.value,
                      colors: colors,
                      width: 100,
                      height: 17,
                      borderRadius: 4,
                    ),

                    const SizedBox(height: 14),

                    // Description lines
                    ...[1.0, 1.0, 1.0, 0.65].map(
                      (w) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _SkeletonBox(
                          shimmer: _shimmerAnimation.value,
                          colors: colors,
                          width: w == 1.0
                              ? double.infinity
                              : MediaQuery.of(context).size.width * w * 0.75,
                          height: 13,
                          borderRadius: 4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Divider(color: colors.text3.withOpacity(0.10), height: 1),

                    const SizedBox(height: 28),

                    // Quantity row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SkeletonBox(
                          shimmer: _shimmerAnimation.value,
                          colors: colors,
                          width: 90,
                          height: 17,
                          borderRadius: 4,
                        ),
                        _SkeletonBox(
                          shimmer: _shimmerAnimation.value,
                          colors: colors,
                          width: 110,
                          height: 42,
                          borderRadius: 14,
                        ),
                      ],
                    ),

                    const SizedBox(height: 36),

                    // Add to cart button
                    _SkeletonBox(
                      shimmer: _shimmerAnimation.value,
                      colors: colors,
                      width: double.infinity,
                      height: 56,
                      borderRadius: 16,
                    ),

                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 32,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildError() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
          SizedBox(height: 12),
          Text(
            "Failed to load product",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ── Skeleton Primitives ──────────────────────────────────────────────────────

class _SkeletonBox extends StatelessWidget {
  final double shimmer;
  final dynamic colors;
  final double? width;
  final double? height;
  final double borderRadius;

  const _SkeletonBox({
    required this.shimmer,
    required this.colors,
    this.width,
    this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF1E1E24) : const Color(0xFFEEEEEE);
    final highlight = isDark
        ? const Color(0xFF2C2C36)
        : const Color(0xFFFAFAFA);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height ?? 16,
        child: AnimatedBuilder(
          animation: AlwaysStoppedAnimation(shimmer),
          builder: (_, __) => CustomPaint(
            painter: _ShimmerPainter(
              shimmer: shimmer,
              base: base,
              highlight: highlight,
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonCircle extends StatelessWidget {
  final double size;
  final double shimmer;
  final dynamic colors;

  const _SkeletonCircle({
    required this.size,
    required this.shimmer,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark
        ? Colors.white.withOpacity(0.12)
        : Colors.black.withOpacity(0.10);
    final highlight = isDark
        ? Colors.white.withOpacity(0.22)
        : Colors.black.withOpacity(0.04);

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _ShimmerPainter(
            shimmer: shimmer,
            base: base,
            highlight: highlight,
          ),
        ),
      ),
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  final double shimmer;
  final Color base;
  final Color highlight;

  const _ShimmerPainter({
    required this.shimmer,
    required this.base,
    required this.highlight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [base, highlight, base],
      stops: const [0.0, 0.5, 1.0],
      transform: _SlideGradient(shimmer),
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) =>
      old.shimmer != shimmer || old.base != base || old.highlight != highlight;
}

class _SlideGradient implements GradientTransform {
  final double slide;
  const _SlideGradient(this.slide);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slide, 0, 0);
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _CircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _CircleButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  final String label;

  const _DiscountBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4C6A),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4C6A).withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;
  final Color activeColor;

  const _DotIndicator({
    required this.count,
    required this.activeIndex,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3.5),
          width: isActive ? 20 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: isActive ? activeColor : activeColor.withOpacity(0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final dynamic colors;

  const _Chip({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colors.text3,
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int qty;
  final Color accent;
  final Color surface;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantitySelector({
    required this.qty,
    required this.accent,
    required this.surface,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _QtyButton(
            icon: Icons.remove_rounded,
            onTap: onDecrement,
            enabled: qty > 1,
            accent: accent,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Text(
              "$qty",
              key: ValueKey(qty),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ),
          _QtyButton(
            icon: Icons.add_rounded,
            onTap: onIncrement,
            enabled: true,
            accent: accent,
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final Color accent;

  const _QtyButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? accent : accent.withOpacity(0.3),
        ),
      ),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  final Color accent;

  const _AddToCartButton({required this.accent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: accent.withOpacity(0.4),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 20),
            SizedBox(width: 10),
            Text(
              "Add to Cart",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
