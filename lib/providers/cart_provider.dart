// // import 'package:flutter/material.dart';
// // import '../models/products_model.dart';
// // import '../services/api_service.dart';

// // class CartProvider extends ChangeNotifier {
// //   MyCartModel? cart;
// //   bool loading = false;
// //   int optimisticCount = 0;
// //   Future<void> fetchCart() async {
// //     final data = await ApiService().getCart();

// //     cart = data;

// //     clearOptimistic();

// //     notifyListeners();
// //   }

// //   Future<void> fetchqty({required int productId}) async {
// //     try {
// //       final qty = await ApiService().getCartQuantity(productId: productId);
// //       optimisticCount = 0;
// //       optimisticTotal = 0;
// //       notifyListeners();
// //     } catch (_) {}
// //   }

// //   double optimisticTotal = 0;

// //   final List<String> _optimisticImages = [];

// //   List<String> get images {
// //     final serverImages =
// //         cart?.items
// //             .where((e) => e.images.isNotEmpty)
// //             .map((e) => e.images.first)
// //             .toList() ??
// //         [];

// //     return [..._optimisticImages, ...serverImages];
// //   }

// //   void addOptimisticItem({
// //     required int productId,
// //     required int quantity,
// //     required String image,
// //     required double price,
// //   }) {
// //     optimisticCount += quantity;
// //     optimisticTotal += price * quantity;

// //     if (!_optimisticImages.contains(image)) {
// //       _optimisticImages.insert(0, image);
// //     }

// //     notifyListeners();
// //   }

// //   void updateOptimisticQty({required int diff, required double price}) {
// //     optimisticCount += diff;
// //     optimisticTotal += price * diff;

// //     if (optimisticCount < 0) {
// //       optimisticCount = 0;
// //     }

// //     if (optimisticTotal < 0) {
// //       optimisticTotal = 0;
// //     }

// //     notifyListeners();
// //   }

// //   void clearOptimistic() {
// //     optimisticCount = 0;
// //     optimisticTotal = 0;
// //     _optimisticImages.clear();
// //   }

// //   void removeLocalItem(int productId) {
// //     if (cart == null) return;

// //     cart!.items.removeWhere((e) => e.productId == productId);

// //     notifyListeners();
// //   }

// //   int get itemCount {
// //     final serverCount = cart?.items.fold<int>(0, (sum, e) => sum + e.qty) ?? 0;

// //     return serverCount + optimisticCount;
// //   }

// //   double get totalPrice {
// //     final serverTotal = cart?.totalPrice ?? 0;

// //     return serverTotal + optimisticTotal;
// //   }

// //   void updateLocalQty({required int productId, required int qty}) {
// //     if (cart == null) return;

// //     final index = cart!.items.indexWhere((e) => e.productId == productId);

// //     if (index == -1) return;

// //     cart!.items[index].qty = qty;

// //     notifyListeners();
// //   }
// // }

// import 'package:flutter/material.dart';
// import '../models/products_model.dart';
// import '../services/api_service.dart';

// class CartProvider extends ChangeNotifier {
//   MyCartModel? cart;
//   bool loading = false;

//   int optimisticCount = 0;
//   double optimisticTotal = 0;
//   final List<String> _optimisticImages = [];

//   Future<void> fetchCart() async {
//     final data = await ApiService().getCart();
//     cart = data;
//     clearOptimistic();
//     notifyListeners();
//   }

//   List<String> get images {
//     final serverImages =
//         cart?.items
//             .where((e) => e.images.isNotEmpty)
//             .map((e) => e.images.first)
//             .toList() ??
//         [];

//     return [..._optimisticImages, ...serverImages];
//   }

//   /// New item being added (not yet confirmed by server)
//   void addOptimisticItem({
//     required int productId,
//     required int quantity,
//     required String image,
//     required double price,
//   }) {
//     optimisticCount += quantity;
//     optimisticTotal += price * quantity;

//     if (!_optimisticImages.contains(image)) {
//       _optimisticImages.insert(0, image);
//     }

//     notifyListeners();
//   }

//   void addLocalItem({required Item item}) {
//     if (cart == null) return;

//     final index = cart!.items.indexWhere((e) => e.productId == item.productId);

//     if (index != -1) {
//       cart!.items[index] = item;
//     } else {
//       cart!.items.add(item);
//     }

//     _recalculateTotal();

//     notifyListeners();
//   }

//   /// Existing item qty changed by diff (+1 / -1)
//   void updateOptimisticQty({required int diff, required double price}) {
//     optimisticCount += diff;
//     optimisticTotal += price * diff;

