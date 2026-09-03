import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/settings_service.dart';
import '../services/lockscreen_ayah_service.dart';
import '../l10n/app_strings.dart';
import 'widget_appearance_screen.dart';

class SettingsScreen extends StatefulWidget {
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

  const SettingsScreen({
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
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _lockscreenUpdateMode = 'byTime';
  int _lockscreenIntervalMinutes = 60;
  int _lockscreenCustomMinutes = 30;
  bool _showLockscreenDetails = false;
  bool _isRefreshing = false;
  Map<String, dynamic>? _previewAyah;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final mode = await SettingsService.getLockscreenUpdateMode();
    final interval = await SettingsService.getLockscreenIntervalMinutes();
    final custom = await SettingsService.getLockscreenCustomMinutes();
    final lastAyah = await LockscreenAyahService.getLastShownAyah();
    if (mounted) {
      setState(() {
        _lockscreenUpdateMode = mode;
        _lockscreenIntervalMinutes = interval;
        _lockscreenCustomMinutes = custom;
        _previewAyah = lastAyah;
      });
    }
  }

  Future<void> _updateLockscreenSettings({String? mode, int? interval, int? custom}) async {
    final newMode = mode ?? _lockscreenUpdateMode;
    final newInterval = interval ?? _lockscreenIntervalMinutes;
    final newCustom = custom ?? _lockscreenCustomMinutes;
    setState(() {
      _lockscreenUpdateMode = newMode;
      _lockscreenIntervalMinutes = newInterval;
      _lockscreenCustomMinutes = newCustom;
    });
    await SettingsService.setLockscreenUpdateMode(newMode);
    await SettingsService.setLockscreenIntervalMinutes(newInterval);
    await SettingsService.setLockscreenCustomMinutes(newCustom);
    await LockscreenAyahService.syncSettingsToNative(
      isEnabled: widget.isLockscreenAyahEnabled,
      updateMode: newMode,
      intervalMinutes: newInterval,
      customMinutes: newCustom,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cfg = AppTheme.getConfig(widget.themeMode);
    final s = AppStrings.of(widget.isArabic);

    return Scaffold(
      backgroundColor: cfg.appBg,
      appBar: AppBar(
        backgroundColor: cfg.appBg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          s.settingsTitle,
          style: TextStyle(color: cfg.textPrimary, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ── APPEARANCE ────────────────────────────────────────────────────
          _sectionHeader(s.sectionAppearance, cfg),
          _sectionCard(cfg, [
            _buildThemePickerTile(cfg, s),
            _divider(cfg),
            _buildNavTile(
              icon: Icons.text_fields_rounded,
              title: s.settingFont,
              subtitle: _fontFamilyLabel(widget.fontFamily, s),
              cfg: cfg,
              onTap: () => _showFontBottomSheet(context, cfg, s),
            ),
          ]),
          const SizedBox(height: 20),

          // ── QURAN ──────────────────────────────────────────────────────────
          _sectionHeader(s.sectionQuran, cfg),
          _sectionCard(cfg, [
            _buildSwitchTile(
              icon: Icons.g_translate_rounded,
              title: s.settingEnTranslation,
              subtitle: widget.isDualLanguage ? s.settingEnTransOn : s.settingEnTransOff,
              value: widget.isDualLanguage,
              cfg: cfg,
              onChanged: widget.onDualLanguageChanged,
            ),
            _divider(cfg),
            _buildNavTile(
              icon: Icons.swap_vert_rounded,
              title: s.settingNavMode,
              subtitle: widget.isHorizontalSwipe ? s.settingNavModeHoriz : s.settingNavModeVert,
              cfg: cfg,
              onTap: () => _showNavigationBottomSheet(context, cfg, s),
            ),
          ]),
          const SizedBox(height: 20),

          // ── LOCK SCREEN ────────────────────────────────────────────────────
          _sectionHeader(s.sectionLockscreen, cfg),
          _sectionCard(cfg, [
            _buildSwitchTile(
              icon: Icons.widgets_rounded,
              title: s.settingLockscreenAyah,
              subtitle: widget.isLockscreenAyahEnabled ? s.settingLockscreenOn : s.settingLockscreenOff,
              value: widget.isLockscreenAyahEnabled,
              cfg: cfg,
              onChanged: (val) async {
                widget.onLockscreenAyahChanged(val);
                await _updateLockscreenSettings();
              },
            ),
            if (widget.isLockscreenAyahEnabled) ...[
              _divider(cfg),
              _buildExpandableTile(
                icon: Icons.schedule_rounded,
                title: s.settingUpdateMode,
                subtitle: _updateModeLabel(s),
                isExpanded: _showLockscreenDetails,
                cfg: cfg,
                onTap: () => setState(() => _showLockscreenDetails = !_showLockscreenDetails),
              ),
              if (_showLockscreenDetails) _buildUpdateModePanel(cfg, s),
              _divider(cfg),
              ListTile(
                leading: _isRefreshing
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: cfg.borderAccent))
                    : Icon(Icons.refresh_rounded, color: cfg.borderAccent, size: 22),
                title: Text(s.settingRefreshNow,
                    style: TextStyle(color: cfg.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(
                  _previewAyah != null
                      ? s.currentAyahLabel(_previewAyah!['surahName'] ?? '', _previewAyah!['ayahNumber'] ?? 0)
                      : s.refreshAyahHint,
                  style: TextStyle(color: cfg.textSecondary, fontSize: 12),
                ),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: cfg.textSecondary),
                onTap: _isRefreshing
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        setState(() => _isRefreshing = true);
                        final newAyah = await LockscreenAyahService.refreshAyahNow();
                        if (mounted) {
                          setState(() {
                            _previewAyah = newAyah;
                            _isRefreshing = false;
                          });
                          messenger.showSnackBar(SnackBar(
                            backgroundColor: cfg.borderAccent,
                            content: Text(s.snackbarRefreshed,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            duration: const Duration(seconds: 2),
                          ));
                        }
                      },
              ),
              _divider(cfg),
              _buildWidgetMiniPreview(cfg, s),
              _divider(cfg),
              ListTile(
                leading: Icon(Icons.color_lens_rounded, color: cfg.borderAccent, size: 22),
                title: Text(s.settingWidgetAppear,
                    style: TextStyle(color: cfg.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(s.settingWidgetAppearSub,
                    style: TextStyle(color: cfg.textSecondary, fontSize: 12)),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: cfg.textSecondary),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WidgetAppearanceScreen(appThemeMode: widget.themeMode),
                    ),
                  );
                },
              ),
            ],
          ]),
          const SizedBox(height: 20),

          // ── LANGUAGE ────────────────────────────────────────────────────────
          _sectionHeader(s.sectionLanguage, cfg),
          _sectionCard(cfg, [
            _buildLangOption(
              flag: '🇸🇦',
              title: s.langArabic,
              subtitle: s.langArabicSub,
              isSelected: widget.isArabic,
              cfg: cfg,
              onTap: () => widget.onLanguageChanged(true),
            ),
            _divider(cfg),
            _buildLangOption(
              flag: '🇬🇧',
              title: s.langEnglish,
              subtitle: s.langEnglishSub,
              isSelected: !widget.isArabic,
              cfg: cfg,
              onTap: () => widget.onLanguageChanged(false),
            ),
          ]),
          const SizedBox(height: 20),

          // ── ABOUT ──────────────────────────────────────────────────────────
          _sectionHeader(s.sectionAbout, cfg),
          _sectionCard(cfg, [
            ListTile(
              leading: Icon(Icons.star_rounded, color: cfg.borderAccent),
              title: Text(s.aboutApp,
                  style: TextStyle(color: cfg.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(s.aboutVersion, style: TextStyle(color: cfg.textSecondary, fontSize: 12)),
            ),
            _divider(cfg),
            ListTile(
              leading: Icon(Icons.person_rounded, color: cfg.borderAccent),
              title: Text(s.developerLabel,
                  style: TextStyle(color: cfg.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text(s.developerName, style: TextStyle(color: cfg.textSecondary, fontSize: 12)),
            ),
            _divider(cfg),
            ListTile(
              leading: Icon(Icons.info_outline_rounded, color: cfg.borderAccent),
              title: Text(s.aboutTitle,
                  style: TextStyle(color: cfg.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
              trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: cfg.textSecondary),
              onTap: () => _showAboutDialog(context, cfg, s),
            ),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // THEME PICKER TILE (opens bottom sheet)
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildThemePickerTile(ThemeConfig cfg, AppStrings s) {
    final currentCfg = AppTheme.getConfig(widget.themeMode);
    return ListTile(
      leading: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: currentCfg.borderAccent,
          shape: BoxShape.circle,
          border: Border.all(color: currentCfg.appBg, width: 2),
        ),
      ),
      title: Text(s.settingTheme,
          style: TextStyle(color: cfg.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(currentCfg.nameArabic,
          style: TextStyle(color: cfg.textSecondary, fontSize: 12)),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: cfg.textSecondary),
      onTap: () => _showThemeBottomSheet(context, cfg, s),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // UPDATE MODE PANEL (expanded inline)
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildUpdateModePanel(ThemeConfig cfg, AppStrings s) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cfg.appBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cfg.borderAccent.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _buildRadioOption(s.updateModeByTime, 'byTime', s.updateModeByTimeSub, cfg),
          if (_lockscreenUpdateMode == 'byTime')
            _buildChipsRow(
              [(s.chipEveryHour, 60), (s.chip3Hours, 180), (s.chip6Hours, 360), (s.chip12Hours, 720), (s.chipDaily, 1440)],
              (min) => _lockscreenIntervalMinutes == min,
              (min) => _updateLockscreenSettings(interval: min),
              cfg,
            ),
          const SizedBox(height: 6),
          _buildRadioOption(s.updateModeCustom, 'custom', s.updateModeCustomSub, cfg),
          if (_lockscreenUpdateMode == 'custom')
            _buildChipsRow(
              [(s.chip15Min, 15), (s.chip30Min, 30), (s.chip45Min, 45), (s.chip2Hours, 120), (s.chip5Hours, 300)],
              (min) => _lockscreenCustomMinutes == min,
              (min) => _updateLockscreenSettings(custom: min),
              cfg,
            ),
          const SizedBox(height: 6),
          _buildRadioOption(s.updateModeScreenOff, 'screenOff', s.updateModeScreenOffSub, cfg),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String title, String value, String subtitle, ThemeConfig cfg) {
    final isSelected = _lockscreenUpdateMode == value;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? cfg.borderAccent : cfg.textSecondary,
        size: 20,
      ),
      title: Text(title,
          style: TextStyle(
              color: isSelected ? cfg.borderAccent : cfg.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13)),
      subtitle: Text(subtitle, style: TextStyle(color: cfg.textSecondary, fontSize: 11)),
      onTap: () => _updateLockscreenSettings(mode: value),
    );
  }

  Widget _buildChipsRow(
    List<(String, int)> options,
    bool Function(int) isSelected,
    void Function(int) onSelect,
    ThemeConfig cfg,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: options.map((opt) {
          final selected = isSelected(opt.$2);
          return ChoiceChip(
            label: Text(opt.$1, style: const TextStyle(fontSize: 11)),
            selected: selected,
            selectedColor: cfg.borderAccent.withValues(alpha: 0.2),
            checkmarkColor: cfg.borderAccent,
            labelStyle: TextStyle(
              color: selected ? cfg.borderAccent : cfg.textSecondary,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
            onSelected: (s) { if (s) onSelect(opt.$2); },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWidgetMiniPreview(ThemeConfig cfg, AppStrings s) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview_rounded, size: 14, color: cfg.borderAccent),
              const SizedBox(width: 5),
              Text(s.settingWidgetPreview,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: cfg.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2823),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFC5A059), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  const Icon(Icons.menu_book_rounded, size: 13, color: Color(0xFFC5A059)),
                  const SizedBox(width: 5),
                  const Text('القرآن الكريم',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFC5A059))),
                  const Spacer(),
                  _badge(_previewAyah?['surahName'] != null ? 'سورة ${_previewAyah!["surahName"]}' : 'سورة الفاتحة'),
                  const SizedBox(width: 4),
                  _badge(_previewAyah?['ayahNumber'] != null ? 'آية ${_previewAyah!["ayahNumber"]}' : 'آية 2'),
                ]),
                const SizedBox(height: 10),
                Text(
                  (_previewAyah?['ayahText'] as String?)?.isNotEmpty == true
                      ? _previewAyah!['ayahText'] as String
                      : 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Color(0xFFFDFBF7), height: 1.8),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 12, color: cfg.textSecondary),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  s.settingWidgetHint,
                  style: TextStyle(fontSize: 10, color: cfg.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0x26C5A059),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x66C5A059), width: 0.8),
      ),
      child: Text(text, style: const TextStyle(fontSize: 9.5, color: Color(0xFFE6D3A3), fontWeight: FontWeight.w600)),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // BOTTOM SHEETS & DIALOGS
  // ──────────────────────────────────────────────────────────────────────────

  void _showThemeBottomSheet(BuildContext context, ThemeConfig cfg, AppStrings s) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cfg.paperBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ThemePickerSheet(
        currentTheme: widget.themeMode,
        cfg: cfg,
        onSelect: widget.onThemeModeChanged,
        titleText: s.chooseTheme,
      ),
    );
  }

  void _showFontBottomSheet(BuildContext context, ThemeConfig cfg, AppStrings s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cfg.paperBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _FontSettingsSheet(
        cfg: cfg,
        fontFamily: widget.fontFamily,
        fontWeight: widget.fontWeight,
        fontSize: widget.fontSize,
        lineHeight: widget.lineHeight,
        onFontFamilyChanged: widget.onFontFamilyChanged,
        onFontWeightChanged: widget.onFontWeightChanged,
        onFontSizeChanged: widget.onFontSizeChanged,
        onLineHeightChanged: widget.onLineHeightChanged,
        strings: s,
      ),
    );
  }

