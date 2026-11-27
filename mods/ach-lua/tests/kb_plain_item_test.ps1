# KB_2026 plain item test (agent 1): adds a PLAIN item (no propbits=medal, no params, no medc) to the END of items.txt
# and gives it to the hero at the start of a NEW game (next to medal_test_rank1). Tells us WHY the medal item does not show up.
# Usage:  powershell -ExecutionPolicy Bypass -File .\kb_plain_item_test.ps1 -GameDir "C:\Program Files (x86)\Blefonix Studios\KB The Legend EE"
# Rollback: -Undo (restores items.txt and hero.txt from *.kb2026plain.bak)
param([Parameter(Mandatory=$true)][string]$GameDir, [switch]$Undo)
$ErrorActionPreference = 'Stop'
$ses = Join-Path $GameDir 'sessions\base\ses'
$items = Join-Path $ses 'items.txt'
$hero = Join-Path $ses 'hero.txt'
$enc = [Text.Encoding]::GetEncoding(28591)
if ($Undo) {
  foreach ($f in @($items,$hero)) { $b = "$f.kb2026plain.bak"; if (Test-Path $b) { Copy-Item $b $f -Force; Write-Host "restored: $f" } }
  return
}
foreach ($f in @($items,$hero)) { if (-not (Test-Path $f)) { throw "Not found: $f" }; $b = "$f.kb2026plain.bak"; if (-not (Test-Path $b)) { Copy-Item $f $b; Write-Host "backup: $b" } }
$it = $enc.GetString([IO.File]::ReadAllBytes($items))
if (-not $it.Contains('medal_test_plain')) {
  $add = "`r`nmedal_test_plain {`r`n  category=o`r`n  image=heroitem_achievement_mental_madman.png`r`n  hint_config=object_item`r`n  label=itm_medal_test_rank1_name`r`n  hint=itm_medal_test_rank1_hint`r`n  information_label=`r`n  maphint=`r`n  mapinfo=`r`n  price=10`r`n  maxcount=0`r`n  level=1`r`n  race=human`r`n  medclass=-1`r`n  use {}`r`n}`r`n"
  $bytes = $enc.GetBytes($add)
  $fs = [IO.File]::Open($items,'Append'); $fs.Write($bytes,0,$bytes.Length); $fs.Close()
  Write-Host 'items.txt: plain item appended at the end'
} else { Write-Host 'items.txt: already has the plain item' }
$h = $enc.GetString([IO.File]::ReadAllBytes($hero))
if (-not $h.Contains('medal_test_plain')) {
  $n = [regex]::Matches($h,'medal_test_rank1=1').Count
  $h2 = $h.Replace('medal_test_rank1=1', "medal_test_rank1=1`r`n            medal_test_plain=1")
  [IO.File]::WriteAllBytes($hero, $enc.GetBytes($h2))
  Write-Host "hero.txt: plain item added to $n start blocks"
} else { Write-Host 'hero.txt: already patched' }
Write-Host 'Done. Start a NEW game, open the hero backpack (arrows under the inventory row) and check for ONE or TWO new items.'
