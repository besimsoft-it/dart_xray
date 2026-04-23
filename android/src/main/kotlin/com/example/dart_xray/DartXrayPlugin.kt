package com.example.dart_xray

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.VpnService
import androidx.annotation.VisibleForTesting
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Android bridge for dart_xray.
 *
 * Integration model:
 * 1) Build libXray for Android locally via libXray build scripts.
 * 2) Copy generated .so files into android/src/main/jniLibs/<abi>/.
 * 3) Plugin loads libxray and drives it through JNI contract in [XrayNativeBridge].
 */
class DartXrayPlugin :
  FlutterPlugin,
  MethodChannel.MethodCallHandler,
  ActivityAware {

  private lateinit var appContext: Context
  private lateinit var methodChannel: MethodChannel
  private lateinit var statusChannel: EventChannel
  private lateinit var persistentStatusChannel: EventChannel

  private var activity: Activity? = null
  private val sessionManager = AndroidXraySessionManager()

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    appContext = binding.applicationContext

    methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL)
    methodChannel.setMethodCallHandler(this)

    statusChannel = EventChannel(binding.binaryMessenger, STATUS_CHANNEL)
    statusChannel.setStreamHandler(sessionManager.ephemeralStreamHandler)

    persistentStatusChannel = EventChannel(binding.binaryMessenger, PERSISTENT_STATUS_CHANNEL)
    persistentStatusChannel.setStreamHandler(sessionManager.persistentStreamHandler)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "init" -> handleInit(result)
      "start" -> handleStart(call, result)
      "stop" -> handleStop(result)
      "prepareVpn" -> handlePrepareVpn(result)
      "startPersistentStatusListener" -> {
        sessionManager.setPersistentEnabled(true)
        result.success(null)
      }
      "stopPersistentStatusListener" -> {
        sessionManager.setPersistentEnabled(false)
        result.success(null)
      }
      "getServerDelay", "getCurrentServerDelay" -> result.success(null)
      else -> result.notImplemented()
    }
  }

  private fun handleInit(result: MethodChannel.Result) {
    runCatching {
      sessionManager.init(appContext)
    }.onSuccess {
      sessionManager.emit(XrayConnectionState.DISCONNECTED)
      result.success(null)
    }.onFailure { throwable ->
      result.errorFrom(throwable)
    }
  }

  private fun handlePrepareVpn(result: MethodChannel.Result) {
    val hostActivity = activity
      ?: return result.error(
        XrayErrors.NO_ACTIVITY.code,
        "No foreground Activity attached. VpnService.prepare(...) requires an Activity.",
        null,
      )

    val consentIntent = VpnService.prepare(hostActivity)
    if (consentIntent == null) {
      result.success(mapOf("prepared" to true, "consentRequired" to false))
      return
    }

    hostActivity.startActivity(consentIntent)
    result.success(mapOf("prepared" to false, "consentRequired" to true))
  }

  private fun handleStart(call: MethodCall, result: MethodChannel.Result) {
    runCatching {
      val startArgs = call.arguments as? Map<*, *>
        ?: throw XrayPluginException(XrayErrors.INVALID_ARGUMENTS, "start requires a map payload")

      sessionManager.start(
        context = appContext,
        startArgs = startArgs,
      )
    }.onSuccess {
      result.success(null)
    }.onFailure { throwable ->
      sessionManager.emit(XrayConnectionState.FAILED)
      result.errorFrom(throwable)
    }
  }

  private fun handleStop(result: MethodChannel.Result) {
    runCatching {
      sessionManager.stop(appContext)
    }.onSuccess {
      result.success(null)
    }.onFailure { throwable ->
      result.errorFrom(throwable)
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
    statusChannel.setStreamHandler(null)
    persistentStatusChannel.setStreamHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  @VisibleForTesting
  internal fun setActivityForTests(activity: Activity?) {
    this.activity = activity
  }

  companion object {
    private const val METHOD_CHANNEL = "dart_xray/methods"
    private const val STATUS_CHANNEL = "dart_xray/status"
    private const val PERSISTENT_STATUS_CHANNEL = "dart_xray/persistent_status"
  }
}
