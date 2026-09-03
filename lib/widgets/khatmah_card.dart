import 'package:flutter/material.dart';
import '../models/khatmah.dart';
import '../services/khatmah_service.dart';
import '../services/quran_data.dart';
import '../theme/app_theme.dart';
import '../l10n/app_strings.dart';
import '../screens/surah_detail_screen.dart';

class KhatmahCard extends StatefulWidget {
  final QuranThemeMode themeMode;
  final bool isDualLanguage;
  final bool isHorizontalSwipe;
  final ArabicFontFamily fontFamily;
  final ArabicFontWeightOption fontWeight;
  final double fontSize;
  final double lineHeight;
  final bool isArabic;

  const KhatmahCard({
    super.key,
    required this.themeMode,
    this.isDualLanguage = true,
    this.isHorizontalSwipe = false,
    this.fontFamily = ArabicFontFamily.amiri,
    this.fontWeight = ArabicFontWeightOption.bold,
    this.fontSize = 26.0,
    this.lineHeight = 1.9,
    this.isArabic = true,
  });

  @override
  State<KhatmahCard> createState() => _KhatmahCardState();
}

class _KhatmahCardState extends State<KhatmahCard> {
  Khatmah? _active;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadKhatmah();
    KhatmahService.activeKhatmahNotifier.addListener(_onKhatmahChanged);
  }

  @override
  void dispose() {
    KhatmahService.activeKhatmahNotifier.removeListener(_onKhatmahChanged);
    super.dispose();
  }

  void _onKhatmahChanged() {
    if (mounted) {
      setState(() {
        _active = KhatmahService.activeKhatmahNotifier.value;
      });
    }
  }

  Future<void> _loadKhatmah() async {
    final k = await KhatmahService.getActiveKhatmah();
    if (mounted) {
      setState(() {
        _active = k;
        _loading = false;
      });
    }
  }

  Future<void> _handleStartKhatmah() async {
    final s = AppStrings.of(widget.isArabic);
    final cfg = AppTheme.getConfig(widget.themeMode);

    // If there is an active in-progress khatmah → ask confirmation
    if (_active != null && !_active!.isCompleted) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: cfg.paperBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(s.khatmahConfirmTitle,
              style: TextStyle(color: cfg.textPrimary, fontWeight: FontWeight.bold)),
          content: Text(s.khatmahConfirmContent,
              style: TextStyle(color: cfg.textSecondary, fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(s.khatmahCancel, style: TextStyle(color: cfg.textSecondary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _openKhatmah(_active!);
              },
              child: Text(s.continueKhatmah,
                  style: TextStyle(color: cfg.borderAccent, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cfg.borderAccent,
                foregroundColor: cfg.playButtonIcon,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.pop(context);
                await _createNewKhatmah();
              },
              child: Text(s.startNewKhatmah,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      await _createNewKhatmah();
    }
  }

  Future<void> _createNewKhatmah() async {
    final k = await KhatmahService.startNewKhatmah();
    setState(() => _active = k);
    if (mounted) _openKhatmah(k);
  }

  void _openKhatmah(Khatmah k) {
    // Find which surah owns the saved Mushaf page, then open from page 1 of that surah
    // We navigate to page 1 of Al-Fatihah for page 1, or find surah by page via allSurahs
    // Since SurahDetailScreen tracks by ayah, we open surah 1 and the horizontal view will jump to saved page
    _navigateToPage(k.currentPage);
  }

  void _navigateToPage(int mushafPage) {
    // Find the surah that contains this mushaf page
    // We do a simple linear search on allSurahs with page range
    // For the navigation we open Surah Al-Fatihah (surah 1) and jump via initialAyah=1.
    // The Khatmah detail screen will handle the exact page via a dedicated page-based navigator
    _openKhatmahReadingPage(mushafPage);
  }

  void _openKhatmahReadingPage(int mushafPage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _KhatmahReaderPage(
          mushafPage: mushafPage,
          themeMode: widget.themeMode,
          isDualLanguage: widget.isDualLanguage,
          isHorizontalSwipe: widget.isHorizontalSwipe,
          fontFamily: widget.fontFamily,
          fontWeight: widget.fontWeight,
          fontSize: widget.fontSize,
          lineHeight: widget.lineHeight,
          isArabic: widget.isArabic,
        ),
      ),
    ).then((_) => _loadKhatmah());
  }

  String _formatDate(DateTime dt, bool isArabic) {
    final d = dt.day, m = dt.month, y = dt.year;
    return '$d/$m/$y';
  }

  @override
  Widget build(BuildContext context) {
    final cfg = AppTheme.getConfig(widget.themeMode);
    final s = AppStrings.of(widget.isArabic);

    if (_loading) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            cfg.borderAccent.withValues(alpha: 0.18),
            cfg.appBg,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        border: Border.all(color: cfg.borderAccent.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: cfg.borderAccent.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -24,
            bottom: -24,
            child: Icon(
              Icons.auto_stories_rounded,
              size: 140,
              color: cfg.borderAccent.withValues(alpha: 0.07),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cfg.borderAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.auto_stories_rounded, color: cfg.borderAccent, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      s.khatmahTitle,
                      style: TextStyle(
                        color: cfg.borderAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const Spacer(),
                    // History button
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _KhatmahHistoryScreen(
                            themeMode: widget.themeMode,
                            isArabic: widget.isArabic,
                          ),
                        ),
                      ).then((_) => _loadKhatmah()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: cfg.borderAccent.withValues(alpha: 0.4)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.history_rounded, size: 14, color: cfg.borderAccent),
                            const SizedBox(width: 4),
                            Text(
                              s.khatmahHistory,
                              style: TextStyle(fontSize: 11, color: cfg.borderAccent),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (_active == null || _active!.isCompleted) ...[
                  // No active khatmah → show start prompt
                  Text(
                    _active != null && _active!.isCompleted
                        ? '🎉  ${s.khatmahCompleted}'
                        : s.khatmahCardDesc,
                    style: TextStyle(
                      color: cfg.textPrimary,
                      fontSize: _active != null ? 18 : 14,
                      fontWeight: _active != null ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _handleStartKhatmah,
                    icon: Icon(Icons.play_arrow_rounded, size: 18, color: cfg.playButtonIcon),
                    label: Text(
                      s.startNewKhatmah,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cfg.playButtonBg,
                      foregroundColor: cfg.playButtonIcon,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                  ),
                ] else ...[
                  // Active in-progress khatmah
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.khatmahPageProgress(
                                _active!.currentPage,
                                604,
                                _active!.progress.toStringAsFixed(1),
                              ),
                              style: TextStyle(
                                color: cfg.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${s.khatmahStartedAt} ${_formatDate(_active!.startedAt, widget.isArabic)}',
                              style: TextStyle(color: cfg.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${_active!.progress.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: cfg.borderAccent,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _active!.progress / 100.0,
                      backgroundColor: cfg.borderAccent.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(cfg.borderAccent),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openKhatmah(_active!),
                          icon: Icon(Icons.arrow_forward_rounded, size: 18, color: cfg.playButtonIcon),
                          label: Text(
                            s.continueKhatmah,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cfg.playButtonBg,
                            foregroundColor: cfg.playButtonIcon,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: _handleStartKhatmah,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cfg.borderAccent,
                          side: BorderSide(color: cfg.borderAccent.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        child: Icon(Icons.add_rounded, size: 20, color: cfg.borderAccent),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Internal navigator screen that opens the correct Surah by mushafPage ─────
class _KhatmahReaderPage extends StatelessWidget {
  final int mushafPage;
  final QuranThemeMode themeMode;
  final bool isDualLanguage;
  final bool isHorizontalSwipe;
  final ArabicFontFamily fontFamily;
  final ArabicFontWeightOption fontWeight;
  final double fontSize;
  final double lineHeight;
  final bool isArabic;

  const _KhatmahReaderPage({
    required this.mushafPage,
    required this.themeMode,
    required this.isDualLanguage,
    required this.isHorizontalSwipe,
    required this.fontFamily,
    required this.fontWeight,
    required this.fontSize,
    required this.lineHeight,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    // Delegate actual surah resolution to _KhatmahPageNavigatorScreen (async).
    return _KhatmahPageNavigatorScreen(
      mushafPage: mushafPage,
      themeMode: themeMode,
      isDualLanguage: isDualLanguage,
      isHorizontalSwipe: isHorizontalSwipe,
      fontFamily: fontFamily,
      fontWeight: fontWeight,
      fontSize: fontSize,
      lineHeight: lineHeight,
      isArabic: isArabic,
    );
  }
}

// ── Dedicated Khatmah page-first navigator ────────────────────────────────────
class _KhatmahPageNavigatorScreen extends StatefulWidget {
  final int mushafPage;
  final QuranThemeMode themeMode;
  final bool isDualLanguage;
  final bool isHorizontalSwipe;
  final ArabicFontFamily fontFamily;
  final ArabicFontWeightOption fontWeight;
  final double fontSize;
  final double lineHeight;
  final bool isArabic;

  const _KhatmahPageNavigatorScreen({
    required this.mushafPage,
    required this.themeMode,
    required this.isDualLanguage,
    required this.isHorizontalSwipe,
    required this.fontFamily,
    required this.fontWeight,
    required this.fontSize,
    required this.lineHeight,
    required this.isArabic,
  });

  @override
  State<_KhatmahPageNavigatorScreen> createState() =>
      _KhatmahPageNavigatorScreenState();
}

class _KhatmahPageNavigatorScreenState
    extends State<_KhatmahPageNavigatorScreen> {
  bool _loading = true;
  int _surahId = 1;
  int _initialAyah = 1;
  Khatmah? _active;

  @override
  void initState() {
    super.initState();
    _resolve();
    KhatmahService.activeKhatmahNotifier.addListener(_onKhatmahChanged);
  }

  @override
  void dispose() {
    KhatmahService.activeKhatmahNotifier.removeListener(_onKhatmahChanged);
    super.dispose();
  }

  void _onKhatmahChanged() {
    if (mounted) setState(() => _active = KhatmahService.activeKhatmahNotifier.value);
  }

  Future<void> _resolve() async {
    _active = await KhatmahService.getActiveKhatmah();
    // Find ayah on the target page
    final ayahs = await QuranDataService.getPageAyahs(widget.mushafPage);
    if (ayahs.isNotEmpty) {
      final first = ayahs.first;
      _surahId = first.surahId;
      _initialAyah = first.numberInSurah;
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cfg = AppTheme.getConfig(widget.themeMode);
    final s = AppStrings.of(widget.isArabic);

    if (_loading) {
      return Scaffold(
        backgroundColor: cfg.appBg,
        body: Center(child: CircularProgressIndicator(color: cfg.borderAccent)),
      );
    }

    final surah = QuranDataService.allSurahs.firstWhere(
      (s) => s.id == _surahId,
      orElse: () => QuranDataService.allSurahs[0],
    );

    return Scaffold(
      backgroundColor: cfg.appBg,
      appBar: AppBar(
        backgroundColor: cfg.appBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: cfg.borderAccent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          s.khatmahTitle,
          style: TextStyle(
            color: cfg.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          if (_active != null)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cfg.borderAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    s.pageOf(
                      KhatmahService.activeKhatmahNotifier.value?.currentPage ?? widget.mushafPage,
                      604,
                    ),
                    style: TextStyle(
                      color: cfg.borderAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SurahDetailScreen(
        surah: surah,
        initialAyah: _initialAyah,
        themeMode: widget.themeMode,
        isDualLanguage: widget.isDualLanguage,
        isHorizontalSwipe: true, // Khatmah always uses horizontal (page-by-page)
        fontFamily: widget.fontFamily,
        fontWeight: widget.fontWeight,
        fontSize: widget.fontSize,
        lineHeight: widget.lineHeight,
        isArabic: widget.isArabic,
        // ── CRITICAL: this flag separates Khatmah reading from normal reading ──
        // Only when isKhatmahReading is true will page/surah changes update
        // Khatmah progress. Normal reading (isKhatmahReading: false, the default)
        // never touches the Khatmah state.
        isKhatmahReading: true,
      ),
    );
  }
}

// ── Khatmah History Screen ────────────────────────────────────────────────────
class _KhatmahHistoryScreen extends StatefulWidget {
  final QuranThemeMode themeMode;
  final bool isArabic;

  const _KhatmahHistoryScreen({
    required this.themeMode,
    required this.isArabic,
  });

  @override
  State<_KhatmahHistoryScreen> createState() => _KhatmahHistoryScreenState();
}

class _KhatmahHistoryScreenState extends State<_KhatmahHistoryScreen> {
  List<Khatmah> _history = [];
  Khatmah? _active;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final active = await KhatmahService.getActiveKhatmah();
    final hist = await KhatmahService.getHistory();
    if (mounted) {
      setState(() {
        _active = active;
        _history = hist;
        _loading = false;
      });
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Widget _statusBadge(Khatmah k, ThemeConfig cfg, AppStrings s) {
    final isCompleted = k.isCompleted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color(0xFF22C55E).withValues(alpha: 0.15)
            : cfg.borderAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isCompleted ? s.khatmahCompleted : s.khatmahInProgress,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isCompleted ? const Color(0xFF22C55E) : cfg.borderAccent,
        ),
      ),
    );
  }

  Widget _khatmahTile(int index, Khatmah k, ThemeConfig cfg, AppStrings s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cfg.paperBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cfg.borderAccent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.khatmahIndexTitle(index),
                style: TextStyle(
                  color: cfg.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              _statusBadge(k, cfg, s),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: cfg.textSecondary),
              const SizedBox(width: 6),
              Text(
                '${s.khatmahStartedAt} ${_formatDate(k.startedAt)}',
                style: TextStyle(color: cfg.textSecondary, fontSize: 12),
              ),
            ],
          ),
          if (k.completedAt != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.check_circle_outline_rounded, size: 14, color: const Color(0xFF22C55E)),
                const SizedBox(width: 6),
                Text(
                  '${s.khatmahCompletedAt} ${_formatDate(k.completedAt!)}',
                  style: const TextStyle(color: Color(0xFF22C55E), fontSize: 12),
                ),
              ],
            ),
          ],
          if (!k.isCompleted) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    s.khatmahPageProgress(
                      k.currentPage,
                      604,
                      k.progress.toStringAsFixed(1),
                    ),
                    style: TextStyle(color: cfg.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: k.progress / 100.0,
                backgroundColor: cfg.borderAccent.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(cfg.borderAccent),
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: cfg.borderAccent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          s.khatmahHistory,
          style: TextStyle(
            color: cfg.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: cfg.borderAccent))
          : _active == null && _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_stories_rounded,
                          size: 64, color: cfg.borderAccent.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text(
                        s.khatmahNoHistory,
                        style: TextStyle(color: cfg.textSecondary, fontSize: 15),
                      ),
                    ],
                  ),
                )
              : Directionality(
                  textDirection: TextDirection.rtl,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_active != null && !_active!.isCompleted) ...[
                        _khatmahTile(1, _active!, cfg, s),
                      ],
                      ..._history.asMap().entries.map((e) {
                        final offset = (_active != null && !_active!.isCompleted) ? 1 : 0;
                        return _khatmahTile(e.key + 1 + offset, e.value, cfg, s);
                      }),
                    ],
                  ),
                ),
    );
  }
}
