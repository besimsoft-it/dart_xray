# Architecture

## 1) libXray analysis summary

Based on `XTLS/libXray` public repository:
- The project exposes Go wrapper entry points to start/stop Xray instances and utility operations such as config testing and latency checks.
- Android-specific wrappers include socket protection hooks for `VpnService` compatibility.
- Build outputs are intended to be consumed by mobile bindings (gomobile/JNI/ObjC) and native wrappers.

Practical constraints:
- Apple TUN mode requires `NetworkExtension` and an extension target.
- Android TUN mode requires `VpnService` and route/protect logic.
- Desktop TUN commonly needs OS-level privileges and drivers (`wintun` or `/dev/net/tun`).

## 2) Plugin layering

- **Dart API layer**: `lib/src/dart_xray_api.dart`
- **Platform abstraction**: `lib/src/platform/dart_xray_platform_interface.dart`
- **Platform channel transport**: `lib/src/platform/method_channel_dart_xray.dart`
- **Parser + config normalization**: `lib/src/parsing/*`, `lib/src/models/*`
- **Native adapters**: `android/`, `ios/`, `macos/`, `windows/`, `linux/`

## 3) Integration strategy

A hybrid approach is used:
- Stable Flutter MethodChannel/EventChannel surface first.
- Native adapters are scaffolded for each OS and expected to call a platform-appropriate libXray wrapper.
- Asynchronous status updates are pushed via event channels.

## 4) Status design

Status mapping is fixed to:
- `CONNECTING`
- `CONNECTED`
- `DISCONNECTED`
- `ERROR`

Recommended transition flow:
1. `start()` request accepted -> `CONNECTING`
2. Runtime active -> `CONNECTED`
3. Stop/cleanup complete -> `DISCONNECTED`
4. Any startup/runtime failure -> `ERROR`

## 5) Why this structure

This architecture prioritizes:
- Uniform public API.
- Explicit platform constraints.
- Incremental hardening of native wrappers without breaking Flutter consumers.
