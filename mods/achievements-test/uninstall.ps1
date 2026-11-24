# Откат achievements-test: возвращает резервные копии и удаляет добавленные файлы.
param([Parameter(Mandatory=$true)][string]$GameDir)
$ErrorActionPreference = 'Stop'
$ses = Join-Path $GameDir 'sessions\base\ses'
$loc = Join-Path $GameDir 'sessions\base\loc_ses\rus'
foreach ($p in @((Join-Path $ses 'config.txt'),(Join-Path $loc 'rus_items.lng'))) {
  $bak = "$p.kb2026.bak"
  if (Test-Path $bak) { Copy-Item $bak $p -Force; Remove-Item $bak; Write-Host "восстановлен: $p" }
  else { Write-Warning "нет резервной копии для $p" }
}
Remove-Item (Join-Path $ses 'achievements.txt') -ErrorAction SilentlyContinue
Remove-Item (Join-Path $GameDir 'data\mods\kb2026_achievements') -Recurse -ErrorAction SilentlyContinue
Write-Host 'Откат выполнен.'
