# Removes items-from-wotn without touching other mods' edits (does not restore whole files).
param([Parameter(Mandatory=$true)][string]$GameDir)
$ErrorActionPreference = 'Stop'
$enc = [Text.Encoding]::GetEncoding(28591)
$ses  = Join-Path $GameDir 'sessions\base\ses'
$lng  = Join-Path $GameDir 'sessions\base\loc_ses\rus\rus_items.lng'
$MB = '//==== kb2026 items-from-wotn begin'
$ME = '//==== kb2026 items-from-wotn end'
$itemsFile = Join-Path $ses 'items_wotn.txt'
$names = @()
if (Test-Path $itemsFile) {
  $t = $enc.GetString([IO.File]::ReadAllBytes($itemsFile))
  $names = [regex]::Matches($t, '(?m)^(\w+)[ \t]*\{[ \t]*\r?$') | ForEach-Object { $_.Groups[1].Value }
}
# items.txt include line
$p = Join-Path $ses 'items.txt'
$s = $enc.GetString([IO.File]::ReadAllBytes($p))
$s = $s.Replace("==items_wotn.txt`r`n", '')
[IO.File]::WriteAllBytes($p, $enc.GetBytes($s))
Remove-Item $itemsFile -ErrorAction SilentlyContinue
# hero.txt start items
$h = Join-Path $ses 'hero.txt'
$hs = $enc.GetString([IO.File]::ReadAllBytes($h))
foreach ($n in $names) { $hs = [regex]::Replace($hs, '(?m)^[ \t]*' + [regex]::Escape($n) + '=1\r\n', '') }
[IO.File]::WriteAllBytes($h, $enc.GetBytes($hs))
# texts block
$lt = [Text.Encoding]::Unicode.GetString([IO.File]::ReadAllBytes($lng))
$i = $lt.IndexOf($MB)
if ($i -ge 0) {
  $j = $lt.IndexOf($ME, $i)
  if ($j -ge 0) { $lt = $lt.Remove($i, ($j + $ME.Length) - $i).TrimEnd("`r","`n") + "`r`n" }
  $bytes = [Text.Encoding]::Unicode.GetBytes($lt)
  [IO.File]::WriteAllBytes($lng, $bytes)
}
Remove-Item (Join-Path $GameDir 'data\mods\kb2026_items') -Recurse -ErrorAction SilentlyContinue
Write-Host 'items-from-wotn removed.'
