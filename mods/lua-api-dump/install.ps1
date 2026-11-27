# KB_2026 lua-api-dump: ONE harmless call in logic_hero.lua (scn_hero_takebox = opening a chest/box) that writes the list of
# script API functions to <game folder>\kb2026_apidump.txt. Changes no game rules.
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
$outFile = ((Join-Path $GameDir 'kb2026_apidump.txt') -replace '\\', '/')
$payload = $enc.GetString([IO.File]::ReadAllBytes((Join-Path $PSScriptRoot 'payload\apidump.lua')))
$payload = $payload.Replace('@@OUTFILE@@', $outFile).Replace("`r`n", "`n").Replace("`n", "`r`n")
$s = $s.Replace($needle, $needle + "`r`n    kb2026_apidump(`"takebox`") -- KB2026-APIDUMP-CALL")
$s = $s + "`r`n-- KB2026-APIDUMP-BEGIN`r`n" + $payload + "`r`n-- KB2026-APIDUMP-END`r`n"
[IO.File]::WriteAllBytes($lua, $enc.GetBytes($s))
Write-Host "Done. Start the game, load a save, open any chest/box on the map. A message APIDUMP ... appears; the file is: $outFile"
Write-Host 'Send that file (it is a plain list of function names, about 50-200 KB).'
