<#
.SYNOPSIS
  ONE script for the whole OWNER_TODO morning run. Result: ONE zip on the Desktop.

.DESCRIPTION
  Run it once. It does, in order (every step is isolated: one failure does not stop the rest):
    1. Finds the games folder and The Legend EE (read only).
    2. Read-only pack (T-01, T-11, T-12, T-14): runs tools\Get-KBOwnerPack.ps1.
    3. Texture inventory (T-16): header-only scan of Legend textures -> tex_inventory\ (no Python needed).
    4. Snapshot of your MAIN game: ini files, data\mods list, leftovers of the frozen v7 mod, PC info.
    5. TEST COPY of The Legend EE (about 6 GB, asked first). Your main game is NEVER modified.
    6. Installs the current trial mods into the COPY: achievements-test, ach-lua (Lua medals), UI v6 + loading ring (T-07),
       map-stats-test (T-08), medal-slots-ui (T-09).
    7. Starts the copy of the game, shows a short checklist, takes screenshots (8 s countdown),
       asks short questions (y/n/text) and writes results.txt.
    8. Optional graphics round (T-10 / T-18) on the copy via mods\gfx-preset level 2 (game.ini backup, restored after).
    9. Packs everything into Desktop\kb_morning_pack.zip.
  Not covered (needs extra tools): T-17 texture upscale. Q-01, Q-03, Q-05, Q-06, Q-07: answer in chat.

.PARAMETER GamesRoot     Folder with the game folders. Default: auto-detect (current folder, Blefonix Studios, GOG Games).
.PARAMETER TestCopyRoot  Where to put the test copy. Default: Desktop\KB_test_copy.
.PARAMETER OutDir        Work folder for results. Default: Desktop\kb_morning_<date_time>.
.PARAMETER NoCopy        Only read-only steps (1-4). No copy, no mods, no game start.
.PARAMETER NoGame        Make the copy and install mods, but do not start the game and do not ask questions.
.PARAMETER Auto          No prompts at all (self-test). Implies -NoGame.
.PARAMETER SkipTextures  Skip the texture inventory (saves several minutes).
.PARAMETER WithProbe     Install mods\lua-probe instead of mods\ach-lua (they exclude each other).
.PARAMETER WithSlotsTest Also install mods\medal-slots-test (start medal in the backpack; already confirmed by agent 1).

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File "<repo>\tools\Run-KBMorning.ps1"
#>
[CmdletBinding()]
param(
    [string]$GamesRoot = '',
    [string]$TestCopyRoot = '',
    [string]$OutDir = '',
    [switch]$NoCopy,
    [switch]$NoGame,
    [switch]$Auto,
    [switch]$SkipTextures,
    [switch]$WithProbe,
    [switch]$WithSlotsTest
)

$ErrorActionPreference = 'Stop'
if ($Auto) { $NoGame = $true }
$script:Start = Get-Date
$script:Problems = New-Object System.Collections.Generic.List[string]
$script:Results = New-Object System.Collections.Generic.List[string]
$script:LogFile = $null
$script:Legend = $null
$script:CopyGame = $null
$script:ModDst = $null
$script:ShotDir = $null
$script:ModsOk = @{}
$script:IconDir = $null
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

