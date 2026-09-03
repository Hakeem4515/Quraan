import 'package:flutter/material.dart';
import '../services/quran_data.dart';
import '../theme/app_theme.dart';
import '../l10n/app_strings.dart';
import 'surah_detail_screen.dart';

class JuzScreen extends StatelessWidget {
  final QuranThemeMode themeMode;
  final bool isDualLanguage;
  final bool isHorizontalSwipe;
  final ArabicFontFamily fontFamily;
  final ArabicFontWeightOption fontWeight;
  final double fontSize;
  final double lineHeight;
  final bool isArabic;

  const JuzScreen({
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

  static final List<Map<String, dynamic>> juzList = [
    {'juzNumber': 1, 'surahId': 1, 'surahNameAr': 'الفاتحة', 'surahNameEn': 'Al-Fatihah', 'startAyah': 1, 'startVerse': 'Al-Fatihah 1:1', 'startVerseAr': 'الفاتحة ١:١', 'startPage': 1},
    {'juzNumber': 2, 'surahId': 2, 'surahNameAr': 'البقرة', 'surahNameEn': 'Al-Baqarah', 'startAyah': 142, 'startVerse': 'Al-Baqarah 2:142', 'startVerseAr': 'البقرة ٢:١٤٢', 'startPage': 22},
    {'juzNumber': 3, 'surahId': 2, 'surahNameAr': 'البقرة', 'surahNameEn': 'Al-Baqarah', 'startAyah': 253, 'startVerse': 'Al-Baqarah 2:253', 'startVerseAr': 'البقرة ٢:٢٥٣', 'startPage': 42},
    {'juzNumber': 4, 'surahId': 3, 'surahNameAr': 'آل عمران', 'surahNameEn': "Ali 'Imran", 'startAyah': 93, 'startVerse': "Ali 'Imran 3:93", 'startVerseAr': 'آل عمران ٣:٩٣', 'startPage': 62},
    {'juzNumber': 5, 'surahId': 4, 'surahNameAr': 'النساء', 'surahNameEn': 'An-Nisa', 'startAyah': 24, 'startVerse': 'An-Nisa 4:24', 'startVerseAr': 'النساء ٤:٢٤', 'startPage': 82},
    {'juzNumber': 6, 'surahId': 4, 'surahNameAr': 'النساء', 'surahNameEn': 'An-Nisa', 'startAyah': 148, 'startVerse': 'An-Nisa 4:148', 'startVerseAr': 'النساء ٤:١٤٨', 'startPage': 102},
    {'juzNumber': 7, 'surahId': 5, 'surahNameAr': 'المائدة', 'surahNameEn': "Al-Ma'idah", 'startAyah': 82, 'startVerse': "Al-Ma'idah 5:82", 'startVerseAr': 'المائدة ٥:٨٢', 'startPage': 121},
    {'juzNumber': 8, 'surahId': 6, 'surahNameAr': 'الأنعام', 'surahNameEn': "Al-An'am", 'startAyah': 111, 'startVerse': "Al-An'am 6:111", 'startVerseAr': 'الأنعام ٦:١١١', 'startPage': 142},
    {'juzNumber': 9, 'surahId': 7, 'surahNameAr': 'الأعراف', 'surahNameEn': "Al-A'raf", 'startAyah': 88, 'startVerse': "Al-A'raf 7:88", 'startVerseAr': 'الأعراف ٧:٨٨', 'startPage': 162},
    {'juzNumber': 10, 'surahId': 8, 'surahNameAr': 'الأنفال', 'surahNameEn': 'Al-Anfal', 'startAyah': 41, 'startVerse': 'Al-Anfal 8:41', 'startVerseAr': 'الأنفال ٨:٤١', 'startPage': 182},
    {'juzNumber': 11, 'surahId': 9, 'surahNameAr': 'التوبة', 'surahNameEn': 'At-Tawbah', 'startAyah': 93, 'startVerse': 'At-Tawbah 9:93', 'startVerseAr': 'التوبة ٩:٩٣', 'startPage': 201},
    {'juzNumber': 12, 'surahId': 11, 'surahNameAr': 'هود', 'surahNameEn': 'Hud', 'startAyah': 6, 'startVerse': 'Hud 11:6', 'startVerseAr': 'هود ١١:٦', 'startPage': 222},
    {'juzNumber': 13, 'surahId': 12, 'surahNameAr': 'يوسف', 'surahNameEn': 'Yusuf', 'startAyah': 53, 'startVerse': 'Yusuf 12:53', 'startVerseAr': 'يوسف ١٢:٥٣', 'startPage': 242},
    {'juzNumber': 14, 'surahId': 15, 'surahNameAr': 'الحجر', 'surahNameEn': 'Al-Hijr', 'startAyah': 1, 'startVerse': 'Al-Hijr 15:1', 'startVerseAr': 'الحجر ١٥:١', 'startPage': 262},
    {'juzNumber': 15, 'surahId': 17, 'surahNameAr': 'الإسراء', 'surahNameEn': 'Al-Isra', 'startAyah': 1, 'startVerse': 'Al-Isra 17:1', 'startVerseAr': 'الإسراء ١٧:١', 'startPage': 282},
    {'juzNumber': 16, 'surahId': 18, 'surahNameAr': 'الكهف', 'surahNameEn': 'Al-Kahf', 'startAyah': 75, 'startVerse': 'Al-Kahf 18:75', 'startVerseAr': 'الكهف ١٨:٧٥', 'startPage': 302},
    {'juzNumber': 17, 'surahId': 21, 'surahNameAr': 'الأنبياء', 'surahNameEn': 'Al-Anbiya', 'startAyah': 1, 'startVerse': 'Al-Anbiya 21:1', 'startVerseAr': 'الأنبياء ٢١:١', 'startPage': 322},
    {'juzNumber': 18, 'surahId': 23, 'surahNameAr': 'المؤمنون', 'surahNameEn': "Al-Mu'minun", 'startAyah': 1, 'startVerse': "Al-Mu'minun 23:1", 'startVerseAr': 'المؤمنون ٢٣:١', 'startPage': 342},
    {'juzNumber': 19, 'surahId': 25, 'surahNameAr': 'الفرقان', 'surahNameEn': 'Al-Furqan', 'startAyah': 21, 'startVerse': 'Al-Furqan 25:21', 'startVerseAr': 'الفرقان ٢٥:٢١', 'startPage': 362},
    {'juzNumber': 20, 'surahId': 27, 'surahNameAr': 'النمل', 'surahNameEn': 'An-Naml', 'startAyah': 56, 'startVerse': 'An-Naml 27:56', 'startVerseAr': 'النمل ٢٧:٥٦', 'startPage': 382},
    {'juzNumber': 21, 'surahId': 29, 'surahNameAr': 'العنكبوت', 'surahNameEn': 'Al-Ankabut', 'startAyah': 46, 'startVerse': 'Al-Ankabut 29:46', 'startVerseAr': 'العنكبوت ٢٩:٤٦', 'startPage': 402},
    {'juzNumber': 22, 'surahId': 33, 'surahNameAr': 'الأحزاب', 'surahNameEn': 'Al-Ahzab', 'startAyah': 31, 'startVerse': 'Al-Ahzab 33:31', 'startVerseAr': 'الأحزاب ٣٣:٣١', 'startPage': 422},
    {'juzNumber': 23, 'surahId': 36, 'surahNameAr': 'يس', 'surahNameEn': 'Ya-Sin', 'startAyah': 28, 'startVerse': 'Ya-Sin 36:28', 'startVerseAr': 'يس ٣٦:٢٨', 'startPage': 442},
    {'juzNumber': 24, 'surahId': 39, 'surahNameAr': 'الزمر', 'surahNameEn': 'Az-Zumar', 'startAyah': 32, 'startVerse': 'Az-Zumar 39:32', 'startVerseAr': 'الزمر ٣٩:٣٢', 'startPage': 462},
    {'juzNumber': 25, 'surahId': 41, 'surahNameAr': 'فصلت', 'surahNameEn': 'Fussilat', 'startAyah': 47, 'startVerse': 'Fussilat 41:47', 'startVerseAr': 'فصلت ٤١:٤٧', 'startPage': 482},
    {'juzNumber': 26, 'surahId': 46, 'surahNameAr': 'الأحقاف', 'surahNameEn': 'Al-Ahqaf', 'startAyah': 1, 'startVerse': 'Al-Ahqaf 46:1', 'startVerseAr': 'الأحقاف ٤٦:١', 'startPage': 502},
    {'juzNumber': 27, 'surahId': 51, 'surahNameAr': 'الذاريات', 'surahNameEn': 'Adh-Dhariyat', 'startAyah': 31, 'startVerse': 'Adh-Dhariyat 51:31', 'startVerseAr': 'الذاريات ٥١:٣١', 'startPage': 522},
    {'juzNumber': 28, 'surahId': 58, 'surahNameAr': 'المجادلة', 'surahNameEn': 'Al-Mujadila', 'startAyah': 1, 'startVerse': 'Al-Mujadila 58:1', 'startVerseAr': 'المجادلة ٥٨:١', 'startPage': 542},
    {'juzNumber': 29, 'surahId': 67, 'surahNameAr': 'الملك', 'surahNameEn': 'Al-Mulk', 'startAyah': 1, 'startVerse': 'Al-Mulk 67:1', 'startVerseAr': 'الملك ٦٧:١', 'startPage': 562},
    {'juzNumber': 30, 'surahId': 78, 'surahNameAr': 'النبإ', 'surahNameEn': 'An-Naba', 'startAyah': 1, 'startVerse': 'An-Naba 78:1', 'startVerseAr': 'النبإ ٧٨:١', 'startPage': 582},
  ];

  @override
  Widget build(BuildContext context) {
    final cfg = AppTheme.getConfig(themeMode);
    final s = AppStrings.of(isArabic);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.juzScreenTitle),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.22,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: juzList.length,
        itemBuilder: (context, index) {
          final item = juzList[index];
          final juzNum = item['juzNumber'] as int;
          final int surahId = item['surahId'] as int;
          final int startAyah = item['startAyah'] as int;
          final int startPage = item['startPage'] as int;
          final surah = QuranDataService.allSurahs.firstWhere(
            (sv) => sv.id == surahId,
            orElse: () => QuranDataService.allSurahs[0],
          );

          return Container(
            decoration: BoxDecoration(
              color: cfg.paperBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cfg.borderAccent.withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: cfg.isDark ? 0.2 : 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SurahDetailScreen(
                      surah: surah,
                      initialAyah: startAyah,
                      themeMode: themeMode,
                      isDualLanguage: isDualLanguage,
                      isHorizontalSwipe: isHorizontalSwipe,
                      fontFamily: fontFamily,
                      fontWeight: fontWeight,
                      fontSize: fontSize,
                      lineHeight: lineHeight,
                      isArabic: isArabic,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: cfg.borderAccent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            s.juzNumber(juzNum),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: cfg.borderAccent,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: cfg.borderAccent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isArabic ? 'ص $startPage' : 'p. $startPage',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: cfg.borderAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.juzStartAt,
                          style: TextStyle(fontSize: 11, color: cfg.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isArabic ? (item['startVerseAr'] as String) : (item['startVerse'] as String),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: cfg.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
