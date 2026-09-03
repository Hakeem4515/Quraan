package com.example.quraan.quraan

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.util.Log

class QuranLockscreenWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val TAG = "QuranWidgetProvider"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        super.onUpdate(context, appWidgetManager, appWidgetIds)
        Log.d(TAG, "onUpdate called for IDs: ${appWidgetIds.joinToString()}")
        QuranWidgetUpdater.updateAllWidgets(context, targetWidgetIds = appWidgetIds, forceNew = false)
        QuranWidgetUpdater.rescheduleUpdates(context)
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "onReceive action: ${intent.action}")
        super.onReceive(context, intent)
        when (intent.action) {
            QuranWidgetUpdater.ACTION_REFRESH_WIDGET -> {
                Log.d(TAG, "Handling ACTION_REFRESH_WIDGET")
                QuranWidgetUpdater.updateAllWidgets(context, forceNew = true)
            }
            QuranWidgetUpdater.ACTION_ALARM_TICK -> {
                Log.d(TAG, "Handling ACTION_ALARM_TICK")
                QuranWidgetUpdater.updateAllWidgets(context, forceNew = true)
            }
        }
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        Log.d(TAG, "onEnabled called - First widget added")
        QuranWidgetUpdater.updateAllWidgets(context, forceNew = true)
        QuranWidgetUpdater.rescheduleUpdates(context)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        Log.d(TAG, "onDisabled called - Last widget removed")
    }
}
