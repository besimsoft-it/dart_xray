# Android

## Modes

- Proxy: scaffolded
- TUN: scaffolded through `VpnService` integration point

## Required setup

1. Add `android.permission.INTERNET` and VPN service declarations.
2. Implement a `VpnService` subclass and user consent flow (`VpnService.prepare`).
3. Integrate libXray Android wrapper (gomobile/JNI) and load native libraries.
4. Wire socket protection callback from VPN service into libXray protect API.
5. Add foreground service handling for long-running sessions.

## Notes

- Some devices require aggressive battery optimization exclusions.
- Route strategy and DNS behavior should be configurable in native layer.
