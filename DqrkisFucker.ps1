# ============================================================
#   DQRKIS FUCKER  -  Cheat Client Detector
#   discord : cheese_cat0  |  discord : mecz.exe
#   Special thanks to Nic
# ============================================================

Add-Type -AssemblyName System.IO.Compression.FileSystem
$Host.UI.RawUI.WindowTitle = "Dqrkis Fucker"

# ── Layout constants ─────────────────────────────────────────
$W = 90   # inner width (between the border pipes)

# ── Colour aliases ───────────────────────────────────────────
Set-Variable -Name CLR -Value @{
    Border   = [System.ConsoleColor]::DarkGray
    Muted    = [System.ConsoleColor]::DarkGray
    Label    = [System.ConsoleColor]::Gray
    Value    = [System.ConsoleColor]::White
    Accent   = [System.ConsoleColor]::Red
    AccentLo = [System.ConsoleColor]::DarkRed
    OK       = [System.ConsoleColor]::Green
    Warn     = [System.ConsoleColor]::DarkYellow
    Hit      = [System.ConsoleColor]::Yellow
    Class    = [System.ConsoleColor]::Cyan
    Res      = [System.ConsoleColor]::Magenta
}

# ── Primitive drawing helpers ─────────────────────────────────
function _Pipe  { Write-Host "│" -ForegroundColor $CLR.Border -NoNewline }
function _Line  { param($C='─',[int]$N=$W) [string]$C * $N }
function _Top   { Write-Host ("┌" + (_Line) + "┐") -ForegroundColor $CLR.Border }
function _Bot   { Write-Host ("└" + (_Line) + "┘") -ForegroundColor $CLR.Border }
function _Sep   { Write-Host ("├" + (_Line) + "┤") -ForegroundColor $CLR.Border }
function _ThinSep { Write-Host ("│" + (_Line '·') + "│") -ForegroundColor $CLR.Muted }
function _Empty { Write-Host ("│" + (" " * $W) + "│") -ForegroundColor $CLR.Border }

# Render one padded row inside the box
function _Row {
    param(
        [string]$Text,
        [System.ConsoleColor]$Color = [System.ConsoleColor]::White,
        [int]$Pad = 2,              # left indent
        [switch]$Center
    )
    if ($Center) {
        $spaces = [math]::Max(0, [math]::Floor(($W - $Text.Length) / 2))
        $right  = [math]::Max(0, $W - $spaces - $Text.Length)
        _Pipe
        Write-Host (" " * $spaces + $Text + " " * $right) -ForegroundColor $Color -NoNewline
        Write-Host "│" -ForegroundColor $CLR.Border
        return
    }
    $maxContent = $W - $Pad
    if ($Text.Length -gt $maxContent) { $Text = $Text.Substring(0, $maxContent - 1) + "…" }
    $right = [math]::Max(0, $W - $Pad - $Text.Length)
    _Pipe
    Write-Host (" " * $Pad + $Text + " " * $right) -ForegroundColor $Color -NoNewline
    Write-Host "│" -ForegroundColor $CLR.Border
}

# Render a label + value row (label in label colour, value in value colour)
function _KV {
    param(
        [string]$Key,
        [string]$Val,
        [System.ConsoleColor]$KC = [System.ConsoleColor]::DarkGray,
        [System.ConsoleColor]$VC = [System.ConsoleColor]::White,
        [int]$Pad = 2
    )
    $maxVal = $W - $Pad - $Key.Length
    if ($Val.Length -gt $maxVal) { $Val = $Val.Substring(0, [math]::Max(0, $maxVal - 1)) + "…" }
    $right = [math]::Max(0, $W - $Pad - $Key.Length - $Val.Length)
    _Pipe
    Write-Host (" " * $Pad) -NoNewline
    Write-Host $Key -ForegroundColor $KC -NoNewline
    Write-Host $Val -ForegroundColor $VC -NoNewline
    Write-Host (" " * $right + "│") -ForegroundColor $CLR.Border
}

