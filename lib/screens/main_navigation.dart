import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../l10n/app_strings.dart';
import 'surah_list_screen.dart';
import 'juz_screen.dart';
import 'bookmarks_screen.dart';
import 'settings_screen.dart';

class MainNavigationHub extends StatefulWidget {
  final QuranThemeMode themeMode;
  final ValueChanged<QuranThemeMode> onThemeModeChanged;
  final bool isDualLanguage;
  final ValueChanged<bool> onDualLanguageChanged;
  final bool isHorizontalSwipe;
  final ValueChanged<bool> onHorizontalSwipeChanged;
  final bool isLockscreenAyahEnabled;
  final ValueChanged<bool> onLockscreenAyahChanged;
  final ArabicFontFamily fontFamily;
  final ValueChanged<ArabicFontFamily> onFontFamilyChanged;
  final ArabicFontWeightOption fontWeight;
  final ValueChanged<ArabicFontWeightOption> onFontWeightChanged;
  final double fontSize;
  final ValueChanged<double> onFontSizeChanged;
  final double lineHeight;
  final ValueChanged<double> onLineHeightChanged;
  final bool isArabic;
  final ValueChanged<bool> onLanguageChanged;

  const MainNavigationHub({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.isDualLanguage,
    required this.onDualLanguageChanged,
    required this.isHorizontalSwipe,
    required this.onHorizontalSwipeChanged,
    required this.isLockscreenAyahEnabled,
    required this.onLockscreenAyahChanged,
    required this.fontFamily,
    required this.onFontFamilyChanged,
    required this.fontWeight,
    required this.onFontWeightChanged,
    required this.fontSize,
    required this.onFontSizeChanged,
    required this.lineHeight,
    required this.onLineHeightChanged,
    required this.isArabic,
    required this.onLanguageChanged,
  });

  @override
  State<MainNavigationHub> createState() => _MainNavigationHubState();
}

class _MainNavigationHubState extends State<MainNavigationHub> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cfg = AppTheme.getConfig(widget.themeMode);
    final s = AppStrings.of(widget.isArabic);

    final List<Widget> pages = [
      SurahListScreen(
        themeMode: widget.themeMode,
        isDualLanguage: widget.isDualLanguage,
        isHorizontalSwipe: widget.isHorizontalSwipe,
        fontFamily: widget.fontFamily,
        fontWeight: widget.fontWeight,
        fontSize: widget.fontSize,
        lineHeight: widget.lineHeight,
        isArabic: widget.isArabic,
      ),
      JuzScreen(
        themeMode: widget.themeMode,
        isDualLanguage: widget.isDualLanguage,
        isHorizontalSwipe: widget.isHorizontalSwipe,
        fontFamily: widget.fontFamily,
        fontWeight: widget.fontWeight,
        fontSize: widget.fontSize,
        lineHeight: widget.lineHeight,
        isArabic: widget.isArabic,
      ),
      BookmarksScreen(
        themeMode: widget.themeMode,
        isDualLanguage: widget.isDualLanguage,
        isHorizontalSwipe: widget.isHorizontalSwipe,
        fontFamily: widget.fontFamily,
        fontWeight: widget.fontWeight,
        fontSize: widget.fontSize,
        lineHeight: widget.lineHeight,
        isArabic: widget.isArabic,
      ),
      SettingsScreen(
        themeMode: widget.themeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
        isDualLanguage: widget.isDualLanguage,
        onDualLanguageChanged: widget.onDualLanguageChanged,
        isHorizontalSwipe: widget.isHorizontalSwipe,
        onHorizontalSwipeChanged: widget.onHorizontalSwipeChanged,
        isLockscreenAyahEnabled: widget.isLockscreenAyahEnabled,
        onLockscreenAyahChanged: widget.onLockscreenAyahChanged,
        fontFamily: widget.fontFamily,
        onFontFamilyChanged: widget.onFontFamilyChanged,
        fontWeight: widget.fontWeight,
        onFontWeightChanged: widget.onFontWeightChanged,
        fontSize: widget.fontSize,
        onFontSizeChanged: widget.onFontSizeChanged,
        lineHeight: widget.lineHeight,
        onLineHeightChanged: widget.onLineHeightChanged,
        isArabic: widget.isArabic,
        onLanguageChanged: widget.onLanguageChanged,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cfg.navBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: cfg.borderAccent.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _currentIndex,
          selectedItemColor: cfg.navActive,
          unselectedItemColor: cfg.navInactive,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          onTap: (index) {
            setState(() { _currentIndex = index; });
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.menu_book_rounded),
              label: s.navQuran,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.grid_view_rounded),
              label: s.navJuz,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bookmark_outline_rounded),
              activeIcon: const Icon(Icons.bookmark_rounded),
              label: s.navBookmark,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings_rounded),
              label: s.navSettings,
            ),
          ],
        ),
      ),
    );
  }
}
