import 'package:flutter/material.dart';
import 'package:mart_frontend/services/api_service.dart';

class ProductDetailProvider extends ChangeNotifier {
  final Map<int, dynamic> _cache = {};

  dynamic getProduct(int id) => _cache[id];

  Future<dynamic> getOrFetch(int productId) async {
    if (_cache.containsKey(productId)) {
      _refresh(productId); // refresh in background
      return _cache[productId];
    }

    final product = await ApiService().fetchProduct(productId);
    _cache[productId] = product;
    return product;
  }

  Future<void> _refresh(int productId) async {
    try {
      final product = await ApiService().fetchProduct(productId);

      _cache[productId] = product;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> forceRefresh(int productId) async {
    final product = await ApiService().fetchProduct(productId);

    _cache[productId] = product;
    notifyListeners();
  }

  void clear(int productId) {
    _cache.remove(productId);
    notifyListeners();
  }

  Future<void> preload(int productId) async {
    await getOrFetch(productId);
  }
}
