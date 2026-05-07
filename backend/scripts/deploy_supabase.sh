#!/usr/bin/env bash
set -euo pipefail

# Deploy migrations + edge functions to a linked Supabase project.
# Reads SUPABASE_PROJECT_REF (and any optional secrets) from <repo>/.env.
#
# This is the simplest possible script. Add `secrets set` calls for any
# integrations your features need (RevenueCat server key, scheduler
# secrets, third-party API keys, …) — look at git history for examples.

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." >/dev/null 2>&1 && pwd)"
BACKEND_DIR="${ROOT_DIR}/backend"
ENV_FILE="${ROOT_DIR}/.env"
cd "${ROOT_DIR}"

if ! command -v supabase >/dev/null 2>&1; then
  echo "supabase CLI is required" >&2
  exit 1
fi

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing ${ENV_FILE} (copy .env.example and fill in values)" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1091
source "${ENV_FILE}"
set +a

if [[ -z "${SUPABASE_PROJECT_REF:-}" || "${SUPABASE_PROJECT_REF}" == "your_project_ref" ]]; then
  echo "Set SUPABASE_PROJECT_REF in ${ENV_FILE}" >&2
  exit 1
fi

echo "[1/3] Linking project ${SUPABASE_PROJECT_REF}"
supabase --workdir "${BACKEND_DIR}" link --project-ref "${SUPABASE_PROJECT_REF}"

echo "[2/3] Pushing migrations"
supabase --workdir "${BACKEND_DIR}" db push

echo "[3/3] Deploying edge functions"
supabase --workdir "${BACKEND_DIR}" functions deploy api

# Subscriptions: deploy the RevenueCat webhook only when its secrets are
# present. Skip silently otherwise so the script stays usable for projects
# that don't ship subscriptions yet.
if [[ -n "${REVENUECAT_WEBHOOK_SECRET:-}" && -n "${REVENUECAT_API_KEY:-}" ]]; then
  echo "[3/3+] Deploying revenuecat_webhook"
  supabase --workdir "${BACKEND_DIR}" functions deploy revenuecat_webhook
  supabase --workdir "${BACKEND_DIR}" secrets set \
    REVENUECAT_API_KEY="${REVENUECAT_API_KEY}" \
    REVENUECAT_WEBHOOK_SECRET="${REVENUECAT_WEBHOOK_SECRET}" \
    ${REVENUECAT_PRO_ENTITLEMENT:+REVENUECAT_PRO_ENTITLEMENT="${REVENUECAT_PRO_ENTITLEMENT}"} \
    ${REVENUECAT_PRO_ENTITLEMENTS:+REVENUECAT_PRO_ENTITLEMENTS="${REVENUECAT_PRO_ENTITLEMENTS}"} \
    >/dev/null
fi

echo "Done."
