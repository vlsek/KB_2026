# KB_2026 medal-slots-test (stage 1): gives a plain test medal item to the hero at the START of a NEW game.
# Needs mods\achievements-test installed first (medal bit in config.txt, achievements.txt, icon).
# Usage:  .\install.ps1 -GameDir "C:\Program Files (x86)\Blefonix Studios\KB The Legend EE"
# Backups: *.kb2026mst.bak. Rollback: .\uninstall.ps1 -GameDir ...
param([Parameter(Mandatory=$true)][string]$GameDir)
$ErrorActionPreference = 'Stop'
$ses  = Join-Path $GameDir 'sessions\base\ses'
$lng  = Join-Path $GameDir 'sessions\base\loc_ses\rus\rus_items.lng'
$hero = Join-Path $ses 'hero.txt'
$ach  = Join-Path $ses 'achievements.txt'
$pay  = Join-Path $PSScriptRoot 'payload'
foreach ($p in @($hero,$ach,$lng)) { if (-not (Test-Path $p)) { throw "File not found: $p (check -GameDir; install achievements-test first)" } }
$enc = [Text.Encoding]::GetEncoding(28591)   # latin1: lossless bytes

function Backup($path) {
  $bak = "$path.kb2026mst.bak"
  if (-not (Test-Path $bak)) { Copy-Item $path $bak; Write-Host "backup: $bak" }
}

# 1) items: append two plain medal items to achievements.txt
Backup $ach
$as = $enc.GetString([IO.File]::ReadAllBytes($ach))
if ($as.Contains('medal_test_rank1')) { Write-Host 'achievements.txt: test items already present' }
else {
  $add = [IO.File]::ReadAllBytes((Join-Path $pay 'medal_items.txt'))
  $fs = [IO.File]::Open($ach,'Append'); $fs.Write($add,0,$add.Length); $fs.Close()
  Write-Host 'achievements.txt: test items added'
}

# 2) texts: append to rus_items.lng (UTF-16 LE)
Backup $lng
$cur = [Text.Encoding]::Unicode.GetString([IO.File]::ReadAllBytes($lng))
if ($cur.Contains('itm_medal_test_rank1_name')) { Write-Host 'rus_items.lng: strings already present' }
else {
  $txt = [Text.Encoding]::UTF8.GetString([IO.File]::ReadAllBytes((Join-Path $pay 'rus_items_append.txt')))
  $b = [Text.Encoding]::Unicode.GetBytes($txt)
  $fs = [IO.File]::Open($lng,'Append'); $fs.Write($b,0,$b.Length); $fs.Close()
  Write-Host 'rus_items.lng: strings added'
}

# 3) hero.txt: put the rank-1 medal into start/items of all three classes (3 empty "items {}" blocks expected)
Backup $hero
$hs = $enc.GetString([IO.File]::ReadAllBytes($hero))
if ($hs.Contains('medal_test_rank1')) { Write-Host 'hero.txt: start item already present' }
else {
  $pat = '(\bitems\s*\{\r\n)(\s*\})'
  $n = [regex]::Matches($hs,$pat).Count
  if ($n -ne 3) { throw "hero.txt: expected 3 empty items blocks, found $n - different file version, stopped (nothing changed)." }
  $new = [regex]::Replace($hs,$pat,('$1            medal_test_rank1=1' + "`r`n" + '$2'))
  [IO.File]::WriteAllBytes($hero, $enc.GetBytes($new))
  Write-Host 'hero.txt: start/items patched (3 classes)'
}
Write-Host "`nDone. Start a NEW game and look in the hero backpack (use the arrows under the inventory row) for 'Test: medal rank 1'."
