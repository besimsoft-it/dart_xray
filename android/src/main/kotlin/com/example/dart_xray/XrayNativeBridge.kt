package com.example.dart_xray

import java.io.FileDescriptor

/**
 * JNI boundary expected from locally built libXray Android artifact.
 *
 * Required symbol:
 * - libxray.so loadable via System.loadLibrary("xray")
 */
internal class XrayNativeBridge {
  private var loaded = false

  fun ensureLoaded() {
    if (loaded) return

    try {
      System.loadLibrary("xray")
    } catch (error: UnsatisfiedLinkError) {
      throw XrayPluginException(
        XrayErrors.NATIVE_ARTIFACT_MISSING,
        "libxray.so is missing. Build libXray for Android and copy ABI folders into android/src/main/jniLibs.",
        error,
      )
    }

    loaded = true
  }

  fun initEngine(configJson: String): Int = nativeInitEngine(configJson)

  fun startEngine(mode: String): Int = nativeStartEngine(mode)

  fun stopEngine(): Int = nativeStopEngine()

  fun registerDns(serverAddress: String): Int = nativeInitDns(serverAddress)

  fun resetDns(): Int = nativeResetDns()

  fun registerTunFd(fd: FileDescriptor): Int = nativeAttachTunFd(fd)

  fun protectSocket(fd: Int): Boolean = nativeProtectSocket(fd)

  private external fun nativeInitEngine(configJson: String): Int
  private external fun nativeStartEngine(mode: String): Int
  private external fun nativeStopEngine(): Int
  private external fun nativeInitDns(serverAddress: String): Int
  private external fun nativeResetDns(): Int
  private external fun nativeAttachTunFd(tunFd: FileDescriptor): Int
  private external fun nativeProtectSocket(fd: Int): Boolean
}
