import 'package:flutter/material.dart';
import '../models/products_model.dart';
import '../services/api_service.dart';

class CartProvider extends ChangeNotifier {
  MyCartModel? cart;
  bool loading = false;
  int optimisticCount = 0;
  Future<void> fetchCart() async {
    final data = await ApiService().getCart();

    cart = data;

    clearOptimistic();

    notifyListeners();
  }

  Future<void> fetchqty({required int productId}) async {
    try {
      final qty = await ApiService().getCartQuantity(productId: productId);
      optimisticCount = 0;
      optimisticTotal = 0;
      notifyListeners();
    } catch (_) {}
  }

  double optimisticTotal = 0;

  final List<String> _optimisticImages = [];

  List<String> get images {
    final serverImages =
        cart?.items
            .where((e) => e.images.isNotEmpty)
            .map((e) => e.images.first)
            .toList() ??
        [];

    return [..._optimisticImages, ...serverImages];
  }

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

  void updateOptimisticQty({required int diff, required double price}) {
    optimisticCount += diff;
    optimisticTotal += price * diff;

    if (optimisticCount < 0) {
      optimisticCount = 0;
    }

    if (optimisticTotal < 0) {
      optimisticTotal = 0;
    }

    notifyListeners();
  }

  void clearOptimistic() {
    optimisticCount = 0;
    optimisticTotal = 0;
    _optimisticImages.clear();
  }

  void removeLocalItem(int productId) {
    if (cart == null) return;

    cart!.items.removeWhere((e) => e.productId == productId);

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
}
