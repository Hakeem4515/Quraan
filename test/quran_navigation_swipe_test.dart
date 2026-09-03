import 'package:flutter_test/flutter_test.dart';
import 'package:quraan/models/khatmah.dart';
import 'package:quraan/services/khatmah_service.dart';
import 'package:quraan/services/quran_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    KhatmahService.resetForTesting();
  });

  group('Quran Navigation (Vertical Continuous & Horizontal 604 Pages)', () {
    test('Page clamping respects Medina Mushaf boundary 1 to 604', () {
      int clampPage(int page) => page.clamp(1, 604);

      expect(clampPage(0), 1);
      expect(clampPage(-5), 1);
      expect(clampPage(1), 1);
      expect(clampPage(100), 100);
      expect(clampPage(604), 604);
      expect(clampPage(605), 604);
      expect(clampPage(999), 604);
    });

    test('Bismillah visibility rules for Surahs', () {
      bool shouldShowBismillah(int surahId) => (surahId != 1 && surahId != 9);

      // Surah 1 (Al-Fatihah) -> No separate Bismillah header (Ayah 1 is Bismillah)
      expect(shouldShowBismillah(1), isFalse);

      // Surah 2 (Al-Baqarah) -> Shows Bismillah header on page 1
      expect(shouldShowBismillah(2), isTrue);

      // Surah 9 (At-Tawbah) -> No Bismillah
      expect(shouldShowBismillah(9), isFalse);

      // Surah 114 (An-Nas) -> Shows Bismillah header
      expect(shouldShowBismillah(114), isTrue);
    });

    test('Horizontal swipe navigation updates Khatmah progress correctly', () async {
      // Start a Khatmah
      final khatmah = await KhatmahService.startNewKhatmah();
      expect(khatmah.currentPage, 1);
      expect(khatmah.progress, closeTo(1 / 604 * 100, 0.1));

      // User swipes Right-to-Left: Page 1 -> Page 2
      await KhatmahService.updateProgress(2);
      var active = await KhatmahService.getActiveKhatmah();
      expect(active?.currentPage, 2);

      // User swipes Right-to-Left: Page 100 -> Page 101
      await KhatmahService.updateProgress(101);
      active = await KhatmahService.getActiveKhatmah();
      expect(active?.currentPage, 101);
      expect(active?.progress, closeTo(101 / 604 * 100, 0.1));

      // User swipes Left-to-Right: Page 101 -> Page 100
      await KhatmahService.updateProgress(100);
      active = await KhatmahService.getActiveKhatmah();
      expect(active?.currentPage, 100);

      // Swiping to page 604 completes the Khatmah
      final justCompleted = await KhatmahService.updateProgress(604);
      expect(justCompleted, isTrue);
      active = await KhatmahService.getActiveKhatmah();
      expect(active?.status, KhatmahStatus.completed);
      expect(active?.currentPage, 604);
    });

    test('Vertical continuous reading loads all 114 Surahs sequentially', () async {
      final surahsMap = await QuranDataService.getAllSurahsMap();
      expect(surahsMap.length, 114);

      // Verify Surah 1 (Al-Fatihah) -> Surah 2 (Al-Baqarah) -> Surah 3 (Ali 'Imran) continuity
      expect(surahsMap[1]!.length, 7);
      expect(surahsMap[2]!.length, 286);
      expect(surahsMap[3]!.length, 200);
      expect(surahsMap[114]!.length, 6);

      // Verify page ranges for surahs
      final fatihahRange = await QuranDataService.getSurahPageRange(1);
      expect(fatihahRange.startPage, 1);
      expect(fatihahRange.endPage, 1);

      final baqarahRange = await QuranDataService.getSurahPageRange(2);
      expect(baqarahRange.startPage, 2);
      expect(baqarahRange.endPage, 49);

      final aliImranRange = await QuranDataService.getSurahPageRange(3);
      expect(aliImranRange.startPage, 50);
      expect(aliImranRange.endPage, 76);
    });

    test('Surah resolution for any Medina Mushaf page', () async {
      // Page 1 -> Al-Fatihah (1)
      final surahP1 = await QuranDataService.getSurahForPage(1);
      expect(surahP1.id, 1);

      // Page 2 -> Al-Baqarah (2)
      final surahP2 = await QuranDataService.getSurahForPage(2);
      expect(surahP2.id, 2);

      // Page 50 -> Ali 'Imran (3)
      final surahP50 = await QuranDataService.getSurahForPage(50);
      expect(surahP50.id, 3);

      // Page 604 -> Al-Ikhlas (112), Al-Falaq (113), An-Nas (114)
      final surahP604 = await QuranDataService.getSurahForPage(604);
      expect(surahP604.id, 112);
    });

    test('Vertical scroll active surah tracking algorithm across boundaries', () {
      // Mock surah bounding boxes along the scroll axis
      final surahOffsets = <int, ({double top, double bottom})>{
        1: (top: 0.0, bottom: 800.0),        // Al-Fatihah
        2: (top: 800.0, bottom: 25000.0),    // Al-Baqarah
        3: (top: 25000.0, bottom: 42000.0),  // Ali 'Imran
        4: (top: 42000.0, bottom: 60000.0),  // An-Nisa
      };

      int resolveActiveSurah(double scrollOffset, double threshold) {
        final readingPos = scrollOffset + threshold;
        for (var entry in surahOffsets.entries) {
          if (readingPos >= entry.value.top && readingPos < entry.value.bottom) {
            return entry.key;
          }
        }
        return 1;
      }

      // Reading Al-Fatihah
      expect(resolveActiveSurah(0.0, 180.0), 1);

      // Scroll into Al-Baqarah
      expect(resolveActiveSurah(1200.0, 180.0), 2);
      expect(resolveActiveSurah(24000.0, 180.0), 2);

      // Scroll into Ali 'Imran (downward)
      expect(resolveActiveSurah(26000.0, 180.0), 3);

      // Scroll back up into Al-Baqarah (upward)
      expect(resolveActiveSurah(15000.0, 180.0), 2);

      // Scroll into An-Nisa (downward)
      expect(resolveActiveSurah(45000.0, 180.0), 4);
    });
  });
}
