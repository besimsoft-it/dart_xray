# Troubleshooting

## App always shows `DISCONNECTED`

Likely cause: native adapters are still scaffolded and not yet linked to libXray runtime. Complete per-platform integration in `docs/platforms/*`.

## Android start fails immediately

Check:
- `VpnService` permission flow
- foreground service declarations
- native `.so` packaging and ABI filters

## iOS/macOS cannot start TUN

Check:
- Packet Tunnel extension target exists
- correct entitlements and signing
- device testing (simulator has VPN limitations)

## Windows TUN not available

Check:
- Wintun driver/runtime installed
- elevated privileges if required
- route setup is permitted

## Linux TUN start permission denied

Check:
- `/dev/net/tun` exists
- process has `CAP_NET_ADMIN`
- firewall/routing tools are installed and available