# ── Banner ───────────────────────────────────────────────────
function Write-Banner {
    Clear-Host
    Write-Host ""

    # ASCII art — tight single-stroke block letters, hand-tuned width
    $art = @(
        "  ██████╗  ██████╗ ██████╗ ██╗  ██╗██╗███████╗    ███████╗██╗   ██╗ ██████╗██╗  ██╗███████╗██████╗",
        "  ██╔══██╗██╔═══██╗██╔══██╗██║ ██╔╝██║██╔════╝    ██╔════╝██║   ██║██╔════╝██║ ██╔╝██╔════╝██╔══██╗",
        "  ██║  ██║██║   ██║██████╔╝█████╔╝ ██║███████╗    █████╗  ██║   ██║██║     █████╔╝ █████╗  ██████╔╝",
        "  ██║  ██║██║▄▄ ██║██╔══██╗██╔═██╗ ██║╚════██║    ██╔══╝  ██║   ██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗",
        "  ██████╔╝╚██████╔╝██║  ██║██║  ██╗██║███████║    ██║     ╚██████╔╝╚██████╗██║  ██╗███████╗██║  ██║",
        "  ╚═════╝  ╚══▀▀═╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝   ╚═╝      ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝"
    )

    # Gradient: top rows Red, bottom rows DarkRed
    for ($n = 0; $n -lt $art.Length; $n++) {
        $c = if ($n -lt 2) { [System.ConsoleColor]::Red }
             elseif ($n -lt 4) { [System.ConsoleColor]::DarkRed }
             else { [System.ConsoleColor]::Red }
        Write-Host $art[$n] -ForegroundColor $c
    }

    Write-Host ""
    # Sub-header bar
    $sub = "  CHEAT CLIENT DETECTOR  ─────────────────────────────────────────  v1.0  "
    Write-Host ("  " + $sub) -ForegroundColor $CLR.AccentLo
    Write-Host ("  " + "discord: cheese_cat0   ·   discord: mecz.exe   ·   thanks Nic") -ForegroundColor $CLR.Muted
    Write-Host ""
}

# ── Signatures ───────────────────────────────────────────────
$signatures = @(
    "FINDING_SPAWNER","OPENING_SPAWNER","WAITING_SPAWNER_GUI","LOOTING_BONES",
    "CLOSING_SPAWNER","ORDER_COMMAND","WAIT_ORDER_GUI","SELECT_ORDER_ITEM",
    "WAIT_DELIVERY_GUI","DELIVERING_BONES","WAIT_AFTER_DELIVERY_1",
    "CLOSING_DELIVERY","WAIT_AFTER_CLOSE_DELIVERY","WAIT_CONFIRM_GUI",
    "WAIT_CONFIRM_SETTLE","CLICK_CONFIRM_SLOT","WAIT_AFTER_CONFIRM_1",
    "WAIT_AFTER_CONFIRM_2","WAIT_AFTER_CONFIRM_3","DOUBLE_ESCAPE",
    "DOUBLE_RIGHTCLICK_FIRST","DOUBLE_RIGHTCLICK_SECOND","POST_CYCLE_DELAY",
    "mace_swap","quick_strike","loot_yeeter","auto_jump_reset","macro_198",
    "stun_slam","safe_anchor","double_anchor","auto_pot_refill","totem_offhand",
    "walksy_optimizer","key_pearl","aim_assist","auto_neth_pot","auto_dtap",
    "bottle_throw","trigger_bot","auto_web",
    "SHOP_END","SHOP_ITEM","SHOP_GLASS_PANE","SHOP_BUY",
    "SHOP_CONFIRM","SHOP_CHECK_FULL","SHOP_EXIT",
    "TARGET_ORDERS","ORDERS_SELECT","ORDERS_EXIT","ORDERS_CONFIRM","ORDERS_FINAL_EXIT",
    "CYCLE_PAUSE","PLACE_OBI","WAIT_OBI","PLACE_CRYSTAL","BREAK_CRYSTAL",
    "ROTATING_DOWN","THROWING","ROTATING_BACK","REFILLING",
    "PLANTING","BONEMEALING",
    "ParseJ.a","CacheE.MISC","CacheE.RENDER","CacheE.CT",
    "CoreH","cn`$MacroState","co`$State"
)

# ── Core scanner ─────────────────────────────────────────────
function Get-StringsFromBytes {
    param([byte[]]$bytes)
    $out = [System.Collections.Generic.List[string]]::new()
    $cur = [System.Text.StringBuilder]::new()
    foreach ($b in $bytes) {
        if ($b -ge 0x20 -and $b -le 0x7E) { [void]$cur.Append([char]$b) }
        else {
            if ($cur.Length -ge 4) { [void]$out.Add($cur.ToString()) }
            [void]$cur.Clear()
        }
    }
    if ($cur.Length -ge 4) { [void]$out.Add($cur.ToString()) }
    return $out
}

