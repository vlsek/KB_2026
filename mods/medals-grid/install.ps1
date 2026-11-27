# KB_2026 medals-grid (agent 4): compact hero window for 3360x945 with an 18-slot medals grid to the right of it.
# Replaces mods\medals-panel (same hero_3360x945.ui name; that one has 6 big slots with text beside them).
# Hover text for each slot goes into rus_hero.lng (keys kb26_med_1..18).
# Usage:  .\install.ps1 -GameDir "C:\Path\To\KB The Legend EE"
# Needs: data\mods\32_9-nsf with forms.txt (herwin block). Slots accept medals only after mods\medal-slots (hero.txt rules).
# Backups: forms.txt.kb2026mg.bak, rus_hero.lng.kb2026mg.bak. Undo: .\uninstall.ps1 -GameDir ...
param([Parameter(Mandatory=$true)][string]$GameDir)
$ErrorActionPreference = 'Stop'
$mod   = Join-Path $GameDir 'data\mods\32_9-nsf'
$forms = Join-Path $mod 'forms.txt'
$lng   = Join-Path $GameDir 'sessions\base\loc_ses\rus\rus_hero.lng'
foreach ($p in @($forms,$lng)) { if (-not (Test-Path $p)) { throw "Not found: $p (check -GameDir; the 32:9 mod must be installed)" } }
foreach ($f in @('hero_3360x945.ui','medals_grid_bg.png','rus_hero_append.txt')) {
  if (-not (Test-Path (Join-Path $PSScriptRoot $f))) { throw "Missing in the mod folder: $f" }
}
$MB = '//==== kb2026 medals-grid begin'
$ME = '//==== kb2026 medals-grid end'
$enc = [Text.Encoding]::GetEncoding(28591)

# 1) forms.txt: one line in the herwin block
$text = $enc.GetString([IO.File]::ReadAllBytes($forms))
$line = '3360x945=hero_3360x945.ui'
if ($text.Contains($line)) { Write-Host 'forms.txt: line already present' }
else {
  $pat = '(herwin\s*\{[^}]*?\bui=hero\.ui\r?\n)'
  if (-not [regex]::IsMatch($text, $pat)) { throw "forms.txt: 'herwin' block with ui=hero.ui not found - stopped, nothing changed." }
  $bak = "$forms.kb2026mg.bak"
  if (-not (Test-Path $bak)) { Copy-Item $forms $bak }
  $nl = if ($text.Contains("`r`n")) { "`r`n" } else { "`n" }
  $new = [regex]::Replace($text, $pat, ('$1    ' + $line + $nl), 1)
  [IO.File]::WriteAllBytes($forms, $enc.GetBytes($new))
  Write-Host "forms.txt: added $line"
}

# 2) hover texts -> rus_hero.lng (UTF-16, between markers)
$lt = [Text.Encoding]::Unicode.GetString([IO.File]::ReadAllBytes($lng))
if ($lt.Contains($MB)) { Write-Host 'rus_hero.lng: block already present (delete it with uninstall first to refresh texts)' }
else {
  $bak = "$lng.kb2026mg.bak"
  if (-not (Test-Path $bak)) { Copy-Item $lng $bak }
  $txt = [Text.Encoding]::UTF8.GetString([IO.File]::ReadAllBytes((Join-Path $PSScriptRoot 'rus_hero_append.txt')))
  $add = [Text.Encoding]::Unicode.GetBytes("`r`n$MB`r`n" + $txt + "$ME`r`n")
  $fs = [IO.File]::Open($lng,'Append'); $fs.Write($add,0,$add.Length); $fs.Close()
  Write-Host 'rus_hero.lng: hover texts added'
}

# 3) files
Copy-Item (Join-Path $PSScriptRoot 'hero_3360x945.ui') $mod -Force
Copy-Item (Join-Path $PSScriptRoot 'medals_grid_bg.png') $mod -Force
Write-Host 'Done. Start the game at 3360x945, open the hero window, hover over the slots.'
