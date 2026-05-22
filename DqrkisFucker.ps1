# ============================================================
#   DQRKIS FUCKER  -  Cheat Client Detector
#   Scans .jar files for known Dqrkis client signatures
# ============================================================

$Host.UI.RawUI.WindowTitle = "Dqrkis Fucker - Cheat Scanner"

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

# ── Signature definitions ─────────────────────────────────────────────────────
# Each entry: @{ Pattern = "..."; Exact = $true/$false }
# Exact = $true  → must match as a whole word / exact string (no substring hits)
# Exact = $false → substring match is fine (unique enough strings)
$signatureDefs = @(
    # Macro states — unique enough, substring ok
    @{ Pattern = "FINDING_SPAWNER";          Exact = $false }
    @{ Pattern = "OPENING_SPAWNER";          Exact = $false }
    @{ Pattern = "WAITING_SPAWNER_GUI";      Exact = $false }
    @{ Pattern = "LOOTING_BONES";            Exact = $false }
    @{ Pattern = "CLOSING_SPAWNER";          Exact = $false }
    @{ Pattern = "ORDER_COMMAND";            Exact = $false }
    @{ Pattern = "WAIT_ORDER_GUI";           Exact = $false }
    @{ Pattern = "SELECT_ORDER_ITEM";        Exact = $false }
    @{ Pattern = "WAIT_DELIVERY_GUI";        Exact = $false }
    @{ Pattern = "DELIVERING_BONES";         Exact = $false }
    @{ Pattern = "WAIT_AFTER_DELIVERY_1";    Exact = $false }
    @{ Pattern = "CLOSING_DELIVERY";         Exact = $false }
    @{ Pattern = "WAIT_AFTER_CLOSE_DELIVERY";Exact = $false }
    @{ Pattern = "WAIT_CONFIRM_GUI";         Exact = $false }
    @{ Pattern = "WAIT_CONFIRM_SETTLE";      Exact = $false }
    @{ Pattern = "CLICK_CONFIRM_SLOT";       Exact = $false }
    @{ Pattern = "WAIT_AFTER_CONFIRM_1";     Exact = $false }
    @{ Pattern = "WAIT_AFTER_CONFIRM_2";     Exact = $false }
    @{ Pattern = "WAIT_AFTER_CONFIRM_3";     Exact = $false }
    @{ Pattern = "DOUBLE_ESCAPE";            Exact = $false }
    @{ Pattern = "DOUBLE_RIGHTCLICK_FIRST";  Exact = $false }
    @{ Pattern = "DOUBLE_RIGHTCLICK_SECOND"; Exact = $false }
    @{ Pattern = "POST_CYCLE_DELAY";         Exact = $false }

    # Module names — exact match to avoid "totem_offhand" hitting "totemcounter" etc.
    @{ Pattern = "mace_swap";        Exact = $true }
    @{ Pattern = "quick_strike";     Exact = $true }
    @{ Pattern = "loot_yeeter";      Exact = $true }
    @{ Pattern = "auto_jump_reset";  Exact = $true }
    @{ Pattern = "macro_198";        Exact = $true }
    @{ Pattern = "stun_slam";        Exact = $true }
    @{ Pattern = "safe_anchor";      Exact = $true }
    @{ Pattern = "double_anchor";    Exact = $true }
    @{ Pattern = "auto_pot_refill";  Exact = $true }
    @{ Pattern = "totem_offhand";    Exact = $true }
    @{ Pattern = "walksy_optimizer"; Exact = $true }
    @{ Pattern = "key_pearl";        Exact = $true }
    @{ Pattern = "aim_assist";       Exact = $true }
    @{ Pattern = "auto_neth_pot";    Exact = $true }
    @{ Pattern = "auto_dtap";        Exact = $true }
    @{ Pattern = "bottle_throw";     Exact = $true }
    @{ Pattern = "trigger_bot";      Exact = $true }
    @{ Pattern = "nametags";         Exact = $true }   # exact only — too generic as substring
    @{ Pattern = "auto_web";         Exact = $true }

    # Shop states
    @{ Pattern = "SHOP_END";         Exact = $false }
    @{ Pattern = "SHOP_ITEM";        Exact = $false }
    @{ Pattern = "SHOP_GLASS_PANE";  Exact = $false }
    @{ Pattern = "SHOP_BUY";         Exact = $false }
    @{ Pattern = "SHOP_CONFIRM";     Exact = $false }
    @{ Pattern = "SHOP_CHECK_FULL";  Exact = $false }
    @{ Pattern = "SHOP_EXIT";        Exact = $false }

    # Order states
    @{ Pattern = "TARGET_ORDERS";       Exact = $false }
    @{ Pattern = "ORDERS_SELECT";       Exact = $false }
    @{ Pattern = "ORDERS_EXIT";         Exact = $false }
    @{ Pattern = "ORDERS_CONFIRM";      Exact = $false }
    @{ Pattern = "ORDERS_FINAL_EXIT";   Exact = $false }

    # Crystal / misc states — MINING and similar are exact only
    @{ Pattern = "CYCLE_PAUSE";    Exact = $false }
    @{ Pattern = "PLACE_OBI";      Exact = $false }
    @{ Pattern = "WAIT_OBI";       Exact = $false }
    @{ Pattern = "PLACE_CRYSTAL";  Exact = $false }
    @{ Pattern = "BREAK_CRYSTAL";  Exact = $false }
    @{ Pattern = "ROTATING_DOWN";  Exact = $false }
    @{ Pattern = "THROWING";       Exact = $true  }
    @{ Pattern = "ROTATING_BACK";  Exact = $false }
    @{ Pattern = "REFILLING";      Exact = $true  }
    @{ Pattern = "PLANTING";       Exact = $true  }
    @{ Pattern = "BONEMEALING";    Exact = $false }
    @{ Pattern = "MINING";         Exact = $true  }   # exact only — extremely common word

    # Internal class identifiers
    @{ Pattern = "ParseJ.a";       Exact = $false }
    @{ Pattern = "CacheE.MISC";    Exact = $false }
    @{ Pattern = "CacheE.RENDER";  Exact = $false }
    @{ Pattern = "CacheE.CT";      Exact = $false }
    @{ Pattern = "CheckC";         Exact = $true  }
    @{ Pattern = "CoreH";          Exact = $true  }
    @{ Pattern = "cn`$MacroState"; Exact = $false }
    @{ Pattern = "co`$State";      Exact = $false }
)

