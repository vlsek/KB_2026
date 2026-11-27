# Removes only the lines added by lua-api-dump from logic_hero.lua (other mods stay).
param([Parameter(Mandatory=$true)][string]$GameDir)
$ErrorActionPreference = 'Stop'
$lua = Join-Path $GameDir 'sessions\base\ses\logic_hero.lua'
if (-not (Test-Path -LiteralPath $lua)) { throw "Not found: $lua" }
$enc = [Text.Encoding]::GetEncoding(28591)
$s = $enc.GetString([IO.File]::ReadAllBytes($lua))
if (-not $s.Contains('KB2026-APIDUMP')) { Write-Host 'not installed'; exit 0 }
$s = [regex]::Replace($s, '\r?\n    kb2026_apidump\("takebox"\) -- KB2026-APIDUMP-CALL', '')
$s = [regex]::Replace($s, '(?s)\r?\n-- KB2026-APIDUMP-BEGIN.*?-- KB2026-APIDUMP-END\r?\n', '')
[IO.File]::WriteAllBytes($lua, $enc.GetBytes($s))
Write-Host 'removed. You may delete kb2026_apidump.txt and logic_hero.lua.kb2026api.bak in the game folder.'
