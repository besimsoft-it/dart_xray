# iOS

## Modes

- Proxy: scaffolded
- TUN: scaffolded via `NEPacketTunnelProvider` extension path

## Required setup

1. Create a Packet Tunnel extension target.
2. Enable Network Extension capability and Packet Tunnel entitlement.
3. Configure App Group if host app and extension share config/state.
4. Integrate libXray iOS binding in extension target.
5. Implement start/stop tunnel flow and status callbacks to Flutter app container.
6. Test on physical device (simulator limitations apply).

## Signing caveats

- Extension and app must be signed with compatible profiles.
- VPN entitlements require Apple Developer account permissions.
