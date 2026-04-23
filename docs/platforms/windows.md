# Windows

## Modes

- Proxy: scaffolded
- TUN: scaffolded (requires external runtime setup)

## Required setup

1. Package libXray native artifacts (`.dll`) with the app.
2. For TUN mode, install/configure Wintun (or equivalent) dependency.
3. Ensure process has privileges needed for route/adapter updates.
4. Implement native bridge from plugin C++ layer to libXray runtime.

## Caveats

- TUN setup may require administrator privileges.
- Driver distribution policies vary by enterprise environment.
