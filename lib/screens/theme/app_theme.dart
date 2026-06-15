import 'package:flutter/material.dart';

class AppColors {
  final Color background;
  final Color text1, text2, text3;

  final Color surface, surface2;
  final Color cardBg, border;
  final Color accent, accentLight;
  final Color flashBg, flashBorder, flashText, bginfo;
  final Color textbg1, textbg2;
  final Color bgicon;

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
    required this.textbg1,
    required this.textbg2,
    required this.bgicon,
  });

  static const light = AppColors(
    /// Main Background
    background: Color(0xFFF8F9FB),

    /// Text
    textbg1: Color(0xFFF1F5F9),
    textbg2: Color(0xFF9CA3AF),
    text1: Color(0xFF111827),
    text2: Color(0xFF6B7280),
    text3: Color(0xFF9CA3AF),

    /// Surface
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF1F5F9),

    /// Cards / Border
    cardBg: Color(0xFFFFFFFF),
    border: Color(0xFFE5E7EB),

    /// Brand
    accent: Color(0xFF2563EB),
    accentLight: Color(0xFFDBEAFE),

    /// Flash Sale
    flashBg: Color(0xFFFEF2F2),
    flashBorder: Color(0xFFFECACA),
    flashText: Color(0xFFDC2626),

    /// Info
    bginfo: Color(0xFFF1F5F9),

    bgicon: const Color(0xFFF6F5F3),
  );


  /// ─────────────────────────────────────────────
  /// DARK THEME
  /// ─────────────────────────────────────────────
  static const dark = AppColors(
    /// Main Background
    background: Color(0xFF0B1120),

    /// Text
    textbg1: Color(0xFF111827),
    textbg2: Color(0xFF9CA3AF),
    text1: Color(0xFFF8FAFC),
    text2: Color(0xFFCBD5E1),
    text3: Color(0xFF64748B),

    /// Surface
    surface: Color(0xFF111827),
    surface2: Color(0xFF1E293B),

    /// Cards / Border
    cardBg: Color(0xFF172033),
    border: Color(0xFF243041),

    /// Brand
    accent: Color(0xFF3B82F6),
    accentLight: Color(0xFF1E3A8A),

    /// Flash Sale
    flashBg: Color(0xFF3F1D1D),
    flashBorder: Color(0xFF7F1D1D),
    flashText: Color(0xFFF87171),

    /// Info
    bginfo: Color(0xFF1E293B),


    bgicon: Color(0xFF2A2340),
  );
}

extension AppThemeExt on BuildContext {
  AppColors get colors {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark ? AppColors.dark : AppColors.light;
  }
}