# ---------------------------------------------------------------- helpers
function Say([string]$t = '', [string]$c = 'Gray') {
    Write-Host $t -ForegroundColor $c
    if ($script:LogFile) { try { Add-Content -LiteralPath $script:LogFile -Value $t -Encoding UTF8 } catch { } }
}
function Step([string]$name, [scriptblock]$body) {
    Say ''
    Say ('=== ' + $name + ' ===') 'Cyan'
    try { & $body }
    catch {
        $m = $name + ' FAILED: ' + $_.Exception.Message
        $script:Problems.Add($m)
        Say $m 'Red'
        try { Add-Content -LiteralPath $script:LogFile -Value ($_.ScriptStackTrace) -Encoding UTF8 } catch { }
    }
}
function Ask([string]$q, [string]$def = '') {
    if ($Auto -or $NoGame) { return $def }
    $a = Read-Host $q
    if ([string]::IsNullOrWhiteSpace($a)) { return $def }
    return $a.Trim()
}
function AskYN([string]$q, [bool]$defYes = $true) {
    if ($Auto) { return $defYes }
    $hint = '[Y/n]'
    if (-not $defYes) { $hint = '[y/N]' }
    $a = Read-Host ($q + ' ' + $hint)
    if ([string]::IsNullOrWhiteSpace($a)) { return $defYes }
    return ($a.Trim().ToLower() -match '^(y|yes|d|da|\u0434)')
}
function Rec([string]$id, [string]$text) {
    $script:Results.Add($id + ' : ' + $text)
    Say ('  -> ' + $id + ' : ' + $text) 'Green'
}
function Pause-Enter([string]$msg) {
    if ($Auto -or $NoGame) { return }
    Read-Host $msg | Out-Null
}
function Get-Desktop {
    $d = ''
    try { $d = [Environment]::GetFolderPath('Desktop') } catch { }
    if ([string]::IsNullOrWhiteSpace($d) -or -not (Test-Path -LiteralPath $d)) { $d = (Get-Location).Path }
    return $d
}
function Run-Child([string]$file, [string[]]$arguments, [string]$logName) {
    $psExe = (Get-Process -Id $PID).Path
    $all = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $file) + $arguments
    $out = & $psExe @all 2>&1 | Out-String
    $code = $LASTEXITCODE
    $lp = Join-Path $script:OutPath $logName
    Set-Content -LiteralPath $lp -Value $out -Encoding UTF8
    Say ($out.TrimEnd())
    return $code
}
function Test-IsLegend([string]$d) {
    return ((Test-Path -LiteralPath (Join-Path $d 'kb.exe')) -and ((Split-Path -Leaf $d) -match 'legend'))
}
function Find-LegendIn([string]$root) {
    if (-not (Test-Path -LiteralPath $root)) { return $null }
    if (Test-IsLegend $root) { return $root }
    foreach ($d in @(Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue)) {
        if (Test-IsLegend $d.FullName) { return $d.FullName }
    }
    return $null
}
function Copy-Tree([string]$src, [string]$dst) {
    New-Item -ItemType Directory -Force -Path $dst | Out-Null
    if (Get-Command robocopy -ErrorAction SilentlyContinue) {
        & robocopy $src $dst /E /R:1 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null
        if ($LASTEXITCODE -ge 8) { throw ('robocopy failed, code ' + $LASTEXITCODE) }
    } else {
        Copy-Item -Path (Join-Path $src '*') -Destination $dst -Recurse -Force
    }
}
function Take-Shot([string]$name) {
    if ($Auto -or $NoGame) { return }
    if ($env:OS -ne 'Windows_NT') { Say 'Screenshots are Windows-only; skipped.' 'Yellow'; return }
    try {
        Say 'Switch to the game window now. Screenshot in 8 seconds...' 'Yellow'
        foreach ($i in 8..1) { Write-Host -NoNewline ($i.ToString() + ' '); Start-Sleep -Seconds 1 }
        Write-Host ''
        $p = Join-Path $script:ShotDir ($name + '.png')
        # kept as text and run with Invoke-Expression so the drawing types are only touched on Windows
        $code = @'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$b = [Windows.Forms.SystemInformation]::VirtualScreen
$bmp = New-Object Drawing.Bitmap $b.Width, $b.Height
$g = [Drawing.Graphics]::FromImage($bmp)
$g.CopyFromScreen($b.Left, $b.Top, 0, 0, $bmp.Size)
$bmp.Save($p, [Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
'@
        Invoke-Expression $code
        Say ('saved: ' + $p) 'Green'
    } catch {
        $script:Problems.Add('screenshot ' + $name + ': ' + $_.Exception.Message)
        Say ('Screenshot failed (' + $_.Exception.Message + '). Make it by hand (Win+PrtScn); the script also picks up new files from Pictures\Screenshots.') 'Yellow'
    }
}

# ---------------------------------------------------------------- texture inventory helpers (T-16)
function Read-Head([IO.Stream]$s, [int]$n) {
    $buf = New-Object byte[] $n
    $r = 0
    while ($r -lt $n) {
        $k = $s.Read($buf, $r, $n - $r)
        if ($k -le 0) { break }
        $r += $k
    }
    if ($r -lt $n) {
        $b2 = New-Object byte[] $r
        [Array]::Copy($buf, $b2, $r)
        return , $b2
    }
    return , $buf
}
function Parse-Tex([string]$ext, [byte[]]$b) {
    if ($ext -eq '.dds') {
        if ($b.Length -lt 128 -or $b[0] -ne 0x44 -or $b[1] -ne 0x44 -or $b[2] -ne 0x53 -or $b[3] -ne 0x20) { return $null }
        $h = [BitConverter]::ToUInt32($b, 12); $w = [BitConverter]::ToUInt32($b, 16); $mips = [BitConverter]::ToUInt32($b, 28)
        $pf = [BitConverter]::ToUInt32($b, 80)
        $fc = ([Text.Encoding]::ASCII.GetString($b, 84, 4)).Trim([char]0)
        $bits = [BitConverter]::ToUInt32($b, 88)
        if (($pf -band 4) -ne 0) {
            $fmt = $fc
            if ($fc -eq 'DX10' -and $b.Length -ge 132) { $fmt = 'DXGI' + [BitConverter]::ToUInt32($b, 128) }
            $alpha = ($fmt -in @('DXT2', 'DXT3', 'DXT4', 'DXT5'))
        } else {
            if (($pf -band 1) -ne 0) { $fmt = 'RGBA' + $bits; $alpha = $true } else { $fmt = 'RGB' + $bits; $alpha = $false }
        }
        if ($mips -lt 1) { $mips = 1 }
        return @{ w = $w; h = $h; mips = $mips; fmt = $fmt; alpha = $alpha }
    }
    if ($ext -eq '.png') {
        if ($b.Length -lt 26 -or $b[0] -ne 0x89 -or $b[1] -ne 0x50) { return $null }
        $w = ([int]$b[16] * 16777216) + ([int]$b[17] * 65536) + ([int]$b[18] * 256) + [int]$b[19]
        $h = ([int]$b[20] * 16777216) + ([int]$b[21] * 65536) + ([int]$b[22] * 256) + [int]$b[23]
        $ct = $b[25]
        return @{ w = $w; h = $h; mips = 1; fmt = 'PNG'; alpha = (($ct -eq 4) -or ($ct -eq 6)) }
    }
    if ($ext -eq '.tga') {
        if ($b.Length -lt 18) { return $null }
        $w = [BitConverter]::ToUInt16($b, 12); $h = [BitConverter]::ToUInt16($b, 14); $bpp = $b[16]
        return @{ w = $w; h = $h; mips = 1; fmt = ('TGA' + $bpp); alpha = ($bpp -eq 32) }
    }
    return $null
}
function Classify-Tex([string]$path) {
    $p = $path.ToLower()
    $n = $p.Substring([Math]::Max($p.LastIndexOfAny([char[]]@('/', '\')) + 1, 0))
    if ($p -match 'interface_textures') { return 'ui' }
    if ($p -match 'sky\.kfs') { return 'sky' }
    if ($n -match '^(fx|fxm)' -or $n -match '_fx\b' -or $n -match 'particle') { return 'fx' }
    if ($n.EndsWith('_spec.dds')) { return 'spec' }
    if ($n -match '(_mask|_bump|_height|_h)\.dds$') { return 'data' }
    if ($n -match '^(water|dxt)' -or $n -match 'cube' -or $n -match 'checkboard') { return 'special' }
    if ($n.EndsWith('_diff.dds')) { return 'diffuse' }
    return 'other'
}
function Get-TextureInventory([string]$root, [string]$outDir) {
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
    $rows = New-Object System.Collections.Generic.List[object]
    $texExt = @('.dds', '.png', '.tga')
    $files = @(Get-ChildItem -LiteralPath $root -Recurse -File -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension.ToLower() -in @('.dds', '.png', '.tga', '.kfs') })
    Say ('  candidate files: ' + $files.Count)
    $n = 0
    foreach ($f in $files) {
        $n++
        if (($n % 200) -eq 0) { Say ('  ... ' + $n + ' / ' + $files.Count) }
        $rel = $f.FullName.Substring($root.Length).TrimStart('\', '/')
        $ext = $f.Extension.ToLower()
        if ($ext -eq '.kfs') {
            $z = $null
            try { $z = [IO.Compression.ZipFile]::OpenRead($f.FullName) } catch { continue }
            try {
                foreach ($e in $z.Entries) {
                    $ie = [IO.Path]::GetExtension($e.FullName).ToLower()
                    if ($ie -notin $texExt) { continue }
                    $st = $null
                    try {
                        $st = $e.Open()
                        $head = Read-Head $st 200
                        $info = Parse-Tex $ie $head
                        if ($info) {
                            $p = $rel + '!/' + $e.FullName
                            $rows.Add([pscustomobject]@{ path = $p; class = (Classify-Tex $p); w = $info.w; h = $info.h; mips = $info.mips; fmt = $info.fmt; alpha = [int]$info.alpha; bytes = $e.Length })
                        }
                    } catch { } finally { if ($st) { $st.Dispose() } }
                }
            } finally { $z.Dispose() }
        } else {
            $fs = $null
            try {
                $fs = [IO.File]::OpenRead($f.FullName)
                $head = Read-Head $fs 200
                $info = Parse-Tex $ext $head
                if ($info) {
                    $rows.Add([pscustomobject]@{ path = $rel; class = (Classify-Tex $rel); w = $info.w; h = $info.h; mips = $info.mips; fmt = $info.fmt; alpha = [int]$info.alpha; bytes = $f.Length })
                }
            } catch { } finally { if ($fs) { $fs.Dispose() } }
        }
    }
    $rows | Export-Csv -LiteralPath (Join-Path $outDir 'inventory.csv') -NoTypeInformation -Encoding UTF8
    $L = New-Object System.Collections.Generic.List[string]
    $L.Add('# Texture inventory (' + $rows.Count + ' files)')
    $L.Add('')
    $L.Add('| class | files | MB | median max side |')
    $L.Add('|---|---|---|---|')
    foreach ($g in ($rows | Group-Object class | Sort-Object { - ($_.Group | Measure-Object bytes -Sum).Sum })) {
        $mb = [Math]::Round((($g.Group | Measure-Object bytes -Sum).Sum) / 1MB, 0)
        $sides = @($g.Group | ForEach-Object { [Math]::Max($_.w, $_.h) } | Sort-Object)
        $L.Add('| ' + $g.Name + ' | ' + $g.Count + ' | ' + $mb + ' | ' + $sides[[int][Math]::Floor($sides.Count / 2)] + ' |')
    }
    $L.Add('')
    $L.Add('## DDS formats')
    foreach ($g in ($rows | Where-Object { $_.path -match '\.dds$' } | Group-Object fmt | Sort-Object Count -Descending)) { $L.Add('- ' + $g.Name + ': ' + $g.Count) }
    $cand = @($rows | Where-Object { ($_.class -eq 'diffuse' -or $_.class -eq 'other') -and ([Math]::Max($_.w, $_.h) -le 1024) })
    $big = [Math]::Round((($cand | Measure-Object bytes -Sum).Sum) / 1MB, 0)
    $L.Add('')
    $L.Add('## Upscale estimate')
    $L.Add('Candidates (diffuse/other, side <= 1024): ' + $cand.Count + ' files, ' + $big + ' MB. x2 upscale is about x4 in size: ' + (4 * $big) + ' MB. The game is 32-bit: start with a subset.')
    Set-Content -LiteralPath (Join-Path $outDir 'SUMMARY.md') -Value ($L -join "`r`n") -Encoding UTF8
    Say ('  textures: ' + $rows.Count + ' -> ' + $outDir)
}

# ---------------------------------------------------------------- start: paths, log
$repo = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path -LiteralPath (Join-Path $repo 'mods'))) { throw ('Repo root not found next to tools\: ' + $repo) }
$desk = Get-Desktop
$stamp = $script:Start.ToString('yyyyMMdd_HHmm')
if ([string]::IsNullOrWhiteSpace($OutDir)) { $OutDir = Join-Path $desk ('kb_morning_' + $stamp) }
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$script:OutPath = (Resolve-Path -LiteralPath $OutDir).Path
$script:LogFile = Join-Path $script:OutPath 'run.log'
$script:ShotDir = Join-Path $script:OutPath 'screens'
New-Item -ItemType Directory -Force -Path $script:ShotDir | Out-Null
if ([string]::IsNullOrWhiteSpace($TestCopyRoot)) { $TestCopyRoot = Join-Path $desk 'KB_test_copy' }

Say '=========================================================' 'White'
Say ' KB_2026 morning run: one script, one zip' 'White'
Say ('  repo   : ' + $repo)
Say ('  output : ' + $script:OutPath)
Say ('  PS     : ' + $PSVersionTable.PSVersion + '   time: ' + $script:Start)
Say '  Your MAIN game is never modified. Mods go to a COPY.' 'Gray'
Say '=========================================================' 'White'

# ---------------------------------------------------------------- 1. find games
Step '1. Find games' {
    $cands = @($GamesRoot, (Get-Location).Path, 'C:\Program Files (x86)\Blefonix Studios', 'C:\Program Files\Blefonix Studios',
        'C:\GOG Games', 'D:\GOG Games', 'D:\Games\KB', 'D:\Games') | Where-Object { $_ -and (Test-Path -LiteralPath $_) }
    foreach ($c in $cands) {
        $l = Find-LegendIn $c
        if ($l) {
            $script:Legend = $l
            if (Test-IsLegend $c) { $script:Root = Split-Path -Parent $c } else { $script:Root = $c }
            break
        }
    }
    if (-not $script:Legend -and -not $Auto) {
        $p = Read-Host 'Games folder not found. Paste the path of the folder that contains "KB The Legend EE"'
        $p = $p.Trim('"').Trim()
        $l = Find-LegendIn $p
        if ($l) { $script:Legend = $l; if (Test-IsLegend $p) { $script:Root = Split-Path -Parent $p } else { $script:Root = $p } }
    }
    if (-not $script:Legend) { throw 'The Legend EE folder (with kb.exe) not found. Run again with -GamesRoot "<folder>".' }
    Say ('  games root : ' + $script:Root)
    Say ('  Legend EE  : ' + $script:Legend)
    foreach ($d in @(Get-ChildItem -LiteralPath $script:Root -Directory -ErrorAction SilentlyContinue)) { Say ('    - ' + $d.Name) }
}
if (-not $script:Legend) {
    Say 'Cannot continue without Legend EE.' 'Red'
}

# ---------------------------------------------------------------- 2. read-only pack
if ($script:Legend) {
    Step '2. Read-only pack (T-01, T-11, T-12, T-14)' {
        $packScript = Join-Path $PSScriptRoot 'Get-KBOwnerPack.ps1'
        if (-not (Test-Path -LiteralPath $packScript)) { throw 'tools\Get-KBOwnerPack.ps1 not found' }
        $packDir = Join-Path $script:OutPath 'owner_pack'
        $code = Run-Child $packScript @('-GamesRoot', $script:Root, '-OutDir', $packDir) 'owner_pack_log.txt'
        if ($code -ne 0) { $script:Problems.Add('Get-KBOwnerPack exit code ' + $code) }
        $png = Join-Path $packDir 'png'
        if (Test-Path -LiteralPath $png) {
            $ic = @(Get-ChildItem -LiteralPath $png -Recurse -File -Filter 'heroitem_achievement_mental_madman*.png' -ErrorAction SilentlyContinue)
            if ($ic.Count -gt 0) {
                $icDir = Join-Path $script:OutPath 'icons_for_install'
                New-Item -ItemType Directory -Force -Path $icDir | Out-Null
                foreach ($i in $ic) { Copy-Item -LiteralPath $i.FullName -Destination $icDir -Force }
                $script:IconDir = $icDir
                Say ('  medal icon found in the pack, will be used for achievements-test: ' + $ic.Count + ' file(s)')
            }
        }
        $dupZip = Join-Path $script:OutPath 'kb_owner_pack.zip'
        if (Test-Path -LiteralPath $dupZip) { Remove-Item -LiteralPath $dupZip -Force }
    }
}

# ---------------------------------------------------------------- 3. textures
if ($script:Legend -and -not $SkipTextures) {
    Step '3. Texture inventory (T-16)' {
        Get-TextureInventory $script:Legend (Join-Path $script:OutPath 'tex_inventory')
    }
}

# ---------------------------------------------------------------- 4. snapshot of main game
if ($script:Legend) {
    Step '4. Snapshot of the main game (read only)' {
        $snap = Join-Path $script:OutPath 'main_game'
        New-Item -ItemType Directory -Force -Path $snap | Out-Null
        $info = New-Object System.Collections.Generic.List[string]
        $info.Add('date: ' + (Get-Date))
        $info.Add('powershell: ' + $PSVersionTable.PSVersion)
        try { $os = Get-CimInstance Win32_OperatingSystem; $info.Add('os: ' + $os.Caption + ' ' + $os.Version) } catch { $info.Add('os: n/a') }
        try { $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1; $info.Add('cpu: ' + $cpu.Name) } catch { }
        try { $ram = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory; $info.Add('ram_gb: ' + [Math]::Round($ram / 1GB, 1)) } catch { }
        try { foreach ($v in @(Get-CimInstance Win32_VideoController)) { $info.Add('gpu: ' + $v.Name + ' driver ' + $v.DriverVersion + ' ' + $v.CurrentHorizontalResolution + 'x' + $v.CurrentVerticalResolution) } } catch { }
        try { $k = Get-Item -LiteralPath (Join-Path $script:Legend 'kb.exe'); $info.Add('kb.exe: ' + $k.Length + ' bytes, ' + $k.LastWriteTime + ', version ' + $k.VersionInfo.FileVersion) } catch { }
        Set-Content -LiteralPath (Join-Path $snap 'system.txt') -Value ($info -join "`r`n") -Encoding UTF8
        # small config files
        $names = @('game.ini', 'default.ini', 'app.ini', 'camera.txt', 'resolutions.txt', 'forms.txt')
        $cfgDir = Join-Path $snap 'configs'
        New-Item -ItemType Directory -Force -Path $cfgDir | Out-Null
        foreach ($f in @(Get-ChildItem -LiteralPath $script:Legend -Recurse -File -Force -ErrorAction SilentlyContinue | Where-Object { $names -contains $_.Name.ToLower() -and $_.Length -lt 1MB })) {
            $rel = $f.FullName.Substring($script:Legend.Length).TrimStart('\', '/')
            $flat = ($rel -replace '[\\/:]', '__')
            Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $cfgDir $flat) -Force
        }
        # data\mods list
        $modsDir = Join-Path $script:Legend 'data\mods'
        if (Test-Path -LiteralPath $modsDir) {
            $l = @(Get-ChildItem -LiteralPath $modsDir -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName.Substring($modsDir.Length).TrimStart('\', '/') + '  ' + $_.Length + '  ' + $_.LastWriteTime })
            Set-Content -LiteralPath (Join-Path $snap 'data_mods_list.txt') -Value $l -Encoding UTF8
            $left = @($l | Where-Object { $_ -match 'hero\.ui|achievements_|new_achievement_' })
            if ($left.Count -gt 0) { Say ('  leftovers of the frozen v7 mod found in the MAIN game mods folder: ' + $left.Count + ' file(s) (see main_game\data_mods_list.txt)') 'Yellow' }
        }
        Say ('  snapshot -> ' + $snap)
    }
}

# ---------------------------------------------------------------- 5. test copy
if ($script:Legend -and -not $NoCopy) {
    Step '5. Test copy of The Legend EE' {
        $dst = Join-Path $TestCopyRoot (Split-Path -Leaf $script:Legend)
        $have = (Test-Path -LiteralPath (Join-Path $dst 'kb.exe'))
        if ($have) {
            Say ('  copy already exists: ' + $dst)
            if (-not (AskYN '  Reuse it (mods are re-installed safely)?' $true)) { throw 'Copy exists and you chose not to reuse it. Delete the folder or use -TestCopyRoot.' }
        } else {
            $sizeGb = 0
            try { $sizeGb = [Math]::Round(((Get-ChildItem -LiteralPath $script:Legend -Recurse -File -Force | Measure-Object Length -Sum).Sum) / 1GB, 1) } catch { }
            Say ('  size of the game: about ' + $sizeGb + ' GB; target: ' + $dst)
            try {
                New-Item -ItemType Directory -Force -Path $TestCopyRoot | Out-Null
                $drv = New-Object IO.DriveInfo ([IO.Path]::GetPathRoot((Resolve-Path -LiteralPath $TestCopyRoot).Path))
                $freeGb = [Math]::Round($drv.AvailableFreeSpace / 1GB, 1)
                Say ('  free space there: ' + $freeGb + ' GB')
                if ($sizeGb -gt 0 -and $freeGb -lt ($sizeGb + 2)) { throw ('Not enough free space (' + $freeGb + ' GB). Use -TestCopyRoot "<other drive>\KB_test_copy".') }
            } catch { if ($_.Exception.Message -like 'Not enough*') { throw } }
            if (-not (AskYN ('  Create the test copy now (copy takes a few minutes)?') $true)) { throw 'Test copy declined; steps 6-8 skipped.' }
            Say '  copying... (please wait)'
            Copy-Tree $script:Legend $dst
        }
        if (-not (Test-Path -LiteralPath (Join-Path $dst 'kb.exe'))) { throw 'kb.exe not found in the copy' }
        $script:CopyGame = $dst
        Say ('  test copy ready: ' + $dst) 'Green'
    }
}

# ---------------------------------------------------------------- 6. install mods into the copy
if ($script:CopyGame) {
    Step '6. Install trial mods into the COPY' {
        $logDir = Join-Path $script:OutPath 'install_logs'
        New-Item -ItemType Directory -Force -Path $logDir | Out-Null
        $list = @('achievements-test')
        if ($WithProbe) { $list += 'lua-probe' } else { $list += 'ach-lua' }
        if ($WithSlotsTest) { $list += 'medal-slots-test' }
        foreach ($m in $list) {
            $inst = Join-Path (Join-Path (Join-Path $repo 'mods') $m) 'install.ps1'
            if (($m -eq 'medal-slots-test' -or $m -eq 'ach-lua') -and -not $script:ModsOk['achievements-test']) {
                Say ('  skip ' + $m + ' (needs achievements-test)') 'Yellow'; $script:Problems.Add($m + ' skipped: achievements-test not installed'); continue
            }
            if (-not (Test-Path -LiteralPath $inst)) { $script:Problems.Add($m + ': install.ps1 not found'); continue }
            if ($m -eq 'ach-lua') {
                # ach-lua refuses to install over lua-probe: remove the probe from the COPY first if the copy has it
                $lua = Join-Path $script:CopyGame 'sessions\base\ses\logic_hero.lua'
                if (Test-Path -LiteralPath $lua) {
                    $txt = [Text.Encoding]::GetEncoding(28591).GetString([IO.File]::ReadAllBytes($lua))
                    if ($txt.Contains('kb2026_probe')) {
                        Say '  lua-probe is in the copy: removing it first (ach-lua replaces it)'
                        $un = Join-Path (Join-Path (Join-Path $repo 'mods') 'lua-probe') 'uninstall.ps1'
                        [void](Run-Child $un @('-GameDir', $script:CopyGame) 'install_logs\lua-probe_uninstall.txt')
                    }
                }
            }
            Say ('  installing ' + $m + ' ...')
            $iargs = @('-GameDir', $script:CopyGame)
            if ($m -eq 'achievements-test' -and $script:IconDir) { $iargs += @('-IconDir', $script:IconDir) }
            $code = Run-Child $inst $iargs ('install_logs\' + $m + '.txt')
            if ($code -eq 0) { $script:ModsOk[$m] = $true; Say ('  ' + $m + ': OK') 'Green' }
            else { $script:ModsOk[$m] = $false; $script:Problems.Add($m + ' install exit code ' + $code); Say ('  ' + $m + ': FAILED (see install_logs)') 'Red' }
        }

        # 32:9 UI mod folder in the copy: clean v6 + loading ring fix, then trial UI files
        $modsRoot = Join-Path $script:CopyGame 'data\mods'
        New-Item -ItemType Directory -Force -Path $modsRoot | Out-Null
        $existing = @(Get-ChildItem -LiteralPath $modsRoot -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^(16|32)_9-nsf$' })
        if ($existing.Count -gt 0) { $dstMod = $existing[0].FullName } else { $dstMod = Join-Path $modsRoot '32_9-nsf' }
        New-Item -ItemType Directory -Force -Path $dstMod | Out-Null
        $script:ModDst = $dstMod
        Say ('  UI mod folder in the copy: ' + $dstMod)
        foreach ($f in @(Get-ChildItem -LiteralPath $dstMod -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^(hero\.ui|achievements_.*|new_achievement_.*)$' })) {
            Remove-Item -LiteralPath $f.FullName -Force
            Say ('  removed v7 leftover: ' + $f.Name)
        }
        $srcMod = Join-Path (Join-Path (Join-Path $repo 'mods') '32x9-ui') '32_9-nsf'
        if (Test-Path -LiteralPath $srcMod) {
            Copy-Item -Path (Join-Path $srcMod '*') -Destination $dstMod -Recurse -Force
            Say '  synced clean v6 UI files from the repo (includes the loading ring fix, T-07)'
        } else { $script:Problems.Add('mods\32x9-ui\32_9-nsf not found in the repo') }
        $heroUi = Join-Path (Join-Path (Join-Path $repo 'mods') 'medal-slots-ui') 'hero.ui'
        if (Test-Path -LiteralPath $heroUi) { Copy-Item -LiteralPath $heroUi -Destination (Join-Path $dstMod 'hero.ui') -Force; Say '  medal-slots-ui: hero.ui installed (T-09)' }
        else { $script:Problems.Add('mods\medal-slots-ui\hero.ui not found') }
        $mapUi = Join-Path (Join-Path (Join-Path $repo 'mods') 'map-stats-test') 'map_3360x945.ui'
        if (Test-Path -LiteralPath $mapUi) {
            $target = Join-Path $dstMod 'map_3360x945.ui'
            if ((Test-Path -LiteralPath $target) -and -not (Test-Path -LiteralPath ($target + '.bak'))) { Copy-Item -LiteralPath $target -Destination ($target + '.bak') }
            Copy-Item -LiteralPath $mapUi -Destination $target -Force
            Say '  map-stats-test: map_3360x945.ui installed (T-08)'
        } else { $script:Problems.Add('mods\map-stats-test\map_3360x945.ui not found') }
    }
}

# ---------------------------------------------------------------- 7. guided test
if ($script:CopyGame -and -not $NoGame) {
    Step '7. Guided test in the game COPY' {
        Say ''
        Say 'CHECKLIST (do in this order, then come back here):' 'White'
        Say '  1. Main menu -> NEW GAME (any class).' 'White'
        Say '  2. Open the HERO window. Look: do the six EMPTY gray slots right of the wife block cover important artwork?' 'White'
        Say '  3. Map: look at the bottom panel (grid of 4 x 6 test cells).' 'White'
        Say '  4. Start ONE battle and cast at least one spell (magic damage). After the battle open ANY chest/box on the map.' 'White'
        Say '     Expected (ach-lua): a message "Achievement: High Mage" and a test medal in the backpack (arrows under the inventory row).' 'White'
        Say '  5. Save, load, watch the loading screen ring. Look at the backpack again.' 'White'
        Say ''
        $exe = Join-Path $script:CopyGame 'kb.exe'
        if (AskYN 'Start the game COPY now?' $true) {
            try { Start-Process -FilePath $exe -WorkingDirectory $script:CopyGame } catch { $script:Problems.Add('could not start kb.exe: ' + $_.Exception.Message); Say 'Could not start the game; start it by hand from the copy folder.' 'Yellow' }
        }
        Pause-Enter 'When you are at the HERO window in the game, press Enter here (a screenshot follows after 8 s)'
        Take-Shot 'T04_T09_hero_window'
        Pause-Enter 'When the chest message (PROBE) is on the screen, press Enter (screenshot follows). If there is no message, just press Enter and switch to the map'
        Take-Shot 'T05_probe_or_map'
        Pause-Enter 'Show the bottom panel of the MAP, press Enter (screenshot follows)'
        Take-Shot 'T08_map_bottom_panel'
        Pause-Enter 'Finish the checklist (battle, save/load). Then press Enter here to answer short questions'

        Say ''
        Say 'QUESTIONS (Enter = skip / unknown):' 'White'
        Rec 'AL-1' ('ach-lua message after spell + chest: ' + (Ask '  AL-1: message "Achievement: High Mage" after a spell battle + opening a chest? (y/n/text)' '?'))
        Rec 'AL-2' ('test medal in backpack after that: ' + (Ask '  AL-2: a test medal appeared in the backpack? (y/n)' '?'))
        Rec 'AL-3' ('medal survives save/load: ' + (Ask '  AL-3: still in the backpack after save and load? (y/n)' '?'))
        Rec 'T-07' ('loading ring: ' + (Ask '  T-07: ring on the loading screen: ok / higher / lower (+ about how many px)' '?'))
        Rec 'T-08' ('map cells with values: ' + (Ask '  T-08: which cells of the map panel show a value (e.g. 1.1, 1.2)? or none' '?'))
        Rec 'T-09' ('medal slots cover the background: ' + (Ask '  T-09: do the 6 empty slots cover important artwork of the hero window? (y/n/describe)' '?'))
        Rec 'Q-01' ('easy difficulty effect: ' + (Ask '  Q-01: what exactly does the game show on easy difficulty: item flicker / minimap icons / hover hints / other?' '?'))
        Rec 'Q-02' ('medals visible in slots: ' + (Ask '  Q-02: how many medals visible: all earned / 6 chosen / other' '?'))
        Rec 'Q-06' ('medal bonus: ' + (Ask '  Q-06: medals: icon only, or also a small bonus (e.g. +leadership)? (icon/bonus/other)' '?'))
        Rec 'FPS-before' (Ask '  FPS on the map now (if you know; else blank)' '?')
        $note = Ask '  Anything else you noticed (one line)?' ''
        if ($note) { Rec 'note' $note }
    }
}

# ---------------------------------------------------------------- 8. graphics round (T-10)
if ($script:CopyGame -and -not $NoGame) {
    Step '8. Graphics round on the copy (T-10, optional)' {
        if (-not (AskYN 'Do the graphics round now (gfx-preset level 2: r_filter 5 + shadows; restored afterwards)?' $false)) { Say '  skipped'; return }
        $gi = Join-Path (Join-Path (Join-Path $repo 'mods') 'gfx-preset') 'install.ps1'
        $gu = Join-Path (Join-Path (Join-Path $repo 'mods') 'gfx-preset') 'uninstall.ps1'
        if (-not (Test-Path -LiteralPath $gi)) { throw 'mods\gfx-preset\install.ps1 not found' }
        $code = Run-Child $gi @('-GameDir', $script:CopyGame, '-Level', '2') 'install_logs\gfx-preset.txt'
        if ($code -ne 0) { throw ('gfx-preset install exit code ' + $code) }
        Say '  gfx-preset level 2 installed in the COPY (r_filter 5, shadows 2048, landscape shadows)'
        Say '  Close the game if it is running, start it again, load a save on the MAP.' 'White'
        try { Start-Process -FilePath (Join-Path $script:CopyGame 'kb.exe') -WorkingDirectory $script:CopyGame } catch { }
        Pause-Enter 'Map is visible, press Enter (screenshot follows)'
        Take-Shot 'T10_gfx_map'
        Pause-Enter 'In a battle on the arena, press Enter (screenshot follows)'
        Take-Shot 'T10_gfx_arena'
        Rec 'T-10-fps' ('FPS after: ' + (Ask '  FPS now (number) or blank' '?'))
        Rec 'T-10-look' ('visual difference: ' + (Ask '  Did textures/shadows look better, same, or worse? crashes?' '?'))
        [void](Run-Child $gu @('-GameDir', $script:CopyGame) 'install_logs\gfx-preset_uninstall.txt')
        Say '  game.ini of the copy restored.'
    }
}

# ---------------------------------------------------------------- 9. collect and zip
Step '9. Collect and pack' {
    # files changed in the copy since the run started (mods and game): small text files only
    if ($script:CopyGame) {
        $chg = New-Object System.Collections.Generic.List[string]
        $keep = Join-Path $script:OutPath 'changed_in_copy'
        New-Item -ItemType Directory -Force -Path $keep | Out-Null
        foreach ($f in @(Get-ChildItem -LiteralPath $script:CopyGame -Recurse -File -Force -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -ge $script:Start.AddMinutes(-1) })) {
            $rel = $f.FullName.Substring($script:CopyGame.Length).TrimStart('\', '/')
            $chg.Add($rel + '  ' + $f.Length + '  ' + $f.LastWriteTime)
            if ($f.Length -lt 1MB -and $f.Extension.ToLower() -in @('.txt', '.lua', '.lu', '.ini', '.log', '.ui', '.bak')) {
                $flat = ($rel -replace '[\\/:]', '__')
                try { Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $keep $flat) -Force } catch { }
            }
        }
        Set-Content -LiteralPath (Join-Path $script:OutPath 'changed_in_copy.txt') -Value $chg -Encoding UTF8
        Say ('  files changed in the copy: ' + $chg.Count)
    }
    # screenshots made by Win+PrtScn during the run
    try {
        $pic = [Environment]::GetFolderPath('MyPictures')
        $ss = Join-Path $pic 'Screenshots'
        if ($pic -and (Test-Path -LiteralPath $ss)) {
            $n = 0
            foreach ($f in @(Get-ChildItem -LiteralPath $ss -File -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -ge $script:Start -and $_.Length -lt 8MB } | Select-Object -First 20)) {
                Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $script:ShotDir ('winshot_' + $f.Name)) -Force; $n++
            }
            if ($n -gt 0) { Say ('  picked up ' + $n + ' screenshot(s) from Pictures\Screenshots') }
        }
    } catch { }
    # saves / logs listing (names only)
    try {
        $docs = [Environment]::GetFolderPath('MyDocuments')
        $lines = New-Object System.Collections.Generic.List[string]
        foreach ($p in @((Join-Path $docs 'My Games'), (Join-Path $docs 'Katauri'), (Join-Path $docs "King's Bounty"))) {
            if (Test-Path -LiteralPath $p) { foreach ($f in @(Get-ChildItem -LiteralPath $p -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 300)) { $lines.Add($f.FullName + '  ' + $f.Length + '  ' + $f.LastWriteTime) } }
        }
        if ($lines.Count -gt 0) { Set-Content -LiteralPath (Join-Path $script:OutPath 'documents_listing.txt') -Value $lines -Encoding UTF8 }
    } catch { }

    $r = New-Object System.Collections.Generic.List[string]
    $r.Add('KB_2026 morning run - ' + $script:Start)
    $r.Add('')
    $r.Add('## Answers')
    if ($script:Results.Count -eq 0) { $r.Add('(no questions were asked in this run)') } else { foreach ($x in $script:Results) { $r.Add($x) } }
    $r.Add('')
    $r.Add('## Mods installed into the copy')
    if ($script:ModsOk.Count -eq 0) { $r.Add('(none)') } else { foreach ($k in $script:ModsOk.Keys) { $r.Add($k + ': ' + $script:ModsOk[$k]) } }
    $r.Add('')
    $r.Add('## Problems')
    if ($script:Problems.Count -eq 0) { $r.Add('none') } else { foreach ($x in $script:Problems) { $r.Add('- ' + $x) } }
    Set-Content -LiteralPath (Join-Path $script:OutPath 'results.txt') -Value ($r -join "`r`n") -Encoding UTF8

    $zip = Join-Path (Split-Path -Parent $script:OutPath) 'kb_morning_pack.zip'
    if (Test-Path -LiteralPath $zip) { Remove-Item -LiteralPath $zip -Force }
    [IO.Compression.ZipFile]::CreateFromDirectory($script:OutPath, $zip)
    $mb = '{0:N2}' -f ((Get-Item -LiteralPath $zip).Length / 1MB)
    Say ''
    Say '=========================================================' 'White'
    Say ('  DONE. Send this file to the chat: ' + $zip + '  (' + $mb + ' MB)') 'Green'
    Say ('  Problems: ' + $script:Problems.Count + '  (listed in results.txt inside the zip)') 'Gray'
    if ($script:CopyGame) { Say ('  Test copy stays here: ' + $script:CopyGame + '  (delete the folder when you do not need it)') 'Gray' }
    Say '=========================================================' 'White'
}
