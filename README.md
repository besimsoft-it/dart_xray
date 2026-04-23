# dart_xray

`dart_xray` is a production-oriented Flutter plugin scaffold for integrating **XTLS/libXray** with a uniform Dart API across Android, iOS, macOS, Windows, and Linux.

> This repository provides:
> - A stable Dart API surface.
> - Link parsing and request normalization utilities.
> - Platform channel bridges and status stream contracts.
> - Full setup documentation for platform-specific VPN/TUN requirements.

## Current implementation status

This first implementation focuses on **API stability and integration scaffolding**. Native runtime hookup to libXray is intentionally explicit and documented rather than faked.

- ✅ Dart API implemented.
- ✅ Link parsing utilities implemented (VLESS, VMess, Trojan, Shadowsocks, SOCKS/HTTP forms).
- ✅ Status stream contract implemented.
- ✅ Platform plugin entry points added for all targets.
- ⚠️ Native libXray runtime binding is scaffolded and must be completed per platform build pipeline.

## Install

```yaml
dependencies:
  dart_xray:
    git:
      url: https://github.com/your-org/dart_xray.git
```

## Quick start

```dart
final xray = DartXray.instance;

await xray.init(const XrayInitOptions(
  workingDirectory: '/tmp/dart_xray',
  enableDebugLogs: true,
));

await xray.startPersistentStatusListener();

final sub = xray.onStatusChanged.listen((status) {
  print('status: ${status.wireValue}');
});

final request = xray.requestFromLink('vless://uuid@example.com:443?security=tls#main');
await xray.start(request);

final ping = await xray.getCurrentServerDelay();
await xray.stop();
await sub.cancel();
```

## Platform feature matrix

| Platform | Proxy mode | TUN mode | Additional setup | Example runs OOTB |
|---|---|---|---|---|
| Android | JNI scaffold with explicit libxray.so contract | VpnService + TUN handoff scaffold | Local libXray Android build + jniLibs install | Requires local native artifact |
| iOS | Scaffolded | Scaffolded via NEPacketTunnelProvider | Network Extension target, entitlements, signing | Requires Xcode edits |
| macOS | Scaffolded | Scaffolded via Network Extension | Entitlements, sandbox + extension target | Requires Xcode edits |
| Windows | Scaffolded | Scaffolded | Wintun/driver/admin caveats | Requires native dependencies |
| Linux | Scaffolded | Scaffolded | `CAP_NET_ADMIN`, `/dev/net/tun`, routing permissions | Requires host setup |

See docs:
- [Architecture](docs/architecture.md)
- [Android native build workflow](docs/android-native-build.md)
- [Status model](docs/status-model.md)
- [Parsing](docs/parsing.md)
- [Troubleshooting](docs/troubleshooting.md)
- Platform guides under [`docs/platforms/`](docs/platforms)

## Security notes

- Never log raw credentials in production.
- Validate and sanitize remote configs before start.
- Restrict working directory permissions.
- Use platform secure storage for secrets.

## Building native artifacts

libXray integration can be done through different paths per platform:
- Go mobile bindings (`gomobile bind`) for Apple/Android wrappers.
- Go `c-shared` wrappers for desktop.
- Native helper process bridge where driver/runtime packaging is required.

Detailed guidance is documented per platform.
