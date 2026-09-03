import 'package:flutter/material.dart';
import '../services/quran_data.dart';
import '../theme/app_theme.dart';
import '../l10n/app_strings.dart';
import '../screens/surah_detail_screen.dart';

class HeroLastReadCard extends StatefulWidget {
  final QuranThemeMode themeMode;
  final bool isDualLanguage;
  final bool isHorizontalSwipe;
  final ArabicFontFamily fontFamily;
  final ArabicFontWeightOption fontWeight;
  final double fontSize;
  final double lineHeight;
  final bool isArabic;

  const HeroLastReadCard({
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
  State<HeroLastReadCard> createState() => _HeroLastReadCardState();
}

class _HeroLastReadCardState extends State<HeroLastReadCard> {
  int _surahId = 1;
  int _ayahNumber = 1;
  String _surahName = "Al-Fatihah";

  @override
  void initState() {
    super.initState();
    _loadLastRead();
  }

  Future<void> _loadLastRead() async {
    final lastRead = await QuranDataService.getLastRead();
    if (mounted) {
      setState(() {
        _surahId = lastRead['surahId'];
        _ayahNumber = lastRead['ayahNumber'];
        _surahName = lastRead['surahName'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cfg = AppTheme.getConfig(widget.themeMode);
    final s = AppStrings.of(widget.isArabic);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [cfg.bannerBg, cfg.appBg],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: cfg.borderAccent.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: cfg.borderAccent.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.menu_book_rounded,
              size: 160,
              color: cfg.borderAccent.withValues(alpha: 0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bookmark_border_rounded, color: cfg.borderAccent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      s.lastRead,
                      style: TextStyle(
                        color: cfg.borderAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _surahName,
                  style: TextStyle(
                    color: cfg.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.ayahNum(_ayahNumber),
                  style: TextStyle(color: cfg.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: () {
                    final surah = QuranDataService.allSurahs.firstWhere(
                      (sv) => sv.id == _surahId,
                      orElse: () => QuranDataService.allSurahs[0],
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SurahDetailScreen(
                          surah: surah,
                          initialAyah: _ayahNumber,
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
                    ).then((_) => _loadLastRead());
                  },
                  icon: Icon(Icons.arrow_forward_rounded, size: 18, color: cfg.playButtonIcon),
                  label: Text(
                    s.continueRead,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cfg.playButtonBg,
                    foregroundColor: cfg.playButtonIcon,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
