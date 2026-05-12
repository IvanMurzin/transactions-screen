#!/usr/bin/env bash
# PostToolUse hook — fires after every Bash call.
# Reads the tool result JSON from stdin, detects common failure patterns,
# and prints a clear stop-message so agents don't spiral into workarounds.

set -euo pipefail

payload="$(cat)"

exit_code=$(echo "${payload}" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('exit_code', 0))" 2>/dev/null || echo "0")

if [[ "${exit_code}" == "0" ]]; then
  exit 0
fi

output=$(echo "${payload}" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('stdout','') + d.get('stderr',''))" 2>/dev/null || echo "")

# build_runner failures
if echo "${output}" | grep -qE "build_runner|BuildRunner|build runner"; then
  cat >&2 <<'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BUILD_RUNNER FAILED — STOP AND READ THIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
The Dart error above is the root cause. Fix the Dart
source file(s) shown in the error, then re-run:
  dart run build_runner build --delete-conflicting-outputs

DO NOT:
  • Read build_runner source code
  • Add experimental flags or dart options
  • Try alternative build_runner commands
  • Loop on this error more than twice — STOP and report
    the Dart error to the user if you cannot fix it.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  exit 0
fi

# flutter analyze failures
if echo "${output}" | grep -qE "flutter analyze|Analyzing "; then
  cat >&2 <<'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FLUTTER ANALYZE FAILED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Fix the errors listed above. Each error shows file:line.
After fixing, re-run: flutter analyze
If the same error recurs twice, STOP and report to user.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  exit 0
fi

# flutter test failures
if echo "${output}" | grep -qE "flutter test|Some tests failed|FAILED"; then
  cat >&2 <<'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FLUTTER TEST FAILED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Fix failing tests shown above. Tests are in client/test/.
After fixing, re-run: flutter test
If the same failure recurs twice, STOP and report to user.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  exit 0
fi

exit 0
