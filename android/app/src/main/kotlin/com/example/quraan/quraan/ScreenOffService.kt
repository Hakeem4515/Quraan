package com.example.quraan.quraan

import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.IBinder
import android.util.Log

class ScreenOffService : Service() {

    companion object {
        private const val TAG = "ScreenOffService"

        fun start(context: Context) {
            try {
                val intent = Intent(context, ScreenOffService::class.java)
                context.startService(intent)
                Log.d(TAG, "ScreenOffService started successfully")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to start ScreenOffService: ${e.message}")
            }
        }

        fun stop(context: Context) {
            try {
                val intent = Intent(context, ScreenOffService::class.java)
                context.stopService(intent)
                Log.d(TAG, "ScreenOffService stopped successfully")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to stop ScreenOffService: ${e.message}")
            }
        }
    }

    private val screenEventReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val action = intent?.action ?: return
            Log.d(TAG, "Received screen event: $action")
            if (context != null && (action == Intent.ACTION_SCREEN_OFF || 
                                    action == Intent.ACTION_SCREEN_ON || 
                                    action == Intent.ACTION_USER_PRESENT)) {
                QuranWidgetUpdater.updateAllWidgets(context, forceNew = true)
            }
        }
    }

    private var isReceiverRegistered = false

    override fun onCreate() {
        super.onCreate()
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_OFF)
            addAction(Intent.ACTION_SCREEN_ON)
            addAction(Intent.ACTION_USER_PRESENT)
        }
        try {
            registerReceiver(screenEventReceiver, filter)
            isReceiverRegistered = true
            Log.d(TAG, "Registered screen events receiver")
        } catch (e: Exception) {
            Log.e(TAG, "Error registering screenEventReceiver: ${e.message}")
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "ScreenOffService onStartCommand")
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        if (isReceiverRegistered) {
            try {
                unregisterReceiver(screenEventReceiver)
                Log.d(TAG, "Unregistered screen events receiver")
            } catch (_: Exception) {}
            isReceiverRegistered = false
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
