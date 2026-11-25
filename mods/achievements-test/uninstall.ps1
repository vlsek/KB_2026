# Rollback of achievements-test: restores backups and removes added files.
param([Parameter(Mandatory=$true)][string]$GameDir)
$ErrorActionPreference = 'Stop'
$ses = Join-Path $GameDir 'sessions\base\ses'
$loc = Join-Path $GameDir 'sessions\base\loc_ses\rus'
foreach ($p in @((Join-Path $ses 'config.txt'),(Join-Path $ses 'items.txt'),(Join-Path $loc 'rus_items.lng'))) {
  $bak = "$p.kb2026.bak"
  if (Test-Path $bak) { Copy-Item $bak $p -Force; Remove-Item $bak; Write-Host "restored: $p" }
  else { Write-Warning "no backup for $p" }
}
Remove-Item (Join-Path $ses 'achievements.txt') -ErrorAction SilentlyContinue
Remove-Item (Join-Path $GameDir 'data\mods\kb2026_achievements') -Recurse -ErrorAction SilentlyContinue
Write-Host 'Rollback done.'
