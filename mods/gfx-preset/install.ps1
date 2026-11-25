# KB_2026 gfx-preset: sets graphics keys in game.ini (Legend EE). Makes game.ini.kb2026.bak first.
# Usage:  .\install.ps1 -GameDir "D:\Games\KB The Legend EE" -Level 1
#   Level 1: anisotropic 16x (r_filter 5)
#   Level 2: Level 1 + shadows 2048 + landscape shadows
#   Level 3: Level 1 + shadows 4096 + landscape shadows (heavier)
# Undo: .\uninstall.ps1 -GameDir ...   (or copy game.ini.kb2026.bak over game.ini)
param(
  [Parameter(Mandatory=$true)][string]$GameDir,
  [ValidateSet(1,2,3)][int]$Level = 1
)
$ErrorActionPreference = 'Stop'
$ini = Get-ChildItem -Path $GameDir -Recurse -Filter 'game.ini' -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch 'mods' } | Select-Object -First 1
if (-not $ini) { throw "game.ini not found under $GameDir. Start the game once, then retry." }
$path = $ini.FullName
Write-Host "game.ini: $path"
$bak = "$path.kb2026.bak"
if (-not (Test-Path $bak)) { Copy-Item $path $bak; Write-Host "backup: $bak" }

$enc  = [Text.Encoding]::GetEncoding(28591)
$text = $enc.GetString([IO.File]::ReadAllBytes($path))

function Set-IniKey([string]$t, [string]$key, [string]$value) {
  $pattern = '(?m)^setf?\s+~' + [regex]::Escape($key) + '\s+[^\r\n]*'
  $line = "setf ~$key $value"
  if ($t -match $pattern) { return [regex]::Replace($t, $pattern, $line) }
  if (-not $t.EndsWith("`n")) { $t += "`r`n" }
  return $t + $line + "`r`n"
}

$settings = @{ 'r_filter' = '5' }
if ($Level -ge 2) { $settings['shadowresolution'] = '2048'; $settings['r_shadowmap_landscape'] = '1' }
if ($Level -ge 3) { $settings['shadowresolution'] = '4096' }
foreach ($k in $settings.Keys) { $text = Set-IniKey $text $k $settings[$k]; Write-Host "set $k = $($settings[$k])" }

[IO.File]::WriteAllBytes($path, $enc.GetBytes($text))
Write-Host 'Done. Start the game, compare the ground in the distance and shadows. Note FPS before/after.'
