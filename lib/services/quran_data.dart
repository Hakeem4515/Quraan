import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/surah.dart';
import 'quran_text_data.dart';

class QuranDataService {
  static const int totalMushafPages = 604;
  static final List<String> _bookmarks = [];
  static int _lastReadSurah = 1;
  static int _lastReadAyah = 1;
  static String _lastReadSurahName = "Al-Fatihah";
  static bool _isLoadedFromPrefs = false;

  static final Map<int, List<Ayah>> _runtimeCachedAyahs = {};
  static Map<int, List<Ayah>>? _offlineSurahsMap;
  static Map<int, List<Ayah>>? _offlinePagesMap;
  static final Map<String, int> _ayahPageLookup = {};

  // Complete List of all 114 Surahs with accurate Arabic names
  static final List<Surah> allSurahs = [
    const Surah(id: 1, nameArabic: "الفاتحة", nameEnglish: "Al-Fatihah", englishTranslation: "The Opening", versesCount: 7, revelationType: "Meccan"),
    const Surah(id: 2, nameArabic: "البقرة", nameEnglish: "Al-Baqarah", englishTranslation: "The Cow", versesCount: 286, revelationType: "Medinan"),
    const Surah(id: 3, nameArabic: "آل عمران", nameEnglish: "Ali 'Imran", englishTranslation: "Family of Imran", versesCount: 200, revelationType: "Medinan"),
    const Surah(id: 4, nameArabic: "النساء", nameEnglish: "An-Nisa", englishTranslation: "The Women", versesCount: 176, revelationType: "Medinan"),
    const Surah(id: 5, nameArabic: "المائدة", nameEnglish: "Al-Ma'idah", englishTranslation: "The Table Spread", versesCount: 120, revelationType: "Medinan"),
    const Surah(id: 6, nameArabic: "الأنعام", nameEnglish: "Al-An'am", englishTranslation: "The Cattle", versesCount: 165, revelationType: "Meccan"),
    const Surah(id: 7, nameArabic: "الأعراف", nameEnglish: "Al-A'raf", englishTranslation: "The Heights", versesCount: 206, revelationType: "Meccan"),
    const Surah(id: 8, nameArabic: "الأنفال", nameEnglish: "Al-Anfal", englishTranslation: "The Spoils of War", versesCount: 75, revelationType: "Medinan"),
    const Surah(id: 9, nameArabic: "التوبة", nameEnglish: "At-Tawbah", englishTranslation: "The Repentance", versesCount: 129, revelationType: "Medinan"),
    const Surah(id: 10, nameArabic: "يونس", nameEnglish: "Yunus", englishTranslation: "Jonah", versesCount: 109, revelationType: "Meccan"),
    const Surah(id: 11, nameArabic: "هود", nameEnglish: "Hud", englishTranslation: "Hud", versesCount: 123, revelationType: "Meccan"),
    const Surah(id: 12, nameArabic: "يوسف", nameEnglish: "Yusuf", englishTranslation: "Joseph", versesCount: 111, revelationType: "Meccan"),
    const Surah(id: 13, nameArabic: "الرعد", nameEnglish: "Ar-Ra'd", englishTranslation: "The Thunder", versesCount: 43, revelationType: "Medinan"),
    const Surah(id: 14, nameArabic: "إبراهيم", nameEnglish: "Ibrahim", englishTranslation: "Abraham", versesCount: 52, revelationType: "Meccan"),
    const Surah(id: 15, nameArabic: "الحجر", nameEnglish: "Al-Hijr", englishTranslation: "The Rocky Tract", versesCount: 99, revelationType: "Meccan"),
    const Surah(id: 16, nameArabic: "النحل", nameEnglish: "An-Nahl", englishTranslation: "The Bee", versesCount: 128, revelationType: "Meccan"),
    const Surah(id: 17, nameArabic: "الإسراء", nameEnglish: "Al-Isra", englishTranslation: "The Night Journey", versesCount: 111, revelationType: "Meccan"),
    const Surah(id: 18, nameArabic: "الكهف", nameEnglish: "Al-Kahf", englishTranslation: "The Cave", versesCount: 110, revelationType: "Meccan"),
    const Surah(id: 19, nameArabic: "مريم", nameEnglish: "Maryam", englishTranslation: "Mary", versesCount: 98, revelationType: "Meccan"),
    const Surah(id: 20, nameArabic: "طه", nameEnglish: "Ta-Ha", englishTranslation: "Ta-Ha", versesCount: 135, revelationType: "Meccan"),
    const Surah(id: 21, nameArabic: "الأنبياء", nameEnglish: "Al-Anbiya", englishTranslation: "The Prophets", versesCount: 112, revelationType: "Meccan"),
    const Surah(id: 22, nameArabic: "الحج", nameEnglish: "Al-Hajj", englishTranslation: "The Pilgrimage", versesCount: 78, revelationType: "Medinan"),
    const Surah(id: 23, nameArabic: "المؤمنون", nameEnglish: "Al-Mu'minun", englishTranslation: "The Believers", versesCount: 118, revelationType: "Meccan"),
    const Surah(id: 24, nameArabic: "النور", nameEnglish: "An-Nur", englishTranslation: "The Light", versesCount: 64, revelationType: "Medinan"),
    const Surah(id: 25, nameArabic: "الفرقان", nameEnglish: "Al-Furqan", englishTranslation: "The Criterion", versesCount: 77, revelationType: "Meccan"),
    const Surah(id: 26, nameArabic: "الشعراء", nameEnglish: "Ash-Shu'ara", englishTranslation: "The Poets", versesCount: 227, revelationType: "Meccan"),
    const Surah(id: 27, nameArabic: "النمل", nameEnglish: "An-Naml", englishTranslation: "The Ant", versesCount: 93, revelationType: "Meccan"),
    const Surah(id: 28, nameArabic: "القصص", nameEnglish: "Al-Qasas", englishTranslation: "The Stories", versesCount: 88, revelationType: "Meccan"),
    const Surah(id: 29, nameArabic: "العنكبوت", nameEnglish: "Al-Ankabut", englishTranslation: "The Spider", versesCount: 69, revelationType: "Meccan"),
    const Surah(id: 30, nameArabic: "الروم", nameEnglish: "Ar-Rum", englishTranslation: "The Romans", versesCount: 60, revelationType: "Meccan"),
    const Surah(id: 31, nameArabic: "لقمان", nameEnglish: "Luqman", englishTranslation: "Luqman", versesCount: 34, revelationType: "Meccan"),
    const Surah(id: 32, nameArabic: "السجدة", nameEnglish: "As-Sajdah", englishTranslation: "The Prostration", versesCount: 30, revelationType: "Meccan"),
    const Surah(id: 33, nameArabic: "الأحزاب", nameEnglish: "Al-Ahzab", englishTranslation: "The Combined Forces", versesCount: 73, revelationType: "Medinan"),
    const Surah(id: 34, nameArabic: "سبإ", nameEnglish: "Saba", englishTranslation: "Sheba", versesCount: 54, revelationType: "Meccan"),
    const Surah(id: 35, nameArabic: "فاطر", nameEnglish: "Fatir", englishTranslation: "Originator", versesCount: 45, revelationType: "Meccan"),
    const Surah(id: 36, nameArabic: "يس", nameEnglish: "Ya-Sin", englishTranslation: "Ya-Sin", versesCount: 83, revelationType: "Meccan"),
    const Surah(id: 37, nameArabic: "الصافات", nameEnglish: "As-Saffat", englishTranslation: "Those who set the Ranks", versesCount: 182, revelationType: "Meccan"),
    const Surah(id: 38, nameArabic: "ص", nameEnglish: "Sad", englishTranslation: "Sad", versesCount: 88, revelationType: "Meccan"),
    const Surah(id: 39, nameArabic: "الزمر", nameEnglish: "Az-Zumar", englishTranslation: "The Troops", versesCount: 75, revelationType: "Meccan"),
    const Surah(id: 40, nameArabic: "غافر", nameEnglish: "Ghafir", englishTranslation: "The Forgiver", versesCount: 85, revelationType: "Meccan"),
    const Surah(id: 41, nameArabic: "فصلت", nameEnglish: "Fussilat", englishTranslation: "Explained in Detail", versesCount: 54, revelationType: "Meccan"),
    const Surah(id: 42, nameArabic: "الشورى", nameEnglish: "Ash-Shura", englishTranslation: "The Consultation", versesCount: 53, revelationType: "Meccan"),
    const Surah(id: 43, nameArabic: "الزخرف", nameEnglish: "Az-Zukhruf", englishTranslation: "The Ornaments of Gold", versesCount: 89, revelationType: "Meccan"),
    const Surah(id: 44, nameArabic: "الدخان", nameEnglish: "Ad-Dukhan", englishTranslation: "The Smoke", versesCount: 59, revelationType: "Meccan"),
    const Surah(id: 45, nameArabic: "الجاثية", nameEnglish: "Al-Jathiyah", englishTranslation: "The Crouching", versesCount: 37, revelationType: "Meccan"),
    const Surah(id: 46, nameArabic: "الأحقاف", nameEnglish: "Al-Ahqaf", englishTranslation: "The Curved Sand-hills", versesCount: 35, revelationType: "Meccan"),
    const Surah(id: 47, nameArabic: "محمد", nameEnglish: "Muhammad", englishTranslation: "Muhammad", versesCount: 38, revelationType: "Medinan"),
    const Surah(id: 48, nameArabic: "الفتح", nameEnglish: "Al-Fath", englishTranslation: "The Victory", versesCount: 29, revelationType: "Medinan"),
    const Surah(id: 49, nameArabic: "الحجرات", nameEnglish: "Al-Hujurat", englishTranslation: "The Dwellings", versesCount: 18, revelationType: "Medinan"),
    const Surah(id: 50, nameArabic: "ق", nameEnglish: "Qaf", englishTranslation: "Qaf", versesCount: 45, revelationType: "Meccan"),
    const Surah(id: 51, nameArabic: "الذاريات", nameEnglish: "Adh-Dhariyat", englishTranslation: "The Winnowing Winds", versesCount: 60, revelationType: "Meccan"),
    const Surah(id: 52, nameArabic: "الطور", nameEnglish: "At-Tur", englishTranslation: "The Mount", versesCount: 49, revelationType: "Meccan"),
    const Surah(id: 53, nameArabic: "النجم", nameEnglish: "An-Najm", englishTranslation: "The Star", versesCount: 62, revelationType: "Meccan"),
    const Surah(id: 54, nameArabic: "القمر", nameEnglish: "Al-Qamar", englishTranslation: "The Moon", versesCount: 55, revelationType: "Meccan"),
    const Surah(id: 55, nameArabic: "الرحمن", nameEnglish: "Ar-Rahman", englishTranslation: "The Beneficent", versesCount: 78, revelationType: "Medinan"),
    const Surah(id: 56, nameArabic: "الواقعة", nameEnglish: "Al-Waqi'ah", englishTranslation: "The Inevitable", versesCount: 96, revelationType: "Meccan"),
    const Surah(id: 57, nameArabic: "الحديد", nameEnglish: "Al-Hadid", englishTranslation: "The Iron", versesCount: 29, revelationType: "Medinan"),
    const Surah(id: 58, nameArabic: "المجادلة", nameEnglish: "Al-Mujadila", englishTranslation: "The Pleading Woman", versesCount: 22, revelationType: "Medinan"),
    const Surah(id: 59, nameArabic: "الحشر", nameEnglish: "Al-Hashr", englishTranslation: "The Exile", versesCount: 24, revelationType: "Medinan"),
    const Surah(id: 60, nameArabic: "الممتحنة", nameEnglish: "Al-Mumtahanah", englishTranslation: "She that is to be examined", versesCount: 13, revelationType: "Medinan"),
    const Surah(id: 61, nameArabic: "الصف", nameEnglish: "As-Saff", englishTranslation: "The Ranks", versesCount: 14, revelationType: "Medinan"),
    const Surah(id: 62, nameArabic: "الجمعة", nameEnglish: "Al-Jumu'ah", englishTranslation: "The Congregation", versesCount: 11, revelationType: "Medinan"),
    const Surah(id: 63, nameArabic: "المنافقون", nameEnglish: "Al-Munafiqun", englishTranslation: "The Hypocrites", versesCount: 11, revelationType: "Medinan"),
    const Surah(id: 64, nameArabic: "التغابن", nameEnglish: "At-Taghabun", englishTranslation: "Mutual Disillusion", versesCount: 18, revelationType: "Medinan"),
    const Surah(id: 65, nameArabic: "الطلاق", nameEnglish: "At-Talaq", englishTranslation: "The Divorce", versesCount: 12, revelationType: "Medinan"),
    const Surah(id: 66, nameArabic: "التحريم", nameEnglish: "At-Tahrim", englishTranslation: "The Prohibition", versesCount: 12, revelationType: "Medinan"),
    const Surah(id: 67, nameArabic: "الملك", nameEnglish: "Al-Mulk", englishTranslation: "The Sovereignty", versesCount: 30, revelationType: "Meccan"),
    const Surah(id: 68, nameArabic: "القلم", nameEnglish: "Al-Qalam", englishTranslation: "The Pen", versesCount: 52, revelationType: "Meccan"),
    const Surah(id: 69, nameArabic: "الحاقة", nameEnglish: "Al-Haqqah", englishTranslation: "The Inevitable", versesCount: 52, revelationType: "Meccan"),
    const Surah(id: 70, nameArabic: "المعارج", nameEnglish: "Al-Ma'arij", englishTranslation: "The Ascending Stairways", versesCount: 44, revelationType: "Meccan"),
    const Surah(id: 71, nameArabic: "نوح", nameEnglish: "Nuh", englishTranslation: "Noah", versesCount: 28, revelationType: "Meccan"),
    const Surah(id: 72, nameArabic: "الجن", nameEnglish: "Al-Jinn", englishTranslation: "The Jinn", versesCount: 28, revelationType: "Meccan"),
    const Surah(id: 73, nameArabic: "المزمل", nameEnglish: "Al-Muzzammil", englishTranslation: "The Enshrouded One", versesCount: 20, revelationType: "Meccan"),
    const Surah(id: 74, nameArabic: "المدثر", nameEnglish: "Al-Muddaththir", englishTranslation: "The Cloaked One", versesCount: 56, revelationType: "Meccan"),
    const Surah(id: 75, nameArabic: "القيامة", nameEnglish: "Al-Qiyamah", englishTranslation: "The Resurrection", versesCount: 40, revelationType: "Meccan"),
    const Surah(id: 76, nameArabic: "الإنسان", nameEnglish: "Al-Insan", englishTranslation: "The Man", versesCount: 31, revelationType: "Medinan"),
    const Surah(id: 77, nameArabic: "المرسلات", nameEnglish: "Al-Mursalat", englishTranslation: "The Emissaries", versesCount: 50, revelationType: "Meccan"),
    const Surah(id: 78, nameArabic: "النبإ", nameEnglish: "An-Naba", englishTranslation: "The Tidings", versesCount: 40, revelationType: "Meccan"),
    const Surah(id: 79, nameArabic: "النازعات", nameEnglish: "An-Nazi'at", englishTranslation: "Those who drag forth", versesCount: 46, revelationType: "Meccan"),
    const Surah(id: 80, nameArabic: "عبس", nameEnglish: "'Abasa", englishTranslation: "He Frowned", versesCount: 42, revelationType: "Meccan"),
    const Surah(id: 81, nameArabic: "التكوير", nameEnglish: "At-Takwir", englishTranslation: "The Overthrowing", versesCount: 29, revelationType: "Meccan"),
    const Surah(id: 82, nameArabic: "الانفطار", nameEnglish: "Al-Infitar", englishTranslation: "The Cleaving", versesCount: 19, revelationType: "Meccan"),
    const Surah(id: 83, nameArabic: "المطففين", nameEnglish: "Al-Mutaffifin", englishTranslation: "The Defrauding", versesCount: 36, revelationType: "Meccan"),
    const Surah(id: 84, nameArabic: "الانشقاق", nameEnglish: "Al-Inshiqaq", englishTranslation: "The Splitting Open", versesCount: 25, revelationType: "Meccan"),
    const Surah(id: 85, nameArabic: "البروج", nameEnglish: "Al-Buruj", englishTranslation: "The Mansions of the Stars", versesCount: 22, revelationType: "Meccan"),
    const Surah(id: 86, nameArabic: "الطارق", nameEnglish: "At-Tariq", englishTranslation: "The Morning Star", versesCount: 17, revelationType: "Meccan"),
    const Surah(id: 87, nameArabic: "الأعلى", nameEnglish: "Al-A'la", englishTranslation: "The Most High", versesCount: 19, revelationType: "Meccan"),
    const Surah(id: 88, nameArabic: "الغاشية", nameEnglish: "Al-Ghashiyah", englishTranslation: "The Overwhelming", versesCount: 26, revelationType: "Meccan"),
    const Surah(id: 89, nameArabic: "الفجر", nameEnglish: "Al-Fajr", englishTranslation: "The Dawn", versesCount: 30, revelationType: "Meccan"),
    const Surah(id: 90, nameArabic: "البلد", nameEnglish: "Al-Balad", englishTranslation: "The City", versesCount: 20, revelationType: "Meccan"),
    const Surah(id: 91, nameArabic: "الشمس", nameEnglish: "Ash-Shams", englishTranslation: "The Sun", versesCount: 15, revelationType: "Meccan"),
    const Surah(id: 92, nameArabic: "الليل", nameEnglish: "Al-Layl", englishTranslation: "The Night", versesCount: 21, revelationType: "Meccan"),
    const Surah(id: 93, nameArabic: "الضحى", nameEnglish: "Ad-Duha", englishTranslation: "The Morning Hours", versesCount: 11, revelationType: "Meccan"),
    const Surah(id: 94, nameArabic: "الشرح", nameEnglish: "Ash-Sharh", englishTranslation: "The Relief", versesCount: 8, revelationType: "Meccan"),
    const Surah(id: 95, nameArabic: "التين", nameEnglish: "At-Tin", englishTranslation: "The Fig", versesCount: 8, revelationType: "Meccan"),
    const Surah(id: 96, nameArabic: "العلق", nameEnglish: "Al-'Alaq", englishTranslation: "The Clot", versesCount: 19, revelationType: "Meccan"),
    const Surah(id: 97, nameArabic: "القدر", nameEnglish: "Al-Qadr", englishTranslation: "The Power", versesCount: 5, revelationType: "Meccan"),
    const Surah(id: 98, nameArabic: "البينة", nameEnglish: "Al-Bayyinah", englishTranslation: "The Clear Proof", versesCount: 8, revelationType: "Medinan"),
    const Surah(id: 99, nameArabic: "الزلزلة", nameEnglish: "Az-Zalzalah", englishTranslation: "The Earthquake", versesCount: 8, revelationType: "Medinan"),
    const Surah(id: 100, nameArabic: "العاديات", nameEnglish: "Al-'Adiyat", englishTranslation: "The Courser", versesCount: 11, revelationType: "Meccan"),
    const Surah(id: 101, nameArabic: "القارعة", nameEnglish: "Al-Qari'ah", englishTranslation: "The Calamity", versesCount: 11, revelationType: "Meccan"),
    const Surah(id: 102, nameArabic: "التكاثر", nameEnglish: "At-Takathur", englishTranslation: "The Rivalry in world increase", versesCount: 8, revelationType: "Meccan"),
    const Surah(id: 103, nameArabic: "العصر", nameEnglish: "Al-'Asr", englishTranslation: "The Declining Day", versesCount: 3, revelationType: "Meccan"),
    const Surah(id: 104, nameArabic: "الهمزة", nameEnglish: "Al-Humazah", englishTranslation: "The Slanderer", versesCount: 9, revelationType: "Meccan"),
    const Surah(id: 105, nameArabic: "الفيل", nameEnglish: "Al-Fil", englishTranslation: "The Elephant", versesCount: 5, revelationType: "Meccan"),
    const Surah(id: 106, nameArabic: "قريش", nameEnglish: "Quraysh", englishTranslation: "Quraysh", versesCount: 4, revelationType: "Meccan"),
    const Surah(id: 107, nameArabic: "الماعون", nameEnglish: "Al-Ma'un", englishTranslation: "Small Kindnesses", versesCount: 7, revelationType: "Meccan"),
    const Surah(id: 108, nameArabic: "الكوثر", nameEnglish: "Al-Kawthar", englishTranslation: "Abundance", versesCount: 3, revelationType: "Meccan"),
    const Surah(id: 109, nameArabic: "الكافرون", nameEnglish: "Al-Kafirun", englishTranslation: "The Disbelievers", versesCount: 6, revelationType: "Meccan"),
    const Surah(id: 110, nameArabic: "النصر", nameEnglish: "An-Nasr", englishTranslation: "The Divine Support", versesCount: 3, revelationType: "Medinan"),
    const Surah(id: 111, nameArabic: "المسد", nameEnglish: "Al-Masad", englishTranslation: "The Palm Fiber", versesCount: 5, revelationType: "Meccan"),
    const Surah(id: 112, nameArabic: "الإخلاص", nameEnglish: "Al-Ikhlas", englishTranslation: "Sincerity", versesCount: 4, revelationType: "Meccan"),
    const Surah(id: 113, nameArabic: "الفلق", nameEnglish: "Al-Falaq", englishTranslation: "The Daybreak", versesCount: 5, revelationType: "Meccan"),
    const Surah(id: 114, nameArabic: "الناس", nameEnglish: "An-Nas", englishTranslation: "Mankind", versesCount: 6, revelationType: "Meccan"),
  ];

