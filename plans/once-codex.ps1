$ErrorActionPreference = "Stop"

function Get-RalphCommits {
  $commits = git log --grep="RALPH" -n 10 --format="%H%n%ad%n%B---" --date=short 2>$null

  if ([string]::IsNullOrWhiteSpace($commits)) {
    return "No RALPH commits found"
  }

  return $commits
}

$ralphCommits = Get-RalphCommits
$prompt = @"
@plans/prompt.md

Previous RALPH commits:
$ralphCommits
"@

codex exec $prompt
