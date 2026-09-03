package com.example.quraan.quraan

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.Typeface
import android.os.Build
import android.os.SystemClock
import android.text.Layout
import android.text.StaticLayout
import android.text.TextDirectionHeuristics
import android.text.TextPaint
import android.text.TextUtils
import android.util.Log
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.widget.RemoteViews
import org.json.JSONArray
import java.io.InputStream
import kotlin.random.Random

object QuranWidgetUpdater {
    private const val TAG = "QuranWidget"
    const val PREFS_NAME = "QuranLockscreenWidgetPrefs"
    const val KEY_ENABLED = "is_widget_enabled"
    const val KEY_UPDATE_MODE = "update_mode" // "byTime", "custom", "screenOff"
    const val KEY_INTERVAL_MINUTES = "interval_minutes"
    const val KEY_CUSTOM_MINUTES = "custom_minutes"
    const val KEY_LAST_SURAH_ID = "last_surah_id"
    const val KEY_LAST_AYAH_NUM = "last_ayah_num"
    const val KEY_LAST_SURAH_NAME = "last_surah_name"
    const val KEY_LAST_AYAH_TEXT = "last_ayah_text"

    // Widget Appearance Keys
    const val KEY_WIDGET_THEME = "widget_theme"            // 0=classic, 1=emerald, 2=dark, 3=minimal, 4=midnight
    const val KEY_WIDGET_SHAPE = "widget_shape"            // 0=rounded, 1=square, 2=card, 3=minimal, 4=islamic
    const val KEY_WIDGET_AYAH_FONT_SIZE = "widget_ayah_font_size"
    const val KEY_WIDGET_SURAH_FONT_SIZE = "widget_surah_font_size"
    const val KEY_WIDGET_TEXT_ALIGN = "widget_text_align"  // 0=center, 1=right
    const val KEY_WIDGET_SHOW_SURAH_NAME = "widget_show_surah_name"
    const val KEY_WIDGET_SHOW_AYAH_NUMBER = "widget_show_ayah_number"
    const val KEY_WIDGET_SHOW_AYAH_TEXT = "widget_show_ayah_text"
    const val KEY_WIDGET_SHOW_DECORATION = "widget_show_decoration"
    const val KEY_WIDGET_SHOW_APP_NAME = "widget_show_app_name"
    const val KEY_WIDGET_FONT_FAMILY = "widget_font_family" // 0=amiri, 1=naskh, 2=hafs/uthmani, 3=system

    // [themeIndex][shapeIndex] background drawables matrix
    private val THEME_SHAPE_BG_DRAWABLES = arrayOf(
        // Theme 0: Classic
        intArrayOf(
            R.drawable.widget_bg_classic_rounded,
            R.drawable.widget_bg_classic_square,
            R.drawable.widget_bg_classic_card,
            R.drawable.widget_bg_classic_minimal,
            R.drawable.widget_bg_classic_islamic
        ),
        // Theme 1: Emerald
        intArrayOf(
            R.drawable.widget_bg_emerald_rounded,
            R.drawable.widget_bg_emerald_square,
            R.drawable.widget_bg_emerald_card,
            R.drawable.widget_bg_emerald_minimal,
            R.drawable.widget_bg_emerald_islamic
        ),
        // Theme 2: Dark
        intArrayOf(
            R.drawable.widget_bg_dark_rounded,
            R.drawable.widget_bg_dark_square,
            R.drawable.widget_bg_dark_card,
            R.drawable.widget_bg_dark_minimal,
            R.drawable.widget_bg_dark_islamic
        ),
        // Theme 3: Minimal
        intArrayOf(
            R.drawable.widget_bg_minimal_rounded,
            R.drawable.widget_bg_minimal_square,
            R.drawable.widget_bg_minimal_card,
            R.drawable.widget_bg_minimal_minimal,
            R.drawable.widget_bg_minimal_islamic
        ),
        // Theme 4: Midnight
        intArrayOf(
            R.drawable.widget_bg_midnight_rounded,
            R.drawable.widget_bg_midnight_square,
            R.drawable.widget_bg_midnight_card,
            R.drawable.widget_bg_midnight_minimal,
            R.drawable.widget_bg_midnight_islamic
        )
    )

