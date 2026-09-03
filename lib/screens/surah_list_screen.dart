import 'package:flutter/material.dart';
import '../models/surah.dart';
import '../services/quran_data.dart';
import '../theme/app_theme.dart';
import '../l10n/app_strings.dart';
import '../widgets/hero_last_read_card.dart';
import '../widgets/surah_card.dart';
import '../widgets/khatmah_card.dart';
import 'surah_detail_screen.dart';

class SurahListScreen extends StatefulWidget {
  final QuranThemeMode themeMode;
  final bool isDualLanguage;
  final bool isHorizontalSwipe;
  final ArabicFontFamily fontFamily;
  final ArabicFontWeightOption fontWeight;
  final double fontSize;
  final double lineHeight;
  final bool isArabic;

  const SurahListScreen({
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
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Surah> _filteredSurahs = QuranDataService.allSurahs;
  String _selectedFilter = "All"; // "All", "Meccan", "Medinan"

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilter);
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredSurahs = QuranDataService.allSurahs.where((surah) {
        final matchesQuery = surah.nameEnglish.toLowerCase().contains(query) ||
            surah.nameArabic.contains(query) ||
            surah.englishTranslation.toLowerCase().contains(query) ||
            surah.id.toString() == query;

        if (_selectedFilter == "Meccan") {
          return matchesQuery && surah.revelationType == "Meccan";
        } else if (_selectedFilter == "Medinan") {
          return matchesQuery && surah.revelationType == "Medinan";
        }
        return matchesQuery;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = AppTheme.getConfig(widget.themeMode);
    final s = AppStrings.of(widget.isArabic);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 110.0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
              title: Row(
                children: [
                  Icon(Icons.star_half_rounded, color: cfg.borderAccent, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    s.appTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: cfg.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: cfg.textPrimary),
                    decoration: InputDecoration(
                      hintText: s.searchHint,
                      hintStyle: TextStyle(color: cfg.textSecondary),
                      prefixIcon: Icon(Icons.search_rounded, color: cfg.borderAccent),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear_rounded, color: cfg.textSecondary),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      filled: true,
                      fillColor: cfg.paperBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: cfg.borderAccent.withValues(alpha: 0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: cfg.borderAccent.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: cfg.borderAccent, width: 1.5),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      _filterChip("All", s.filterAll, cfg, s),
                      const SizedBox(width: 8),
                      _filterChip("Meccan", s.filterMeccan, cfg, s),
                      const SizedBox(width: 8),
                      _filterChip("Medinan", s.filterMedian, cfg, s),
                    ],
                  ),
                ),
                if (_searchController.text.isEmpty && _selectedFilter == "All")
                  HeroLastReadCard(
                    themeMode: widget.themeMode,
                    isDualLanguage: widget.isDualLanguage,
                    isHorizontalSwipe: widget.isHorizontalSwipe,
                    fontFamily: widget.fontFamily,
                    fontWeight: widget.fontWeight,
                    fontSize: widget.fontSize,
                    lineHeight: widget.lineHeight,
                    isArabic: widget.isArabic,
                  ),
                if (_searchController.text.isEmpty && _selectedFilter == "All")
                  KhatmahCard(
                    themeMode: widget.themeMode,
                    isDualLanguage: widget.isDualLanguage,
                    isHorizontalSwipe: widget.isHorizontalSwipe,
                    fontFamily: widget.fontFamily,
                    fontWeight: widget.fontWeight,
                    fontSize: widget.fontSize,
                    lineHeight: widget.lineHeight,
                    isArabic: widget.isArabic,
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final surah = _filteredSurahs[index];
                return SurahCard(
                  surah: surah,
                  themeMode: widget.themeMode,
                  fontFamily: widget.fontFamily,
                  fontWeight: widget.fontWeight,
                  isArabic: widget.isArabic,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SurahDetailScreen(
                          surah: surah,
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
                    );
                  },
                );
              },
              childCount: _filteredSurahs.length,
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }

  Widget _filterChip(String value, String label, ThemeConfig cfg, AppStrings s) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = value;
            _applyFilter();
          });
        }
      },
      backgroundColor: cfg.paperBg,
      selectedColor: cfg.borderAccent.withValues(alpha: 0.2),
      checkmarkColor: cfg.borderAccent,
      labelStyle: TextStyle(
        color: isSelected ? cfg.borderAccent : cfg.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? cfg.borderAccent : cfg.borderAccent.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}