//     if (optimisticCount < 0) optimisticCount = 0;
//     if (optimisticTotal < 0) optimisticTotal = 0;

//     notifyListeners();
//   }

//   void clearOptimistic() {
//     optimisticCount = 0;
//     optimisticTotal = 0;
//     _optimisticImages.clear();
//     notifyListeners();
//   }

//   // void removeLocalItem(int productId) {
//   //   if (cart == null) return;
//   //   cart!.items.removeWhere((e) => e.productId == productId);
//   //   notifyListeners();
//   // }
//   void removeLocalItem(int productId) {
//     if (cart == null) return;

//     cart!.items.removeWhere((e) => e.productId == productId);

//     _recalculateTotal();

//     notifyListeners();
//   }

//   // void updateLocalQty({required int productId, required int qty}) {
//   //   if (cart == null) return;

//   //   final index = cart!.items.indexWhere((e) => e.productId == productId);

//   //   if (index == -1) return;

//   //   final item = cart!.items[index];

//   //   item.qty = qty;

//   //   final price = double.parse(item.price);

//   //   item.totalPrice = price * qty;

//   //   _recalculateTotal();

//   //   notifyListeners();
//   // }
//   void updateLocalQty({required int productId, required int qty}) {
//     if (cart == null) return;

//     final index = cart!.items.indexWhere((e) => e.productId == productId);

//     if (index == -1) return;

//     if (qty == 0) {
//       cart!.items.removeAt(index);
//     } else {
//       final item = cart!.items[index];

//       item.qty = qty;

//       final price = double.parse(item.price);

//       item.totalPrice = price * qty;
//     }

//     cart!.totalPrice = cart!.items.fold(0.0, (sum, e) => sum + e.totalPrice);

//     notifyListeners();
//   }

//   int get itemCount {
//     final serverCount = cart?.items.fold<int>(0, (sum, e) => sum + e.qty) ?? 0;
//     return serverCount + optimisticCount;
//   }

//   double get totalPrice {
//     final serverTotal = cart?.totalPrice ?? 0;
//     return serverTotal + optimisticTotal;
//   }

//   void clear() {
//     cart = null;

//     optimisticCount = 0;
//     optimisticTotal = 0;
//     _optimisticImages.clear();

//     notifyListeners();
//   }

//   void _recalculateTotal() {
//     if (cart == null) return;

//     cart!.totalPrice = cart!.items.fold(
//       0.0,
//       (sum, item) => sum + item.totalPrice,
//     );
//   }
// }

















































// import 'package:flutter/material.dart';
// import '../models/products_model.dart';
// import '../services/api_service.dart';

// class CartProvider extends ChangeNotifier {
//   MyCartModel? cart;
//   bool loading = false;
//   int optimisticCount = 0;
//   Future<void> fetchCart() async {
//     final data = await ApiService().getCart();

//     cart = data;

//     clearOptimistic();

//     notifyListeners();
//   }

//   Future<void> fetchqty({required int productId}) async {
//     try {
//       final qty = await ApiService().getCartQuantity(productId: productId);
//       optimisticCount = 0;
//       optimisticTotal = 0;
//       notifyListeners();
//     } catch (_) {}
//   }

//   double optimisticTotal = 0;

//   final List<String> _optimisticImages = [];

//   List<String> get images {
//     final serverImages =
//         cart?.items
//             .where((e) => e.images.isNotEmpty)
//             .map((e) => e.images.first)
//             .toList() ??
//         [];

//     return [..._optimisticImages, ...serverImages];
//   }

//   void addOptimisticItem({
//     required int productId,
//     required int quantity,
//     required String image,
//     required double price,
//   }) {
//     optimisticCount += quantity;
//     optimisticTotal += price * quantity;

//     if (!_optimisticImages.contains(image)) {
//       _optimisticImages.insert(0, image);
//     }

//     notifyListeners();
//   }

//   void updateOptimisticQty({required int diff, required double price}) {
//     optimisticCount += diff;
//     optimisticTotal += price * diff;

//     if (optimisticCount < 0) {
//       optimisticCount = 0;
//     }

//     if (optimisticTotal < 0) {
//       optimisticTotal = 0;
//     }

//     notifyListeners();
//   }

//   void clearOptimistic() {
//     optimisticCount = 0;
//     optimisticTotal = 0;
//     _optimisticImages.clear();
//   }

//   void removeLocalItem(int productId) {
//     if (cart == null) return;

//     cart!.items.removeWhere((e) => e.productId == productId);

