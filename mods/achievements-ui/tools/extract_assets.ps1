<# Extracts achievement UI images from interface_textures.kfs of a donor game (Warriors of the North / Dark Side).
   Usage (output goes to a folder on the desktop by default - Program Files needs admin rights):
     powershell -ExecutionPolicy Bypass -File .\extract_assets.ps1 -Kfs "...\King's Bounty Warriors of the North\data\interface_textures.kfs"
   Then copy the PNG files from the output folder into the mod folder (Explorer will ask for admin confirmation),
   or pass -OutDir with the mod folder and run PowerShell as Administrator.
   Deletes nothing, does not overwrite existing files. Prints OK / HAVE / MISS / FAIL for every image. #>
param(
  [Parameter(Mandatory=$true)][string]$Kfs,
  [string]$OutDir = "$env:USERPROFILE\Desktop\kb_ach_png"
)
Add-Type -AssemblyName System.IO.Compression.FileSystem
New-Item -ItemType Directory -Force $OutDir | Out-Null
# Only images that the game itself does NOT already have. Book buttons (book_next_page_*, bookbuttonclose_*) and
# buy_button_ok2_* are already used by Legend windows book.ui / buy.ui, so they are not extracted.
$want = @(
 'achievement_bg.png',
 'new_achievement_background02.png','titule_header.png',
 'ahievements_button_normal_01.png','ahievements_button_mouse_over_01.png','ahievements_button_click_01.png','ahievements_button_non_active_01.png',
 'achievements_bar_04.png'
)
$z = [IO.Compression.ZipFile]::OpenRead($Kfs)
$found = @{}
foreach ($e in $z.Entries) { if ($want -contains $e.Name) { $found[$e.Name] = $e } }
$bad = 0
foreach ($n in $want) {
  if (-not $found.ContainsKey($n)) { Write-Host "MISS $n (not in this archive; try textures.kfs or another game)"; continue }
  $dst = Join-Path $OutDir $n
  if (Test-Path $dst) { Write-Host "HAVE $n"; continue }
  try { [IO.Compression.ZipFileExtensions]::ExtractToFile($found[$n], $dst); Write-Host "OK   $n" }
  catch { Write-Host "FAIL $n : $($_.Exception.Message)"; $bad++ }
}
$z.Dispose()
Write-Host "Output folder: $OutDir"
if ($bad -gt 0) { Write-Host "Some files failed: choose a writable -OutDir (e.g. the desktop) or run PowerShell as Administrator." }
