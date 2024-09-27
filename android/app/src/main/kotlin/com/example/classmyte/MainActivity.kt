package com.example.classmyte

import android.app.PendingIntent
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import android.telephony.SmsManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.sms/sendSMS"
    private val SENT = "SMS_SENT"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sendSMS") {
                val phoneNumber = call.argument<String>("phoneNumber")
                val message = call.argument<String>("message")
                if (phoneNumber != null && message != null) {
                    sendSMS(phoneNumber, message, result)
                } else {
                    result.error("INVALID_ARGUMENTS", "Invalid phone number or message", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

  private fun sendSMS(phoneNumber: String, message: String, result: MethodChannel.Result) {
    try {
      
        
        // Split the message if it exceeds 70 characters (for Unicode)
        val messages = if (message.length > 70) {
            SmsManager.getDefault().divideMessage(message)
        } else {
            listOf(message)
        }

        // Create a PendingIntent for sent confirmation
        val sentIntent = PendingIntent.getBroadcast(
            applicationContext, 0, Intent(SENT), PendingIntent.FLAG_IMMUTABLE
        )

        // Send the actual message(s) next
        for (msg in messages) {
            SmsManager.getDefault().sendTextMessage(
                phoneNumber,
                null,
                msg,
                sentIntent,
                null
            )
        }

        result.success(true)
    } catch (e: Exception) {
        result.error("SEND_SMS_ERROR", e.message, null)
    }
}


}    