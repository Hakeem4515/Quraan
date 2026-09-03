import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/surah.dart';
import '../services/quran_data.dart';
import '../theme/app_theme.dart';
import '../l10n/app_strings.dart';
import '../services/khatmah_service.dart';

class SurahDetailScreen extends StatefulWidget {
  final Surah surah;
  final int initialAyah;
  final QuranThemeMode themeMode;
  final bool isDualLanguage;
  final bool isHorizontalSwipe;
  final ArabicFontFamily fontFamily;
  final ArabicFontWeightOption fontWeight;
  final double fontSize;
  final double lineHeight;
  final bool isArabic;

  /// When true, this screen is opened inside a Khatmah session.
  /// Only in that case will reading position changes update Khatmah progress.
  /// Normal reading (isKhatmahReading = false) never touches Khatmah state.
  final bool isKhatmahReading;

  const SurahDetailScreen({
    super.key,
    required this.surah,
    this.initialAyah = 1,
    this.themeMode = QuranThemeMode.emeraldGold,
    this.isDualLanguage = true,
    this.isHorizontalSwipe = false,
    this.fontFamily = ArabicFontFamily.amiri,
    this.fontWeight = ArabicFontWeightOption.bold,
    this.fontSize = 26.0,
    this.lineHeight = 1.9,
    this.isArabic = true,
    this.isKhatmahReading = false,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  late Future<Map<int, List<Ayah>>> _surahsDataFuture;
  late PageController _pageController;
  late ScrollController _verticalScrollController;
  late double _arabicFontSize;
  late double _translationFontSize;

  Set<int> _bookmarkedAyahs = {};
  bool _isMushafView = true;
  late bool _showTranslation;
  late bool _horizontalSwipeMode;

  /// Current active Surah (updates dynamically in both Horizontal and Vertical modes)
  late Surah _currentSurah;
  late ValueNotifier<Surah> _currentSurahNotifier;
  Timer? _syncTimer;

  /// Current active Mushaf Page (1 to 604)
  int _currentMushafPage = 1;

  /// GlobalKeys for each of the 114 surahs in Vertical Continuous Mode
  final Map<int, GlobalKey> _surahKeys = {
    for (int i = 1; i <= 114; i++) i: GlobalKey(),
  };

  bool _isScrollingProgrammatically = false;

  @override
  void initState() {
    super.initState();
    _currentSurah = widget.surah;
    _currentSurahNotifier = ValueNotifier<Surah>(widget.surah);
    _showTranslation = widget.isDualLanguage;
    _horizontalSwipeMode = widget.isHorizontalSwipe;
    _arabicFontSize = widget.fontSize;
    _translationFontSize = widget.fontSize * 0.55;

    _verticalScrollController = ScrollController();
    _verticalScrollController.addListener(_onVerticalScroll);
    _pageController = PageController(initialPage: 0);

    _surahsDataFuture = QuranDataService.getAllSurahsMap();
    _initReadingPosition();
    _loadBookmarks();
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _currentSurahNotifier.dispose();
    _pageController.dispose();
    _verticalScrollController.removeListener(_onVerticalScroll);
    _verticalScrollController.dispose();
    super.dispose();
  }

  void _onVerticalScroll() {
    if (_horizontalSwipeMode || _isScrollingProgrammatically) return;

    int? foundSurahId;
    const double threshold = 160.0;

    // In ListView.builder, only mounted contexts (~2-4 items) exist.
    // Iterating only over mounted contexts takes microseconds without UI jank.
    for (int id = 1; id <= 114; id++) {
      final key = _surahKeys[id];
      final ctx = key?.currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          final top = box.localToGlobal(Offset.zero).dy;
          final bottom = top + box.size.height;

          // If reading threshold (just below AppBar) is inside this Surah:
          if (top <= threshold && bottom > threshold) {
            foundSurahId = id;
            break;
          }
          if (top >= 0 && foundSurahId == null) {
            foundSurahId = id;
          }
        }
      }
    }

    if (foundSurahId != null && foundSurahId != _currentSurahNotifier.value.id) {
      final newSurah = QuranDataService.allSurahs.firstWhere(
        (s) => s.id == foundSurahId,
        orElse: () => QuranDataService.allSurahs[0],
      );
      _currentSurah = newSurah;
      _currentSurahNotifier.value = newSurah;
      _debouncedSyncPosition(foundSurahId);
    }
  }

