package com.example.dart_xray

internal enum class XrayConnectionState(val wireValue: String) {
  CONNECTING("CONNECTING"),
  CONNECTED("CONNECTED"),
  DISCONNECTING("DISCONNECTING"),
  DISCONNECTED("DISCONNECTED"),
  FAILED("FAILED"),
}
