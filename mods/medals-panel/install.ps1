# KB_2026 medals-panel: hero window for 3360x945 with a medals panel to the right of it.
# Needs the 32:9 mod folder data\mods\32_9-nsf (it must already contain forms.txt with the 'herwin' block).
# Usage:  .\install.ps1 -GameDir "C:\Path\To\KB The Legend EE"
# Backup: forms.txt.kb2026mp.bak. Rollback: .\uninstall.ps1 -GameDir ...
# Medal slots 13..18 only accept medals after mods\medal-slots-test (hero.txt rules). Without it the panel shows empty slots.
param([Parameter(Mandatory=$true)][string]$GameDir)
$ErrorActionPreference = 'Stop'
$mod   = Join-Path $GameDir 'data\mods\32_9-nsf'
$forms = Join-Path $mod 'forms.txt'
if (-not (Test-Path $forms)) { throw "Not found: $forms (check -GameDir, the 32:9 mod must be installed)" }
foreach ($f in @('hero_3360x945.ui','medals_panel_bg.png')) {
  if (-not (Test-Path (Join-Path $PSScriptRoot $f))) { throw "Missing in the mod folder: $f" }
}
$enc  = [Text.Encoding]::GetEncoding(28591)   # latin1: lossless bytes
$text = $enc.GetString([IO.File]::ReadAllBytes($forms))
$line = '3360x945=hero_3360x945.ui'
if ($text.Contains($line)) {
  Write-Host "forms.txt already contains the hero 3360x945 line, only copying files."
} else {
  $pat = '(herwin\s*\{[^}]*?\bui=hero\.ui\r?\n)'
  if (-not [regex]::IsMatch($text, $pat)) { throw "forms.txt: the 'herwin' block with ui=hero.ui was not found - stopped, nothing changed." }
  $bak = "$forms.kb2026mp.bak"
  if (-not (Test-Path $bak)) { Copy-Item $forms $bak }
  $nl  = if ($text.Contains("`r`n")) { "`r`n" } else { "`n" }
  $new = [regex]::Replace($text, $pat, ('$1    ' + $line + $nl), 1)
  [IO.File]::WriteAllBytes($forms, $enc.GetBytes($new))
  Write-Host "forms.txt: added $line to the herwin block."
}
Copy-Item (Join-Path $PSScriptRoot 'hero_3360x945.ui') $mod -Force
Copy-Item (Join-Path $PSScriptRoot 'medals_panel_bg.png') $mod -Force
Write-Host "Done. Start the game at 3360x945 and open the hero window."
