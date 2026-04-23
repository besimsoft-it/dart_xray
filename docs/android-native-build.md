# Android local native build: libXray -> dart_xray

This is the reproducible maintainer workflow.

## 1) Build libXray Android artifact locally

```bash
git clone https://github.com/XTLS/libXray.git
cd libXray
python3 build/main.py android
```

## 2) Find produced `libxray.so` files

Locate ABI outputs (for example):

- `arm64-v8a/libxray.so`
- `armeabi-v7a/libxray.so`
- `x86_64/libxray.so`

## 3) Install into plugin

From `dart_xray` repo root:

```bash
./scripts/android/install_libxray.sh /absolute/path/to/libxray/output
```

The script copies to:

- `android/src/main/jniLibs/<abi>/libxray.so`

## 4) Build Flutter Android app

```bash
flutter run -d android
```

## JNI contract expected by plugin

`XrayNativeBridge` expects these JNI methods to exist in `libxray.so`:

- `nativeInitEngine(configJson: String): Int`
- `nativeStartEngine(mode: String): Int`
- `nativeStopEngine(): Int`
- `nativeInitDns(serverAddress: String): Int`
- `nativeResetDns(): Int`
- `nativeAttachTunFd(tunFd: FileDescriptor): Int`
- `nativeProtectSocket(fd: Int): Boolean`

If these are missing, startup fails with `native_engine_unavailable`.
