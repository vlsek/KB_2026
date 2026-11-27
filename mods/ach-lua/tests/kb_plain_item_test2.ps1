# KB_2026 item test #2 (agent 1): adds item medal_test_ok written in the REAL Legend item format
# (race=neutral, propbits=rare, mods {}, params {}) - copied from how the familiar mod defines its item - and gives it to the hero
# at the start of a NEW game (hero.txt start/items), next to the earlier test items.
# Usage:  powershell -ExecutionPolicy Bypass -File .\kb_plain_item_test2.ps1 -GameDir "C:\Program Files (x86)\Blefonix Studios\KB The Legend EE"
# Rollback: run kb_plain_item_test.ps1 with -Undo (restores items.txt and hero.txt from the *.kb2026plain.bak backups)
param([Parameter(Mandatory=$true)][string]$GameDir)
$ErrorActionPreference = 'Stop'
$ses = Join-Path $GameDir 'sessions\base\ses'
$items = Join-Path $ses 'items.txt'
$hero = Join-Path $ses 'hero.txt'
$enc = [Text.Encoding]::GetEncoding(28591)
foreach ($f in @($items,$hero)) { if (-not (Test-Path $f)) { throw "Not found: $f" }; $b = "$f.kb2026plain.bak"; if (-not (Test-Path $b)) { Copy-Item $f $b; Write-Host "backup: $b" } }
$it = $enc.GetString([IO.File]::ReadAllBytes($items))
if (-not $it.Contains('medal_test_ok')) {
  $add = "`r`nmedal_test_ok {`r`n  category=o`r`n  image=heroitem_achievement_mental_madman.png`r`n  hint_config=object_item`r`n  label=itm_medal_test_rank1_name`r`n  hint=itm_medal_test_rank1_hint`r`n  information_label=`r`n  maphint=`r`n  mapinfo=`r`n  price=10`r`n  maxcount=0`r`n  level=1`r`n  race=neutral`r`n  use {}`r`n  propbits=rare`r`n  mods {}`r`n  params {}`r`n}`r`n"
  $bytes = $enc.GetBytes($add)
  $fs = [IO.File]::Open($items,'Append'); $fs.Write($bytes,0,$bytes.Length); $fs.Close()
  Write-Host 'items.txt: medal_test_ok appended'
} else { Write-Host 'items.txt: already has medal_test_ok' }
$h = $enc.GetString([IO.File]::ReadAllBytes($hero))
if (-not $h.Contains('medal_test_ok')) {
  $key = 'medal_test_rank1=1'
  if (-not $h.Contains($key)) { throw 'hero.txt does not contain the earlier test item - run the previous scripts first' }
  $h2 = $h.Replace($key, "$key`r`n            medal_test_ok=1")
  [IO.File]::WriteAllBytes($hero, $enc.GetBytes($h2))
  Write-Host 'hero.txt: medal_test_ok added to the start blocks'
} else { Write-Host 'hero.txt: already patched' }
Write-Host 'Done. Start a NEW game and look in the hero backpack: report how many of the 3 test items you see.'
