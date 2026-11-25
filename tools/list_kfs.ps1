<# Lists contents of all .kfs in the game data folder -> kfs_listing.csv on the desktop.
   Usage: powershell -ExecutionPolicy Bypass -File .\list_kfs.ps1 -DataDir "C:\...\KB The Legend EE\data"
   Changes nothing. .kfs are read as zip, no renaming needed. #>
param([string]$DataDir = ".", [string]$Out = "$env:USERPROFILE\Desktop\kfs_listing.csv")
Add-Type -AssemblyName System.IO.Compression.FileSystem
Get-ChildItem $DataDir -Filter *.kfs | ForEach-Object {
  $kfs = $_.Name
  $z = [IO.Compression.ZipFile]::OpenRead($_.FullName)
  $z.Entries | ForEach-Object { [pscustomobject]@{Archive=$kfs; Path=$_.FullName; Size=$_.Length} }
  $z.Dispose()
} | Export-Csv $Out -NoTypeInformation -Encoding UTF8
