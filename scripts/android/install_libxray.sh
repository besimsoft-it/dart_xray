#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 /path/to/dart_xray-abi-output" >&2
  exit 1
fi

SRC_ROOT="$1"
DST_ROOT="$(cd "$(dirname "$0")/../.." && pwd)/android/src/main/jniLibs"

if [[ ! -d "$SRC_ROOT" ]]; then
  echo "Source directory does not exist: $SRC_ROOT" >&2
  exit 1
fi

mapfile -t so_files < <(find "$SRC_ROOT" -type f -name 'libdart_xray_ffi.so')
if [[ ${#so_files[@]} -eq 0 ]]; then
  echo "No libdart_xray_ffi.so files found under: $SRC_ROOT" >&2
  exit 1
fi

for so in "${so_files[@]}"; do
  abi="$(basename "$(dirname "$so")")"
  mkdir -p "$DST_ROOT/$abi"
  cp -f "$so" "$DST_ROOT/$abi/libdart_xray_ffi.so"
  echo "Installed $abi/libdart_xray_ffi.so"
done

echo "Done. Installed libraries into: $DST_ROOT"
