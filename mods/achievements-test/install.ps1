# KB_2026 achievements-test: ставит ОДНО тестовое достижение "Высший маг" в King's Bounty The Legend EE.
# Запуск (PowerShell):
#   .\install.ps1 -GameDir "D:\Games\KB The Legend EE" -IconDir "D:\path\to\folder_with_png"
# Ничего не удаляет: перед правкой делает резервные копии *.kb2026.bak. Откат: .\uninstall.ps1 -GameDir ...
param(
  [Parameter(Mandatory=$true)][string]$GameDir,
  [string]$IconDir = (Join-Path $PSScriptRoot 'icons')
)
$ErrorActionPreference = 'Stop'
$ses  = Join-Path $GameDir 'sessions\base\ses'
$loc  = Join-Path $GameDir 'sessions\base\loc_ses\rus'
$mod  = Join-Path $GameDir 'data\mods\kb2026_achievements'
$cfg  = Join-Path $ses 'config.txt'
$lng  = Join-Path $loc 'rus_items.lng'
$pay  = Join-Path $PSScriptRoot 'payload'

foreach ($p in @($cfg,$lng)) { if (-not (Test-Path $p)) { throw "Не найден файл: $p (проверь -GameDir)" } }

function Backup($path) {
  $bak = "$path.kb2026.bak"
  if (-not (Test-Path $bak)) { Copy-Item $path $bak; Write-Host "backup: $bak" }
}

# 1) config.txt: включаем бит medal (в Legend строка закомментирована как //undropable=0x0008). Правим на уровне байтов, кодировку не трогаем.
Backup $cfg
$b   = [IO.File]::ReadAllBytes($cfg)
$enc = [Text.Encoding]::GetEncoding(28591)   # latin1: 1 байт = 1 символ, без потерь
$s   = $enc.GetString($b)
if ($s -match 'medal=0x0008') {
  Write-Host 'config.txt: medal уже включён'
} elseif ($s.Contains('//undropable=0x0008')) {
  $s = $s.Replace('//undropable=0x0008','medal=0x0008')
  [IO.File]::WriteAllBytes($cfg, $enc.GetBytes($s)); Write-Host 'config.txt: medal=0x0008 включён'
} else {
  throw 'config.txt: не нашёл строку //undropable=0x0008 — версия файла другая, остановился (ничего не менял).'
}

# 2) items.txt: подключаем achievements.txt (в Legend такой строки нет; в DS/WotN она стоит в начале items.txt). Добавляем байтами в начало.
$items = Join-Path $ses 'items.txt'
Backup $items
$ib = [IO.File]::ReadAllBytes($items)
$is = $enc.GetString($ib)
if ($is.Contains('==achievements.txt')) {
  Write-Host 'items.txt: include уже есть'
} else {
  $ins = $enc.GetBytes("==achievements.txt`r`n")
  [IO.File]::WriteAllBytes($items, [byte[]]($ins + $ib)); Write-Host 'items.txt: добавлено ==achievements.txt'
}

# 2b) achievements.txt
Copy-Item (Join-Path $pay 'achievements.txt') (Join-Path $ses 'achievements.txt') -Force
Write-Host 'achievements.txt скопирован'

# 3) тексты: дописываем в конец rus_items.lng (UTF-16 LE с BOM)
Backup $lng
$cur = [IO.File]::ReadAllBytes($lng)
$txt = [Text.Encoding]::UTF8.GetString([IO.File]::ReadAllBytes((Join-Path $pay 'rus_items_append.txt')))
$curTxt = [Text.Encoding]::Unicode.GetString($cur)
if ($curTxt.Contains('itm_medal_achievement_mental_madman_1_name')) {
  Write-Host 'rus_items.lng: строки уже есть'
} else {
  $add = [Text.Encoding]::Unicode.GetBytes($txt)
  $fs = [IO.File]::Open($lng,'Append'); $fs.Write($add,0,$add.Length); $fs.Close()
  Write-Host 'rus_items.lng: строки добавлены'
}

# 4) иконки
New-Item -ItemType Directory -Force $mod | Out-Null
$icons = Get-ChildItem $IconDir -Filter 'heroitem_achievement_mental_madman*.png' -ErrorAction SilentlyContinue
if ($icons) { $icons | ForEach-Object { Copy-Item $_.FullName $mod -Force }; Write-Host "иконки скопированы в $mod" }
else { Write-Warning "иконки не найдены в $IconDir — достижение сработает, но значок может быть пустым" }

Write-Host "`nГотово. Запусти НОВУЮ игру или загрузи сохранение, проведи бой с магией (порог 1 урон магией — достаточно одного заклинания в бою)."
