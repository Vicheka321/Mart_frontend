import 'package:flutter/material.dart';



// ── Place this inside your main Scaffold, above bottomNavigationBar ──

class FloatingCartBar extends StatelessWidget {
  final int itemCount;
  final double totalPrice;
  final VoidCallback onCheckout;

  const FloatingCartBar({
    super.key,
    required this.itemCount,
    required this.totalPrice,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      offset: itemCount > 0 ? Offset.zero : const Offset(0, 2),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: itemCount > 0 ? 1 : 0,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1B5E20),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B5E20).withOpacity(.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // ── Badge ────────────────────────────────────────
              _AnimatedBadge(count: itemCount),
              const SizedBox(width: 10),

              // ── Labels ───────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'items in cart',
                      style: TextStyle(
                        color: Colors.green[200],
                        fontSize: 11,
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        '\$${totalPrice.toStringAsFixed(2)}',
                        key: ValueKey(totalPrice.toStringAsFixed(2)),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Checkout button ───────────────────────────────
              GestureDetector(
                onTap: onCheckout,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.shopping_cart_outlined,
                          color: Colors.white, size: 15),
                      SizedBox(width: 6),
                      Text(
                        'Checkout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bouncing badge ─────────────────────────────────────────────────
class _AnimatedBadge extends StatefulWidget {
  final int count;
  const _AnimatedBadge({required this.count});

  @override
  State<_AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<_AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = Tween<double>(begin: 1, end: 1.4).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeOutBack),
    );
  }

  @override
  void didUpdateWidget(_AnimatedBadge old) {
    super.didUpdateWidget(old);
    if (old.count != widget.count) {
      _c.forward(from: 0).then((_) => _c.reverse());
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '${widget.count}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}


// In your product list page — track cart state here
int _totalItems = 0;
double _totalPrice = 0;

// Pass to Scaffold's bottomNavigationBar or as a Stack overlay:
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // your product grid...
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: FloatingCartBar(
            itemCount: _totalItems,
            totalPrice: _totalPrice,
            onCheckout: () => Navigator.pushNamed(context, '/checkout'),
          ),
        ),
      ],
    ),
  );
}