  void _showNavigationBottomSheet(BuildContext context, ThemeConfig cfg, AppStrings s) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cfg.paperBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _NavigationSheet(
        cfg: cfg,
        isHorizontalSwipe: widget.isHorizontalSwipe,
        onChanged: widget.onHorizontalSwipeChanged,
        strings: s,
      ),
    );
  }



  void _showAboutDialog(BuildContext context, ThemeConfig cfg, AppStrings s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cfg.paperBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.auto_stories_rounded, color: cfg.borderAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                s.aboutApp,
                style: TextStyle(color: cfg.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: cfg.borderAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cfg.borderAccent.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_rounded, size: 18, color: cfg.borderAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${s.developerLabel}: ${s.developerName}',
                      style: TextStyle(
                        color: cfg.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              s.aboutContent,
              style: TextStyle(color: cfg.textSecondary, height: 1.6, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.ok, style: TextStyle(color: cfg.borderAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // LAYOUT HELPERS
  // ──────────────────────────────────────────────────────────────────────────

  Widget _sectionHeader(String title, ThemeConfig cfg) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: cfg.borderAccent,
          letterSpacing: 1.4,
        ),
      ),
    );
  }

  Widget _sectionCard(ThemeConfig cfg, List<Widget> children) {
    return Material(
      color: cfg.paperBg,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: cfg.borderAccent.withValues(alpha: 0.25)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ThemeConfig cfg,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: cfg.borderAccent, size: 22),
      title: Text(title,
          style: TextStyle(color: cfg.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(color: cfg.textSecondary, fontSize: 12)),
      value: value,
      activeTrackColor: cfg.borderAccent,
      onChanged: onChanged,
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeConfig cfg,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: cfg.borderAccent, size: 22),
      title: Text(title,
          style: TextStyle(color: cfg.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(color: cfg.textSecondary, fontSize: 12)),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: cfg.textSecondary),
      onTap: onTap,
    );
  }

  Widget _buildExpandableTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isExpanded,
    required ThemeConfig cfg,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: cfg.borderAccent, size: 22),
      title: Text(title,
          style: TextStyle(color: cfg.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(color: cfg.textSecondary, fontSize: 12)),
      trailing: Icon(
          isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
          color: cfg.borderAccent),
      onTap: onTap,
    );
  }

  Widget _divider(ThemeConfig cfg) =>
      Divider(height: 1, color: cfg.borderAccent.withValues(alpha: 0.12));

  String _fontFamilyLabel(ArabicFontFamily family, AppStrings s) {
    switch (family) {
      case ArabicFontFamily.amiri:  return s.fontAmiri;
      case ArabicFontFamily.naskh:  return s.fontNaskh;
      case ArabicFontFamily.hafs:   return s.fontHafs;
      case ArabicFontFamily.system: return s.fontSystem;
    }
  }

  String _updateModeLabel(AppStrings s) {
    switch (_lockscreenUpdateMode) {
      case 'custom':    return s.updateModeCustom;
      case 'screenOff': return s.updateModeScreenOff;
      default:          return s.updateModeByTime;
    }
  }

  Widget _buildLangOption({
    required String flag,
    required String title,
    required String subtitle,
    required bool isSelected,
    required ThemeConfig cfg,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(title,
          style: TextStyle(
              color: isSelected ? cfg.borderAccent : cfg.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(color: cfg.textSecondary, fontSize: 12)),
      trailing: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? cfg.borderAccent : cfg.textSecondary,
      ),
      onTap: onTap,
    );
  }
}

