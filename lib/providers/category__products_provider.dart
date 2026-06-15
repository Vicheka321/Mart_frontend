import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/categories_with_products_model.dart';
import '../services/api_service.dart';

class CategoriesWithProductsProvider extends ChangeNotifier {
  List<CategoriesWithProductsModel> categories = [];

  Future<void> loadCache() async {
    final prefs = await SharedPreferences.getInstance();

    final cache = prefs.getString(
      'categories_with_products_cache',
    );

    if (cache != null) {
      categories =
          categoriesWithProductsModelFromJson(cache);

      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    try {
      final fresh =
          await ApiService().fetchCategoriesWithProducts();

      categories = fresh;

      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> init() async {
    await loadCache();

    fetchCategories(); // no await
  }
}