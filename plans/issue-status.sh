#!/usr/bin/env bash
set -euo pipefail

shopt -s nullglob
issue_files=(docs/issues/*.md)

if ((${#issue_files[@]} == 0)); then
  echo "No docs/issues files found"
  exit 0
fi

for file in "${issue_files[@]}"; do
  title="$(grep -m1 -E '^#\s+' "$file" | sed -E 's/^#\s+//; s/[[:space:]]+$//' || true)"
  if [[ -z "$title" ]]; then
    title="$(basename "$file" .md)"
  fi

  done_count="$(grep -c -E '^- \[x\] ' "$file" || true)"
  open_count="$(grep -c -E '^- \[ \] ' "$file" || true)"

  if [[ "$open_count" == "0" ]]; then
    status="done"
  else
    status="open"
  fi

  echo "$file | $status | done=$done_count open=$open_count | $title"

  blocked_by="$(grep -E '^- docs/issues/.+\.md[[:space:]]*$' "$file" | sed -E 's/^- //; s/[[:space:]]+$//' || true)"
  if [[ -n "$blocked_by" ]]; then
    echo "  blocked_by: $(echo "$blocked_by" | paste -sd ', ' -)"
  fi

  grep -E '^- \[ \] ' "$file" |
    sed -E 's/^- \[ \] /  open: /' || true
done
