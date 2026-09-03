import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Verify all 604 pages integrity and completeness', () {
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

        expect(page >= 1 && page <= 604, isTrue);
        expect(juz >= 1 && juz <= 30, isTrue);

        pageMap.putIfAbsent(page, () => []).add({
          'surahId': surahId,
          'surahName': s['nameArabic'],
          'ayah': ayahNum,
          'juz': juz,
        });

        ayahToPage['$surahId:$ayahNum'] = page;
      }
    }

    expect(totalAyahs, equals(6236));
    expect(pageMap.keys.length, equals(604));

    for (int p = 1; p <= 604; p++) {
      expect(pageMap.containsKey(p), isTrue);
      expect(pageMap[p]!.isNotEmpty, isTrue);
    }
  });
}

