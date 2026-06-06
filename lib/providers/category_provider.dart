import 'package:flutter/material.dart';
import 'package:mart_frontend/models/categories_model.dart';
import 'package:mart_frontend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryProvider extends ChangeNotifier {
  List<CategoriesModel> categories = [];

  Future<void> loadCache() async {
    final prefs = await SharedPreferences.getInstance();

    final cache = prefs.getString('categories_cache');

    if (cache != null) {
      categories = categoriesModelFromJson(cache);

      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    try {
      final freshCategories = await ApiService().fetchCategories();

      categories = freshCategories;

      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
