import 'package:flutter/material.dart';
import 'package:mart_frontend/models/products_model.dart';
import 'package:mart_frontend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecommendProvider extends ChangeNotifier {
  List<RecommendedModel> recommended = [];

  Future<void> loadCache() async {
    final prefs = await SharedPreferences.getInstance();

    final cache = prefs.getString('recommended_cache');

    if (cache != null) {
      recommended = recommendedModelFromJson(cache);

      notifyListeners();
    }
  }

    Future<void> fetchRecommended() async {
    try {
      final freshRecommended = await ApiService().fetchRecommended();

      recommended = freshRecommended;

      notifyListeners();
      
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
