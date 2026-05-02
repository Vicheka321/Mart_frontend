import 'package:flutter/material.dart';

class AppColors {
  final Color background;
  final Color text1, text2, text3;

  final Color surface, surface2;
  final Color cardBg, border;
  final Color accent, accentLight;
  final Color flashBg, flashBorder, flashText, bginfo;

  const AppColors({
    required this.background,
    required this.text1,
    required this.text2,
    required this.text3,
    required this.surface,
    required this.surface2,
    required this.cardBg,
    required this.border,
    required this.accent,
    required this.accentLight,
    required this.flashBg,
    required this.flashBorder,
    required this.flashText,
    required this.bginfo,
  });

  static const light = AppColors(
    background: Color(0xFFD9D9D9),
    text1: Color(0xFF111111),
    text2: Color(0xFF555555),
    text3: Color(0xFF999999),
    surface: Color(0xFFF2F2F2),
    surface2: Color(0xFFEAEAEA),
    cardBg: Color(0xFFFFFFFF),
    border: Colors.green,
    accent: Colors.blue,
    accentLight: Color(0xFFEDE9FB),
    flashBg: Color(0xFFFFF5F5),
    flashBorder: Color(0xFFFFD0D0),
    flashText: Color(0xFFE24B4A),
    bginfo: Color(0xFFF6F6F6),
  );

  static const dark = AppColors(
    background: Color.fromARGB(255, 255, 255, 255),
    text1: Color(0xFFF5F5F5),
    text2: Color(0xFFAAAAAA),
    text3: Color(0xFF666666),
    surface: Color(0xFF1E1E1E),
    surface2: Color(0xFF2A2A2A),
    cardBg: Color(0xFF1A1A1A),
    border: Color(0xFF2E2E2E),
    accent: Color(0xFF3949AB),
    accentLight: Color(0xFFEDE9FB),
    flashBg: Color(0xFF2A1A1A),
    flashBorder: Color(0xFF4A2020),
    flashText: Color(0xFFE24B4A),
    bginfo: Color(0xFFF6F6F6),
  );
}

extension AppThemeExt on BuildContext {
  AppColors get colors {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark ? AppColors.dark : AppColors.light;
  }
}
