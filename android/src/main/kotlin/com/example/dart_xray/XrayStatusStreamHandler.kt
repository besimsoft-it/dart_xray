package com.example.dart_xray

import io.flutter.plugin.common.EventChannel

internal class XrayStatusStreamHandler : EventChannel.StreamHandler {
  private var sink: EventChannel.EventSink? = null

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    sink = events
    events?.success(XrayConnectionState.DISCONNECTED.wireValue)
  }

  override fun onCancel(arguments: Any?) {
    sink = null
  }

  fun emit(value: String) {
    sink?.success(value)
  }
}
