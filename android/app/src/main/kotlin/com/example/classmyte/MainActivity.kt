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
                    if (phoneNumbers != null && message != null) {
                        startForegroundService(phoneNumbers, message, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Invalid phone numbers or message", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startForegroundService(phoneNumbers: List<String>, message: String, result: MethodChannel.Result) {
        val serviceIntent = Intent(this, SmsForegroundService::class.java).apply {
            putStringArrayListExtra("phoneNumbers", ArrayList(phoneNumbers))
            putExtra("message", message)
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
}
