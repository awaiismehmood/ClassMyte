package com.example.classmyte

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.os.Build
import android.telephony.SmsManager
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.lifecycle.LifecycleService
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class SmsForegroundService : LifecycleService() {

    private val CHANNEL_ID = "sms_channel_id"

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        startForeground(1, createNotification("Service Running"))
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "SMS Service Channel",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java) as NotificationManager
            manager.createNotificationChannel(serviceChannel)
            Log.d("SmsForegroundService", "Notification channel created")
        }
    }

    private fun createNotification(content: String): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Sending SMS")
            .setContentText(content)
            .setSmallIcon(R.drawable.ic_sms) // Ensure this drawable exists
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .build()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val phoneNumbers = intent?.getStringArrayListExtra("phoneNumbers") ?: emptyList()
        val message = intent?.getStringExtra("message")

        if (message != null) {
            Log.d("SmsForegroundService", "Sending SMS to: $phoneNumbers")
            sendSms(phoneNumbers, message)
        } else {
            Log.e("SmsForegroundService", "Message is null")
        }

        return START_NOT_STICKY
    }

    private fun sendSms(phoneNumbers: List<String>, message: String) {
        CoroutineScope(Dispatchers.IO).launch {
            for (phoneNumber in phoneNumbers) {
                try {
                    val smsManager = SmsManager.getDefault()
                    smsManager.sendTextMessage(phoneNumber, null, message, null, null)
                    Log.d("SmsForegroundService", "Message sent to $phoneNumber")
                    updateNotification("Message sent to $phoneNumber")
                } catch (e: Exception) {
                    Log.e("SmsForegroundService", "Failed to send message to $phoneNumber: ${e.message}")
                    updateNotification("Failed to send message to $phoneNumber")
                }
                // Delay before sending the next message
                delay(15000) // Delay for 15 seconds (or any user-selected delay)
            }
            completeNotification()
        }
    }

    private fun updateNotification(content: String) {
        val notification = createNotification(content)
        val manager = getSystemService(NotificationManager::class.java) as NotificationManager
        manager.notify(1, notification)
        Log.d("SmsForegroundService", "Notification updated: $content")
    }

    private fun completeNotification() {
        val notification = createNotification("All messages sent successfully!")
        val manager = getSystemService(NotificationManager::class.java) as NotificationManager
        manager.notify(1, notification)
        stopForeground(true)
        stopSelf() // Stop the service after completion
        Log.d("SmsForegroundService", "Notification completed and service stopped")
    }
}
