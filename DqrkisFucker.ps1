# ============================================================
#   DQRKIS FUCKER  -  Cheat Client Detector
#   Scans .jar files for known Dqrkis client signatures
# ============================================================

$Host.UI.RawUI.WindowTitle = "Dqrkis Fucker - Cheat Scanner"

# Force-load compression assemblies via reflection (works on all PS versions)
$null = [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression")
$null = [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")

function Write-Banner {
    Clear-Host
    $banner = @"

  ██████╗  ██████╗ ██████╗ ██╗  ██╗██╗███████╗    ███████╗██╗   ██╗ ██████╗██╗  ██╗███████╗██████╗
  ██╔══██╗██╔═══██╗██╔══██╗██║ ██╔╝██║██╔════╝    ██╔════╝██║   ██║██╔════╝██║ ██╔╝██╔════╝██╔══██╗
  ██║  ██║██║   ██║██████╔╝█████╔╝ ██║███████╗    █████╗  ██║   ██║██║     █████╔╝ █████╗  ██████╔╝
  ██║  ██║██║▄▄ ██║██╔══██╗██╔═██╗ ██║╚════██║    ██╔══╝  ██║   ██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗
  ██████╔╝╚██████╔╝██║  ██║██║  ██╗██║███████║    ██║     ╚██████╔╝╚██████╗██║  ██╗███████╗██║  ██║
  ╚═════╝  ╚══▀▀═╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝   ╚═╝      ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝

"@
    Write-Host $banner -ForegroundColor Red
    Write-Host ("  " + ("─" * 95)) -ForegroundColor DarkGray
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

# ── Extract printable ASCII strings from raw bytes ───────────
function Get-StringsFromBytes {
    param([byte[]]$bytes)
    $results = [System.Collections.Generic.List[string]]::new()
    $sb      = [System.Text.StringBuilder]::new()
    foreach ($b in $bytes) {
        if ($b -ge 32 -and $b -le 126) {
            [void]$sb.Append([char]$b)
        } else {
            if ($sb.Length -ge 4) { [void]$results.Add($sb.ToString()) }
            [void]$sb.Clear()
        }
    }
    if ($sb.Length -ge 4) { [void]$results.Add($sb.ToString()) }
    return $results
}

# ── Scan a single jar ────────────────────────────────────────
function Invoke-ScanJar {
    param([string]$jarPath)

    $hits = [System.Collections.Generic.List[PSCustomObject]]::new()

    try {
        # Open as zip using ZipFile (requires FileSystem assembly)
        $archive = [System.IO.Compression.ZipFile]::OpenRead($jarPath)

        foreach ($entry in $archive.Entries) {
            $name = $entry.FullName
            if ($name -notmatch '\.(class|json|txt|cfg|properties|yml|yaml|toml)$') { continue }

            try {
                $stream = $entry.Open()
                $ms     = [System.IO.MemoryStream]::new()
                $stream.CopyTo($ms)
                $stream.Dispose()

                $bytes   = $ms.ToArray()
                $ms.Dispose()
                $strings = Get-StringsFromBytes -bytes $bytes

                foreach ($sig in $signatures) {
                    $pat = [regex]::Escape($sig)
                    foreach ($s in $strings) {
                        if ($s -match $pat) {
                            [void]$hits.Add([PSCustomObject]@{ Signature = $sig; Entry = $name })
                            break
                        }
                    }
                }
            } catch { }
        }

        $archive.Dispose()
    }
    catch {
        return $null   # signals read failure to caller
    }

    return $hits
}

# ── Entry point ──────────────────────────────────────────────
Write-Banner

Write-Host "  Enter the folder path to scan (drag & drop works):" -ForegroundColor Cyan
Write-Host "  > " -ForegroundColor White -NoNewline
$scanPath = (Read-Host).Trim().Trim('"')

if (-not (Test-Path $scanPath -PathType Container)) {
    Write-Host ""
    Write-Host "  [ERROR] Path not found: $scanPath" -ForegroundColor Red
    Write-Host ""
    Read-Host "  Press Enter to exit"
    exit 1
}

$jars = @(Get-ChildItem -Path $scanPath -Recurse -Filter "*.jar" -ErrorAction SilentlyContinue)

if ($jars.Count -eq 0) {
    Write-Host ""
    Write-Host "  [!] No .jar files found in: $scanPath" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "  Press Enter to exit"
    exit 0
}

Write-Host ""
Write-Host "  Found $($jars.Count) jar(s). Starting scan..." -ForegroundColor Green
Write-Host ("  " + ("─" * 95)) -ForegroundColor DarkGray
Write-Host ""

$totalFlagged = 0
$skipped      = 0

foreach ($jar in $jars) {
    Write-Host "  Scanning  $($jar.Name) ..." -ForegroundColor DarkGray -NoNewline

    $hits = Invoke-ScanJar -jarPath $jar.FullName

    if ($null -eq $hits) {
        Write-Host "  FAILED (unreadable)" -ForegroundColor DarkYellow
        $skipped++
        continue
    }

    if ($hits.Count -gt 0) {
        Write-Host ""
        Write-Host ""
        Write-Host "  ╔══ DETECTED: $($jar.Name)" -ForegroundColor Red
        Write-Host "  ║   Path    : $($jar.FullName)" -ForegroundColor DarkRed
        Write-Host "  ║   Matches : $($hits.Count) signature(s) found" -ForegroundColor DarkRed
        Write-Host "  ╠══ Matched Strings:" -ForegroundColor Red

        $grouped = $hits | Group-Object -Property Entry
        foreach ($grp in $grouped) {
            Write-Host "  ║" -ForegroundColor Red
            Write-Host "  ║   [File]  $($grp.Name)" -ForegroundColor DarkYellow
            foreach ($h in $grp.Group) {
                Write-Host "  ║     [-]  $($h.Signature)" -ForegroundColor Yellow
            }
        }

        Write-Host "  ╚══" -ForegroundColor Red
        Write-Host ""
        $totalFlagged++
    } else {
        Write-Host "  CLEAN" -ForegroundColor Green
    }
}

# ── Summary ──────────────────────────────────────────────────
Write-Host ""
Write-Host ("  " + ("─" * 95)) -ForegroundColor DarkGray
Write-Host ""
Write-Host "  SCAN COMPLETE" -ForegroundColor Cyan
Write-Host "  Jars scanned  : $($jars.Count)" -ForegroundColor White
Write-Host "  Flagged       : $totalFlagged" -ForegroundColor $(if ($totalFlagged -gt 0) { "Red" } else { "Green" })
Write-Host "  Clean         : $($jars.Count - $totalFlagged - $skipped)" -ForegroundColor Green
if ($skipped -gt 0) {
    Write-Host "  Skipped       : $skipped  (unreadable/corrupt)" -ForegroundColor DarkYellow
}
Write-Host ""
if ($totalFlagged -gt 0) {
    Write-Host "  [!] Dqrkis client signatures detected. Review flagged jars above." -ForegroundColor Red
} else {
    Write-Host "  [OK] No Dqrkis signatures detected in any scanned jar." -ForegroundColor Green
}

Write-Host ""
Write-Host ("  " + ("─" * 95)) -ForegroundColor DarkGray
Write-Host "  discord: cheese_cat0   |   discord: mecz.exe   |   Special thanks to Nic" -ForegroundColor DarkGray
Write-Host ("  " + ("─" * 95)) -ForegroundColor DarkGray
Write-Host ""
Read-Host "  Press Enter to exit"