  // Authentic start pages for each of the 30 Juz in the Medina Mushaf
  static const List<int> juzStartPages = [
    1,   // Juz 1 (Al-Fatihah 1:1)
    22,  // Juz 2 (Al-Baqarah 2:142)
    42,  // Juz 3 (Al-Baqarah 2:253)
    62,  // Juz 4 (Ali 'Imran 3:93)
    82,  // Juz 5 (An-Nisa 4:24)
    102, // Juz 6 (An-Nisa 4:148)
    121, // Juz 7 (Al-Ma'idah 5:82)
    142, // Juz 8 (Al-An'am 6:111)
    162, // Juz 9 (Al-A'raf 7:88)
    182, // Juz 10 (Al-Anfal 8:41)
    201, // Juz 11 (At-Tawbah 9:93)
    222, // Juz 12 (Hud 11:6)
    242, // Juz 13 (Yusuf 12:53)
    262, // Juz 14 (Al-Hijr 15:1)
    282, // Juz 15 (Al-Isra 17:1)
    302, // Juz 16 (Al-Kahf 18:75)
    322, // Juz 17 (Al-Anbiya 21:1)
    342, // Juz 18 (Al-Mu'minun 23:1)
    362, // Juz 19 (Al-Furqan 25:21)
    382, // Juz 20 (An-Naml 27:56)
    402, // Juz 21 (Al-Ankabut 29:46)
    422, // Juz 22 (Al-Ahzab 33:31)
    442, // Juz 23 (Ya-Sin 36:28)
    462, // Juz 24 (Az-Zumar 39:32)
    482, // Juz 25 (Fussilat 41:47)
    502, // Juz 26 (Al-Ahqaf 46:1)
    522, // Juz 27 (Adh-Dhariyat 51:31)
    542, // Juz 28 (Al-Mujadila 58:1)
    562, // Juz 29 (Al-Mulk 67:1)
    582, // Juz 30 (An-Naba 78:1)
  ];

