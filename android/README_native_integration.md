# Android native integration (libXray)

This plugin uses a **local-build-first** Android integration model.

## Expected artifact

Expected native output from local `libXray` Android build:

- JNI shared library: `libxray.so`
- one folder per ABI (for example `arm64-v8a`, `armeabi-v7a`, `x86_64`)

Place files in:

- `android/src/main/jniLibs/<abi>/libxray.so`

Example:

```
android/src/main/jniLibs/
  arm64-v8a/libxray.so
  armeabi-v7a/libxray.so
  x86_64/libxray.so
```

If `libxray.so` is missing, `init()` fails with `native_artifact_missing`.

## Local build + install workflow

1. Clone upstream libXray.
2. Run official Android build script:

   ```bash
   python3 build/main.py android
   ```

3. Locate generated `.so` files from libXray build output.
4. Copy ABI folders into this plugin:

   ```bash
   ./scripts/android/install_libxray.sh /path/to/libxray/output
   ```

5. Build your Flutter Android app.

## VPN and service contract

- `DartXrayPlugin` owns plugin channel and start/stop orchestration.
- `DartXrayVpnService` owns VPN process lifecycle and foreground notification.
- `prepareVpn` method calls `VpnService.prepare(activity)` and triggers consent UI.
- `start()` requires prior consent; otherwise it fails with `vpn_permission_not_granted`.
- `start()` starts `DartXrayVpnService` as a foreground service.

## Socket protect contract

`libXray` socket protect is expected through JNI method:

- `nativeProtectSocket(fd: Int): Boolean`

`DartXrayVpnService` is the Android owner of `VpnService.protect(fd)` semantics.
The native side must call this JNI endpoint before opening protected outbound sockets.

## DNS handling contract

To prevent VPN recursion loops:

- service calls `nativeInitDns(dnsServer)` before engine start
- service calls `nativeResetDns()` on stop

Native side should route resolver sockets through protect logic.

## TUN handoff contract

When mode is `tun`:

1. service creates TUN via `VpnService.Builder.establish()`
2. service passes TUN file descriptor to native using `nativeAttachTunFd(FileDescriptor)`
3. service then calls `nativeStartEngine(mode)`

For `proxy` mode, no TUN fd is attached.
