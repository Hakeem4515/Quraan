import 'package:flutter/material.dart';

/// ثيمات الـ Widget المتاحة
enum WidgetTheme {
  classic,   // كريمي + ذهبي
  emerald,   // أخضر إسلامي + ذهبي
  dark,      // داكن جداً مع أزرق/أخضر
  minimal,   // بسيط أبيض
  midnight,  // أزرق داكن + بنفسجي
}

/// أشكال الـ Widget
enum WidgetShape {
  rounded,       // زوايا دائرية عادية
  square,        // زوايا مربعة
  card,          // بظل خفيف وحدود
  minimal,       // بدون حدود
  islamicFrame,  // إطار إسلامي بزخارف
}

/// محاذاة نص الآية
enum WidgetTextAlign {
  center,
  right,
}

/// إعدادات مظهر الـ Widget الكاملة
class WidgetAppearanceSettings {
  final WidgetTheme theme;
  final WidgetShape shape;
  final double ayahFontSize;
  final double surahFontSize;
  final WidgetTextAlign textAlign;
  final bool showAyahText;
  final bool showSurahName;
  final bool showAyahNumber;
  final bool showDecoration;
  final bool showAppName;

  const WidgetAppearanceSettings({
    this.theme = WidgetTheme.classic,
    this.shape = WidgetShape.rounded,
    this.ayahFontSize = 15.0,
    this.surahFontSize = 11.0,
    this.textAlign = WidgetTextAlign.center,
    this.showAyahText = true,
    this.showSurahName = true,
    this.showAyahNumber = true,
    this.showDecoration = true,
    this.showAppName = true,
  });

  WidgetAppearanceSettings copyWith({
    WidgetTheme? theme,
    WidgetShape? shape,
    double? ayahFontSize,
    double? surahFontSize,
    WidgetTextAlign? textAlign,
    bool? showAyahText,
    bool? showSurahName,
    bool? showAyahNumber,
    bool? showDecoration,
    bool? showAppName,
  }) {
    return WidgetAppearanceSettings(
      theme: theme ?? this.theme,
      shape: shape ?? this.shape,
      ayahFontSize: ayahFontSize ?? this.ayahFontSize,
      surahFontSize: surahFontSize ?? this.surahFontSize,
      textAlign: textAlign ?? this.textAlign,
      showAyahText: showAyahText ?? this.showAyahText,
      showSurahName: showSurahName ?? this.showSurahName,
      showAyahNumber: showAyahNumber ?? this.showAyahNumber,
      showDecoration: showDecoration ?? this.showDecoration,
      showAppName: showAppName ?? this.showAppName,
    );
  }
}

/// مواصفات كل ثيم
class WidgetThemeConfig {
  final String nameArabic;
  final String nameEnglish;
  final String emoji;
  final Color background;
  final Color ayahTextColor;
  final Color accentColor;
  final Color surahBadgeBg;
  final Color surahBadgeText;
  final Color appTitleColor;
  final Color overlayColor;

  const WidgetThemeConfig({
    required this.nameArabic,
    required this.nameEnglish,
    required this.emoji,
    required this.background,
    required this.ayahTextColor,
    required this.accentColor,
    required this.surahBadgeBg,
    required this.surahBadgeText,
    required this.appTitleColor,
    required this.overlayColor,
  });
}

/// مخزن إعدادات الثيمات
class WidgetThemeRegistry {
  static const Map<WidgetTheme, WidgetThemeConfig> configs = {
    WidgetTheme.classic: WidgetThemeConfig(
      nameArabic: 'كلاسيك',
      nameEnglish: 'Classic',
      emoji: '📜',
      background: Color(0xFF1A2823),
      ayahTextColor: Color(0xFFFDFBF7),
      accentColor: Color(0xFFC5A059),
      surahBadgeBg: Color(0x33C5A059),
      surahBadgeText: Color(0xFFE6D3A3),
      appTitleColor: Color(0xFFC5A059),
      overlayColor: Color(0x1AFFFFFF),
    ),
    WidgetTheme.emerald: WidgetThemeConfig(
      nameArabic: 'زمردي',
      nameEnglish: 'Emerald',
      emoji: '🌿',
      background: Color(0xFF072C21),
      ayahTextColor: Color(0xFFF4F9F6),
      accentColor: Color(0xFFD4AF37),
      surahBadgeBg: Color(0x33D4AF37),
      surahBadgeText: Color(0xFFF4D068),
      appTitleColor: Color(0xFFD4AF37),
      overlayColor: Color(0x1A4CAF50),
    ),
    WidgetTheme.dark: WidgetThemeConfig(
      nameArabic: 'داكن',
      nameEnglish: 'Dark',
      emoji: '🌙',
      background: Color(0xFF0D0D0D),
      ayahTextColor: Color(0xFFF1F5F9),
      accentColor: Color(0xFF2DD4BF),
      surahBadgeBg: Color(0x332DD4BF),
      surahBadgeText: Color(0xFF7EEAE2),
      appTitleColor: Color(0xFF2DD4BF),
      overlayColor: Color(0x1A2DD4BF),
    ),
    WidgetTheme.minimal: WidgetThemeConfig(
      nameArabic: 'بسيط',
      nameEnglish: 'Minimal',
      emoji: '⬜',
      background: Color(0xFFF8FAFC),
      ayahTextColor: Color(0xFF1E293B),
      accentColor: Color(0xFF0F5A47),
      surahBadgeBg: Color(0x220F5A47),
      surahBadgeText: Color(0xFF0F5A47),
      appTitleColor: Color(0xFF0F5A47),
      overlayColor: Color(0x0A0F5A47),
    ),
    WidgetTheme.midnight: WidgetThemeConfig(
      nameArabic: 'منتصف الليل',
      nameEnglish: 'Midnight',
      emoji: '✨',
      background: Color(0xFF0A0E1A),
      ayahTextColor: Color(0xFFE2E8F0),
      accentColor: Color(0xFFA78BFA),
      surahBadgeBg: Color(0x33A78BFA),
      surahBadgeText: Color(0xFFC4B5FD),
      appTitleColor: Color(0xFFA78BFA),
      overlayColor: Color(0x1AA78BFA),
    ),
  };

  static WidgetThemeConfig getConfig(WidgetTheme theme) {
    return configs[theme] ?? configs[WidgetTheme.classic]!;
  }
}
