# KB_2026 medal-slots (agent 4): formal version of the "mslot" slot type that the owner confirmed in the game.
# Adds a slot type "mslot" (propbits bit 0x1000000) and N extra hero slots 13..(12+N) of that type, for all 3 hero classes.
# A medal item must have  propbits=mslot  (see mods\medal-slots-test items). Only such items fit these slots.
# Usage:  .\install.ps1 -GameDir "C:\Path\To\KB The Legend EE" [-Count 18]      (Count 6..18, default 18)
# Backups: config.txt / hero.txt / rus_hero.lng with .kb2026ms.bak. Undo: .\uninstall.ps1 -GameDir ...
#   -TestMedals  also adds 3 test medals (propbits=mslot, icon of the quest medal) to the start backpack of a NEW game.
# NOTE: slots 13..18 were proven in the game by the owner; slots 19..30 are NEW and untested (use -Count 6 to stay on the proven set).
param(
  [Parameter(Mandatory=$true)][string]$GameDir,
  [ValidateRange(6,18)][int]$Count = 18,
  [switch]$TestMedals
)
$ErrorActionPreference = 'Stop'
$enc  = [Text.Encoding]::GetEncoding(28591)
$ses  = Join-Path $GameDir 'sessions\base\ses'
$cfg  = Join-Path $ses 'config.txt'
$hero = Join-Path $ses 'hero.txt'
$lng  = Join-Path $GameDir 'sessions\base\loc_ses\rus\rus_hero.lng'
foreach ($p in @($cfg,$hero,$lng)) { if (-not (Test-Path $p)) { throw "Not found: $p (check -GameDir)" } }
$MB = '//==== kb2026 medal-slots begin'
$ME = '//==== kb2026 medal-slots end'

# preflight on all files BEFORE changing anything
$cs = $enc.GetString([IO.File]::ReadAllBytes($cfg))
$hs = $enc.GetString([IO.File]::ReadAllBytes($hero))
$needCfg = -not ($cs -match '(?m)^\s*mslot=')
if ($needCfg -and -not ($cs -match '(?m)^\s*artefact=0x800000\r?$')) { throw 'config.txt: line artefact=0x800000 not found - different version, nothing changed.' }
$lastSlot = 12 + $Count
$oldSixComplete = $true
for ($i = 13; $i -le 18; $i++) {
  if ([regex]::Matches($hs, "(?m)^[ \t]*$i=mslot(?:\r?)[ \t]*$").Count -ne 3) { $oldSixComplete = $false }
}
$targetComplete = $true
for ($i = 13; $i -le $lastSlot; $i++) {
  if ([regex]::Matches($hs, "(?m)^[ \t]*$i=mslot(?:\r?)[ \t]*$").Count -ne 3) { $targetComplete = $false }
}
$hasAnyExtended = [regex]::IsMatch($hs, '(?m)^[ \t]*19=mslot(?:\r?)[ \t]*$')
$correctMslotBg = [regex]::IsMatch($hs, '(?m)^[ \t]*mslot=inventory_slot_bg\d+\.png/hero_slot_mslot(?:\r?)[ \t]*$')
$needHero = -not $targetComplete -or -not $correctMslotBg
if ($needHero) {
  if (-not ($hs -match '(?m)^\s*8=artefact\r?$')) { throw 'hero.txt: line 8=artefact not found - different version, nothing changed.' }
  if (-not ($hs -match '(?m)^\s*artefact=inventory_slot_bg\d+\.png/hero_slot_artefact\r?$')) { throw 'hero.txt: slot_bgs line for artefact not found - nothing changed.' }
  if (-not $targetComplete -and $oldSixComplete -and -not $hasAnyExtended) {
    Write-Host "hero.txt: existing medal slots 13..18 found; will append slots 19..$lastSlot."
  } elseif (-not $targetComplete -and $oldSixComplete -and $hasAnyExtended) {
    throw "hero.txt: partial extended slot set found; expected all slots through $lastSlot in all 3 class blocks. Nothing changed."
  }
}
function Backup($path) { $bak = "$path.kb2026ms.bak"; if (-not (Test-Path $bak)) { Copy-Item $path $bak; Write-Host "backup: $bak" } }

# 1) config.txt
if ($needCfg) {
  Backup $cfg
  $cs = [regex]::Replace($cs, '(?m)^(\s*artefact=0x800000\r?\n)', ('$1  mslot=0x1000000' + "`r`n"), 1)
  [IO.File]::WriteAllBytes($cfg, $enc.GetBytes($cs)); Write-Host 'config.txt: mslot=0x1000000 added'
} else { Write-Host 'config.txt: mslot already present' }

