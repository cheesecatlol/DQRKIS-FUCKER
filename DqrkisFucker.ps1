# ============================================================
#   DQRKIS FUCKER  -  Cheat Client Detector
#   Scans .jar files for known Dqrkis client signatures
# ============================================================
#   discord : cheese_cat0
#   discord : mecz.exe
#   Special thanks to Nic for helping me
# ============================================================

Add-Type -AssemblyName System.IO.Compression.FileSystem

$Host.UI.RawUI.WindowTitle = "Dqrkis Fucker — Cheat Scanner"

# ── Colour palette ──────────────────────────────────────────
$C = @{
    Banner      = 'Red'
    Accent      = 'Cyan'
    Dim         = 'DarkGray'
    OK          = 'Green'
    Warn        = 'DarkYellow'
    Bad         = 'Red'
    BadDim      = 'DarkRed'
    Hit         = 'Yellow'
    White       = 'White'
}

# ── Helpers ─────────────────────────────────────────────────
function Write-Rule {
    param([string]$Color = $C.Dim, [int]$Width = 82)
    Write-Host ("  " + ([string][char]0x2500 * $Width)) -ForegroundColor $Color
}

function Write-Section {
    param([string]$Title, [string]$Color = $C.Accent)
    Write-Rule -Color $Color
    Write-Host "  $Title" -ForegroundColor $Color
    Write-Rule -Color $Color
}

function Write-Banner {
    Clear-Host
    Write-Host ""

    $lines = @(
        " /$$$$$$$   /$$$$$$  /$$$$$$$  /$$   /$$ /$$$$$$  /$$$$$$",
        "| $$__  $$ /$$__  $$| $$__  $$| $$  /$$/|_  $$_/ /$$__  $$",
        "| $$  \ $$| $$  \ $$| $$  \ $$| $$ /$$/   | $$  | $$  \__/",
        "| $$  | $$| $$  | $$| $$$$$$$/| $$$$$/    | $$  |  $$$$$$ ",
        "| $$  | $$| $$  | $$| $$__  $$| $$  $$    | $$   \____  $$",
        "| $$  | $$| $$  | $$| $$  \ $$| $$\  $$   | $$   /$$  \ $$",
        "| $$$$$$$/|  $$$$$$/| $$  | $$| $$ \  $$ /$$$$$$|  $$$$$$/",
        "|_______/  \______/ |__/  |__/|__/  \__/|______/ \______/ ",
        "",
        "        F U C K E R   —   C H E A T   C L I E N T   D E T E C T O R"
    )

    foreach ($line in $lines) {
        Write-Host ("    " + $line) -ForegroundColor $C.Banner
    }

    Write-Host ""
    Write-Rule -Color $C.Dim
    Write-Host ("  {0,-40} {1,40}" -f "  discord: cheese_cat0  |  discord: mecz.exe", "Special thanks to Nic") -ForegroundColor $C.Dim
    Write-Rule -Color $C.Dim
    Write-Host ""
}

# ── Signature list ───────────────────────────────────────────
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
    "bottle_throw","trigger_bot","nametags","auto_web",
    "SHOP_END","SHOP_ITEM","SHOP_GLASS_PANE","SHOP_BUY",
    "SHOP_CONFIRM","SHOP_CHECK_FULL","SHOP_EXIT",
    "TARGET_ORDERS","ORDERS_SELECT","ORDERS_EXIT","ORDERS_CONFIRM","ORDERS_FINAL_EXIT",
    "CYCLE_PAUSE","PLACE_OBI","WAIT_OBI","PLACE_CRYSTAL","BREAK_CRYSTAL",
    "ROTATING_DOWN","THROWING","ROTATING_BACK","REFILLING",
    "PLANTING","BONEMEALING","MINING",
    "ParseJ.a","CacheE.MISC","CacheE.RENDER","CacheE.CT",
    "CheckC","CoreH","cn`$MacroState","co`$State"
)

