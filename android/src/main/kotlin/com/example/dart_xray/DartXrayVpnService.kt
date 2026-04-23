package com.example.dart_xray

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import androidx.core.app.NotificationCompat

/**
 * Android OS integration only.
 *
 * This service owns foreground lifecycle and TUN setup. It does not mirror
 * engine controls (init/start/stop/delay/status) for Dart; engine control is FFI-only.
 */
class DartXrayVpnService : VpnService() {
  private var tunInterface: ParcelFileDescriptor? = null

  override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
    when (intent?.action) {
      ACTION_START -> startSession()
      ACTION_STOP -> stopSession()
      else -> Unit
    }
    return START_STICKY
  }

  private fun startSession() {
    startForeground(NOTIFICATION_ID, buildForegroundNotification())
    if (tunInterface == null) {
      tunInterface = createTunInterface()
    }
  }

  private fun stopSession() {
    runCatching {
      tunInterface?.close()
      tunInterface = null
    }
    stopForeground(STOP_FOREGROUND_REMOVE)
    stopSelf()
  }

  private fun createTunInterface(): ParcelFileDescriptor {
    return Builder()
      .setSession("dart_xray")
      .setMtu(1500)
      .addAddress("10.111.0.2", 30)
      .addRoute("0.0.0.0", 0)
      .addDnsServer("1.1.1.1")
      .addDnsServer("8.8.8.8")
      .establish()
      ?: error("VpnService.Builder.establish() returned null")
  }

  private fun buildForegroundNotification(): Notification {
    ensureChannel()

    val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
    val pendingIntent = PendingIntent.getActivity(
      this,
      1,
      launchIntent,
      PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
    )

    return NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)

      .setContentText("VPN tunnel is active")
      .setContentIntent(pendingIntent)
      .setOngoing(true)
      .build()
  }

  private fun ensureChannel() {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

    val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    val existing = manager.getNotificationChannel(NOTIFICATION_CHANNEL_ID)
    if (existing != null) return

    val channel = NotificationChannel(
      NOTIFICATION_CHANNEL_ID,
      "dart_xray VPN",
      NotificationManager.IMPORTANCE_LOW,
    )
    manager.createNotificationChannel(channel)
  }

  companion object {
    const val ACTION_START = "com.example.dart_xray.action.START"
    const val ACTION_STOP = "com.example.dart_xray.action.STOP"

    private const val NOTIFICATION_CHANNEL_ID = "dart_xray_vpn"
    private const val NOTIFICATION_ID = 7342
  }
}
