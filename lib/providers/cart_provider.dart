import 'package:flutter/material.dart';
import '../models/productsModel.dart';
import '../services/api_service.dart';

class CartProvider extends ChangeNotifier {
  MyCartModel? cart;

  bool loading = false;

  // 🔥 CALL API HERE
  Future<void> fetchCart() async {
    try {
      loading = true;
      notifyListeners();

      final data = await ApiService().getCart();

      cart = data;

      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      notifyListeners();
    }
  }

  int get itemCount {
    if (cart == null) return 0;
    return cart!.items.fold(0, (sum, e) => sum + e.qty);
  }

  List<String> get images {
    if (cart == null) return [];
    return cart!.items
        .where((e) => e.images.isNotEmpty)
        .map((e) => e.images.first)
        .toList();
  }
}