  /// Initialize and cache the offline Quran datasets (both surah and 604 pages mappings)
  static Future<void> _ensureDatasetsLoaded() async {
    if (_offlineSurahsMap != null && _offlinePagesMap != null) {
      return;
    }

    try {
      // Load Arabic text (quran_cleaned.json)
      String arabicJsonString;
      try {
        arabicJsonString = await rootBundle.loadString('assets/data/quran_cleaned.json');
      } catch (_) {
        final f = File('assets/data/quran_cleaned.json');
        if (f.existsSync()) {
          arabicJsonString = f.readAsStringSync();
        } else {
          rethrow;
        }
      }
      final List<dynamic> surahsList = jsonDecode(arabicJsonString);

      // Load English translation (quran_en.json) and build a fast lookup map
      Map<int, Map<int, String>> englishLookup = {};
      try {
        String? englishJsonString;
        try {
          englishJsonString = await rootBundle.loadString('assets/data/quran_en.json');
        } catch (_) {
          final f = File('assets/data/quran_en.json');
          if (f.existsSync()) {
            englishJsonString = f.readAsStringSync();
          }
        }
        if (englishJsonString != null) {
          final Map<String, dynamic> englishData = jsonDecode(englishJsonString);
          final List<dynamic> englishSurahs = englishData['data']['surahs'] as List<dynamic>;
          for (var s in englishSurahs) {
            final int surahNum = s['number'] as int;
            englishLookup[surahNum] = {};
            final List<dynamic> ayahs = s['ayahs'] as List<dynamic>;
            for (var a in ayahs) {
              final int ayahNum = a['numberInSurah'] as int;
              englishLookup[surahNum]![ayahNum] = (a['text'] as String?) ?? '';
            }
          }
        }
      } catch (_) {
        // English translation unavailable – continue with Arabic dataset
      }

      final Map<int, List<Ayah>> surahsMap = {};
      final Map<int, List<Ayah>> pagesMap = {};

      for (var s in surahsList) {
        int surahId = s['id'] as int;
        List<dynamic> ayahsRaw = s['ayahs'] as List<dynamic>;
        List<Ayah> ayahs = ayahsRaw.map((a) {
          final int ayahNum = a['numberInSurah'] as int;
          final int pageNum = (a['page'] as int?) ?? 1;
          final int juzNum = (a['juz'] as int?) ?? 1;

          final String translation =
              englishLookup[surahId]?[ayahNum] ??
              (a['englishTranslation'] as String?) ??
              '';

          final ayah = Ayah(
            surahId: surahId,
            numberInSurah: ayahNum,
            arabicText: a['arabicText'] as String,
            englishTranslation: translation,
            juz: juzNum,
            page: pageNum,
          );

          pagesMap.putIfAbsent(pageNum, () => []).add(ayah);
          _ayahPageLookup["$surahId:$ayahNum"] = pageNum;

          return ayah;
        }).toList();

        surahsMap[surahId] = ayahs;
      }

      _offlineSurahsMap = surahsMap;
      _offlinePagesMap = pagesMap;
    } catch (_) {
      _offlineSurahsMap = QuranTextData.surahAyahs;
      _offlinePagesMap = {};
      for (var entry in QuranTextData.surahAyahs.entries) {
        for (var ayah in entry.value) {
          _offlinePagesMap!.putIfAbsent(ayah.page, () => []).add(ayah);
          _ayahPageLookup["${entry.key}:${ayah.numberInSurah}"] = ayah.page;
        }
      }
    }
  }

