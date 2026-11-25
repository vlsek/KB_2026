<#
.SYNOPSIS
  One run = everything the agents ask for in OWNER_TODO block 1 (T-01, T-11, T-12). READ ONLY.

.DESCRIPTION
  Run ONCE in the folder that contains all game folders (for example
  C:\Program Files (x86)\Blefonix Studios). The script:
    1. finds the games by folder name (legend, crossworlds, red_sands, wotn, dark_side);
    2. T-11: copies small sample files (medals, rewards, records, achievements)
       from the game folders and from inside .kfs archives -> ref\<game>\;
    3. T-12: extracts interface icons (png) from interface_textures.kfs -> png\<game>\;
    4. T-01: searches The Legend (loose files and inside .kfs) for the difficulty / highlight
       words -> kb_find.txt;
    5. packs everything into ONE zip: kb_owner_pack.zip.
  Games are never modified. Needs only PowerShell (no Python). Windows PowerShell 5.1 or 7.

.PARAMETER GamesRoot  Folder with the game folders. Default: current folder.
.PARAMETER OutDir     Where to write. Default: Desktop\kb_owner_pack (or current folder if no Desktop).
.PARAMETER Names      File names to collect as samples (exact names, no path, case-insensitive). rus_*.lng give Russian names and conditions of medals.
.PARAMETER MaxMB      Skip sample files bigger than this. Default 4.
.PARAMETER FindPattern  Regex for the Legend search (T-01).
.PARAMETER Skip       Steps to skip: any of samples, icons, find.

.EXAMPLE
  cd "C:\Program Files (x86)\Blefonix Studios"
  powershell -ExecutionPolicy Bypass -File "<repo>\tools\Get-KBOwnerPack.ps1" -GamesRoot .
#>
[CmdletBinding()]
param(
    [string]$GamesRoot = (Get-Location).Path,
    [string]$OutDir = '',
    [string[]]$Names = @('addon_rewards.lua', 'medals.txt', 'records.txt', 'records_score_calc.txt',
        'achievements.txt', 'achievement_large_entourage.lu',
        'rus_items.lng', 'rus_rewards.lng', 'rus_records.lng'),
    [double]$MaxMB = 4,
    [string]$FindPattern = 'difficult|hardness|diff_level|highlight|show_?item|item_?hint|map_?hint',
    [ValidateSet('samples', 'icons', 'find')][string[]]$Skip = @()
)

$ErrorActionPreference = 'Stop'
$sw = [System.Diagnostics.Stopwatch]::StartNew()
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Say([string]$t = '', [ConsoleColor]$c = 'Gray') { Write-Host $t -ForegroundColor $c }

function Get-GameId([string]$folderName) {
    $n = $folderName.ToLower()
    if ($n -match 'dark\s*side|dark_side') { return 'dark_side' }
    if ($n -match 'north|wotn') { return 'wotn' }
    if ($n -match 'crimson|sands|red_sands|red\s*sands') { return 'red_sands' }
    if ($n -match 'cross') { return 'crossworlds' }
    if ($n -match 'armored|princess') { return 'armored_princess' }
    if ($n -match 'legend|bounty') { return 'legend' }
    $id = ($n -replace '[^a-z0-9]+', '_').Trim('_')
    if (-not $id) { $id = 'game' }
    return $id
}

function Get-SafeName([string]$s) { return (($s -replace '!/', '__') -replace '[\\/:*?"<>|]', '__') }