    // Theme Text Colors
    private val THEME_TEXT = intArrayOf(
        Color.parseColor("#FDFBF7"),  // classic
        Color.parseColor("#F4F9F6"),  // emerald
        Color.parseColor("#F1F5F9"),  // dark
        Color.parseColor("#1E293B"),  // minimal
        Color.parseColor("#E2E8F0")   // midnight
    )
    private val THEME_ACCENT = intArrayOf(
        Color.parseColor("#C5A059"),  // classic
        Color.parseColor("#D4AF37"),  // emerald
        Color.parseColor("#2DD4BF"),  // dark
        Color.parseColor("#0F5A47"),  // minimal
        Color.parseColor("#A78BFA")   // midnight
    )
    private val THEME_BADGE_TEXT = intArrayOf(
        Color.parseColor("#E6D3A3"),  // classic
        Color.parseColor("#F4D068"),  // emerald
        Color.parseColor("#7EEAE2"),  // dark
        Color.parseColor("#0F5A47"),  // minimal
        Color.parseColor("#C4B5FD")   // midnight
    )
    private val THEME_REFRESH_BG = intArrayOf(
        Color.parseColor("#29C5A059"), // classic
        Color.parseColor("#29D4AF37"), // emerald
        Color.parseColor("#292DD4BF"), // dark
        Color.parseColor("#1F0F5A47"), // minimal
        Color.parseColor("#29A78BFA")  // midnight
    )

    const val ACTION_REFRESH_WIDGET = "com.example.quraan.quraan.ACTION_REFRESH_WIDGET"
    const val ACTION_ALARM_TICK = "com.example.quraan.quraan.ACTION_ALARM_TICK"

    private const val ALARM_REQUEST_CODE = 9002

    fun getPrefs(context: Context): SharedPreferences {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }

    private fun getFlutterPrefs(context: Context): SharedPreferences {
        return context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
    }

    private fun getWidgetThemeIndex(context: Context): Int {
        val prefs = getPrefs(context)
        if (prefs.contains(KEY_WIDGET_THEME)) {
            return prefs.getInt(KEY_WIDGET_THEME, 0).coerceIn(0, 4)
        }
        try {
            val fp = getFlutterPrefs(context)
            val v = fp.all["flutter.$KEY_WIDGET_THEME"]
            if (v is Number) return v.toInt().coerceIn(0, 4)
        } catch (_: Exception) {}
        return 0
    }

    private fun getWidgetShapeIndex(context: Context): Int {
        val prefs = getPrefs(context)
        if (prefs.contains(KEY_WIDGET_SHAPE)) {
            return prefs.getInt(KEY_WIDGET_SHAPE, 0).coerceIn(0, 4)
        }
        try {
            val fp = getFlutterPrefs(context)
            val v = fp.all["flutter.$KEY_WIDGET_SHAPE"]
            if (v is Number) return v.toInt().coerceIn(0, 4)
        } catch (_: Exception) {}
        return 0
    }

    private fun getWidgetAyahFontSize(context: Context): Float {
        val prefs = getPrefs(context)
        if (prefs.contains(KEY_WIDGET_AYAH_FONT_SIZE)) {
            return prefs.getFloat(KEY_WIDGET_AYAH_FONT_SIZE, 15f)
        }
        try {
            val fp = getFlutterPrefs(context)
            val v = fp.all["flutter.$KEY_WIDGET_AYAH_FONT_SIZE"]
            if (v is Number) return v.toFloat()
            if (v is String) return v.toFloatOrNull() ?: 15f
        } catch (_: Exception) {}
        return 15f
    }

    private fun getWidgetSurahFontSize(context: Context): Float {
        val prefs = getPrefs(context)
        if (prefs.contains(KEY_WIDGET_SURAH_FONT_SIZE)) {
            return prefs.getFloat(KEY_WIDGET_SURAH_FONT_SIZE, 11f)
        }
        try {
            val fp = getFlutterPrefs(context)
            val v = fp.all["flutter.$KEY_WIDGET_SURAH_FONT_SIZE"]
            if (v is Number) return v.toFloat()
            if (v is String) return v.toFloatOrNull() ?: 11f
        } catch (_: Exception) {}
        return 11f
    }

