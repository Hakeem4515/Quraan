// lib/l10n/app_strings.dart
// Centralized bilingual UI strings – Arabic & English.
// Usage: final s = AppStrings.of(isArabic);  then s.navQuran, etc.

class AppStrings {
  final bool isArabic;
  const AppStrings._(this.isArabic);

  static AppStrings of(bool isArabic) => AppStrings._(isArabic);

  // ── Bottom Navigation ────────────────────────────────────────────────────────
  String get navQuran    => isArabic ? 'المصحف'    : 'Quran';
  String get navJuz      => isArabic ? 'الأجزاء'   : 'Juz';
  String get navBookmark => isArabic ? 'المفضلة'   : 'Bookmarks';
  String get navSettings => isArabic ? 'الإعدادات' : 'Settings';

  // ── Settings Screen ──────────────────────────────────────────────────────────
  String get settingsTitle          => isArabic ? 'الإعدادات'                    : 'Settings';
  String get sectionAppearance      => isArabic ? 'المظهر'                       : 'APPEARANCE';
  String get sectionQuran           => isArabic ? 'القرآن'                       : 'QURAN';
  String get sectionLockscreen      => isArabic ? 'شاشة القفل'                   : 'LOCK SCREEN';
  String get sectionLanguage        => isArabic ? 'اللغة'                        : 'LANGUAGE';
  String get sectionAbout           => isArabic ? 'حول التطبيق'                  : 'ABOUT';

  String get settingTheme           => isArabic ? 'سمة التطبيق'                  : 'App Theme';
  String get settingFont            => isArabic ? 'حجم الخط والخط العربي'         : 'Arabic Font & Size';
  String get settingEnTranslation   => isArabic ? 'الترجمة الإنجليزية'            : 'English Translation';
  String get settingEnTransOn       => isArabic ? 'يظهر النص الإنجليزي مع الآية'  : 'English text shown with each verse';
  String get settingEnTransOff      => isArabic ? 'النص العربي فقط'               : 'Arabic text only';
  String get settingNavMode         => isArabic ? 'طريقة التنقل في المصحف'        : 'Quran Navigation Mode';
  String get settingNavModeHoriz    => isArabic ? 'السحب بالإصبع • كالمصحف المطبوع' : 'Finger Swipe • Like printed Mus-haf';
  String get settingNavModeVert     => isArabic ? 'تمرير رأسي • تمرير مستمر'            : 'Vertical Scroll • Continuous scroll';


  String get settingLockscreenAyah  => isArabic ? 'آية على شاشة القفل'            : 'Lock Screen Ayah';
  String get settingLockscreenOn    => isArabic ? 'مفعّل • Widget نشط على شاشة القفل' : 'Enabled • Widget active on lock screen';
  String get settingLockscreenOff   => isArabic ? 'معطّل • اضغط لتفعيل الميزة'    : 'Disabled • Tap to enable';
  String get settingUpdateMode      => isArabic ? 'طريقة تحديث الآية'             : 'Ayah Update Mode';
  String get settingRefreshNow      => isArabic ? 'تحديث الآية الآن'              : 'Refresh Ayah Now';
  String get settingWidgetAppear    => isArabic ? 'تخصيص مظهر Widget الآية'       : 'Customize Ayah Widget';
  String get settingWidgetAppearSub => isArabic ? 'الثيم، الشكل، حجم الخط، المحاذاة والعناصر' : 'Theme, shape, font size, alignment & elements';
  String get settingWidgetPreview   => isArabic ? 'معاينة الـ Widget'             : 'Widget Preview';
  String get settingWidgetHint      => isArabic
      ? 'لإضافة الـ Widget: اضغط مطولاً على الشاشة الرئيسية ← Widgets ← القرآن الكريم'
      : 'To add Widget: long press Home screen → Widgets → Al-Quran';

  String get updateModeByTime       => isArabic ? 'حسب الوقت'            : 'By Time';
  String get updateModeByTimeSub    => isArabic ? 'تحديث دوري منتظم'     : 'Regular periodic update';
  String get updateModeCustom       => isArabic ? 'فترة مخصصة'           : 'Custom Interval';
  String get updateModeCustomSub    => isArabic ? 'حدد المدة بنفسك'      : 'Set your own interval';
  String get updateModeScreenOff    => isArabic ? 'عند إطفاء الشاشة'     : 'On Screen Off';
  String get updateModeScreenOffSub => isArabic ? 'موفر للطاقة جداً'     : 'Very battery-friendly';

