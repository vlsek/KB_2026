param([Parameter(Mandatory=$true)][string]$GameDir)
$ErrorActionPreference = 'Stop'
$enc  = [Text.Encoding]::GetEncoding(28591)
$ses  = Join-Path $GameDir 'sessions\base\ses'
$cfg  = Join-Path $ses 'config.txt'
$hero = Join-Path $ses 'hero.txt'
$lng  = Join-Path $GameDir 'sessions\base\loc_ses\rus\rus_hero.lng'
$MB = '//==== kb2026 medal-slots begin'
$ME = '//==== kb2026 medal-slots end'
$cs = $enc.GetString([IO.File]::ReadAllBytes($cfg))
$cs = [regex]::Replace($cs, '(?m)^[ \t]*mslot=0x1000000\r?\n', '')
[IO.File]::WriteAllBytes($cfg, $enc.GetBytes($cs))
$hs = $enc.GetString([IO.File]::ReadAllBytes($hero))
$hs = [regex]::Replace($hs, '(?m)^[ \t]*\d+=mslot\r?\n', '')
$hs = [regex]::Replace($hs, '(?m)^[ \t]*mslot=inventory_slot_bg\d+\.png/hero_slot_mslot\r?\n', '')
[IO.File]::WriteAllBytes($hero, $enc.GetBytes($hs))
$lt = [Text.Encoding]::Unicode.GetString([IO.File]::ReadAllBytes($lng))
$i = $lt.IndexOf($MB)
if ($i -ge 0) {
  $j = $lt.IndexOf($ME, $i)
  if ($j -ge 0) { $lt = $lt.Remove($i, ($j + $ME.Length) - $i).TrimEnd("`r","`n") + "`r`n" }
  [IO.File]::WriteAllBytes($lng, [Text.Encoding]::Unicode.GetBytes($lt))
}
# test medals (if installed with -TestMedals)
$itemsTxt = Join-Path $ses 'items.txt'
$it = $enc.GetString([IO.File]::ReadAllBytes($itemsTxt)); $it = $it.Replace("==items_kb26_medals.txt`r`n", '')
[IO.File]::WriteAllBytes($itemsTxt, $enc.GetBytes($it))
Remove-Item (Join-Path $ses 'items_kb26_medals.txt') -ErrorAction SilentlyContinue
$hs = $enc.GetString([IO.File]::ReadAllBytes($hero))
$hs = [regex]::Replace($hs, '(?m)^[ \t]*kb26_test_medal_\d=1\r\n', '')
[IO.File]::WriteAllBytes($hero, $enc.GetBytes($hs))
$lngItems = Join-Path $GameDir 'sessions\base\loc_ses\rus\rus_items.lng'
if (Test-Path $lngItems) {
  $li = [Text.Encoding]::Unicode.GetString([IO.File]::ReadAllBytes($lngItems))
  $a = $li.IndexOf('//==== kb2026 medal-slots items begin')
  if ($a -ge 0) {
    $b = $li.IndexOf('//==== kb2026 medal-slots items end', $a)
    if ($b -ge 0) { $li = $li.Remove($a, ($b + '//==== kb2026 medal-slots items end'.Length) - $a).TrimEnd("`r","`n") + "`r`n" }
    [IO.File]::WriteAllBytes($lngItems, [Text.Encoding]::Unicode.GetBytes($li))
  }
}
Write-Host 'medal-slots removed (backups *.kb2026ms.bak are left in place).'