// =============================================================================
// THEME PICKER BOTTOM SHEET
// =============================================================================

class _ThemePickerSheet extends StatelessWidget {
  final QuranThemeMode currentTheme;
  final ThemeConfig cfg;
  final ValueChanged<QuranThemeMode> onSelect;
  final String titleText;

  const _ThemePickerSheet({
    required this.currentTheme,
    required this.cfg,
    required this.onSelect,
    this.titleText = 'اختر سمة التطبيق',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            titleText,
            style: TextStyle(color: cfg.textPrimary, fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: QuranThemeMode.values.map((mode) {
              final config = AppTheme.getConfig(mode);
              final isSelected = currentTheme == mode;
              return GestureDetector(
                onTap: () {
                  onSelect(mode);
                  Navigator.pop(context);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: config.appBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? config.borderAccent : Colors.grey.withValues(alpha: 0.3),
                      width: isSelected ? 2.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: config.borderAccent.withValues(alpha: 0.3), blurRadius: 12)]
                        : [],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 32,
                              decoration: BoxDecoration(
                                color: config.paperBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: config.borderAccent, width: 1.5),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(config.nameArabic,
                                style: TextStyle(
                                    color: config.isDark ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                                color: config.borderAccent, shape: BoxShape.circle),
                            child: Icon(Icons.check,
                                size: 12,
                                color: config.isDark ? Colors.black : Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// FONT SETTINGS BOTTOM SHEET
// =============================================================================

class _FontSettingsSheet extends StatefulWidget {
  final ThemeConfig cfg;
  final ArabicFontFamily fontFamily;
  final ArabicFontWeightOption fontWeight;
  final double fontSize;
  final double lineHeight;
  final ValueChanged<ArabicFontFamily> onFontFamilyChanged;
  final ValueChanged<ArabicFontWeightOption> onFontWeightChanged;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<double> onLineHeightChanged;
  final AppStrings strings;

  const _FontSettingsSheet({
    required this.cfg,
    required this.fontFamily,
    required this.fontWeight,
    required this.fontSize,
    required this.lineHeight,
    required this.onFontFamilyChanged,
    required this.onFontWeightChanged,
    required this.onFontSizeChanged,
    required this.onLineHeightChanged,
    required this.strings,
  });

  @override
  State<_FontSettingsSheet> createState() => _FontSettingsSheetState();
}

class _FontSettingsSheetState extends State<_FontSettingsSheet> {
  late ArabicFontFamily _fontFamily;
  late ArabicFontWeightOption _fontWeight;
  late double _fontSize;
  late double _lineHeight;

  @override
  void initState() {
    super.initState();
    _fontFamily = widget.fontFamily;
    _fontWeight = widget.fontWeight;
    _fontSize = widget.fontSize;
    _lineHeight = widget.lineHeight;
  }

  @override
  Widget build(BuildContext context) {
    final cfg = widget.cfg;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: cfg.textSecondary.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(widget.strings.chooseFontTitle,
              style: TextStyle(color: cfg.textPrimary, fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 16),

          // Preview
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: cfg.bannerBg.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cfg.borderAccent.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(
                'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                style: AppTheme.getArabicTextStyle(
                  fontFamily: _fontFamily,
                  fontWeight: _fontWeight,
                  fontSize: _fontSize,
                  lineHeight: _lineHeight,
                  color: cfg.borderAccent,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(widget.strings.fontType,
              style: TextStyle(color: cfg.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          ...ArabicFontFamily.values.map((family) {
            final isSelected = _fontFamily == family;
            final labels = {
              ArabicFontFamily.amiri: widget.strings.fontAmiri,
              ArabicFontFamily.naskh: widget.strings.fontNaskh,
              ArabicFontFamily.hafs:  widget.strings.fontHafs,
              ArabicFontFamily.system: widget.strings.fontSystem,
            };
            return ListTile(
              dense: true,
              leading: Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? cfg.borderAccent : cfg.textSecondary, size: 20),
              title: Text(labels[family]!,
                  style: TextStyle(
                      color: isSelected ? cfg.borderAccent : cfg.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
              trailing: Text('﴿١﴾',
                  style: AppTheme.getArabicTextStyle(fontFamily: family, fontSize: 16, color: cfg.borderAccent)),
              onTap: () {
                setState(() => _fontFamily = family);
                widget.onFontFamilyChanged(family);
              },
            );
          }),
          const Divider(height: 24),

          Text(widget.strings.fontWeightLabel,
              style: TextStyle(color: cfg.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ArabicFontWeightOption.values.map((w) {
              final labels = {
                ArabicFontWeightOption.normal: widget.strings.fontNormal,
                ArabicFontWeightOption.bold:   widget.strings.fontBold,
                ArabicFontWeightOption.heavy:  widget.strings.fontHeavy,
              };
              final isSelected = _fontWeight == w;
              return ChoiceChip(
                label: Text(labels[w]!),
                selected: isSelected,
                selectedColor: cfg.borderAccent.withValues(alpha: 0.2),
                checkmarkColor: cfg.borderAccent,
                labelStyle: TextStyle(
                  color: isSelected ? cfg.borderAccent : cfg.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 12,
                ),
                onSelected: (s) {
                  if (s) {
                    setState(() => _fontWeight = w);
                    widget.onFontWeightChanged(w);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.strings.fontSizeLabel,
                  style: TextStyle(color: cfg.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
              Text('${_fontSize.toInt()} pt',
                  style: TextStyle(color: cfg.borderAccent, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          Slider(
            value: _fontSize, min: 18, max: 42, divisions: 12,
            activeColor: cfg.borderAccent, inactiveColor: cfg.borderAccent.withValues(alpha: 0.2),
            onChanged: (v) { setState(() => _fontSize = v); widget.onFontSizeChanged(v); },
          ),
          const SizedBox(height: 8),

          Text(widget.strings.lineSpacing,
              style: TextStyle(color: cfg.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [(widget.strings.spacingClose, 1.5), (widget.strings.spacingNormal, 1.9), (widget.strings.spacingWide, 2.3)].map((opt) {
              final isSelected = _lineHeight == opt.$2;
              return ChoiceChip(
                label: Text(opt.$1),
                selected: isSelected,
                selectedColor: cfg.borderAccent.withValues(alpha: 0.2),
                checkmarkColor: cfg.borderAccent,
                labelStyle: TextStyle(
                  color: isSelected ? cfg.borderAccent : cfg.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 12,
                ),
                onSelected: (s) {
                  if (s) { setState(() => _lineHeight = opt.$2); widget.onLineHeightChanged(opt.$2); }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// =============================================================================
// NAVIGATION SETTINGS BOTTOM SHEET
// =============================================================================

class _NavigationSheet extends StatelessWidget {
  final ThemeConfig cfg;
  final bool isHorizontalSwipe;
  final ValueChanged<bool> onChanged;
  final AppStrings strings;

  const _NavigationSheet({
    required this.cfg,
    required this.isHorizontalSwipe,
    required this.onChanged,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(strings.chooseNavMode,
              style: TextStyle(color: cfg.textPrimary, fontWeight: FontWeight.bold, fontSize: 17)),
        ),
        _navOption(context, Icons.swap_horiz_rounded, strings.navHoriz, strings.navHorizSub, true),
        Divider(height: 1, color: cfg.borderAccent.withValues(alpha: 0.15)),
        _navOption(context, Icons.swap_vert_rounded, strings.navVert, strings.navVertSub, false),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _navOption(BuildContext context, IconData icon, String title, String sub, bool horizontal) {
    final isSelected = isHorizontalSwipe == horizontal;
    return ListTile(
      leading: Icon(icon, color: isSelected ? cfg.borderAccent : cfg.textSecondary),
      title: Text(title,
          style: TextStyle(
              color: isSelected ? cfg.borderAccent : cfg.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      subtitle: Text(sub, style: TextStyle(color: cfg.textSecondary, fontSize: 12)),
      trailing: Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: isSelected ? cfg.borderAccent : cfg.textSecondary),
      onTap: () {
        onChanged(horizontal);
        Navigator.pop(context);
      },
    );
  }
}
