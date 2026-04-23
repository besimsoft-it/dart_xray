package com.example.dart_xray

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Android bridge for dart_xray.
 *
 * This scaffold maps Flutter calls to a future libXray-backed engine wrapper.
 */
class DartXrayPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
  private lateinit var methodChannel: MethodChannel
  private lateinit var statusChannel: EventChannel
  private lateinit var persistentStatusChannel: EventChannel

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel = MethodChannel(binding.binaryMessenger, "dart_xray/methods")
    methodChannel.setMethodCallHandler(this)

    statusChannel = EventChannel(binding.binaryMessenger, "dart_xray/status")
    statusChannel.setStreamHandler(SimpleStatusStreamHandler())

    persistentStatusChannel = EventChannel(binding.binaryMessenger, "dart_xray/persistent_status")
    persistentStatusChannel.setStreamHandler(SimpleStatusStreamHandler())
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "init",
      "start",
      "stop",
      "startPersistentStatusListener",
      "stopPersistentStatusListener" -> result.success(null)
      "getServerDelay",
      "getCurrentServerDelay" -> result.success(null)
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
    statusChannel.setStreamHandler(null)
    persistentStatusChannel.setStreamHandler(null)
  }
}

private class SimpleStatusStreamHandler : EventChannel.StreamHandler {
  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    events?.success("DISCONNECTED")
  }

  override fun onCancel(arguments: Any?) = Unit
}
