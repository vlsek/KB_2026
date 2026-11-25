<#
.SYNOPSIS
  One-run manifest of every King's Bounty game in a folder, plus a comparison report.

.DESCRIPTION
  Run ONCE in the folder that contains the game folders:

      D:\Games\KB\
          King's Bounty The Legend\
          King's Bounty Crossworlds\
          King's Bounty Warriors of the North\
          ...

  For each game the script:
    * walks all files (path, size, date, first 8 bytes, quick hash);
    * reads the table of contents INSIDE every .kfs archive (it is a zip):
      name, size, CRC32. Nothing is unpacked or changed.
  Then it compares all games with the base game (The Legend by default)
  and writes REPORT.md: what exists only in newer games, what differs,
  where "achievement"-like names live.

  Nothing is written into the game folders. Output goes to <GamesRoot>\kb_manifests.
  Output holds only names, sizes and checksums, never game content.
  No Python needed. Works in Windows PowerShell 5.1 and PowerShell 7.

.PARAMETER GamesRoot    Folder that contains the game folders. Default: current folder.
.PARAMETER OutDir       Output folder. Default: <GamesRoot>\kb_manifests.
.PARAMETER Hash         none | fast | full. fast (default): SHA1 of first+last 64 KB plus size.
                        full reads whole files (slow on several GB).
.PARAMETER Base         Base game for comparison (id like legend, or part of the folder name).
.PARAMETER Include      Wildcard filter of folder names, e.g. -Include '*Legend*','*North*'.
.PARAMETER CompareOnly  Do not rescan: compare the *.items.csv already present in OutDir.
.PARAMETER NoZip        Do not build kb_manifests.zip at the end.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\Get-KBManifest.ps1 -GamesRoot "D:\Games\KB"

.EXAMPLE
  .\Get-KBManifest.ps1 -GamesRoot . -Hash none     # fastest run
#>
[CmdletBinding()]
param(
    [string]$GamesRoot = (Get-Location).Path,
    [string]$OutDir = '',
    [ValidateSet('none', 'fast', 'full')][string]$Hash = 'fast',
    [string]$Base = '',
    [string[]]$Include = @(),
    [switch]$CompareOnly,
    [switch]$NoZip
)

$ErrorActionPreference = 'Stop'
$sw = [System.Diagnostics.Stopwatch]::StartNew()

