import 'package:flutter/material.dart';
import '../models/widget_appearance.dart';
import '../services/settings_service.dart';
import '../services/lockscreen_ayah_service.dart';
import '../theme/app_theme.dart';

class WidgetAppearanceScreen extends StatefulWidget {
  final QuranThemeMode appThemeMode;

  const WidgetAppearanceScreen({super.key, required this.appThemeMode});

  @override
  State<WidgetAppearanceScreen> createState() => _WidgetAppearanceScreenState();
}

class _WidgetAppearanceScreenState extends State<WidgetAppearanceScreen> {
  WidgetAppearanceSettings _settings = const WidgetAppearanceSettings();
  ArabicFontFamily _fontFamily = ArabicFontFamily.amiri;
  Map<String, dynamic>? _previewAyah;
  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsService.getWidgetAppearance();
    final ayah = await LockscreenAyahService.getLastShownAyah();
    final font = await SettingsService.getFontFamily();
    if (mounted) {
      setState(() {
        _settings = settings;
        _previewAyah = ayah;
        _fontFamily = font;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAndApply() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSaving = true);
    await SettingsService.setWidgetAppearance(_settings);
    await LockscreenAyahService.syncAppearanceToNative(_settings);
    final ayah = await LockscreenAyahService.getLastShownAyah();
    if (mounted) {
      setState(() {
        _previewAyah = ayah;
        _isSaving = false;
      });
      messenger.showSnackBar(
        SnackBar(
          content: const Text(
            'تم حفظ مظهر الـ Widget وتطبيقه فورياً على الشاشة',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFC5A059),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appCfg = AppTheme.getConfig(widget.appThemeMode);
    final widgetCfg = WidgetThemeRegistry.getConfig(_settings.theme);

    return Scaffold(
      backgroundColor: appCfg.appBg,
      appBar: AppBar(
        backgroundColor: appCfg.appBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: appCfg.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'مظهر Widget الآية',
          style: TextStyle(color: appCfg.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isSaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: appCfg.borderAccent, strokeWidth: 2.5),
                  )
                : TextButton.icon(
                    onPressed: _saveAndApply,
                    icon: Icon(Icons.check_rounded, size: 18, color: appCfg.borderAccent),
                    label: Text(
                      'حفظ',
                      style: TextStyle(color: appCfg.borderAccent, fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: appCfg.borderAccent))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                // ─── LIVE PREVIEW ─────────────────────────────────────────
                _buildPreviewSection(widgetCfg, appCfg),
                const SizedBox(height: 28),

                // ─── THEME SELECTOR ───────────────────────────────────────
                _buildSectionTitle('السمة / Theme', Icons.palette_outlined, appCfg),
                const SizedBox(height: 12),
                _buildThemeSelector(appCfg),
                const SizedBox(height: 24),

                // ─── SHAPE SELECTOR ───────────────────────────────────────
                _buildSectionTitle('شكل الـ Widget', Icons.crop_rounded, appCfg),
                const SizedBox(height: 12),
                _buildShapeSelector(appCfg, widgetCfg),
                const SizedBox(height: 24),

                // ─── FONT SIZE ────────────────────────────────────────────
                _buildSectionTitle('حجم الخط', Icons.text_fields_rounded, appCfg),
                const SizedBox(height: 8),
                _buildFontSizeSection(appCfg),
                const SizedBox(height: 24),

                // ─── TEXT ALIGNMENT ───────────────────────────────────────
                _buildSectionTitle('محاذاة النص', Icons.format_align_center_rounded, appCfg),
                const SizedBox(height: 12),
                _buildTextAlignSelector(appCfg),
                const SizedBox(height: 24),

                // ─── VISIBLE ELEMENTS ─────────────────────────────────────
                _buildSectionTitle('العناصر الظاهرة', Icons.visibility_outlined, appCfg),
                const SizedBox(height: 8),
                _buildVisibilityToggles(appCfg),
                const SizedBox(height: 32),

                // ─── SAVE BUTTON ──────────────────────────────────────────
                _buildSaveButton(appCfg),
                const SizedBox(height: 12),
                _buildAndroidNote(appCfg),
              ],
            ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // LIVE PREVIEW
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildPreviewSection(WidgetThemeConfig widgetCfg, ThemeConfig appCfg) {
    final ayahText = (_previewAyah?['ayahText'] as String?)?.isNotEmpty == true
        ? _previewAyah!['ayahText'] as String
        : 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ';
    final surahName = (_previewAyah?['surahName'] as String?)?.isNotEmpty == true
        ? _previewAyah!['surahName'] as String
        : 'الفاتحة';
    final ayahNum = _previewAyah?['ayahNumber'] ?? 2;

    final textAlign = _settings.textAlign == WidgetTextAlign.center
        ? TextAlign.center
        : TextAlign.right;

    BorderRadius borderRadius;
    switch (_settings.shape) {
      case WidgetShape.square:
        borderRadius = BorderRadius.circular(6);
        break;
      case WidgetShape.card:
        borderRadius = BorderRadius.circular(20);
        break;
      case WidgetShape.minimal:
        borderRadius = BorderRadius.circular(12);
        break;
      case WidgetShape.islamicFrame:
        borderRadius = BorderRadius.circular(24);
        break;
      case WidgetShape.rounded:
        borderRadius = BorderRadius.circular(18);
        break;
    }

    bool showBorder = _settings.shape != WidgetShape.minimal;
    bool showShadow = _settings.shape == WidgetShape.card;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.preview_rounded, size: 16, color: appCfg.borderAccent),
            const SizedBox(width: 6),
            Text(
              'معاينة مباشرة',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: appCfg.borderAccent,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: widgetCfg.background,
            borderRadius: borderRadius,
            border: showBorder
                ? Border.all(color: widgetCfg.accentColor, width: 1.5)
                : null,
            boxShadow: showShadow
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
          ),
          child: Stack(
            children: [
              // Islamic pattern overlay for islamicFrame shape
              if (_settings.shape == WidgetShape.islamicFrame)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: borderRadius,
                    child: CustomPaint(painter: _IslamicPatternPainter(widgetCfg.overlayColor)),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header bar
                    Row(
                      children: [
                        if (_settings.showAppName || _settings.showDecoration) ...[
                          Icon(Icons.menu_book_rounded, size: 14, color: widgetCfg.appTitleColor),
                          const SizedBox(width: 5),
                        ],
                        if (_settings.showAppName)
                          Text(
                            'القرآن الكريم',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: widgetCfg.appTitleColor,
                            ),
                          ),
                        const Spacer(),
                        if (_settings.showSurahName)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: widgetCfg.surahBadgeBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: widgetCfg.accentColor.withValues(alpha: 0.5), width: 0.8),
                            ),
                            child: Text(
                              'سورة $surahName',
                              style: TextStyle(
                                fontSize: _settings.surahFontSize,
                                fontWeight: FontWeight.bold,
                                color: widgetCfg.surahBadgeText,
                              ),
                            ),
                          ),
                        if (_settings.showAyahNumber) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: widgetCfg.surahBadgeBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: widgetCfg.accentColor.withValues(alpha: 0.4), width: 0.8),
                            ),
                            child: Text(
                              'آية $ayahNum',
                              style: TextStyle(
                                fontSize: _settings.surahFontSize - 1,
                                color: widgetCfg.accentColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Ayah Text
                    if (_settings.showAyahText)
                      Text(
                        ayahText,
                        textAlign: textAlign,
                        style: AppTheme.getArabicTextStyle(
                          fontFamily: _fontFamily,
                          fontSize: _settings.ayahFontSize,
                          color: widgetCfg.ayahTextColor,
                          lineHeight: 1.8,
                        ),
                      ),
                    // Decorative line
                    if (_settings.showDecoration) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          width: 60,
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                widgetCfg.accentColor,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // THEME SELECTOR
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildThemeSelector(ThemeConfig appCfg) {
    return SizedBox(
      height: 88,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: WidgetTheme.values.map((theme) {
          final cfg = WidgetThemeRegistry.getConfig(theme);
          final isSelected = _settings.theme == theme;
          return GestureDetector(
            onTap: () => setState(() => _settings = _settings.copyWith(theme: theme)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: cfg.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? cfg.accentColor : Colors.grey.withValues(alpha: 0.3),
                  width: isSelected ? 2.5 : 1,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: cfg.accentColor.withValues(alpha: 0.4), blurRadius: 10)]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(cfg.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text(
                    cfg.nameArabic,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: cfg.accentColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle_rounded, size: 14, color: cfg.accentColor),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SHAPE SELECTOR
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildShapeSelector(ThemeConfig appCfg, WidgetThemeConfig widgetCfg) {
    final shapes = {
      WidgetShape.rounded: ('دائري', Icons.rounded_corner_rounded),
      WidgetShape.square: ('مربع', Icons.crop_square_rounded),
      WidgetShape.card: ('بطاقة', Icons.credit_card_rounded),
      WidgetShape.minimal: ('بسيط', Icons.crop_din_rounded),
      WidgetShape.islamicFrame: ('إسلامي', Icons.auto_awesome_rounded),
    };

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: shapes.entries.map((entry) {
        final isSelected = _settings.shape == entry.key;
        return GestureDetector(
          onTap: () => setState(() => _settings = _settings.copyWith(shape: entry.key)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? appCfg.borderAccent.withValues(alpha: 0.15)
                  : appCfg.paperBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? appCfg.borderAccent : appCfg.borderAccent.withValues(alpha: 0.25),
                width: isSelected ? 1.8 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(entry.value.$2, size: 16,
                    color: isSelected ? appCfg.borderAccent : appCfg.textSecondary),
                const SizedBox(width: 6),
                Text(
                  entry.value.$1,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? appCfg.borderAccent : appCfg.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // FONT SIZE
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildFontSizeSection(ThemeConfig appCfg) {
    return Material(
      color: appCfg.paperBg,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: appCfg.borderAccent.withValues(alpha: 0.25)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Ayah text size
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('نص الآية', style: TextStyle(color: appCfg.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: appCfg.borderAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_settings.ayahFontSize.toStringAsFixed(0)} pt',
                    style: TextStyle(color: appCfg.borderAccent, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            Slider(
              value: _settings.ayahFontSize,
              min: 11.0,
              max: 22.0,
              divisions: 11,
              activeColor: appCfg.borderAccent,
              inactiveColor: appCfg.borderAccent.withValues(alpha: 0.2),
              onChanged: (v) => setState(() => _settings = _settings.copyWith(ayahFontSize: v)),
            ),
            const Divider(height: 16),
            // Surah name size
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('اسم السورة والرقم', style: TextStyle(color: appCfg.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: appCfg.borderAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_settings.surahFontSize.toStringAsFixed(0)} pt',
                    style: TextStyle(color: appCfg.borderAccent, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            Slider(
              value: _settings.surahFontSize,
              min: 8.0,
              max: 16.0,
              divisions: 8,
              activeColor: appCfg.borderAccent,
              inactiveColor: appCfg.borderAccent.withValues(alpha: 0.2),
              onChanged: (v) => setState(() => _settings = _settings.copyWith(surahFontSize: v)),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // TEXT ALIGNMENT
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildTextAlignSelector(ThemeConfig appCfg) {
    return Row(
      children: [
        Expanded(child: _alignChip('توسيط', WidgetTextAlign.center, Icons.format_align_center_rounded, appCfg)),
        const SizedBox(width: 12),
        Expanded(child: _alignChip('يمين', WidgetTextAlign.right, Icons.format_align_right_rounded, appCfg)),
      ],
    );
  }

  Widget _alignChip(String label, WidgetTextAlign align, IconData icon, ThemeConfig appCfg) {
    final isSelected = _settings.textAlign == align;
    return GestureDetector(
      onTap: () => setState(() => _settings = _settings.copyWith(textAlign: align)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? appCfg.borderAccent.withValues(alpha: 0.15) : appCfg.paperBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? appCfg.borderAccent : appCfg.borderAccent.withValues(alpha: 0.25),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? appCfg.borderAccent : appCfg.textSecondary),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? appCfg.borderAccent : appCfg.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // VISIBILITY TOGGLES
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildVisibilityToggles(ThemeConfig appCfg) {
    return Material(
      color: appCfg.paperBg,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: appCfg.borderAccent.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            _buildToggleTile('نص الآية', Icons.text_snippet_outlined, _settings.showAyahText, appCfg,
                (v) => setState(() => _settings = _settings.copyWith(showAyahText: v))),
            _divider(appCfg),
            _buildToggleTile('اسم السورة', Icons.bookmark_outline_rounded, _settings.showSurahName, appCfg,
                (v) => setState(() => _settings = _settings.copyWith(showSurahName: v))),
            _divider(appCfg),
            _buildToggleTile('رقم الآية', Icons.tag_rounded, _settings.showAyahNumber, appCfg,
                (v) => setState(() => _settings = _settings.copyWith(showAyahNumber: v))),
            _divider(appCfg),
            _buildToggleTile('زخرفة إسلامية', Icons.auto_awesome_outlined, _settings.showDecoration, appCfg,
                (v) => setState(() => _settings = _settings.copyWith(showDecoration: v))),
            _divider(appCfg),
            _buildToggleTile('اسم التطبيق', Icons.apps_rounded, _settings.showAppName, appCfg,
                (v) => setState(() => _settings = _settings.copyWith(showAppName: v))),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile(
    String label,
    IconData icon,
    bool value,
    ThemeConfig appCfg,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      secondary: Icon(icon, color: appCfg.borderAccent, size: 20),
      title: Text(label, style: TextStyle(color: appCfg.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
      value: value,
      activeTrackColor: appCfg.borderAccent,
      onChanged: onChanged,
      dense: true,
    );
  }

  Widget _divider(ThemeConfig appCfg) =>
      Divider(height: 1, indent: 56, color: appCfg.borderAccent.withValues(alpha: 0.12));

  // ──────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title, IconData icon, ThemeConfig appCfg) {
    return Row(
      children: [
        Icon(icon, size: 16, color: appCfg.borderAccent),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: appCfg.borderAccent,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(ThemeConfig appCfg) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveAndApply,
        style: ElevatedButton.styleFrom(
          backgroundColor: appCfg.borderAccent,
          foregroundColor: appCfg.isDark ? Colors.black : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4,
        ),
        icon: _isSaving
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.save_rounded, size: 20),
        label: Text(
          _isSaving ? 'جاري الحفظ...' : 'حفظ وتطبيق التغييرات',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildAndroidNote(ThemeConfig appCfg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appCfg.borderAccent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: appCfg.borderAccent.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 15, color: appCfg.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'ملاحظة: يتم تطبيق الثيم، شكل الـ Widget (دائري، مربع، بطاقة، بسيط، إسلامي)، حجم الخط، محاذاة النص، وخيارات الظهور فوراً على الـ Widget الحقيقي في شاشة الهاتف.',
              style: TextStyle(fontSize: 11, color: appCfg.textSecondary, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Islamic Pattern Painter
// ─────────────────────────────────────────────────────────────────────────────

class _IslamicPatternPainter extends CustomPainter {
  final Color color;
  _IslamicPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 4, paint);
        canvas.drawLine(Offset(x, y - 4), Offset(x, y + 4), paint);
        canvas.drawLine(Offset(x - 4, y), Offset(x + 4, y), paint);
      }
    }
    // Corner ornaments
    final cornerPaint = Paint()..color = color..strokeWidth = 1.5..style = PaintingStyle.stroke;
    const c = 20.0;
    // Top-left
    canvas.drawArc(Rect.fromLTWH(0, 0, c * 2, c * 2), 0, 1.6, false, cornerPaint);
    // Top-right
    canvas.drawArc(Rect.fromLTWH(size.width - c * 2, 0, c * 2, c * 2), 1.6, 1.6, false, cornerPaint);
    // Bottom-left
    canvas.drawArc(Rect.fromLTWH(0, size.height - c * 2, c * 2, c * 2), 3.2, 1.6, false, cornerPaint);
    // Bottom-right
    canvas.drawArc(Rect.fromLTWH(size.width - c * 2, size.height - c * 2, c * 2, c * 2), 4.7, 1.6, false, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant _IslamicPatternPainter old) => old.color != color;
}
