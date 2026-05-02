import 'package:flutter/material.dart';
import '../screens/theme/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  final String title;
  final Future<List<dynamic>> Function() fetch;

  const ProductListScreen({
    super.key,
    required this.title,
    required this.fetch,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.fetch();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _Header(title: widget.title),

            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _LoadingState();
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text("Error"));
                  }

                  final products = snapshot.data ?? [];

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return _ProductCardList(
                        product: products[index],
                        index: index,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// HEADER (same style as code 1)
////////////////////////////////////////////////////////////
class _Header extends StatelessWidget {
  final String title;

  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = MediaQuery.of(context).size.shortestSide;

    return Padding(
      padding: EdgeInsets.fromLTRB(s * 0.04, s * 0.03, s * 0.04, s * 0.02),
      child: SizedBox(
        height: s * 0.12,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: s * 0.11,
                  height: s * 0.11,
                  decoration: BoxDecoration(
                    color: colors.cardBg,
                    borderRadius: BorderRadius.circular(s * 0.3),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: s * 0.04,
                    color: colors.text1,
                  ),
                ),
              ),
            ),

            Text(
              title,
              style: TextStyle(
                fontSize: s * 0.055,
                fontWeight: FontWeight.w700,
                color: colors.text1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// PRODUCT CARD (NOW SAME AS CODE 1)
////////////////////////////////////////////////////////////
class _ProductCardList extends StatefulWidget {
  final dynamic product;
  final int index;

  const _ProductCardList({required this.product, required this.index});

  @override
  State<_ProductCardList> createState() => _ProductCardListState();
}

class _ProductCardListState extends State<_ProductCardList>
    with SingleTickerProviderStateMixin {
  int _qty = 0;
  bool _loading = false;

  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _controller.forward();
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

  bool get _isLowStock => widget.product.quantity < 20;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final colors = context.colors;
    final s = MediaQuery.of(context).size.shortestSide;

    /// ✅ EXACT SAME SIZES AS CODE 1
    final imageSize = s * 0.24;
    final gap = s * 0.03;
    final fontTitle = s * 0.035;
    final fontSmall = s * 0.03;
    final fontPrice = s * 0.040;
    final cartSize = s * 0.075;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(productId: p.id),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.only(bottom: s * 0.03),
            padding: EdgeInsets.all(s * 0.025),
            decoration: BoxDecoration(
              color: colors.cardBg,
              borderRadius: BorderRadius.circular(s * 0.04),
            ),
            child: Row(
              children: [
                /// IMAGE
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
                          child: Icon(Icons.image, color: colors.text3),
                        ),
                ),

                SizedBox(width: gap),

                /// INFO (MATCHED TO CODE 1)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

                      Row(
                        children: [
                          Text(
                            "${p.categoryName ?? 'Unknown'}",
                            style: TextStyle(
                              fontSize: fontSmall,
                              color: colors.text2,
                            ),
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
                              "${p.brandName ?? 'No Brand'}",
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

                      Text(
                        p.description ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: fontSmall,
                          color: colors.text3,
                        ),
                      ),

                      SizedBox(height: s * 0.015),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                                  Text(
                                    "\$${p.salePrice}",
                                    style: TextStyle(
                                      fontSize: fontSmall,
                                      color: colors.text3,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

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

////////////////////////////////////////////////////////////
/// CART BUTTON
////////////////////////////////////////////////////////////
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
