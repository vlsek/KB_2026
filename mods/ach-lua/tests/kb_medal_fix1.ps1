# KB_2026 medal fix #1 (agent 1): reuse native icon + try propbits=quest; dump rus_items_base.lng for type-string search
# Run in PowerShell AS ADMINISTRATOR. Undo: -Undo
param([switch]$Undo)
$g = 'C:\Program Files (x86)\Blefonix Studios\KB The Legend EE'
$f = Join-Path $g 'sessions\base\ses\items.txt'
$bak = $f + '.kb2026medalfix.bak'
if ($Undo) { if (Test-Path $bak) { Copy-Item $bak $f -Force; Write-Host 'items.txt restored' } else { Write-Host 'no backup' }; return }
if (-not (Test-Path $bak)) { Copy-Item $f $bak }
$t = [IO.File]::ReadAllText($f, [Text.Encoding]::Default)
$i = $t.IndexOf('medal_test_ok {')
if ($i -lt 0) { Write-Host 'medal_test_ok not found'; return }
$head = $t.Substring(0, $i)
$blk = $t.Substring($i)
$blk = $blk.Replace('image=heroitem_achievement_mental_madman.png', 'image=heroitem_quest_medal.png')
$blk = $blk.Replace('propbits=rare', 'propbits=quest')
[IO.File]::WriteAllText($f, $head + $blk, [Text.Encoding]::Default)
Write-Host 'items.txt patched: image=heroitem_quest_medal.png, propbits=quest'
$out = Join-Path $env:USERPROFILE 'Desktop\items_base_dump.txt'
$l = Join-Path $g 'sessions\base\loc_ses\rus\rus_items_base.lng'
Get-Content $l -Encoding Unicode | Select-Object -First 80 | Out-File $out -Encoding utf8
Write-Host "dump: $out"
