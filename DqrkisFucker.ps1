# ============================================================
#   DQRKIS FUCKER  -  Cheat Client Detector
#   Scans .jar files for known Dqrkis client signatures
# ============================================================

$Host.UI.RawUI.WindowTitle = "Dqrkis Fucker - Cheat Scanner"

# Load compression — try multiple methods for compatibility
try {
    Add-Type -AssemblyName "System.IO.Compression"          -ErrorAction Stop
    Add-Type -AssemblyName "System.IO.Compression.FileSystem" -ErrorAction Stop
} catch {
    try {
        $null = [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression")
        $null = [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")
    } catch { }
}

# Bail early if ZipFile still not available
if (-not ("System.IO.Compression.ZipFile" -as [type])) {
    Write-Host "[FATAL] Could not load System.IO.Compression. Requires .NET 4.5+ / PowerShell 3+." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

function Write-Banner {
    Clear-Host
    $b = @"

  ██████╗  ██████╗ ██████╗ ██╗  ██╗██╗███████╗    ███████╗██╗   ██╗ ██████╗██╗  ██╗███████╗██████╗
  ██╔══██╗██╔═══██╗██╔══██╗██║ ██╔╝██║██╔════╝    ██╔════╝██║   ██║██╔════╝██║ ██╔╝██╔════╝██╔══██╗
  ██║  ██║██║   ██║██████╔╝█████╔╝ ██║███████╗    █████╗  ██║   ██║██║     █████╔╝ █████╗  ██████╔╝
  ██║  ██║██║▄▄ ██║██╔══██╗██╔═██╗ ██║╚════██║    ██╔══╝  ██║   ██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗
  ██████╔╝╚██████╔╝██║  ██║██║  ██╗██║███████║    ██║     ╚██████╔╝╚██████╗██║  ██╗███████╗██║  ██║
  ╚═════╝  ╚══▀▀═╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝   ╚═╝      ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝

"@
    Write-Host $b -ForegroundColor Red
    Write-Host ("  " + ("─" * 95)) -ForegroundColor DarkGray
    Write-Host ""
}

# ── Signatures ────────────────────────────────────────────────
$signatureDefs = @(
    @{ P = "FINDING_SPAWNER";           E = $false }
    @{ P = "OPENING_SPAWNER";           E = $false }
    @{ P = "WAITING_SPAWNER_GUI";       E = $false }
    @{ P = "LOOTING_BONES";             E = $false }
    @{ P = "CLOSING_SPAWNER";           E = $false }
    @{ P = "ORDER_COMMAND";             E = $false }
    @{ P = "WAIT_ORDER_GUI";            E = $false }
    @{ P = "SELECT_ORDER_ITEM";         E = $false }
    @{ P = "WAIT_DELIVERY_GUI";         E = $false }
    @{ P = "DELIVERING_BONES";          E = $false }
    @{ P = "WAIT_AFTER_DELIVERY_1";     E = $false }
    @{ P = "CLOSING_DELIVERY";          E = $false }
    @{ P = "WAIT_AFTER_CLOSE_DELIVERY"; E = $false }
    @{ P = "WAIT_CONFIRM_GUI";          E = $false }
    @{ P = "WAIT_CONFIRM_SETTLE";       E = $false }
    @{ P = "CLICK_CONFIRM_SLOT";        E = $false }
    @{ P = "WAIT_AFTER_CONFIRM_1";      E = $false }
    @{ P = "WAIT_AFTER_CONFIRM_2";      E = $false }
    @{ P = "WAIT_AFTER_CONFIRM_3";      E = $false }
    @{ P = "DOUBLE_ESCAPE";             E = $false }
    @{ P = "DOUBLE_RIGHTCLICK_FIRST";   E = $false }
    @{ P = "DOUBLE_RIGHTCLICK_SECOND";  E = $false }
    @{ P = "POST_CYCLE_DELAY";          E = $false }
    @{ P = "mace_swap";                 E = $true  }
    @{ P = "quick_strike";              E = $true  }
    @{ P = "loot_yeeter";               E = $true  }
    @{ P = "auto_jump_reset";           E = $true  }
    @{ P = "macro_198";                 E = $true  }
    @{ P = "stun_slam";                 E = $true  }
    @{ P = "safe_anchor";               E = $true  }
    @{ P = "double_anchor";             E = $true  }
    @{ P = "auto_pot_refill";           E = $true  }
    @{ P = "totem_offhand";             E = $true  }
    @{ P = "walksy_optimizer";          E = $true  }
    @{ P = "key_pearl";                 E = $true  }
    @{ P = "aim_assist";                E = $true  }
    @{ P = "auto_neth_pot";             E = $true  }
    @{ P = "auto_dtap";                 E = $true  }
    @{ P = "bottle_throw";              E = $true  }
    @{ P = "trigger_bot";               E = $true  }
    @{ P = "nametags";                  E = $true  }
    @{ P = "auto_web";                  E = $true  }
    @{ P = "SHOP_END";                  E = $false }
    @{ P = "SHOP_ITEM";                 E = $false }
    @{ P = "SHOP_GLASS_PANE";           E = $false }
    @{ P = "SHOP_BUY";                  E = $false }
    @{ P = "SHOP_CONFIRM";              E = $false }
    @{ P = "SHOP_CHECK_FULL";           E = $false }
    @{ P = "SHOP_EXIT";                 E = $false }
    @{ P = "TARGET_ORDERS";             E = $false }
    @{ P = "ORDERS_SELECT";             E = $false }
    @{ P = "ORDERS_EXIT";               E = $false }
    @{ P = "ORDERS_CONFIRM";            E = $false }
    @{ P = "ORDERS_FINAL_EXIT";         E = $false }
    @{ P = "CYCLE_PAUSE";               E = $false }
    @{ P = "PLACE_OBI";                 E = $false }
    @{ P = "WAIT_OBI";                  E = $false }
    @{ P = "PLACE_CRYSTAL";             E = $false }
    @{ P = "BREAK_CRYSTAL";             E = $false }
    @{ P = "ROTATING_DOWN";             E = $false }
    @{ P = "THROWING";                  E = $true  }
    @{ P = "ROTATING_BACK";             E = $false }
    @{ P = "REFILLING";                 E = $true  }
    @{ P = "PLANTING";                  E = $true  }
    @{ P = "BONEMEALING";               E = $false }
    @{ P = "MINING";                    E = $true  }
    @{ P = "ParseJ.a";                  E = $false }
    @{ P = "CacheE.MISC";               E = $false }
    @{ P = "CacheE.RENDER";             E = $false }
    @{ P = "CacheE.CT";                 E = $false }
    @{ P = "CheckC";                    E = $true  }
    @{ P = "CoreH";                     E = $true  }
    @{ P = 'cn$MacroState';             E = $false }
    @{ P = 'co$State';                  E = $false }
)

# Pre-compile all regexes once so we don't recompile per-string
$compiledSigs = foreach ($def in $signatureDefs) {
    $escaped = [regex]::Escape($def.P)
    $pattern = if ($def.E) { "(?-i)(^|[^a-zA-Z0-9_\$])$escaped([^a-zA-Z0-9_\$]|$)" } else { "(?-i)$escaped" }
    [PSCustomObject]@{
        Name    = $def.P
        Regex   = [regex]::new($pattern)
    }
}

# ── Extract printable ASCII strings from raw bytes ────────────
function Get-Strings ([byte[]]$bytes) {
    $list = [System.Collections.Generic.List[string]]::new()
    $sb   = [System.Text.StringBuilder]::new(128)
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

# ── Scan one jar ──────────────────────────────────────────────
function Invoke-ScanJar ([string]$path) {
    $hits = [System.Collections.Generic.List[PSCustomObject]]::new()

    try {
        $archive = [System.IO.Compression.ZipFile]::OpenRead($path)
    } catch {
        return $null
    }

    try {
        foreach ($entry in $archive.Entries) {
            if ($entry.FullName -notmatch '\.(class|json|txt|cfg|properties|yml|yaml|toml)$') { continue }

            try {
                $es = $entry.Open()
                $ms = [System.IO.MemoryStream]::new()
                $es.CopyTo($ms)
                $es.Dispose()
                $strings = Get-Strings $ms.ToArray()
                $ms.Dispose()
            } catch {
                continue
            }

            # Track which sigs already hit this entry (HashSet = O(1))
            $hitSigsThisEntry = [System.Collections.Generic.HashSet[string]]::new()

            foreach ($sig in $compiledSigs) {
                if ($hitSigsThisEntry.Contains($sig.Name)) { continue }
                foreach ($s in $strings) {
                    if ($sig.Regex.IsMatch($s)) {
                        [void]$hits.Add([PSCustomObject]@{ Signature = $sig.Name; Entry = $entry.FullName })
                        [void]$hitSigsThisEntry.Add($sig.Name)
                        break
                    }
                }
            }
        }
    } finally {
        $archive.Dispose()
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

$allResults = [ordered]@{}
$skipped    = 0
$i          = 0

foreach ($jar in $jars) {
    $i++
    $hits = Invoke-ScanJar -path $jar.FullName

    if ($null -eq $hits) {
        Write-Host "  [$i/$($jars.Count)]  $($jar.Name)  ->  UNREADABLE" -ForegroundColor DarkYellow
        $skipped++
    } elseif ($hits.Count -gt 0) {
        Write-Host "  [$i/$($jars.Count)]  $($jar.Name)  ->  HIT ($($hits.Count))" -ForegroundColor Red
        $allResults[$jar.FullName] = $hits
    } else {
        Write-Host "  [$i/$($jars.Count)]  $($jar.Name)  ->  clean" -ForegroundColor DarkGreen
    }
}

# ── Print all results after scan ──────────────────────────────
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
Write-Host "  Flagged       : $($allResults.Count)" -ForegroundColor $(if ($allResults.Count -gt 0) {"Red"} else {"Green"})
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
