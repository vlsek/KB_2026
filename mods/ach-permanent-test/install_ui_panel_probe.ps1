param([Parameter(Mandatory=$true)][string]$GameDir)
$ErrorActionPreference = 'Stop'
$game = [IO.Path]::GetFullPath($GameDir).TrimEnd('\')
if ((Split-Path -Leaf (Split-Path -Parent $game)) -ne 'KB_test_copy' -or (Split-Path -Leaf $game) -ne 'KB The Legend EE') { throw 'Safety stop: only KB_test_copy is accepted.' }
$ses = Join-Path $game 'sessions\base\ses'
$mod = Join-Path $game 'data\mods\32_9-nsf'
$loc = Join-Path $game 'sessions\base\loc_ses\rus'
$lua = Join-Path $ses 'logic_hero.lua'
$textgen = Join-Path $ses 'textgen.lua'
$forms = Join-Path $mod 'forms.txt'
$lng = Join-Path $loc 'rus_windows_small.lng'
foreach ($f in @($lua,$textgen,$forms,$lng)) { if (-not (Test-Path -LiteralPath $f)) { throw "Required file not found: $f" } }
$latin = [Text.Encoding]::GetEncoding(28591)
$s = $latin.GetString([IO.File]::ReadAllBytes($lua))
$tg = $latin.GetString([IO.File]::ReadAllBytes($textgen))
$fs = $latin.GetString([IO.File]::ReadAllBytes($forms))
$lb = [IO.File]::ReadAllBytes($lng)
if ($lb.Length -lt 2 -or $lb[0] -ne 0xFF -or $lb[1] -ne 0xFE) { throw 'Expected UTF-16 LE rus_windows_small.lng. Nothing changed.' }
$ls = [Text.Encoding]::Unicode.GetString($lb)
if ($fs.Contains('kb26_medal_screen') -or $s.Contains('Scenario.formsolo("kb26_medal_screen")')) { throw 'UI probe already installed. Nothing changed.' }
$cbStart = $s.IndexOf('-- KB_2026 permanent medal prototype.')
$cbEnd = if ($cbStart -ge 0) { $s.IndexOf('-- KB_2026 lua-api-dump', $cbStart) } else { -1 }
if ($cbStart -lt 0 -or $cbEnd -lt 0) { throw 'Permanent medal callback markers not found. Nothing changed.' }
$h = 'function scn_hero_takebox ( param )'
if (-not $s.Contains($h) -or -not $s.Contains('kb2026_check_ach("takebox")')) { throw 'Expected chest hook not found. Nothing changed.' }
if ($tg.Contains('gen_kb26_medal_panel')) { throw 'Generator already installed. Nothing changed.' }
$entry = "`r`n`r`nkb26_medal_screen {`r`n  description=KB2026 medal screen probe`r`n  ui=kb26_medal_screen.ui`r`n  form=dialog`r`n}`r`n"
$uiPath = Join-Path $mod 'kb26_medal_screen.ui'
if (Test-Path -LiteralPath $uiPath) { throw "UI file already exists: $uiPath" }
$ui = @'
gui_begin 0 0
gui_object_begin picture
gui_object_picture "buy_panel2.png"
gui_object_picture_angle 0.000000 1
gui_object_position 0 0 527 274
gui_object_name "kb26_panel_bg"
gui_object_end
gui_object_begin simple_text
gui_object_position 38 36 489 196
gui_object_name "kb26_panel_text"
gui_object_text "" "kb26_medal_panel_text" 0.010000 0.990000 0.010000 0.990000
gui_object_end
gui_object_begin button
gui_object_position 363 209 468 247
gui_object_name "b_cancel"
gui_object_button_normal "buy_button_cancel2_normal.png" "" "" 0.000000 1 0.010000 0.990000 0.010000 0.990000
gui_object_button_focused "buy_button_cancel2_onmouse.png" "" "" 0.000000 1 0.010000 0.990000 0.010000 0.990000
gui_object_button_pressed "buy_button_cancel2_onpress.png" "" "" 0.000000 1 0.010000 0.990000 0.010000 0.990000
gui_object_button_disabled "buy_button_cancel2_disable.png" "" "" 0.000000 1 0.010000 0.990000 0.010000 0.990000
gui_object_end
gui_end
'@
$gen = @'

-- KB2026 UI probe: status text for the custom dialog.
function gen_kb26_medal_panel()
  local rank = tonumber(Game.GVNum("kb26_perm_chest_medal_rank")) or 0
  local intellect = tonumber(Logic.hero_lu_item("intellect", "count")) or 0
  local text = "<label=kb26_medal_panel_title><br><br>"
  if rank >= 1 then
    text = text .. "<label=kb26_medal_panel_rank> I"
  else
    text = text .. "<label=kb26_medal_panel_locked>"
  end
  text = text .. "<br><br><label=kb26_medal_panel_intellect> " .. tostring(intellect)
  return text
end
'@
$labels = @'

// KB2026 custom medal screen probe
kb26_medal_panel_text=<gen=gen_kb26_medal_panel>
kb26_medal_panel_title=<color=235,223,179><font=ft1_16>ДОСТИЖЕНИЯ</font></color>
kb26_medal_panel_rank=<color=252,249,220>Испытание сундука — ранг
kb26_medal_panel_locked=<color=180,180,180>Испытание сундука — пока не получено
kb26_medal_panel_intellect=<color=252,249,220>Интеллект сейчас:
'@
$backs = @($lua,$textgen,$forms,$lng)
foreach ($f in $backs) { $bak="$f.kb2026panel.bak"; if (Test-Path -LiteralPath $bak) { throw "Backup exists: $bak. Nothing changed." } }
foreach ($f in $backs) { Copy-Item -LiteralPath $f -Destination "$f.kb2026panel.bak" }
$newCallback = @'
-- KB_2026 permanent medal prototype. Lua 5.0 compatible; ASCII-only source.
-- Rank, inventory badge, and permanent stat reward are separate effects.
function kb2026_check_ach(tag)
  local ok, err = pcall(function()
    local rank = tonumber(Game.GVNum("kb26_perm_chest_medal_rank")) or 0
    if rank < 1 then
      local badge_ok, badge_err = pcall(function() Logic.hero_add_item("kb26_medal_chest_rank1") end)
      local intellect = tonumber(Logic.hero_lu_item("intellect", "count")) or 0
      Logic.hero_lu_item("intellect", "count", intellect + 1)
      Game.GVNumInc("kb26_perm_chest_medal_rank", 1)
      rank = 1
    end
    Scenario.formsolo("kb26_medal_screen")
  end)
  if not ok then pcall(function() Game.MessageBox("KB2026 UI TEST ERROR: " .. tostring(err)) end) end
end
'@
$s = $s.Substring(0,$cbStart) + $newCallback + "`r`n" + $s.Substring($cbEnd)
$tg = $tg + $gen
$fs = $fs.TrimEnd() + $entry
$lbNew = [byte[]]($lb + [Text.Encoding]::Unicode.GetBytes($labels))
[IO.File]::WriteAllBytes($lua,$latin.GetBytes($s))
[IO.File]::WriteAllBytes($textgen,$latin.GetBytes($tg))
[IO.File]::WriteAllBytes($forms,$latin.GetBytes($fs))
[IO.File]::WriteAllBytes($lng,$lbNew)
[IO.File]::WriteAllText($uiPath,$ui,[Text.Encoding]::ASCII)
Write-Host 'Installed a custom dialog probe using Scenario.formsolo and a GVNum-backed text generator.'
Write-Host 'Backups (.kb2026panel.bak) were created for logic_hero.lua, textgen.lua, forms.txt, and rus_windows_small.lng.'
Write-Host 'Restart game, load the current save, open an unopened chest, and check that the custom medal panel appears.'

