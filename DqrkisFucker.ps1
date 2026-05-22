# ============================================================
#   DQRKIS FUCKER 
#  Cheese & Nic
# ============================================================
#   discord : cheese_cat0
#   discord : mecz.exe
#   Special thanks to Nic for helping me
# ============================================================

Add-Type -AssemblyName "System.IO.Compression"
Add-Type -AssemblyName "System.IO.Compression.FileSystem"

$Host.UI.RawUI.WindowTitle = "Dqrkis Fucker - Cheat Scanner"

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
    Write-Host "  [$( Get-Date -Format 'yyyy-MM-dd HH:mm:ss' )]  Dqrkis Cheat Client Detector" -ForegroundColor DarkGray
    Write-Host "  discord: cheese_cat0   |   discord: mecz.exe   |   Special thanks to Nic" -ForegroundColor DarkGray
    Write-Host ("  " + ("─" * 95)) -ForegroundColor DarkGray
    Write-Host ""
}

$signatures = @(
    "FINDING_SPAWNER", "OPENING_SPAWNER", "WAITING_SPAWNER_GUI", "LOOTING_BONES",
    "CLOSING_SPAWNER", "ORDER_COMMAND", "WAIT_ORDER_GUI", "SELECT_ORDER_ITEM",
    "WAIT_DELIVERY_GUI", "DELIVERING_BONES", "WAIT_AFTER_DELIVERY_1",
    "CLOSING_DELIVERY", "WAIT_AFTER_CLOSE_DELIVERY", "WAIT_CONFIRM_GUI",
    "WAIT_CONFIRM_SETTLE", "CLICK_CONFIRM_SLOT", "WAIT_AFTER_CONFIRM_1",
    "WAIT_AFTER_CONFIRM_2", "WAIT_AFTER_CONFIRM_3", "DOUBLE_ESCAPE",
    "DOUBLE_RIGHTCLICK_FIRST", "DOUBLE_RIGHTCLICK_SECOND", "POST_CYCLE_DELAY",
    "mace_swap", "quick_strike", "loot_yeeter", "auto_jump_reset", "macro_198",
    "stun_slam", "safe_anchor", "double_anchor", "auto_pot_refill", "totem_offhand",
    "walksy_optimizer", "key_pearl", "aim_assist", "auto_neth_pot", "auto_dtap",
    "bottle_throw", "trigger_bot", "nametags", "auto_web",
    "SHOP_END", "SHOP_ITEM", "SHOP_GLASS_PANE", "SHOP_BUY",
    "SHOP_CONFIRM", "SHOP_CHECK_FULL", "SHOP_EXIT",
    "TARGET_ORDERS", "ORDERS_SELECT", "ORDERS_EXIT", "ORDERS_CONFIRM", "ORDERS_FINAL_EXIT",
    "CYCLE_PAUSE", "PLACE_OBI", "WAIT_OBI", "PLACE_CRYSTAL", "BREAK_CRYSTAL",
    "ROTATING_DOWN", "THROWING", "ROTATING_BACK", "REFILLING",
    "PLANTING", "BONEMEALING", "MINING",
    "ParseJ.a", "CacheE.MISC", "CacheE.RENDER", "CacheE.CT",
    "CheckC", "CoreH", "cn`$MacroState", "co`$State"
)

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

