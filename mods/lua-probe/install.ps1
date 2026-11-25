# KB_2026 lua-probe: adds ONE harmless probe call to logic_hero.lua (scn_hero_takebox = picking up a chest/box on the map).
# Usage:  .\install.ps1 -GameDir "D:\Games\KB The Legend EE"
# Makes a backup logic_hero.lua.kb2026.bak. Undo: .\uninstall.ps1 -GameDir ...
param([Parameter(Mandatory=$true)][string]$GameDir)
$ErrorActionPreference = 'Stop'
$lua = Join-Path $GameDir 'sessions\base\ses\logic_hero.lua'
if (-not (Test-Path $lua)) { throw "Not found: $lua (check -GameDir)" }
$bak = "$lua.kb2026.bak"
if (-not (Test-Path $bak)) { Copy-Item $lua $bak; Write-Host "backup: $bak" }
$enc = [Text.Encoding]::GetEncoding(28591)
$b = [IO.File]::ReadAllBytes($lua)
$s = $enc.GetString($b)
if ($s.Contains('kb2026_probe')) { Write-Host 'already installed'; exit 0 }
$needle = 'function scn_hero_takebox ( param )'
if (-not $s.Contains($needle)) { throw 'scn_hero_takebox not found - file differs, nothing changed.' }
$s = $s.Replace($needle, $needle + "`r`n    kb2026_probe(`"takebox`")")
$probe = $enc.GetString([IO.File]::ReadAllBytes((Join-Path $PSScriptRoot 'payload\probe.lua'))).Replace("`r`n","`n").Replace("`n","`r`n")
$s = $s + "`r`n" + $probe
[IO.File]::WriteAllBytes($lua, $enc.GetBytes($s))
Write-Host 'Done. Start the game, load a save, pick up any chest/box on the map: a message box with PROBE ... should appear. Send a screenshot.'
