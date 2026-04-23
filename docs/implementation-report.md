# Implementation report

## Architecture summary

- Unified Dart API in `DartXray`.
- Method/Event channel based native boundary.
- Public parsing utilities convert links into normalized models and start requests.
- Per-platform plugin registrants scaffolded for future libXray runtime binding.

## Feature matrix

| Feature | Status |
|---|---|
| `init/start/stop` API | Implemented |
| Delay APIs | Implemented at API contract level |
| Live status streams | Implemented |
| Persistent status stream API | Implemented |
| Link parsing (VLESS/VMess/Trojan/SS/SOCKS/HTTP) | Implemented |
| Native libXray start/stop integration | Scaffolded |
| Android VpnService wiring | Implemented scaffold with explicit service + JNI contracts |
| Apple NetworkExtension wiring | Scaffolded + documented |
| Windows/Linux runtime + TUN dependency wiring | Scaffolded + documented |

## Fully implemented now

- Dart API contract and models.
- Parser module and parser tests.
- Example Flutter UI flow.
- Comprehensive platform setup documentation.

## Partial / remaining gaps

- Native adapters currently return placeholder success and default `DISCONNECTED` status.
- Actual libXray wrappers must be compiled and invoked per platform.
- TUN data-path orchestration must be implemented in native layers.

## Tradeoffs

- Prioritized API stability and explicit docs over fake native completeness.
- Chose platform channels for broad Flutter compatibility and async event support.
