# KB_2026 medals-panel: rollback. Usage: .\uninstall.ps1 -GameDir "C:\Path\To\KB The Legend EE"
param([Parameter(Mandatory=$true)][string]$GameDir)
$ErrorActionPreference = 'Stop'
$mod   = Join-Path $GameDir 'data\mods\32_9-nsf'
$forms = Join-Path $mod 'forms.txt'
$bak   = "$forms.kb2026mp.bak"
if (Test-Path $bak) { Copy-Item $bak $forms -Force; Remove-Item $bak; Write-Host "forms.txt restored from backup." }
else { Write-Host "No forms.txt backup found (nothing was changed by install, or it was already rolled back)." }
foreach ($f in @('hero_3360x945.ui','medals_panel_bg.png')) {
  $p = Join-Path $mod $f
  if (Test-Path $p) { Remove-Item $p; Write-Host "removed $f" }
}
Write-Host "Rollback done."
