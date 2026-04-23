package com.example.dart_xray

import android.content.Context

internal object XrayEngineRegistry {
  private var appContext: Context? = null
  private var bridge: XrayNativeBridge? = null

  fun register(appContext: Context, bridge: XrayNativeBridge) {
    this.appContext = appContext
    this.bridge = bridge
  }

  fun context(): Context = appContext
    ?: throw XrayPluginException(XrayErrors.NATIVE_ENGINE_UNAVAILABLE, "Engine registry context unavailable.")

  fun bridge(): XrayNativeBridge = bridge
    ?: throw XrayPluginException(XrayErrors.NATIVE_ENGINE_UNAVAILABLE, "Engine bridge unavailable. Call init() first.")
}