# ---------------------------------------------------------------- C# helper
if (-not ('KbZip' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.IO;
using System.Security.Cryptography;
using System.Text;

public class KbZipEntry {
    public string Name; public long Size; public long Packed; public uint Crc; public string Date;
}

public static class KbZip {
    static uint U32(byte[] b, int o) { return BitConverter.ToUInt32(b, o); }
    static ushort U16(byte[] b, int o) { return BitConverter.ToUInt16(b, o); }
    static ulong U64(byte[] b, int o) { return BitConverter.ToUInt64(b, o); }

    static int ReadFully(Stream s, byte[] buf, int count) {
        int got = 0;
        while (got < count) {
            int n = s.Read(buf, got, count - got);
            if (n <= 0) break;
            got += n;
        }
        return got;
    }

    static string Hex(byte[] b, int count) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < count && i < b.Length; i++) sb.Append(b[i].ToString("x2"));
        return sb.ToString();
    }

    // Read zip (.kfs) table of contents without unpacking: central directory only.
    public static List<KbZipEntry> Read(string path) {
        List<KbZipEntry> res = new List<KbZipEntry>();
        using (FileStream fs = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite)) {
            long len = fs.Length;
            if (len < 22) throw new InvalidDataException("file too small for zip");
            int tailLen = (int)Math.Min(len, 65535 + 22 + 64);
            byte[] tail = new byte[tailLen];
            fs.Seek(len - tailLen, SeekOrigin.Begin);
            ReadFully(fs, tail, tailLen);
            int pos = -1;
            for (int i = tailLen - 22; i >= 0; i--) {
                if (tail[i] == 0x50 && tail[i + 1] == 0x4b && tail[i + 2] == 5 && tail[i + 3] == 6) { pos = i; break; }
            }
            if (pos < 0) throw new InvalidDataException("zip end-of-directory not found (not a zip?)");
            long eocdAbs = len - tailLen + pos;
            long entries = U16(tail, pos + 10);
            long cdSize = U32(tail, pos + 12);
            long cdOff = U32(tail, pos + 16);
            bool z64 = false;
            if (entries == 0xFFFF || cdSize == 0xFFFFFFFFL || cdOff == 0xFFFFFFFFL) {
                if (pos >= 20 && U32(tail, pos - 20) == 0x07064b50) {
                    long z64Off = (long)U64(tail, pos - 20 + 8);
                    byte[] z = new byte[56];
                    fs.Seek(z64Off, SeekOrigin.Begin);
                    ReadFully(fs, z, 56);
                    if (U32(z, 0) == 0x06064b50) {
                        entries = (long)U64(z, 32); cdSize = (long)U64(z, 40); cdOff = (long)U64(z, 48);
                        z64 = true;
                    }
                }
            }
            // data before the zip shifts offsets
            if (!z64 && cdOff + cdSize != eocdAbs) cdOff = eocdAbs - cdSize;
            if (cdOff < 0 || cdSize < 0 || cdOff + cdSize > len) throw new InvalidDataException("broken zip directory");
            byte[] cd = new byte[(int)cdSize];
            fs.Seek(cdOff, SeekOrigin.Begin);
            ReadFully(fs, cd, cd.Length);

            Encoding latin1 = Encoding.GetEncoding(28591);
            int p = 0;
            while (p + 46 <= cd.Length && U32(cd, p) == 0x02014b50) {
                ushort flags = U16(cd, p + 8);
                ushort dtime = U16(cd, p + 12);
                ushort ddate = U16(cd, p + 14);
                uint crc = U32(cd, p + 16);
                long csize = U32(cd, p + 20);
                long usize = U32(cd, p + 24);
                int nameLen = U16(cd, p + 28);
                int extraLen = U16(cd, p + 30);
                int commLen = U16(cd, p + 32);
                string name = ((flags & 0x800) != 0 ? Encoding.UTF8 : latin1).GetString(cd, p + 46, nameLen);

                int ep = p + 46 + nameLen;
                int ee = ep + extraLen;
                while (ep + 4 <= ee) {
                    int id = U16(cd, ep);
                    int sz = U16(cd, ep + 2);
                    if (id == 1) {
                        int q = ep + 4;
                        if (usize == 0xFFFFFFFFL && q + 8 <= ep + 4 + sz) { usize = (long)U64(cd, q); q += 8; }
                        if (csize == 0xFFFFFFFFL && q + 8 <= ep + 4 + sz) { csize = (long)U64(cd, q); q += 8; }
                    }
                    ep += 4 + sz;
                }

                string date = "";
                try {
                    int y = ((ddate >> 9) & 0x7f) + 1980, mo = (ddate >> 5) & 0xf, d = ddate & 0x1f;
                    int h = (dtime >> 11) & 0x1f, mi = (dtime >> 5) & 0x3f;
                    date = new DateTime(y, mo, d, h, mi, 0).ToString("yyyy-MM-dd");
                } catch { }

                if (!name.EndsWith("/")) {
                    KbZipEntry e = new KbZipEntry();
                    e.Name = name; e.Size = usize; e.Packed = csize; e.Crc = crc; e.Date = date;
                    res.Add(e);
                }
                p += 46 + nameLen + extraLen + commLen;
            }
        }
        return res;
    }

    // returns { signature (first 8 bytes), hash }
    public static string[] Probe(string path, string mode) {
        using (FileStream fs = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite, 65536)) {
            long len = fs.Length;
            byte[] head = new byte[(int)Math.Min(len, 65536)];
            int n = ReadFully(fs, head, head.Length);
            string sig = Hex(head, Math.Min(n, 8));
            string hash = "";
            if (mode == "fast") {
                using (SHA1 sha = SHA1.Create()) {
                    sha.TransformBlock(head, 0, n, null, 0);
                    if (len > 65536) {
                        int tl = (int)Math.Min(len - 65536, 65536);
                        byte[] t = new byte[tl];
                        fs.Seek(len - tl, SeekOrigin.Begin);
                        int m = ReadFully(fs, t, tl);
                        sha.TransformBlock(t, 0, m, null, 0);
                    }
                    byte[] lb = BitConverter.GetBytes(len);
                    sha.TransformFinalBlock(lb, 0, lb.Length);
                    hash = Hex(sha.Hash, 8);
                }
            } else if (mode == "full") {
                fs.Seek(0, SeekOrigin.Begin);
                using (SHA1 sha = SHA1.Create()) { hash = Hex(sha.ComputeHash(fs), 10); }
            }
            return new string[] { sig, hash };
        }
    }
}
'@
}
# ---------------------------------------------------------------- console helpers
function Write-Line([string]$text = '', [ConsoleColor]$color = 'Gray') { Write-Host $text -ForegroundColor $color }
function Fmt-Mb([double]$bytes) { return ('{0:N1}' -f ($bytes / 1MB)) }
function Fmt-Gb([double]$bytes) { return ('{0:N2}' -f ($bytes / 1GB)) }
function Fmt-Time([TimeSpan]$t) { return ('{0:mm\:ss}' -f $t) }

