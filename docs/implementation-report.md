# Implementation Report

## Step 1 audit summary

Previous state:
- Dart API delegated engine calls through platform interface + `MethodChannel`.
- Status streams were backed by `EventChannel`.
- Native integration was mostly scaffolded.

Reusable pieces:
- Public API shape and data models.
- Link parser and tests.

Replaced pieces:
- Channel-backed engine control path.
- Platform interface as primary runtime contract.

## Step 2 architecture chosen

- Single FFI-first engine path for all platforms.
- Stable symbol contract (`dart_xray_*`) to isolate libXray internals.
- Callback-based native status propagation to Dart streams.
- Local artifact build/copy workflow treated as first-class.

## Step 3 implementation delivered

Added:
- `lib/src/ffi/xray_dynamic_library_loader.dart`
- `lib/src/ffi/xray_native_bindings.dart`
- `lib/src/ffi/xray_engine_ffi.dart`
- `lib/src/ffi/xray_ffi_exceptions.dart`

Updated:
- `DartXray` now calls FFI engine directly.
- Tests now mock FFI engine instead of platform channel interface.

## Step 4 channel isolation

Engine operations (`init/start/stop/delay/status`) no longer depend on channels.
Legacy platform plugin classes may still exist in platform folders for app-host concerns, but are not used for engine control.

## Step 5 documentation updates

Updated:
- `README.md`
- `docs/architecture.md`

Documented:
- ABI symbols
- artifact naming/placement by platform
- local build and integration workflow
- native VPN/TUN responsibilities outside FFI

## Step 6 current state

Fully implemented:
- Dart API to FFI bridge
- dynamic loading
- symbol binding
- callback stream propagation
- explicit error mapping

Manual work still required:
- produce per-platform native artifacts from libXray + wrapper
- wire VPN/TUN host-layer setup in each target app