function Invoke-ScanJar {
    param([string]$jarPath)

    # Each hit: [psobject] with Signature, Entry
    $hits    = [System.Collections.Generic.List[PSCustomObject]]::new()
    $jarName = Split-Path $jarPath -Leaf

    try {
        $fileStream = [System.IO.File]::OpenRead($jarPath)
        $archive    = [System.IO.Compression.ZipArchive]::new($fileStream, [System.IO.Compression.ZipArchiveMode]::Read, $false)

        foreach ($entry in $archive.Entries) {
            if ($entry.FullName -notmatch '\.(class|json|txt|cfg|properties|yml|yaml|toml)$') { continue }

            try {
                $entryStream = $entry.Open()
                $ms          = [System.IO.MemoryStream]::new()
                $entryStream.CopyTo($ms)
                $entryStream.Dispose()

                $entryBytes   = $ms.ToArray()
                $ms.Dispose()
                $entryStrings = Get-StringsFromBytes -bytes $entryBytes

                foreach ($sig in $signatures) {
                    $pattern = [regex]::Escape($sig)
                    $matched = $false
                    foreach ($str in $entryStrings) {
                        if ($str -match $pattern) {
                            $matched = $true
                            break
                        }
                    }
                    if ($matched) {
                        [void]$hits.Add([PSCustomObject]@{ Signature = $sig; Entry = $entry.FullName })
                    }
                }
            } catch {
                # skip unreadable entries silently
            }
        }

        $archive.Dispose()
        $fileStream.Dispose()
    }
    catch {
        Write-Host "  [!] Could not read: $jarName  ($($_.Exception.Message))" -ForegroundColor DarkYellow
        return $null
    }

    return $hits
}

# ── Main ────────────────────────────────────────────────────
Write-Banner

Write-Host "  Enter the folder path to scan (drag & drop works):" -ForegroundColor Cyan
Write-Host "  > " -ForegroundColor White -NoNewline
$scanPath = Read-Host
$scanPath = $scanPath.Trim().Trim('"')

if (-not (Test-Path $scanPath -PathType Container)) {
    Write-Host ""
    Write-Host "  [ERROR] Path not found or not a directory: $scanPath" -ForegroundColor Red
    Write-Host ""
    Read-Host "  Press Enter to exit"
    exit 1
}

$jars = Get-ChildItem -Path $scanPath -Recurse -Filter "*.jar" -ErrorAction SilentlyContinue

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

foreach ($jar in $jars) {
    Write-Host "  Scanning  $($jar.Name) ..." -ForegroundColor DarkGray -NoNewline

    $hits = Invoke-ScanJar -jarPath $jar.FullName

    if ($null -eq $hits) {
        # error already printed inside function
        continue
    }

    if ($hits.Count -gt 0) {
        Write-Host ""
        Write-Host ""
        Write-Host "  ╔══ DETECTED: $($jar.Name)" -ForegroundColor Red
        Write-Host "  ║   Path     : $($jar.FullName)" -ForegroundColor DarkRed
        Write-Host "  ║   Matches  : $($hits.Count) signature(s) found" -ForegroundColor DarkRed
        Write-Host "  ╠══ Matched Strings:" -ForegroundColor Red

        # Group by entry file for clarity
        $grouped = $hits | Group-Object -Property Entry
        foreach ($group in $grouped) {
            Write-Host "  ║" -ForegroundColor Red
            Write-Host "  ║   [Class]  $($group.Name)" -ForegroundColor DarkYellow
            foreach ($h in $group.Group) {
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

# ── Summary ─────────────────────────────────────────────────
Write-Host ""
Write-Host ("  " + ("─" * 95)) -ForegroundColor DarkGray
Write-Host ""
Write-Host "  SCAN COMPLETE" -ForegroundColor Cyan
Write-Host "  Jars scanned  : $($jars.Count)" -ForegroundColor White
Write-Host "  Flagged       : $totalFlagged" -ForegroundColor $(if ($totalFlagged -gt 0) { "Red" } else { "Green" })
Write-Host "  Clean         : $($jars.Count - $totalFlagged)" -ForegroundColor Green
Write-Host ""

if ($totalFlagged -gt 0) {
    Write-Host "  [!] Dqrkis client signatures were found. Review flagged jars above." -ForegroundColor Red
} else {
    Write-Host "  [OK] No Dqrkis signatures detected in any scanned jar." -ForegroundColor Green
}

Write-Host ""
Write-Host "  discord: cheese_cat0   |   discord: mecz.exe   |   Special thanks to Nic" -ForegroundColor DarkGray
Write-Host ""
Read-Host "  Press Enter to exit"
