#!/usr/bin/env bash
set -euo pipefail

# Reset the local Supabase database (drops data, re-runs migrations
# and seed.sql). Asks for confirmation before destroying anything.
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd)"
cd "${ROOT_DIR}"

if ! command -v supabase >/dev/null 2>&1; then
  echo "supabase CLI is required" >&2
  exit 1
fi

read -r -p "This will drop the LOCAL Supabase database. Continue? [y/N] " ans
case "${ans}" in
  y|Y|yes|YES) ;;
  *) echo "aborted"; exit 1 ;;
esac

supabase --workdir backend db reset
