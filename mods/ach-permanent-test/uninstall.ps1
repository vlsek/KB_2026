# Restore the exact logic_hero.lua captured by install.ps1.
param([Parameter(Mandatory=$true)][string]$GameDir)
$ErrorActionPreference = 'Stop'
$lua = Join-Path ([IO.Path]::GetFullPath($GameDir)) 'sessions\base\ses\logic_hero.lua'
$backup = "$lua.kb2026perm.bak"
if (-not (Test-Path -LiteralPath $backup)) { throw "Backup not found: $backup" }
Copy-Item -LiteralPath $backup -Destination $lua -Force
Remove-Item -LiteralPath $backup
Write-Host 'Restored logic_hero.lua from the pre-prototype backup.'
