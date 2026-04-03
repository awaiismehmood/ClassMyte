package com.alnoor.classmyte

import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.alnoor.sms/sendSMS"
    private val PROGRESS_CHANNEL = "com.alnoor.sms/progress"
    
    companion object {
        var eventSink: EventChannel.EventSink? = null
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendSMS" -> {
                    val phoneNumbers = call.argument<List<String>>("phoneNumbers")
                    val names = call.argument<List<String>>("names") ?: emptyList()
                    val messages = call.argument<List<String>>("messages")
                    val delay = call.argument<Int>("delay") ?: 15 
                    if (phoneNumbers != null && messages != null && phoneNumbers.size == messages.size) {
                        startForegroundService(phoneNumbers, names, messages, delay, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Mismatch in numbers and messages, or invalid input", null)
                    }
                }
                "stopService" -> {
                    stopForegroundService(result)
                }
                "isServiceRunning" -> {
                    result.success(SmsForegroundService.isServiceRunning)
                }
                else -> result.notImplemented()
            }
        }

        // Event Channel for real-time progress updates
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, PROGRESS_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )
    }

  private fun startForegroundService(phoneNumbers: List<String>, names: List<String>, messages: List<String>, delay: Int, result: MethodChannel.Result) {
    val serviceIntent = Intent(this, SmsForegroundService::class.java).apply {
        putStringArrayListExtra("phoneNumbers", ArrayList(phoneNumbers))
        putStringArrayListExtra("names", ArrayList(names))
        putStringArrayListExtra("messages", ArrayList(messages))
        putExtra("delay", delay)
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
    // Use startService specifically to pass the intent with the cancel action
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        startForegroundService(serviceIntent)
    } else {
        startService(serviceIntent)
    }
    Log.d("MainActivity", "Forwarded cancel action to service")
    result.success(true)
}

}