    private fun getWidgetTextAlign(context: Context): Int {
        val prefs = getPrefs(context)
        if (prefs.contains(KEY_WIDGET_TEXT_ALIGN)) {
            return prefs.getInt(KEY_WIDGET_TEXT_ALIGN, 0)
        }
        try {
            val fp = getFlutterPrefs(context)
            val v = fp.all["flutter.$KEY_WIDGET_TEXT_ALIGN"]
            if (v is Number) return v.toInt()
        } catch (_: Exception) {}
        return 0
    }

    private fun getWidgetShowSurahName(context: Context): Boolean {
        val prefs = getPrefs(context)
        if (prefs.contains(KEY_WIDGET_SHOW_SURAH_NAME)) {
            return prefs.getBoolean(KEY_WIDGET_SHOW_SURAH_NAME, true)
        }
        try {
            val fp = getFlutterPrefs(context)
            val v = fp.all["flutter.$KEY_WIDGET_SHOW_SURAH_NAME"]
            if (v is Boolean) return v
        } catch (_: Exception) {}
        return true
    }

    private fun getWidgetShowAyahNumber(context: Context): Boolean {
        val prefs = getPrefs(context)
        if (prefs.contains(KEY_WIDGET_SHOW_AYAH_NUMBER)) {
            return prefs.getBoolean(KEY_WIDGET_SHOW_AYAH_NUMBER, true)
        }
        try {
            val fp = getFlutterPrefs(context)
            val v = fp.all["flutter.$KEY_WIDGET_SHOW_AYAH_NUMBER"]
            if (v is Boolean) return v
        } catch (_: Exception) {}
        return true
    }

    private fun getWidgetShowAyahText(context: Context): Boolean {
        val prefs = getPrefs(context)
        if (prefs.contains(KEY_WIDGET_SHOW_AYAH_TEXT)) {
            return prefs.getBoolean(KEY_WIDGET_SHOW_AYAH_TEXT, true)
        }
        try {
            val fp = getFlutterPrefs(context)
            val v = fp.all["flutter.$KEY_WIDGET_SHOW_AYAH_TEXT"]
            if (v is Boolean) return v
        } catch (_: Exception) {}
        return true
    }

    private fun getWidgetShowAppName(context: Context): Boolean {
        val prefs = getPrefs(context)
        if (prefs.contains(KEY_WIDGET_SHOW_APP_NAME)) {
            return prefs.getBoolean(KEY_WIDGET_SHOW_APP_NAME, true)
        }
        try {
            val fp = getFlutterPrefs(context)
            val v = fp.all["flutter.$KEY_WIDGET_SHOW_APP_NAME"]
            if (v is Boolean) return v
        } catch (_: Exception) {}
        return true
    }

    data class QuranAyahItem(
        val surahId: Int,
        val surahName: String,
        val ayahNumber: Int,
        val text: String
    )

    private var cachedAyahs: List<QuranAyahItem>? = null

