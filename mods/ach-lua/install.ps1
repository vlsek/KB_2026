# KB_2026 achievements v0 (agent 1): adds kb2026_check_ach() to logic_hero.lua and calls it from scn_hero_takebox (opening a chest/box).
# Needs mods\achievements-test (medal items) installed. Run PowerShell AS ADMINISTRATOR (the game is in Program Files).
# Usage:  powershell -ExecutionPolicy Bypass -File .\install.ps1 -GameDir "C:\Program Files (x86)\Blefonix Studios\KB The Legend EE"
# Backup: logic_hero.lua.kb2026ach.bak. Undo: .\uninstall.ps1 -GameDir ...  (uninstall lua-probe first if it is installed)
param([Parameter(Mandatory=$true)][string]$GameDir)
$ErrorActionPreference = 'Stop'
$lua = Join-Path $GameDir 'sessions\base\ses\logic_hero.lua'
if (-not (Test-Path $lua)) { throw "Not found: $lua (check -GameDir)" }
$enc = [Text.Encoding]::GetEncoding(28591)
$s = $enc.GetString([IO.File]::ReadAllBytes($lua))
if ($s.Contains('kb2026_probe')) { throw 'lua-probe is installed - run lua-probe uninstall.ps1 first. Nothing changed.' }
if ($s.Contains('kb2026_check_ach')) { Write-Host 'already installed'; exit 0 }
$needle = 'function scn_hero_takebox ( param )'
if (-not $s.Contains($needle)) { throw 'scn_hero_takebox not found - file differs, nothing changed.' }
$bak = "$lua.kb2026ach.bak"
if (-not (Test-Path $bak)) { Copy-Item $lua $bak; Write-Host "backup: $bak" }
$s = $s.Replace($needle, $needle + "`r`n    kb2026_check_ach(`"takebox`")")
$add = $enc.GetString([IO.File]::ReadAllBytes((Join-Path $PSScriptRoot 'payload\ach.lua'))).Replace("`r`n","`n").Replace("`n","`r`n")
$s = $s + "`r`n" + $add
[IO.File]::WriteAllBytes($lua, $enc.GetBytes($s))
Write-Host 'Done. New game: cast ANY spell in a battle (magic damage), then open a chest/box. Expect: an Achievement: High Mage message and the test medal in the backpack.'
