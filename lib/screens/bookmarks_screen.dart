import 'package:flutter/material.dart';
import '../models/surah.dart';
import '../services/quran_data.dart';
import '../theme/app_theme.dart';
import '../l10n/app_strings.dart';
import 'surah_detail_screen.dart';

class BookmarksScreen extends StatefulWidget {
  final QuranThemeMode themeMode;
  final bool isDualLanguage;
  final bool isHorizontalSwipe;
  final ArabicFontFamily fontFamily;
  final ArabicFontWeightOption fontWeight;
  final double fontSize;
  final double lineHeight;
  final bool isArabic;

  const BookmarksScreen({
    super.key,
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
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Map<String, dynamic>> _bookmarkedItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() => _isLoading = true);
    final rawBookmarks = await QuranDataService.getBookmarks();

    List<Map<String, dynamic>> items = [];
    for (String b in rawBookmarks) {
      final parts = b.split(":");
      if (parts.length == 2) {
        int surahId = int.parse(parts[0]);
        int ayahNum = int.parse(parts[1]);
        final surah = QuranDataService.allSurahs.firstWhere(
          (sv) => sv.id == surahId,
          orElse: () => QuranDataService.allSurahs[0],
        );
        items.add({'surah': surah, 'ayahNumber': ayahNum});
      }
    }

    if (mounted) {
      setState(() {
        _bookmarkedItems = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _removeBookmark(int surahId, int ayahNumber) async {
    await QuranDataService.toggleBookmark(surahId, ayahNumber);
    _loadBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = AppTheme.getConfig(widget.themeMode);
    final s = AppStrings.of(widget.isArabic);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.bookmarksTitle),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: cfg.borderAccent))
          : _bookmarkedItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border_rounded,
                        size: 80,
                        color: cfg.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        s.bookmarksEmpty,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: cfg.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          s.bookmarksEmptySub,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: cfg.textSecondary, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _bookmarkedItems.length,
                  itemBuilder: (context, index) {
                    final item = _bookmarkedItems[index];
                    final Surah surah = item['surah'];
                    final int ayahNum = item['ayahNumber'];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: cfg.paperBg,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: cfg.borderAccent.withValues(alpha: 0.25)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: cfg.borderAccent.withValues(alpha: 0.12),
                            ),
                            child: Center(
                              child: Icon(Icons.bookmark_rounded, color: cfg.borderAccent, size: 20),
                            ),
                          ),
                          title: Text(
                            widget.isArabic
                                ? '${surah.nameArabic} (${surah.nameEnglish}) • ${s.ayahLabel(ayahNum)}'
                                : '${surah.nameEnglish} (${surah.nameArabic}) • ${s.ayahLabel(ayahNum)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: cfg.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            surah.englishTranslation,
                            style: TextStyle(color: cfg.textSecondary),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                            onPressed: () => _removeBookmark(surah.id, ayahNum),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SurahDetailScreen(
                                  surah: surah,
                                  initialAyah: ayahNum,
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
                            ).then((_) => _loadBookmarks());
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}