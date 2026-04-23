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
 * Owns Android VpnService lifecycle and TUN handoff to native layer.
 */
class DartXrayVpnService : VpnService() {
  private var tunInterface: ParcelFileDescriptor? = null

  override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
    when (intent?.action) {
      ACTION_START -> startSession(intent)
      ACTION_STOP -> stopSession()
      else -> Unit
    }
    return START_STICKY
  }

  private fun startSession(intent: Intent) {
    startForeground(NOTIFICATION_ID, buildForegroundNotification())

    val config = intent.getStringExtra(EXTRA_XRAY_CONFIG)
      ?: throw XrayPluginException(XrayErrors.INVALID_ARGUMENTS, "Missing EXTRA_XRAY_CONFIG")
    val mode = intent.getStringExtra(EXTRA_MODE) ?: "proxy"
    val dnsServer = intent.getStringExtra(EXTRA_DNS_SERVER) ?: "1.1.1.1:53"

    val bridge = XrayEngineRegistry.bridge()
    val startTun = mode.equals("tun", ignoreCase = true)

    if (startTun) {
      val tun = createTunInterface()
      bridge.registerTunFd(tun.fileDescriptor)
    }

    bridge.registerDns(dnsServer)
    val initCode = bridge.initEngine(config)
    if (initCode != 0) {
      throw XrayPluginException(XrayErrors.NATIVE_ENGINE_UNAVAILABLE, "nativeInitEngine failed with code=$initCode")
    }

    val startCode = bridge.startEngine(mode)
    if (startCode != 0) {
      throw XrayPluginException(XrayErrors.NATIVE_ENGINE_UNAVAILABLE, "nativeStartEngine failed with code=$startCode")
    }
  }

  private fun stopSession() {
    runCatching {
      val bridge = XrayEngineRegistry.bridge()
      bridge.stopEngine()
      bridge.resetDns()
      tunInterface?.close()
      tunInterface = null
    }
    stopForeground(STOP_FOREGROUND_REMOVE)
    stopSelf()
  }

  private fun createTunInterface(): ParcelFileDescriptor {
    val tun = Builder()
      .setSession("dart_xray")
      .setMtu(1500)
      .addAddress("10.111.0.2", 30)
      .addRoute("0.0.0.0", 0)
      .addDnsServer("1.1.1.1")
      .addDnsServer("8.8.8.8")
      .establish()
      ?: throw XrayPluginException(XrayErrors.TUN_STARTUP_NOT_WIRED, "VpnService.Builder.establish() returned null")

    tunInterface = tun
    return tun
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
      .setSmallIcon(android.R.drawable.stat_sys_vpn_ic)
      .setContentTitle("dart_xray VPN")
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

    const val EXTRA_XRAY_CONFIG = "xray_config"
    const val EXTRA_MODE = "xray_mode"
    const val EXTRA_DNS_SERVER = "xray_dns_server"

    private const val NOTIFICATION_CHANNEL_ID = "dart_xray_vpn"
    private const val NOTIFICATION_ID = 7342
  }
}
