#!/usr/bin/env bash
set -euo pipefail

iterations="${1:-1}"
model="${2:-gpt-5.3-codex-spark}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! [[ "$iterations" =~ ^[0-9]+$ ]] || ((iterations < 1)); then
  echo "Usage: npm run l:ralph:afk -- <iterations> [model]" >&2
  exit 1
fi

write_progress() {
  local timestamp
  timestamp="$(date +%H:%M:%S)"
  echo "[$timestamp] $*"
}

get_next_issue_line() {
  bash "$script_dir/issue-status.sh" | grep -m1 -E '\|\s+open\s+\|' || true
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

write_progress "Starting issue loop for $iterations iteration(s). Model: $model."

for ((i = 1; i <= iterations; i++)); do
  iteration_start="$SECONDS"
  echo
  write_progress "Iteration $i/$iterations starting."

  next_issue="$(get_next_issue_line)"
  if [[ -z "$next_issue" ]]; then
    write_progress "No open issue found before iteration."
  else
    write_progress "Next open issue: $next_issue"
  fi

  tmp_file="$(mktemp)"
  set +e
  bash "$script_dir/once-codex.sh" "$model" 2>&1 | tee "$tmp_file"
  exit_code="${PIPESTATUS[0]}"
  set -e

  duration=$((SECONDS - iteration_start))
  write_progress "Iteration $i/$iterations finished in $(printf '%02d:%02d' $((duration / 60)) $((duration % 60))). Exit code: $exit_code."

  if ((exit_code != 0)); then
    rm -f "$tmp_file"
    write_progress "Stopping because iteration command failed."
    exit "$exit_code"
  fi

  final_promise="$(get_final_promise "$tmp_file")"
  rm -f "$tmp_file"

  if [[ "$final_promise" == "NO_MORE_TASKS" ]]; then
    write_progress "Issue loop complete after $i iteration(s)."
    exit 0
  fi

  if [[ "$final_promise" == "ABORT" ]]; then
    write_progress "Issue loop aborted after $i iteration(s)."
    exit 1
  fi
done

write_progress "Issue loop reached requested iteration limit."
