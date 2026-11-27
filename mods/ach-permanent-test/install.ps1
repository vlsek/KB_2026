# Install the no-item permanent medal test into KB_test_copy only.
param([Parameter(Mandatory=$true)][string]$GameDir)
$ErrorActionPreference = 'Stop'
$game = [IO.Path]::GetFullPath($GameDir).TrimEnd('\')
$parent = Split-Path -Parent $game
if ((Split-Path -Leaf $parent) -ne 'KB_test_copy' -or (Split-Path -Leaf $game) -ne 'KB The Legend EE') {
  throw 'Safety stop: this prototype installer only accepts ...\KB_test_copy\KB The Legend EE. Original game was not changed.'
}
$lua = Join-Path $game 'sessions\base\ses\logic_hero.lua'
if (-not (Test-Path -LiteralPath $lua)) { throw "Not found: $lua" }
$enc = [Text.Encoding]::GetEncoding(28591)
$s = $enc.GetString([IO.File]::ReadAllBytes($lua))
$startMarker = '-- KB_2026 achievements v0.3 (agent 1):'
$endMarker = '-- KB_2026 lua-api-dump'
$start = $s.IndexOf($startMarker)
$end = if ($start -ge 0) { $s.IndexOf($endMarker, $start) } else { -1 }
if ($start -lt 0 -or $end -lt 0) { throw 'Expected achievement/APIDUMP markers not found. Nothing changed.' }
if (-not $s.Contains('kb2026_check_ach("takebox")')) { throw 'Chest hook not found. Nothing changed.' }
if ($s.Contains('kb26_perm_chest_medal_rank')) { Write-Host 'Permanent medal prototype already installed.'; exit 0 }
$backup = "$lua.kb2026perm.bak"
if (-not (Test-Path -LiteralPath $backup)) { Copy-Item -LiteralPath $lua -Destination $backup; Write-Host "Backup: $backup" }
$payload = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'payload\ach.lua'), [Text.Encoding]::ASCII)
$s = $s.Substring(0, $start) + $payload + "`r`n" + $s.Substring($end)
[IO.File]::WriteAllBytes($lua, $enc.GetBytes($s))
Write-Host 'Installed. APIDUMP and the chest hook were preserved.'
Write-Host 'Start a NEW game in KB_test_copy, note Intellect, then open the nearby chest.'
