import 'package:flutter/material.dart';

enum QuranThemeMode {
  emeraldGold,   // الثيم الأخضر الذهبي
  darkNight,     // الثيم الداكن
  creamyMushaf,  // ثيم المصحف (كريمي)
  modernMinimal, // الثيم الحديث البسيط
}

enum ArabicFontFamily {
  amiri,        // خط الأميري العثماني
  naskh,        // خط النسخ (شهرزاد)
  hafs,         // الخط العثماني (حفص)
  system,       // الخط القياسي
}

enum ArabicFontWeightOption {
  normal,       // عادي
  bold,         // عريض
  heavy,        // عريض جداً
}

class ThemeConfig {
  final String nameArabic;
  final String descriptionArabic;
  final Color appBg;
  final Color paperBg;
  final Color borderAccent;
  final Color bannerBg;
  final Color bannerText;
  final Color textPrimary;
  final Color textSecondary;
  final Color playButtonBg;
  final Color playButtonIcon;
  final Color navBg;
  final Color navActive;
  final Color navInactive;
  final bool isDark;

  const ThemeConfig({
    required this.nameArabic,
    required this.descriptionArabic,
    required this.appBg,
    required this.paperBg,
    required this.borderAccent,
    required this.bannerBg,
    required this.bannerText,
    required this.textPrimary,
    required this.textSecondary,
    required this.playButtonBg,
    required this.playButtonIcon,
    required this.navBg,
    required this.navActive,
    required this.navInactive,
    required this.isDark,
  });
}

class AppTheme {
  static const Map<QuranThemeMode, ThemeConfig> themeConfigs = {
    // 1. الثيم الأخضر الذهبي
    QuranThemeMode.emeraldGold: ThemeConfig(
      nameArabic: "الثيم الأخضر الذهبي",
      descriptionArabic: "فخامة وروحانية ولمسات ذهبية",
      appBg: Color(0xFF072C21),
      paperBg: Color(0xFFFAF4E8),
      borderAccent: Color(0xFFD4AF37),
      bannerBg: Color(0xFF0B3A2C),
      bannerText: Color(0xFFF4D068),
      textPrimary: Color(0xFF1C2823),
      textSecondary: Color(0xFF8A9A92),
      playButtonBg: Color(0xFFD4AF37),
      playButtonIcon: Color(0xFF072C21),
      navBg: Color(0xFF052119),
      navActive: Color(0xFFD4AF37),
      navInactive: Color(0xFF527568),
      isDark: true,
    ),

    // 2. الثيم الداكن
    QuranThemeMode.darkNight: ThemeConfig(
      nameArabic: "الثيم الداكن",
      descriptionArabic: "راحة للعين في الإضاءة المنخفضة",
      appBg: Color(0xFF090D10),
      paperBg: Color(0xFF11171D),
      borderAccent: Color(0xFF1B8A6B),
      bannerBg: Color(0xFF16222A),
      bannerText: Color(0xFF2DD4BF),
      textPrimary: Color(0xFFF1F5F9),
      textSecondary: Color(0xFF94A3B8),
      playButtonBg: Color(0xFF10B981),
      playButtonIcon: Color(0xFFFFFFFF),
      navBg: Color(0xFF090D10),
      navActive: Color(0xFF2DD4BF),
      navInactive: Color(0xFF475569),
      isDark: true,
    ),

    // 3. ثيم المصحف (كريمي)
    QuranThemeMode.creamyMushaf: ThemeConfig(
      nameArabic: "ثيم المصحف (كريمي)",
      descriptionArabic: "تصميم كلاسيكي يشبه المصحف الشريف",
      appBg: Color(0xFFF4EEDD),
      paperBg: Color(0xFFFAF6EB),
      borderAccent: Color(0xFFC59B4E),
      bannerBg: Color(0xFFEBE0C9),
      bannerText: Color(0xFF7A581A),
      textPrimary: Color(0xFF2A2016),
      textSecondary: Color(0xFF8C7B6B),
      playButtonBg: Color(0xFFC59B4E),
      playButtonIcon: Color(0xFF2A2016),
      navBg: Color(0xFFECE4D2),
      navActive: Color(0xFF8C6A27),
      navInactive: Color(0xFF9E9283),
      isDark: false,
    ),

    // 4. الثيم الحديث البسيط
    QuranThemeMode.modernMinimal: ThemeConfig(
      nameArabic: "الثيم الحديث البسيط",
      descriptionArabic: "تصميم بسيط وحديث ومَرِن",
      appBg: Color(0xFFF8FAFC),
      paperBg: Color(0xFFFFFFFF),
      borderAccent: Color(0xFF0F5A47),
      bannerBg: Color(0xFF0F5A47),
      bannerText: Color(0xFFFFFFFF),
      textPrimary: Color(0xFF0F172A),
      textSecondary: Color(0xFF64748B),
      playButtonBg: Color(0xFF0F5A47),
      playButtonIcon: Color(0xFFFFFFFF),
      navBg: Color(0xFFFFFFFF),
      navActive: Color(0xFF0F5A47),
      navInactive: Color(0xFF94A3B8),
      isDark: false,
    ),
  };

  static ThemeConfig getConfig(QuranThemeMode mode) {
    return themeConfigs[mode] ?? themeConfigs[QuranThemeMode.emeraldGold]!;
  }

  // Dynamic Arabic Text Style with Font Family and Weight Options
  static TextStyle getArabicTextStyle({
    ArabicFontFamily fontFamily = ArabicFontFamily.amiri,
    ArabicFontWeightOption fontWeight = ArabicFontWeightOption.bold,
    double fontSize = 26.0,
    double lineHeight = 1.9,
    Color? color,
    Color? backgroundColor,
  }) {
    String fontName = 'Amiri';
    if (fontFamily == ArabicFontFamily.naskh) {
      fontName = 'Scheherazade';
    } else if (fontFamily == ArabicFontFamily.hafs) {
      fontName = 'Uthmani';
    } else if (fontFamily == ArabicFontFamily.system) {
      fontName = '';
    }

    FontWeight weight = FontWeight.bold;
    if (fontWeight == ArabicFontWeightOption.normal) {
      weight = FontWeight.w400;
    } else if (fontWeight == ArabicFontWeightOption.heavy) {
      weight = FontWeight.w900;
    }

    return TextStyle(
      fontFamily: fontName.isNotEmpty ? fontName : null,
      fontWeight: weight,
      fontSize: fontSize,
      height: lineHeight,
      color: color,
      backgroundColor: backgroundColor,
    );
  }

  static TextStyle get arabicFont => getArabicTextStyle();

  static ThemeData getThemeData(QuranThemeMode mode) {
    final config = getConfig(mode);
    final brightness = config.isDark ? Brightness.dark : Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: config.appBg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: config.borderAccent,
        onPrimary: config.isDark ? Colors.black : Colors.white,
        secondary: config.playButtonBg,
        onSecondary: config.playButtonIcon,
        error: Colors.redAccent,
        onError: Colors.white,
        surface: config.paperBg,
        onSurface: config.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: config.appBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: config.textPrimary),
        titleTextStyle: TextStyle(
          color: config.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: config.paperBg,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: config.borderAccent.withValues(alpha: 0.3), width: 1),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: config.navBg,
        selectedItemColor: config.navActive,
        unselectedItemColor: config.navInactive,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: config.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
        bodyLarge: TextStyle(
          color: config.textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: config.textSecondary,
          fontSize: 14,
        ),
      ),
    );
  }
}
