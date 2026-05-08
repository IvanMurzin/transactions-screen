#!/usr/bin/env bash
set -euo pipefail

STATE_FILE=".agent/state/mvp-orchestrator.json"
SPEC_ROOT="docs/specs/open"

if [[ ! -f "${STATE_FILE}" ]]; then
  exit 0
fi

current_spec="$(sed -nE 's/^[[:space:]]*"current_spec":[[:space:]]*"([^"]+)".*/\1/p' "${STATE_FILE}")"
if [[ -z "${current_spec}" ]]; then
  exit 0
fi

spec_file="$(find "${SPEC_ROOT}" -type f -name "${current_spec}-*.md" | head -n1 || true)"
if [[ -z "${spec_file}" || ! -f "${spec_file}" ]]; then
  exit 0
fi

payload="$(cat)"

# Preferred source: frontmatter `allowed_change_areas`.
# Supported formats:
# - allowed_change_areas: ["client/lib/**", "test/**"]
# - allowed_change_areas:
#   - client/lib/**
#   - test/**
allowed=()
while IFS= read -r line; do
  [[ -n "${line}" ]] && allowed+=("${line}")
done < <(
  awk '
    BEGIN {
      fm=0
      in_allowed=0
      fm_seen=0
    }
    /^---[[:space:]]*$/ {
      if (fm_seen == 0) {
        fm=1
        fm_seen=1
        next
      }
      if (fm == 1) {
        fm=0
        in_allowed=0
        next
      }
    }
    fm == 1 {
      if ($0 ~ /^allowed_change_areas:[[:space:]]*\[/) {
        line=$0
        sub(/^allowed_change_areas:[[:space:]]*\[/, "", line)
        sub(/\][[:space:]]*$/, "", line)
        n=split(line, parts, /,[[:space:]]*/)
        for (i=1; i<=n; i++) {
          v=parts[i]
          gsub(/^[[:space:]]*"/, "", v)
          gsub(/"[[:space:]]*$/, "", v)
          gsub(/^[[:space:]]*'\''/, "", v)
          gsub(/'\''[[:space:]]*$/, "", v)
          if (v != "") print v
        }
        in_allowed=0
        next
      }
      if ($0 ~ /^allowed_change_areas:[[:space:]]*$/) {
        in_allowed=1
        next
      }
      if (in_allowed == 1) {
        if ($0 ~ /^[[:space:]]*-[[:space:]]+/) {
          v=$0
          sub(/^[[:space:]]*-[[:space:]]+/, "", v)
          gsub(/^[[:space:]]*"/, "", v)
          gsub(/"[[:space:]]*$/, "", v)
          gsub(/^[[:space:]]*'\''/, "", v)
          gsub(/'\''[[:space:]]*$/, "", v)
          if (v != "") print v
          next
        }
        if ($0 ~ /^[[:alpha:]_][[:alnum:]_]*:[[:space:]]*/) {
          in_allowed=0
        }
      }
    }
  ' "${spec_file}"
)

# Backward-compatible fallback: markdown section.
if [[ "${#allowed[@]}" -eq 0 ]]; then
  while IFS= read -r line; do
    [[ -n "${line}" ]] && allowed+=("${line}")
  done < <(
    awk '
      /^## Allowed change areas/ {on=1; next}
      /^## / && on==1 {on=0}
      on==1 && /^- `/ {
        gsub(/^- `/, "", $0)
        gsub(/`$/, "", $0)
        print $0
      }
    ' "${spec_file}"
  )
fi

if [[ "${#allowed[@]}" -eq 0 ]]; then
  exit 0
fi

touched=()
while IFS= read -r line; do
  [[ -n "${line}" ]] && touched+=("${line}")
done < <(grep -Eo '"file_path":"[^"]+"' <<< "${payload}" | sed -E 's/"file_path":"(.*)"/\1/')
if [[ "${#touched[@]}" -eq 0 ]]; then
  exit 0
fi

for path in "${touched[@]}"; do
  ok=0
  for prefix in "${allowed[@]}"; do
    prefix="${prefix%\*\*}"
    prefix="${prefix%*}"
    if [[ "${path}" == ${prefix}* ]]; then
      ok=1
      break
    fi
  done
  if [[ "${ok}" -eq 0 ]]; then
    echo "Blocked by spec scope guard: ${path} is outside allowed_change_areas in ${spec_file}" >&2
    exit 3
  fi
done