function Invoke-ScanJar {
    param([string]$jarPath)
    $hits = [System.Collections.Generic.List[PSCustomObject]]::new()
    try {
        $archive = [System.IO.Compression.ZipFile]::OpenRead($jarPath)
        foreach ($entry in $archive.Entries) {
            if ($entry.FullName -notmatch '\.(class|json|txt|cfg|properties|yml|yaml|toml)$') { continue }
            try {
                $s  = $entry.Open(); $ms = [System.IO.MemoryStream]::new()
                $s.CopyTo($ms); $s.Dispose()
                $strs = Get-StringsFromBytes -bytes $ms.ToArray(); $ms.Dispose()
                foreach ($sig in $signatures) {
                    $p = [regex]::Escape($sig)
                    foreach ($str in $strs) {
                        if ($str -match $p) {
                            [void]$hits.Add([PSCustomObject]@{ Signature = $sig; Entry = $entry.FullName })
                            break
                        }
                    }
                }
            } catch {}
        }
        $archive.Dispose()
    } catch {
        return $null
    }
    return $hits
}

# ── Progress bar ─────────────────────────────────────────────
function Write-ScanLine {
    param([int]$Done, [int]$Total, [string]$Name)
    $pct    = [math]::Floor($Done / $Total * 100)
    $filled = [math]::Floor($pct / 2)           # 50-char bar
    $bar    = ([string][char]0x2588 * $filled) + ([string][char]0x2591 * (50 - $filled))
    $lbl    = $Name.PadRight(28).Substring(0, [math]::Min(28, $Name.Length))
    [Console]::Write("  │  {0}  {1,3}%  {2}`r" -f $bar, $pct, $lbl)
}

# ════════════════════════════════════════════════════════════
#   ENTRY POINT
# ════════════════════════════════════════════════════════════
Write-Banner

# Input prompt
_Top
_Row "  TARGET DIRECTORY" $CLR.Accent
_Sep
_Empty
_Row "  Enter the folder to scan. Leave blank to use .minecraft/mods." $CLR.Label
_Empty
_Row "  Default: $env:USERPROFILE\AppData\Roaming\.minecraft\mods" $CLR.Muted
_Empty
_Bot

Write-Host ""
Write-Host "  > " -ForegroundColor $CLR.Accent -NoNewline
$scanPath = (Read-Host).Trim().Trim('"')
if ([string]::IsNullOrWhiteSpace($scanPath)) {
    $scanPath = "$env:USERPROFILE\AppData\Roaming\.minecraft\mods"
}
Write-Host ""

if (-not (Test-Path $scanPath -PathType Container)) {
    _Top
    _Row "  ERROR  ─  Path not found or not a directory." $CLR.Accent
    _Row "  $scanPath" $CLR.Muted
    _Bot
    Write-Host ""; $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown"); exit 1
}

$jars = Get-ChildItem -Path $scanPath -Recurse -Filter "*.jar" -ErrorAction SilentlyContinue
if ($jars.Count -eq 0) {
    _Top
    _Row "  No .jar files found in the specified directory." $CLR.Warn
    _Row "  $scanPath" $CLR.Muted
    _Bot
    Write-Host ""; $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown"); exit 0
}

$ts        = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$totalSize = [math]::Round(($jars | Measure-Object -Property Length -Sum).Sum / 1MB, 2)

# Scan header
_Top
_Row ("  SCAN  ─  " + $ts) $CLR.Accent
_Sep
_KV "  Path        " $scanPath
_KV "  Files       " "$($jars.Count) jar(s)  ·  $totalSize MB"
_KV "  Signatures  " "$($signatures.Count) loaded"
_Bot
Write-Host ""

# Progress section
Write-Host "  ┌─ Scanning" -ForegroundColor $CLR.AccentLo
Write-Host "  │" -ForegroundColor $CLR.AccentLo

$totalFlagged = 0; $totalClean = 0; $totalErrors = 0
$flaggedMods  = [System.Collections.Generic.List[PSCustomObject]]::new()
$i = 0

foreach ($jar in $jars) {
    $i++
    Write-ScanLine -Done $i -Total $jars.Count -Name $jar.Name
    $hits = Invoke-ScanJar -jarPath $jar.FullName
    if ($null -eq $hits)         { $totalErrors++;  continue }
    if ($hits.Count -gt 0) {
        $totalFlagged++
        $flaggedMods.Add([PSCustomObject]@{
            Name     = $jar.Name
            Path     = $jar.FullName
            Size     = [math]::Round($jar.Length / 1KB, 1)
            HitCount = $hits.Count
            Hits     = $hits
        })
    } else { $totalClean++ }
}

