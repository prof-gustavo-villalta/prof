param(
  [Parameter(Position = 0)]
  [int]$Iterations = 1
)

$ErrorActionPreference = "Stop"

if ($Iterations -lt 1) {
  Write-Error "Usage: npm run ralph:afk -- <iterations>"
}

for ($i = 1; $i -le $Iterations; $i++) {
  Write-Host "------- ITERATION $i --------"

  $tmpFile = New-TemporaryFile

  try {
    & powershell -NoProfile -ExecutionPolicy Bypass -File "$PSScriptRoot\once-codex.ps1" 2>&1 |
      Tee-Object -FilePath $tmpFile.FullName

    $text = Get-Content -Raw $tmpFile.FullName
  } finally {
    Remove-Item -LiteralPath $tmpFile.FullName -Force -ErrorAction SilentlyContinue
  }

  if ($text.Contains("<promise>NO MORE TASKS</promise>")) {
    Write-Host "Issue loop complete after $i iterations."
    exit 0
  }

  if ($text.Contains("<promise>ABORT</promise>")) {
    Write-Host "Issue loop aborted after $i iterations."
    exit 1
  }
}