  String get chipEveryHour => isArabic ? 'كل ساعة'    : '1 hour';
  String get chip3Hours    => isArabic ? 'كل 3 ساعات' : '3 hours';
  String get chip6Hours    => isArabic ? 'كل 6 ساعات' : '6 hours';
  String get chip12Hours   => isArabic ? 'كل 12 ساعة' : '12 hours';
  String get chipDaily     => isArabic ? 'يومياً'      : 'Daily';
  String get chip15Min     => isArabic ? '15 دقيقة'   : '15 min';
  String get chip30Min     => isArabic ? '30 دقيقة'   : '30 min';
  String get chip45Min     => isArabic ? '45 دقيقة'   : '45 min';
  String get chip2Hours    => isArabic ? 'ساعتان'     : '2 hours';
  String get chip5Hours    => isArabic ? '5 ساعات'    : '5 hours';

  String get languageTitle  => isArabic ? 'لغة التطبيق'      : 'App Language';
  String get langArabic     => isArabic ? 'العربية'           : 'Arabic';
  String get langArabicSub  => isArabic ? 'واجهة عربية كاملة' : 'Full Arabic interface';
  String get langEnglish    => isArabic ? 'الإنجليزية'        : 'English';
  String get langEnglishSub => isArabic ? 'Full English interface' : 'Full English interface';

  String get developerLabel => isArabic ? 'المطور' : 'Developer';
  String get developerName  => isArabic ? 'عبدالحكيم حيدر' : 'Abdulhakeem Haider';

  String get aboutApp     => isArabic ? 'القرآن الكريم • Al-Quran Al-Kareem' : 'Al-Quran Al-Kareem';
  String get aboutVersion => isArabic ? 'الإصدار 1.0.0' : 'Version 1.0.0';
  String get aboutTitle   => isArabic ? 'حول التطبيق'   : 'About App';
  String get aboutContent => isArabic
      ? 'تطبيق القرآن الكريم الإصدار 1.0.0\n\nيتضمن:\n• قراءة القرآن كاملاً\n• خطوط عربية متعددة\n• ترجمة إنجليزية\n• إشارات مرجعية\n• Widget آية على شاشة القفل\n• ثيمات متعددة للمظهر'
      : 'Al-Quran Al-Kareem v1.0.0\n\nFeatures:\n• Full Quran reading\n• Multiple Arabic fonts\n• English translation\n• Bookmarks\n• Lock screen ayah widget\n• Multiple app themes';
  String get ok => isArabic ? 'حسناً' : 'OK';

  String get chooseTheme     => isArabic ? 'اختر سمة التطبيق' : 'Choose App Theme';
  String get chooseFontTitle => isArabic ? 'إعدادات الخط'    : 'Font Settings';
  String get fontType        => isArabic ? 'نوع الخط'         : 'Font Type';
  String get fontWeightLabel => isArabic ? 'سمك الخط'         : 'Font Weight';
  String get fontSizeLabel   => isArabic ? 'حجم الخط'         : 'Font Size';
  String get lineSpacing     => isArabic ? 'تباعد الأسطر'     : 'Line Spacing';

  String get chooseNavMode   => isArabic ? 'طريقة التنقل في المصحف' : 'Quran Navigation Mode';
  String get navHoriz        => isArabic ? 'السحب بالإصبع (أفقي)' : 'Finger Swipe (Horizontal)';
  String get navHorizSub     => isArabic ? 'سحب يميناً ويساراً كالمصحف (604 صفحة)' : 'Swipe right & left like printed Mus-haf (604 pages)';
  String get navVert         => isArabic ? 'تمرير رأسي'       : 'Vertical Scroll';
  String get navVertSub      => isArabic ? 'تمرير مستمر لآيات السورة' : 'Continuous surah scrolling';

  // Font labels
  String get fontAmiri     => isArabic ? 'خط الأميري'    : 'Amiri';
  String get fontNaskh     => isArabic ? 'خط شهرزاد'     : 'Scheherazade';
  String get fontHafs      => isArabic ? 'الخط العثماني' : 'Uthmanic Script';
  String get fontSystem    => isArabic ? 'الخط القياسي'  : 'System Font';
  String get fontNormal    => isArabic ? 'عادي'           : 'Normal';
  String get fontBold      => isArabic ? 'عريض'           : 'Bold';
  String get fontHeavy     => isArabic ? 'ثقيل'           : 'Heavy';
  String get spacingClose  => isArabic ? 'متقارب'         : 'Compact';
  String get spacingNormal => isArabic ? 'قياسي'          : 'Normal';
  String get spacingWide   => isArabic ? 'متباعد'         : 'Wide';

