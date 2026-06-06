import 'package:flutter/material.dart';
import 'package:mart_frontend/models/products_model.dart';
import 'package:mart_frontend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BestSellerProvider extends ChangeNotifier {
  List<BestSellerModel> products = [];

  Future<void> loadCache() async {
    final prefs = await SharedPreferences.getInstance();

    final cache = prefs.getString('best_sellers_cache');
    if (cache != null) {
      products = bestSellerModelFromJson(cache);

      notifyListeners();
    }
  }

  Future<void> fetchBestSellers() async {
    try {
      final freshProducts = await ApiService().fetchBestSellers();

      products = freshProducts;

      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
