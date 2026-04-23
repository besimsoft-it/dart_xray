# Android

Android engine control is FFI-based, same as other platforms.

## Artifact contract

Build locally and package per ABI:

- `android/src/main/jniLibs/arm64-v8a/libdart_xray_ffi.so`
- `android/src/main/jniLibs/armeabi-v7a/libdart_xray_ffi.so`
- `android/src/main/jniLibs/x86_64/libdart_xray_ffi.so`

Dart loads `libdart_xray_ffi.so` via `dart:ffi`.

## Runtime boundary

FFI handles engine operations:
- `init`
- `start`
- `stop`
- delay APIs
- status callback registration

Android-native app/service code still owns:
- `VpnService.prepare(...)` consent UX
- foreground service policy
- socket protect routing (`VpnService.protect`)
- TUN fd lifecycle and handoff

These host responsibilities must not move engine control back to channels.

## Local workflow

1. Build libXray + thin C ABI wrapper for Android.
2. Ensure exported symbols match `dart_xray_*` ABI.
3. Copy `.so` files into `android/src/main/jniLibs/<abi>/`.
4. Build and run Flutter app.

## Common failures

- Missing `.so` → library load exception at `init`.
- Missing symbol export → symbol lookup exception.
- VPN permission not granted → start should fail in host-layer integration.
- DNS/socket loop → protect sockets used by engine and DNS helper paths.