  // ── Surah List Screen ────────────────────────────────────────────────────────
  String get appTitle     => isArabic ? 'القرآن الكريم'              : 'Al-Quran';
  String get searchHint   => isArabic ? 'بحث باسم السورة أو رقمها...' : 'Search surah name or number...';
  String get filterAll    => isArabic ? 'الكل'  : 'All';
  String get filterMeccan => isArabic ? 'مكية'  : 'Meccan';
  String get filterMedian => isArabic ? 'مدنية' : 'Medinan';

  // ── Juz Screen ───────────────────────────────────────────────────────────────
  String get juzScreenTitle => isArabic ? 'أجزاء القرآن الكريم (30 جزء)' : '30 Juz of the Holy Quran';
  String juzNumber(int n)   => isArabic ? 'الجزء $n'    : 'Juz $n';
  String get juzStartAt     => isArabic ? 'بداية الجزء:' : 'Starts at:';

  // ── Bookmarks Screen ─────────────────────────────────────────────────────────
  String get bookmarksTitle    => isArabic ? 'الآيات المحفوظة'            : 'Bookmarks';
  String get bookmarksEmpty    => isArabic ? 'لا توجد آيات محفوظة حالياً' : 'No Bookmarks Yet';
  String get bookmarksEmptySub => isArabic
      ? 'اضغط على أيقونة المفضلة بأي آية أثناء القراءة لحفظها هنا والوصول إليها بسرعة.'
      : 'Tap the bookmark icon on any ayah while reading to save it here.';
  String ayahLabel(int n) => isArabic ? 'الآية $n' : 'Ayah $n';

  // ── Surah Detail Screen ──────────────────────────────────────────────────────
  String surahTitle(String nameAr, String nameEn) =>
      isArabic ? 'سورة $nameAr' : 'Surah $nameEn';
  String versesInfo(String type, int count) {
    final typeLabel = type == 'Meccan'
        ? (isArabic ? 'مكية' : 'Meccan')
        : (isArabic ? 'مدنية' : 'Medinan');
    return isArabic ? '$typeLabel • $count آيات' : '$typeLabel • $count Verses';
  }

  String get readingSettingsTitle => isArabic ? 'إعدادات القراءة' : 'Reading Settings';
  String get readingNavMode       => isArabic ? 'طريقة التنقل'   : 'Navigation Mode';
  String get readingTranslation   => isArabic ? 'الترجمة'        : 'Translation';
  String get readingFontSize      => isArabic ? 'حجم الخط'       : 'Font Size';
  String get readingViewMode      => isArabic ? 'طريقة العرض'    : 'View Mode';

  String get tooltipHorizSwipe => isArabic ? 'التمرير الأفقي مفعّل'    : 'Horizontal swipe active';
  String get tooltipVertSwipe  => isArabic ? 'التمرير العمودي مفعّل'   : 'Vertical scroll active';
  String get tooltipShowTrans  => isArabic ? 'إظهار الترجمة الإنجليزية' : 'Show English translation';
  String get tooltipHideTrans  => isArabic ? 'إخفاء الترجمة الإنجليزية' : 'Hide English translation';
  String get tooltipListView   => isArabic ? 'عرض القائمة'  : 'List view';
  String get tooltipMushafView => isArabic ? 'عرض المصحف'   : 'Mus-haf view';
  String get tooltipDecrFont   => isArabic ? 'تصغير الخط'   : 'Decrease font';
  String get tooltipIncrFont   => isArabic ? 'تكبير الخط'   : 'Increase font';



  String get copySuccess  => isArabic ? 'تم نسخ الآية إلى الحافظة' : 'Ayah copied to clipboard';
  String bookmarkAdded(int n)   => isArabic ? 'تم حفظ الآية $n في المفضلة'   : 'Ayah $n bookmarked';
  String bookmarkRemoved(int n) => isArabic ? 'تم إزالة الآية $n من المفضلة' : 'Ayah $n removed';
  String bookmark(bool marked) => isArabic ? (marked ? 'إزالة' : 'حفظ')      : (marked ? 'Remove' : 'Bookmark');

