#!/usr/bin/env bash
set -euo pipefail

model="${1:-gpt-5.3-codex-spark}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

recent_commits="$(git log -n 12 --format="%H%n%ad%n%B---" --date=short 2>/dev/null || true)"
if [[ -z "$recent_commits" ]]; then
  recent_commits="No commits found"
fi

issue_snapshot="$(bash "$script_dir/issue-status.sh")"

prompt="$(cat <<EOF
@plans/prompt.md

Recent commits:
$recent_commits

docs/issues snapshot:
$issue_snapshot
EOF
)"

codex exec --dangerously-bypass-approvals-and-sandbox --model "$model" "$prompt"
