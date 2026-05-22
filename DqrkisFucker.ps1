# ============================================================
#   DQRKIS FUCKER  -  Cheat Client Detector
#   discord : cheese_cat0  |  discord : mecz.exe
#   Special thanks to Nic
# ============================================================

Add-Type -AssemblyName System.IO.Compression.FileSystem
$Host.UI.RawUI.WindowTitle = "Dqrkis Fucker"

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
    "bottle_throw", "trigger_bot", "auto_web",
    "SHOP_END", "SHOP_ITEM", "SHOP_GLASS_PANE", "SHOP_BUY",
    "SHOP_CONFIRM", "SHOP_CHECK_FULL", "SHOP_EXIT",
    "TARGET_ORDERS", "ORDERS_SELECT", "ORDERS_EXIT", "ORDERS_CONFIRM", "ORDERS_FINAL_EXIT",
    "CYCLE_PAUSE", "PLACE_OBI", "WAIT_OBI", "PLACE_CRYSTAL", "BREAK_CRYSTAL",
    "ROTATING_DOWN", "THROWING", "ROTATING_BACK", "REFILLING",
    "PLANTING", "BONEMEALING",
    "ParseJ.a", "CacheE.MISC", "CacheE.RENDER", "CacheE.CT",
    "CoreH", "cn`$MacroState", "co`$State"
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
    $hits = [System.Collections.Generic.List[PSCustomObject]]::new()
    try {
        $archive = [System.IO.Compression.ZipFile]::OpenRead($jarPath)
        foreach ($entry in $archive.Entries) {
            if ($entry.FullName -notmatch '\.(class|json|txt|cfg|properties|yml|yaml|toml)$') { continue }
            try {
                $es = $entry.Open(); $ms = [System.IO.MemoryStream]::new()
                $es.CopyTo($ms); $es.Dispose()
                $bytes   = $ms.ToArray(); $ms.Dispose()
                $strings = Get-StringsFromBytes -bytes $bytes
                foreach ($sig in $signatures) {
                    $pat = [regex]::Escape($sig)
                    foreach ($s in $strings) {
                        if ($s -match $pat) {
                            [void]$hits.Add([PSCustomObject]@{ Sig = $sig; Entry = $entry.FullName })
                            break
                        }
                    }
                }
            } catch {}
        }
        $archive.Dispose()
    } catch {}
    return $hits
}

function Find-Instances {
    $instances = [System.Collections.Generic.List[PSCustomObject]]::new()
    $roaming = $env:APPDATA
    $local   = $env:LOCALAPPDATA

    $default = Join-Path $roaming ".minecraft\mods"
    if (Test-Path $default) {
        [void]$instances.Add([PSCustomObject]@{ Name = ".minecraft"; Path = $default })
    }

    $mrBases = @(
        (Join-Path $roaming "ModrinthApp\profiles"),
        (Join-Path $roaming "com.modrinth.theseus\profiles")
    )
    foreach ($base in $mrBases) {
        if (Test-Path $base) {
            $dirs = Get-ChildItem -Path $base -Directory -ErrorAction SilentlyContinue
            foreach ($d in $dirs) {
                $mods = Join-Path $d.FullName "mods"
                if (Test-Path $mods) {
                    [void]$instances.Add([PSCustomObject]@{ Name = "Modrinth / $($d.Name)"; Path = $mods })
                }
            }
        }
    }

    $launchers = @(
        @{ Base = (Join-Path $local  "PrismLauncher\instances");         Label = "Prism";      Sub = "minecraft\mods" },
        @{ Base = (Join-Path $local  "MultiMC\instances");               Label = "MultiMC";    Sub = "minecraft\mods" },
        @{ Base = (Join-Path $roaming "curseforge\minecraft\Instances"); Label = "CurseForge"; Sub = "mods"           },
        @{ Base = (Join-Path $roaming "ATLauncher\instances");           Label = "ATLauncher"; Sub = "mods"           },
        @{ Base = (Join-Path $roaming "Feather\instances");              Label = "Feather";    Sub = "mods"           }
    )
    foreach ($l in $launchers) {
        if (Test-Path $l.Base) {
            $dirs = Get-ChildItem -Path $l.Base -Directory -ErrorAction SilentlyContinue
            foreach ($d in $dirs) {
                $mods = Join-Path $d.FullName $l.Sub
                if (Test-Path $mods) {
                    [void]$instances.Add([PSCustomObject]@{ Name = "$($l.Label) / $($d.Name)"; Path = $mods })
                }
            }
        }
    }

    return $instances
}

function Write-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "▄▄▄▄▄▄                                   ▄▄▄▄▄▄▄                             " -ForegroundColor Red
    Write-Host "███▀▀██▄             ▄▄     ▀▀          ███▀▀▀▀▀          ▄▄                 " -ForegroundColor Red
    Write-Host "███  ███ ▄████ ████▄ ██ ▄█▀ ██  ▄█▀▀▀   ███▄▄ ██ ██ ▄████ ██ ▄█▀ ▄█▀█▄ ████▄ " -ForegroundColor Red
    Write-Host "███  ███ ██ ██ ██ ▀▀ ████   ██  ▀███▄   ███▀▀ ██ ██ ██    ████   ██▄█▀ ██ ▀▀ " -ForegroundColor DarkRed
    Write-Host "██████▀  ▀████ ██    ██ ▀█▄ ██▄ ▄▄▄█▀   ███   ▀██▀█ ▀████ ██ ▀█▄ ▀█▄▄▄ ██    " -ForegroundColor DarkRed
    Write-Host "            ██                                                               " -ForegroundColor DarkRed
    Write-Host "            ▀▀                                                               " -ForegroundColor DarkRed
    Write-Host ""
    Write-Host "  [$( Get-Date -Format 'yyyy-MM-dd HH:mm:ss' )]  v1.0" -ForegroundColor DarkGray
    Write-Host ("  " + ("-" * 88)) -ForegroundColor DarkGray
    Write-Host ""
}

