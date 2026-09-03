package com.example.quraan.quraan

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.quraan/lockscreen_widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidgetSettings" -> {
                    val enabled = call.argument<Boolean>("isEnabled") ?: false
                    val mode = call.argument<String>("updateMode") ?: "byTime"
                    val intervalMinutes = call.argument<Int>("intervalMinutes") ?: 60
                    val customMinutes = call.argument<Int>("customMinutes") ?: 30

                    val prefs = QuranWidgetUpdater.getPrefs(context)
                    prefs.edit()
                        .putBoolean(QuranWidgetUpdater.KEY_ENABLED, enabled)
                        .putString(QuranWidgetUpdater.KEY_UPDATE_MODE, mode)
                        .putInt(QuranWidgetUpdater.KEY_INTERVAL_MINUTES, intervalMinutes)
                        .putInt(QuranWidgetUpdater.KEY_CUSTOM_MINUTES, customMinutes)
                        .apply()

                    QuranWidgetUpdater.rescheduleUpdates(context)
                    if (enabled) {
                        QuranWidgetUpdater.updateAllWidgets(context, forceNew = false)
                    }
                    result.success(true)
                }

                "updateWidgetAppearance" -> {
                    val theme = call.argument<Int>("theme") ?: 0
                    val shape = call.argument<Int>("shape") ?: 0
                    val ayahFontSize = (call.argument<Double>("ayahFontSize") ?: 15.0).toFloat()
                    val surahFontSize = (call.argument<Double>("surahFontSize") ?: 11.0).toFloat()
                    val textAlign = call.argument<Int>("textAlign") ?: 0
                    val showAyahText = call.argument<Boolean>("showAyahText") ?: true
                    val showSurahName = call.argument<Boolean>("showSurahName") ?: true
                    val showAyahNumber = call.argument<Boolean>("showAyahNumber") ?: true
                    val showDecoration = call.argument<Boolean>("showDecoration") ?: true
                    val showAppName = call.argument<Boolean>("showAppName") ?: true

                    val prefs = QuranWidgetUpdater.getPrefs(context)
                    prefs.edit()
                        .putInt(QuranWidgetUpdater.KEY_WIDGET_THEME, theme)
                        .putInt(QuranWidgetUpdater.KEY_WIDGET_SHAPE, shape)
                        .putFloat(QuranWidgetUpdater.KEY_WIDGET_AYAH_FONT_SIZE, ayahFontSize)
                        .putFloat(QuranWidgetUpdater.KEY_WIDGET_SURAH_FONT_SIZE, surahFontSize)
                        .putInt(QuranWidgetUpdater.KEY_WIDGET_TEXT_ALIGN, textAlign)
                        .putBoolean(QuranWidgetUpdater.KEY_WIDGET_SHOW_AYAH_TEXT, showAyahText)
                        .putBoolean(QuranWidgetUpdater.KEY_WIDGET_SHOW_SURAH_NAME, showSurahName)
                        .putBoolean(QuranWidgetUpdater.KEY_WIDGET_SHOW_AYAH_NUMBER, showAyahNumber)
                        .putBoolean(QuranWidgetUpdater.KEY_WIDGET_SHOW_DECORATION, showDecoration)
                        .putBoolean(QuranWidgetUpdater.KEY_WIDGET_SHOW_APP_NAME, showAppName)
                        .apply()

                    QuranWidgetUpdater.updateAllWidgets(context, forceNew = false)
                    result.success(true)
                }

                "updateWidgetFontFamily" -> {
                    val fontIndex = call.argument<Int>("fontFamily") ?: 0
                    val prefs = QuranWidgetUpdater.getPrefs(context)
                    prefs.edit()
                        .putInt(QuranWidgetUpdater.KEY_WIDGET_FONT_FAMILY, fontIndex)
                        .apply()

                    QuranWidgetUpdater.updateAllWidgets(context, forceNew = false)
                    result.success(true)
                }

                "refreshAyahNow" -> {
                    QuranWidgetUpdater.updateAllWidgets(context, forceNew = true)
                    val prefs = QuranWidgetUpdater.getPrefs(context)
                    val map = mapOf(
                        "surahId" to prefs.getInt(QuranWidgetUpdater.KEY_LAST_SURAH_ID, 1),
                        "ayahNumber" to prefs.getInt(QuranWidgetUpdater.KEY_LAST_AYAH_NUM, 1),
                        "surahName" to (prefs.getString(QuranWidgetUpdater.KEY_LAST_SURAH_NAME, "") ?: ""),
                        "ayahText" to (prefs.getString(QuranWidgetUpdater.KEY_LAST_AYAH_TEXT, "") ?: "")
                    )
                    result.success(map)
                }

                "hasActiveWidgets" -> {
                    val appWidgetManager = AppWidgetManager.getInstance(context)
                    val componentName = ComponentName(context, QuranLockscreenWidgetProvider::class.java)
                    val widgetIds = appWidgetManager.getAppWidgetIds(componentName)
                    result.success(widgetIds != null && widgetIds.isNotEmpty())
                }

                "getLastShownAyah" -> {
                    val prefs = QuranWidgetUpdater.getPrefs(context)
                    val map = mapOf(
                        "surahId" to prefs.getInt(QuranWidgetUpdater.KEY_LAST_SURAH_ID, 1),
                        "ayahNumber" to prefs.getInt(QuranWidgetUpdater.KEY_LAST_AYAH_NUM, 1),
                        "surahName" to (prefs.getString(QuranWidgetUpdater.KEY_LAST_SURAH_NAME, "") ?: ""),
                        "ayahText" to (prefs.getString(QuranWidgetUpdater.KEY_LAST_AYAH_TEXT, "") ?: "")
                    )
                    result.success(map)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
