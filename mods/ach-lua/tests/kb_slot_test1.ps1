# KB_2026 slot test #1 (agent 1): can hero slot 13 accept the test medal?
# Slots 13..18 get type "artefact" (existing type), medal_test_ok gets propbits=artefact.
# Needs: medal-slots-ui hero.ui (slots 13..18) and medal_test_ok item already installed. Run as ADMIN. Undo: -Undo
param([switch]$Undo)
$g = 'C:\Program Files (x86)\Blefonix Studios\KB The Legend EE'
$ses = Join-Path $g 'sessions\base\ses'
$hf = Join-Path $ses 'hero.txt'; $itf = Join-Path $ses 'items.txt'
$hb = $hf + '.kb2026slot.bak'; $ib = $itf + '.kb2026slot.bak'
if ($Undo) {
  if (Test-Path $hb) { Copy-Item $hb $hf -Force; Write-Host 'hero.txt restored' }
  if (Test-Path $ib) { Copy-Item $ib $itf -Force; Write-Host 'items.txt restored' }
  return
}
if (-not (Test-Path $hb)) { Copy-Item $hf $hb }
if (-not (Test-Path $ib)) { Copy-Item $itf $ib }
$enc = [Text.Encoding]::Default
$h = [IO.File]::ReadAllText($hf, $enc)
if ($h.Contains('13=artefact')) { Write-Host 'hero.txt: already patched' } else {
  $add = "      4=boots`r`n      13=artefact`r`n      14=artefact`r`n      15=artefact`r`n      16=artefact`r`n      17=artefact`r`n      18=artefact"
  $n = ([regex]::Matches($h, '      4=boots')).Count
  $h = $h.Replace('      4=boots', $add)
  [IO.File]::WriteAllText($hf, $h, $enc)
  Write-Host "hero.txt: slots 13..18 added in $n class blocks"
}
$t = [IO.File]::ReadAllText($itf, $enc)
$i = $t.IndexOf('medal_test_ok {')
if ($i -lt 0) { Write-Host 'medal_test_ok not found'; return }
$blk = $t.Substring($i).Replace('propbits=quest', 'propbits=artefact')
[IO.File]::WriteAllText($itf, $t.Substring(0, $i) + $blk, $enc)
Write-Host 'items.txt: medal_test_ok propbits=artefact'
Write-Host 'Now start a NEW game, open hero window, drag the medal to slots 13..18 (right of the wife block).'
