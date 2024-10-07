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
import kotlinx.coroutines.*
import android.app.PendingIntent

class SmsForegroundService : LifecycleService() {

    private val CHANNEL_ID = "sms_channel_id"
    private var smsJob: Job? = null

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
    // Create an intent that will trigger the cancellation of the service
    val cancelIntent = Intent(this, SmsForegroundService::class.java).apply {
        action = "ACTION_CANCEL_SENDING"
    }
    val cancelPendingIntent = PendingIntent.getService(
        this, 0, cancelIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    return NotificationCompat.Builder(this, CHANNEL_ID)
        .setContentTitle("ClassMyte SMS service")
        .setContentText(content)
        .setSmallIcon(R.drawable.ic_sms) // Ensure this drawable exists
        .setPriority(NotificationCompat.PRIORITY_LOW)
        .setOngoing(true)
        .addAction(android.R.drawable.ic_menu_close_clear_cancel, "Cancel", cancelPendingIntent)
        .build()
}


    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
    val action = intent?.action

    when (action) {
        "ACTION_START_SENDING" -> {
            val phoneNumbers = intent.getStringArrayListExtra("phoneNumbers") ?: emptyList()
            val message = intent.getStringExtra("message")
            val delay = intent.getIntExtra("delay", 15) // Use default delay of 15 seconds if none is provided

            if (message != null) {
                Log.d("SmsForegroundService", "Sending SMS to: $phoneNumbers with delay of $delay seconds")
                startSendingSms(phoneNumbers, message, delay)
            } else {
                Log.e("SmsForegroundService", "Message is null")
            }
        }
        "ACTION_CANCEL_SENDING" -> {
            cancelSmsSending()
        }
        else -> Log.d("SmsForegroundService", "Unknown action: $action")
    }

  return START_STICKY  // Keeps the service running until explicitly stopped
}

private fun startSendingSms(phoneNumbers: List<String>, message: String, delay: Int) {
    smsJob = CoroutineScope(Dispatchers.IO).launch {
        for (phoneNumber in phoneNumbers) {
            try {
                // Split the message if it exceeds 70 characters (for Unicode)
                val messages = if (message.length > 70) {
                    SmsManager.getDefault().divideMessage(message)
                } else {
                    listOf(message)
                }

                // Send each part of the split message
                for (msg in messages) {
                    SmsManager.getDefault().sendTextMessage(phoneNumber, null, msg, null, null)
                    updateNotification("Message sent to $phoneNumber")
                }

            } catch (e: Exception) {
                Log.e("SmsForegroundService", "Failed to send message to $phoneNumber: ${e.message}")
                updateNotification("Failed to send message to $phoneNumber")
            }
            // Delay before sending the next message
            delay(delay * 1000L)  // Delay for user-selected time or default 15 seconds
        }
        completeNotification()
    }
}


    // Cancel the ongoing SMS sending process
    private fun cancelSmsSending() {
        smsJob?.cancel()
        updateNotification("Message sending canceled")
        stopForeground(true)
        stopSelf()
        Log.d("SmsForegroundService", "Message sending canceled, service stopped")
    }

    // Update notification content
    private fun updateNotification(content: String) {
        val notification = createNotification(content)
        val manager = getSystemService(NotificationManager::class.java) as NotificationManager
        manager.notify(1, notification)
        Log.d("SmsForegroundService", "Updated status: $content")
    }

    // Complete notification when all messages are sent
    private fun completeNotification() {
        val notification = createNotification("All messages sent successfully!")
        val manager = getSystemService(NotificationManager::class.java) as NotificationManager
        manager.notify(1, notification)
        stopForeground(true)
        stopSelf() // Stop the service after completion
        Log.d("SmsForegroundService", "Notification completed and service stopped")
    }

    override fun onDestroy() {
        super.onDestroy()
        smsJob?.cancel() // Ensure any ongoing SMS sending is stopped if the service is destroyed
    }
}
