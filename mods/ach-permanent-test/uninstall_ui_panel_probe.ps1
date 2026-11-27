param([Parameter(Mandatory=$true)][string]$GameDir)
$ErrorActionPreference = 'Stop'
$game = [IO.Path]::GetFullPath($GameDir).TrimEnd('\')
if ((Split-Path -Leaf (Split-Path -Parent $game)) -ne 'KB_test_copy' -or (Split-Path -Leaf $game) -ne 'KB The Legend EE') { throw 'Safety stop: only KB_test_copy is accepted.' }
$ses=Join-Path $game 'sessions\base\ses'; $mod=Join-Path $game 'data\mods\32_9-nsf'; $loc=Join-Path $game 'sessions\base\loc_ses\rus'
$files=@((Join-Path $ses 'logic_hero.lua'),(Join-Path $ses 'textgen.lua'),(Join-Path $mod 'forms.txt'),(Join-Path $loc 'rus_windows_small.lng'))
foreach($f in $files){if(-not(Test-Path -LiteralPath ($f+'.kb2026panel.bak'))){throw "Required backup missing: $f.kb2026panel.bak. Nothing restored."}}
foreach($f in $files){Copy-Item -LiteralPath ($f+'.kb2026panel.bak') -Destination $f -Force}
$ui=Join-Path $mod 'kb26_medal_screen.ui'; if(Test-Path -LiteralPath $ui){Remove-Item -LiteralPath $ui -Force}
Write-Host 'Restored the four pre-panel files and removed kb26_medal_screen.ui. Backups were retained.'
