package com.example.dart_xray

import io.flutter.embedding.engine.plugins.FlutterPlugin

/**
 * Platform plugin registration for dart_xray.
 *
 * Engine lifecycle and status now use Dart FFI directly; no MethodChannel/EventChannel
 * bridge is registered for engine control.
 */
class DartXrayPlugin : FlutterPlugin {
  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    // Intentionally empty.
    // Android-side code in this package is reserved for OS concerns such as VpnService.
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    // Intentionally empty.
  }
}
