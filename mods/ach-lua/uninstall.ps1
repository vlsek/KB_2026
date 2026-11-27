param([Parameter(Mandatory=$true)][string]$GameDir)
$lua = Join-Path $GameDir 'sessions\base\ses\logic_hero.lua'
$bak = "$lua.kb2026ach.bak"
if (Test-Path $bak) { Copy-Item $bak $lua -Force -ErrorAction Stop; Remove-Item $bak -ErrorAction Stop; Write-Host 'restored' } else { Write-Warning 'no backup found' }