//     notifyListeners();
//   }

//   int get itemCount {
//     final serverCount = cart?.items.fold<int>(0, (sum, e) => sum + e.qty) ?? 0;

//     return serverCount + optimisticCount;
//   }

//   double get totalPrice {
//     final serverTotal = cart?.totalPrice ?? 0;

//     return serverTotal + optimisticTotal;
//   }

//   void updateLocalQty({required int productId, required int qty}) {
//     if (cart == null) return;

//     final index = cart!.items.indexWhere((e) => e.productId == productId);

//     if (index == -1) return;

//     cart!.items[index].qty = qty;

//     notifyListeners();
//   }
// }

import 'package:flutter/material.dart';
import '../models/products_model.dart';
import '../services/api_service.dart';

class CartProvider extends ChangeNotifier {
  MyCartModel? cart;
  bool loading = false;

  int optimisticCount = 0;
  double optimisticTotal = 0;
  final List<String> _optimisticImages = [];
  bool cartLoaded = false;

  Future<void> fetchCart() async {
    final data = await ApiService().getCart();
    cart = data;
    // cartLoaded = true;
    // loading = false;
    clearOptimistic();
    notifyListeners();
  }

  List<String> get images {
    final serverImages =
        cart?.items
            .where((e) => e.images.isNotEmpty)
            .map((e) => e.images.first)
            .toList() ??
        [];

    return [..._optimisticImages, ...serverImages];
  }

  /// New item being added (not yet confirmed by server)
  void addOptimisticItem({
    required int productId,
    required int quantity,
    required String image,
    required double price,
  }) {
    optimisticCount += quantity;
    optimisticTotal += price * quantity;

    if (!_optimisticImages.contains(image)) {
      _optimisticImages.insert(0, image);
    }

    notifyListeners();
  }

  void addLocalItem({required Item item}) {
    if (cart == null) return;

    final index = cart!.items.indexWhere((e) => e.productId == item.productId);

    if (index != -1) {
      cart!.items[index] = item;
    } else {
      cart!.items.add(item);
    }

    _recalculateTotal();

    notifyListeners();
  }

  /// Existing item qty changed by diff (+1 / -1)
  void updateOptimisticQty({required int diff, required double price}) {
    optimisticCount += diff;
    optimisticTotal += price * diff;

    if (optimisticCount < 0) optimisticCount = 0;
    if (optimisticTotal < 0) optimisticTotal = 0;

    notifyListeners();
  }

  void clearOptimistic() {
    optimisticCount = 0;
    optimisticTotal = 0;
    _optimisticImages.clear();
    notifyListeners();
  }

  // void removeLocalItem(int productId) {
  //   if (cart == null) return;
  //   cart!.items.removeWhere((e) => e.productId == productId);
  //   notifyListeners();
  // }
  void removeLocalItem(int productId) {
    if (cart == null) return;

    cart!.items.removeWhere((e) => e.productId == productId);

    _recalculateTotal();

    notifyListeners();
  }

  // void updateLocalQty({required int productId, required int qty}) {
  //   if (cart == null) return;

  //   final index = cart!.items.indexWhere((e) => e.productId == productId);

  //   if (index == -1) return;

  //   final item = cart!.items[index];

  //   item.qty = qty;

  //   final price = double.parse(item.price);

  //   item.totalPrice = price * qty;

  //   _recalculateTotal();

  //   notifyListeners();
  // }
  void updateLocalQty({required int productId, required int qty}) {
    if (cart == null) return;

    final index = cart!.items.indexWhere((e) => e.productId == productId);

    if (index == -1) return;

    if (qty == 0) {
      cart!.items.removeAt(index);
    } else {
      final item = cart!.items[index];

      item.qty = qty;

      final price = double.parse(item.price);

      item.totalPrice = price * qty;
    }

    cart!.totalPrice = cart!.items.fold(0.0, (sum, e) => sum + e.totalPrice);

    notifyListeners();
  }

  int get itemCount {
    final serverCount = cart?.items.fold<int>(0, (sum, e) => sum + e.qty) ?? 0;
    return serverCount + optimisticCount;
  }

  double get totalPrice {
    final serverTotal = cart?.totalPrice ?? 0;
    return serverTotal + optimisticTotal;
  }

  void clear() {
    cart = null;

    optimisticCount = 0;
    optimisticTotal = 0;
    _optimisticImages.clear();

    notifyListeners();
  }

  void _recalculateTotal() {
    if (cart == null) return;

    cart!.totalPrice = cart!.items.fold(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );
  }
}
