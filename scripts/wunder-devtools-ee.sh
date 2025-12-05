#!/usr/bin/env bash
set -euo pipefail

IMAGE="ghcr.io/lightning-it/wunder-devtools-ee:main"

docker run --rm \
  --entrypoint "" \
  -v "$PWD":/workspace \
  -w /workspace \
  "$IMAGE" "$@"
