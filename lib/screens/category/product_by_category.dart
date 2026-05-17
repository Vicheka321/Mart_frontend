import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../auth/login_register_screen.dart';
import '../../models/categories_model.dart';
import '../../services/api_service.dart';
import '../../translations/catalog_translation.dart';
import '../theme/app_theme.dart';
import '../product/product_detail_screen.dart';

// ─────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────
class CategoryProductsScreen extends StatefulWidget {
  final int categoryId;
  final String? categoryName;

  const CategoryProductsScreen({
    Key? key,
    required this.categoryId,
    this.categoryName,
  }) : super(key: key);

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen>
    with SingleTickerProviderStateMixin {
  late Future<GetProductsByCategoryModel> _categoryFuture;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _categoryFuture = ApiService().fetchCategoryWithProducts(widget.categoryId);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AppBar(
                categoryName: widget.categoryName ?? 'Products',
                colors: colors,
              ),
              SizedBox(height: 15),

              Expanded(
                child: FutureBuilder<GetProductsByCategoryModel>(
                  future: _categoryFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const _LoadingState();
                    }
                    if (snapshot.hasError) {
                      return _ErrorState(
                        error: snapshot.error.toString(),
                        colors: colors,
                      );
                    }
                    final category = snapshot.data;
                    if (category == null || category.products.isEmpty) {
                      return _EmptyState(colors: colors);
                    }
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                        itemCount: category.products.length,
                        itemBuilder: (context, index) {
                          return _ProductCard(
                            product: category.products[index],
                            colors: colors,
                            index: index,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  App Bar
// ─────────────────────────────────────────────
class _AppBar extends StatelessWidget {
  final String categoryName;
  final AppColors colors;

  const _AppBar({required this.categoryName, required this.colors});

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.shortestSide;

    final height = s * 0.12;
    final fontSize = s * 0.055;
    final iconSize = s * 0.04;
    final paddingH = s * 0.04;

    return Padding(
      padding: EdgeInsets.fromLTRB(paddingH, s * 0.03, paddingH, s * 0.02),
      child: SizedBox(
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 🔙 Back Button
            Align(
              alignment: Alignment.centerLeft,
              child: _IconButton(
                onTap: () => Navigator.of(context).pop(),
                backgroundColor: colors.cardBg,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: iconSize,
                  color: colors.text1,
                ),
              ),
            ),

            // 🏷 TITLE
            Padding(
              padding: EdgeInsets.symmetric(horizontal: s * 0.2),
              child: Text(
                categoryName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: colors.text1,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Icon Button
// ─────────────────────────────────────────────
class _IconButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color backgroundColor;
  final Widget child;

  const _IconButton({
    required this.onTap,
    required this.backgroundColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.shortestSide;
    final size = s * 0.11;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(size * 0.3),
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Product Card  ── Grid style
// ─────────────────────────────────────────────
class _ProductCard extends StatefulWidget {
  final dynamic product;
  final AppColors colors;
  final int index;

  const _ProductCard({
    required this.product,
    required this.colors,
    required this.index,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  int _qty = 0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _slideController.forward();
    });

    _loadCartQty();
  }

  Future<void> _loadCartQty() async {
    try {
      final qty = await ApiService().getCartQuantity(
        productId: widget.product.id,
      );
      if (mounted) setState(() => _qty = qty);
    } catch (_) {}
  }

  Future<void> _handleAddTap() async {
    final loggedIn = await ApiService().isLoggedIn();
    if (!loggedIn) {
      showAuthBottomSheet(context);
      return;
    }

    final oldQty = _qty;
    setState(() => _qty = 1);

    try {
      await ApiService().addToCart(productId: widget.product.id, quantity: 1);
    } catch (_) {
      setState(() => _qty = oldQty);
    }
  }

  Future<void> _setQty(int newQty) async {
    final prev = _qty;
    setState(() => _qty = newQty < 0 ? 0 : newQty);

    try {
      if (newQty <= 0) {
        await ApiService().removeCart(widget.product.id);
        setState(() => _qty = 0);
      } else {
        await ApiService().updateCart(
          productId: widget.product.id,
          quantity: newQty,
        );
      }
    } catch (_) {
      setState(() => _qty = prev);
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  bool get _isLowStock => widget.product.quantity < 20;

  @override
  Widget build(BuildContext context) {
    // Use theme from context (preferred)
    final colors = context.colors;

    final p = widget.product;
    final s = MediaQuery.of(context).size.shortestSide;

    // 🔧 Responsive scale
    final imageSize = s * 0.24;
    final gap = s * 0.03;
    final fontTitle = s * 0.035;
    final fontSmall = s * 0.03;
    final fontPrice = s * 0.040;
    final cartSize = s * 0.075;

    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ProductDetailScreen(productId: widget.product.id),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.only(bottom: s * 0.03),
            padding: EdgeInsets.all(s * 0.025),
            decoration: BoxDecoration(
              color: colors.cardBg,
              borderRadius: BorderRadius.circular(s * 0.04),
              // border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                // 🖼 IMAGE + DISCOUNT
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(s * 0.03),
                      child: p.images.isNotEmpty
                          ? Image.network(
                              p.images.first,
                              width: imageSize,
                              height: imageSize,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: imageSize,
                              height: imageSize,
                              color: colors.surface2,
                              child: Icon(
                                Icons.image_outlined,
                                color: colors.text3,
                              ),
                            ),
                    ),

                    if (p.discount != null)
                      Positioned(
                        top: s * 0.02,
                        left: s * 0.02,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: s * 0.02,
                            vertical: s * 0.008,
                          ),
                          decoration: BoxDecoration(
                            color: colors.flashText,
                            borderRadius: BorderRadius.circular(s * 0.02),
                          ),
                          child: Text(
                            "-${p.discount}",
                            style: TextStyle(
                              fontSize: fontSmall * 0.9,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(width: gap),

                // 📄 INFO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // NAME
                      Text(
                        p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: fontTitle,
                          fontWeight: FontWeight.w600,
                          color: colors.text1,
                        ),
                      ),

                      SizedBox(height: s * 0.01),

                      // CATEGORY | BRAND
                      Row(
                        children: [
                          Text(
                            p.categoryName ?? 'Unknown',
                            style: TextStyle(
                              fontSize: fontSmall,
                              color: colors.text2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            " | ",
                            style: TextStyle(
                              fontSize: fontSmall,
                              color: colors.text3,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              CatalogTranslation.translate(
                                p.brandName ?? 'No Brand',
                              ),
                              style: TextStyle(
                                fontSize: fontSmall,
                                color: colors.accent,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: s * 0.01),

                      // DESCRIPTION
                      Text(
                        p.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: fontSmall,
                          color: colors.text3,
                        ),
                      ),

                      SizedBox(height: s * 0.015),

                      // PRICE + CART
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // PRICE
                          Flexible(
                            child: Row(
                              children: [
                                Text(
                                  "\$${p.finalPrice}",
                                  style: TextStyle(
                                    fontSize: fontPrice,
                                    color: colors.accent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (p.discount != null) ...[
                                  SizedBox(width: s * 0.02),
                                  Flexible(
                                    child: Text(
                                      "\$${p.salePrice}",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: fontSmall,
                                        color: colors.text3,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // CART
                          _CartStepper(
                            qty: _qty,
                            loading: _loading,
                            s: cartSize,
                            colors: colors,
                            onAdd: _handleAddTap,
                            onIncrement: () => _setQty(_qty + 1),
                            onDecrement: () => _setQty(_qty - 1),
                          ),
                        ],
                      ),

                      if (_isLowStock)
                        Padding(
                          padding: EdgeInsets.only(top: s * 0.01),
                          child: Text(
                            "Low stock",
                            style: TextStyle(
                              fontSize: fontSmall,
                              color: colors.flashText,
                            ),
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

class _CartStepper extends StatelessWidget {
  final int qty;
  final bool loading;
  final double s;
  final AppColors colors;
  final Future<void> Function() onAdd;
  final Future<void> Function() onIncrement;
  final Future<void> Function() onDecrement;

  const _CartStepper({
    required this.qty,
    required this.loading,
    required this.s,
    required this.colors,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final btn = s;

    if (loading) {
      return SizedBox(
        width: btn,
        height: btn,
        child: Padding(
          padding: EdgeInsets.all(btn * 0.25),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colors.accent,
          ),
        ),
      );
    }

    if (qty == 0) {
      return GestureDetector(
        onTap: onAdd,
        child: Container(
          width: btn,
          height: btn,
          decoration: BoxDecoration(
            color: colors.accent,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      );
    }

    return Container(
      height: btn,
      decoration: BoxDecoration(
        color: colors.accent,
        borderRadius: BorderRadius.circular(btn / 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onDecrement,
            child: SizedBox(
              width: btn,
              height: btn,
              child: const Icon(Icons.remove, color: Colors.white),
            ),
          ),
          SizedBox(
            width: btn * 0.7,
            child: Text(
              "$qty",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          GestureDetector(
            onTap: onIncrement,
            child: SizedBox(
              width: btn,
              height: btn,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Add Button
// ─────────────────────────────────────────────
class _AddButton extends StatefulWidget {
  final VoidCallback onTap;
  final AppColors colors;

  const _AddButton({required this.onTap, required this.colors});

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    _scale = Tween<double>(
      begin: 1,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.shortestSide;

    final size = s * 0.09; // responsive size
    final iconSize = size * 0.55;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: widget.colors.accent,
            borderRadius: BorderRadius.circular(size * 0.3),
            boxShadow: [
              BoxShadow(
                color: widget.colors.accent.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(Icons.add_rounded, color: Colors.white, size: iconSize),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Loading State  ── Grid Skeleton
// ─────────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.shortestSide;

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(s * 0.04, 0, s * 0.04, s * 0.08),
      itemCount: 6,
      itemBuilder: (_, __) => const _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmer;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();

    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _anim = CurvedAnimation(parent: _shimmer, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = MediaQuery.of(context).size.shortestSide;

    // 🔧 responsive sizes
    final imageSize = s * 0.26;
    final fontBig = s * 0.04;
    final fontSmall = s * 0.03;
    final buttonSize = s * 0.085;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final base = Color.lerp(colors.surface2, colors.surface, _anim.value)!;

        return Container(
          margin: EdgeInsets.only(bottom: s * 0.03),
          padding: EdgeInsets.all(s * 0.025),
          decoration: BoxDecoration(
            color: colors.cardBg,
            borderRadius: BorderRadius.circular(s * 0.04),
            // border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              // 🖼 IMAGE
              Container(
                width: imageSize,
                height: imageSize,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(s * 0.03),
                ),
              ),

              SizedBox(width: s * 0.03),

              // 📄 TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Container(
                      height: fontBig,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: base,
                        borderRadius: BorderRadius.circular(s * 0.02),
                      ),
                    ),

                    SizedBox(height: s * 0.015),

                    // Category + Brand
                    Container(
                      height: fontSmall,
                      width: s * 0.4,
                      decoration: BoxDecoration(
                        color: base,
                        borderRadius: BorderRadius.circular(s * 0.02),
                      ),
                    ),

                    SizedBox(height: s * 0.015),

                    // Description
                    Container(
                      height: fontSmall,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: base,
                        borderRadius: BorderRadius.circular(s * 0.02),
                      ),
                    ),

                    SizedBox(height: s * 0.02),

                    // Price
                    Container(
                      height: fontBig,
                      width: s * 0.25,
                      decoration: BoxDecoration(
                        color: base,
                        borderRadius: BorderRadius.circular(s * 0.02),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: s * 0.02),

              // ➕ BUTTON
              Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(buttonSize * 0.3),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  Empty State
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final AppColors colors;
  final String message;

  const _EmptyState({
    required this.colors,
    this.message = 'No products found in this category.',
  });

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.shortestSide;

    final iconBox = s * 0.16;
    final iconSize = s * 0.07;
    final fontSize = s * 0.035;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(s * 0.1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🏪 ICON BOX
            Container(
              width: iconBox,
              height: iconBox,
              decoration: BoxDecoration(
                color: colors.surface2,
                borderRadius: BorderRadius.circular(s * 0.05),
              ),
              child: Icon(
                Icons.storefront_outlined,
                size: iconSize,
                color: colors.text3,
              ),
            ),

            SizedBox(height: s * 0.04),

            // 📝 MESSAGE
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                color: colors.text3,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Error State
// ─────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String error;
  final AppColors colors;

  const _ErrorState({required this.error, required this.colors});

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.shortestSide;

    final iconSize = s * 0.08;
    final titleSize = s * 0.04;
    final textSize = s * 0.032;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(s * 0.06),
        child: Container(
          padding: EdgeInsets.all(s * 0.05),
          decoration: BoxDecoration(
            color: colors.flashBg,
            border: Border.all(color: colors.flashBorder),
            borderRadius: BorderRadius.circular(s * 0.04),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ❌ ICON
              Icon(
                Icons.error_outline_rounded,
                size: iconSize,
                color: colors.flashText,
              ),

              SizedBox(height: s * 0.03),

              // TITLE
              Text(
                'Something went wrong',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colors.flashText,
                  fontSize: titleSize,
                ),
              ),

              SizedBox(height: s * 0.02),

              // ERROR MESSAGE
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: textSize,
                  color: colors.flashText,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