# ── Extract printable ASCII strings from raw bytes ────────────────────────────
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

# ── Test one string against one signature def ─────────────────────────────────
function Test-Signature {
    param([string]$str, [hashtable]$def)
    $pat = [regex]::Escape($def.Pattern)
    if ($def.Exact) {
        # Must be whole string or surrounded by non-word chars
        return $str -match "(?i)(^|[^a-zA-Z0-9_\$])$pat([^a-zA-Z0-9_\$]|$)"
    } else {
        return $str -match "(?i)$pat"
    }
}

# ── Scan a single jar, return list of hit objects or $null on failure ─────────
function Invoke-ScanJar {
    param([string]$jarPath)
    $hits = [System.Collections.Generic.List[PSCustomObject]]::new()

    try {
        $archive = [System.IO.Compression.ZipFile]::OpenRead($jarPath)

        foreach ($entry in $archive.Entries) {
            if ($entry.FullName -notmatch '\.(class|json|txt|cfg|properties|yml|yaml|toml)$') { continue }

            try {
                $stream = $entry.Open()
                $ms     = [System.IO.MemoryStream]::new()
                $stream.CopyTo($ms)
                $stream.Dispose()

                $bytes   = $ms.ToArray()
                $ms.Dispose()
                $strings = Get-StringsFromBytes -bytes $bytes

                foreach ($def in $signatureDefs) {
                    $alreadyHit = ($hits | Where-Object { $_.Signature -eq $def.Pattern -and $_.Entry -eq $entry.FullName })
                    if ($alreadyHit) { continue }
                    foreach ($s in $strings) {
                        if (Test-Signature -str $s -def $def) {
                            [void]$hits.Add([PSCustomObject]@{
                                Signature = $def.Pattern
                                Entry     = $entry.FullName
                            })
                            break
                        }
                    }
                }
            } catch { }
        }

        $archive.Dispose()
    } catch {
        return $null
    }

    return $hits
}

# ════════════════════════════════════════════════════════════════
#   MAIN
# ════════════════════════════════════════════════════════════════
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

# ── Scan phase: show only progress, store all results ────────
$allResults = @{}
$skipped    = 0

foreach ($jar in $jars) {
    Write-Host "  [ .. ]  $($jar.Name)" -ForegroundColor DarkGray -NoNewline

    $hits = Invoke-ScanJar -jarPath $jar.FullName

    if ($null -eq $hits) {
        Write-Host "`r  [ !! ]  $($jar.Name)  — unreadable" -ForegroundColor DarkYellow
        $skipped++
        continue
    }

    if ($hits.Count -gt 0) {
        Write-Host "`r  [ HIT ]  $($jar.Name)  — $($hits.Count) signature(s)" -ForegroundColor Red
        $allResults[$jar.FullName] = $hits
    } else {
        Write-Host "`r  [  OK ]  $($jar.Name)" -ForegroundColor DarkGreen
    }
}

# ── Results phase: print all detections after scan finishes ──
Write-Host ""
Write-Host ("  " + ("═" * 95)) -ForegroundColor DarkGray
Write-Host "  SCAN RESULTS" -ForegroundColor Cyan
Write-Host ("  " + ("═" * 95)) -ForegroundColor DarkGray
Write-Host ""

if ($allResults.Count -eq 0) {
    Write-Host "  [OK] No Dqrkis signatures detected in any scanned jar." -ForegroundColor Green
} else {
    foreach ($jarPath in $allResults.Keys) {
        $hits    = $allResults[$jarPath]
        $jarName = Split-Path $jarPath -Leaf

        Write-Host "  ╔══ DETECTED: $jarName" -ForegroundColor Red
        Write-Host "  ║   Path     : $jarPath" -ForegroundColor DarkRed
        Write-Host "  ║   Matches  : $($hits.Count) signature(s)" -ForegroundColor DarkRed
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
    }
}

# ── Summary ───────────────────────────────────────────────────
Write-Host ("  " + ("─" * 95)) -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Jars scanned  : $($jars.Count)" -ForegroundColor White
Write-Host "  Flagged       : $($allResults.Count)" -ForegroundColor $(if ($allResults.Count -gt 0) { "Red" } else { "Green" })
Write-Host "  Clean         : $($jars.Count - $allResults.Count - $skipped)" -ForegroundColor Green
if ($skipped -gt 0) {
    Write-Host "  Skipped       : $skipped  (unreadable)" -ForegroundColor DarkYellow
}

Write-Host ""
Write-Host ("  " + ("─" * 95)) -ForegroundColor DarkGray
Write-Host "  discord: cheese_cat0   |   discord: mecz.exe   |   Special thanks to Nic" -ForegroundColor DarkGray
Write-Host ("  " + ("─" * 95)) -ForegroundColor DarkGray
Write-Host ""
Read-Host "  Press Enter to exit"
