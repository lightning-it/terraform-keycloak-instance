#!/usr/bin/env bash
set -euo pipefail

IMAGE="ghcr.io/lightning-it/wunder-devtools-ee:v1.0.8"

docker run --rm \
  --entrypoint "" \
  -v "$PWD":/workspace \
  -w /workspace \
  "$IMAGE" "$@"
