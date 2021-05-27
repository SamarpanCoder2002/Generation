package com.official.generation

import android.app.NotificationManager
import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.official.generation/nativeCallBack"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "cancelAllNotification") {
                result.success(cancelNotificationAllInProgrammatically())
            } else {
                result.notImplemented()
            }
        }
    }

    private fun cancelNotificationAllInProgrammatically(): Boolean {
        return try {
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.cancelAll()

            true
        } catch (e: Throwable) {

            false
        }
    }


}

