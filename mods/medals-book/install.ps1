# KB_2026 medals-book (agent 5): the 18-medal panel in the style of the game (frame, vines, plaque, a card under each slot
# with the name, condition and ranks). Replaces mods\medals-grid / mods\medals-panel (same hero_3360x945.ui name).
# Usage:  .\install.ps1 -GameDir "C:\Path\To\KB The Legend EE"        (install into a TEST COPY first)
# Needs: data\mods\32_9-nsf with forms.txt (herwin block) and mods\medal-slots (slots 13..30 in hero.txt).
# Backups: forms.txt.kb2026mb.bak, rus_hero.lng.kb2026mb.bak. Undo: .\uninstall.ps1 -GameDir ...
param([Parameter(Mandatory=$true)][string]$GameDir)
$ErrorActionPreference = 'Stop'
$mod   = Join-Path $GameDir 'data\mods\32_9-nsf'
$forms = Join-Path $mod 'forms.txt'
$lng   = Join-Path $GameDir 'sessions\base\loc_ses\rus\rus_hero.lng'
foreach ($p in @($forms,$lng)) { if (-not (Test-Path $p)) { throw "Not found: $p (check -GameDir; the 32:9 mod must be installed)" } }
foreach ($f in @('hero_3360x945.ui','medals_book_bg.png','rus_hero_append.txt')) {
  if (-not (Test-Path (Join-Path $PSScriptRoot $f))) { throw "Missing in the mod folder: $f" }
}
$MB = '//==== kb2026 medals-book begin'
$ME = '//==== kb2026 medals-book end'
$enc = [Text.Encoding]::GetEncoding(28591)

# 1) forms.txt: one line in the herwin block (skipped when an earlier panel mod already added it)
$text = $enc.GetString([IO.File]::ReadAllBytes($forms))
$line = '3360x945=hero_3360x945.ui'
if ($text.Contains($line)) { Write-Host 'forms.txt: line already present' }
else {
  $pat = '(herwin\s*\{[^}]*?\bui=hero\.ui\r?\n)'
  if (-not [regex]::IsMatch($text, $pat)) { throw "forms.txt: 'herwin' block with ui=hero.ui not found - stopped, nothing changed." }
  $bak = "$forms.kb2026mb.bak"
  if (-not (Test-Path $bak)) { Copy-Item $forms $bak }
  $nl = if ($text.Contains("`r`n")) { "`r`n" } else { "`n" }
  $new = [regex]::Replace($text, $pat, ('$1    ' + $line + $nl), 1)
  [IO.File]::WriteAllBytes($forms, $enc.GetBytes($new))
  Write-Host "forms.txt: added $line"
}

# 2) hover texts -> rus_hero.lng (UTF-16): remove an older medals-grid / medals-book block, then write ours
$lt = [Text.Encoding]::Unicode.GetString([IO.File]::ReadAllBytes($lng))
$bak = "$lng.kb2026mb.bak"
if (-not (Test-Path $bak)) { Copy-Item $lng $bak }
foreach ($m in @('medals-grid', 'medals-book')) {
  $b = "//==== kb2026 $m begin"; $e = "//==== kb2026 $m end"
  $i = $lt.IndexOf($b)
  if ($i -ge 0) { $j = $lt.IndexOf($e, $i); if ($j -ge 0) { $lt = $lt.Remove($i, ($j + $e.Length) - $i).TrimEnd("`r","`n") + "`r`n"; Write-Host "rus_hero.lng: old $m block removed" } }
}
$txt = [Text.Encoding]::UTF8.GetString([IO.File]::ReadAllBytes((Join-Path $PSScriptRoot 'rus_hero_append.txt')))
$lt = $lt + "`r`n$MB`r`n" + $txt + "$ME`r`n"
[IO.File]::WriteAllBytes($lng, [Text.Encoding]::Unicode.GetBytes($lt))
Write-Host 'rus_hero.lng: hover texts written'

# 3) files
Copy-Item (Join-Path $PSScriptRoot 'hero_3360x945.ui') $mod -Force
Copy-Item (Join-Path $PSScriptRoot 'medals_book_bg.png') $mod -Force
Remove-Item (Join-Path $mod 'medals_grid_bg.png') -ErrorAction SilentlyContinue
Write-Host 'Done. Start the game at 3360x945, open the hero window: the panel with 18 cards is to the right of it.'
