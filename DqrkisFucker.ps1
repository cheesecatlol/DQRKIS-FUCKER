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

# ── Signature definitions ─────────────────────────────────────
# Exact = $true  → whole-word match only (no substring hits)
# Exact = $false → substring match ok (string is unique enough)
$signatureDefs = @(
    @{ Pattern = "FINDING_SPAWNER";           Exact = $false }
    @{ Pattern = "OPENING_SPAWNER";           Exact = $false }
    @{ Pattern = "WAITING_SPAWNER_GUI";       Exact = $false }
    @{ Pattern = "LOOTING_BONES";             Exact = $false }
    @{ Pattern = "CLOSING_SPAWNER";           Exact = $false }
    @{ Pattern = "ORDER_COMMAND";             Exact = $false }
    @{ Pattern = "WAIT_ORDER_GUI";            Exact = $false }
    @{ Pattern = "SELECT_ORDER_ITEM";         Exact = $false }
    @{ Pattern = "WAIT_DELIVERY_GUI";         Exact = $false }
    @{ Pattern = "DELIVERING_BONES";          Exact = $false }
    @{ Pattern = "WAIT_AFTER_DELIVERY_1";     Exact = $false }
    @{ Pattern = "CLOSING_DELIVERY";          Exact = $false }
    @{ Pattern = "WAIT_AFTER_CLOSE_DELIVERY"; Exact = $false }
    @{ Pattern = "WAIT_CONFIRM_GUI";          Exact = $false }
    @{ Pattern = "WAIT_CONFIRM_SETTLE";       Exact = $false }
    @{ Pattern = "CLICK_CONFIRM_SLOT";        Exact = $false }
    @{ Pattern = "WAIT_AFTER_CONFIRM_1";      Exact = $false }
    @{ Pattern = "WAIT_AFTER_CONFIRM_2";      Exact = $false }
    @{ Pattern = "WAIT_AFTER_CONFIRM_3";      Exact = $false }
    @{ Pattern = "DOUBLE_ESCAPE";             Exact = $false }
    @{ Pattern = "DOUBLE_RIGHTCLICK_FIRST";   Exact = $false }
    @{ Pattern = "DOUBLE_RIGHTCLICK_SECOND";  Exact = $false }
    @{ Pattern = "POST_CYCLE_DELAY";          Exact = $false }
    @{ Pattern = "mace_swap";                 Exact = $true  }
    @{ Pattern = "quick_strike";              Exact = $true  }
    @{ Pattern = "loot_yeeter";               Exact = $true  }
    @{ Pattern = "auto_jump_reset";           Exact = $true  }
    @{ Pattern = "macro_198";                 Exact = $true  }
    @{ Pattern = "stun_slam";                 Exact = $true  }
    @{ Pattern = "safe_anchor";               Exact = $true  }
    @{ Pattern = "double_anchor";             Exact = $true  }
    @{ Pattern = "auto_pot_refill";           Exact = $true  }
    @{ Pattern = "totem_offhand";             Exact = $true  }
    @{ Pattern = "walksy_optimizer";          Exact = $true  }
    @{ Pattern = "key_pearl";                 Exact = $true  }
    @{ Pattern = "aim_assist";                Exact = $true  }
    @{ Pattern = "auto_neth_pot";             Exact = $true  }
    @{ Pattern = "auto_dtap";                 Exact = $true  }
    @{ Pattern = "bottle_throw";              Exact = $true  }
    @{ Pattern = "trigger_bot";               Exact = $true  }
    @{ Pattern = "nametags";                  Exact = $true  }
    @{ Pattern = "auto_web";                  Exact = $true  }
    @{ Pattern = "SHOP_END";                  Exact = $false }
    @{ Pattern = "SHOP_ITEM";                 Exact = $false }
    @{ Pattern = "SHOP_GLASS_PANE";           Exact = $false }
    @{ Pattern = "SHOP_BUY";                  Exact = $false }
    @{ Pattern = "SHOP_CONFIRM";              Exact = $false }
    @{ Pattern = "SHOP_CHECK_FULL";           Exact = $false }
    @{ Pattern = "SHOP_EXIT";                 Exact = $false }
    @{ Pattern = "TARGET_ORDERS";             Exact = $false }
    @{ Pattern = "ORDERS_SELECT";             Exact = $false }
    @{ Pattern = "ORDERS_EXIT";               Exact = $false }
    @{ Pattern = "ORDERS_CONFIRM";            Exact = $false }
    @{ Pattern = "ORDERS_FINAL_EXIT";         Exact = $false }
    @{ Pattern = "CYCLE_PAUSE";               Exact = $false }
    @{ Pattern = "PLACE_OBI";                 Exact = $false }
    @{ Pattern = "WAIT_OBI";                  Exact = $false }
    @{ Pattern = "PLACE_CRYSTAL";             Exact = $false }
    @{ Pattern = "BREAK_CRYSTAL";             Exact = $false }
    @{ Pattern = "ROTATING_DOWN";             Exact = $false }
    @{ Pattern = "THROWING";                  Exact = $true  }
    @{ Pattern = "ROTATING_BACK";             Exact = $false }
    @{ Pattern = "REFILLING";                 Exact = $true  }
    @{ Pattern = "PLANTING";                  Exact = $true  }
    @{ Pattern = "BONEMEALING";               Exact = $false }
    @{ Pattern = "MINING";                    Exact = $true  }
    @{ Pattern = "ParseJ.a";                  Exact = $false }
    @{ Pattern = "CacheE.MISC";               Exact = $false }
    @{ Pattern = "CacheE.RENDER";             Exact = $false }
    @{ Pattern = "CacheE.CT";                 Exact = $false }
    @{ Pattern = "CheckC";                    Exact = $true  }
    @{ Pattern = "CoreH";                     Exact = $true  }
    @{ Pattern = "cn`$MacroState";            Exact = $false }
    @{ Pattern = "co`$State";                 Exact = $false }
)