function Write-Banner {
    $line = '=' * 64
    Write-Line ''
    Write-Line "  +$line+" Cyan
    Write-Line ('  |  {0,-61}|' -f "KB_2026  -  King's Bounty series manifest + comparison") Cyan
    Write-Line ('  |  {0,-61}|' -f 'read-only: game folders are never modified') DarkCyan
    Write-Line "  +$line+" Cyan
    Write-Line ''
}

function Write-Bar([double]$value, [double]$max, [int]$width = 20) {
    if ($max -le 0) { return ('.' * $width) }
    $n = [int][math]::Round($width * $value / $max)
    if ($n -gt $width) { $n = $width }
    return (('#' * $n) + ('.' * ($width - $n)))
}

# ---------------------------------------------------------------- game id from folder name
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

# ---------------------------------------------------------------- scan one game
function Scan-Game([string]$dir, [string]$id, [string]$mode) {
    $items = New-Object System.Collections.Generic.List[object]
    $warn = New-Object System.Collections.Generic.List[string]
    $files = @(Get-ChildItem -LiteralPath $dir -Recurse -File -Force -ErrorAction SilentlyContinue)
    $total = $files.Count
    $i = 0
    foreach ($f in $files) {
        $i++
        if (($i % 40) -eq 0 -or $i -eq $total) {
            Write-Progress -Activity "Scanning: $id" -Status ("{0} / {1}  {2}" -f $i, $total, $f.Name) -PercentComplete ([int](100 * $i / [math]::Max($total, 1)))
        }
        $rel = ($f.FullName.Substring($dir.Length).TrimStart('\', '/')) -replace '\\', '/'
        $ext = $f.Extension.ToLower()
        $sig = ''; $hash = ''
        try {
            $pr = [KbZip]::Probe($f.FullName, $mode)
            $sig = $pr[0]; $hash = $pr[1]
        } catch { $warn.Add("not read: $rel ($($_.Exception.Message))") }

        $items.Add([pscustomobject]@{
                Where = '(disk)'; Path = $rel; Ext = $ext; Size = [long]$f.Length; Packed = [long]$f.Length
                Id = $hash; Sig = $sig; Date = $f.LastWriteTime.ToString('yyyy-MM-dd')
            })

        if ($ext -eq '.kfs') {
            try {
                foreach ($e in [KbZip]::Read($f.FullName)) {
                    $en = [System.IO.Path]::GetExtension($e.Name).ToLower()
                    $items.Add([pscustomobject]@{
                            Where = $rel; Path = ($e.Name -replace '\\', '/'); Ext = $en; Size = [long]$e.Size; Packed = [long]$e.Packed
                            Id = ('{0:x8}' -f $e.Crc); Sig = ''; Date = $e.Date
                        })
                }
            } catch { $warn.Add("archive not opened: $rel ($($_.Exception.Message))") }
        }
    }
    Write-Progress -Activity "Scanning: $id" -Completed
    return [pscustomobject]@{ Items = $items; Warnings = $warn; DiskFiles = $total }
}

function Get-Leaf($it) { return (($it.Path -split '/')[-1]).ToLower() }
# identity of content: size + crc (inside .kfs) or size + hash (loose file)
function Get-Token($it) { return ([string]$it.Size + ':' + [string]$it.Id) }

# ---------------------------------------------------------------- setup
Write-Banner
$GamesRoot = (Resolve-Path -LiteralPath $GamesRoot).Path.TrimEnd('\', '/')
if (-not $OutDir) { $OutDir = Join-Path $GamesRoot 'kb_manifests' }
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$OutDir = (Resolve-Path -LiteralPath $OutDir).Path

Write-Line ("  Games folder : {0}" -f $GamesRoot) White
Write-Line ("  Output       : {0}" -f $OutDir) White
Write-Line ("  Hash mode    : {0}{1}" -f $Hash, $(if ($CompareOnly) { '   (compare only)' } else { '' })) White
Write-Line ''

$games = New-Object System.Collections.Generic.List[object]

if ($CompareOnly) {
    foreach ($csv in Get-ChildItem -LiteralPath $OutDir -Filter '*.items.csv') {
        $gid = $csv.Name -replace '\.items\.csv$', ''
        $rows = @(Import-Csv -LiteralPath $csv.FullName)
        foreach ($r in $rows) { $r.Size = [long]$r.Size; $r.Packed = [long]$r.Packed }
        $games.Add([pscustomobject]@{ Id = $gid; Name = $gid; Items = $rows; Warnings = @(); DiskFiles = @($rows | Where-Object { $_.Where -eq '(disk)' }).Count })
        Write-Line ("  [ok] loaded {0}: {1} entries" -f $gid, $rows.Count) Green
    }
} else {
    $dirs = @(Get-ChildItem -LiteralPath $GamesRoot -Directory -Force | Where-Object { $_.Name -ne 'kb_manifests' -and $_.FullName -ne $OutDir })
    if ($Include.Count -gt 0) {
        $dirs = @($dirs | Where-Object { $n = $_.Name; ($Include | Where-Object { $n -like $_ }).Count -gt 0 })
    }
    if ($dirs.Count -eq 0) { Write-Line '  No game folders found.' Red; return }

    Write-Line '  Games found:' Cyan
    $usedIds = @{}
    $plan = @()
    foreach ($d in $dirs) {
        $gid = Get-GameId $d.Name
        if ($usedIds.ContainsKey($gid)) { $gid = $gid + '_' + (($d.Name -replace '[^A-Za-z0-9]+', '').ToLower()) }
        $usedIds[$gid] = 1
        $plan += [pscustomobject]@{ Id = $gid; Dir = $d.FullName; Name = $d.Name }
        Write-Line ("    - {0,-18} <- {1}" -f $gid, $d.Name) Gray
    }
    Write-Line ''

    $gi = 0
    foreach ($g in $plan) {
        $gi++
        $t0 = [System.Diagnostics.Stopwatch]::StartNew()
        Write-Line ("  [{0}/{1}] {2}" -f $gi, $plan.Count, $g.Id) Yellow
        try {
            $scan = Scan-Game -dir $g.Dir -id $g.Id -mode $Hash
        } catch {
            Write-Line ("    [FAIL] {0}" -f $_.Exception.Message) Red
            continue
        }
        $items = $scan.Items
        $items | Export-Csv -LiteralPath (Join-Path $OutDir ($g.Id + '.items.csv')) -NoTypeInformation -Encoding UTF8

        $agg = @{}
        foreach ($it in $items) {
            $k = $it.Where + "`t" + $it.Ext
            if (-not $agg.ContainsKey($k)) { $agg[$k] = [pscustomobject]@{ Where = $it.Where; Ext = $it.Ext; Files = 0; Bytes = [long]0 } }
            $agg[$k].Files++; $agg[$k].Bytes += $it.Size
        }
        $agg.Values | Sort-Object Where, Ext | ForEach-Object {
            [pscustomobject]@{ Where = $_.Where; Ext = $_.Ext; Files = $_.Files; SizeMB = [math]::Round($_.Bytes / 1MB, 2) }
        } | Export-Csv -LiteralPath (Join-Path $OutDir ($g.Id + '.summary.csv')) -NoTypeInformation -Encoding UTF8

        $kfsCount = 0; $diskBytes = [long]0
        foreach ($it in $items) { if ($it.Where -ne '(disk)') { $kfsCount++ } else { $diskBytes += $it.Size } }
        $t0.Stop()
        Write-Line ("    [ok] disk files: {0}   inside .kfs: {1}   size: {2} GB   time: {3}" -f $scan.DiskFiles, $kfsCount, (Fmt-Gb $diskBytes), (Fmt-Time $t0.Elapsed)) Green
        foreach ($w in $scan.Warnings) { Write-Line ("    [warn] {0}" -f $w) DarkYellow }
        $games.Add([pscustomobject]@{ Id = $g.Id; Name = $g.Name; Items = $items; Warnings = $scan.Warnings; DiskFiles = $scan.DiskFiles })
    }
}

if ($games.Count -eq 0) { Write-Line '  Nothing to compare.' Red; return }

# ---------------------------------------------------------------- comparison
Write-Line ''
Write-Line '  Building comparison report...' Cyan

$baseGame = $null
if ($Base) { $baseGame = $games | Where-Object { $_.Id -eq $Base -or $_.Name -like "*$Base*" } | Select-Object -First 1 }
if (-not $baseGame) { $baseGame = $games | Where-Object { $_.Id -eq 'legend' } | Select-Object -First 1 }
if (-not $baseGame) { $baseGame = $games[0] }

$scriptExt = @('.lua', '.lu', '.txt', '.ui', '.qst', '.act', '.chat', '.loc', '.hero', '.strg', '.ini', '.cfg', '.lng', '.csv', '.track', '.atom', '.ptb', '.csh')
$kwRegex = '(?i)achiev|trophy|trophies|medal|award|steam|stats?[_\.\-/]'

# base: leaf name -> set of content tokens
$baseLeaf = @{}
foreach ($it in $baseGame.Items) {
    $leaf = Get-Leaf $it
    if (-not $baseLeaf.ContainsKey($leaf)) { $baseLeaf[$leaf] = @{} }
    $baseLeaf[$leaf][(Get-Token $it)] = 1
}

$L = New-Object System.Collections.Generic.List[string]
$L.Add('# King''s Bounty series comparison')
$L.Add('')
$L.Add(('Generated: {0}. Base game: **{1}**. Hash mode: `{2}`.' -f (Get-Date -Format 'yyyy-MM-dd HH:mm'), $baseGame.Id, $Hash))
$L.Add('')
$L.Add('Names are matched by file name only (folder and archive are ignored), because the games pack data into different archives. Only names, sizes and checksums are listed here, no game content.')
$L.Add('')
$L.Add('## Games')
$L.Add('')
$L.Add('| Game | Folder | Disk files | Entries inside .kfs | Size on disk, GB |')
$L.Add('|---|---|---:|---:|---:|')
foreach ($g in $games) {
    $k = 0; $b = [long]0
    foreach ($it in $g.Items) { if ($it.Where -ne '(disk)') { $k++ } else { $b += $it.Size } }
    $L.Add(('| {0} | {1} | {2} | {3} | {4} |' -f $g.Id, $g.Name, $g.DiskFiles, $k, (Fmt-Gb $b)))
}
$L.Add('')

$extCounts = @{}
foreach ($g in $games) {
    foreach ($it in $g.Items) {
        $e = if ($it.Ext) { $it.Ext } else { '(none)' }
        if (-not $extCounts.ContainsKey($e)) { $extCounts[$e] = @{} }
        if (-not $extCounts[$e].ContainsKey($g.Id)) { $extCounts[$e][$g.Id] = 0 }
        $extCounts[$e][$g.Id]++
    }
}
$L.Add('## File types per game (disk + inside .kfs)')
$L.Add('')
$L.Add('| Extension | ' + (($games | ForEach-Object { $_.Id }) -join ' | ') + ' |')
$L.Add('|---|' + (('---:|') * $games.Count))
$extOrder = $extCounts.Keys | Sort-Object { - ($extCounts[$_].Values | Measure-Object -Sum).Sum } | Select-Object -First 45
foreach ($e in $extOrder) {
    $cells = foreach ($g in $games) { if ($extCounts[$e].ContainsKey($g.Id)) { $extCounts[$e][$g.Id] } else { 0 } }
    $L.Add(('| `{0}` | {1} |' -f $e, ($cells -join ' | ')))
}
$L.Add('')

$summaryRows = New-Object System.Collections.Generic.List[object]

foreach ($g in $games) {
    if ($g.Id -eq $baseGame.Id) { continue }
    $new = New-Object System.Collections.Generic.List[object]
    $changed = New-Object System.Collections.Generic.List[object]
    $same = 0
    $seenLeaf = @{}
    foreach ($it in $g.Items) {
        $leaf = Get-Leaf $it
        $seenLeaf[$leaf] = 1
        if (-not $baseLeaf.ContainsKey($leaf)) { $new.Add($it) }
        elseif ($baseLeaf[$leaf].ContainsKey((Get-Token $it))) { $same++ }
        else { $changed.Add($it) }
    }
    $onlyBase = 0
    foreach ($k in $baseLeaf.Keys) { if (-not $seenLeaf.ContainsKey($k)) { $onlyBase++ } }
    $newBytes = [long]0; foreach ($it in $new) { $newBytes += $it.Size }

    $new | Export-Csv -LiteralPath (Join-Path $OutDir ('new_in_' + $g.Id + '.csv')) -NoTypeInformation -Encoding UTF8
    $changed | Export-Csv -LiteralPath (Join-Path $OutDir ('changed_in_' + $g.Id + '.csv')) -NoTypeInformation -Encoding UTF8
    $summaryRows.Add([pscustomobject]@{ Id = $g.Id; Total = $g.Items.Count; Same = $same; Changed = $changed.Count; New = $new.Count; OnlyBase = $onlyBase })

    $L.Add("## $($g.Id) vs $($baseGame.Id)")
    $L.Add('')
    $L.Add('| | Entries | MB |')
    $L.Add('|---|---:|---:|')
    $L.Add(('| Identical to base (same name and content) | {0} | |' -f $same))
    $L.Add(('| Same name, **different content** | {0} | |' -f $changed.Count))
    $L.Add(('| **New** (name not in {0}) | {1} | {2} |' -f $baseGame.Id, $new.Count, (Fmt-Mb $newBytes)))
    $L.Add(('| Names present only in {0} | {1} | |' -f $baseGame.Id, $onlyBase))
    $L.Add('')

    $byExt = @{}
    foreach ($it in $new) {
        $e = if ($it.Ext) { $it.Ext } else { '(none)' }
        if (-not $byExt.ContainsKey($e)) { $byExt[$e] = [pscustomobject]@{ Ext = $e; Files = 0; Bytes = [long]0 } }
        $byExt[$e].Files++; $byExt[$e].Bytes += $it.Size
    }
    $L.Add("### New in $($g.Id): by type")
    $L.Add('')
    $L.Add('| Type | Files | MB |')
    $L.Add('|---|---:|---:|')
    foreach ($r in ($byExt.Values | Sort-Object Files -Descending | Select-Object -First 20)) {
        $L.Add(('| `{0}` | {1} | {2} |' -f $r.Ext, $r.Files, (Fmt-Mb $r.Bytes)))
    }
    $L.Add('')

    $byWhere = @{}
    foreach ($it in $new) {
        if (-not $byWhere.ContainsKey($it.Where)) { $byWhere[$it.Where] = [pscustomobject]@{ Where = $it.Where; Files = 0; Bytes = [long]0 } }
        $byWhere[$it.Where].Files++; $byWhere[$it.Where].Bytes += $it.Size
    }
    $L.Add("### New in $($g.Id): by container")
    $L.Add('')
    $L.Add('| Where | Files | MB |')
    $L.Add('|---|---:|---:|')
    foreach ($r in ($byWhere.Values | Sort-Object Files -Descending | Select-Object -First 20)) {
        $L.Add(('| `{0}` | {1} | {2} |' -f $r.Where, $r.Files, (Fmt-Mb $r.Bytes)))
    }
    $L.Add('')

    $scripts = @($new | Where-Object { $scriptExt -contains $_.Ext })
    $L.Add("### New scripts and data not in $($baseGame.Id) ($($scripts.Count))")
    $L.Add('')
    $L.Add('First 40. Full list: `new_in_' + $g.Id + '.csv`.')
    $L.Add('')
    foreach ($it in ($scripts | Sort-Object Where, Path | Select-Object -First 40)) {
        $L.Add(('- `{0}` -> `{1}` ({2} B)' -f $it.Where, $it.Path, $it.Size))
    }
    $L.Add('')

    $chScripts = @($changed | Where-Object { $scriptExt -contains $_.Ext })
    $L.Add("### Scripts and data with same name but different content ($($chScripts.Count))")
    $L.Add('')
    $L.Add('First 40. Full list: `changed_in_' + $g.Id + '.csv`.')
    $L.Add('')
    foreach ($it in ($chScripts | Sort-Object Where, Path | Select-Object -First 40)) {
        $L.Add(('- `{0}` -> `{1}` ({2} B)' -f $it.Where, $it.Path, $it.Size))
    }
    $L.Add('')

    $kw = @($g.Items | Where-Object { $_.Path -match $kwRegex })
    $L.Add("### Names that look like achievements / stats ($($kw.Count))")
    $L.Add('')
    if ($kw.Count -eq 0) { $L.Add('_no matches_') }
    foreach ($it in ($kw | Select-Object -First 60)) {
        $mark = if ($baseLeaf.ContainsKey((Get-Leaf $it))) { '' } else { ' **new**' }
        $L.Add(('- `{0}` -> `{1}`{2}' -f $it.Where, $it.Path, $mark))
    }
    $L.Add('')
}

$kwBase = @($baseGame.Items | Where-Object { $_.Path -match $kwRegex })
$L.Add("## $($baseGame.Id): names that look like achievements / stats ($($kwBase.Count))")
$L.Add('')
if ($kwBase.Count -eq 0) { $L.Add('_no matches_') }
foreach ($it in ($kwBase | Select-Object -First 60)) { $L.Add(('- `{0}` -> `{1}`' -f $it.Where, $it.Path)) }
$L.Add('')

$reportPath = Join-Path $OutDir 'REPORT.md'
[System.IO.File]::WriteAllLines($reportPath, $L.ToArray(), (New-Object System.Text.UTF8Encoding($true)))

# ---------------------------------------------------------------- final screen summary
Write-Line ''
Write-Line '  SUMMARY' Cyan
Write-Line ('  {0,-22} {1,9} {2,9} {3,9} {4,10}  {5}' -f 'game', 'entries', 'changed', 'new', 'base-only', 'new share') DarkCyan
Write-Line ('  ' + ('-' * 78)) DarkGray
foreach ($g in $games) {
    if ($g.Id -eq $baseGame.Id) {
        Write-Line ('  {0,-22} {1,9} {2,9} {3,9} {4,10}' -f ($g.Id + ' (base)'), $g.Items.Count, '-', '-', '-') White
        continue
    }
    $s = $summaryRows | Where-Object { $_.Id -eq $g.Id } | Select-Object -First 1
    Write-Line ('  {0,-22} {1,9} {2,9} {3,9} {4,10}  [{5}]' -f $g.Id, $s.Total, $s.Changed, $s.New, $s.OnlyBase, (Write-Bar $s.New $s.Total 20)) Gray
}
Write-Line ''

if (-not $NoZip -and -not $CompareOnly) {
    $zip = Join-Path $OutDir 'kb_manifests.zip'
    if (Test-Path -LiteralPath $zip) { Remove-Item -LiteralPath $zip -Force }
    $toZip = @(Get-ChildItem -LiteralPath $OutDir -File | Where-Object { $_.Name -ne 'kb_manifests.zip' } | ForEach-Object { $_.FullName })
    try {
        Compress-Archive -LiteralPath $toZip -DestinationPath $zip -CompressionLevel Optimal
        Write-Line ('  Archive to send : {0}  ({1} MB)' -f $zip, (Fmt-Mb (Get-Item -LiteralPath $zip).Length)) Green
    } catch { Write-Line ('  [warn] could not build zip: {0}' -f $_.Exception.Message) DarkYellow }
}
Write-Line ('  Report          : {0}' -f $reportPath) Green
Write-Line ('  Total time      : {0}' -f (Fmt-Time $sw.Elapsed)) DarkGray
Write-Line ''
