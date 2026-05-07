import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  var isDark = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTheme();
  }

  void toggleTheme(bool value) async {
    isDark.value = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isDark", value);

    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  void loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool("isDark") ?? false;

    isDark.value = saved;
    Get.changeThemeMode(saved ? ThemeMode.dark : ThemeMode.light);
  }
}