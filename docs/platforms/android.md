# Android

This page defines the concrete Android integration contract for `dart_xray` + `libXray`.

## Chosen native integration model

`dart_xray` uses this model:

1. Build `libXray` Android native output **locally**.
2. Copy generated `libxray.so` files into plugin `jniLibs`.
3. Plugin loads `libxray.so` using `System.loadLibrary("xray")` and calls JNI methods from `XrayNativeBridge`.

This avoids forcing a Go toolchain into every Flutter build.

## Expected native artifact

Expected artifact per ABI:

- `libxray.so`

Expected plugin location:

- `android/src/main/jniLibs/<abi>/libxray.so`

Example:

```text
android/src/main/jniLibs/
  arm64-v8a/libxray.so
  armeabi-v7a/libxray.so
  x86_64/libxray.so
```

If missing, `init()` fails with error code `native_artifact_missing`.

## Local build + install steps

```bash
# 1) clone upstream
# https://github.com/XTLS/libXray

# 2) build Android output
python3 build/main.py android

# 3) install into this plugin
cd /path/to/dart_xray
./scripts/android/install_libxray.sh /path/to/libxray/build/output
```

Then run your Flutter Android build as usual.

## Android runtime ownership

### Plugin layer

- `DartXrayPlugin` handles method/event channels.
- `AndroidXraySessionManager` validates init/start/stop and emits status.

### VPN layer

- `DartXrayVpnService` owns `VpnService` lifecycle.
- service is declared in `android/src/main/AndroidManifest.xml`.
- service runs foreground for long-running sessions.

## VPN consent flow

- Flutter calls `prepareVpnPermission()`.
- Native calls `VpnService.prepare(activity)`.
- If consent UI is needed, Android shows it.
- `start()` fails with `vpn_permission_not_granted` until permission is granted.

## Socket protect contract

Native side must call JNI endpoint:

- `nativeProtectSocket(fd: Int): Boolean`

This is the integration point for Android `VpnService.protect(fd)` semantics.
Without this, outbound sockets can loop back into VPN routes.

## DNS handling contract

To avoid DNS recursion/looping:

- service calls `nativeInitDns(dnsServer)` before engine start
- service calls `nativeResetDns()` on stop

Native resolver sockets must be protected before connect.

## TUN handoff contract

When `mode == "tun"`:

1. service creates TUN with `VpnService.Builder.establish()`
2. service passes TUN file descriptor to `nativeAttachTunFd(FileDescriptor)`
3. service starts engine with `nativeStartEngine(mode)`

For `proxy` mode, TUN fd is not attached.

## Explicit startup errors

Android layer returns explicit errors:

- `native_artifact_missing`
- `native_engine_unavailable`
- `vpn_permission_not_granted`
- `not_initialized`
- `tun_startup_not_wired`
- `invalid_arguments`

Use these errors as actionable integration feedback.
