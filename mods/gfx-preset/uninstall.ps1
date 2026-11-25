param([Parameter(Mandatory=$true)][string]$GameDir)
$ini = Get-ChildItem -Path $GameDir -Recurse -Filter 'game.ini.kb2026.bak' -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $ini) { Write-Warning 'no backup found'; exit 1 }
$target = $ini.FullName -replace '\.kb2026\.bak$',''
Copy-Item $ini.FullName $target -Force
Remove-Item $ini.FullName
Write-Host "restored: $target"