  String actionSheetTitle(String nameAr, String nameEn, int ayahNum) =>
      isArabic ? 'سورة $nameAr (الآية $ayahNum)' : 'Surah $nameEn (Ayah $ayahNum)';

  String get snackbarRefreshed => isArabic ? 'تم تحديث الـ Widget بآية جديدة' : 'Widget updated with a new ayah';
  String currentAyahLabel(String surahName, int ayahNum) =>
      isArabic ? 'الآية الحالية: $surahName آية $ayahNum' : 'Current: $surahName – Ayah $ayahNum';
  String get refreshAyahHint => isArabic ? 'اضغط لاختيار آية جديدة عشوائية' : 'Tap to pick a new random ayah';

  String pageOf(int page, int total) =>
      isArabic ? 'صفحة $page من $total' : 'Page $page of $total';

  // ── Hero Last Read Card ────────────────────────────────────────────────────────
  String get lastRead     => isArabic ? 'آخر قراءة'      : 'LAST READ';
  String ayahNum(int n)   => isArabic ? 'الآية رقم $n'   : 'Ayah No. $n';
  String get continueRead => isArabic ? 'متابعة القراءة' : 'Continue Reading';

  // ── Khatmah Feature ──────────────────────────────────────────────────────────
  String get khatmahTitle       => isArabic ? 'ختمة القرآن'             : 'Quran Khatmah';
  String get startKhatmah       => isArabic ? 'بدء ختمة'               : 'Start Khatmah';
  String get startNewKhatmah    => isArabic ? 'بدء ختمة جديدة'         : 'Start New Khatmah';
  String get continueKhatmah    => isArabic ? 'متابعة الختمة'          : 'Continue Khatmah';
  String get khatmahHistory     => isArabic ? 'سجل الختمات'            : 'Khatmah History';
  String get khatmahInProgress  => isArabic ? 'قيد التقدم'             : 'In Progress';
  String get khatmahCompleted   => isArabic ? 'مكتملة'                 : 'Completed';
  String get khatmahStartedAt   => isArabic ? 'تاريخ البدء:'           : 'Started:';
  String get khatmahCompletedAt => isArabic ? 'تاريخ الإكمال:'         : 'Completed:';
  String get khatmahCardDesc    => isArabic
      ? 'ابدأ رحلة ختم القرآن الكريم وتابع تقدمك تلقائياً صفحة بصفحة'
      : 'Start your Quran Khatmah journey and track your progress automatically';
  String get khatmahCongratTitle => isArabic
      ? 'مبارك! أتممت ختم القرآن الكريم.'
      : 'Congratulations! You have completed the Holy Quran.';
  String get khatmahCongratSub => isArabic
      ? 'تقبل الله منا ومنكم صالح الأعمال وجعله شفيعاً لنا ولكم يوم القيامة.'
      : 'May Allah accept it from us and grant you immense blessings.';
  String get khatmahConfirmTitle => isArabic
      ? 'لديك ختمة قيد التقدم'
      : 'Khatmah In Progress';
  String get khatmahConfirmContent => isArabic
      ? 'لديك ختمة حالية قيد التقدم. هل تريد متابعتها أم بدء ختمة جديدة؟'
      : 'You have a Khatmah in progress. Would you like to continue it or start a new one?';
  String get khatmahCancel       => isArabic ? 'إلغاء'                  : 'Cancel';
  String get khatmahNoHistory    => isArabic
      ? 'لا توجد ختمات مسجلة حتى الآن'
      : 'No recorded Khatmahs yet';
  String khatmahIndexTitle(int n) => isArabic ? 'الختمة رقم $n' : 'Khatmah #$n';
  String khatmahPageProgress(int page, int total, String pct) => isArabic
      ? 'الصفحة $page من $total ($pct%)'
      : 'Page $page of $total ($pct%)';
  String khatmahProgressLabel(String pct) => isArabic
      ? 'التقدم $pct%'
      : 'Progress $pct%';

  // ── Errors ───────────────────────────────────────────────────────────────────
  String get errorLoadAyahs => isArabic ? 'خطأ في تحميل آيات السورة' : 'Error loading surah verses';

  // ── Surah Picker ─────────────────────────────────────────────────────────────
  String get surahPickerTitle      => isArabic ? 'اختر السورة'           : 'Choose Surah';
  String get surahPickerSearchHint => isArabic ? 'بحث باسم السورة أو رقمها...' : 'Search surah name or number...';
}