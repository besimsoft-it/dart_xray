# Implementation Report

## Hard-correction refactor summary

This refactor removes platform-channel engine control and leaves engine integration FFI-only.

## Removed bridge classes/methods

Removed Android bridge layer classes that mirrored Dart engine APIs via channels/JNI proxies:

- `android/src/main/kotlin/com/example/dart_xray/AndroidXraySessionManager.kt`
- `android/src/main/kotlin/com/example/dart_xray/XrayNativeBridge.kt`
- `android/src/main/kotlin/com/example/dart_xray/XrayEngineRegistry.kt`
- `android/src/main/kotlin/com/example/dart_xray/XrayStatusStreamHandler.kt`
- `android/src/main/kotlin/com/example/dart_xray/XrayConnectionState.kt`
- `android/src/main/kotlin/com/example/dart_xray/XrayErrors.kt`

Removed channel-based engine handlers from platform plugin entrypoints:

- Android `DartXrayPlugin.kt` no longer registers MethodChannel/EventChannel handlers.
- iOS/macOS/Linux/Windows plugin entrypoints no longer expose engine method handlers.

## Remaining native OS-only classes

Kept native code where OS/framework ownership is required:

- `android/src/main/kotlin/com/example/dart_xray/DartXrayVpnService.kt`
  - foreground service lifecycle
  - TUN interface establishment and ownership

Current plugin registrar classes remain minimal/no-op registrars and do not act as engine bridges.

## FFI-bound engine entrypoints

Engine-facing API is direct Dart FFI through:

- `lib/src/ffi/xray_dynamic_library_loader.dart`
- `lib/src/ffi/xray_native_bindings.dart`
- `lib/src/ffi/xray_engine_ffi.dart`

Required ABI symbols:

- `dart_xray_init`
- `dart_xray_start`
- `dart_xray_stop`
- `dart_xray_destroy`
- `dart_xray_get_server_delay`
- `dart_xray_get_current_server_delay`
- `dart_xray_register_status_callback`
- `dart_xray_unregister_status_callback`

Status stream implementation is now FFI callback-backed only (no EventChannel).

## Platform-specific limitations / follow-ups

- Android VPN permission flow (`VpnService.prepare`) must be handled by the host app/native layer.
- Android `DartXrayVpnService` currently covers OS lifecycle/TUN ownership only; engine orchestration stays in FFI path.
- Teams integrating Packet Tunnel / Network Extension / desktop TUN drivers must keep those OS hooks outside engine API mirroring.
