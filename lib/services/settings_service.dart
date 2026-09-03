import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../models/widget_appearance.dart';

class SettingsService {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyIsDualLanguage = 'is_dual_language';
  static const String _keyIsHorizontalSwipe = 'is_horizontal_swipe';
  static const String _keyFontFamily = 'font_family';
  static const String _keyFontWeight = 'font_weight';
  static const String _keyFontSize = 'font_size';
  static const String _keyLineHeight = 'line_height';

  static const String _keyIsLockscreenAyahEnabled = 'is_lockscreen_ayah_enabled';
  static const String _keyLockscreenUpdateMode = 'lockscreen_update_mode'; // 'byTime', 'custom', 'screenOff'
  static const String _keyLockscreenIntervalMinutes = 'lockscreen_interval_minutes'; // 60, 180, 360, 720, 1440
  static const String _keyLockscreenCustomMinutes = 'lockscreen_custom_minutes'; // e.g. 30
  static const String _keyAppLanguage = 'app_language'; // 'ar' | 'en'

  // Widget Appearance Keys
  static const String _keyWidgetTheme = 'widget_theme';
  static const String _keyWidgetShape = 'widget_shape';
  static const String _keyWidgetAyahFontSize = 'widget_ayah_font_size';
  static const String _keyWidgetSurahFontSize = 'widget_surah_font_size';
  static const String _keyWidgetTextAlign = 'widget_text_align';
  static const String _keyWidgetShowAyahText = 'widget_show_ayah_text';
  static const String _keyWidgetShowSurahName = 'widget_show_surah_name';
  static const String _keyWidgetShowAyahNumber = 'widget_show_ayah_number';
  static const String _keyWidgetShowDecoration = 'widget_show_decoration';
  static const String _keyWidgetShowAppName = 'widget_show_app_name';


  // Load Settings
  static Future<QuranThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_keyThemeMode);
    if (index != null && index >= 0 && index < QuranThemeMode.values.length) {
      return QuranThemeMode.values[index];
    }
    return QuranThemeMode.emeraldGold;
  }

  static Future<void> setThemeMode(QuranThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, mode.index);
  }

  static Future<bool> getIsDualLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsDualLanguage) ?? true;
  }

  static Future<void> setIsDualLanguage(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsDualLanguage, value);
  }

  /// Returns 'ar' or 'en'. Defaults to 'ar'.
  static Future<String> getAppLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAppLanguage) ?? 'ar';
  }

  static Future<void> setAppLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAppLanguage, lang);
  }

  static Future<bool> getIsHorizontalSwipe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsHorizontalSwipe) ?? false;
  }

  static Future<void> setIsHorizontalSwipe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsHorizontalSwipe, value);
  }

  static Future<ArabicFontFamily> getFontFamily() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_keyFontFamily);
    if (index != null && index >= 0 && index < ArabicFontFamily.values.length) {
      return ArabicFontFamily.values[index];
    }
    return ArabicFontFamily.amiri;
  }

  static Future<void> setFontFamily(ArabicFontFamily family) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyFontFamily, family.index);
  }

  static Future<ArabicFontWeightOption> getFontWeight() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_keyFontWeight);
    if (index != null && index >= 0 && index < ArabicFontWeightOption.values.length) {
      return ArabicFontWeightOption.values[index];
    }
    return ArabicFontWeightOption.bold;
  }

  static Future<void> setFontWeight(ArabicFontWeightOption weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyFontWeight, weight.index);
  }

  static Future<double> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyFontSize) ?? 26.0;
  }

  static Future<void> setFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFontSize, size);
  }

  static Future<double> getLineHeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyLineHeight) ?? 1.9;
  }

  static Future<void> setLineHeight(double height) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyLineHeight, height);
  }



  static Future<bool> getIsLockscreenAyahEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLockscreenAyahEnabled) ?? false;
  }

  static Future<void> setIsLockscreenAyahEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLockscreenAyahEnabled, value);
  }

  static Future<String> getLockscreenUpdateMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLockscreenUpdateMode) ?? 'byTime';
  }

  static Future<void> setLockscreenUpdateMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLockscreenUpdateMode, mode);
  }

  static Future<int> getLockscreenIntervalMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLockscreenIntervalMinutes) ?? 60;
  }

  static Future<void> setLockscreenIntervalMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLockscreenIntervalMinutes, minutes);
  }

  static Future<int> getLockscreenCustomMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLockscreenCustomMinutes) ?? 30;
  }

  static Future<void> setLockscreenCustomMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLockscreenCustomMinutes, minutes);
  }

  // ─── Widget Appearance ─────────────────────────────────────────────────────

  static Future<WidgetAppearanceSettings> getWidgetAppearance() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_keyWidgetTheme) ?? 0;
    final shapeIndex = prefs.getInt(_keyWidgetShape) ?? 0;
    final alignIndex = prefs.getInt(_keyWidgetTextAlign) ?? 0;

    return WidgetAppearanceSettings(
      theme: WidgetTheme.values[themeIndex.clamp(0, WidgetTheme.values.length - 1)],
      shape: WidgetShape.values[shapeIndex.clamp(0, WidgetShape.values.length - 1)],
      ayahFontSize: prefs.getDouble(_keyWidgetAyahFontSize) ?? 15.0,
      surahFontSize: prefs.getDouble(_keyWidgetSurahFontSize) ?? 11.0,
      textAlign: WidgetTextAlign.values[alignIndex.clamp(0, WidgetTextAlign.values.length - 1)],
      showAyahText: prefs.getBool(_keyWidgetShowAyahText) ?? true,
      showSurahName: prefs.getBool(_keyWidgetShowSurahName) ?? true,
      showAyahNumber: prefs.getBool(_keyWidgetShowAyahNumber) ?? true,
      showDecoration: prefs.getBool(_keyWidgetShowDecoration) ?? true,
      showAppName: prefs.getBool(_keyWidgetShowAppName) ?? true,
    );
  }

  static Future<void> setWidgetAppearance(WidgetAppearanceSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyWidgetTheme, settings.theme.index);
    await prefs.setInt(_keyWidgetShape, settings.shape.index);
    await prefs.setDouble(_keyWidgetAyahFontSize, settings.ayahFontSize);
    await prefs.setDouble(_keyWidgetSurahFontSize, settings.surahFontSize);
    await prefs.setInt(_keyWidgetTextAlign, settings.textAlign.index);
    await prefs.setBool(_keyWidgetShowAyahText, settings.showAyahText);
    await prefs.setBool(_keyWidgetShowSurahName, settings.showSurahName);
    await prefs.setBool(_keyWidgetShowAyahNumber, settings.showAyahNumber);
    await prefs.setBool(_keyWidgetShowDecoration, settings.showDecoration);
    await prefs.setBool(_keyWidgetShowAppName, settings.showAppName);
  }
}
