<# Extracts files whose NAME matches a regex from one or more .kfs (zip) archives. Read only on the game folder.
   Usage:
     powershell -ExecutionPolicy Bypass -File .\extract_png.ps1 -Pattern "^(hero_bg18|records_.*)\.png$" -Kfs "C:\...\interface_textures.kfs"
   Output: Desktop\kb_png\<archive name>\<file>  (override with -OutDir). Statuses: OK / FAIL per file, summary at the end. #>
param(
  [Parameter(Mandatory=$true)][string]$Pattern,
  [Parameter(Mandatory=$true)][string[]]$Kfs,
  [string]$OutDir = "$env:USERPROFILE\Desktop\kb_png"
)
Add-Type -AssemblyName System.IO.Compression.FileSystem
$ok = 0; $fail = 0
foreach ($k in $Kfs) {
  if (-not (Test-Path $k)) { Write-Host "NOT FOUND: $k"; continue }
  $dst = Join-Path $OutDir ([IO.Path]::GetFileNameWithoutExtension($k))
  New-Item -ItemType Directory -Force -Path $dst | Out-Null
  $z = [IO.Compression.ZipFile]::OpenRead($k)
  foreach ($e in $z.Entries) {
    if ($e.Name -notmatch $Pattern) { continue }
    try {
      [IO.Compression.ZipFileExtensions]::ExtractToFile($e, (Join-Path $dst $e.Name), $true)
      Write-Host "OK   $($e.Name)"; $ok++
    } catch { Write-Host "FAIL $($e.Name): $($_.Exception.Message)"; $fail++ }
  }
  $z.Dispose()
}
Write-Host "Done: $ok extracted, $fail failed. Folder: $OutDir"
