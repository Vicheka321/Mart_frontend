import 'package:flutter/material.dart';
import 'package:mart_frontend/models/brands_model.dart';
import 'package:mart_frontend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BrandsProvider extends ChangeNotifier {
  List<BrandsModel> brands = [];
  Future<void> loadCache() async {
    final prefs = await SharedPreferences.getInstance();

    final cache = prefs.getString('brands_cache');

    if (cache != null) {
      brands = brandsModelFromJson(cache);

      notifyListeners();
    }
  }

  Future<void> fetchBrands() async {
    try {
      final freshBrands = await ApiService().fetchBrands();

      brands = freshBrands;

      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
