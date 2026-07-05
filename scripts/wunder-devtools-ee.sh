#!/usr/bin/env bash
set -euo pipefail

IMAGE="quay.io/l-it/ee-wunder-devtools-ubi9:v1.9.2"

docker run --rm \
  --entrypoint "" \
  -v "$PWD":/workspace \
  -w /workspace \
  "$IMAGE" "$@"
