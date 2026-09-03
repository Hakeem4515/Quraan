import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation.dart';
import 'services/settings_service.dart';
import 'services/lockscreen_ayah_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LockscreenAyahService.initialize();
  runApp(const QuraanApp());
}

class QuraanApp extends StatefulWidget {
  const QuraanApp({super.key});

  @override
  State<QuraanApp> createState() => _QuraanAppState();
}

class _QuraanAppState extends State<QuraanApp> {
  QuranThemeMode _currentThemeMode = QuranThemeMode.emeraldGold;
  bool _isDualLanguage = true;
  bool _isHorizontalSwipe = false;
  bool _isLockscreenAyahEnabled = false;
  ArabicFontFamily _selectedFontFamily = ArabicFontFamily.amiri;
  ArabicFontWeightOption _selectedFontWeight = ArabicFontWeightOption.bold;
  double _fontSize = 26.0;
  double _lineHeight = 1.9;
  bool _isArabic = true; // App UI language: true=Arabic, false=English

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  Future<void> _loadSavedSettings() async {
    final mode = await SettingsService.getThemeMode();
    final dualLang = await SettingsService.getIsDualLanguage();
    final horizSwipe = await SettingsService.getIsHorizontalSwipe();
    final lockscreenEnabled = await SettingsService.getIsLockscreenAyahEnabled();
    final fontFamily = await SettingsService.getFontFamily();
    final fontWeight = await SettingsService.getFontWeight();
    final fontSize = await SettingsService.getFontSize();
    final lineHeight = await SettingsService.getLineHeight();
    final appLang = await SettingsService.getAppLanguage();

    if (mounted) {
      setState(() {
        _currentThemeMode = mode;
        _isDualLanguage = dualLang;
        _isHorizontalSwipe = horizSwipe;
        _isLockscreenAyahEnabled = lockscreenEnabled;
        _selectedFontFamily = fontFamily;
        _selectedFontWeight = fontWeight;
        _fontSize = fontSize;
        _lineHeight = lineHeight;
        _isArabic = appLang == 'ar';
      });
    }
  }

  void _changeThemeMode(QuranThemeMode mode) {
    setState(() { _currentThemeMode = mode; });
    SettingsService.setThemeMode(mode);
  }

  void _toggleDualLanguage(bool value) {
    setState(() { _isDualLanguage = value; });
    SettingsService.setIsDualLanguage(value);
  }

  void _toggleHorizontalSwipe(bool value) {
    setState(() { _isHorizontalSwipe = value; });
    SettingsService.setIsHorizontalSwipe(value);
  }

  void _toggleLockscreenAyah(bool value) {
    setState(() { _isLockscreenAyahEnabled = value; });
    if (value) {
      LockscreenAyahService.enable();
    } else {
      LockscreenAyahService.disable();
    }
  }

  void _changeFontFamily(ArabicFontFamily family) {
    setState(() { _selectedFontFamily = family; });
    SettingsService.setFontFamily(family);
    LockscreenAyahService.syncFontFamilyToNative(family);
  }

  void _changeFontWeight(ArabicFontWeightOption weight) {
    setState(() { _selectedFontWeight = weight; });
    SettingsService.setFontWeight(weight);
  }

  void _changeFontSize(double size) {
    setState(() { _fontSize = size; });
    SettingsService.setFontSize(size);
  }

  void _changeLineHeight(double height) {
    setState(() { _lineHeight = height; });
    SettingsService.setLineHeight(height);
  }

  void _changeAppLanguage(bool isArabic) {
    setState(() { _isArabic = isArabic; });
    SettingsService.setAppLanguage(isArabic ? 'ar' : 'en');
  }

  @override
  Widget build(BuildContext context) {
    final themeData = AppTheme.getThemeData(_currentThemeMode);

    return MaterialApp(
      title: 'Al-Quran Al-Kareem',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      locale: Locale(_isArabic ? 'ar' : 'en'),
      builder: (context, child) {
        return Directionality(
          textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      home: MainNavigationHub(
        themeMode: _currentThemeMode,
        onThemeModeChanged: _changeThemeMode,
        isDualLanguage: _isDualLanguage,
        onDualLanguageChanged: _toggleDualLanguage,
        isHorizontalSwipe: _isHorizontalSwipe,
        onHorizontalSwipeChanged: _toggleHorizontalSwipe,
        isLockscreenAyahEnabled: _isLockscreenAyahEnabled,
        onLockscreenAyahChanged: _toggleLockscreenAyah,
        fontFamily: _selectedFontFamily,
        onFontFamilyChanged: _changeFontFamily,
        fontWeight: _selectedFontWeight,
        onFontWeightChanged: _changeFontWeight,
        fontSize: _fontSize,
        onFontSizeChanged: _changeFontSize,
        lineHeight: _lineHeight,
        onLineHeightChanged: _changeLineHeight,
        isArabic: _isArabic,
        onLanguageChanged: _changeAppLanguage,
      ),
    );
  }
}
