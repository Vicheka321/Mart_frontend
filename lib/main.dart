import 'package:flutter/material.dart';
import 'package:mart_frontend/providers/ProductDetailProvider.dart';
import 'package:mart_frontend/providers/banner_provider.dart';
import 'package:mart_frontend/providers/best_seller_provider.dart';
import 'package:mart_frontend/providers/brands_products_provider.dart';
import 'package:mart_frontend/providers/brands_provider.dart';
import 'package:mart_frontend/providers/category__products_provider.dart';
import 'package:mart_frontend/providers/category_provider.dart';
import 'package:mart_frontend/providers/new_arrival_provider.dart';
import 'package:mart_frontend/providers/profile_provider.dart';
import 'package:mart_frontend/providers/recommend_provider.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'providers/cart_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/theme/theme_controller.dart';
import 'controllers/language_controller.dart';
import 'translations/app_translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ThemeController());
  Get.put(LanguageController());
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => BannerProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => BestSellerProvider()),
        ChangeNotifierProvider(create: (_) => NewArrivalsProvider()),
        ChangeNotifierProvider(create: (_) => BrandsProvider()),
        ChangeNotifierProvider(create: (_) => RecommendProvider()),
        ChangeNotifierProvider(create: (_) => ProductDetailProvider()),
        ChangeNotifierProvider(create: (_) => CategoriesWithProductsProvider()),
        ChangeNotifierProvider(create: (_) => BrandsWithProductsProvider())

      ],
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

// class MyApp extends StatelessWidget {
//   MyApp({super.key});

//   final ThemeController controller = Get.put(ThemeController());
//   final languageController = Get.put(LanguageController());

//   @override
//   Widget build(BuildContext context) {
//     return Obx(
//       () => GetMaterialApp(
//         translations: AppTranslations(),
//         locale: Locale(languageController.language.value),
//         fallbackLocale: const Locale('en'),
//         debugShowCheckedModeBanner: false,

//         // 🌞 Light Theme
//         theme: lightTheme,

//         // 🌙 Dark Theme
//         darkTheme: darkTheme,

//         // 🔥 Dynamic Theme
//         themeMode: controller.isDark.value ? ThemeMode.dark : ThemeMode.light,

//         home: SplashScreen(),
//       ),
//     );
//   }
// }

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ThemeController controller = Get.find<ThemeController>();
  final LanguageController languageController = Get.find<LanguageController>();

  String getFontFamily(String lang) {
    switch (lang) {
      case 'km':
        return 'NotoSansKhmer';

      case 'zh':
        return 'NotoSansSC';

      default:
        return 'NotoSans';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final lang = languageController.language.value;
      final fontFamily = getFontFamily(lang);

      return GetMaterialApp(
        translations: AppTranslations(),
        locale: Locale(lang),
        fallbackLocale: const Locale('en'),
        debugShowCheckedModeBanner: false,

        theme: lightTheme.copyWith(
          textTheme: lightTheme.textTheme.apply(fontFamily: fontFamily),
        ),

        darkTheme: darkTheme.copyWith(
          textTheme: darkTheme.textTheme.apply(fontFamily: fontFamily),
        ),

        themeMode: controller.isDark.value ? ThemeMode.dark : ThemeMode.light,

        home: SplashScreen(),
      );
    });
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

  scaffoldBackgroundColor: const Color(0xFFF8F9FB),

  colorScheme: const ColorScheme.light(
    primary: Color(0xFF2563EB),
    secondary: Color(0xFF2563EB),
    surface: Color(0xFFFFFFFF),
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
    thumbColor: WidgetStateProperty.all(const Color(0xFF2563EB)),
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
  scaffoldBackgroundColor: const Color(0xFF0E0E0E),

  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF8B7CF6),
    secondary: Color(0xFF8B7CF6),
    surface: Color(0xFF1A1A1A),
    onSurface: Color(0xFFF0F0F0),
  ),
  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: const Color(0xFFF0F0F0),
    displayColor: const Color(0xFFF0F0F0),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0E0E0E),
    foregroundColor: Colors.white,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
  ),

  cardTheme: CardThemeData(
    color: Color(0xFF1A1A1A),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),

  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.all(const Color(0xFF8B7CF6)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1A1A1A),
    hintStyle: const TextStyle(color: Color(0xFF888888)),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
  ),
);
