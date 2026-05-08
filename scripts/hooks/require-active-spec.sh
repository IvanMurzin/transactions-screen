#!/usr/bin/env bash
set -euo pipefail

STATE_FILE=".agent/state/mvp-orchestrator.json"

# If the orchestrator state is not present, do not block generic editing.
if [[ ! -f "${STATE_FILE}" ]]; then
  exit 0
fi

payload="$(cat)"

# Only gate code-area edits/writes. Spec authoring in docs/specs is always allowed.
if ! grep -Eq '"file_path":"(client/lib/|backend/)' <<< "${payload}"; then
  exit 0
fi

if grep -Eq '"current_spec":[[:space:]]*null' "${STATE_FILE}"; then
  echo "Blocked: current_spec is null in ${STATE_FILE}. Select or create an active spec first." >&2
  exit 2
fi
