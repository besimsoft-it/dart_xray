# dart_xray FFI Architecture

## Core decision

`dart_xray` uses direct `dart:ffi` for engine integration on all supported platforms:
- Android
- iOS
- macOS
- Windows
- Linux

`MethodChannel`/`EventChannel` are not part of the engine control path.

## Layers

1. **Public Dart API** (`DartXray`)
   - `init/start/stop/getServerDelay/getCurrentServerDelay`
   - status streams
   - parsing helpers
2. **FFI engine bridge** (`lib/src/ffi/*`)
   - dynamic library loading
   - symbol binding
   - callback registration and stream fan-out
   - explicit exception mapping
3. **Native ABI wrapper** (built from libXray + thin C exports)
   - stable C symbols consumed by Dart
4. **Platform-native VPN/TUN host pieces**
   - VpnService / Network Extension / TUN driver setup

## Native callback model

Dart registers a native callback function pointer through FFI.
Native runtime pushes status updates (`CONNECTING`, `CONNECTED`, `DISCONNECTED`, `ERROR`) through this callback.
Dart converts them into:
- `onStatusChanged`
- `persistentStatusStream`

No EventChannel is used.

## Artifact loading strategy

Loader checks, in order:
1. env `DART_XRAY_LIB_PATH`
2. `XrayInitOptions.nativeAssetsPath`
3. platform defaults (`libdart_xray_ffi.so`, `dart_xray_ffi.dll`, process/framework on Apple)

Failure throws `XrayNativeLibraryLoadException` with attempted locations.

## Error model

- load failures → `XrayNativeLibraryLoadException`
- missing symbols → `XrayNativeSymbolException`
- runtime native errors → `XrayNativeCallException`

Errors are explicit; no silent fallbacks.
