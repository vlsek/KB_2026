# KB_2026 achievements-test: installs ONE test achievement (Mental Madman) into King's Bounty The Legend EE.
# Usage (PowerShell):
#   .\install.ps1 -GameDir "D:\Games\KB The Legend EE" -IconDir "D:\path\to\folder_with_png"
# Deletes nothing: makes *.kb2026.bak backups before editing. Rollback: .\uninstall.ps1 -GameDir ...
param(
  [Parameter(Mandatory=$true)][string]$GameDir,
  [string]$IconDir = (Join-Path $PSScriptRoot 'icons')
)
$ErrorActionPreference = 'Stop'
$ses  = Join-Path $GameDir 'sessions\base\ses'
$loc  = Join-Path $GameDir 'sessions\base\loc_ses\rus'
$mod  = Join-Path $GameDir 'data\mods\kb2026_achievements'
$cfg  = Join-Path $ses 'config.txt'
$lng  = Join-Path $loc 'rus_items.lng'
$pay  = Join-Path $PSScriptRoot 'payload'

foreach ($p in @($cfg,$lng)) { if (-not (Test-Path $p)) { throw "File not found: $p (check -GameDir)" } }

function Backup($path) {
  $bak = "$path.kb2026.bak"
  if (-not (Test-Path $bak)) { Copy-Item $path $bak; Write-Host "backup: $bak" }
}

# 1) config.txt: enable the medal bit (in Legend the line is commented out as //undropable=0x0008). Edited at byte level, encoding untouched.
Backup $cfg
$b   = [IO.File]::ReadAllBytes($cfg)
$enc = [Text.Encoding]::GetEncoding(28591)   # latin1: 1 byte = 1 char, lossless
$s   = $enc.GetString($b)
if ($s -match 'medal=0x0008') {
  Write-Host 'config.txt: medal already enabled'
} elseif ($s.Contains('//undropable=0x0008')) {
  $s = $s.Replace('//undropable=0x0008','medal=0x0008')
  [IO.File]::WriteAllBytes($cfg, $enc.GetBytes($s)); Write-Host 'config.txt: medal=0x0008 enabled'
} else {
  throw 'config.txt: line //undropable=0x0008 not found - different file version, stopped (nothing changed).'
}

# 2) items.txt: include achievements.txt (Legend has no such line; DS/WotN have it at the top of items.txt). Prepended at byte level.
$items = Join-Path $ses 'items.txt'
Backup $items
$ib = [IO.File]::ReadAllBytes($items)
$is = $enc.GetString($ib)
if ($is.Contains('==achievements.txt')) {
  Write-Host 'items.txt: include already present'
} else {
  $ins = $enc.GetBytes("==achievements.txt`r`n")
  [IO.File]::WriteAllBytes($items, [byte[]]($ins + $ib)); Write-Host 'items.txt: added ==achievements.txt'
}

# 2b) achievements.txt
Copy-Item (Join-Path $pay 'achievements.txt') (Join-Path $ses 'achievements.txt') -Force
Write-Host 'achievements.txt copied'

# 3) texts: append to the end of rus_items.lng (UTF-16 LE with BOM)
Backup $lng
$cur = [IO.File]::ReadAllBytes($lng)
$txt = [Text.Encoding]::UTF8.GetString([IO.File]::ReadAllBytes((Join-Path $pay 'rus_items_append.txt')))
$curTxt = [Text.Encoding]::Unicode.GetString($cur)
if ($curTxt.Contains('itm_medal_achievement_mental_madman_1_name')) {
  Write-Host 'rus_items.lng: strings already present'
} else {
  $add = [Text.Encoding]::Unicode.GetBytes($txt)
  $fs = [IO.File]::Open($lng,'Append'); $fs.Write($add,0,$add.Length); $fs.Close()
  Write-Host 'rus_items.lng: strings added'
}

# 4) icons
New-Item -ItemType Directory -Force $mod | Out-Null
$icons = Get-ChildItem $IconDir -Filter 'heroitem_achievement_mental_madman*.png' -ErrorAction SilentlyContinue
if ($icons) { $icons | ForEach-Object { Copy-Item $_.FullName $mod -Force }; Write-Host "icons copied to $mod" }
else { Write-Warning "icons not found in $IconDir - the achievement will work but the icon may be empty" }

Write-Host "`nDone. Start a NEW game or load a save and fight a battle with magic (threshold is 1 magic damage - one spell in a battle is enough)."
