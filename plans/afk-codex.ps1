param(
  [Parameter(Position = 0)]
  [int]$Iterations = 1,
  [string]$Model = "gpt-5.3-codex-spark"
)

$ErrorActionPreference = "Stop"

if ($Iterations -lt 1) {
  Write-Error "Usage: npm run ralph:afk -- <iterations>"
}

function Write-ProgressLine {
  param([string]$Message)

  $timestamp = Get-Date -Format "HH:mm:ss"
  Write-Host "[$timestamp] $Message"
}

function Get-NextIssueLine {
  $issueStatus = & powershell -NoProfile -ExecutionPolicy Bypass -File "$PSScriptRoot\issue-status.ps1"
  $issueStatus | Where-Object { $_ -match '\|\s+open\s+\|' } | Select-Object -First 1
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

Write-ProgressLine "Starting issue loop for $Iterations iteration(s). Model: $Model."

for ($i = 1; $i -le $Iterations; $i++) {
  $iterationStart = Get-Date
  Write-Host ""
  Write-ProgressLine "Iteration $i/$Iterations starting."

  $nextIssue = Get-NextIssueLine
  if ([string]::IsNullOrWhiteSpace($nextIssue)) {
    Write-ProgressLine "No open issue found before iteration."
  } else {
    Write-ProgressLine "Next open issue: $nextIssue"
  }

  $tmpFile = New-TemporaryFile
  $exitCode = 0
  $previousErrorActionPreference = $ErrorActionPreference

  try {
    $ErrorActionPreference = "Continue"
    & powershell -NoProfile -ExecutionPolicy Bypass -File "$PSScriptRoot\once-codex.ps1" -Model $Model |
      Tee-Object -FilePath $tmpFile.FullName
    $exitCode = $LASTEXITCODE

    $text = Get-Content -Raw $tmpFile.FullName
  } finally {
    $ErrorActionPreference = $previousErrorActionPreference
    Remove-Item -LiteralPath $tmpFile.FullName -Force -ErrorAction SilentlyContinue
  }

  $duration = New-TimeSpan -Start $iterationStart -End (Get-Date)
  Write-ProgressLine ("Iteration $i/$Iterations finished in {0:mm\:ss}. Exit code: $exitCode." -f $duration)

  if ($exitCode -ne 0) {
    Write-ProgressLine "Stopping because iteration command failed."
    exit $exitCode
  }

  $finalPromise = Get-FinalPromise -Text $text

  if ($finalPromise -eq "NO_MORE_TASKS") {
    Write-ProgressLine "Issue loop complete after $i iteration(s)."
    exit 0
  }

  if ($finalPromise -eq "ABORT") {
    Write-ProgressLine "Issue loop aborted after $i iteration(s)."
    exit 1
  }
}

Write-ProgressLine "Issue loop reached requested iteration limit."
