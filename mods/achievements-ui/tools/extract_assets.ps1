<# Достаёт картинки интерфейса достижений из interface_textures.kfs игры-донора (Воин Севера / Dark Side) в папку мода.
   Использование:
     powershell -ExecutionPolicy Bypass -File .\extract_assets.ps1 -Kfs "...\King's Bounty Warriors of the North\data\interface_textures.kfs" -OutDir "...\KB The Legend EE\data\mods\16_9-nsf"
   Ничего не удаляет, существующие файлы не перезаписывает. Если какой-то картинки нет в этом архиве — выведет её имя. #>
param([Parameter(Mandatory=$true)][string]$Kfs, [Parameter(Mandatory=$true)][string]$OutDir)
Add-Type -AssemblyName System.IO.Compression.FileSystem
$want = @(
 'achievement_bg.png','book_next_page_normal.png','book_next_page_onmouse.png','book_next_page_onpress.png',
 'book_prev_page_normal.png','book_prev_page_onmouse.png','book_prev_page_onpress.png',
 'bookbuttonclose_normal.png','bookbuttonclose_onmouse.png','bookbuttonclose_onpress.png',
 'new_achievement_background02.png','titule_header.png',
 'buy_button_ok2_normal.png','buy_button_ok2_onmouse.png','buy_button_ok2_onpress.png','buy_button_ok2_disable.png',
 'ahievements_button_normal_01.png','ahievements_button_mouse_over_01.png','ahievements_button_click_01.png','ahievements_button_non_active_01.png',
 'achievements_bar_04.png'
)
$z = [IO.Compression.ZipFile]::OpenRead($Kfs)
$found = @{}
foreach ($e in $z.Entries) { if ($want -contains $e.Name) { $found[$e.Name] = $e } }
foreach ($n in $want) {
  if ($found.ContainsKey($n)) {
    $dst = Join-Path $OutDir $n
    if (-not (Test-Path $dst)) { [IO.Compression.ZipFileExtensions]::ExtractToFile($found[$n], $dst); Write-Host "ok   $n" } else { Write-Host "есть $n" }
  } else { Write-Host "НЕТ  $n (искать в textures.kfs или в другой игре)" }
}
$z.Dispose()
