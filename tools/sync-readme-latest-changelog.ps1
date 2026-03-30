param(
  [switch]$CheckOnly
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$changelogPath = Join-Path $repoRoot "CHANGELOG.md"
$readmePath = Join-Path $repoRoot "README.md"

if (-not (Test-Path $changelogPath)) {
  throw "CHANGELOG.md not found at $changelogPath"
}

if (-not (Test-Path $readmePath)) {
  throw "README.md not found at $readmePath"
}

$changelog = Get-Content -Path $changelogPath -Raw -Encoding UTF8
$readme = Get-Content -Path $readmePath -Raw -Encoding UTF8
$nl = if ($readme.Contains("`r`n")) { "`r`n" } else { "`n" }

$latestEntryPattern = '(?ms)^##\s+\[[^\]]+\]\s+-\s+[^\r\n]+\r?\n.*?(?=^##\s+\[[^\]]+\]\s+-|\z)'
$latestMatch = [regex]::Match($changelog, $latestEntryPattern)

if (-not $latestMatch.Success) {
  throw "Could not find a changelog version entry (expected: ## [x.y.z] - YYYY-MM-DD)."
}

$latestEntry = $latestMatch.Value.TrimEnd()
$entryLines = $latestEntry -split "`r?`n"

for ($i = 0; $i -lt $entryLines.Length; $i += 1) {
  if ($entryLines[$i] -like "### *") {
    $entryLines[$i] = $entryLines[$i] -replace '^###\s+', '#### '
    continue
  }

  if ($entryLines[$i] -like "## *") {
    $entryLines[$i] = $entryLines[$i] -replace '^##\s+', '### '
  }
}

$entryForReadme = ($entryLines -join $nl)
$startMarker = "<!-- LATEST_CHANGELOG:START -->"
$endMarker = "<!-- LATEST_CHANGELOG:END -->"

$managedBlock = @(
  $startMarker
  $entryForReadme
  ""
  "[View full changelog](CHANGELOG.md)"
  $endMarker
) -join $nl

$updatedReadme = $readme
$markerPattern = [regex]::Escape($startMarker) + '.*?' + [regex]::Escape($endMarker)
$markerRegex = [regex]::new($markerPattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)

if ($markerRegex.IsMatch($readme)) {
  $updatedReadme = $markerRegex.Replace(
    $readme,
    [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $managedBlock },
    1
  )
} else {
  $section = @(
    "## Latest Changelog",
    "",
    $managedBlock,
    ""
  ) -join $nl

  $updatedReadme = [regex]::Replace(
    $readme,
    '(?m)^## Project Structure',
    [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $section + $m.Value },
    1
  )

  if ($updatedReadme -eq $readme) {
    $updatedReadme = $readme.TrimEnd() + $nl + $nl + $section
  }
}

if ($updatedReadme -eq $readme) {
  Write-Output "README latest changelog section is already up to date."
  exit 0
}

if ($CheckOnly) {
  Write-Output "README latest changelog section is out of date. Run this script without -CheckOnly to sync it."
  exit 1
}

Set-Content -Path $readmePath -Value $updatedReadme -Encoding UTF8
Write-Output "Synced README latest changelog section from CHANGELOG.md."
