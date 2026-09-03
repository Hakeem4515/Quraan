import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quraan/models/surah.dart';
import 'package:quraan/screens/surah_detail_screen.dart';
import 'package:quraan/services/khatmah_service.dart';
import 'package:quraan/services/quran_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await QuranDataService.getAllSurahsMap();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    KhatmahService.resetForTesting();
  });

  Widget createDetailScreen({required Surah surah, bool isHorizontal = false}) {
    return MaterialApp(
      home: SurahDetailScreen(
        surah: surah,
        isHorizontalSwipe: isHorizontal,
        isArabic: true,
      ),
    );
  }

  Future<void> pumpScreen(WidgetTester tester, Surah surah, {bool isHorizontal = false}) async {
    await QuranDataService.getAllSurahsMap();
    await tester.pumpWidget(createDetailScreen(surah: surah, isHorizontal: isHorizontal));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
  }

  group('Vertical Scroll Mode - Direct Surah Navigation Tests', () {
    testWidgets('Test 1: Opening Al-Fatihah (Surah 1) directly in vertical mode', (tester) async {
      final fatihah = QuranDataService.allSurahs.firstWhere((s) => s.id == 1);
      await pumpScreen(tester, fatihah);

      expect(find.textContaining('الفاتحة'), findsWidgets);
    });

    testWidgets('Test 2: Opening Al-Baqarah (Surah 2) directly in vertical mode', (tester) async {
      final baqarah = QuranDataService.allSurahs.firstWhere((s) => s.id == 2);
      await pumpScreen(tester, baqarah);

      expect(find.textContaining('البقرة'), findsWidgets);
    });

    testWidgets('Test 3: Opening Ali \'Imran (Surah 3) directly in vertical mode', (tester) async {
      final aliImran = QuranDataService.allSurahs.firstWhere((s) => s.id == 3);
      await pumpScreen(tester, aliImran);

      expect(find.textContaining('آل عمران'), findsWidgets);
    });

    testWidgets('Test 4: Opening Al-Kahf (Surah 18) directly in vertical mode', (tester) async {
      final kahf = QuranDataService.allSurahs.firstWhere((s) => s.id == 18);
      await pumpScreen(tester, kahf);

      expect(find.textContaining('الكهف'), findsWidgets);
    });

    testWidgets('Test 5: Opening Ya-Sin (Surah 36) directly in vertical mode', (tester) async {
      final yasin = QuranDataService.allSurahs.firstWhere((s) => s.id == 36);
      await pumpScreen(tester, yasin);

      expect(find.textContaining('يس'), findsWidgets);
    });

    testWidgets('Test 6: Opening Ar-Rahman (Surah 55) directly in vertical mode', (tester) async {
      final rahman = QuranDataService.allSurahs.firstWhere((s) => s.id == 55);
      await pumpScreen(tester, rahman);

      expect(find.textContaining('الرحمن'), findsWidgets);
    });

    testWidgets('Test 7: Opening An-Nas (Surah 114) directly in vertical mode', (tester) async {
      final nas = QuranDataService.allSurahs.firstWhere((s) => s.id == 114);
      await pumpScreen(tester, nas);

      expect(find.textContaining('الناس'), findsWidgets);
    });

    testWidgets('Test 8: Surah picker allows switching to any distant Surah and returning back', (tester) async {
      final fatihah = QuranDataService.allSurahs.firstWhere((s) => s.id == 1);
      await pumpScreen(tester, fatihah);

      // Open Surah picker bottom sheet by tapping the header title
      final titleFinder = find.byKey(const ValueKey('surah_picker_title_button'));
      await tester.tap(titleFinder);
      await tester.pump(const Duration(milliseconds: 400));

      // Search and select Surah Al-Kahf (18)
      final searchFinder = find.byType(TextField);
      expect(searchFinder, findsOneWidget);
      await tester.enterText(searchFinder, 'الكهف');
      await tester.pump(const Duration(milliseconds: 300));

      final kahfItem = find.textContaining('الكهف');
      expect(kahfItem, findsWidgets);
      await tester.tap(kahfItem.first);
      await tester.pump(const Duration(milliseconds: 500));

      // Header and content should now be Al-Kahf
      expect(find.textContaining('الكهف'), findsWidgets);

      // Now open picker again and return to Al-Fatihah (1)
      await tester.tap(titleFinder);
      await tester.pump(const Duration(milliseconds: 400));

      final searchFinder2 = find.byType(TextField);
      await tester.enterText(searchFinder2, 'الفاتحة');
      await tester.pump(const Duration(milliseconds: 300));

      final fatihahItem = find.textContaining('الفاتحة');
      expect(fatihahItem, findsWidgets);
      await tester.tap(fatihahItem.first);
      await tester.pump(const Duration(milliseconds: 500));

      // Header and content should now be Al-Fatihah
      expect(find.textContaining('الفاتحة'), findsWidgets);
    });

    testWidgets('Test 9: Horizontal mode remains completely functional', (tester) async {
      final kahf = QuranDataService.allSurahs.firstWhere((s) => s.id == 18);
      await pumpScreen(tester, kahf, isHorizontal: true);

      expect(find.byType(PageView), findsOneWidget);
      expect(find.textContaining('الكهف'), findsWidgets);
    });
  });
}
