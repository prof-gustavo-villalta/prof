param(
  [string]$Model = "gpt-5.3-codex-spark"
)

$ErrorActionPreference = "Stop"
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

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

function Assert-CleanWorktree {
  $status = git status --porcelain

  if (-not [string]::IsNullOrWhiteSpace($status)) {
    Write-Error "codex-once requires a clean worktree before it can auto-commit changes."
  }
}

function Test-WorktreeDirty {
  $status = git status --porcelain
  return -not [string]::IsNullOrWhiteSpace($status)
}

function Get-FinalPromise {
  param([string]$Text)

  $lines = $Text -split "\r?\n" |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_.Length -gt 0 }

  if ($lines.Count -eq 0) {
    return $null
  }

  $lastLines = $lines | Select-Object -Last 5

  foreach ($line in $lastLines) {
    if ($line -eq "<promise>NO MORE TASKS</promise>") {
      return "NO_MORE_TASKS"
    }

    if ($line -eq "<promise>ABORT</promise>") {
      return "ABORT"
    }
  }

  return $null
}

function Get-AutoCommitMessage {
  $changedIssue = git diff --name-only | Where-Object { $_ -match '^docs/issues/\d+-.+\.md$' } | Select-Object -First 1

  if ([string]::IsNullOrWhiteSpace($changedIssue)) {
    return "Complete codex iteration"
  }

  $issueTitle = Get-Content $changedIssue |
    Where-Object { $_ -match '^#\s+' } |
    Select-Object -First 1

  if ([string]::IsNullOrWhiteSpace($issueTitle)) {
    return "Complete codex iteration for $changedIssue"
  }

  $cleanTitle = $issueTitle -replace '^#\s+', ''
  return "Complete $cleanTitle"
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

Assert-CleanWorktree
$tmpFile = New-TemporaryFile
$previousErrorActionPreference = $ErrorActionPreference

try {
  $ErrorActionPreference = "Continue"
  $prompt | codex exec --dangerously-bypass-approvals-and-sandbox --model $Model - |
    Tee-Object -FilePath $tmpFile.FullName

  $codexExitCode = $LASTEXITCODE
  if ($codexExitCode -ne 0) {
    exit $codexExitCode
  }

  $codexOutput = Get-Content -Raw $tmpFile.FullName
} finally {
  $ErrorActionPreference = $previousErrorActionPreference
  Remove-Item -LiteralPath $tmpFile.FullName -Force -ErrorAction SilentlyContinue
}

$finalPromise = Get-FinalPromise -Text $codexOutput

if ((Test-WorktreeDirty) -and [string]::IsNullOrWhiteSpace($finalPromise)) {
  npm run analyze
  npm run test

  $message = Get-AutoCommitMessage
  $body = @"
Automated codex-once commit.

Review changed files for selected issue and criterion details.
"@

  git add -A
  git commit -m $message -m $body
}
