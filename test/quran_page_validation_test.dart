import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:quraan/services/quran_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Medina Mushaf (604 Pages) Full Quran & Page Mapping Verification', () {
    late List<dynamic> surahsList;
    late Map<int, List<Map<String, dynamic>>> pageToAyahs;
    late Map<String, int> ayahToPageMap;
    int totalVerses = 0;

    setUpAll(() {
      final file = File('assets/data/quran_cleaned.json');
      expect(file.existsSync(), isTrue, reason: 'assets/data/quran_cleaned.json must exist');

      final content = file.readAsStringSync();
      surahsList = jsonDecode(content);
      pageToAyahs = {};
      ayahToPageMap = {};

      for (var s in surahsList) {
        int surahId = s['id'];
        String surahName = s['nameArabic'];
        List ayahs = s['ayahs'];
        totalVerses += ayahs.length;

        for (var a in ayahs) {
          int ayahNum = a['numberInSurah'];
          int pageNum = a['page'];
          int juzNum = a['juz'];

          pageToAyahs.putIfAbsent(pageNum, () => []).add({
            'surahId': surahId,
            'surahName': surahName,
            'numberInSurah': ayahNum,
            'juz': juzNum,
            'page': pageNum,
            'arabicText': a['arabicText'],
          });

          ayahToPageMap['$surahId:$ayahNum'] = pageNum;
        }
      }
    });

    test('1. Total Surahs must be exactly 114', () {
      expect(surahsList.length, equals(114));
      expect(QuranDataService.allSurahs.length, equals(114));
    });

    test('2. Total Ayahs must be exactly 6,236', () {
      expect(totalVerses, equals(6236));
    });

    test('3. Total distinct pages must be exactly 604 (1 to 604)', () {
      expect(pageToAyahs.keys.length, equals(604));
      expect(QuranDataService.totalMushafPages, equals(604));

      for (int p = 1; p <= 604; p++) {
        expect(pageToAyahs.containsKey(p), isTrue, reason: 'Page $p must exist');
        expect(pageToAyahs[p]!.isNotEmpty, isTrue, reason: 'Page $p must contain verses');
      }
    });

    test('4. Sequential continuity across all 604 pages (No gaps, no duplicates, no off-by-one errors)', () {
      int expectedSurah = 1;
      int expectedAyah = 1;

      for (int p = 1; p <= 604; p++) {
        final versesOnPage = pageToAyahs[p]!;
        for (var v in versesOnPage) {
          int sId = v['surahId'];
          int aNum = v['numberInSurah'];

          expect(sId, equals(expectedSurah),
              reason: 'Page $p expected Surah $expectedSurah but found Surah $sId');
          expect(aNum, equals(expectedAyah),
              reason: 'Page $p expected Ayah $expectedAyah of Surah $sId but found Ayah $aNum');

          final currentSurahObj = surahsList[expectedSurah - 1];
          final int surahVersesCount = (currentSurahObj['ayahs'] as List).length;

          if (expectedAyah < surahVersesCount) {
            expectedAyah++;
          } else {
            expectedSurah++;
            expectedAyah = 1;
          }
        }
      }

      expect(expectedSurah, equals(115), reason: 'All 114 Surahs must be fully visited');
    });

    test('5. Verify Page 1 (Al-Fatihah 1:1 to 1:7)', () {
      final p1 = pageToAyahs[1]!;
      expect(p1.length, equals(7));
      expect(p1.first['surahId'], equals(1));
      expect(p1.first['numberInSurah'], equals(1));
      expect(p1.last['surahId'], equals(1));
      expect(p1.last['numberInSurah'], equals(7));
    });

    test('6. Verify Page 2 (Al-Baqarah 2:1 to 2:5)', () {
      final p2 = pageToAyahs[2]!;
      expect(p2.length, equals(5));
      expect(p2.first['surahId'], equals(2));
      expect(p2.first['numberInSurah'], equals(1));
      expect(p2.last['surahId'], equals(2));
      expect(p2.last['numberInSurah'], equals(5));
    });

    test('7. Verify Page 3 (Al-Baqarah 2:6 to 2:16)', () {
      final p3 = pageToAyahs[3]!;
      expect(p3.length, equals(11));
      expect(p3.first['surahId'], equals(2));
      expect(p3.first['numberInSurah'], equals(6));
      expect(p3.last['surahId'], equals(2));
      expect(p3.last['numberInSurah'], equals(16));
    });

    test('8. Verify Page 49 to 50 transition (End of Al-Baqarah 2:286 -> Start of Ali Imran 3:1)', () {
      final p49 = pageToAyahs[49]!;
      expect(p49.last['surahId'], equals(2));
      expect(p49.last['numberInSurah'], equals(286));

      final p50 = pageToAyahs[50]!;
      expect(p50.first['surahId'], equals(3));
      expect(p50.first['numberInSurah'], equals(1));
    });

    test('9. Verify Page 604 (Surah 112:1 to Surah 114:6)', () {
      final p604 = pageToAyahs[604]!;
      expect(p604.length, equals(15)); // 4 (112) + 5 (113) + 6 (114)

      final surahsOn604 = p604.map((a) => a['surahId']).toSet();
      expect(surahsOn604, equals({112, 113, 114}));

      expect(p604.first['surahId'], equals(112));
      expect(p604.first['numberInSurah'], equals(1));

      expect(p604.last['surahId'], equals(114));
      expect(p604.last['numberInSurah'], equals(6));
    });

    test('10. Verify all 30 Juz start pages match Medina Mushaf standard', () {
      expect(QuranDataService.juzStartPages.length, equals(30));

      for (int j = 1; j <= 30; j++) {
        int expectedStartPage = QuranDataService.getJuzStartPage(j);
        final versesOnPage = pageToAyahs[expectedStartPage]!;
        expect(versesOnPage.any((v) => v['juz'] == j), isTrue,
            reason: 'Page $expectedStartPage must contain verses of Juz $j');
      }
    });

    test('11. Verify quran_uthmani.json matches quran_cleaned.json 100%', () {
      final uthmaniFile = File('assets/data/quran_uthmani.json');
      expect(uthmaniFile.existsSync(), isTrue);

      final uthmaniRaw = jsonDecode(uthmaniFile.readAsStringSync());
      final List uthmaniSurahs = uthmaniRaw['data']['surahs'];
      expect(uthmaniSurahs.length, equals(114));

      for (int s = 0; s < 114; s++) {
        final cSurah = surahsList[s];
        final uSurah = uthmaniSurahs[s];
        final List cAyahs = cSurah['ayahs'];
        final List uAyahs = uSurah['ayahs'];

        expect(cAyahs.length, equals(uAyahs.length),
            reason: 'Surah ${s + 1} ayah count must match');

        for (int a = 0; a < cAyahs.length; a++) {
          expect(cAyahs[a]['page'], equals(uAyahs[a]['page']),
              reason: 'Surah ${s + 1}:${a + 1} page must match');
          expect(cAyahs[a]['juz'], equals(uAyahs[a]['juz']),
              reason: 'Surah ${s + 1}:${a + 1} juz must match');
        }
      }
    });
  });
}
