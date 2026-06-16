#!/usr/bin/env bash
set -euo pipefail

model="${1:-gpt-5.3-codex-spark}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

recent_commits="$(git log -n 12 --format="%H%n%ad%n%B---" --date=short 2>/dev/null || true)"
if [[ -z "$recent_commits" ]]; then
  recent_commits="No commits found"
fi

assert_clean_worktree() {
  if [[ -n "$(git status --porcelain)" ]]; then
    echo "codex-once requires a clean worktree before it can auto-commit changes." >&2
    exit 1
  fi
}

worktree_dirty() {
  [[ -n "$(git status --porcelain)" ]]
}

get_final_promise() {
  local file="$1"
  local last_lines
  last_lines="$(tail -n 5 "$file" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"

  if printf '%s\n' "$last_lines" | grep -qx '<promise>NO MORE TASKS</promise>'; then
    echo "NO_MORE_TASKS"
    return
  fi

  if printf '%s\n' "$last_lines" | grep -qx '<promise>ABORT</promise>'; then
    echo "ABORT"
    return
  fi
}

get_auto_commit_message() {
  local changed_issue
  changed_issue="$(git diff --name-only | grep -m1 -E '^docs/issues/[0-9]+-.+\.md$' || true)"

  if [[ -z "$changed_issue" ]]; then
    echo "Complete codex iteration"
    return
  fi

  local issue_title
  issue_title="$(grep -m1 -E '^#[[:space:]]+' "$changed_issue" | sed -E 's/^#[[:space:]]+//')"

  if [[ -z "$issue_title" ]]; then
    echo "Complete codex iteration for $changed_issue"
    return
  fi

  echo "Complete $issue_title"
}

issue_snapshot="$(bash "$script_dir/issue-status.sh")"

prompt="$(cat <<EOF
@plans/prompt.md

Recent commits:
$recent_commits

docs/issues snapshot:
$issue_snapshot
EOF
)"

assert_clean_worktree
tmp_file="$(mktemp)"
set +e
codex exec --dangerously-bypass-approvals-and-sandbox --model "$model" "$prompt" 2>&1 | tee "$tmp_file"
exit_code="${PIPESTATUS[0]}"
set -e

if ((exit_code != 0)); then
  rm -f "$tmp_file"
  exit "$exit_code"
fi

final_promise="$(get_final_promise "$tmp_file")"
rm -f "$tmp_file"

if worktree_dirty && [[ -z "$final_promise" ]]; then
  npm run analyze
  npm run test

  message="$(get_auto_commit_message)"
  git add -A
  git commit -m "$message" -m "Automated codex-once commit.

Review changed files for selected issue and criterion details."
fi