# ══════════════════════════════════════════════════════════════
#   MAIN
# ══════════════════════════════════════════════════════════════
Write-Banner

$instances = Find-Instances

if ($instances.Count -eq 0) {
    Write-Host "  no instances found — enter path manually" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  > " -NoNewline
    $scanPath = (Read-Host).Trim().Trim('"')
    if (-not (Test-Path $scanPath -PathType Container)) {
        Write-Host "  invalid path." -ForegroundColor Red
        Read-Host "  press enter to exit"
        exit 1
    }
    $instances = @([PSCustomObject]@{ Name = "Custom"; Path = $scanPath })
}

Write-Host "  scanning..." -ForegroundColor DarkGray
Write-Host "  " -NoNewline

$allJars = [System.Collections.Generic.List[PSCustomObject]]::new()
foreach ($inst in $instances) {
    $jars = Get-ChildItem -Path $inst.Path -Filter "*.jar" -ErrorAction SilentlyContinue
    foreach ($jar in $jars) {
        [void]$allJars.Add([PSCustomObject]@{
            Name     = $jar.Name
            Path     = $jar.FullName
            Size     = [math]::Round($jar.Length / 1KB, 1)
            Instance = $inst.Name
        })
    }
}

if ($allJars.Count -eq 0) {
    Write-Host ""
    Write-Host "  no jars found." -ForegroundColor DarkGray
    Read-Host "  press enter to exit"
    exit 0
}

$totalSize    = [math]::Round(($allJars | Measure-Object -Property Size -Sum).Sum / 1024, 2)
$flaggedMods  = [System.Collections.Generic.List[PSCustomObject]]::new()
$totalFlagged = 0; $totalClean = 0; $totalErrors = 0
$i = 0

foreach ($jar in $allJars) {
    $i++
    $pct = [math]::Floor(($i / $allJars.Count) * 100)
    [Console]::Write("`r  $pct%")
    $hits = Invoke-ScanJar -jarPath $jar.Path
    if ($null -eq $hits) { $totalErrors++; continue }
    if ($hits.Count -gt 0) {
        $totalFlagged++
        $flaggedMods.Add([PSCustomObject]@{
            Name     = $jar.Name
            Path     = $jar.Path
            Size     = $jar.Size
            Instance = $jar.Instance
            Hits     = $hits
        })
    } else { $totalClean++ }
}

[Console]::Write("`r  done" + (" " * 10) + "`r")
Start-Sleep -Milliseconds 150

# ══════════════════════════════════════════════════════════════
#   REPORT
# ══════════════════════════════════════════════════════════════
Write-Banner

$hasFlagged = $totalFlagged -gt 0

Write-Host "  scanned   " -NoNewline -ForegroundColor DarkGray
Write-Host "$($allJars.Count) files  ($totalSize MB)" -ForegroundColor White
Write-Host "  clean     " -NoNewline -ForegroundColor DarkGray
Write-Host "$totalClean" -ForegroundColor Green
Write-Host "  errors    " -NoNewline -ForegroundColor DarkGray
if ($totalErrors -gt 0) { Write-Host "$totalErrors" -ForegroundColor DarkYellow } else { Write-Host "0" -ForegroundColor DarkGray }
Write-Host "  flagged   " -NoNewline -ForegroundColor DarkGray
if ($hasFlagged) { Write-Host "$totalFlagged" -ForegroundColor Red } else { Write-Host "0" -ForegroundColor Green }

Write-Host ("  " + ("-" * 88)) -ForegroundColor DarkGray

if ($hasFlagged) {
    Write-Host ""
    $idx = 0
    foreach ($mod in $flaggedMods) {
        $idx++
        Write-Host "  [$idx]" -ForegroundColor Red -NoNewline
        Write-Host " $($mod.Name)" -ForegroundColor White

        Write-Host "      path      " -NoNewline -ForegroundColor DarkGray
        $dispPath = $mod.Path
        if ($dispPath.Length -gt 55) { $dispPath = "..." + $dispPath.Substring($dispPath.Length - 52) }
        Write-Host $dispPath -ForegroundColor Gray

        Write-Host "      size      " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($mod.Size) KB" -ForegroundColor Gray

        Write-Host "      hits      " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($mod.Hits.Count)" -ForegroundColor Red
        Write-Host ""

        $grouped = $mod.Hits | Group-Object -Property Entry | Sort-Object Name
        foreach ($g in $grouped) {
            foreach ($h in $g.Group) {
                Write-Host "      $($h.Sig)" -ForegroundColor Cyan
            }
        }

        if ($idx -lt $flaggedMods.Count) { Write-Host "" }
    }

    Write-Host ""
    Write-Host ("  " + ("-" * 88)) -ForegroundColor DarkGray
    Write-Host "  result    " -NoNewline -ForegroundColor DarkGray
    Write-Host "dqrkis fucked" -ForegroundColor Red

} else {
    Write-Host ""
    Write-Host "  result    " -NoNewline -ForegroundColor DarkGray
    Write-Host "clean — no dqrkis signatures found" -ForegroundColor Green
}

Write-Host ("  " + ("-" * 88)) -ForegroundColor DarkGray
Write-Host ""
Write-Host "  discord: cheese_cat0  .  discord: mecz.exe  .  Special thanks to Nic" -ForegroundColor DarkGray
Write-Host ""
Read-Host "  press enter to exit"
