import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/brands_with_products.dart';
import '../services/api_service.dart';

class BrandsWithProductsProvider extends ChangeNotifier {
  List<BrandsWithProductsModel> brands = [];

  bool loading = false;

  Future<void> loadCache() async {
    final prefs = await SharedPreferences.getInstance();

    final cache = prefs.getString('brands_with_products_cache');

    if (cache != null) {
      brands = brandsWithProductsModelFromJson(cache);

      notifyListeners();
    }
  }

  Future<void> fetchBrands() async {
    try {
      loading = true;

      final fresh = await ApiService().fetchBrandsWithProducts();

      brands = fresh;

      loading = false;

      notifyListeners();
    } catch (e) {
      loading = false;
      debugPrint(e.toString());
    }
  }

  Future<void> init() async {
    await loadCache();

    fetchBrands(); // don't await
  }
}
