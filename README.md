# dart_xray

`dart_xray` is a Flutter plugin/package that controls a `libXray`-based runtime through **direct Dart FFI** on Android, iOS, macOS, Windows, and Linux.

## Architecture (mandatory)

Engine control path is FFI-only:
- `dart:ffi` + stable C ABI exports
- no `MethodChannel` for `init/start/stop/delay/status`
- no `EventChannel` for status streaming

Public API remains Dart-owned via `DartXray`.

## Stable native ABI contract

The native artifact must export these symbols:

- `int32_t dart_xray_init(const char* json, char* err, int32_t err_len)`
- `int32_t dart_xray_start(const char* json, char* err, int32_t err_len)`
- `int32_t dart_xray_stop(char* err, int32_t err_len)`
- `int32_t dart_xray_destroy(char* err, int32_t err_len)`
- `int64_t dart_xray_get_server_delay(const char* input, char* err, int32_t err_len)`
- `int64_t dart_xray_get_current_server_delay(const char* input, char* err, int32_t err_len)`
- `int32_t dart_xray_register_status_callback(void (*cb)(int32_t,const char*,void*), void* user, char* err, int32_t err_len)`
- `int32_t dart_xray_unregister_status_callback(char* err, int32_t err_len)`

Status code mapping:
- `0 = CONNECTING`
- `1 = CONNECTED`
- `2 = DISCONNECTED`
- `3+ = ERROR`

## Artifact names and placement

Build native artifacts locally, then copy into your app/plugin packaging pipeline.

| Platform | Artifact name expected by Dart loader | Typical packaging location |
|---|---|---|
| Android | `libdart_xray_ffi.so` | `android/src/main/jniLibs/<abi>/libdart_xray_ffi.so` |
| iOS | symbols in process (`dart_xray_ffi.framework`) | embedded framework in app/extension |
| macOS | `dart_xray_ffi.framework/dart_xray_ffi` or `libdart_xray_ffi.dylib` | `macos/Runner/Frameworks` |
| Windows | `dart_xray_ffi.dll` | next to executable or configured runtime dir |
| Linux | `libdart_xray_ffi.so` | next to executable or system library path |

Override path at runtime with:
- env var `DART_XRAY_LIB_PATH`, or
- `XrayInitOptions(nativeAssetsPath: ...)`

## Local build workflow

1. Build libXray-based native wrapper per target platform.
2. Ensure it exports the ABI symbols above.
3. Copy artifacts to the platform packaging location.
4. Start Flutter app; `DartXray` loads artifact with `dart:ffi`.

## Platform-specific responsibilities (outside engine FFI)

- Android: `VpnService`, socket protect, foreground service policy.
- Apple: `NEPacketTunnelProvider`, entitlements, signing, app group wiring.
- Linux/Windows: TUN interface setup, permissions/driver/runtime dependencies.

These responsibilities remain native, but engine control stays FFI-based.

## API

```dart
final xray = DartXray.instance;
await xray.init(const XrayInitOptions(workingDirectory: '/tmp/dart_xray'));
await xray.startPersistentStatusListener();
await xray.start(request);
final delay = await xray.getCurrentServerDelay();
await xray.stop();
```

Status streams:
- `onStatusChanged`
- `persistentStatusStream`

Parser utilities include VLESS, VMess, Trojan, Shadowsocks, SOCKS, and HTTP link forms.
