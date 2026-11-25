<# Searches text inside .kfs archives (they are zip files) WITHOUT unpacking them.
   Usage:
     powershell -ExecutionPolicy Bypass -File .\search_kfs.ps1 -Pattern "ahievements|achievements" -Kfs "C:\...\ses.kfs","C:\...\data.kfs"
   Writes matches to Desktop\kfs_search.txt (file name inside archive, line number, line text).
   Looks only at text-like files (lua, txt, ui, ini, cfg, lng, qst, act, chat). UTF-16 (BOM) files are decoded automatically.
   Read only: changes nothing. #>
param(
  [Parameter(Mandatory=$true)][string]$Pattern,
  [Parameter(Mandatory=$true)][string[]]$Kfs,
  [string]$Out = "$env:USERPROFILE\Desktop\kfs_search.txt",
  [string]$Ext = "lua,txt,ui,ini,cfg,lng,qst,act,chat,lu"
)
Add-Type -AssemblyName System.IO.Compression.FileSystem
$exts = $Ext.Split(',') | ForEach-Object { "." + $_.Trim().ToLower() }
$lines = New-Object System.Collections.Generic.List[string]
foreach ($k in $Kfs) {
  if (-not (Test-Path $k)) { Write-Host "NOT FOUND: $k"; continue }
  Write-Host "Scanning $k ..."
  $z = [IO.Compression.ZipFile]::OpenRead($k)
  foreach ($e in $z.Entries) {
    $x = [IO.Path]::GetExtension($e.Name).ToLower()
    if ($exts -notcontains $x -or $e.Length -eq 0 -or $e.Length -gt 20MB) { continue }
    $ms = New-Object IO.MemoryStream
    $s = $e.Open(); $s.CopyTo($ms); $s.Dispose()
    $b = $ms.ToArray(); $ms.Dispose()
    if ($b.Length -ge 2 -and $b[0] -eq 0xFF -and $b[1] -eq 0xFE) { $t = [Text.Encoding]::Unicode.GetString($b) }
    else { $t = [Text.Encoding]::GetEncoding(28591).GetString($b) }
    if ($t -notmatch $Pattern) { continue }
    $n = 0
    foreach ($ln in ($t -split "`n")) {
      $n++
      if ($ln -match $Pattern) { $c = $ln.Trim(); if ($c.Length -gt 220) { $c = $c.Substring(0,220) }; $lines.Add("$([IO.Path]::GetFileName($k)) | $($e.FullName) | $n | $c") }
    }
  }
  $z.Dispose()
}
$lines | Set-Content -Path $Out -Encoding UTF8
Write-Host "Matches: $($lines.Count). Saved to $Out"
