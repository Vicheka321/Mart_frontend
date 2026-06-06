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

//     if (cart.itemCount == 0) {
//       return const SizedBox.shrink();
//     }
//     final itemCount = cart.itemCount;
//     final total = cart.totalPrice;
//     final images = cart.images;

//     return Positioned(
//       bottom: MediaQuery.of(context).padding.bottom + 5,
//       left: s * 0.04,
//       right: s * 0.04,
//       child: GestureDetector(
//         onTap: () {
//           showModalBottomSheet(
//             context: context,
//             isScrollControlled: true,
//             backgroundColor: Colors.transparent,
//             builder: (_) => const CartBottomSheet(),
//           );
//         },
//         child: Container(
//           padding: EdgeInsets.symmetric(
//             horizontal: s * 0.04,
//             vertical: s * 0.028,
//           ),
//           decoration: BoxDecoration(
//             color: colors.surface,
//             borderRadius: BorderRadius.circular(30),
//             border: Border.all(color: colors.border, width: 1),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.08),
//                 blurRadius: 20,
//                 offset: const Offset(0, 6),
//               ),
//               BoxShadow(
//                 color: colors.accent.withOpacity(0.06),
//                 blurRadius: 12,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               // 🛒 Accent icon pill
//               Container(
//                 padding: EdgeInsets.all(s * 0.022),
//                 decoration: BoxDecoration(
//                   color: colors.accentLight,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   Icons.shopping_bag_outlined,
//                   color: colors.accent,
//                   size: s * 0.055,
//                 ),
//               ),

//               SizedBox(width: s * 0.03),

//               // 📸 Stacked product thumbnails (up to 3)
//               if (images.isNotEmpty) ...[
//                 _StackedImages(images: images, size: s * 0.07),
//                 SizedBox(width: s * 0.025),
//               ],

//               // 📝 Label
//               Expanded(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
//                       style: TextStyle(
//                         fontSize: s * 0.03,
//                         fontWeight: FontWeight.w500,
//                         color: colors.text2,
//                         height: 1.2,
//                       ),
//                     ),
//                     Text(
//                       'View Cart',
//                       style: TextStyle(
//                         fontSize: s * 0.038,
//                         fontWeight: FontWeight.w700,
//                         color: colors.text1,
//                         height: 1.2,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               SizedBox(width: s * 0.02),

//               // 💲 Price + chevron
//               Container(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: s * 0.035,
//                   vertical: s * 0.018,
//                 ),
//                 decoration: BoxDecoration(
//                   color: colors.accent,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       '\$${total.toStringAsFixed(2)}',
//                       style: TextStyle(
//                         fontSize: s * 0.038,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.white,
//                       ),
//                     ),
//                     SizedBox(width: s * 0.015),
//                     Icon(
//                       Icons.arrow_forward_ios_rounded,
//                       color: Colors.white.withOpacity(0.85),
//                       size: s * 0.03,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// Stacked circular product image thumbnails
// class _StackedImages extends StatelessWidget {
//   final List<String> images;
//   final double size;

//   const _StackedImages({required this.images, required this.size});

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
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
//                 border: Border.all(color: colors.surface, width: 2),
//                 color: colors.surface2,
//               ),
//               child: ClipOval(
//                 child: Image.network(
//                   visible[i],
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => Icon(
//                     Icons.image_not_supported_outlined,
//                     size: size * 0.5,
//                     color: colors.text3,
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


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import 'cart_bottom_sheet.dart';

class FloatingCartBar extends StatelessWidget {
  const FloatingCartBar({super.key});

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
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const CartBottomSheet(),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: s * 0.035,
            vertical: s * 0.025,
          ),
          decoration: BoxDecoration(
            color: colors.accent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colors.accent.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Stacked thumbnails or bag icon
              if (images.isNotEmpty)
                _StackedImages(images: images, size: s * 0.068)
              else
                Icon(
                  Icons.shopping_bag_rounded,
                  color: Colors.white,
                  size: s * 0.055,
                ),

              SizedBox(width: s * 0.03),

              // Item count pill
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: s * 0.022,
                  vertical: s * 0.008,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$itemCount',
                  style: TextStyle(
                    fontSize: s * 0.032,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),

              SizedBox(width: s * 0.025),

              // Label
              Expanded(
                child: Text(
                  'View Cart',
                  style: TextStyle(
                    fontSize: s * 0.038,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ),

              // Price
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: s * 0.038,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              SizedBox(width: s * 0.015),

              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.7),
                size: s * 0.028,
              ),
            ],
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
    final overlap = size * 0.55;

    return SizedBox(
      width: size + (visible.length - 1) * overlap,
      height: size,
      child: Stack(
        children: List.generate(visible.length, (i) {
          return Positioned(
            left: i * overlap,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: visible[i],
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.white54,
                    size: 14,
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