    private fun loadAyahs(context: Context): List<QuranAyahItem> {
        cachedAyahs?.let { return it }

        val list = mutableListOf<QuranAyahItem>()
        try {
            val assetManager = context.assets
            val possiblePaths = listOf(
                "flutter_assets/assets/data/quran_cleaned.json",
                "assets/data/quran_cleaned.json",
                "quran_cleaned.json"
            )

            var inputStream: InputStream? = null
            for (path in possiblePaths) {
                try {
                    inputStream = assetManager.open(path)
                    if (inputStream != null) {
                        Log.d(TAG, "Successfully opened Quran asset at path: $path")
                        break
                    }
                } catch (_: Exception) {}
            }

            if (inputStream != null) {
                val jsonStr = inputStream.bufferedReader().use { it.readText() }
                val surahsArray = JSONArray(jsonStr)
                for (i in 0 until surahsArray.length()) {
                    val sObj = surahsArray.getJSONObject(i)
                    val sId = sObj.getInt("id")
                    val sName = sObj.getString("nameArabic")
                    val ayahsArray = sObj.getJSONArray("ayahs")
                    for (j in 0 until ayahsArray.length()) {
                        val aObj = ayahsArray.getJSONObject(j)
                        val num = aObj.getInt("numberInSurah")
                        val text = aObj.getString("arabicText")
                        list.add(QuranAyahItem(sId, sName, num, text))
                    }
                }
                Log.d(TAG, "Loaded ${list.size} Ayahs from asset JSON")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error loading Quran assets: ${e.message}", e)
        }

        if (list.isEmpty()) {
            Log.w(TAG, "Asset list is empty, using fallback core Ayahs")
            list.add(QuranAyahItem(1, "الفاتحة", 1, "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ"))
            list.add(QuranAyahItem(1, "الفاتحة", 2, "ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ"))
            list.add(QuranAyahItem(2, "البقرة", 255, "ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلْحَىُّ ٱلْقَيُّومُ ۚ لَا تَأْخُذُهُۥ سِنَةٌ وَلَا نَوْمٌ ۚ"))
            list.add(QuranAyahItem(112, "الإخلاص", 1, "قُلْ هُوَ ٱللَّهُ أَحَدٌ"))
            list.add(QuranAyahItem(113, "الفلق", 1, "قُلْ أَعُوذُ بِرَبِّ ٱلْفَلَقِ"))
            list.add(QuranAyahItem(114, "الناس", 1, "قُلْ أَعُوذُ بِرَبِّ ٱلنَّاسِ"))
        }

        cachedAyahs = list
        return list
    }

    fun pickRandomAyah(context: Context): QuranAyahItem {
        val ayahs = loadAyahs(context)
        val prefs = getPrefs(context)
        val lastSurah = prefs.getInt(KEY_LAST_SURAH_ID, -1)
        val lastAyah = prefs.getInt(KEY_LAST_AYAH_NUM, -1)

        if (ayahs.size <= 1) return ayahs[0]

        var selected: QuranAyahItem
        var attempts = 0
        do {
            val randomIndex = Random.nextInt(ayahs.size)
            selected = ayahs[randomIndex]
            attempts++
        } while (attempts < 10 && selected.surahId == lastSurah && selected.ayahNumber == lastAyah)

        prefs.edit()
            .putInt(KEY_LAST_SURAH_ID, selected.surahId)
            .putInt(KEY_LAST_AYAH_NUM, selected.ayahNumber)
            .putString(KEY_LAST_SURAH_NAME, selected.surahName)
            .putString(KEY_LAST_AYAH_TEXT, selected.text)
            .apply()

        Log.d(TAG, "Picked Ayah: Surah ${selected.surahName} (${selected.surahId}), Ayah ${selected.ayahNumber}")
        return selected
    }

    // Helper to draw a crisp Quran book bitmap icon safely for RemoteViews
    private fun createBookIconBitmap(color: Int = Color.parseColor("#C5A059")): Bitmap {
        val size = 48
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            this.color = color
            style = Paint.Style.STROKE
            strokeWidth = 3.5f
            strokeCap = Paint.Cap.ROUND
            strokeJoin = Paint.Join.ROUND
        }

        val path = Path().apply {
            // Left page
            moveTo(6f, 12f)
            lineTo(6f, 38f)
            cubicTo(12f, 35f, 18f, 35f, 24f, 38f)
            lineTo(24f, 12f)
            cubicTo(18f, 9f, 12f, 9f, 6f, 12f)
            close()

            // Right page
            moveTo(42f, 12f)
            lineTo(42f, 38f)
            cubicTo(36f, 35f, 30f, 35f, 24f, 38f)
            lineTo(24f, 12f)
            cubicTo(30f, 9f, 36f, 9f, 42f, 12f)
            close()
        }
        canvas.drawPath(path, paint)
        return bitmap
    }

