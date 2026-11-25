# Rollback for medal-slots-test: restores files from *.kb2026mst.bak
param([Parameter(Mandatory=$true)][string]$GameDir)
$ses = Join-Path $GameDir 'sessions\base\ses'
$files = @((Join-Path $ses 'hero.txt'), (Join-Path $ses 'achievements.txt'), (Join-Path $GameDir 'sessions\base\loc_ses\rus\rus_items.lng'))
foreach ($f in $files) {
  $bak = "$f.kb2026mst.bak"
  if (Test-Path $bak) { Copy-Item $bak $f -Force; Remove-Item $bak; Write-Host "restored: $f" } else { Write-Host "no backup: $f" }
}
Write-Host 'Done. Saves made with the test medal may complain - use a new game.'
