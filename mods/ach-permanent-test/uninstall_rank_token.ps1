param([Parameter(Mandatory=$true)][string]$GameDir)
$ErrorActionPreference = 'Stop'
$game = [IO.Path]::GetFullPath($GameDir).TrimEnd('\')
if ((Split-Path -Leaf (Split-Path -Parent $game)) -ne 'KB_test_copy' -or (Split-Path -Leaf $game) -ne 'KB The Legend EE') { throw 'Safety stop: only KB_test_copy is accepted.' }
$files = @(
  (Join-Path $game 'sessions\base\ses\logic_hero.lua'),
  (Join-Path $game 'sessions\base\ses\items.txt'),
  (Join-Path $game 'sessions\base\loc_ses\rus\rus_items.lng')
)
foreach ($f in $files) {
  $bak = "$f.kb2026token.bak"
  if (-not (Test-Path -LiteralPath $bak)) { throw "Required backup missing: $bak. Nothing restored." }
}
foreach ($f in $files) { Copy-Item -LiteralPath "$f.kb2026token.bak" -Destination $f -Force }
Write-Host 'Restored logic_hero.lua, items.txt, and rus_items.lng to their pre-token-prototype versions. Backups were retained.'
