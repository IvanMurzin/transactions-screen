#!/usr/bin/env bash
set -euo pipefail

# End-of-work / pre-commit check: format + analyze + tests + AI-instruction parity.
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd)"
cd "${ROOT_DIR}"

./scripts/format.sh
./scripts/analyze.sh

echo "Running flutter test..."
(cd client && flutter test --no-pub)

./scripts/check-ai-consistency.sh
