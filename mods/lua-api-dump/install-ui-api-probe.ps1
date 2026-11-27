param([Parameter(Mandatory=$true)][string]$GameDir)
$ErrorActionPreference = 'Stop'
$game = [IO.Path]::GetFullPath($GameDir).TrimEnd('\')
if ((Split-Path -Leaf (Split-Path -Parent $game)) -ne 'KB_test_copy' -or (Split-Path -Leaf $game) -ne 'KB The Legend EE') { throw 'Safety stop: only KB_test_copy is accepted.' }
$lua = Join-Path $game 'sessions\base\ses\logic_hero.lua'
if (-not (Test-Path -LiteralPath $lua)) { throw "Not found: $lua" }
$enc = [Text.Encoding]::GetEncoding(28591)
$s = $enc.GetString([IO.File]::ReadAllBytes($lua))
$old = 'local terms = {"item", "artifact", "artefact", "equip", "slot", "inventory", "medal", "reward"}'
$new = 'local terms = {"item", "artifact", "artefact", "equip", "slot", "inventory", "medal", "reward", "form", "ui", "window", "dialog", "msg", "gui", "open", "show", "push"}'
if (-not $s.Contains($old)) {
  if ($s.Contains($new)) { Write-Host 'UI API probe already installed.'; exit 0 }
  throw 'Expected APIPROBE filter not found. Nothing changed.'
}
$backup = "$lua.kb2026uiprobe.bak"
if (Test-Path -LiteralPath $backup) { throw "Backup already exists: $backup. Nothing changed." }
$needle = 'local namespaces = {"Game", "Logic", "Obj", "Bonus", "Hero"}'
$replacement = @'
local namespaces = {"Game", "Logic", "Obj", "Bonus", "Hero", "Scenario", "Action", "UI", "GUI", "Form", "Forms"}
    add("GLOBAL_UI_API=[" .. selected_names(_G, {"form", "ui", "window", "dialog", "msg", "gui", "open", "show", "push"}) .. "]")
'@
if (-not $s.Contains($needle)) { throw 'Namespace list not found. Nothing changed.' }
Copy-Item -LiteralPath $lua -Destination $backup
$s = $s.Replace($old,$new).Replace($needle,$replacement.TrimEnd("`r","`n"))
[IO.File]::WriteAllBytes($lua,$enc.GetBytes($s))
Write-Host "Installed UI API probe. Backup: $backup"
Write-Host 'Restart game, load the current test save, open any chest once, and send all APIPROBE pages.'

