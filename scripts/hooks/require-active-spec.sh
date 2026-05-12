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
  current_blocked=$(python3 -c "
import sys, json
d = json.load(open('${STATE_FILE}'))
blocked = d.get('blocked_specs', [])
print(', '.join(blocked) if blocked else 'none')
" 2>/dev/null || echo "unknown")

  cat >&2 <<EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BLOCKED: No active spec selected
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
You are trying to edit client/lib/ or backend/ without
an active spec in ${STATE_FILE}.

To proceed:
  1. Pick a spec from docs/specs/open/
  2. Set "current_spec": "SPEC-XXXX" in ${STATE_FILE}
  3. Or run /mvp-orchestrator to let it select the next spec

Blocked specs (do not retry): ${current_blocked}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  exit 2
fi
