import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../checkout/checkout_screen.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/skeleton_loader.dart';
import '../theme/app_theme.dart';

class CartBottomSheet extends StatefulWidget {
  const CartBottomSheet({super.key});

  @override
  State<CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends State<CartBottomSheet> {
  final Set<int> _updatingItems = {};

  Future<void> _updateQty(
    BuildContext context,
    int productId,
    int newQty,
  ) async {
    if (_updatingItems.contains(productId)) return;

    setState(() => _updatingItems.add(productId));

    try {
      if (newQty <= 0) {
        await ApiService().removeCart(productId);
      } else {
        await ApiService().updateCart(productId: productId, quantity: newQty);
      }
      if (context.mounted) {
        await context.read<CartProvider>().fetchCart();
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _updatingItems.remove(productId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>().cart;
    final colors = context.colors;
    final s = MediaQuery.of(context).size.shortestSide;

    if (cart == null || cart.items.isEmpty) {
      return _EmptyCart(colors: colors, s: s);
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Drag handle ──────────────────────────────────────
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 14),

              // ── Title ────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: s * 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cart',
                      style: TextStyle(
                        fontSize: s * 0.052,
                        fontWeight: FontWeight.w700,
                        color: colors.text1,
                      ),
                    ),
                    Text(
                      '${cart.items.fold(0, (sum, e) => sum + e.qty)} items',
                      style: TextStyle(
                        fontSize: s * 0.035,
                        color: colors.text3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Item list ────────────────────────────────────────
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: s * 0.05,
                    vertical: 4,
                  ),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: colors.border),
                  itemBuilder: (_, i) {
                    final item = cart.items[i];
                    final isUpdating = _updatingItems.contains(item.productId);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          // Product image
                          Container(
                            width: s * 0.16,
                            height: s * 0.16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Padding(
                              padding: EdgeInsets.all(s * 0.015),
                              child: CachedNetworkImage(
                                imageUrl: item.images.isNotEmpty
                                    ? item.images.first
                                    : '',
                                fit: BoxFit.contain,
                                placeholder: (_, __) => Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colors.accent,
                                    ),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Icon(
                                  Icons.image_not_supported_outlined,
                                  color: colors.text3,
                                  size: s * 0.07,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: s * 0.04),

                          // Name + price
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: s * 0.038,
                                    fontWeight: FontWeight.w600,
                                    color: colors.text1,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${item.price}',
                                  style: TextStyle(
                                    fontSize: s * 0.036,
                                    fontWeight: FontWeight.w500,
                                    color: colors.text2,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: s * 0.03),

                          // Qty stepper
                          isUpdating
                              ? SizedBox(
                                  width: s * 0.06,
                                  height: s * 0.06,
                                  child: SkeletonBox(
                                    width: s * 0.06,
                                    height: s * 0.06,
                                    borderRadius: BorderRadius.circular(
                                      s * 0.03,
                                    ),
                                    baseColor: colors.accent.withValues(
                                      alpha: 0.18,
                                    ),
                                    highlightColor: colors.accent.withValues(
                                      alpha: 0.35,
                                    ),
                                  ),
                                )
                              : _QtyStepper(
                                  qty: item.qty,
                                  accent: colors.accent,
                                  surface: colors.surface2,
                                  s: s,
                                  onDecrement: () => _updateQty(
                                    context,
                                    item.productId,
                                    item.qty - 1,
                                  ),
                                  onIncrement: () => _updateQty(
                                    context,
                                    item.productId,
                                    item.qty + 1,
                                  ),
                                ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ── Bottom: total + checkout button ──────────────────
              Container(
                padding: EdgeInsets.fromLTRB(
                  s * 0.05,
                  16,
                  s * 0.05,
                  MediaQuery.of(context).padding.bottom + 20,
                ),
                decoration: BoxDecoration(
                  color: colors.background,
                  border: Border(
                    top: BorderSide(color: colors.border, width: 1),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: s * 0.14,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CheckoutScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Checkout Now (\$${cart.totalPrice.toStringAsFixed(2)})',
                          style: TextStyle(
                            fontSize: s * 0.042,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: s * 0.025),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${cart.items.fold(0, (sum, e) => sum + e.qty)}',
                            style: TextStyle(
                              fontSize: s * 0.034,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: s * 0.02),
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: s * 0.05,
                          color: Colors.white,
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
    );
  }
}

// ── Quantity stepper widget ──────────────────────────────────────────────────

class _QtyStepper extends StatelessWidget {
  final int qty;
  final Color accent;
  final Color surface;
  final double s;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QtyStepper({
    required this.qty,
    required this.accent,
    required this.surface,
    required this.s,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepBtn(
          icon: qty <= 1 ? Icons.delete_outline_rounded : Icons.remove,
          color: qty <= 1 ? Colors.red.shade400 : accent,
          bg: qty <= 1 ? Colors.red.shade50 : accent.withValues(alpha: 0.1),
          size: s * 0.075,
          onTap: onDecrement,
        ),
        SizedBox(
          width: s * 0.09,
          child: Text(
            '$qty',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: s * 0.042,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ),
        _StepBtn(
          icon: Icons.add,
          color: accent,
          bg: accent.withValues(alpha: 0.1),
          size: s * 0.075,
          onTap: onIncrement,
        ),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  final double size;
  final VoidCallback onTap;

  const _StepBtn({
    required this.icon,
    required this.color,
    required this.bg,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: size * 0.55),
      ),
    );
  }
}

// ── Empty cart state ─────────────────────────────────────────────────────────

class _EmptyCart extends StatelessWidget {
  final AppColors colors;
  final double s;

  const _EmptyCart({required this.colors, required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.all(s * 0.08),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 32),
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Icon(
            Icons.shopping_cart_outlined,
            size: s * 0.18,
            color: colors.text3,
          ),
          SizedBox(height: s * 0.04),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: s * 0.045,
              fontWeight: FontWeight.w600,
              color: colors.text1,
            ),
          ),
          SizedBox(height: s * 0.02),
          Text(
            'Add items to get started',
            style: TextStyle(fontSize: s * 0.035, color: colors.text3),
          ),
          SizedBox(height: s * 0.06),
        ],
      ),
    );
  }
}
