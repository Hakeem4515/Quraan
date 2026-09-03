import 'package:flutter/services.dart';
import 'settings_service.dart';
import '../models/widget_appearance.dart';
import '../theme/app_theme.dart';

class LockscreenAyahService {
  static const MethodChannel _channel = MethodChannel(
    'com.example.quraan/lockscreen_widget',
  );

  /// Initialize and synchronize widget state from saved settings
  static Future<void> initialize() async {
    final isEnabled = await SettingsService.getIsLockscreenAyahEnabled();
    final updateMode = await SettingsService.getLockscreenUpdateMode();
    final intervalMinutes =
        await SettingsService.getLockscreenIntervalMinutes();
    final customMinutes = await SettingsService.getLockscreenCustomMinutes();
    final appearance = await SettingsService.getWidgetAppearance();
    final fontFamily = await SettingsService.getFontFamily();

    await syncSettingsToNative(
      isEnabled: isEnabled,
      updateMode: updateMode,
      intervalMinutes: intervalMinutes,
      customMinutes: customMinutes,
    );

    await syncAppearanceToNative(appearance);
    await syncFontFamilyToNative(fontFamily);
  }

  /// Synchronize selected Arabic font family to Android Native Widget
  static Future<void> syncFontFamilyToNative(ArabicFontFamily family) async {
    try {
      await _channel.invokeMethod('updateWidgetFontFamily', {
        'fontFamily': family.index, // 0=amiri, 1=naskh, 2=hafs, 3=system
      });
    } catch (_) {}
  }

  /// Synchronize settings to Android Native AppWidget & AlarmManager
  static Future<void> syncSettingsToNative({
    required bool isEnabled,
    required String updateMode,
    required int intervalMinutes,
    required int customMinutes,
  }) async {
    try {
      await _channel.invokeMethod('updateWidgetSettings', {
        'isEnabled': isEnabled,
        'updateMode': updateMode,
        'intervalMinutes': intervalMinutes,
        'customMinutes': customMinutes,
      });
    } catch (_) {}
  }

  /// Synchronize appearance settings (theme, fonts, visibility, alignment) to Android Native Widget
  static Future<void> syncAppearanceToNative(
    WidgetAppearanceSettings settings,
  ) async {
    try {
      await _channel.invokeMethod('updateWidgetAppearance', {
        'theme': settings.theme.index,
        'shape': settings.shape.index,
        'ayahFontSize': settings.ayahFontSize,
        'surahFontSize': settings.surahFontSize,
        'textAlign': settings.textAlign.index,
        'showAyahText': settings.showAyahText,
        'showSurahName': settings.showSurahName,
        'showAyahNumber': settings.showAyahNumber,
        'showDecoration': settings.showDecoration,
        'showAppName': settings.showAppName,
      });
    } catch (_) {}
  }

  /// Request immediate random Ayah refresh on the widget
  static Future<Map<String, dynamic>?> refreshAyahNow() async {
    try {
      final result = await _channel.invokeMethod('refreshAyahNow');
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      }
    } catch (_) {}
    return null;
  }

  /// Check if user has added the widget to their lock screen or home screen
  static Future<bool> hasActiveWidgets() async {
    try {
      final result = await _channel.invokeMethod('hasActiveWidgets');
      return result == true;
    } catch (_) {
      return false;
    }
  }

  /// Get the last shown Ayah on the widget
  static Future<Map<String, dynamic>?> getLastShownAyah() async {
    try {
      final result = await _channel.invokeMethod('getLastShownAyah');
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      }
    } catch (_) {}
    return null;
  }

  /// Enable widget feature
  static Future<void> enable() async {
    await SettingsService.setIsLockscreenAyahEnabled(true);
    await initialize();
  }

  /// Disable widget feature
  static Future<void> disable() async {
    await SettingsService.setIsLockscreenAyahEnabled(false);
    await initialize();
  }
}
