# macOS

## Modes

- Proxy: scaffolded
- TUN: scaffolded via Network Extension approach

## Required setup

1. Add a Packet Tunnel extension target.
2. Enable Network Extension entitlements on app + extension.
3. Configure App Sandbox entitlements according to VPN needs.
4. Integrate libXray macOS-compatible binary/binding in extension.
5. Handle user approval and system extension behavior where applicable.

## Differences vs iOS

- macOS may require additional sandbox/network permissions.
- Distribution/signing policy differs between debug and notarized builds.
