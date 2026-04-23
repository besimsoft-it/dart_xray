#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 /path/to/libxray-android-output" >&2
  exit 1
fi

SRC_ROOT="$1"
DST_ROOT="$(cd "$(dirname "$0")/../.." && pwd)/android/src/main/jniLibs"

if [[ ! -d "$SRC_ROOT" ]]; then
  echo "Source directory does not exist: $SRC_ROOT" >&2
  exit 1
fi

mapfile -t so_files < <(find "$SRC_ROOT" -type f -name 'libxray.so')
if [[ ${#so_files[@]} -eq 0 ]]; then
  echo "No libxray.so files found under: $SRC_ROOT" >&2
  exit 1
fi

for so in "${so_files[@]}"; do
  abi="$(basename "$(dirname "$so")")"
  mkdir -p "$DST_ROOT/$abi"
  cp -f "$so" "$DST_ROOT/$abi/libxray.so"
  echo "Installed $abi/libxray.so"
done

echo "Done. Installed libraries into: $DST_ROOT"