    // Helper to draw a refresh icon bitmap with matching theme circular background safely for RemoteViews
    private fun createRefreshIconBitmap(iconColor: Int, bgColor: Int): Bitmap {
        val size = 56
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        // Background Circle
        val bgPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            this.color = bgColor
            style = Paint.Style.FILL
        }
        canvas.drawCircle(size / 2f, size / 2f, size / 2f - 2f, bgPaint)

        // Border Circle
        val borderPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            this.color = iconColor
            alpha = 70
            style = Paint.Style.STROKE
            strokeWidth = 1.8f
        }
        canvas.drawCircle(size / 2f, size / 2f, size / 2f - 2f, borderPaint)

        // Refresh Arc
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            this.color = iconColor
            style = Paint.Style.STROKE
            strokeWidth = 3.5f
            strokeCap = Paint.Cap.ROUND
        }
        canvas.drawArc(15f, 15f, 41f, 41f, 45f, 270f, false, paint)

        // Refresh Arrow Head
        val arrowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            this.color = iconColor
            style = Paint.Style.FILL_AND_STROKE
            strokeWidth = 2f
        }
        val arrowPath = Path().apply {
            moveTo(38f, 20f)
            lineTo(44f, 27f)
            lineTo(35f, 29f)
            close()
        }
        canvas.drawPath(arrowPath, arrowPaint)
        return bitmap
    }

    fun getWidgetFontFamily(context: Context): Int {
        return getPrefs(context).getInt(KEY_WIDGET_FONT_FAMILY, 0)
    }

    fun getQuranTypeface(context: Context, fontIndex: Int): Typeface {
        return try {
            val assetPath = when (fontIndex) {
                0 -> "fonts/Amiri-Bold.ttf"
                1 -> "fonts/ScheherazadeNew-Bold.ttf"
                2 -> "fonts/NotoNaskhArabic-Regular.ttf"
                else -> null
            }
            if (assetPath != null) {
                Typeface.createFromAsset(context.assets, assetPath)
            } else {
                Typeface.DEFAULT_BOLD
            }
        } catch (e: Exception) {
            Log.w(TAG, "Failed to load typeface from asset (index $fontIndex): ${e.message}")
            Typeface.DEFAULT_BOLD
        }
    }

    // Helper to render Quran Ayah text into crisp Bitmap with the selected Arabic font, size, alignment, and Harakat
    private fun createAyahTextBitmap(
        context: Context,
        text: String,
        fontIndex: Int,
        fontSizeSp: Float,
        textColor: Int,
        textAlign: Int,
        targetWidthPx: Int = 800
    ): Bitmap {
        val density = context.resources.displayMetrics.density
        val textSizePx = fontSizeSp * density * 1.05f
        val typeface = getQuranTypeface(context, fontIndex)

        val textPaint = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
            this.color = textColor
            this.textSize = textSizePx
            this.typeface = typeface
        }

        val alignment = if (textAlign == 1) Layout.Alignment.ALIGN_NORMAL else Layout.Alignment.ALIGN_CENTER
        val width = targetWidthPx.coerceAtLeast(320)

        val staticLayout = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            StaticLayout.Builder.obtain(text, 0, text.length, textPaint, width)
                .setAlignment(alignment)
                .setLineSpacing(4f * density, 1.15f)
                .setIncludePad(true)
                .setTextDirection(TextDirectionHeuristics.RTL)
                .setMaxLines(4)
                .setEllipsize(TextUtils.TruncateAt.END)
                .build()
        } else {
            @Suppress("DEPRECATION")
            StaticLayout(
                text, textPaint, width,
                alignment, 1.15f, 4f * density, true
            )
        }

        val height = (staticLayout.height + (10 * density).toInt()).coerceAtLeast(40)
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        canvas.save()
        canvas.translate(0f, 4f * density)
        staticLayout.draw(canvas)
        canvas.restore()

        return bitmap
    }

    fun updateAllWidgets(context: Context, targetWidgetIds: IntArray? = null, forceNew: Boolean = false) {
        try {
            val appWidgetManager = AppWidgetManager.getInstance(context) ?: return
            val componentName = ComponentName(context, QuranLockscreenWidgetProvider::class.java)
            val appWidgetIds = if (targetWidgetIds != null && targetWidgetIds.isNotEmpty()) {
                targetWidgetIds
            } else {
                appWidgetManager.getAppWidgetIds(componentName)
            }

            if (appWidgetIds == null || appWidgetIds.isEmpty()) {
                Log.d(TAG, "No active widget IDs found to update")
                return
            }

            Log.d(TAG, "Updating widgets: ${appWidgetIds.joinToString()} (forceNew=$forceNew)")

            val prefs = getPrefs(context)
            val item = if (forceNew) {
                pickRandomAyah(context)
            } else {
                val sId = prefs.getInt(KEY_LAST_SURAH_ID, -1)
                val aNum = prefs.getInt(KEY_LAST_AYAH_NUM, -1)
                val sName = prefs.getString(KEY_LAST_SURAH_NAME, null)
                val text = prefs.getString(KEY_LAST_AYAH_TEXT, null)

                if (sId != -1 && aNum != -1 && sName != null && text != null) {
                    QuranAyahItem(sId, sName, aNum, text)
                } else {
                    pickRandomAyah(context)
                }
            }

            // ── Read Widget Appearance & Font Settings ────────────────────
            val themeIndex = getWidgetThemeIndex(context)
            val shapeIndex = getWidgetShapeIndex(context)
            val fontIndex = getWidgetFontFamily(context)
            val textColor = THEME_TEXT[themeIndex]
            val accentColor = THEME_ACCENT[themeIndex]
            val badgeTextColor = THEME_BADGE_TEXT[themeIndex]
            val refreshBgColor = THEME_REFRESH_BG[themeIndex]
            val ayahFontSize = getWidgetAyahFontSize(context)
            val surahFontSize = getWidgetSurahFontSize(context)
            val textAlign = getWidgetTextAlign(context)
            val showSurahName = getWidgetShowSurahName(context)
            val showAyahNumber = getWidgetShowAyahNumber(context)
            val showAyahText = getWidgetShowAyahText(context)
            val showAppName = getWidgetShowAppName(context)

            val bgResId = THEME_SHAPE_BG_DRAWABLES[themeIndex][shapeIndex]

            Log.d(TAG, "Applying theme=$themeIndex shape=$shapeIndex font=$fontIndex bgResId=$bgResId ayahSize=$ayahFontSize textAlign=$textAlign")

            val bookBitmap = createBookIconBitmap(accentColor)
            val refreshBitmap = createRefreshIconBitmap(badgeTextColor, refreshBgColor)
            val ayahBitmap = createAyahTextBitmap(context, item.text, fontIndex, ayahFontSize, textColor, textAlign)

            val cleanSurahName = if (item.surahName.startsWith("سورة") ||
                                     item.surahName.startsWith("سُورَةُ") ||
                                     item.surahName.startsWith("سُورَة")) {
                item.surahName
            } else {
                "سورة ${item.surahName}"
            }

            for (appWidgetId in appWidgetIds) {
                val views = RemoteViews(context.packageName, R.layout.quran_lockscreen_widget)

                // ── Apply Theme Background via Safe RemoteViews ImageView ───
                views.setImageViewResource(R.id.iv_widget_bg, bgResId)

                // ── Text Content ────────────────────────────────────────
                views.setTextViewText(R.id.tv_surah_name, cleanSurahName)
                views.setTextViewText(R.id.tv_ayah_num, "آية ${item.ayahNumber}")
                views.setTextViewText(R.id.tv_app_title, "القرآن الكريم")

                // ── Ayah Text with Selected Custom Font Bitmap ──────────
                views.setImageViewBitmap(R.id.iv_ayah_text, ayahBitmap)

                // ── Visibility ──────────────────────────────────────────
                views.setViewVisibility(R.id.iv_icon, if (showAppName) View.VISIBLE else View.GONE)
                views.setViewVisibility(R.id.tv_app_title, if (showAppName) View.VISIBLE else View.GONE)
                views.setViewVisibility(R.id.tv_surah_name, if (showSurahName) View.VISIBLE else View.GONE)
                views.setViewVisibility(R.id.tv_ayah_num, if (showAyahNumber) View.VISIBLE else View.GONE)
                views.setViewVisibility(R.id.iv_ayah_text, if (showAyahText) View.VISIBLE else View.GONE)
                views.setViewVisibility(R.id.tv_ayah_text, View.GONE)

                // ── Apply Theme Text Colors ──────────────────────────────
                views.setTextColor(R.id.tv_app_title, accentColor)
                views.setTextColor(R.id.tv_surah_name, badgeTextColor)
                views.setTextColor(R.id.tv_ayah_num, accentColor)

                // ── Safe RemoteViews Font Sizes ─────────────────────────
                views.setTextViewTextSize(R.id.tv_surah_name, TypedValue.COMPLEX_UNIT_SP, surahFontSize)
                views.setTextViewTextSize(R.id.tv_ayah_num, TypedValue.COMPLEX_UNIT_SP, (surahFontSize - 1f).coerceAtLeast(8f))

                // ── Safe Bitmaps ─────────────────────────────────────────
                views.setImageViewBitmap(R.id.iv_icon, bookBitmap)
                views.setImageViewBitmap(R.id.btn_refresh_widget, refreshBitmap)

                // Intent to open Main App
                val appIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    putExtra("surah_id", item.surahId)
                    putExtra("ayah_number", item.ayahNumber)
                }
                val appPendingIntent = PendingIntent.getActivity(
                    context, appWidgetId, appIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_root, appPendingIntent)

                // Intent for Refresh Button
                val refreshIntent = Intent(context, QuranLockscreenWidgetProvider::class.java).apply {
                    action = ACTION_REFRESH_WIDGET
                }
                val refreshPendingIntent = PendingIntent.getBroadcast(
                    context, appWidgetId + 5000, refreshIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.btn_refresh_widget, refreshPendingIntent)

                appWidgetManager.updateAppWidget(appWidgetId, views)
                Log.d(TAG, "Successfully updated appWidgetId $appWidgetId with theme=$themeIndex shape=$shapeIndex")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Exception during updateAllWidgets: ${e.message}", e)
        }
    }

    fun rescheduleUpdates(context: Context) {
        try {
            val prefs = getPrefs(context)
            val isEnabled = prefs.getBoolean(KEY_ENABLED, false)
            val mode = prefs.getString(KEY_UPDATE_MODE, "byTime") ?: "byTime"
            val intervalMinutes = prefs.getInt(KEY_INTERVAL_MINUTES, 60)
            val customMinutes = prefs.getInt(KEY_CUSTOM_MINUTES, 30)

            Log.d(TAG, "rescheduleUpdates: isEnabled=$isEnabled, mode=$mode")

            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
            val intent = Intent(context, QuranLockscreenWidgetProvider::class.java).apply {
                action = ACTION_ALARM_TICK
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                ALARM_REQUEST_CODE,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            if (!isEnabled) {
                alarmManager?.cancel(pendingIntent)
                ScreenOffService.stop(context)
                Log.d(TAG, "Widget disabled: cancelled alarms and stopped ScreenOffService")
                return
            }

            if (mode == "screenOff") {
                alarmManager?.cancel(pendingIntent)
                ScreenOffService.start(context)
                Log.d(TAG, "Mode screenOff: started ScreenOffService and cancelled timer alarms")
                return
            }

            // By time or custom interval
            ScreenOffService.stop(context)

            val targetMinutes = if (mode == "custom") customMinutes else intervalMinutes
            val intervalMillis = (targetMinutes.coerceAtLeast(15) * 60 * 1000L)

            alarmManager?.cancel(pendingIntent)
            alarmManager?.setInexactRepeating(
                AlarmManager.ELAPSED_REALTIME,
                SystemClock.elapsedRealtime() + intervalMillis,
                intervalMillis,
                pendingIntent
            )
            Log.d(TAG, "Scheduled periodic widget updates every $targetMinutes minutes ($intervalMillis ms)")
        } catch (e: Exception) {
            Log.e(TAG, "Error in rescheduleUpdates: ${e.message}", e)
        }
    }
}