# ── Extract printable ASCII strings from raw bytes ────────────
function Get-StringsFromBytes ([byte[]]$bytes) {
    $list = [System.Collections.Generic.List[string]]::new()
    $sb   = [System.Text.StringBuilder]::new()
    foreach ($b in $bytes) {
        if ($b -ge 32 -and $b -le 126) {
            [void]$sb.Append([char]$b)
        } else {
            if ($sb.Length -ge 4) { [void]$list.Add($sb.ToString()) }
            [void]$sb.Clear()
        }
    }
    if ($sb.Length -ge 4) { [void]$list.Add($sb.ToString()) }
    return $list
}

# ── Test a string against one signature def ───────────────────
function Test-Sig ([string]$str, [hashtable]$def) {
    $p = [regex]::Escape($def.Pattern)
    if ($def.Exact) {
        return [bool]($str -match "(?i)(^|[^a-zA-Z0-9_\$])$p([^a-zA-Z0-9_\$]|`$)")
    }
    return [bool]($str -match "(?i)$p")
}

# ── Scan one jar; returns list of hit objects, or $null on error ──
function Invoke-ScanJar ([string]$path) {
    $hits = [System.Collections.Generic.List[PSCustomObject]]::new()
    try {
        $archive = [System.IO.Compression.ZipFile]::OpenRead($path)
        foreach ($entry in $archive.Entries) {
            if ($entry.FullName -notmatch '\.(class|json|txt|cfg|properties|yml|yaml|toml)$') { continue }
            try {
                $es  = $entry.Open()
                $ms  = [System.IO.MemoryStream]::new()
                $es.CopyTo($ms)
                $es.Dispose()
                $strs = Get-StringsFromBytes $ms.ToArray()
                $ms.Dispose()

                foreach ($def in $signatureDefs) {
                    $sig     = $def.Pattern
                    $already = $false
                    foreach ($h in $hits) {
                        if ($h.Signature -eq $sig -and $h.Entry -eq $entry.FullName) { $already = $true; break }
                    }
                    if ($already) { continue }
                    foreach ($s in $strs) {
                        if (Test-Sig $s $def) {
                            [void]$hits.Add([PSCustomObject]@{ Signature = $sig; Entry = $entry.FullName })
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

# ════════════════════════════════════════════════════════════
#  MAIN
# ════════════════════════════════════════════════════════════
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
Write-Host "  Found $($jars.Count) jar(s). Scanning..." -ForegroundColor Green
Write-Host ("  " + ("─" * 95)) -ForegroundColor DarkGray
Write-Host ""

$allResults = [System.Collections.Generic.Dictionary[string, object]]::new()
$skipped    = 0
$i          = 0

foreach ($jar in $jars) {
    $i++
    $label = "  [$i/$($jars.Count)]  $($jar.Name)"

    $hits = Invoke-ScanJar -path $jar.FullName

    if ($null -eq $hits) {
        Write-Host "$label  -> UNREADABLE" -ForegroundColor DarkYellow
        $skipped++
        continue
    }

    if ($hits.Count -gt 0) {
        Write-Host "$label  -> HIT ($($hits.Count))" -ForegroundColor Red
        $allResults[$jar.FullName] = $hits
    } else {
        Write-Host "$label  -> clean" -ForegroundColor DarkGreen
    }
}

# ── Results ───────────────────────────────────────────────────
Write-Host ""
Write-Host ("  " + ("═" * 95)) -ForegroundColor DarkGray
Write-Host "  RESULTS" -ForegroundColor Cyan
Write-Host ("  " + ("═" * 95)) -ForegroundColor DarkGray
Write-Host ""

if ($allResults.Count -eq 0) {
    Write-Host "  [OK] No Dqrkis signatures detected." -ForegroundColor Green
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
