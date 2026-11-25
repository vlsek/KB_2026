<#
  Snapshot of a game folder structure (for the KB_2026 project).
  Usage:  powershell -ExecutionPolicy Bypass -File .\dump_structure.ps1 -GameRoot "C:\path\to\game"
  Changes nothing, read only. Output uses relative paths.
#>
param(
  [string]$GameRoot = ".",
  [string]$OutDir = ".\kb_structure"
)

$root = (Resolve-Path -LiteralPath $GameRoot).Path.TrimEnd('\')
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

Write-Host "Scanning $root ..."
$files = Get-ChildItem -LiteralPath $root -Recurse -File -Force -ErrorAction SilentlyContinue

$rows = foreach ($f in $files) {
  $rel = $f.FullName.Substring($root.Length).TrimStart('\')
  $dir = Split-Path $rel -Parent
  [pscustomobject]@{
    Dir   = if ($dir) { $dir } else { "." }
    Ext   = $f.Extension.ToLower()
    Size  = $f.Length
    Date  = $f.LastWriteTime.ToString("yyyy-MM-dd")
    Path  = $rel
  }
}

# 1. Summary: folder + extension
$rows | Group-Object Dir, Ext | ForEach-Object {
  $first = $_.Group[0]
  [pscustomobject]@{
    Dir     = $first.Dir
    Ext     = $first.Ext
    Files   = $_.Count
    SizeMB  = [math]::Round((($_.Group | Measure-Object Size -Sum).Sum / 1MB), 2)
    OldestDate = ($_.Group | Sort-Object Date | Select-Object -First 1).Date
    NewestDate = ($_.Group | Sort-Object Date | Select-Object -Last 1).Date
  }
} | Sort-Object Dir, Ext | Export-Csv -Path "$OutDir\summary.csv" -NoTypeInformation -Encoding UTF8

# 2. Folder tree up to depth 3
$dirs = Get-ChildItem -LiteralPath $root -Recurse -Directory -Force -Depth 2 -ErrorAction SilentlyContinue
$dirs | ForEach-Object {
  $rel = $_.FullName.Substring($root.Length).TrimStart('\')
  $cnt = (Get-ChildItem -LiteralPath $_.FullName -File -Force -ErrorAction SilentlyContinue | Measure-Object).Count
  "{0}  ({1} files)" -f $rel, $cnt
} | Sort-Object | Out-File -FilePath "$OutDir\top_levels.txt" -Encoding UTF8

# 3. Full listing
$rows | Select-Object Path, Size, Date | Export-Csv -Path "$OutDir\full_listing.csv" -NoTypeInformation -Encoding UTF8

Write-Host "Done: $OutDir (summary.csv, top_levels.txt, full_listing.csv)"
