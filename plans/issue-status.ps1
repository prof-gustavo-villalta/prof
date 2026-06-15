$ErrorActionPreference = "Stop"

$issueFiles = Get-ChildItem -Path "docs/issues" -Filter "*.md" | Sort-Object Name

if ($issueFiles.Count -eq 0) {
  Write-Output "No docs/issues files found"
  exit 0
}

foreach ($file in $issueFiles) {
  $content = Get-Content -Raw $file.FullName
  $titleMatch = [regex]::Match($content, '(?m)^#\s+(.+)$')
  $title = if ($titleMatch.Success) { $titleMatch.Groups[1].Value.Trim() } else { $file.BaseName }

  $openItems = [regex]::Matches($content, '(?m)^-\s+\[\s\]\s+(.+)$') |
    ForEach-Object { $_.Groups[1].Value.Trim() }
  $doneItems = [regex]::Matches($content, '(?m)^-\s+\[x\]\s+(.+)$')
  $blockedBy = [regex]::Matches($content, '(?m)^-\s+(docs/issues/.+\.md)\s*$') |
    ForEach-Object { $_.Groups[1].Value.Trim() }

  $status = if ($openItems.Count -eq 0) { "done" } else { "open" }
  $relativePath = "docs/issues/$($file.Name)"

  Write-Output "$relativePath | $status | done=$($doneItems.Count) open=$($openItems.Count) | $title"

  if ($blockedBy.Count -gt 0) {
    Write-Output "  blocked_by: $($blockedBy -join ', ')"
  }

  foreach ($item in $openItems) {
    Write-Output "  open: $item"
  }
}
