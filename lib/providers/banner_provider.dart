import 'package:flutter/material.dart';
import 'package:mart_frontend/models/banners_model.dart';
import 'package:mart_frontend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BannerProvider extends ChangeNotifier {
  List<BannersModel> banners = [];

  Future<void> loadCache() async {
    final prefs = await SharedPreferences.getInstance();

    final cache = prefs.getString('banners_cache');

    if (cache != null) {
      banners = bannersModelFromJson(cache);

      notifyListeners();
    }
  }

    Future<void> fetchBanners() async {
    try {
      final freshBanners = await ApiService().fetchBanners();

      banners = freshBanners;

      notifyListeners();
      
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
