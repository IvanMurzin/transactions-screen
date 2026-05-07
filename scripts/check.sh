#!/usr/bin/env bash
set -euo pipefail

# End-of-work / pre-commit check. Lightweight: format + analyze +
# AI-instruction parity. Does NOT run tests.
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd)"
cd "${ROOT_DIR}"

./scripts/format.sh
./scripts/analyze.sh
./scripts/check-ai-consistency.sh