# 2) hero.txt: slot type background + slots 13..(12+Count) in every class
if ($needHero) {
  Backup $hero
  if (-not $targetComplete) {
    $nl = if ($hs.Contains("`r`n")) { "`r`n" } else { "`n" }
    if ($oldSixComplete -and -not $hasAnyExtended) {
      $ins = ''
      for ($i = 19; $i -le $lastSlot; $i++) { $ins += "      $i=mslot$nl" }
      $pat = '(?m)^([ \t]*18=mslot)(?:\r?)[ \t]*$'
      if ([regex]::Matches($hs, $pat).Count -ne 3) { throw 'hero.txt: expected 3 slot-18 lines; nothing changed.' }
      $hs = [regex]::Replace($hs, $pat, ('$1' + $nl + $ins.TrimEnd("`r","`n")), 3)
    } else {
      $ins = ''
      for ($i = 13; $i -le $lastSlot; $i++) { $ins += "      $i=mslot$nl" }
      $hs = [regex]::Replace($hs, '(?m)^([ \t]*8=artefact)(?:\r?)[ \t]*$', ('$1' + $nl + $ins.TrimEnd("`r","`n")), 3)
    }
  }
  if (-not $correctMslotBg) {
    $map = '(?m)^([ \t]*mslot=inventory_slot_bg\d+\.png/)[^\r\n]*$'
    if ([regex]::IsMatch($hs,$map)) {
      $hs = [regex]::Replace($hs,$map,'$1hero_slot_mslot',1)
    } else {
      $artefactMap = '(?m)^([ \t]*artefact=inventory_slot_bg\d+\.png/hero_slot_artefact)(?:\r?)[ \t]*$'
      if ([regex]::Matches($hs,$artefactMap).Count -ne 1) { throw 'hero.txt: cannot locate slot_bgs insertion point.' }
      $hs = [regex]::Replace($hs,$artefactMap,('$1' + $nl + '  mslot=inventory_slot_bg8.png/hero_slot_mslot'),1)
    }
  }
  [IO.File]::WriteAllBytes($hero, $enc.GetBytes($hs))
  Write-Host "hero.txt: ensured slots 13..$lastSlot = mslot (3 classes) + medal tooltip mapping"
} else { Write-Host "hero.txt: slots 13..$lastSlot and medal tooltip mapping already present" }

# 3) hint text of the slot type
$lt = [Text.Encoding]::Unicode.GetString([IO.File]::ReadAllBytes($lng))
if (-not ($lt -match '(?m)^hero_slot_mslot=')) {
  Backup $lng
  $txt = "hero_slot_mslot=" + [string]::Join('', [char[]](0x41C,0x435,0x434,0x430,0x43B,0x44C))
  $add = [Text.Encoding]::Unicode.GetBytes("`r`n$MB`r`n$txt`r`n$ME`r`n")
  $fs = [IO.File]::Open($lng,'Append'); $fs.Write($add,0,$add.Length); $fs.Close()
  Write-Host 'rus_hero.lng: hero_slot_mslot=Медаль added'
} else { Write-Host 'rus_hero.lng: medal slot tooltip already present' }

# 4) optional: 3 test medals with propbits=mslot (so the slots can be tried right away)
if ($TestMedals) {
  $itemsTxt = Join-Path $ses 'items.txt'
  $incFile  = Join-Path $ses 'items_kb26_medals.txt'
  $blocks = ''
  foreach ($n in 1..3) {
    $blocks += "kb26_test_medal_$n {`r`n  category=o`r`n  image=heroitem_quest_medal.png`r`n  hint_config=object_item`r`n  label=itm_kb26_test_medal_${n}_name`r`n  hint=itm_kb26_test_medal_${n}_hint`r`n  information_label=`r`n  maphint=`r`n  mapinfo=`r`n  price=10`r`n  maxcount=0`r`n  level=1`r`n  race=neutral`r`n  use {}`r`n  propbits=mslot`r`n  mods {}`r`n  params {}`r`n}`r`n`r`n"
  }
  [IO.File]::WriteAllBytes($incFile, $enc.GetBytes($blocks))
  $it = $enc.GetString([IO.File]::ReadAllBytes($itemsTxt))
  if (-not $it.Contains('==items_kb26_medals.txt')) {
    Backup $itemsTxt
    [IO.File]::WriteAllBytes($itemsTxt, [byte[]]($enc.GetBytes("==items_kb26_medals.txt`r`n") + [IO.File]::ReadAllBytes($itemsTxt)))
    Write-Host 'items.txt: include added'
  }
  $lt2 = [Text.Encoding]::Unicode.GetString([IO.File]::ReadAllBytes((Join-Path $GameDir 'sessions\base\loc_ses\rus\rus_items.lng')))
  $lngItems = Join-Path $GameDir 'sessions\base\loc_ses\rus\rus_items.lng'
  if (-not (Test-Path $lngItems)) { throw 'rus_items.lng not found' }
  $MB2 = '//==== kb2026 medal-slots items begin'
  $ME2 = '//==== kb2026 medal-slots items end'
  if (-not $lt2.Contains($MB2)) {
    Backup $lngItems
    $tx = ''
    foreach ($n in 1..3) { $tx += "itm_kb26_test_medal_${n}_name=Test medal $n`r`nitm_kb26_test_medal_${n}_hint=^?^Test medal for the mslot slots`r`n" }
    $ad = [Text.Encoding]::Unicode.GetBytes("`r`n$MB2`r`n$tx$ME2`r`n")
    $fs = [IO.File]::Open($lngItems,'Append'); $fs.Write($ad,0,$ad.Length); $fs.Close()
    Write-Host 'rus_items.lng: test medal texts added'
  }
  $hs2 = $enc.GetString([IO.File]::ReadAllBytes($hero))
  if (-not $hs2.Contains('kb26_test_medal_1=1')) {
    $new = [regex]::Replace($hs2, '(\bitems\s*\{\r\n)', ('$1' + "            kb26_test_medal_1=1`r`n            kb26_test_medal_2=1`r`n            kb26_test_medal_3=1`r`n"))
    [IO.File]::WriteAllBytes($hero, $enc.GetBytes($new))
    Write-Host 'hero.txt: 3 test medals in the start backpack (all classes)'
  }
}
Write-Host "`nDone. Start a NEW game. Medal items need propbits=mslot (not quest)."
