<# Find-KBText.ps1 - search text in loose files AND inside .kfs archives of a game folder. READ ONLY.
   Usage:
     powershell -ExecutionPolicy Bypass -File .\Find-KBText.ps1 -GameDir "C:\Games\KB The Legend EE" -Pattern "difficult|highlight"
   Output: Desktop\kb_find.txt   (lines: <where> | <line number> | <text, cut to 220 chars>)
   Where = path relative to the game folder; for archives: <archive>.kfs!<file inside>.
   Default extensions: lua, lu, txt, ui, ini, cfg, csv. Add more with -Ext "lua,lu,txt,ui,lng,qst".
   -SkipPath is an optional regex: paths that match it are skipped (e.g. "quest_").
   UTF-16 files (with BOM) are decoded automatically. Nothing is changed or written next to the game. #>
param(
  [Parameter(Mandatory=$true)][string]$GameDir,
  [Parameter(Mandatory=$true)][string]$Pattern,
  [string]$Out = "$env:USERPROFILE\Desktop\kb_find.txt",
  [string]$Ext = "lua,lu,txt,ui,ini,cfg,csv",
  [string]$SkipPath = ""
)
Add-Type -AssemblyName System.IO.Compression.FileSystem
$exts = $Ext.Split(',') | ForEach-Object { "." + $_.Trim().ToLower() }
$root = (Resolve-Path -LiteralPath $GameDir).Path.TrimEnd('\')
$lines = New-Object System.Collections.Generic.List[string]
$perFile = @{}

function Decode([byte[]]$b) {
  if ($b.Length -ge 2 -and $b[0] -eq 0xFF -and $b[1] -eq 0xFE) { return [Text.Encoding]::Unicode.GetString($b) }
  return [Text.Encoding]::GetEncoding(28591).GetString($b)
}

function Scan([string]$where, [string]$text) {
  if ($text -notmatch $Pattern) { return }
  $n = 0
  foreach ($ln in ($text -split "`n")) {
    $n++
    if ($ln -match $Pattern) {
      $c = $ln.Trim()
      if ($c.Length -gt 220) { $c = $c.Substring(0, 220) }
      $script:lines.Add("$where | $n | $c")
      if ($script:perFile.ContainsKey($where)) { $script:perFile[$where]++ } else { $script:perFile[$where] = 1 }
    }
  }
}

Write-Host "Scanning loose files in $root ..."
$all = Get-ChildItem -LiteralPath $root -Recurse -File -Force -ErrorAction SilentlyContinue
foreach ($f in $all) {
  $rel = $f.FullName.Substring($root.Length).TrimStart('\')
  if ($SkipPath -ne "" -and $rel -match $SkipPath) { continue }
  $x = $f.Extension.ToLower()
  if ($x -eq ".kfs") { continue }
  if ($exts -notcontains $x -or $f.Length -eq 0 -or $f.Length -gt 20MB) { continue }
  Scan $rel (Decode ([IO.File]::ReadAllBytes($f.FullName)))
}

foreach ($f in ($all | Where-Object { $_.Extension -ieq ".kfs" })) {
  $rel = $f.FullName.Substring($root.Length).TrimStart('\')
  Write-Host "Scanning archive $rel ..."
  try { $z = [IO.Compression.ZipFile]::OpenRead($f.FullName) } catch { Write-Host "  cannot open: $rel"; continue }
  foreach ($e in $z.Entries) {
    $x = [IO.Path]::GetExtension($e.Name).ToLower()
    if ($exts -notcontains $x -or $e.Length -eq 0 -or $e.Length -gt 20MB) { continue }
    if ($SkipPath -ne "" -and $e.FullName -match $SkipPath) { continue }
    $ms = New-Object IO.MemoryStream
    $s = $e.Open(); $s.CopyTo($ms); $s.Dispose()
    $b = $ms.ToArray(); $ms.Dispose()
    Scan "$rel!$($e.FullName)" (Decode $b)
  }
  $z.Dispose()
}

$lines | Set-Content -Path $Out -Encoding UTF8
Write-Host ""
Write-Host "Matches: $($lines.Count) in $($perFile.Count) files. Saved to $Out"
Write-Host "Top files:"
$perFile.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 15 | ForEach-Object { Write-Host ("  {0,5}  {1}" -f $_.Value, $_.Key) }
