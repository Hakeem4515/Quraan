import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Verify quran_cleaned.json 604 pages mapping and structure', () {
    final file = File('assets/data/quran_cleaned.json');
    expect(file.existsSync(), isTrue);

    final content = file.readAsStringSync();
    final List<dynamic> surahs = jsonDecode(content);

    expect(surahs.length, equals(114));

    int totalAyahs = 0;
    final Map<int, List<Map<String, dynamic>>> pageMap = {};
    final Map<String, int> ayahToPage = {};

    for (var s in surahs) {
      final int surahId = s['id'];
      final List<dynamic> ayahs = s['ayahs'];
      totalAyahs += ayahs.length;

      for (var a in ayahs) {
        final int ayahNum = a['numberInSurah'];
        final int page = a['page'];
        final int juz = a['juz'];

        expect(page, greaterThanOrEqualTo(1));
        expect(page, lessThanOrEqualTo(604));
        expect(juz, greaterThanOrEqualTo(1));
        expect(juz, lessThanOrEqualTo(30));

        pageMap.putIfAbsent(page, () => []).add({
          'surahId': surahId,
          'surahName': s['nameArabic'],
          'ayah': ayahNum,
          'juz': juz,
          'text': a['arabicText'],
        });

        ayahToPage['$surahId:$ayahNum'] = page;
      }
    }

    expect(totalAyahs, equals(6236));
    expect(pageMap.keys.length, equals(604));

    // Test specific key pages as requested by user
    // Page 1: Surah 1 (1-7)
    final p1 = pageMap[1]!;
    expect(p1.first['surahId'], equals(1));
    expect(p1.first['ayah'], equals(1));
    expect(p1.last['surahId'], equals(1));
    expect(p1.last['ayah'], equals(7));

    // Page 2: Surah 2 (1-5)
    final p2 = pageMap[2]!;
    expect(p2.first['surahId'], equals(2));
    expect(p2.first['ayah'], equals(1));
    expect(p2.last['surahId'], equals(2));
    expect(p2.last['ayah'], equals(5));

    // Page 3: Surah 2 (6-16)
    final p3 = pageMap[3]!;
    expect(p3.first['surahId'], equals(2));
    expect(p3.first['ayah'], equals(6));
    expect(p3.last['surahId'], equals(2));
    expect(p3.last['ayah'], equals(16));

    // Page 42: Surah 2 (253-256)
    final p42 = pageMap[42]!;
    expect(p42.first['surahId'], equals(2));
    expect(p42.first['ayah'], equals(253));

    // Page 50: Surah 3 (1-9) - Start of Ali 'Imran
    final p50 = pageMap[50]!;
    expect(p50.first['surahId'], equals(3));
    expect(p50.first['ayah'], equals(1));

    // Page 604: Surah 112 (1-4), Surah 113 (1-5), Surah 114 (1-6)
    final p604 = pageMap[604]!;
    final p604Surahs = p604.map((a) => a['surahId']).toSet();
    expect(p604Surahs, containsAll([112, 113, 114]));
    expect(p604.last['surahId'], equals(114));
    expect(p604.last['ayah'], equals(6));
  });
}

