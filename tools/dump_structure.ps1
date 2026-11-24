<#
  Снимок структуры папки игры (для проекта KB_2026).
  Использование:  powershell -ExecutionPolicy Bypass -File .\dump_structure.ps1 -GameRoot "C:\путь\к\игре"
  Ничего не меняет, только читает. В выводе — относительные пути.
#>
param(
  [string]$GameRoot = ".",
  [string]$OutDir = ".\kb_structure"
)

$root = (Resolve-Path -LiteralPath $GameRoot).Path.TrimEnd('\')
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

Write-Host "Сканирую $root ..."
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

# 1. Сводка: папка + расширение
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

# 2. Дерево папок до глубины 3
$dirs = Get-ChildItem -LiteralPath $root -Recurse -Directory -Force -Depth 2 -ErrorAction SilentlyContinue
$dirs | ForEach-Object {
  $rel = $_.FullName.Substring($root.Length).TrimStart('\')
  $cnt = (Get-ChildItem -LiteralPath $_.FullName -File -Force -ErrorAction SilentlyContinue | Measure-Object).Count
  "{0}  ({1} файлов)" -f $rel, $cnt
} | Sort-Object | Out-File -FilePath "$OutDir\top_levels.txt" -Encoding UTF8

# 3. Полный список
$rows | Select-Object Path, Size, Date | Export-Csv -Path "$OutDir\full_listing.csv" -NoTypeInformation -Encoding UTF8

Write-Host "Готово: $OutDir (summary.csv, top_levels.txt, full_listing.csv)"
