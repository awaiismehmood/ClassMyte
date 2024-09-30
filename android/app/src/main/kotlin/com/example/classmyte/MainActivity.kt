package com.example.classmyte

import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.sms/sendSMS"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendSMS" -> {
                    val phoneNumbers = call.argument<List<String>>("phoneNumbers")
                    val message = call.argument<String>("message")
                    val delay = call.argument<Int>("delay") ?: 15 
                    if (phoneNumbers != null && message != null) {
                        startForegroundService(phoneNumbers, message, delay, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Invalid phone numbers or message", null)
                    }
                }
                "stopService" -> {
                    stopForegroundService(result)
                }
                else -> result.notImplemented()
            }
        }
    }

 private fun startForegroundService(phoneNumbers: List<String>, message: String, delay: Int, result: MethodChannel.Result) {
    val serviceIntent = Intent(this, SmsForegroundService::class.java).apply {
        putStringArrayListExtra("phoneNumbers", ArrayList(phoneNumbers))
        putExtra("message", message)
        putExtra("delay", delay) // Pass the delay to the service
        action = "ACTION_START_SENDING"
    }

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        startForegroundService(serviceIntent)
        Log.d("MainActivity", "Foreground service started for sending SMS")
    } else {
        startService(serviceIntent)
        Log.d("MainActivity", "Service started for sending SMS")
    }

    result.success(true)
}




private fun stopForegroundService(result: MethodChannel.Result) {
    val serviceIntent = Intent(this, SmsForegroundService::class.java).apply {
        action = "ACTION_CANCEL_SENDING"  // Add action for canceling the service
    }
    stopService(serviceIntent)
    Log.d("MainActivity", "Foreground service stopped")
    result.success(true)
}

}
