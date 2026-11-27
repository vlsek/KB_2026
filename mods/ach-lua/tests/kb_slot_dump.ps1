# KB_2026 slot dump (agent 1): collects how equipment slots and propbits are defined. Read-only.
# Run in PowerShell (admin not needed). Output: Desktop\slot_dump.txt
$g = 'C:\Program Files (x86)\Blefonix Studios\KB The Legend EE'
$out = Join-Path $env:USERPROFILE 'Desktop\slot_dump.txt'
$ses = Join-Path $g 'sessions\base\ses'
"== hero.txt: lines with slot (context 4)" | Out-File $out -Encoding utf8
Select-String -Path (Join-Path $ses 'hero.txt') -Pattern 'slot' -Context 4,4 | ForEach-Object { $_.ToString() } | Out-File $out -Append -Encoding utf8
"== config.txt: propbits / slot (context 3)" | Out-File $out -Append -Encoding utf8
Select-String -Path (Join-Path $ses 'config.txt') -Pattern 'propbit|slot|medal' -Context 3,3 | ForEach-Object { $_.ToString() } | Out-File $out -Append -Encoding utf8
"== logic_hero.lua: slot / on_body (context 2)" | Out-File $out -Append -Encoding utf8
Select-String -Path (Join-Path $ses 'logic_hero.lua') -Pattern 'slot|on_body' -Context 2,2 | ForEach-Object { $_.ToString() } | Out-File $out -Append -Encoding utf8
Write-Host "Done: $out"
