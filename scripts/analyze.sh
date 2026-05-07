#!/usr/bin/env bash
set -euo pipefail

# Static analysis only. Does not run tests.
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd)"
cd "${ROOT_DIR}/client"

echo "==> flutter analyze"
flutter analyze
