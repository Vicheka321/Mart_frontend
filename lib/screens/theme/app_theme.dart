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
    // background: Color(0xFFD9D9D9),
    // text1: Color(0xFF111111),
    // text2: Color(0xFF555555),
    // text3: Color(0xFF999999),
    // surface: Color(0xFFF2F2F2),
    // surface2: Color(0xFFEAEAEA),
    // cardBg: Color(0xFFFFFFFF),
    // border: Colors.green,
    // accent: Colors.blue,
    // accentLight: Color(0xFFEDE9FB),
    // flashBg: Color(0xFFFFF5F5),
    // flashBorder: Color(0xFFFFD0D0),
    // flashText: Color(0xFFE24B4A),
    // bginfo: Color(0xFFF6F6F6),
    background: Color(0xFFF8F9FB), // soft white (not harsh)
    text1: Color(0xFF1A1A1A),
    text2: Color(0xFF6B7280),
    text3: Color(0xFF9CA3AF),

    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF1F5F9),

    cardBg: Color(0xFFFFFFFF),
    border: Color(0xFFE5E7EB),

    accent: Color(0xFF2563EB), // professional blue
    accentLight: Color(0xFFDBEAFE),

    flashBg: Color(0xFFFEF2F2),
    flashBorder: Color(0xFFFECACA),
    flashText: Color(0xFFDC2626),

    bginfo: Color(0xFFF1F5F9),
  );

  static const dark = AppColors(
    background: Color(0xFF0E0E0E),
    text1: Color(0xFFF0F0F0),
    text2: Color(0xFFB8B8B8),
    text3: Color(0xFF8A8A8A),

    surface: Color(0xFF121212),
    surface2: Color(0xFF252525),

    cardBg: Color(0xFF1A1A1A),
    border: Color(0xFF2A2A2A),

    accent: Color(0xFF8B7CF6),
    accentLight: Color(0xFF2A2340),

    flashBg: Color(0xFF2A1A1A),
    flashBorder: Color(0xFF7F1D1D),
    flashText: Color(0xFFF87171),

    bginfo: Color(0xFF252525),
  );
}

extension AppThemeExt on BuildContext {
  AppColors get colors {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark ? AppColors.dark : AppColors.light;
  }
}
