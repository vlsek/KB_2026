param([Parameter(Mandatory=$true)][string]$GameDir)
$ErrorActionPreference = 'Stop'
$mod   = Join-Path $GameDir 'data\mods\32_9-nsf'
$forms = Join-Path $mod 'forms.txt'
$lng   = Join-Path $GameDir 'sessions\base\loc_ses\rus\rus_hero.lng'
$MB = '//==== kb2026 medals-book begin'
$ME = '//==== kb2026 medals-book end'
$bak = "$forms.kb2026mb.bak"
if (Test-Path $bak) { Copy-Item $bak $forms -Force; Remove-Item $bak; Write-Host 'forms.txt restored' }
$lt = [Text.Encoding]::Unicode.GetString([IO.File]::ReadAllBytes($lng))
$i = $lt.IndexOf($MB)
if ($i -ge 0) {
  $j = $lt.IndexOf($ME, $i)
  if ($j -ge 0) { $lt = $lt.Remove($i, ($j + $ME.Length) - $i).TrimEnd("`r","`n") + "`r`n" }
  [IO.File]::WriteAllBytes($lng, [Text.Encoding]::Unicode.GetBytes($lt))
  Write-Host 'rus_hero.lng: block removed'
}
foreach ($f in @('hero_3360x945.ui','medals_book_bg.png')) { Remove-Item (Join-Path $mod $f) -ErrorAction SilentlyContinue }
Remove-Item "$lng.kb2026mb.bak" -ErrorAction SilentlyContinue
Write-Host 'medals-book removed.'
