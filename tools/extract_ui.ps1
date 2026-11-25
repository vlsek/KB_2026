<# Extracts all *.ui and resolutions.txt from data.kfs into folder kb_ui and zips it to kb_ui.zip on the desktop.
   Usage: powershell -ExecutionPolicy Bypass -File .\extract_ui.ps1 -Kfs "C:\...\data\data.kfs" #>
param([string]$Kfs, [string]$OutDir = "$env:USERPROFILE\Desktop\kb_ui")
Add-Type -AssemblyName System.IO.Compression.FileSystem
New-Item -ItemType Directory -Force $OutDir | Out-Null
$z = [IO.Compression.ZipFile]::OpenRead($Kfs)
$z.Entries | Where-Object { $_.Name -like "*.ui" -or $_.Name -eq "resolutions.txt" } |
  ForEach-Object { [IO.Compression.ZipFileExtensions]::ExtractToFile($_, "$OutDir\$($_.Name)", $true) }
$z.Dispose()
Compress-Archive "$OutDir\*" "$OutDir.zip" -Force
