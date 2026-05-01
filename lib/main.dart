import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDark = false;

  void toggleTheme(bool value) {
    setState(() {
      isDark = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,

      child: MaterialApp(
        key: ValueKey(isDark), // important for animation
        debugShowCheckedModeBanner: false,

        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: isDark
            ? ThemeMode.dark
            : ThemeMode.light,

        home: SplashScreen(),
      ),
    );
  }
}



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
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
),

  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.all(
      const Color(0xFF8B7CF6),
    ),
  ),
);



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
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
),

  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.all(
      const Color(0xFF8B7CF6),
    ),
  ),
);