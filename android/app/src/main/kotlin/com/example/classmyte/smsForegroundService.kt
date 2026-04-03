package com.alnoor.classmyte

import android.app.*
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.PowerManager
import android.telephony.SmsManager
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.lifecycle.LifecycleService
import kotlinx.coroutines.*
import java.util.concurrent.atomic.AtomicInteger
import kotlin.coroutines.resume

class SmsForegroundService : LifecycleService() {

    companion object {
        var isServiceRunning = false
    }

    private val CHANNEL_ID = "sms_channel_id"
    private var smsJob: Job? = null
    private var wakeLock: PowerManager.WakeLock? = null

    // Track state to report back to Flutter
    private val sentCount = AtomicInteger(0)
    private val failedCount = AtomicInteger(0)
    private val failedList = mutableListOf<Map<String, String>>()
    private var totalCount = 0

    private val SENT_ACTION = "SMS_SENT_ACTION"

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        startForeground(1, createNotification("Starting service..."))
        acquireWakeLock()
    }

    private fun acquireWakeLock() {
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "ClassMyte:SMSLock")
        wakeLock?.acquire()
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
        }
    }

    private fun createNotification(content: String): Notification {
        val cancelIntent = Intent(this, SmsForegroundService::class.java).apply {
            action = "ACTION_CANCEL_SENDING"
        }
        val cancelPendingIntent = PendingIntent.getService(
            this, 0, cancelIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("ClassMyte SMS Service")
            .setContentText(content)
            .setSmallIcon(R.drawable.ic_sms)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .addAction(android.R.drawable.ic_menu_close_clear_cancel, "Cancel", cancelPendingIntent)
            .build()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        super.onStartCommand(intent, flags, startId)
        val action = intent?.action

        when (action) {
            "ACTION_START_SENDING" -> {
                isServiceRunning = true
                val phoneNumbers = intent.getStringArrayListExtra("phoneNumbers") ?: emptyList()
                val names = intent.getStringArrayListExtra("names") ?: emptyList()
                val messages = intent.getStringArrayListExtra("messages") ?: emptyList()
                val delay = intent.getIntExtra("delay", 15)

                totalCount = phoneNumbers.size
                sentCount.set(0)
                failedCount.set(0)
                failedList.clear()

                startSendingSms(phoneNumbers, names, messages, delay)
            }
            "ACTION_CANCEL_SENDING" -> {
                cancelSmsSending()
            }
        }
        return START_STICKY
    }

    private fun startSendingSms(phoneNumbers: List<String>, names: List<String>, messages: List<String>, delay: Int) {
        smsJob = CoroutineScope(Dispatchers.IO).launch {
            val smsManager = getSmsManager()
            
            for (i in phoneNumbers.indices) {
                if (!isActive) break

                val phoneNumber = phoneNumbers[i]
                val name = if (i < names.size) names[i] else phoneNumber
                val currentMessage = if (i < messages.size) messages[i] else ""
                
                updateNotification("Sending message to $name (${i + 1}/$totalCount)")
                emitProgress(i + 1, name, phoneNumber)

                try {
                    val isSuccess = sendIndividualSms(smsManager, phoneNumber, currentMessage)
                    if (isSuccess) {
                        sentCount.incrementAndGet()
                    } else {
                        failedCount.incrementAndGet()
                        failedList.add(mapOf("name" to name, "number" to phoneNumber, "error" to "Failed to send"))
                    }
                } catch (e: Exception) {
                    failedCount.incrementAndGet()
                    failedList.add(mapOf("name" to name, "number" to phoneNumber, "error" to (e.message ?: "Unknown error")))
                }

                // Wait for the user-defined delay
                if (i < phoneNumbers.size - 1) {
                    delay(delay * 1000L)
                }
            }
            emitFinalReport()
            completeNotification()
        }
    }

    private suspend fun sendIndividualSms(smsManager: SmsManager, phoneNumber: String, message: String): Boolean {
        return suspendCancellableCoroutine { continuation ->
            val sentReceiver = object : BroadcastReceiver() {
                var finished = false
                override fun onReceive(context: Context?, intent: Intent?) {
                    if (finished) return
                    finished = true
                    try {
                        unregisterReceiver(this)
                    } catch (e: Exception) {}
                    val success = resultCode == Activity.RESULT_OK
                    continuation.resume(success)
                }
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(sentReceiver, IntentFilter(SENT_ACTION), Context.RECEIVER_EXPORTED)
            } else {
                @Suppress("UnspecifiedRegisterReceiverFlag")
                registerReceiver(sentReceiver, IntentFilter(SENT_ACTION))
            }

            val sentIntent = PendingIntent.getBroadcast(
                this, phoneNumber.hashCode() + System.currentTimeMillis().toInt(), Intent(SENT_ACTION), 
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )

            try {
                val parts = smsManager.divideMessage(message)
                if (parts.size > 1) {
                    val sentIntents = ArrayList<PendingIntent>()
                    for (part in parts) sentIntents.add(sentIntent)
                    smsManager.sendMultipartTextMessage(phoneNumber, null, parts, sentIntents, null)
                } else {
                    smsManager.sendTextMessage(phoneNumber, null, message, sentIntent, null)
                }
            } catch (e: Exception) {
                try {
                    unregisterReceiver(sentReceiver)
                } catch (ex: Exception) {}
                continuation.resume(false)
            }
        }
    }

    private fun getSmsManager(): SmsManager {
        @Suppress("DEPRECATION")
        return SmsManager.getDefault()
    }

    private fun emitProgress(index: Int, name: String, number: String) {
        val data = mapOf(
            "status" to "sending",
            "index" to index,
            "total" to totalCount,
            "sent" to sentCount.get(),
            "failed" to failedCount.get(),
            "currentName" to name,
            "currentNumber" to number
        )
        MainScope().launch {
            MainActivity.eventSink?.success(data)
        }
    }

    private fun emitFinalReport() {
        val data = mapOf(
            "status" to "completed",
            "total" to totalCount,
            "sent" to sentCount.get(),
            "failed" to failedCount.get(),
            "failedList" to failedList
        )
        MainScope().launch {
            MainActivity.eventSink?.success(data)
        }
    }

    private fun cancelSmsSending() {
        isServiceRunning = false
        smsJob?.cancel()
        val data = mapOf("status" to "cancelled", "sent" to sentCount.get(), "failed" to failedCount.get())
        MainScope().launch {
            MainActivity.eventSink?.success(data)
        }
        stopForeground(true)
        stopSelf()
    }

    private fun updateNotification(content: String) {
        val notification = createNotification(content)
        val manager = getSystemService(NotificationManager::class.java) as NotificationManager
        manager.notify(1, notification)
    }

    private fun completeNotification() {
        val notification = createNotification("Task completed: ${sentCount.get()} sent, ${failedCount.get()} failed")
        val manager = getSystemService(NotificationManager::class.java) as NotificationManager
        manager.notify(1, notification)
        stopForeground(false)
        isServiceRunning = false
        stopSelf()
    }

    override fun onDestroy() {
        isServiceRunning = false
        wakeLock?.let { if (it.isHeld) it.release() }
        smsJob?.cancel()
        super.onDestroy()
    }
}
