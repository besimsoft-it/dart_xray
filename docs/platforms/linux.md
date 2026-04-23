# Linux

## Modes

- Proxy: scaffolded
- TUN: scaffolded (requires host capabilities)

## Required setup

1. Provide libXray shared library and load path.
2. Ensure `/dev/net/tun` exists and is accessible.
3. Grant `CAP_NET_ADMIN` (or run with equivalent privileges).
4. Implement route and DNS handling in native integration layer.

## Caveats

- Behavior can vary by distro and network manager.
- Containerized environments often block TUN unless explicitly enabled.
