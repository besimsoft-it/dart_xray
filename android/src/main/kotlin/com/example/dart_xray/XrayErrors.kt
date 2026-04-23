package com.example.dart_xray

import io.flutter.plugin.common.MethodChannel

internal enum class XrayErrors(val code: String) {
  NOT_INITIALIZED("not_initialized"),
  INVALID_ARGUMENTS("invalid_arguments"),
  NATIVE_ARTIFACT_MISSING("native_artifact_missing"),
  NATIVE_ENGINE_UNAVAILABLE("native_engine_unavailable"),
  VPN_PERMISSION_NOT_GRANTED("vpn_permission_not_granted"),
  NO_ACTIVITY("no_activity"),
  VPN_SERVICE_NOT_DECLARED("vpn_service_not_declared"),
  TUN_STARTUP_NOT_WIRED("tun_startup_not_wired"),
}

internal class XrayPluginException(
  val error: XrayErrors,
  override val message: String,
  override val cause: Throwable? = null,
) : RuntimeException(message, cause)

internal fun MethodChannel.Result.errorFrom(throwable: Throwable) {
  when (throwable) {
    is XrayPluginException -> error(throwable.error.code, throwable.message, throwable.cause?.message)
    else -> error("unknown_error", throwable.message ?: throwable.javaClass.simpleName, null)
  }
}
