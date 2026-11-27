# KB_2026 lua-api-dump: one diagnostic call on chest opening. Displays a focused Lua API probe in game message boxes.
# The 2017 EE Lua sandbox has no file-writing API. Changes no game rules.
# Usage:  .\install.ps1 -GameDir "C:\Program Files (x86)\Blefonix Studios\KB The Legend EE"   (as administrator if the game is in Program Files)
# Backup: logic_hero.lua.kb2026api.bak. Remove: .\uninstall.ps1 -GameDir ... (removes only its own lines, other mods stay)
param([Parameter(Mandatory=$true)][string]$GameDir)
$ErrorActionPreference = 'Stop'
$lua = Join-Path $GameDir 'sessions\base\ses\logic_hero.lua'
if (-not (Test-Path -LiteralPath $lua)) { throw "Not found: $lua (check -GameDir)" }
$enc = [Text.Encoding]::GetEncoding(28591)
$s = $enc.GetString([IO.File]::ReadAllBytes($lua))
if ($s.Contains('KB2026-APIDUMP-BEGIN')) { Write-Host 'already installed'; exit 0 }
$needle = 'function scn_hero_takebox ( param )'
if (-not $s.Contains($needle)) { throw 'scn_hero_takebox not found - file differs, nothing changed.' }
$bak = "$lua.kb2026api.bak"
if (-not (Test-Path -LiteralPath $bak)) { Copy-Item -LiteralPath $lua -Destination $bak; Write-Host "backup: $bak" }
$payload = $enc.GetString([IO.File]::ReadAllBytes((Join-Path $PSScriptRoot 'payload\apidump.lua')))
$payload = $payload.Replace("`r`n", "`n").Replace("`n", "`r`n")
$call = '    kb2026_apidump("takebox") -- KB2026-APIDUMP-CALL'
$achCall = '    kb2026_check_ach("takebox")'
if ($s.Contains($achCall)) {
  $s = $s.Replace($achCall, $achCall + "`r`n" + $call)
} else {
  $s = $s.Replace($needle, $needle + "`r`n" + $call)
}
$s = $s + "`r`n-- KB2026-APIDUMP-BEGIN`r`n" + $payload + "`r`n-- KB2026-APIDUMP-END`r`n"
[IO.File]::WriteAllBytes($lua, $enc.GetBytes($s))
Write-Host 'Done. Start a NEW game and open a chest/box. APIPROBE messages show filtered item/slot APIs and safe query results.'
Write-Host 'If ach-lua is installed, the probe is placed after its test grant so item queries observe the granted medal.'
