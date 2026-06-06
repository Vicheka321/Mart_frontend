import 'package:flutter/material.dart';
import 'package:mart_frontend/models/products_model.dart';
import 'package:mart_frontend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewArrivalsProvider extends ChangeNotifier {
  List<NewArrivalsModel> products = [];

  Future<void> loadCache() async {
    final prefs = await SharedPreferences.getInstance();

    final cache = prefs.getString('new_arrivals_cache');
    if (cache != null) {
      products = newArrivalsModelFromJson(cache);
      notifyListeners();
    }
  }

  Future<void> fetchNewArrivals() async {
    try {
      products = await ApiService().fetchNewArrivals();

      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
