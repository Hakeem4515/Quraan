import '../models/surah.dart';

class QuranTextData {
  // Pre-cached authentic Uthmani Quran verses for offline playback and guaranteed instant display
  static final Map<int, List<Ayah>> surahAyahs = {
    // 1. Al-Fatihah
    1: [
      Ayah(surahId: 1, numberInSurah: 1, arabicText: "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ", englishTranslation: "In the name of Allah, the Entirely Merciful, the Especially Merciful.", juz: 1, page: 1),
      Ayah(surahId: 1, numberInSurah: 2, arabicText: "ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ", englishTranslation: "[All] praise is [due] to Allah, Lord of the worlds -", juz: 1, page: 1),
      Ayah(surahId: 1, numberInSurah: 3, arabicText: "ٱلرَّحْمَٰنِ ٱلرَّحِيمِ", englishTranslation: "The Entirely Merciful, the Especially Merciful,", juz: 1, page: 1),
      Ayah(surahId: 1, numberInSurah: 4, arabicText: "مَٰلِكِ يَوْمِ ٱلدِّينِ", englishTranslation: "Sovereign of the Day of Recompense.", juz: 1, page: 1),
      Ayah(surahId: 1, numberInSurah: 5, arabicText: "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ", englishTranslation: "It is You we worship and You we ask for help.", juz: 1, page: 1),
      Ayah(surahId: 1, numberInSurah: 6, arabicText: "ٱهْدِنَا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ", englishTranslation: "Guide us to the straight path -", juz: 1, page: 1),
      Ayah(surahId: 1, numberInSurah: 7, arabicText: "صِرَٰطَ ٱلَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ ٱلْمَغْضُوبِ عَلَيْهِمْ وَلَا ٱلضَّآلِّينَ", englishTranslation: "The path of those upon whom You have bestowed favor, not of those who have evoked [Your] anger or of those who are astray.", juz: 1, page: 1),
    ],

    // 2. Al-Baqarah (First 20 Ayahs embedded authentic Uthmani text)
    2: [
      Ayah(surahId: 2, numberInSurah: 1, arabicText: "الم", englishTranslation: "Alif, Lam, Meem.", juz: 1, page: 2),
      Ayah(surahId: 2, numberInSurah: 2, arabicText: "ذَٰلِكَ ٱلْكِتَٰبُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ", englishTranslation: "This is the Book about which there is no doubt, a guidance for those conscious of Allah -", juz: 1, page: 2),
      Ayah(surahId: 2, numberInSurah: 3, arabicText: "ٱلَّذِينَ يُؤْمِنُونَ بِٱلْغَيْبِ وَيُقِيمُونَ ٱلصَّلَوٰةَ وَمِمَّا رَزَقْنَٰهُمْ يُنفِقُونَ", englishTranslation: "Who believe in the unseen, establish prayer, and spend out of what We have provided for them,", juz: 1, page: 2),
      Ayah(surahId: 2, numberInSurah: 4, arabicText: "وَٱلَّذِينَ يُؤْمِنُونَ بِمَآ أُنزِلَ إِلَيْكَ وَمَآ أُنزِلَ مِن قَبْلِكَ وَبِٱلْءَاخِرَةِ هُمْ يُوقِنُونَ", englishTranslation: "And who believe in what has been revealed to you, [O Muhammad], and what was revealed before you, and of the Hereafter they are certain [in faith].", juz: 1, page: 2),
      Ayah(surahId: 2, numberInSurah: 5, arabicText: "أُولَٰٓئِكَ عَلَىٰ هُدًى مِّن رَّبِّهِمْ ۖ وَأُولَٰٓئِكَ هُمُ ٱلْمُفْلِحُونَ", englishTranslation: "Those are upon [right] guidance from their Lord, and it is those who are the successful.", juz: 1, page: 2),
      Ayah(surahId: 2, numberInSurah: 6, arabicText: "إِنَّ ٱلَّذِينَ كَفَرُوا۟ سَوَآءٌ عَلَيْهِمْ ءَأَنذَرْتَهُمْ أَمْ لَمْ تُنذِرْهُمْ لَا يُؤْمِنُونَ", englishTranslation: "Indeed, those who disbelieve - it is all the same for them whether you warn them or do not warn them - they will not believe.", juz: 1, page: 3),
      Ayah(surahId: 2, numberInSurah: 7, arabicText: "خَتَمَ ٱللَّهُ عَلَىٰ قُلُوبِهِمْ وَعَلَىٰ سَمْعِهِمْ ۖ وَعَلَىٰٓ أَبْصَٰرِهِمْ غِشَٰوَةٌ ۖ وَلَهُمْ عَذَابٌ عَظِيمٌ", englishTranslation: "Allah has set a seal upon their hearts and upon their hearing, and over their vision is a veil. And for them is a great punishment.", juz: 1, page: 3),
      Ayah(surahId: 2, numberInSurah: 8, arabicText: "وَمِنَ ٱلنَّاسِ مَن يَقُولُ ءَامَنَّا بِٱللَّهِ وَبِٱلْيَوْمِ ٱلْءَاخِرِ وَمَا هُم بِمُؤْمِنِينَ", englishTranslation: "And of the people are some who say, \"We believe in Allah and the Last Day,\" but they are not believers.", juz: 1, page: 3),
      Ayah(surahId: 2, numberInSurah: 9, arabicText: "يُخَٰدِعُونَ ٱللَّهَ وَٱلَّذِينَ ءَامَنُوا۟ وَمَا يَخْدَعُونَ إِلَّآ أَنفُسَهُمْ وَمَا يَشْعُرُونَ", englishTranslation: "They [think to] deceive Allah and those who believe, but they deceive not except themselves and perceive [it] not.", juz: 1, page: 3),
      Ayah(surahId: 2, numberInSurah: 10, arabicText: "فِي قُلُوبِهِم مَّرَضٌ فَزَادَهُمُ ٱللَّهُ مَرَضًا ۖ وَلَهُمْ عَذَابٌ أَلِيمٌۢ بِمَا كَانُوا۟ يَكْذِبُونَ", englishTranslation: "In their hearts is disease, so Allah has increased their disease; and for them is a painful punishment because they [habitually] used to lie.", juz: 1, page: 3),
      Ayah(surahId: 2, numberInSurah: 11, arabicText: "وَإِذَا قِيلَ لَهُمْ لَا تُفْسِدُوا۟ فِي ٱلْأَرْضِ قَالُوٓا۟ إِنَّمَا نَحْنُ مُصْلِحُونَ", englishTranslation: "And when it is said to them, \"Do not cause corruption on the earth,\" they say, \"We are but reformers.\"", juz: 1, page: 3),
      Ayah(surahId: 2, numberInSurah: 12, arabicText: "أَلَآ إِنَّهُمْ هُمُ ٱلْمُفْسِدُونَ وَلَٰكِن لَّا يَشْعُرُونَ", englishTranslation: "Unquestionably, it is they who are the corrupters, but they perceive [it] not.", juz: 1, page: 3),
      Ayah(surahId: 2, numberInSurah: 13, arabicText: "وَإِذَا قِيلَ لَهُمْ ءَامِنُوا۟ كَمَآ ءَامَنَ ٱلنَّاسُ قَالُوٓا۟ أَنُؤْمِنُ كَمَآ ءَامَنَ ٱلسُّفَهَآءُ ۗ أَلَآ إِنَّهُمْ هُمُ ٱلسُّفَهَآءُ وَلَٰكِن لَّا يَعْلَمُونَ", englishTranslation: "And when it is said to them, \"Believe as the people have believed,\" they say, \"Should we believe as the foolish have believed?\" Unquestionably, it is they who are the foolish, but they know [it] not.", juz: 1, page: 3),
      Ayah(surahId: 2, numberInSurah: 14, arabicText: "وَإِذَا لَقُوا۟ ٱلَّذِينَ ءَامَنُوا۟ قَالُوٓا۟ ءَامَنَّا وَإِذَا خَلَوْا۟ إِلَىٰ شَيَٰطِينِهِمْ قَالُوٓا۟ إِنَّا مَعَكُمْ إِنَّمَا نَحْنُ مُسْتَهْزِءُونَ", englishTranslation: "And when they meet those who believe, they say, \"We believe\"; but when they are alone with their evil ones, they say, \"Indeed, we are with you; we were only mockers.\"", juz: 1, page: 3),
      Ayah(surahId: 2, numberInSurah: 15, arabicText: "ٱللَّهُ يَسْتَهْزِئُ بِهِمْ وَيَمُدُّهُمْ فِي طُغْيَٰنِهِمْ يَعْمَهُونَ", englishTranslation: "[Allah] mocks them and prolongs them in their transgression [while] they wander blindly.", juz: 1, page: 3),
      Ayah(surahId: 2, numberInSurah: 16, arabicText: "أُولَٰٓئِكَ ٱلَّذِينَ ٱشْتَرَوُا۟ ٱلضَّلَٰلَةَ بِٱلْهُدَىٰ فَمَا رَبِحَت تِّجَٰرَتُهُمْ وَمَا كَانُوا۟ مُهْتَدِينَ", englishTranslation: "Those are the ones who have purchased error [in exchange] for guidance, so their transaction has brought no profit, nor were they guided.", juz: 1, page: 3),
      Ayah(surahId: 2, numberInSurah: 17, arabicText: "مَثَلُهُمْ كَمَثَلِ ٱلَّذِي ٱسْتَوْقَدَ نَارًا فَلَمَّآ أَضَآءَتْ مَا حَوْلَهُۥ ذَهَبَ ٱللَّهُ بِنُورِهِمْ وَتَرَكَهُمْ فِي ظُلُمَٰتٍ لَّا يُبْصِرُونَ", englishTranslation: "Their example is that of one who kindled a fire, but when it illuminated what was around him, Allah took away their light and left them in darkness [so] they could not see.", juz: 1, page: 4),
      Ayah(surahId: 2, numberInSurah: 18, arabicText: "صُمٌّ بُكْمٌ عُمْيٌ فَهُمْ لَا يَرْجِعُونَ", englishTranslation: "Deaf, dumb and blind - so they will not return [to the right path].", juz: 1, page: 4),
      Ayah(surahId: 2, numberInSurah: 19, arabicText: "أَوْ كَصَيِّبٍ مِّنَ ٱلسَّمَآءِ فِيهِ ظُلُمَٰتٌ وَرَعْدٌ وَبَرْقٌ يَجْعَلُونَ أَصَٰبِعَهُمْ فِي ءَاذَانِهِم مِّنَ ٱلصَّوَٰعِقِ حَذَرَ ٱلْمَوْتِ ۚ وَٱللَّهُ مُحِيطٌۢ بِٱلْكَٰفِرِينَ", englishTranslation: "Or [it is] like a rainstorm from the sky within which is darkness, thunder and lightning. They put their fingers in their ears against the thunderclaps in dread of death. But Allah is encompassing of the disbelievers.", juz: 1, page: 4),
      Ayah(surahId: 2, numberInSurah: 20, arabicText: "يَكَادُ ٱلْبَرْقُ يَخْطَفُ أَبْصَٰرَهُمْ ۖ كُلَّمَآ أَضَآءَ لَهُم مَّشَوْا۟ فِيهِ وَإِذَآ أَظْلَمَ عَلَيْهِمْ قَامُوا۟ ۚ وَلَوْ شَآءَ ٱللَّهُ لَذَهَبَ بِسَمْعِهِمْ وَأَبْصَٰرِهِمْ ۚ إِنَّ ٱللَّهَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ", englishTranslation: "The lightning almost snatches away their sight. Whenever it lights [the way] for them, they walk therein; but when darkness comes over them, they stand [still]. And if Allah had willed, He could have taken away their hearing and their sight. Indeed, Allah is over all things competent.", juz: 1, page: 4),
    ],

    // 36. Ya-Sin
    36: [
      Ayah(surahId: 36, numberInSurah: 1, arabicText: "يس", englishTranslation: "Ya, Seen.", juz: 22, page: 440),
      Ayah(surahId: 36, numberInSurah: 2, arabicText: "وَٱلْقُرْءَانِ ٱلْحَكِيمِ", englishTranslation: "By the wise Qur'an.", juz: 22, page: 440),
      Ayah(surahId: 36, numberInSurah: 3, arabicText: "إِنَّكَ لَمِنَ ٱلْمُرْسَلِينَ", englishTranslation: "Indeed you, [O Muhammad], are from among the messengers,", juz: 22, page: 440),
      Ayah(surahId: 36, numberInSurah: 4, arabicText: "عَلَىٰ صِرَٰطٍ مُّسْتَقِيمٍ", englishTranslation: "On a straight path.", juz: 22, page: 440),
      Ayah(surahId: 36, numberInSurah: 5, arabicText: "تَنزِيلَ ٱلْعَزِيزِ ٱلرَّحِيمِ", englishTranslation: "[This is] a revelation of the Exalted in Might, the Merciful,", juz: 22, page: 440),
      Ayah(surahId: 36, numberInSurah: 6, arabicText: "لِتُنذِرَ قَوْمًا مَّآ أُنذِرَ ءَابَآؤُهُمْ فَهُمْ غَٰفِلُونَ", englishTranslation: "That you may warn a people whose forefathers were not warned, so they are unaware.", juz: 22, page: 440),
    ],

    // 67. Al-Mulk
    67: [
      Ayah(surahId: 67, numberInSurah: 1, arabicText: "تَبَٰرَكَ ٱلَّذِي بِيَدِهِ ٱلْمُلْكُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ", englishTranslation: "Blessed is He in whose hand is dominion, and He is over all things competent -", juz: 29, page: 562),
      Ayah(surahId: 67, numberInSurah: 2, arabicText: "ٱلَّذِي خَلَقَ ٱلْمَوْتَ وَٱلْحَيَٰوةَ لِيَبْلُوَكُمْ أَيُّكُمْ أَحْسَنُ عَمَلًا ۚ وَهُوَ ٱلْعَزِيزُ ٱلْغَفُورُ", englishTranslation: "[He] who created death and life to test you [as to] which of you is best in deed - and He is the Exalted in Might, the Forgiving -", juz: 29, page: 562),
      Ayah(surahId: 67, numberInSurah: 3, arabicText: "ٱلَّذِي خَلَقَ سَبْعَ سَمَٰوَٰتٍ طِبَاقًا ۖ مَّا تَرَىٰ فِي خَلْقِ ٱلرَّحْمَٰنِ مِن تَفَٰوُتٍ ۖ فَٱرْجِعِ ٱلْبَصَرَ هَلْ تَرَىٰ مِن فُطُورٍ", englishTranslation: "[And] who created seven heavens in layers. You do not see in the creation of the Most Merciful any inconsistency. So return [your] vision [to the sky]; do you see any breaks?", juz: 29, page: 562),
      Ayah(surahId: 67, numberInSurah: 4, arabicText: "ثُمَّ ٱرْجِعِ ٱلْبَصَرَ كَرَّتَيْنِ يَنقَلِبْ إِلَيْكَ ٱلْبَصَرُ خَاسِئًا وَهُوَ حَسِيرٌ", englishTranslation: "Then return [your] vision twice again. [Your] vision will return to you humbled while it is fatigued.", juz: 29, page: 562),
    ],

    // 108. Al-Kawthar
    108: [
      Ayah(surahId: 108, numberInSurah: 1, arabicText: "إِنَّآ أَعْطَيْنَٰكَ ٱلْكَوْثَرَ", englishTranslation: "Indeed, We have granted you, [O Muhammad], al-Kawthar.", juz: 30, page: 602),
      Ayah(surahId: 108, numberInSurah: 2, arabicText: "فَصَلِّ لِرَبِّكَ وَٱنْحَرْ", englishTranslation: "So pray to your Lord and sacrifice [to Him alone].", juz: 30, page: 602),
      Ayah(surahId: 108, numberInSurah: 3, arabicText: "إِنَّ شَانِئَكَ هُوَ ٱلْأَبْتَرُ", englishTranslation: "Indeed, your enemy is the one cut off.", juz: 30, page: 602),
    ],

    // 110. An-Nasr
    110: [
      Ayah(surahId: 110, numberInSurah: 1, arabicText: "إِذَا جَآءَ نَصْرُ ٱللَّهِ وَٱلْفَتْحُ", englishTranslation: "When the victory of Allah has come and the conquest,", juz: 30, page: 603),
      Ayah(surahId: 110, numberInSurah: 2, arabicText: "وَرَأَيْتَ ٱلنَّاسَ يَدْخُلُونَ فِي دِينِ ٱللَّهِ أَفْوَاجًا", englishTranslation: "And you see the people entering into the religion of Allah in multitudes,", juz: 30, page: 603),
      Ayah(surahId: 110, numberInSurah: 3, arabicText: "فَسَبِّحْ بِحَمْدِ رَبِّكَ وَٱسْتَغْفِرْهُ ۚ إِنَّهُۥ كَانَ تَوَّابًۢا", englishTranslation: "Then exalt [Him] with praise of your Lord and ask forgiveness of Him. Indeed, He is ever Accepting of repentance.", juz: 30, page: 603),
    ],

    // 112. Al-Ikhlas
    112: [
      Ayah(surahId: 112, numberInSurah: 1, arabicText: "قُلْ هُوَ ٱللَّهُ أَحَدٌ", englishTranslation: "Say, \"He is Allah, [who is] One,", juz: 30, page: 604),
      Ayah(surahId: 112, numberInSurah: 2, arabicText: "ٱللَّهُ ٱلصَّمَدُ", englishTranslation: "Allah, the Eternal Refuge.", juz: 30, page: 604),
      Ayah(surahId: 112, numberInSurah: 3, arabicText: "لَمْ يَلِدْ وَلَمْ يُولَدْ", englishTranslation: "He neither begets nor is born,", juz: 30, page: 604),
      Ayah(surahId: 112, numberInSurah: 4, arabicText: "وَلَمْ يَكُن لَّهُۥ كُفُوًا أَحَدٌ", englishTranslation: "Nor is there to Him any equivalent.\"", juz: 30, page: 604),
    ],

    // 113. Al-Falaq
    113: [
      Ayah(surahId: 113, numberInSurah: 1, arabicText: "قُلْ أَعُوذُ بِرَبِّ ٱلْفَلَقِ", englishTranslation: "Say, \"I seek refuge in the Lord of daybreak", juz: 30, page: 604),
      Ayah(surahId: 113, numberInSurah: 2, arabicText: "مِن شَرِّ مَا خَلَقَ", englishTranslation: "From the evil of that which He created", juz: 30, page: 604),
      Ayah(surahId: 113, numberInSurah: 3, arabicText: "وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ", englishTranslation: "And from the evil of darkness when it settles", juz: 30, page: 604),
      Ayah(surahId: 113, numberInSurah: 4, arabicText: "وَمِن شَرِّ ٱلنَّفَّٰثَٰتِ فِي ٱلْعُقَدِ", englishTranslation: "And from the evil of the blowers in knots", juz: 30, page: 604),
      Ayah(surahId: 113, numberInSurah: 5, arabicText: "وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ", englishTranslation: "And from the evil of an envier when he envies.\"", juz: 30, page: 604),
    ],

    // 114. An-Nas
    114: [
      Ayah(surahId: 114, numberInSurah: 1, arabicText: "قُلْ أَعُوذُ بِرَبِّ ٱلنَّاسِ", englishTranslation: "Say, \"I seek refuge in the Lord of mankind,", juz: 30, page: 604),
      Ayah(surahId: 114, numberInSurah: 2, arabicText: "مَلِكِ ٱلنَّاسِ", englishTranslation: "The Sovereign of mankind,", juz: 30, page: 604),
      Ayah(surahId: 114, numberInSurah: 3, arabicText: "إِلَٰهِ ٱلنَّاسِ", englishTranslation: "The God of mankind,", juz: 30, page: 604),
      Ayah(surahId: 114, numberInSurah: 4, arabicText: "مِن شَرِّ ٱلْوَسْوَاسِ ٱلْخَنَّاسِ", englishTranslation: "From the evil of the retreating whisperer -", juz: 30, page: 604),
      Ayah(surahId: 114, numberInSurah: 5, arabicText: "ٱلَّذِي يُوَسْوِسُ فِي صُدُورِ ٱلنَّاسِ", englishTranslation: "Who whispers into the breasts of mankind -", juz: 30, page: 604),
      Ayah(surahId: 114, numberInSurah: 6, arabicText: "مِنَ ٱلْجِنَّةِ وَٱلنَّاسِ", englishTranslation: "From among the jinn and mankind.\"", juz: 30, page: 604),
    ],

  };
}