# ── String extractor ─────────────────────────────────────────
function Get-StringsFromBytes {
    param([byte[]]$bytes)
    $results = [System.Collections.Generic.List[string]]::new()
    $current = [System.Text.StringBuilder]::new()
    foreach ($b in $bytes) {
        if ($b -ge 0x20 -and $b -le 0x7E) {
            [void]$current.Append([char]$b)
        } else {
            if ($current.Length -ge 4) { [void]$results.Add($current.ToString()) }
            [void]$current.Clear()
        }
    }
    if ($current.Length -ge 4) { [void]$results.Add($current.ToString()) }
    return $results
}

# ── Jar scanner ──────────────────────────────────────────────
function Invoke-ScanJar {
    param([string]$jarPath)
    $hits = [System.Collections.Generic.List[PSCustomObject]]::new()

    try {
        $archive = [System.IO.Compression.ZipFile]::OpenRead($jarPath)

        foreach ($entry in $archive.Entries) {
            if ($entry.FullName -notmatch '\.(class|json|txt|cfg|properties|yml|yaml|toml)$') { continue }

            try {
                $entryStream = $entry.Open()
                $ms = [System.IO.MemoryStream]::new()
                $entryStream.CopyTo($ms)
                $entryStream.Dispose()
                $entryBytes   = $ms.ToArray()
                $ms.Dispose()
                $entryStrings = Get-StringsFromBytes -bytes $entryBytes

                foreach ($sig in $signatures) {
                    $pattern = [regex]::Escape($sig)
                    foreach ($str in $entryStrings) {
                        if ($str -match $pattern) {
                            [void]$hits.Add([PSCustomObject]@{ Signature = $sig; Entry = $entry.FullName })
                            break
                        }
                    }
                }
            } catch { }
        }

        $archive.Dispose()
    } catch {
        Write-Host "  [!] Could not read: $(Split-Path $jarPath -Leaf)" -ForegroundColor $C.Warn
        return $null
    }

    return $hits
}

# ── Progress bar ─────────────────────────────────────────────
function Write-Progress-Bar {
    param([int]$Current, [int]$Total, [string]$Label)
    $pct    = [math]::Floor(($Current / $Total) * 100)
    $filled = [math]::Floor($pct / 2)
    $empty  = 50 - $filled
    $bar    = ([string][char]0x2588 * $filled) + ([string][char]0x2591 * $empty)
    $name   = $Label.PadRight(38).Substring(0, [math]::Min(38, $Label.Length))
    [Console]::Write("  [{0}] {1,3}%  {2}`r" -f $bar, $pct, $name)
}

# ════════════════════════════════════════════════════════════
#   MAIN
# ════════════════════════════════════════════════════════════
Write-Banner

Write-Host "  Enter the folder path to scan (drag & drop works):" -ForegroundColor $C.Accent
Write-Host "  > " -ForegroundColor $C.White -NoNewline
$scanPath = (Read-Host).Trim().Trim('"')

Write-Host ""

if (-not (Test-Path $scanPath -PathType Container)) {
    Write-Host "  [ERROR] Path not found or not a directory:" -ForegroundColor $C.Bad
    Write-Host "          $scanPath" -ForegroundColor $C.BadDim
    Write-Host ""
    Read-Host "  Press Enter to exit"
    exit 1
}

$jars = Get-ChildItem -Path $scanPath -Recurse -Filter "*.jar" -ErrorAction SilentlyContinue

if ($jars.Count -eq 0) {
    Write-Host "  [!] No .jar files found in:" -ForegroundColor $C.Warn
    Write-Host "      $scanPath" -ForegroundColor $C.Dim
    Write-Host ""
    Read-Host "  Press Enter to exit"
    exit 0
}

Write-Host "  [+] Found $($jars.Count) jar(s) — starting scan..." -ForegroundColor $C.OK
Write-Host ""