  /// Get all Ayahs of a specific Surah (1 to 114)
  static Future<List<Ayah>> getAyahsForSurah(int surahId) async {
    if (_runtimeCachedAyahs.containsKey(surahId)) {
      return _runtimeCachedAyahs[surahId]!;
    }

    await _ensureDatasetsLoaded();

    if (_offlineSurahsMap != null && _offlineSurahsMap!.containsKey(surahId) && _offlineSurahsMap![surahId]!.isNotEmpty) {
      final offlineAyahs = _offlineSurahsMap![surahId]!;
      _runtimeCachedAyahs[surahId] = offlineAyahs;
      return offlineAyahs;
    }

    // Secondary fallback: API fetch
    try {
      final response = await http
          .get(Uri.parse('https://api.alquran.cloud/v1/surah/$surahId/editions/quran-uthmani,en.sahih'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final arabicList = data['data'][0]['ayahs'] as List;
        final englishList = data['data'][1]['ayahs'] as List;

        List<Ayah> ayahs = [];
        const String bismillah = "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ ";

        for (int i = 0; i < arabicList.length; i++) {
          int ayahNum = arabicList[i]['numberInSurah'];
          String rawArabicText = arabicList[i]['text'] ?? '';

          if (surahId != 1 && surahId != 9 && ayahNum == 1) {
            if (rawArabicText.startsWith(bismillah)) {
              rawArabicText = rawArabicText.substring(bismillah.length);
            } else if (rawArabicText.startsWith("بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ ")) {
              rawArabicText = rawArabicText.substring("بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ ".length);
            }
          }

          final pageNum = (arabicList[i]['page'] as int?) ?? 1;
          final juzNum = (arabicList[i]['juz'] as int?) ?? 1;

          ayahs.add(Ayah(
            surahId: surahId,
            numberInSurah: ayahNum,
            arabicText: rawArabicText,
            englishTranslation: englishList[i]['text'] ?? '',
            juz: juzNum,
            page: pageNum,
          ));
        }

        _runtimeCachedAyahs[surahId] = ayahs;
        return ayahs;
      }
    } catch (_) {}

    // Fallback: embedded dataset
    if (QuranTextData.surahAyahs.containsKey(surahId)) {
      return QuranTextData.surahAyahs[surahId]!;
    }

    return [];
  }

  /// Get all Ayahs belonging to a specific Medina Mushaf page (1 to 604)
  static Future<List<Ayah>> getPageAyahs(int pageNumber) async {
    if (pageNumber < 1 || pageNumber > totalMushafPages) return [];
    await _ensureDatasetsLoaded();
    return _offlinePagesMap?[pageNumber] ?? [];
  }

  /// Group a Surah's Ayahs by their actual Medina Mushaf page numbers
  /// Returns a Map where key is the authentic Mushaf page number and value is the list of Ayahs on that page.
  static Future<Map<int, List<Ayah>>> getSurahPagesGrouped(int surahId) async {
    final ayahs = await getAyahsForSurah(surahId);
    final Map<int, List<Ayah>> grouped = {};
    for (var ayah in ayahs) {
      grouped.putIfAbsent(ayah.page, () => []).add(ayah);
    }
    return grouped;
  }

  /// Get the authentic Medina Mushaf page number for a given verse (surahId, ayahNumber)
  static Future<int> getPageForAyah(int surahId, int ayahNumber) async {
    final key = "$surahId:$ayahNumber";
    if (_ayahPageLookup.containsKey(key)) {
      return _ayahPageLookup[key]!;
    }
    final ayahs = await getAyahsForSurah(surahId);
    for (var a in ayahs) {
      if (a.numberInSurah == ayahNumber) {
        _ayahPageLookup[key] = a.page;
        return a.page;
      }
    }
    return 1;
  }

  /// Get start and end page for a Surah in the Medina Mushaf
  static Future<({int startPage, int endPage})> getSurahPageRange(int surahId) async {
    final ayahs = await getAyahsForSurah(surahId);
    if (ayahs.isEmpty) return (startPage: 1, endPage: 1);
    return (startPage: ayahs.first.page, endPage: ayahs.last.page);
  }

  /// Get all 114 Surahs with their loaded Ayahs in memory
  static Future<Map<int, List<Ayah>>> getAllSurahsMap() async {
    await _ensureDatasetsLoaded();
    if (_offlineSurahsMap != null) return _offlineSurahsMap!;
    for (int i = 1; i <= 114; i++) {
      await getAyahsForSurah(i);
    }
    return _offlineSurahsMap ?? {};
  }

  /// Get the primary Surah that appears on a given Medina Mushaf page (1 to 604)
  static Future<Surah> getSurahForPage(int pageNumber) async {
    final pageAyahs = await getPageAyahs(pageNumber);
    if (pageAyahs.isNotEmpty) {
      final surahId = pageAyahs.first.surahId;
      return allSurahs.firstWhere(
        (s) => s.id == surahId,
        orElse: () => allSurahs[0],
      );
    }
    return allSurahs[0];
  }

  /// Get the starting page of any Juz (1 to 30)
  static int getJuzStartPage(int juzNumber) {
    if (juzNumber >= 1 && juzNumber <= 30) {
      return juzStartPages[juzNumber - 1];
    }
    return 1;
  }


  static Future<void> _ensureLoaded() async {
    if (_isLoadedFromPrefs) return;
    _isLoadedFromPrefs = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      _lastReadSurah = prefs.getInt('last_read_surah') ?? 1;
      _lastReadAyah = prefs.getInt('last_read_ayah') ?? 1;
      _lastReadSurahName = prefs.getString('last_read_surah_name') ?? "Al-Fatihah";
      final savedBookmarks = prefs.getStringList('bookmarks');
      if (savedBookmarks != null) {
        _bookmarks.clear();
        _bookmarks.addAll(savedBookmarks);
      }
    } catch (_) {}
  }

  // Save Last Read Position
  static Future<void> saveLastRead(int surahId, int ayahNumber, String surahName) async {
    await _ensureLoaded();
    _lastReadSurah = surahId;
    _lastReadAyah = ayahNumber;
    _lastReadSurahName = surahName;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_read_surah', surahId);
      await prefs.setInt('last_read_ayah', ayahNumber);
      await prefs.setString('last_read_surah_name', surahName);
    } catch (_) {}
  }

  // Load Last Read Position
  static Future<Map<String, dynamic>> getLastRead() async {
    await _ensureLoaded();
    return {
      'surahId': _lastReadSurah,
      'ayahNumber': _lastReadAyah,
      'surahName': _lastReadSurahName,
    };
  }

  // Bookmark Helpers
  static Future<List<String>> getBookmarks() async {
    await _ensureLoaded();
    return List.unmodifiable(_bookmarks);
  }

  static Future<void> toggleBookmark(int surahId, int ayahNumber) async {
    await _ensureLoaded();
    String key = "$surahId:$ayahNumber";
    if (_bookmarks.contains(key)) {
      _bookmarks.remove(key);
    } else {
      _bookmarks.add(key);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('bookmarks', _bookmarks);
    } catch (_) {}
  }
}
