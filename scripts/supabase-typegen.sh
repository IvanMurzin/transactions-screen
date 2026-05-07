#!/usr/bin/env bash
set -euo pipefail

# Generate TypeScript types from the local Supabase schema for use
# inside Edge Functions. Output goes to:
#   backend/supabase/functions/_shared/database.types.ts
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd)"
cd "${ROOT_DIR}"

if ! command -v supabase >/dev/null 2>&1; then
  echo "supabase CLI is required" >&2
  exit 1
fi

OUT="backend/supabase/functions/_shared/database.types.ts"
echo "==> Generating ${OUT}"
supabase --workdir backend gen types typescript --local >"${OUT}"
echo "==> Wrote ${OUT}"
