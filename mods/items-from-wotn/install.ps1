# KB_2026 items-from-wotn (test batch): copies 16 equipment items from Warriors of the North into Legend EE.
# Reads WotN files directly (nothing from the game is stored in the repo). Makes *.kb2026wi.bak backups.
# Usage:
#   .\install.ps1 -GameDir "D:\Games\KB The Legend EE" -WotnDir "D:\Games\King's Bounty Warriors of the North" [-GiveStart]
# Icons: temporary (borrowed from Legend items of the same slot) - real icons need a texture atlas (KBMaster tex mechanism).
#   -GiveStart  also puts the items into the starting backpack of a NEW game (fast test).
# Undo: .\uninstall.ps1 -GameDir ...
param(
  [Parameter(Mandatory=$true)][string]$GameDir,
  [Parameter(Mandatory=$true)][string]$WotnDir,
  [switch]$GiveStart
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$items = @(
 'nomad_helm', 'astral_bow', 'invisible_helm', 'thunder_musket',
 'elconium', 'guard_helm', 'moon_sword', 'army_drum',
 'walnut_mandolin', 'king_borg_horn', 'inkpot', 'stike',
 'voodoo_doll', 'dog_bone', 'travel_bag', 'addon2_regalia_orc_banner'
)
$MB = '//==== kb2026 items-from-wotn begin'
$ME = '//==== kb2026 items-from-wotn end'
$enc = [Text.Encoding]::GetEncoding(28591)   # latin1: lossless bytes

$ses  = Join-Path $GameDir 'sessions\base\ses'
$lng  = Join-Path $GameDir 'sessions\base\loc_ses\rus\rus_items.lng'
$hero = Join-Path $ses 'hero.txt'
$itemsTxt = Join-Path $ses 'items.txt'
$wSes = Join-Path $WotnDir 'sessions\addon\ses.kfs'
$wLoc = Join-Path $WotnDir 'sessions\addon\loc_ses.kfs'
foreach ($p in @($itemsTxt,$lng,$hero,$wSes,$wLoc)) { if (-not (Test-Path $p)) { throw "File not found: $p (check -GameDir / -WotnDir)" } }

function Backup($path) { $bak = "$path.kb2026wi.bak"; if (-not (Test-Path $bak)) { Copy-Item $path $bak; Write-Host "backup: $bak" } }

function Read-ZipEntryBytes($zipPath, $entryName) {
  $zip = [IO.Compression.ZipFile]::OpenRead($zipPath)
  try {
    $e = $zip.Entries | Where-Object { $_.FullName -ieq $entryName -or $_.Name -ieq $entryName } | Select-Object -First 1
    if (-not $e) { return $null }
    $ms = New-Object IO.MemoryStream
    $st = $e.Open(); $st.CopyTo($ms); $st.Close()
    return ,$ms.ToArray()
  } finally { $zip.Dispose() }
}

function Get-Block([string]$text, [string]$name) {
  $m = [regex]::Match($text, '(?m)^' + [regex]::Escape($name) + '[ \t]*\{[ \t]*\r?$')
  if (-not $m.Success) { return $null }
  $depth = 1; $i = $m.Index + $m.Length
  while ($depth -gt 0 -and $i -lt $text.Length) {
    $c = $text[$i]
    if ($c -eq '{') { $depth++ } elseif ($c -eq '}') { $depth-- }
    $i++
  }
  return $text.Substring($m.Index, $i - $m.Index)
}


# Item icons come from game atlases (itextures.dat); loose PNGs are NOT picked up (verified by the owner).
# So every copied item borrows the icon of the first Legend item with the same slot type (temporary look).
function Get-FallbackImage([string]$legendText, [string]$slotBits) {
  foreach ($m in [regex]::Matches($legendText, '(?m)^\w+[ \t]*\{[ \t]*\r?$')) {
    $end = $legendText.IndexOf("`n}", $m.Index)
    if ($end -lt 0) { continue }
    $blk = $legendText.Substring($m.Index, $end - $m.Index)
    if ($blk -match '(?m)^\s*propbits=' + [regex]::Escape($slotBits) + '\s*\r?$' -and $blk -match '(?m)^\s*image=(\S+)') { return $Matches[1] }
  }
  return $null
}

# ---- 1) item blocks from WotN items.txt
$wb = Read-ZipEntryBytes $wSes 'items.txt'
if (-not $wb) { throw 'items.txt not found inside WotN ses.kfs' }
$wItems = $enc.GetString($wb)
$cur = $enc.GetString([IO.File]::ReadAllBytes($itemsTxt))
$blocks = New-Object Text.StringBuilder
$done = @()
foreach ($n in $items) {
  if ($cur -match ('(?m)^' + [regex]::Escape($n) + '[ \t]*\{')) { Write-Host "skip (already in Legend): $n"; continue }
  $b = Get-Block $wItems $n
  if (-not $b) { Write-Warning "not found in WotN: $n"; continue }
  $pb = [regex]::Match($b, '(?m)^\s*propbits=([\w,]+)')
  if ($pb.Success) {
    $fi = Get-FallbackImage $cur $pb.Groups[1].Value
    if ($fi) { $b = [regex]::Replace($b, '(?m)^(\s*image=)\S+', ('${1}' + $fi)) } else { Write-Warning "no fallback icon for $n ($($pb.Groups[1].Value))" }
  }
  [void]$blocks.Append($b + "`r`n`r`n")
  $done += $n
}
if ($done.Count -eq 0) { Write-Host 'nothing to add (already installed?)' }
$itemsFile = Join-Path $ses 'items_wotn.txt'
[IO.File]::WriteAllBytes($itemsFile, $enc.GetBytes("// kb2026 items-from-wotn (generated)`r`n" + $blocks.ToString()))
Write-Host "items_wotn.txt: $($done.Count) items"
Backup $itemsTxt
if (-not $cur.Contains('==items_wotn.txt')) {
  [IO.File]::WriteAllBytes($itemsTxt, [byte[]]($enc.GetBytes("==items_wotn.txt`r`n") + [IO.File]::ReadAllBytes($itemsTxt)))
  Write-Host 'items.txt: include added'
}

# ---- 2) texts from WotN rus_items.lng (UTF-16) -> append to Legend rus_items.lng
$lb = Read-ZipEntryBytes $wLoc 'rus_items.lng'
if (-not $lb) { throw 'rus_items.lng not found inside WotN loc_ses.kfs' }
$wText = [Text.Encoding]::Unicode.GetString($lb)
$lines = New-Object Text.StringBuilder
foreach ($n in $done) {
  foreach ($ln in ($wText -split "\r?\n")) { if ($ln.StartsWith("itm_${n}_")) { [void]$lines.Append($ln + "`r`n") } }
}
Backup $lng
$lt = [Text.Encoding]::Unicode.GetString([IO.File]::ReadAllBytes($lng))
if ($lt.Contains($MB)) { Write-Host 'rus_items.lng: block already present' }
else {
  $add = [Text.Encoding]::Unicode.GetBytes("`r`n$MB`r`n" + $lines.ToString() + "$ME`r`n")
  $fs = [IO.File]::Open($lng,'Append'); $fs.Write($add,0,$add.Length); $fs.Close()
  Write-Host 'rus_items.lng: texts added'
}

# ---- 3) optional start items (tolerant: inserts after every 'items {' line, any content)
if ($GiveStart) {
  Backup $hero
  $hs = $enc.GetString([IO.File]::ReadAllBytes($hero))
  if ($hs.Contains("$($done[0])=1")) { Write-Host 'hero.txt: start items already present' }
  else {
    $ins = ''; foreach ($n in $done) { $ins += "            $n=1`r`n" }
    $new = [regex]::Replace($hs, '(\bitems\s*\{\r\n)', ('$1' + $ins))
    [IO.File]::WriteAllBytes($hero, $enc.GetBytes($new))
    Write-Host 'hero.txt: start items added (all classes)'
  }
}
Write-Host "`nDone. Start a NEW game. With -GiveStart: items are in the backpack. Otherwise they drop from chests/shops over time."