$totalFlagged = 0
$totalClean   = 0
$totalErrors  = 0
$flaggedMods  = [System.Collections.Generic.List[PSCustomObject]]::new()
$i = 0

foreach ($jar in $jars) {
    $i++
    Write-Progress-Bar -Current $i -Total $jars.Count -Label $jar.Name

    $hits = Invoke-ScanJar -jarPath $jar.FullName

    if ($null -eq $hits) {
        $totalErrors++
        continue
    }

    if ($hits.Count -gt 0) {
        $totalFlagged++
        $flaggedMods.Add([PSCustomObject]@{
            Name     = $jar.Name
            Path     = $jar.FullName
            HitCount = $hits.Count
            Hits     = $hits
        })
    } else {
        $totalClean++
    }
}

# clear progress line
[Console]::Write(" " * 100 + "`r")

# ── Summary ──────────────────────────────────────────────────
Write-Host ""
Write-Section -Title "  SCAN COMPLETE  [$( Get-Date -Format 'yyyy-MM-dd HH:mm:ss' )]" -Color $C.Accent
Write-Host ""

$flagColor = if ($totalFlagged -gt 0) { $C.Bad } else { $C.OK }

Write-Host ("  {0,-20} {1}" -f "Jars scanned",  $jars.Count)       -ForegroundColor $C.White
Write-Host ("  {0,-20} {1}" -f "Clean",          $totalClean)       -ForegroundColor $C.OK
Write-Host ("  {0,-20} {1}" -f "Errors",         $totalErrors)      -ForegroundColor $C.Warn
Write-Host ("  {0,-20} {1}" -f "Flagged",        $totalFlagged)     -ForegroundColor $flagColor

Write-Host ""

# ── Flagged detail ───────────────────────────────────────────
if ($flaggedMods.Count -gt 0) {

    Write-Section -Title "  DETECTED JARS  —  $($flaggedMods.Count) file(s) matched Dqrkis signatures" -Color $C.Bad
    Write-Host ""

    foreach ($mod in $flaggedMods) {
        Write-Host "  $([char]0x250C)$([string][char]0x2500 * 2) DETECTED " -ForegroundColor $C.Bad -NoNewline
        Write-Host $mod.Name                                                 -ForegroundColor $C.White
        Write-Host "  $([char]0x2502)  Path    : $($mod.Path)"              -ForegroundColor $C.BadDim
        Write-Host "  $([char]0x2502)  Matches : $($mod.HitCount) signature(s)" -ForegroundColor $C.BadDim
        Write-Host "  $([char]0x251C)$([string][char]0x2500 * 2) Matched Strings:" -ForegroundColor $C.Bad

        $grouped = $mod.Hits | Group-Object -Property Entry
        foreach ($group in $grouped) {
            Write-Host "  $([char]0x2502)" -ForegroundColor $C.Bad
            Write-Host "  $([char]0x2502)  $([char]0x25B8) $($group.Name)" -ForegroundColor $C.Warn
            foreach ($h in $group.Group) {
                Write-Host "  $([char]0x2502)      $([char]0x2022) $($h.Signature)" -ForegroundColor $C.Hit
            }
        }

        Write-Host "  $([char]0x2514)$([string][char]0x2500 * 60)" -ForegroundColor $C.Bad
        Write-Host ""
    }

    Write-Host "  [!] Review flagged jars above — Dqrkis signatures found." -ForegroundColor $C.Bad

} else {
    Write-Host "  [OK] No Dqrkis signatures detected in any scanned jar." -ForegroundColor $C.OK
}

Write-Host ""
Write-Rule -Color $C.Dim
Write-Host "  discord: cheese_cat0   |   discord: mecz.exe   |   Special thanks to Nic" -ForegroundColor $C.Dim
Write-Rule -Color $C.Dim
Write-Host ""
Read-Host "  Press Enter to exit"
