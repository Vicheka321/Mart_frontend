// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/cart_provider.dart';
// import '../theme/app_theme.dart';
// import 'cart_bottom_sheet.dart';

// class FloatingCartBar extends StatelessWidget {
//   const FloatingCartBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final cart = context.watch<CartProvider>();
//     final colors = context.colors;
//     final s = MediaQuery.of(context).size.shortestSide;

//     if (cart.itemCount == 0) return const SizedBox.shrink();

//     final itemCount = cart.itemCount;
//     final total = cart.totalPrice;
//     final images = cart.images;

//     return Positioned(
//       bottom: MediaQuery.of(context).padding.bottom + 12,
//       left: s * 0.04,
//       right: s * 0.04,
//       child: GestureDetector(
//         onTap: () async {
//           final provider = context.read<CartProvider>();

//           if (provider.cart == null) {
//             await provider.fetchCart();
//           }

//           if (!context.mounted) return;

//           showModalBottomSheet(
//             context: context,
//             isScrollControlled: true,
//             backgroundColor: Colors.transparent,
//             builder: (_) => const CartBottomSheet(),
//           );
//         },
//         child: Container(
//           padding: EdgeInsets.symmetric(
//             horizontal: s * 0.035,
//             vertical: s * 0.025,
//           ),
//           decoration: BoxDecoration(
//             color: colors.accent,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: colors.accent.withOpacity(0.35),
//                 blurRadius: 24,
//                 offset: const Offset(0, 8),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               // Stacked thumbnails or bag icon
//               if (images.isNotEmpty)
//                 _StackedImages(images: images, size: s * 0.068)
//               else
//                 Icon(
//                   Icons.shopping_bag_rounded,
//                   color: Colors.white,
//                   size: s * 0.055,
//                 ),

//               SizedBox(width: s * 0.03),

//               // Item count pill
//               Container(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: s * 0.022,
//                   vertical: s * 0.008,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.18),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   '$itemCount',
//                   style: TextStyle(
//                     fontSize: s * 0.032,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),

//               SizedBox(width: s * 0.025),

//               // Label
//               Expanded(
//                 child: Text(
//                   'View Cart',
//                   style: TextStyle(
//                     fontSize: s * 0.038,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.white,
//                     letterSpacing: -0.2,
//                   ),
//                 ),
//               ),

//               // Price
//               Text(
//                 '\$${total.toStringAsFixed(2)}',
//                 style: TextStyle(
//                   fontSize: s * 0.038,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.white,
//                 ),
//               ),

//               SizedBox(width: s * 0.015),

//               Icon(
//                 Icons.arrow_forward_ios_rounded,
//                 color: Colors.white.withOpacity(0.7),
//                 size: s * 0.028,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _StackedImages extends StatelessWidget {
//   final List<String> images;
//   final double size;

//   const _StackedImages({required this.images, required this.size});

//   @override
//   Widget build(BuildContext context) {
//     final visible = images.take(3).toList();
//     final overlap = size * 0.55;

//     return SizedBox(
//       width: size + (visible.length - 1) * overlap,
//       height: size,
//       child: Stack(
//         children: List.generate(visible.length, (i) {
//           return Positioned(
//             left: i * overlap,
//             child: Container(
//               width: size,
//               height: size,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: Colors.white.withOpacity(0.4),
//                   width: 1.5,
//                 ),
//               ),
//               child: ClipOval(
//                 child: CachedNetworkImage(
//                   imageUrl: visible[i],
//                   fit: BoxFit.cover,
//                   errorWidget: (_, __, ___) => const Icon(
//                     Icons.image_not_supported_outlined,
//                     color: Colors.white54,
//                     size: 14,
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import 'cart_bottom_sheet.dart';

class FloatingCartBar extends StatefulWidget {
  const FloatingCartBar({super.key});

  @override
  State<FloatingCartBar> createState() => _FloatingCartBarState();
}

class _FloatingCartBarState extends State<FloatingCartBar> {
  double _scale = 1;

  void _setPressed(bool pressed) {
    setState(() => _scale = pressed ? 0.97 : 1);
  }

  Future<void> _open(BuildContext context) async {
    final provider = context.read<CartProvider>();

    if (provider.cart == null) {
      await provider.fetchCart();
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CartBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final colors = context.colors;
    final s = MediaQuery.of(context).size.shortestSide;

    if (cart.itemCount == 0) return const SizedBox.shrink();

    final itemCount = cart.itemCount;
    final total = cart.totalPrice;
    final images = cart.images;

    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 12,
      left: s * 0.04,
      right: s * 0.04,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: GestureDetector(
          onTapDown: (_) => _setPressed(true),
          onTapCancel: () => _setPressed(false),
          onTapUp: (_) => _setPressed(false),
          onTap: () => _open(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                padding: EdgeInsets.symmetric(
                  horizontal: s * 0.032,
                  vertical: s * 0.022,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colors.accent, colors.accent.withOpacity(0.82)],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.16),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.accent.withOpacity(0.4),
                      blurRadius: 28,
                      spreadRadius: -4,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Thumbnails or bag icon inside a soft chip
                    Container(
                      width: s * 0.11,
                      height: s * 0.11,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        shape: BoxShape.circle,
                      ),
                      child: images.isNotEmpty
                          ? _StackedImages(images: images, size: s * 0.078)
                          : Icon(
                              Icons.shopping_bag_rounded,
                              color: Colors.white,
                              size: s * 0.05,
                            ),
                    ),

                    SizedBox(width: s * 0.03),

                    // Label + item count
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View Cart',
                            style: TextStyle(
                              fontSize: s * 0.037,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.2,
                              height: 1.1,
                            ),
                          ),
                          SizedBox(height: s * 0.004),
                          Text(
                            '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                            style: TextStyle(
                              fontSize: s * 0.028,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.72),
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Price pill
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: s * 0.03,
                        vertical: s * 0.016,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: s * 0.035,
                              fontWeight: FontWeight.w800,
                              color: colors.accent,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(width: s * 0.012),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: colors.accent,
                            size: s * 0.032,
                          ),
                        ],
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

class _StackedImages extends StatelessWidget {
  final List<String> images;
  final double size;

  const _StackedImages({required this.images, required this.size});

  @override
  Widget build(BuildContext context) {
    final visible = images.take(3).toList();
    final overlap = size * 0.5;

    return SizedBox(
      width: size + (visible.length - 1) * overlap,
      height: size,
      child: Stack(
        children: List.generate(visible.length, (i) {
          // Later images sit underneath so the front one reads clearly.
          final index = visible.length - 1 - i;
          return Positioned(
            left: index * overlap,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.9),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: visible[index],
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.white24,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white70,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
