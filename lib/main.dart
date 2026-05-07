import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/cart_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/theme/theme_controller.dart';
import 'controllers/language_controller.dart';
import 'translations/app_translations.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
      child: MyApp(),
    ),
  );
}

//
// ─────────────────────────────────────────────
// THEME CONTROLLER (GETX)
// ─────────────────────────────────────────────
//

//
// ─────────────────────────────────────────────
// MAIN APP
// ─────────────────────────────────────────────
//

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ThemeController controller = Get.put(ThemeController());
  final languageController = Get.put(LanguageController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        translations: AppTranslations(),
        locale: Locale(languageController.language.value),
        fallbackLocale: const Locale('en'),
        debugShowCheckedModeBanner: false,

        // 🌞 Light Theme
        theme: lightTheme,

        // 🌙 Dark Theme
        darkTheme: darkTheme,

        // 🔥 Dynamic Theme
        themeMode: controller.isDark.value ? ThemeMode.dark : ThemeMode.light,

        home: SplashScreen(),
      ),
    );
  }
}

//
// ─────────────────────────────────────────────
// LIGHT THEME
// ─────────────────────────────────────────────
//

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  scaffoldBackgroundColor: Colors.white,

  colorScheme: const ColorScheme.light(
    primary: Color(0xFF8B7CF6),
    secondary: Color(0xFF8B7CF6),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 0,
  ),

  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),

  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.all(const Color(0xFF8B7CF6)),
  ),
);

//
// ─────────────────────────────────────────────
// DARK THEME
// ─────────────────────────────────────────────
//

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  scaffoldBackgroundColor: const Color(0xff121212),

  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF8B7CF6),
    secondary: Color(0xFF8B7CF6),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xff121212),
    foregroundColor: Colors.white,
    elevation: 0,
  ),

  cardTheme: CardThemeData(
    color: Color(0xff1E1E1E),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),

  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.all(const Color(0xFF8B7CF6)),
  ),
);
