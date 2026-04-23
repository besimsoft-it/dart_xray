# Android native integration (libXray)

This plugin uses a **local-build-first** Android integration model with a thin FFI ABI wrapper.

## Expected artifact

Expected native output consumed by Dart FFI:

- ABI shared library: `libdart_xray_ffi.so`
- one folder per ABI (for example `arm64-v8a`, `armeabi-v7a`, `x86_64`)

Place files in:

- `android/src/main/jniLibs/<abi>/libdart_xray_ffi.so`

Example:

```
android/src/main/jniLibs/
  arm64-v8a/libdart_xray_ffi.so
  armeabi-v7a/libdart_xray_ffi.so
  x86_64/libdart_xray_ffi.so
```

## Local build + install workflow

1. Build libXray for Android.
2. Build/package the `dart_xray` ABI wrapper library that exports `dart_xray_*` symbols.
3. Copy ABI folders into this plugin:

   ```bash
   ./scripts/android/install_libxray.sh /path/to/abi-wrapper/output
   ```

4. Build your Flutter Android app.

## Android native scope (OS only)

Android native code in this repository is limited to OS/framework responsibilities:

- `DartXrayVpnService` foreground lifecycle
- TUN interface ownership (`VpnService.Builder.establish()`)
- service declaration and lifecycle integration

Engine operations are **not** proxied through Flutter channels.
All engine controls (`init/start/stop/delay/status`) are FFI-based from Dart.
