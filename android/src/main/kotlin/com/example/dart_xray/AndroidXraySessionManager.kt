package com.example.dart_xray

import android.content.Context
import android.content.Intent
import android.net.VpnService

internal class AndroidXraySessionManager {
  val ephemeralStreamHandler = XrayStatusStreamHandler()
  val persistentStreamHandler = XrayStatusStreamHandler()

  private val nativeBridge = XrayNativeBridge()
  private var persistentEnabled: Boolean = false
  private var initialized: Boolean = false

  fun init(context: Context) {
    nativeBridge.ensureLoaded()
    XrayEngineRegistry.register(appContext = context.applicationContext, bridge = nativeBridge)
    initialized = true
  }

  fun start(context: Context, startArgs: Map<*, *>) {
    ensureInitialized()

    if (VpnService.prepare(context) != null) {
      throw XrayPluginException(
        error = XrayErrors.VPN_PERMISSION_NOT_GRANTED,
        message = "VPN permission is not granted. Call prepareVpn and wait for user consent before start().",
      )
    }

    val config = startArgs["config"] as? String
      ?: throw XrayPluginException(
        XrayErrors.INVALID_ARGUMENTS,
        "start requires `config` (String).",
      )

    val mode = startArgs["mode"] as? String ?: "proxy"
    val dnsServer = (startArgs["dnsServer"] as? String)?.ifBlank { null } ?: "1.1.1.1:53"

    emit(XrayConnectionState.CONNECTING)

    val serviceIntent = Intent(context, DartXrayVpnService::class.java).apply {
      action = DartXrayVpnService.ACTION_START
      putExtra(DartXrayVpnService.EXTRA_XRAY_CONFIG, config)
      putExtra(DartXrayVpnService.EXTRA_MODE, mode)
      putExtra(DartXrayVpnService.EXTRA_DNS_SERVER, dnsServer)
    }

    context.startForegroundService(serviceIntent)
  }

  fun stop(context: Context) {
    ensureInitialized()

    val serviceIntent = Intent(context, DartXrayVpnService::class.java).apply {
      action = DartXrayVpnService.ACTION_STOP
    }
    context.startService(serviceIntent)

    emit(XrayConnectionState.DISCONNECTED)
  }

  fun setPersistentEnabled(enabled: Boolean) {
    persistentEnabled = enabled
  }

  fun emit(state: XrayConnectionState) {
    ephemeralStreamHandler.emit(state.wireValue)
    if (persistentEnabled) {
      persistentStreamHandler.emit(state.wireValue)
    }
  }

  private fun ensureInitialized() {
    if (!initialized) {
      throw XrayPluginException(XrayErrors.NOT_INITIALIZED, "Call init() before start()/stop().")
    }
  }
}
