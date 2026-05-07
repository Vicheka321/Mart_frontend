import 'dart:ui';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  var language = 'en'.obs; // default English

  @override
  void onInit() {
    super.onInit();
    loadLanguage();
  }

  void changeLanguage(String langCode) async {
    language.value = langCode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);

    Get.updateLocale(Locale(langCode));
  }

  void loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('language') ?? 'en';

    language.value = saved;
    Get.updateLocale(Locale(saved));
  }
}