# ---- setup
$GamesRoot = (Resolve-Path -LiteralPath $GamesRoot).Path.TrimEnd('\', '/')
if (-not $OutDir) {
    $desk = [Environment]::GetFolderPath('Desktop')
    if (-not $desk) { $desk = (Get-Location).Path }
    $OutDir = Join-Path $desk 'kb_owner_pack'
}
if (Test-Path -LiteralPath $OutDir) { Remove-Item -LiteralPath $OutDir -Recurse -Force }
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$OutDir = (Resolve-Path -LiteralPath $OutDir).Path

Say ''
Say '  +----------------------------------------------------------+' Cyan
Say '  |  KB_2026  -  owner pack (T-01 / T-11 / T-12), read-only   |' Cyan
Say '  +----------------------------------------------------------+' Cyan
Say ''
Say ("  Games folder : {0}" -f $GamesRoot) White
Say ("  Output       : {0}" -f $OutDir) White
Say ''

$dirs = @(Get-ChildItem -LiteralPath $GamesRoot -Directory -Force | Where-Object { $_.FullName -ne $OutDir -and $_.Name -ne 'kb_owner_pack' })
$games = @()
$used = @{}
foreach ($d in $dirs) {
    $id = Get-GameId $d.Name
    if ($used.ContainsKey($id)) { $id = $id + '_' + (($d.Name -replace '[^A-Za-z0-9]+', '').ToLower()) }
    $used[$id] = 1
    $games += [pscustomobject]@{ Id = $id; Dir = $d.FullName; Name = $d.Name }
}
if ($games.Count -eq 0) { Say '  No game folders found. Run it in the folder that contains the games.' Red; return }
Say '  Games found:' Cyan
foreach ($g in $games) { Say ("    - {0,-18} <- {1}" -f $g.Id, $g.Name) Gray }
Say ''

$stat = [ordered]@{ samples = 0; icons = 0; find = 0 }
$problems = New-Object System.Collections.Generic.List[string]

# ---- T-11: sample files
if ($Skip -notcontains 'samples') {
    Say '  [1/3] Sample files (T-11)' Yellow
    $want = @{}
    foreach ($n in $Names) { $want[$n.ToLower()] = 1 }
    $lim = [long]($MaxMB * 1MB)
    foreach ($g in $games) {
        $dst = Join-Path $OutDir (Join-Path 'ref' $g.Id)
        New-Item -ItemType Directory -Force -Path $dst | Out-Null
        $cnt = 0
        $files = @(Get-ChildItem -LiteralPath $g.Dir -Recurse -File -Force -ErrorAction SilentlyContinue)
        foreach ($f in $files) {
            $rel = ($f.FullName.Substring($g.Dir.Length).TrimStart('\', '/')) -replace '\\', '/'
            if ($want.ContainsKey($f.Name.ToLower()) -and $f.Length -le $lim) {
                try { Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $dst (Get-SafeName $rel)) -Force; $cnt++ }
                catch { $problems.Add("copy failed: $rel ($($_.Exception.Message))") }
            }
            if ($f.Extension -ieq '.kfs') {
                $z = $null
                try { $z = [IO.Compression.ZipFile]::OpenRead($f.FullName) } catch { $problems.Add("not a zip: $rel"); continue }
                try {
                    foreach ($e in $z.Entries) {
                        if ($e.Name -and $want.ContainsKey($e.Name.ToLower()) -and $e.Length -le $lim) {
                            $target = Join-Path $dst (Get-SafeName ($rel + '!/' + $e.FullName))
                            try { [IO.Compression.ZipFileExtensions]::ExtractToFile($e, $target, $true); $cnt++ }
                            catch { $problems.Add("extract failed: $rel!$($e.FullName) ($($_.Exception.Message))") }
                        }
                    }
                } finally { $z.Dispose() }
            }
        }
        $stat['samples'] += $cnt
        Say ("    {0,-18} {1} file(s)" -f $g.Id, $cnt) $(if ($cnt -gt 0) { 'Green' } else { 'DarkYellow' })
    }
    Say ''
}

# ---- T-12: icons
if ($Skip -notcontains 'icons') {
    Say '  [2/3] Interface icons (T-12)' Yellow
    $patLegend = '^(hero_bg18|records_.*|mainpanel_12|mana4_empty|rage1_empty|mana21_empty|rage2_empty)\.png$'
    $patOthers = '^(heroitem_medal_.*|heroitem_achievement.*|reward_.*|achievements_bar.*|hero_pet.*)\.png$'
    foreach ($g in $games) {
        $pat = if ($g.Id -eq 'legend') { $patLegend } else { $patOthers }
        $kfsList = @(Get-ChildItem -LiteralPath $g.Dir -Recurse -File -Force -Filter 'interface_textures.kfs' -ErrorAction SilentlyContinue)
        if ($kfsList.Count -eq 0) { Say ("    {0,-18} interface_textures.kfs not found" -f $g.Id) DarkYellow; continue }
        $cnt = 0
        $dst = Join-Path $OutDir (Join-Path 'png' $g.Id)
        New-Item -ItemType Directory -Force -Path $dst | Out-Null
        foreach ($k in $kfsList) {
            $z = $null
            try { $z = [IO.Compression.ZipFile]::OpenRead($k.FullName) } catch { $problems.Add("not a zip: $($k.FullName)"); continue }
            try {
                foreach ($e in $z.Entries) {
                    if ($e.Name -and $e.Name -match $pat) {
                        try { [IO.Compression.ZipFileExtensions]::ExtractToFile($e, (Join-Path $dst $e.Name), $true); $cnt++ }
                        catch { $problems.Add("png failed: $($e.Name) ($($_.Exception.Message))") }
                    }
                }
            } finally { $z.Dispose() }
        }
        $stat['icons'] += $cnt
        Say ("    {0,-18} {1} png" -f $g.Id, $cnt) $(if ($cnt -gt 0) { 'Green' } else { 'DarkYellow' })
    }
    Say ''
}

# ---- T-01: search in The Legend
if ($Skip -notcontains 'find') {
    Say '  [3/3] Search in The Legend (T-01)' Yellow
    $legend = $games | Where-Object { $_.Id -eq 'legend' } | Select-Object -First 1
    $finder = Join-Path $PSScriptRoot 'Find-KBText.ps1'
    if (-not $legend) { Say '    The Legend folder not found, skipped.' DarkYellow }
    elseif (-not (Test-Path -LiteralPath $finder)) { Say '    Find-KBText.ps1 not found next to this script, skipped.' DarkYellow }
    else {
        $findOut = Join-Path $OutDir 'kb_find.txt'
        try {
            & $finder -GameDir $legend.Dir -Pattern $FindPattern -Out $findOut | Out-Null
            if (Test-Path -LiteralPath $findOut) { $stat['find'] = @(Get-Content -LiteralPath $findOut).Count }
            Say ("    kb_find.txt: {0} matching line(s)" -f $stat['find']) $(if ($stat['find'] -gt 0) { 'Green' } else { 'DarkYellow' })
        } catch { $problems.Add("search failed: $($_.Exception.Message)"); Say ("    search failed: {0}" -f $_.Exception.Message) Red }
    }
    Say ''
}

# ---- pack
$zip = Join-Path (Split-Path -Parent $OutDir) 'kb_owner_pack.zip'
if (Test-Path -LiteralPath $zip) { Remove-Item -LiteralPath $zip -Force }
try {
    [IO.Compression.ZipFile]::CreateFromDirectory($OutDir, $zip)
    $zipMb = '{0:N2}' -f ((Get-Item -LiteralPath $zip).Length / 1MB)
    Say ("  Zip to send : {0}  ({1} MB)" -f $zip, $zipMb) Green
} catch {
    $problems.Add("zip failed: $($_.Exception.Message)")
    Say ("  Could not build zip: {0}. Send the folder {1} packed by hand." -f $_.Exception.Message, $OutDir) Red
}

Say ''
Say '  SUMMARY' Cyan
Say ("    sample files : {0}" -f $stat['samples']) White
Say ("    png icons    : {0}" -f $stat['icons']) White
Say ("    search lines : {0}" -f $stat['find']) White
if ($problems.Count -gt 0) {
    Say ("    problems     : {0} (first 10 below)" -f $problems.Count) DarkYellow
    foreach ($p in ($problems | Select-Object -First 10)) { Say ("      - {0}" -f $p) DarkYellow }
}
Say ("    time         : {0:mm\:ss}" -f $sw.Elapsed) DarkGray
Say ''
Say '  Send kb_owner_pack.zip to the chat. Game files are NOT committed to the repo.' Gray
Say ''
