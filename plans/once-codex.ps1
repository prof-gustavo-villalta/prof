param(
  [string]$Model = "gpt-5.3-codex-spark"
)

$ErrorActionPreference = "Stop"

function Get-RecentCommits {
  $commits = git log -n 12 --format="%H%n%ad%n%B---" --date=short 2>$null

  if ([string]::IsNullOrWhiteSpace($commits)) {
    return "No commits found"
  }

  return $commits
}

function Get-IssueSnapshot {
  return (& powershell -NoProfile -ExecutionPolicy Bypass -File "$PSScriptRoot\issue-status.ps1" | Out-String)
}

$recentCommits = Get-RecentCommits
$issueSnapshot = Get-IssueSnapshot
$prompt = @"
@plans/prompt.md

Recent commits:
$recentCommits

docs/issues snapshot:
$issueSnapshot
"@

codex exec --yolo --model $Model $prompt
