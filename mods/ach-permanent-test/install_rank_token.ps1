param([Parameter(Mandatory=$true)][string]$GameDir)
$ErrorActionPreference = 'Stop'
$game = [IO.Path]::GetFullPath($GameDir).TrimEnd('\')
if ((Split-Path -Leaf (Split-Path -Parent $game)) -ne 'KB_test_copy' -or (Split-Path -Leaf $game) -ne 'KB The Legend EE') {
  throw 'Safety stop: this installer only accepts ...\KB_test_copy\KB The Legend EE.'
}
$ses = Join-Path $game 'sessions\base\ses'
$lua = Join-Path $ses 'logic_hero.lua'
$items = Join-Path $ses 'items.txt'
$lng = Join-Path $game 'sessions\base\loc_ses\rus\rus_items.lng'
foreach ($f in @($lua,$items,$lng)) { if (-not (Test-Path -LiteralPath $f)) { throw "Required file not found: $f" } }
$latin = [Text.Encoding]::GetEncoding(28591)
$s = $latin.GetString([IO.File]::ReadAllBytes($lua))
$begin = $s.IndexOf('-- KB_2026 permanent medal prototype.')
$finish = if ($begin -ge 0) { $s.IndexOf('-- KB_2026 lua-api-dump', $begin) } else { -1 }
if ($begin -lt 0 -or $finish -lt 0 -or -not $s.Contains('kb2026_check_ach("takebox")')) { throw 'Expected installed prototype and chest hook not found. Nothing changed.' }
$itemBytes = [IO.File]::ReadAllBytes($items)
$itemText = $latin.GetString($itemBytes)
$lngBytes = [IO.File]::ReadAllBytes($lng)
if ($lngBytes.Length -lt 2 -or $lngBytes[0] -ne 0xFF -or $lngBytes[1] -ne 0xFE) { throw 'Expected UTF-16 LE localization file. Nothing changed.' }
$lngText = [Text.Encoding]::Unicode.GetString($lngBytes)
$newItem = 'kb26_medal_chest_rank1'
if ($itemText.Contains($newItem) -or $lngText.Contains('itm_kb26_medal_chest_rank1_name')) { throw 'Rank-token data already exists. Nothing changed.' }
$suffixes = @('.kb2026token.bak')
foreach ($f in @($lua,$items,$lng)) { if (Test-Path -LiteralPath ($f + $suffixes[0])) { throw "Backup already exists: $f$suffixes. Nothing changed." } }
foreach ($f in @($lua,$items,$lng)) { Copy-Item -LiteralPath $f -Destination ($f + $suffixes[0]) }
$itemDef = @'

kb26_medal_chest_rank1 {
  category=o
  image=heroitem_quest_medal.png
  hint_config=object_item
  label=itm_kb26_medal_chest_rank1_name
  hint=itm_kb26_medal_chest_rank1_hint
  information_label=itm_kb26_medal_chest_rank1_info
  maphint=
  mapinfo=
  price=0
  maxcount=0
  level=1
  race=neutral
  use {}
  propbits=quest
  params {}
}
'@
[IO.File]::WriteAllBytes($items, [byte[]]($itemBytes + $latin.GetBytes($itemDef)))
$labels = @'

// KB2026 permanent medal rank-token prototype
itm_kb26_medal_chest_rank1_name=Достижение: испытание сундука I
itm_kb26_medal_chest_rank1_taken=^?^
itm_kb26_medal_chest_rank1_minfo=^?^
itm_kb26_medal_chest_rank1_mhint=^?^
itm_kb26_medal_chest_rank1_info=^?^Постоянный знак первого этапа испытания сундука.
itm_kb26_medal_chest_rank1_hint=^?^Ранг I. Получен за открытие сундука. Не надевается.
'@
$labelBytes = [Text.Encoding]::Unicode.GetBytes($labels)
[IO.File]::WriteAllBytes($lng, [byte[]]($lngBytes + $labelBytes))
$newBlock = @'
-- KB_2026 permanent medal prototype. Lua 5.0 compatible; ASCII-only source.
-- First chest opened: persist rank 1, add a backpack badge, and apply +1 Intellect once.
function kb2026_check_ach(tag)
  local ok, err = pcall(function()
    local rank = tonumber(Game.GVNum("kb26_perm_chest_medal_rank")) or 0
    if rank >= 1 then return end

    local badge_ok, badge_err = pcall(function() Logic.hero_add_item("kb26_medal_chest_rank1") end)
    local intellect = tonumber(Logic.hero_lu_item("intellect", "count")) or 0
    Logic.hero_lu_item("intellect", "count", intellect + 1)
    Game.GVNumInc("kb26_perm_chest_medal_rank", 1)
    Game.MessageBox("KB2026 TEST: Chest medal rank I unlocked. Permanent Intellect +1. Backpack badge call=" .. tostring(badge_ok))
  end)
  if not ok then
    pcall(function() Game.MessageBox("KB2026 TEST ERROR: " .. tostring(err)) end)
  end
end
'@
$s = $s.Substring(0,$begin) + $newBlock + "`r`n" + $s.Substring($finish)
[IO.File]::WriteAllBytes($lua, $latin.GetBytes($s))
Write-Host 'Installed rank-token variant. Backups (.kb2026token.bak) were created for logic_hero.lua, items.txt, and rus_items.lng.'
Write-Host 'Start a NEW game, open the first chest, and check the Quest/backpack inventory for the rank token.'

