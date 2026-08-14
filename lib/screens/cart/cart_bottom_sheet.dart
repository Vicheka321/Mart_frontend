import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:mart_frontend/models/products_model.dart';
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
  final Map<int, Timer> _debounceTimers = {};

  Future<void> _updateQty(
    BuildContext context,
    int productId,
    int newQty,
  ) async {
    final provider = context.read<CartProvider>();

    final item = provider.cart!.items.firstWhere(
      (e) => e.productId == productId,
    );

    final oldQty = item.qty;

    // Update UI immediately
    provider.updateLocalQty(productId: productId, qty: newQty);
    _debounceTimers[productId]?.cancel();

    _debounceTimers[productId] = Timer(
      const Duration(milliseconds: 300),
      () async {
        try {
          if (newQty <= 0) {
            await ApiService().removeCart(productId);

            provider.removeLocalItem(productId);

            if (!mounted) return;

            if (provider.cart?.items.isEmpty ?? true) {
              Navigator.of(context).pop();
            }
          } else {
            await ApiService().updateCart(
              productId: productId,
              quantity: newQty,
            );
          }
        } catch (e) {
          // Restore previous quantity
          provider.updateLocalQty(productId: productId, qty: oldQty);

          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Failed to update cart')));
          }
        } finally {}
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>().cart;
    final colors = context.colors;
    final s = MediaQuery.of(context).size.shortestSide;
    if (cart == null || cart.items.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });

      return const SizedBox.shrink();
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
                                Row(
                                  children: [
                                    Text(
                                      '\$${item.price}',
                                      style: TextStyle(
                                        fontSize: s * 0.036,
                                        fontWeight: FontWeight.w500,
                                        color: colors.text2,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Stock ${(item.stock - item.qty).clamp(0, item.stock)}',
                                      style: TextStyle(
                                        fontSize: s * 0.036,
                                        fontWeight: FontWeight.w500,
                                        color: colors.text2,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: s * 0.03),

                          // Qty stepper
                          _QtyStepper(
                            qty: item.qty,
                            stock: item.stock,
                            accent: colors.accent,
                            surface: colors.surface2,
                            s: s,
                            onDecrement: () => _updateQty(
                              context,
                              item.productId,
                              item.qty - 1,
                            ),
                            onIncrement: item.qty >= item.stock
                                ? null
                                : () => _updateQty(
                                    context,
                                    item.productId,
                                    item.qty + 1,
                                  ),
                            onQtyChanged: (newQty) =>
                                _updateQty(context, item.productId, newQty),
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
                        MaterialPageRoute(
                          builder: (_) =>
                              CheckoutScreen(items: [], fromCart: true),
                        ),
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

class _QtyStepper extends StatefulWidget {
  final int qty;
  final int stock;
  final Color accent;
  final Color surface;
  final double s;
  final VoidCallback onDecrement;
  final VoidCallback? onIncrement;
  final ValueChanged<int> onQtyChanged;

  const _QtyStepper({
    required this.qty,
    required this.stock,
    required this.accent,
    required this.surface,
    required this.s,
    required this.onDecrement,
    this.onIncrement,
    required this.onQtyChanged,
  });

  @override
  State<_QtyStepper> createState() => _QtyStepperState();
}

class _QtyStepperState extends State<_QtyStepper> {
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
  void didUpdateWidget(covariant _QtyStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If qty changed from outside (e.g. +/- buttons) while the field
    // isn't focused, keep the text field in sync.
    if (!_focusNode.hasFocus && oldWidget.qty != widget.qty) {
      _controller.text = '${widget.qty}';
    }
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // Select all text so typing replaces the current value.
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    } else {
      _submit();
    }
  }

  void _submit() {
    final raw = _controller.text.trim();
    int? value = int.tryParse(raw);

    // Invalid or empty input -> clamp to minimum.
    if (value == null || value < 1) {
      value = 1;
    }
    // Safety net: never exceed available stock
    // (the input formatter already blocks this while typing).
    if (value > widget.stock) {
      value = widget.stock;
    }

    // Reflect the clamped value back into the field.
    _controller.text = '$value';

    // Only fire the update if the value actually changed —
    // avoids redundant API calls / debounce restarts.
    if (value != widget.qty) {
      widget.onQtyChanged(value);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepBtn(
          icon: widget.qty <= 1 ? Icons.delete_outline_rounded : Icons.remove,
          color: widget.qty <= 1 ? Colors.red.shade400 : widget.accent,
          bg: widget.qty <= 1
              ? Colors.red.shade50
              : widget.accent.withValues(alpha: 0.1),
          size: widget.s * 0.075,
          onTap: widget.onDecrement,
        ),
        Container(
          width: widget.s * 0.13,
          margin: EdgeInsets.symmetric(horizontal: widget.s * 0.015),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _MaxValueInputFormatter(max: widget.stock),
            ],
            style: TextStyle(
              fontSize: widget.s * 0.042,
              fontWeight: FontWeight.w700,
              color: widget.accent,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: widget.s * 0.018),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: widget.accent.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: widget.accent.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: widget.accent, width: 1.5),
              ),
            ),
            onSubmitted: (_) => _focusNode.unfocus(),
          ),
        ),
        _StepBtn(
          icon: Icons.add,
          color: widget.onIncrement == null ? Colors.grey : widget.accent,
          bg: widget.onIncrement == null
              ? Colors.grey.shade200
              : widget.accent.withValues(alpha: 0.1),
          size: widget.s * 0.075,
          onTap: widget.onIncrement,
        ),
      ],
    );
  }
}

/// Prevents the user from ever typing a number greater than [max].
/// Rejects the edit in real time instead of waiting for blur.
class _MaxValueInputFormatter extends TextInputFormatter {
  final int max;

  _MaxValueInputFormatter({required this.max});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final parsed = int.tryParse(newValue.text);
    if (parsed == null) return oldValue;

    if (parsed > max) return oldValue; // reject the keystroke entirely

    return newValue;
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  final double size;
  final VoidCallback? onTap;

  const _StepBtn({
    required this.icon,
    required this.color,
    required this.bg,
    required this.size,
    this.onTap,
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