  void _debouncedSyncPosition(int surahId) {
    _syncTimer?.cancel();
    _syncTimer = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      _loadBookmarks();
      _saveLastRead(1);
      final range = await QuranDataService.getSurahPageRange(surahId);
      if (mounted) {
        _currentMushafPage = range.startPage;
        _updateKhatmahPage(range.startPage);
      }
    });
  }

  Future<void> _initReadingPosition() async {
    final page = await QuranDataService.getPageForAyah(widget.surah.id, widget.initialAyah);
    if (mounted) {
      _currentMushafPage = page;

      if (_horizontalSwipeMode) {
        _pageController.dispose();
        _pageController = PageController(initialPage: (page - 1).clamp(0, 603));
      } else if (widget.surah.id > 1) {
        _scrollToSurah(widget.surah.id, animate: false);
      }
      // Only save normal reading position when NOT in Khatmah context.
      // Khatmah has its own independent position stored via KhatmahService.
      if (!widget.isKhatmahReading) {
        _saveLastRead(widget.initialAyah);
      }
    }
  }

  Future<void> _loadBookmarks() async {
    final bookmarks = await QuranDataService.getBookmarks();
    if (mounted) {
      setState(() {
        _bookmarkedAyahs = bookmarks
            .where((b) => b.startsWith("${_currentSurah.id}:"))
            .map((b) => int.parse(b.split(":")[1]))
            .toSet();
      });
    }
  }

  Future<void> _saveLastRead(int ayahNum) async {
    await QuranDataService.saveLastRead(_currentSurah.id, ayahNum, _currentSurah.nameEnglish);
  }

  // ── Surah Navigation & Jumps ──────────────────────────────────────────────────

  double _estimateOffsetForSurah(int targetSurahId) {
    if (targetSurahId <= 1) return 0.0;
    double offset = 0.0;
    for (int i = 1; i < targetSurahId; i++) {
      final s = QuranDataService.allSurahs[i - 1];
      double surahHeight = (i != 1 && i != 9) ? 200.0 : 130.0;
      if (_isMushafView && !_showTranslation) {
        surahHeight += s.versesCount * (_arabicFontSize * 2.2);
      } else {
        surahHeight += s.versesCount * (_arabicFontSize * 3.6 + (_showTranslation ? 50.0 : 20.0));
      }
      offset += surahHeight + 24.0; // 24 is bottom margin
    }
    return offset;
  }

  void _scrollToSurah(int surahId, {bool animate = false}) {
    if (surahId <= 1) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_verticalScrollController.hasClients) return;
      _isScrollingProgrammatically = true;
      try {
        final key = _surahKeys[surahId];
        if (key != null && key.currentContext != null) {
          if (animate) {
            Scrollable.ensureVisible(
              key.currentContext!,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: 0.0,
            );
          } else {
            Scrollable.ensureVisible(
              key.currentContext!,
              duration: Duration.zero,
              alignment: 0.0,
            );
          }
        } else {
          final targetOffset = _estimateOffsetForSurah(surahId);
          final maxScroll = _verticalScrollController.position.maxScrollExtent;
          _verticalScrollController.jumpTo(targetOffset.clamp(0.0, maxScroll));

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final postKey = _surahKeys[surahId];
            if (postKey != null && postKey.currentContext != null) {
              Scrollable.ensureVisible(
                postKey.currentContext!,
                duration: Duration.zero,
                alignment: 0.0,
              );
            }
          });
        }
      } catch (_) {
      } finally {
        _isScrollingProgrammatically = false;
      }
    });
  }

  /// Navigate directly to a chosen Surah from the Surah Picker
  Future<void> _navigateToSurah(Surah surah) async {
    _currentSurah = surah;
    _currentSurahNotifier.value = surah;
    _loadBookmarks();

    if (_horizontalSwipeMode) {
      final range = await QuranDataService.getSurahPageRange(surah.id);
      final targetPageIdx = (range.startPage - 1).clamp(0, 603);
      if (_pageController.hasClients) {
        _pageController.jumpToPage(targetPageIdx);
      }
      setState(() {
        _currentMushafPage = range.startPage;
      });
      _updateKhatmahPage(range.startPage);
    } else {
      _scrollToSurah(surah.id, animate: true);
      final range = await QuranDataService.getSurahPageRange(surah.id);
      _updateKhatmahPage(range.startPage);
    }
    _saveLastRead(1);
  }

  /// Switch between Horizontal (PageView 604 pages) and Vertical (Continuous 114 Surahs)
  Future<void> _toggleNavigationMode(bool isHorizontal) async {
    if (_horizontalSwipeMode == isHorizontal) return;

    if (isHorizontal) {
      // Switching to Horizontal mode: get starting page of current reading position
      final page = _currentMushafPage.clamp(1, 604);
      setState(() {
        _horizontalSwipeMode = true;
      });
      _pageController.dispose();
      _pageController = PageController(initialPage: page - 1);
    } else {
      // Switching to Vertical continuous mode
      setState(() {
        _horizontalSwipeMode = false;
      });
      _scrollToSurah(_currentSurahNotifier.value.id);
    }
  }

  /// Shows the searchable Surah Picker BottomSheet
  void _showSurahPickerSheet(ThemeConfig cfg) {
    final s = AppStrings.of(widget.isArabic);
    final allSurahs = QuranDataService.allSurahs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SurahPickerSheet(
        cfg: cfg,
        isArabic: widget.isArabic,
        allSurahs: allSurahs,
        currentSurahId: _currentSurahNotifier.value.id,
        searchHintText: s.surahPickerSearchHint,
        titleText: s.surahPickerTitle,
        onSurahSelected: (surah) {
          Navigator.pop(context);
          _navigateToSurah(surah);
        },
      ),
    );
  }

  /// Saves Khatmah progress for the given Medina Mushaf page number (1‒604).
  /// This method is a NO-OP when the screen is opened in normal reading mode
  /// (isKhatmahReading == false). Only Khatmah sessions may update Khatmah progress.
  Future<void> _updateKhatmahPage(int mushafPage) async {
    // ── KEY GUARD ─────────────────────────────────────────────────────────────
    // Normal reading navigation (surah list, search, vertical scroll, page swipe)
    // must NEVER modify Khatmah progress. Only Khatmah sessions do.
    if (!widget.isKhatmahReading) return;
    // ─────────────────────────────────────────────────────────────────────────
    final bool justCompleted = await KhatmahService.updateProgress(mushafPage);
    if (justCompleted && mounted) {
      final s = AppStrings.of(widget.isArabic);
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: AppTheme.getConfig(widget.themeMode).paperBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Text('🎉 ', style: TextStyle(fontSize: 28)),
              Expanded(
                child: Text(
                  s.khatmahCongratTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.getConfig(widget.themeMode).textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            s.khatmahCongratSub,
            style: TextStyle(color: AppTheme.getConfig(widget.themeMode).textSecondary, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(s.ok, style: TextStyle(color: AppTheme.getConfig(widget.themeMode).borderAccent)),
            ),
          ],
        ),
      );
    }
  }

  void _toggleBookmark(int surahId, int ayahNum) async {
    await QuranDataService.toggleBookmark(surahId, ayahNum);
    if (!mounted) return;
    setState(() {
      if (_bookmarkedAyahs.contains(ayahNum)) {
        _bookmarkedAyahs.remove(ayahNum);
      } else {
        _bookmarkedAyahs.add(ayahNum);
      }
    });

    final s = AppStrings.of(widget.isArabic);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _bookmarkedAyahs.contains(ayahNum)
              ? s.bookmarkAdded(ayahNum)
              : s.bookmarkRemoved(ayahNum),
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _toArabicDigits(int number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String str = number.toString();
    for (int i = 0; i < english.length; i++) {
      str = str.replaceAll(english[i], arabic[i]);
    }
    return str;
  }

  void _showAyahActionSheet(Ayah ayah, Surah surah, ThemeConfig cfg) {
    final isBookmarked = _bookmarkedAyahs.contains(ayah.numberInSurah);
    final s = AppStrings.of(widget.isArabic);

    showModalBottomSheet(
      context: context,
      backgroundColor: cfg.paperBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: cfg.borderAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      s.actionSheetTitle(surah.nameArabic, surah.nameEnglish, ayah.numberInSurah),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cfg.borderAccent,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: cfg.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ayah.arabicText,
                style: AppTheme.getArabicTextStyle(
                  fontFamily: widget.fontFamily,
                  fontWeight: widget.fontWeight,
                  fontSize: 22,
                  lineHeight: widget.lineHeight,
                  color: cfg.textPrimary,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
              if (_showTranslation) ...[
                const SizedBox(height: 12),
                Text(
                  ayah.englishTranslation,
                  style: TextStyle(
                    fontSize: 14,
                    color: cfg.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      _toggleBookmark(surah.id, ayah.numberInSurah);
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: cfg.borderAccent,
                    ),
                    label: Text(
                      s.bookmark(isBookmarked),
                      style: TextStyle(color: cfg.borderAccent),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: cfg.borderAccent),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                        text: _showTranslation
                            ? "${ayah.arabicText}\n\n${ayah.englishTranslation}\n(${surah.nameArabic} - ${surah.nameEnglish} ${surah.id}:${ayah.numberInSurah})"
                            : "${ayah.arabicText}\n(${surah.nameArabic} ${surah.id}:${ayah.numberInSurah})",
                      ));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(s.copySuccess),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: Text(widget.isArabic ? 'نسخ' : 'Copy'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cfg.borderAccent.withValues(alpha: 0.15),
                      foregroundColor: cfg.textPrimary,
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReadingSettingsSheet(ThemeConfig cfg) {
    final s = AppStrings.of(widget.isArabic);

    showModalBottomSheet(
      context: context,
      backgroundColor: cfg.paperBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: cfg.borderAccent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.settings_outlined, color: cfg.borderAccent, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              s.readingSettingsTitle,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: cfg.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: cfg.textPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(height: 1, color: cfg.borderAccent.withValues(alpha: 0.2)),
                    const SizedBox(height: 16),

                    // 1. Navigation Mode (طريقة التنقل: تمرير رأسي / تمرير أفقي)
                    Row(
                      children: [
                        Icon(Icons.swap_horiz_rounded, size: 18, color: cfg.borderAccent),
                        const SizedBox(width: 8),
                        Text(
                          s.readingNavMode,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: cfg.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              _toggleNavigationMode(false);
                              setModalState(() {});
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                color: !_horizontalSwipeMode
                                    ? cfg.borderAccent.withValues(alpha: 0.15)
                                    : cfg.appBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: !_horizontalSwipeMode
                                      ? cfg.borderAccent
                                      : cfg.borderAccent.withValues(alpha: 0.2),
                                  width: !_horizontalSwipeMode ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.swap_vert_rounded,
                                    size: 18,
                                    color: !_horizontalSwipeMode ? cfg.borderAccent : cfg.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    s.navVert,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: !_horizontalSwipeMode ? FontWeight.bold : FontWeight.normal,
                                      color: !_horizontalSwipeMode ? cfg.borderAccent : cfg.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              _toggleNavigationMode(true);
                              setModalState(() {});
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                color: _horizontalSwipeMode
                                    ? cfg.borderAccent.withValues(alpha: 0.15)
                                    : cfg.appBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _horizontalSwipeMode
                                      ? cfg.borderAccent
                                      : cfg.borderAccent.withValues(alpha: 0.2),
                                  width: _horizontalSwipeMode ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.swap_horiz_rounded,
                                    size: 18,
                                    color: _horizontalSwipeMode ? cfg.borderAccent : cfg.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    s.navHoriz,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: _horizontalSwipeMode ? FontWeight.bold : FontWeight.normal,
                                      color: _horizontalSwipeMode ? cfg.borderAccent : cfg.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // 2. Translation Toggle (الترجمة)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: cfg.appBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: cfg.borderAccent.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.translate_rounded, size: 18, color: cfg.borderAccent),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.readingTranslation,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: cfg.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    _showTranslation ? s.settingEnTransOn : s.settingEnTransOff,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: cfg.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Switch(
                            value: _showTranslation,
                            activeThumbColor: cfg.borderAccent,
                            onChanged: (val) {
                              setState(() => _showTranslation = val);
                              setModalState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 3. Font Size (حجم الخط)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.format_size_rounded, size: 18, color: cfg.borderAccent),
                            const SizedBox(width: 8),
                            Text(
                              s.readingFontSize,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: cfg.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: cfg.borderAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "${_arabicFontSize.toInt()} pt",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: cfg.borderAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline, color: cfg.borderAccent),
                          onPressed: _arabicFontSize > 20
                              ? () {
                                  setState(() {
                                    _arabicFontSize -= 2;
                                    _translationFontSize -= 1;
                                  });
                                  setModalState(() {});
                                }
                              : null,
                        ),
                        Expanded(
                          child: Slider(
                            value: _arabicFontSize,
                            min: 20.0,
                            max: 42.0,
                            divisions: 11,
                            activeColor: cfg.borderAccent,
                            inactiveColor: cfg.borderAccent.withValues(alpha: 0.2),
                            onChanged: (val) {
                              setState(() {
                                _arabicFontSize = val;
                                _translationFontSize = val * 0.55;
                              });
                              setModalState(() {});
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline, color: cfg.borderAccent),
                          onPressed: _arabicFontSize < 42
                              ? () {
                                  setState(() {
                                    _arabicFontSize += 2;
                                    _translationFontSize += 1;
                                  });
                                  setModalState(() {});
                                }
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // 4. View Mode (طريقة العرض)
                    Row(
                      children: [
                        Icon(Icons.auto_stories_outlined, size: 18, color: cfg.borderAccent),
                        const SizedBox(width: 8),
                        Text(
                          s.readingViewMode,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: cfg.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() => _isMushafView = true);
                              setModalState(() {});
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                color: _isMushafView
                                    ? cfg.borderAccent.withValues(alpha: 0.15)
                                    : cfg.appBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _isMushafView
                                      ? cfg.borderAccent
                                      : cfg.borderAccent.withValues(alpha: 0.2),
                                  width: _isMushafView ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.auto_stories_rounded,
                                    size: 18,
                                    color: _isMushafView ? cfg.borderAccent : cfg.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    s.tooltipMushafView,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: _isMushafView ? FontWeight.bold : FontWeight.normal,
                                      color: _isMushafView ? cfg.borderAccent : cfg.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() => _isMushafView = false);
                              setModalState(() {});
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                color: !_isMushafView
                                    ? cfg.borderAccent.withValues(alpha: 0.15)
                                    : cfg.appBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: !_isMushafView
                                      ? cfg.borderAccent
                                      : cfg.borderAccent.withValues(alpha: 0.2),
                                  width: !_isMushafView ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.view_agenda_outlined,
                                    size: 18,
                                    color: !_isMushafView ? cfg.borderAccent : cfg.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    s.tooltipListView,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: !_isMushafView ? FontWeight.bold : FontWeight.normal,
                                      color: !_isMushafView ? cfg.borderAccent : cfg.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
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
        title: GestureDetector(
          key: const ValueKey('surah_picker_title_button'),
          onTap: () => _showSurahPickerSheet(cfg),
          behavior: HitTestBehavior.opaque,
          child: ValueListenableBuilder<Surah>(
            valueListenable: _currentSurahNotifier,
            builder: (context, activeSurah, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          s.surahTitle(activeSurah.nameArabic, activeSurah.nameEnglish),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: cfg.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          s.versesInfo(activeSurah.revelationType, activeSurah.versesCount),
                          style: TextStyle(
                            fontSize: 11,
                            color: cfg.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: cfg.borderAccent,
                    size: 22,
                  ),
                ],
              );
            },
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: cfg.borderAccent,
            ),
            tooltip: s.readingSettingsTitle,
            onPressed: () => _showReadingSettingsSheet(cfg),
          ),
          const SizedBox(width: 4),
        ],
      ),

      body: FutureBuilder<Map<int, List<Ayah>>>(
        future: _surahsDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: cfg.borderAccent),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                s.errorLoadAyahs,
                style: TextStyle(color: cfg.textSecondary),
              ),
            );
          }

          final surahsMap = snapshot.data!;

          return _horizontalSwipeMode
              ? _buildHorizontalPageView(surahsMap, cfg)
              : _buildVerticalContinuousView(surahsMap, cfg);
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // 1. الوضع الأفقي (سحب أفقي بين الـ 604 صفحة كالمصحف الشريف)
  // ═══════════════════════════════════════════════════════════════════════════════

  Widget _buildHorizontalPageView(Map<int, List<Ayah>> surahsMap, ThemeConfig cfg) {
    final s = AppStrings.of(widget.isArabic);
    final int safeCurrentPage = _currentMushafPage.clamp(1, 604);

    return Column(
      children: [
        // Navigation bar with previous/next controls and page indicator
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: cfg.paperBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cfg.borderAccent.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Next Page (In RTL: Left arrow turns to next page N+1)
              IconButton(
                icon: Icon(
                  widget.isArabic ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                  color: safeCurrentPage < 604 ? cfg.borderAccent : cfg.borderAccent.withValues(alpha: 0.3),
                ),
                tooltip: widget.isArabic ? 'الصفحة التالية (سحب لليسار)' : 'Next Page (Swipe Left)',
                onPressed: safeCurrentPage < 604
                    ? () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
              ),

              // Page info badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: cfg.borderAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  s.pageOf(safeCurrentPage, QuranDataService.totalMushafPages),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: cfg.borderAccent,
                  ),
                ),
              ),

              // Previous Page (In RTL: Right arrow turns to previous page N-1)
              IconButton(
                icon: Icon(
                  widget.isArabic ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
                  color: safeCurrentPage > 1 ? cfg.borderAccent : cfg.borderAccent.withValues(alpha: 0.3),
                ),
                tooltip: widget.isArabic ? 'الصفحة السابقة (سحب لليمين)' : 'Previous Page (Swipe Right)',
                onPressed: safeCurrentPage > 1
                    ? () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
              ),
            ],
          ),
        ),

        // 604-page PageView with RTL support for natural swipe right / left
        Expanded(
          child: Directionality(
            textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: PageView.builder(
              controller: _pageController,
              physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
              onPageChanged: (index) async {
                final pageNum = (index + 1).clamp(1, 604);
                setState(() {
                  _currentMushafPage = pageNum;
                });
                final surah = await QuranDataService.getSurahForPage(pageNum);
                if (mounted) {
                  setState(() {
                    _currentSurah = surah;
                  });
                }
                _updateKhatmahPage(pageNum);
                _saveLastRead(1);
              },
              itemCount: 604,
              itemBuilder: (context, pageIdx) {
                final int mushafPage = pageIdx + 1;

                return FutureBuilder<List<Ayah>>(
                  future: QuranDataService.getPageAyahs(mushafPage),
                  builder: (context, pageSnap) {
                    if (!pageSnap.hasData || pageSnap.data!.isEmpty) {
                      return Center(child: CircularProgressIndicator(color: cfg.borderAccent));
                    }

                    final pageAyahs = pageSnap.data!;
                    final groupedBySurah = <int, List<Ayah>>{};
                    for (var a in pageAyahs) {
                      groupedBySurah.putIfAbsent(a.surahId, () => []).add(a);
                    }

                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        decoration: BoxDecoration(
                          color: cfg.paperBg,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: cfg.borderAccent,
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: cfg.isDark ? 0.3 : 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: groupedBySurah.entries.map((entry) {
                            final surahId = entry.key;
                            final surahAyahs = entry.value;
                            final surahObj = QuranDataService.allSurahs.firstWhere(
                              (s) => s.id == surahId,
                              orElse: () => QuranDataService.allSurahs[0],
                            );
                            final bool isFirstPageOfThisSurah = surahAyahs.any((a) => a.numberInSurah == 1);
                            final bool shouldShowBismillah = (surahId != 1 && surahId != 9);

                            return Column(
                              children: [
                                if (isFirstPageOfThisSurah) ...[
                                  Container(
                                    margin: const EdgeInsets.only(top: 8, bottom: 16),
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: cfg.bannerBg,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: cfg.borderAccent, width: 1.5),
                                    ),
                                    child: Text(
                                      "سُورَةُ ${surahObj.nameArabic}",
                                      style: AppTheme.getArabicTextStyle(
                                        fontFamily: widget.fontFamily,
                                        fontWeight: widget.fontWeight,
                                        fontSize: 24,
                                        color: cfg.bannerText,
                                      ),
                                    ),
                                  ),
                                  if (shouldShowBismillah)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 20),
                                      child: Text(
                                        "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
                                        style: AppTheme.getArabicTextStyle(
                                          fontFamily: widget.fontFamily,
                                          fontWeight: widget.fontWeight,
                                          fontSize: 28,
                                          color: cfg.borderAccent,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                ],

                                if (!_showTranslation) ...[
                                  Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: Text.rich(
                                      TextSpan(
                                        children: surahAyahs.expand((ayah) {
                                            return [
                                              TextSpan(
                                              text: "${ayah.arabicText} ",
                                              style: AppTheme.getArabicTextStyle(
                                                fontFamily: widget.fontFamily,
                                                fontWeight: widget.fontWeight,
                                                fontSize: _arabicFontSize,
                                                lineHeight: widget.lineHeight,
                                                color: cfg.textPrimary,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  _saveLastRead(ayah.numberInSurah);
                                                  _showAyahActionSheet(ayah, surahObj, cfg);
                                                },
                                            ),
                                            TextSpan(
                                              text: "﴿${_toArabicDigits(ayah.numberInSurah)}﴾ ",
                                              style: AppTheme.getArabicTextStyle(
                                                fontFamily: widget.fontFamily,
                                                fontWeight: widget.fontWeight,
                                                fontSize: _arabicFontSize * 0.85,
                                                color: cfg.borderAccent,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  _saveLastRead(ayah.numberInSurah);
                                                  _showAyahActionSheet(ayah, surahObj, cfg);
                                                },
                                            ),
                                          ];
                                        }).toList(),
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                ] else ...[
                                  Column(
                                    children: surahAyahs.map((ayah) {
                                      return GestureDetector(
                                        onTap: () {
                                          _saveLastRead(ayah.numberInSurah);
                                          _showAyahActionSheet(ayah, surahObj, cfg);
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: 14),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.transparent,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              Directionality(
                                                textDirection: TextDirection.rtl,
                                                child: Text(
                                                  "${ayah.arabicText} ﴿${_toArabicDigits(ayah.numberInSurah)}﴾",
                                                  style: AppTheme.getArabicTextStyle(
                                                    fontFamily: widget.fontFamily,
                                                    fontWeight: widget.fontWeight,
                                                    fontSize: _arabicFontSize,
                                                    lineHeight: widget.lineHeight,
                                                    color: cfg.textPrimary,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "${ayah.numberInSurah}. ${ayah.englishTranslation}",
                                                style: TextStyle(
                                                  fontSize: _translationFontSize,
                                                  color: cfg.textSecondary,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                                const SizedBox(height: 12),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // 2. الوضع الرأسي (تمرير رأسي متواصل ومستمر عبر جميع سور القرآن الـ 114)
  // ═══════════════════════════════════════════════════════════════════════════════

  Widget _buildVerticalContinuousView(Map<int, List<Ayah>> surahsMap, ThemeConfig cfg) {
    return ListView.builder(
      controller: _verticalScrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: 114,
      itemBuilder: (context, index) {
        final int surahId = index + 1;
        final Surah surah = QuranDataService.allSurahs.firstWhere(
          (s) => s.id == surahId,
          orElse: () => QuranDataService.allSurahs[0],
        );
        final List<Ayah> ayahs = surahsMap[surahId] ?? [];
        final bool shouldShowBismillah = (surahId != 1 && surahId != 9);

        return RepaintBoundary(
          key: _surahKeys[surahId],
          child: Container(
            margin: const EdgeInsets.only(bottom: 24.0),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: cfg.paperBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: cfg.borderAccent,
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: cfg.isDark ? 0.3 : 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Surah Banner
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: cfg.bannerBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cfg.borderAccent, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "سُورَةُ ${surah.nameArabic}",
                        style: AppTheme.getArabicTextStyle(
                          fontFamily: widget.fontFamily,
                          fontWeight: widget.fontWeight,
                          fontSize: 24,
                          color: cfg.bannerText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_showTranslation) ...[
                        const SizedBox(height: 4),
                        Text(
                          "${surah.nameEnglish} • ${surah.englishTranslation} (${surah.versesCount} verses)",
                          style: TextStyle(
                            fontSize: 12,
                            color: cfg.bannerText.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Bismillah Header
                if (shouldShowBismillah) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        Text(
                          "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
                          style: AppTheme.getArabicTextStyle(
                            fontFamily: widget.fontFamily,
                            fontWeight: widget.fontWeight,
                            fontSize: 28,
                            color: cfg.borderAccent,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_showTranslation) ...[
                          const SizedBox(height: 4),
                          Text(
                            "In the name of Allah, the Entirely Merciful, the Especially Merciful.",
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: cfg.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // ── Ayahs (Mushaf View vs List View)
                if (_isMushafView && !_showTranslation) ...[
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text.rich(
                      TextSpan(
                        children: ayahs.expand((ayah) {
                          return [
                            TextSpan(
                              text: "${ayah.arabicText} ",
                              style: AppTheme.getArabicTextStyle(
                                fontFamily: widget.fontFamily,
                                fontWeight: widget.fontWeight,
                                fontSize: _arabicFontSize,
                                lineHeight: widget.lineHeight,
                                color: cfg.textPrimary,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  _currentSurah = surah;
                                  _currentSurahNotifier.value = surah;
                                  _saveLastRead(ayah.numberInSurah);
                                  _updateKhatmahPage(ayah.page);
                                  _showAyahActionSheet(ayah, surah, cfg);
                                },
                            ),
                            TextSpan(
                              text: "﴿${_toArabicDigits(ayah.numberInSurah)}﴾ ",
                              style: AppTheme.getArabicTextStyle(
                                fontFamily: widget.fontFamily,
                                fontWeight: widget.fontWeight,
                                fontSize: _arabicFontSize * 0.85,
                                color: cfg.borderAccent,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  _currentSurah = surah;
                                  _currentSurahNotifier.value = surah;
                                  _saveLastRead(ayah.numberInSurah);
                                  _updateKhatmahPage(ayah.page);
                                  _showAyahActionSheet(ayah, surah, cfg);
                                },
                            ),
                          ];
                        }).toList(),
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ] else ...[
                  // List View / With Translation
                  Column(
                    children: ayahs.map((ayah) {
                      return GestureDetector(
                        onTap: () {
                          _currentSurah = surah;
                          _currentSurahNotifier.value = surah;
                          _saveLastRead(ayah.numberInSurah);
                          _updateKhatmahPage(ayah.page);
                          _showAyahActionSheet(ayah, surah, cfg);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: cfg.borderAccent.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: cfg.borderAccent.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "${surah.id}:${ayah.numberInSurah}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: cfg.borderAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Directionality(
                                textDirection: TextDirection.rtl,
                                child: Text(
                                  "${ayah.arabicText} ﴿${_toArabicDigits(ayah.numberInSurah)}﴾",
                                  style: AppTheme.getArabicTextStyle(
                                    fontFamily: widget.fontFamily,
                                    fontWeight: widget.fontWeight,
                                    fontSize: _arabicFontSize,
                                    lineHeight: widget.lineHeight,
                                    color: cfg.textPrimary,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              if (_showTranslation) ...[
                                const SizedBox(height: 6),
                                Text(
                                  "${ayah.numberInSurah}. ${ayah.englishTranslation}",
                                  style: TextStyle(
                                    fontSize: _translationFontSize,
                                    color: cfg.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }


}

// ═══════════════════════════════════════════════════════════════════════════════
// Surah Picker Sheet — searchable list of all 114 surahs
// ═══════════════════════════════════════════════════════════════════════════════

class _SurahPickerSheet extends StatefulWidget {
  final ThemeConfig cfg;
  final bool isArabic;
  final List<Surah> allSurahs;
  final int currentSurahId;
  final String searchHintText;
  final String titleText;
  final void Function(Surah) onSurahSelected;

  const _SurahPickerSheet({
    required this.cfg,
    required this.isArabic,
    required this.allSurahs,
    required this.currentSurahId,
    required this.searchHintText,
    required this.titleText,
    required this.onSurahSelected,
  });

  @override
  State<_SurahPickerSheet> createState() => _SurahPickerSheetState();
}

class _SurahPickerSheetState extends State<_SurahPickerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<Surah> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.allSurahs;
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = widget.allSurahs;
      } else {
        _filtered = widget.allSurahs.where((s) {
          final nameAr = s.nameArabic.toLowerCase();
          final nameEn = s.nameEnglish.toLowerCase();
          final numStr = s.id.toString();
          return nameAr.contains(q) || nameEn.contains(q) || numStr.contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cfg = widget.cfg;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: BoxDecoration(
            color: cfg.paperBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cfg.borderAccent.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.menu_book_rounded, color: cfg.borderAccent, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      widget.titleText,
                      style: TextStyle(
                        color: cfg.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: cfg.borderAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.allSurahs
                            .firstWhere((s) => s.id == widget.currentSurahId)
                            .nameArabic,
                        style: TextStyle(
                          color: cfg.borderAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
              ),
              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _searchCtrl,
                  textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
                  style: TextStyle(color: cfg.textPrimary, fontSize: 14),
                  cursorColor: cfg.borderAccent,
                  decoration: InputDecoration(
                    hintText: widget.searchHintText,
                    hintStyle: TextStyle(color: cfg.textSecondary, fontSize: 14),
                    hintTextDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
                    prefixIcon: Icon(Icons.search_rounded, color: cfg.borderAccent, size: 20),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded, color: cfg.textSecondary, size: 18),
                            onPressed: () => _searchCtrl.clear(),
                          )
                        : null,
                    filled: true,
                    fillColor: cfg.appBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: cfg.borderAccent, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Divider(height: 1, color: cfg.borderAccent.withValues(alpha: 0.15)),
              // Surah list
              Expanded(
                child: _filtered.isEmpty
                    ? Center(
                        child: Text(
                          widget.isArabic ? 'لا نتائج' : 'No results',
                          style: TextStyle(color: cfg.textSecondary, fontSize: 14),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final surah = _filtered[i];
                          final isCurrent = surah.id == widget.currentSurahId;

                          return InkWell(
                            onTap: () => widget.onSurahSelected(surah),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? cfg.borderAccent.withValues(alpha: 0.12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                                border: isCurrent
                                    ? Border.all(
                                        color: cfg.borderAccent.withValues(alpha: 0.4),
                                        width: 1)
                                    : null,
                              ),
                              child: Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  // Number circle
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isCurrent
                                          ? cfg.borderAccent
                                          : cfg.borderAccent.withValues(alpha: 0.1),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${surah.id}',
                                      style: TextStyle(
                                        color: isCurrent ? cfg.playButtonIcon : cfg.borderAccent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Names
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          surah.nameArabic,
                                          style: TextStyle(
                                            color: isCurrent
                                                ? cfg.borderAccent
                                                : cfg.textPrimary,
                                            fontSize: 15,
                                            fontWeight: isCurrent
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                          ),
                                          textDirection: TextDirection.rtl,
                                        ),
                                        Text(
                                          surah.nameEnglish,
                                          style: TextStyle(
                                            color: cfg.textSecondary,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Verse count badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: cfg.borderAccent.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      widget.isArabic
                                          ? '${surah.versesCount} آية'
                                          : '${surah.versesCount} v.',
                                      style: TextStyle(
                                        color: cfg.borderAccent,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (isCurrent) ...[
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: cfg.borderAccent,
                                      size: 18,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}