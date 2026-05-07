#!/usr/bin/env bash
set -euo pipefail

# Format all source code in the repo.
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd)"
cd "${ROOT_DIR}"

echo "==> dart format client/"
( cd client && dart format . )

if command -v deno >/dev/null 2>&1; then
  echo "==> deno fmt backend/supabase/functions/"
  deno fmt backend/supabase/functions/
else
  echo "==> deno not installed — skipping backend fmt"
fi
