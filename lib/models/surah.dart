class Surah {
  final int id;
  final String nameArabic;
  final String nameEnglish;
  final String englishTranslation;
  final int versesCount;
  final String revelationType; // 'Meccan' or 'Medinan'

  const Surah({
    required this.id,
    required this.nameArabic,
    required this.nameEnglish,
    required this.englishTranslation,
    required this.versesCount,
    required this.revelationType,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      id: json['number'] ?? json['id'],
      nameArabic: json['name'] ?? json['nameArabic'] ?? '',
      nameEnglish: json['englishName'] ?? json['nameEnglish'] ?? '',
      englishTranslation: json['englishNameTranslation'] ?? json['englishTranslation'] ?? '',
      versesCount: json['numberOfAyahs'] ?? json['versesCount'] ?? 0,
      revelationType: json['revelationType'] ?? 'Meccan',
    );
  }
}

class Ayah {
  final int surahId;
  final int numberInSurah;
  final String arabicText;
  final String englishTranslation;
  final int juz;
  final int page;
  bool isBookmarked;

  Ayah({
    this.surahId = 1,
    required this.numberInSurah,
    required this.arabicText,
    required this.englishTranslation,
    required this.juz,
    required this.page,
    this.isBookmarked = false,
  });
}
