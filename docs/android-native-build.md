# Android local native build: libXray -> dart_xray FFI ABI

This is the reproducible maintainer workflow.

## 1) Build libXray Android artifact locally

```bash
git clone https://github.com/XTLS/libXray.git
cd libXray
python3 build/main.py android
```

## 2) Build/produce the thin ABI wrapper used by Dart FFI

`dart_xray` expects an Android shared object named `libdart_xray_ffi.so` that exports
`dart_xray_*` C symbols (for init/start/stop/destroy/delay/status callback APIs).

The wrapper links to (or embeds) libXray and exposes the stable ABI consumed from
`lib/src/ffi/xray_native_bindings.dart`.

## 3) Install ABI artifacts into plugin Android jniLibs

From `dart_xray` repo root:

```bash
./scripts/android/install_libxray.sh /absolute/path/to/abi-wrapper-output
```

The script copies to:

- `android/src/main/jniLibs/<abi>/libdart_xray_ffi.so`

## 4) Build Flutter Android app

```bash
flutter run -d android
```

## Important separation

- Engine control is Dart -> FFI -> `libdart_xray_ffi.so`.
- Android framework responsibilities stay native (`VpnService`, foreground service, permission flow in app code).
- No engine operation is invoked through Flutter MethodChannel/EventChannel.