# Finish progress
[Console]::Write("  │  " + ([string][char]0x2588 * 50) + "  100%  done" + (" " * 30) + "`r")
Write-Host ("  │  " + ([string][char]0x2588 * 50) + "  100%  done") -ForegroundColor $CLR.OK
Write-Host "  └─ finished" -ForegroundColor $CLR.AccentLo
Start-Sleep -Milliseconds 150
Clear-Host

# ════════════════════════════════════════════════════════════
#   RESULTS
# ════════════════════════════════════════════════════════════
Write-Banner

$flagColor = if ($totalFlagged -gt 0) { $CLR.Accent } else { $CLR.OK }

_Top
_Row "  RESULTS  ─  $ts" $CLR.Accent
_Sep
_KV "  Path        " $scanPath $CLR.Muted $CLR.Label
_KV "  Scanned     " "$($jars.Count) file(s)  ·  $totalSize MB" $CLR.Muted $CLR.Value
_KV "  Signatures  " "$($signatures.Count) in database" $CLR.Muted $CLR.Value
_Sep
_KV "  Clean       " "$totalClean" $CLR.Muted $CLR.OK
_KV "  Errors      " "$totalErrors" $CLR.Muted $(if ($totalErrors -gt 0) { $CLR.Warn } else { $CLR.Muted })
_KV "  Flagged     " "$totalFlagged" $CLR.Muted $flagColor
_Bot
Write-Host ""

# ── Flagged detail ───────────────────────────────────────────
if ($flaggedMods.Count -gt 0) {

    _Top
    _Row ("  DETECTIONS  ─  $($flaggedMods.Count) file(s) matched Dqrkis signatures") $CLR.Accent

    $idx = 0
    foreach ($mod in $flaggedMods) {
        $idx++
        _Sep
        _Empty
        _KV "  [$idx]  " $mod.Name $CLR.Muted $CLR.Value
        _KV "       Path   " $mod.Path $CLR.Muted $CLR.Label
        _KV "       Size   " "$($mod.Size) KB" $CLR.Muted $CLR.Muted
        _KV "       Hits   " "$($mod.HitCount) signature(s)" $CLR.Muted $CLR.Accent
        _Empty

        $grouped = $mod.Hits | Group-Object -Property Entry | Sort-Object Name
        foreach ($group in $grouped) {
            $isCls   = $group.Name -match '\.class$'
            $tag     = if ($isCls) { "CLS" } else { "RES" }
            $tagClr  = if ($isCls) { $CLR.Class } else { $CLR.Res }

            # Entry path row
            $entryText = "  $tag  $($group.Name)"
            if ($entryText.Length -gt $W - 2) { $entryText = $entryText.Substring(0, $W - 5) + "…" }
            $right = [math]::Max(0, $W - $entryText.Length)
            _Pipe
            Write-Host ("  ") -NoNewline
            Write-Host $tag -ForegroundColor $tagClr -NoNewline
            $rest = "  " + $group.Name
            if ($rest.Length -gt $W - 6) { $rest = $rest.Substring(0, $W - 9) + "…" }
            $r2 = [math]::Max(0, $W - 2 - $tag.Length - $rest.Length)
            Write-Host $rest -ForegroundColor $CLR.Muted -NoNewline
            Write-Host (" " * $r2 + "│") -ForegroundColor $CLR.Border

            # Individual signatures
            foreach ($h in $group.Group) {
                $sig = $h.Signature
                _KV "       ·  " $sig $CLR.Muted $CLR.Hit
            }
        }
        _Empty
    }
    _Bot
    Write-Host ""
    _Top
    _Row "  VERDICT  ─  Dqrkis client signatures confirmed. Review files above." $CLR.Accent
    _Bot

} else {
    _Top
    _Row "  ALL CLEAR  ─  No Dqrkis signatures detected across all scanned files." $CLR.OK
    _Bot
}

# ── Footer ───────────────────────────────────────────────────
Write-Host ""
Write-Host ("  " + ([string][char]0x2500 * $W)) -ForegroundColor $CLR.Muted
Write-Host "  discord: cheese_cat0   ·   discord: mecz.exe   ·   Special thanks to Nic" -ForegroundColor $CLR.Muted
Write-Host ("  " + ([string][char]0x2500 * $W)) -ForegroundColor $CLR.Muted
Write-Host ""
Write-Host "  Press any key to exit" -ForegroundColor $CLR.Muted
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
