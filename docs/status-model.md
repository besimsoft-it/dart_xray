# Status model

The plugin exposes two streams:
- `onStatusChanged`: session-level live status.
- `persistentStatusStream`: long-lived listener for repeated start/stop cycles.

## Canonical states

- `CONNECTING`: startup/tunnel setup in progress.
- `CONNECTED`: active session.
- `DISCONNECTED`: stopped and cleaned up.
- `ERROR`: startup/runtime failure.

## Transition rules

- `start()` should emit `CONNECTING` immediately.
- On success, emit `CONNECTED`.
- On any failure, emit `ERROR`.
- `stop()` must end in `DISCONNECTED`.

## Runtime failure handling

If a native tunnel/process dies unexpectedly:
1. emit `ERROR`
2. leave cleanup to caller-driven `stop()`
3. once cleanup finishes, emit `DISCONNECTED`
