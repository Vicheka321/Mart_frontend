import 'package:flutter/material.dart';
import 'package:mart_frontend/models/profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';

class ProfileProvider extends ChangeNotifier {
  MyProfileModel? profile;

  Future<void> loadCache() async {
    final prefs = await SharedPreferences.getInstance();

    final cache = prefs.getString('my_profile_cache');

    if (cache != null) {
      profile = myProfileModelFromJson(cache);
      notifyListeners();
    }
  }

  Future<void> fetchProfile() async {
    try {
      final freshProfile = await ApiService().fetchMyProfile();

      profile = freshProfile;

      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> loadGuestProfile() async {
    profile = MyProfileModel(
      id: 0,
      fullName: 'Dear',
      email: '',
      phone: '',
      avatar: 'https://camo.githubusercontent.com/9105e4cd984bdf30d9027d64564d5541774e471fdfb84db12ef7a707b533dd61/68747470733a2f2f63646e2e6a7364656c6976722e6e65742f67682f616c6f68652f617661746172732f706e672f6d656d6f5f31372e706e67',
      createdAt: DateTime.now(),

    );

    notifyListeners();
  }
}
