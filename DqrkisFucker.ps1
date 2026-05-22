#Requires -Version 5.1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
Add-Type -AssemblyName System.IO.Compression.FileSystem

# ================================================================
#  ANIMATION & DISPLAY HELPERS
# ================================================================

function Write-Animated {
    param([string[]]$Lines, [ConsoleColor]$Color = "Red", [int]$DelayMs = 18)
    foreach ($line in $Lines) {
        Write-Host $line -ForegroundColor $Color
        Start-Sleep -Milliseconds $DelayMs
    }
}

function Write-TypeOut {
    param([string]$Text, [ConsoleColor]$Color = "White", [int]$DelayMs = 12, [switch]$NoNewline)
    foreach ($char in $Text.ToCharArray()) {
        Write-Host $char -NoNewline -ForegroundColor $Color
        Start-Sleep -Milliseconds $DelayMs
    }
    if (-not $NoNewline) { Write-Host "" }
}

function Write-Spinner {
    param([string]$Message, [int]$DurationMs = 800)
    $frames = @("|", "/", "-", "\")
    $end = [DateTime]::Now.AddMilliseconds($DurationMs)
    $i = 0
    while ([DateTime]::Now -lt $end) {
        Write-Host "`r  $($frames[$i % 4])  $Message" -NoNewline -ForegroundColor DarkRed
        Start-Sleep -Milliseconds 80
        $i++
    }
    Write-Host "`r  $(" " * ($Message.Length + 6))`r" -NoNewline
}

function Write-Banner {
    Clear-Host
    Start-Sleep -Milliseconds 100

    $L1  = "  ██████╗  ██████╗ ██████╗ ██╗  ██╗██╗███████╗"
    $L2  = "  ██╔══██╗██╔═══██╗██╔══██╗██║ ██╔╝██║██╔════╝"
    $L3  = "  ██║  ██║██║   ██║██████╔╝█████╔╝ ██║███████╗"
    $L4  = "  ██║  ██║██║▄▄ ██║██╔══██╗██╔═██╗ ██║╚════██║"
    $L5  = "  ██████╔╝╚██████╔╝██║  ██║██║  ██╗██║███████║"
    $L6  = "  ╚═════╝  ╚══▀▀═╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝"

    $L7  = "  ███████╗██╗   ██╗ ██████╗██╗  ██╗███████╗██████╗ "
    $L8  = "  ██╔════╝██║   ██║██╔════╝██║ ██╔╝██╔════╝██╔══██╗"
    $L9  = "  █████╗  ██║   ██║██║     █████╔╝ █████╗  ██████╔╝"
    $L10 = "  ██╔══╝  ██║   ██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗"
    $L11 = "  ██║     ╚██████╔╝╚██████╗██║  ██╗███████╗██║  ██║"
    $L12 = "  ╚═╝      ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝"

    Write-Animated -Lines @($L1,$L2,$L3,$L4,$L5,$L6) -Color Red -DelayMs 20
    Write-Host ""
    Write-Animated -Lines @($L7,$L8,$L9,$L10,$L11,$L12) -Color DarkRed -DelayMs 20
    Write-Host ""

    Write-Host "  " -NoNewline
    Write-Host "  x X x X x  [ dqrkis fucker v1.0 ]  x X x X x  " -ForegroundColor DarkRed
    Write-Host ""
    Write-Host ("  " + "~" * 64) -ForegroundColor DarkRed
    Write-Host ""
}

function Write-SectionHeader {
    param([string]$Title, [ConsoleColor]$Color = "Red")
    Write-Host ""
    Write-Host ("  " + "~" * 64) -ForegroundColor DarkRed
    Write-Host "  $Title" -ForegroundColor $Color
    Write-Host ("  " + "~" * 64) -ForegroundColor DarkRed
    Write-Host ""
}

function Write-ProgressBar {
    param([int]$Current, [int]$Total, [string]$Label)
    if ($Total -eq 0) { return }
    $pct   = [Math]::Round(($Current / $Total) * 100)
    $filled = [Math]::Round(($Current / $Total) * 40)
    $empty  = 40 - $filled
    $bar    = ("█" * $filled) + ("░" * $empty)
    Write-Host "`r  [$bar] $pct%  $Label          " -NoNewline -ForegroundColor Red
}

# ================================================================
#  TARGET STRINGS
# ================================================================

$TargetStrings = @(
    # State machine / spawner macros
    "FINDING_SPAWNER","OPENING_SPAWNER","WAITING_SPAWNER_GUI","LOOTING_BONES","CLOSING_SPAWNER",
    "ORDER_COMMAND","WAIT_ORDER_GUI","SELECT_ORDER_ITEM","WAIT_DELIVERY_GUI","DELIVERING_BONES",
    "WAIT_AFTER_DELIVERY_1","CLOSING_DELIVERY","WAIT_AFTER_CLOSE_DELIVERY",
    "WAIT_CONFIRM_GUI","WAIT_CONFIRM_SETTLE","CLICK_CONFIRM_SLOT",
    "WAIT_AFTER_CONFIRM_1","WAIT_AFTER_CONFIRM_2","WAIT_AFTER_CONFIRM_3",
    "DOUBLE_ESCAPE","DOUBLE_RIGHTCLICK_FIRST","DOUBLE_RIGHTCLICK_SECOND","POST_CYCLE_DELAY",

    # Named cheats / modules
    "mace_swap","quick_strike","loot_yeeter","auto_jump_reset","macro_198",
    "stun_slam","safe_anchor","double_anchor","auto_pot_refill","totem_offhand",
    "walksy_optimizer","key_pearl","aim_assist","auto_neth_pot","auto_dtap",
    "bottle_throw","trigger_bot","nametags","auto_web",

    # Shop macro states
    "SHOP","SHOP_END","SHOP_ITEM","SHOP_GLASS_PANE","SHOP_BUY",
    "SHOP_CONFIRM","SHOP_CHECK_FULL","SHOP_EXIT",

    # Order macro states
    "TARGET_ORDERS","ORDERS_SELECT","ORDERS_EXIT","ORDERS_CONFIRM","ORDERS_FINAL_EXIT","CYCLE_PAUSE",

    # Crystal / obi / farming automation
    "PLACE_OBI","WAIT_OBI","PLACE_CRYSTAL","BREAK_CRYSTAL",
    "ROTATING_DOWN","THROWING","ROTATING_BACK","REFILLING",
    "PLANTING","BONEMEALING","MINING",

    # Internal class / obfuscation signatures
    "ParseJ.a","CacheE.MISC","CacheE.RENDER","CacheE.CT",
    "CheckC","CoreH","cn`$MacroState","co`$State"
)

# Clean version without escapes for display
$TargetStringsClean = @(
    "FINDING_SPAWNER","OPENING_SPAWNER","WAITING_SPAWNER_GUI","LOOTING_BONES","CLOSING_SPAWNER",
    "ORDER_COMMAND","WAIT_ORDER_GUI","SELECT_ORDER_ITEM","WAIT_DELIVERY_GUI","DELIVERING_BONES",
    "WAIT_AFTER_DELIVERY_1","CLOSING_DELIVERY","WAIT_AFTER_CLOSE_DELIVERY",
    "WAIT_CONFIRM_GUI","WAIT_CONFIRM_SETTLE","CLICK_CONFIRM_SLOT",
    "WAIT_AFTER_CONFIRM_1","WAIT_AFTER_CONFIRM_2","WAIT_AFTER_CONFIRM_3",
    "DOUBLE_ESCAPE","DOUBLE_RIGHTCLICK_FIRST","DOUBLE_RIGHTCLICK_SECOND","POST_CYCLE_DELAY",
    "mace_swap","quick_strike","loot_yeeter","auto_jump_reset","macro_198",
    "stun_slam","safe_anchor","double_anchor","auto_pot_refill","totem_offhand",
    "walksy_optimizer","key_pearl","aim_assist","auto_neth_pot","auto_dtap",
    "bottle_throw","trigger_bot","nametags","auto_web",
    "SHOP","SHOP_END","SHOP_ITEM","SHOP_GLASS_PANE","SHOP_BUY",
    "SHOP_CONFIRM","SHOP_CHECK_FULL","SHOP_EXIT",
    "TARGET_ORDERS","ORDERS_SELECT","ORDERS_EXIT","ORDERS_CONFIRM","ORDERS_FINAL_EXIT","CYCLE_PAUSE",
    "PLACE_OBI","WAIT_OBI","PLACE_CRYSTAL","BREAK_CRYSTAL",
    "ROTATING_DOWN","THROWING","ROTATING_BACK","REFILLING",
    "PLANTING","BONEMEALING","MINING",
    "ParseJ.a","CacheE.MISC","CacheE.RENDER","CacheE.CT",
    "CheckC","CoreH","cn`$MacroState","co`$State"
)

$ScanExtensions = [System.Collections.Generic.HashSet[string]]::new(
    [string[]]@(".class",".json",".txt",".toml",".cfg",".properties",".js",".yml",".yaml")
)

# ================================================================
#  SCAN FUNCTION
# ================================================================

function Invoke-DeepScan {
    param([string]$JarPath)

    $hits    = [System.Collections.Generic.List[string]]::new()
    $zipPath = $JarPath

    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
    } catch {
        return $hits
    }

    try {
        foreach ($entry in $zip.Entries) {
            $ext = [System.IO.Path]::GetExtension($entry.FullName).ToLower()
            if (-not $ScanExtensions.Contains($ext)) { continue }

            try {
                $stream = $entry.Open()
                $reader = [System.IO.StreamReader]::new($stream, [System.Text.Encoding]::UTF8, $true)
                $content = $reader.ReadToEnd()
                $reader.Dispose()
                $stream.Dispose()
            } catch { continue }

            foreach ($sig in $TargetStringsClean) {
                if ($content.IndexOf($sig, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                    if (-not $hits.Contains($sig)) {
                        $hits.Add($sig)
                    }
                }
            }
        }
    } finally {
        $zip.Dispose()
    }

    return $hits
}

# ================================================================
#  ENTRY POINT
# ================================================================

Write-Banner

Write-Host "  " -NoNewline
Write-Host " ABOUT " -ForegroundColor White -BackgroundColor DarkRed -NoNewline
Write-Host "  Scans .jar mod files for dqrkis / cheat strings" -ForegroundColor DarkGray
Write-Host ""
Write-Host ("  " + "~" * 64) -ForegroundColor DarkRed
Write-Host ""

# --- PATH INPUT ---
Write-Host "  Enter the path to your mods folder:" -ForegroundColor Red
Write-Host "  " -NoNewline
$modsPath = Read-Host

Write-Host ""

if (-not (Test-Path $modsPath)) {
    Write-Host "  " -NoNewline
    Write-Host " ERROR " -ForegroundColor White -BackgroundColor DarkRed -NoNewline
    Write-Host "  Path does not exist: $modsPath" -ForegroundColor Red
    Write-Host ""
    Read-Host "  Press Enter to exit"
    exit 1
}

$jarFiles = @(Get-ChildItem -Path $modsPath -Recurse -Filter "*.jar" -ErrorAction SilentlyContinue)

if ($jarFiles.Count -eq 0) {
    Write-Host "  " -NoNewline
    Write-Host " WARNING " -ForegroundColor Black -BackgroundColor Yellow -NoNewline
    Write-Host "  No .jar files found in: $modsPath" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "  Press Enter to exit"
    exit 0
}

Write-Host ("  " + "~" * 64) -ForegroundColor DarkRed
Write-Host "  Found " -NoNewline -ForegroundColor DarkGray
Write-Host "$($jarFiles.Count)" -NoNewline -ForegroundColor White
Write-Host " jar file(s) — starting deep scan..." -ForegroundColor DarkGray
Write-Host ("  " + "~" * 64) -ForegroundColor DarkRed
Write-Host ""

# ================================================================
#  SCAN LOOP
# ================================================================

$flaggedMods   = [System.Collections.Generic.List[hashtable]]::new()
$cleanMods     = [System.Collections.Generic.List[string]]::new()
$errorMods     = [System.Collections.Generic.List[string]]::new()
$totalScanned  = 0

foreach ($jar in $jarFiles) {
    $totalScanned++
    Write-ProgressBar -Current $totalScanned -Total $jarFiles.Count -Label $jar.Name

    try {
        $hits = Invoke-DeepScan -JarPath $jar.FullName
        if ($hits.Count -gt 0) {
            $flaggedMods.Add(@{ File = $jar.Name; Path = $jar.FullName; Hits = $hits })
        } else {
            $cleanMods.Add($jar.Name)
        }
    } catch {
        $errorMods.Add($jar.Name)
    }
}

Write-Host ""
Write-Host ""

# ================================================================
#  RESULTS
# ================================================================

$sep = "  " + ("─" * 70)

# --- FLAGGED ---
if ($flaggedMods.Count -gt 0) {
    Write-Host ""
    Write-Host ("  " + "~" * 64) -ForegroundColor DarkRed
    Write-Host "  " -NoNewline
    Write-Host " !! " -ForegroundColor White -BackgroundColor DarkRed -NoNewline
    Write-Host "  FLAGGED MODS  ($($flaggedMods.Count))" -ForegroundColor Red
    Write-Host ("  " + "~" * 64) -ForegroundColor DarkRed
    Write-Host ""

    foreach ($m in $flaggedMods) {
        Write-Host $sep -ForegroundColor DarkRed
        Write-Host "  │ " -ForegroundColor DarkRed -NoNewline
        Write-Host " FLAGGED " -ForegroundColor White -BackgroundColor DarkRed -NoNewline
        Write-Host "  $($m.File)" -ForegroundColor Yellow
        Write-Host ("  │ " + ("─" * 66)) -ForegroundColor DarkRed
        Write-Host "  │  " -ForegroundColor DarkRed -NoNewline
        Write-Host "Path: " -NoNewline -ForegroundColor DarkGray
        $displayPath = if ($m.Path.Length -gt 58) { "..." + $m.Path.Substring($m.Path.Length - 55) } else { $m.Path }
        Write-Host $displayPath -ForegroundColor DarkGray
        Write-Host ("  │ " + ("─" * 66)) -ForegroundColor DarkRed
        Write-Host "  │  " -ForegroundColor DarkRed -NoNewline
        Write-Host "Matched strings ($($m.Hits.Count)):" -ForegroundColor DarkGray
        Write-Host "  │" -ForegroundColor DarkRed

        foreach ($hit in $m.Hits) {
            Write-Host "  │  " -ForegroundColor DarkRed -NoNewline
            Write-Host "◉ " -ForegroundColor Red -NoNewline
            Write-Host $hit -ForegroundColor White
        }

        Write-Host "  │" -ForegroundColor DarkRed
        Write-Host $sep -ForegroundColor DarkRed
        Write-Host ""
    }
}

# --- CLEAN ---
if ($cleanMods.Count -gt 0) {
    Write-Host ""
    Write-Host ("  " + "~" * 64) -ForegroundColor DarkGreen
    Write-Host "  " -NoNewline
    Write-Host " OK " -ForegroundColor Black -BackgroundColor DarkGreen -NoNewline
    Write-Host "  CLEAN MODS  ($($cleanMods.Count))" -ForegroundColor Green
    Write-Host ("  " + "~" * 64) -ForegroundColor DarkGreen
    Write-Host ""
    foreach ($c in $cleanMods) {
        Write-Host "  " -NoNewline
        Write-Host "✓ " -NoNewline -ForegroundColor Green
        Write-Host $c -ForegroundColor DarkGray
    }
    Write-Host ""
}

# --- ERRORS ---
if ($errorMods.Count -gt 0) {
    Write-Host ""
    Write-Host ("  " + "~" * 64) -ForegroundColor DarkYellow
    Write-Host "  " -NoNewline
    Write-Host " ! " -ForegroundColor Black -BackgroundColor DarkYellow -NoNewline
    Write-Host "  UNREADABLE / ERRORED  ($($errorMods.Count))" -ForegroundColor Yellow
    Write-Host ("  " + "~" * 64) -ForegroundColor DarkYellow
    Write-Host ""
    foreach ($e in $errorMods) {
        Write-Host "  " -NoNewline
        Write-Host "? " -NoNewline -ForegroundColor Yellow
        Write-Host $e -ForegroundColor DarkGray
    }
    Write-Host ""
}

# ================================================================
#  SUMMARY
# ================================================================

$sumSep = "  " + ("~" * 64)

Write-Host ""
Write-Host $sumSep -ForegroundColor Red
Write-Host "  SUMMARY" -ForegroundColor Red
Write-Host $sumSep -ForegroundColor Red
Write-Host ""
Write-Host "  Total scanned  : " -NoNewline -ForegroundColor DarkGray; Write-Host "$totalScanned" -ForegroundColor White
Write-Host "  Flagged mods   : " -NoNewline -ForegroundColor DarkGray
if ($flaggedMods.Count -gt 0) { Write-Host "$($flaggedMods.Count)" -ForegroundColor Red } else { Write-Host "0" -ForegroundColor Green }
Write-Host "  Clean mods     : " -NoNewline -ForegroundColor DarkGray; Write-Host "$($cleanMods.Count)" -ForegroundColor Green
Write-Host "  Errored        : " -NoNewline -ForegroundColor DarkGray
if ($errorMods.Count -gt 0) { Write-Host "$($errorMods.Count)" -ForegroundColor Yellow } else { Write-Host "0" -ForegroundColor Green }
Write-Host ""
Write-Host $sumSep -ForegroundColor Red
Write-Host ""

if ($flaggedMods.Count -gt 0) {
    Write-Host "  " -NoNewline
    Write-Host " !! CHEAT STRINGS DETECTED — check the flagged mods above !! " -ForegroundColor White -BackgroundColor DarkRed
} else {
    Write-Host "  " -NoNewline
    Write-Host " No target strings found. Mods look clean. " -ForegroundColor Black -BackgroundColor DarkGreen
}

Write-Host ""
Write-Host "  Scan complete. " -NoNewline -ForegroundColor White
Write-Host "x" -ForegroundColor Red
Write-Host ""
Write-Host $sumSep -ForegroundColor DarkRed
Write-Host ""
Read-Host "  Press Enter to exit"
