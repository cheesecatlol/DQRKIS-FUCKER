# ============================================================
#   DQRKIS FUCKER  -  Cheat Client Detector
#   discord : cheese_cat0  |  discord : mecz.exe
#   Special thanks to Nic
# ============================================================

Add-Type -AssemblyName System.IO.Compression.FileSystem
$Host.UI.RawUI.WindowTitle = "Dqrkis Fucker"

# ── Colours ──────────────────────────────────────────────────
$R  = [System.ConsoleColor]::Red
$DR = [System.ConsoleColor]::DarkRed
$DG = [System.ConsoleColor]::DarkGray
$GR = [System.ConsoleColor]::Gray
$WH = [System.ConsoleColor]::White
$GN = [System.ConsoleColor]::Green
$YL = [System.ConsoleColor]::Yellow
$DY = [System.ConsoleColor]::DarkYellow
$CY = [System.ConsoleColor]::Cyan

# ── Helpers ───────────────────────────────────────────────────
function Gap  { Write-Host "" }
function Rule { Write-Host ("  " + "-" * 80) -ForegroundColor $DG }

function Section {
    param([string]$Title, [System.ConsoleColor]$C = $R)
    Gap
    Write-Host "  $Title" -ForegroundColor $C
    Rule
}

function KV {
    param([string]$K, [string]$V,
          [System.ConsoleColor]$KC = $DG,
          [System.ConsoleColor]$VC = $WH)
    Write-Host "    $K" -ForegroundColor $KC -NoNewline
    Write-Host $V -ForegroundColor $VC
}

function Write-ScanLine {
    param([int]$Done, [int]$Total, [string]$Name)
    $pct    = [math]::Floor($Done / $Total * 100)
    $filled = [math]::Floor($pct / 2)
    $empty  = 50 - $filled
    $bar    = ("#" * $filled) + ("." * $empty)
    $lbl    = if ($Name.Length -gt 30) { $Name.Substring(0,27) + "..." } else { $Name.PadRight(30) }
    $pctStr = $pct.ToString().PadLeft(3)
    [Console]::Write("  [" + $bar + "]  " + $pctStr + "%  " + $lbl + "`r")
}

# ── Banner ────────────────────────────────────────────────────
function Write-Banner {
    Clear-Host
    Gap
    # Clean big-text banner, zero box-drawing characters
    Write-Host "  ____  __  ___  ____  _  _  __  ___     ____  _  _   ___  _  _  ____  ____" -ForegroundColor $R
    Write-Host " (  _ \(  )/ __)(  _ \( )/ )(_  )/ __)   ( ___)( )( ) / __)( )/ )( ___)(  _ \" -ForegroundColor $R
    Write-Host "  )(_) ))(__\__ \ )   / )  (  / /\__ \    )__)  )()(  ( (__  )  (  )__)  )   /" -ForegroundColor $DR
    Write-Host " (____/(____)(___/(_)\_)(_)\_)(___)(___/   (__)  \__/   \___)(_)\_)(____)(_)\_)" -ForegroundColor $DR
    Gap
    Rule

    Rule
    Gap
}

# ── Signatures ────────────────────────────────────────────────
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

# ── Scanner core ──────────────────────────────────────────────
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
                $s = $entry.Open(); $ms = [System.IO.MemoryStream]::new()
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
    } catch { return $null }
    return $hits
}

# ══════════════════════════════════════════════════════════════
#   MAIN
# ══════════════════════════════════════════════════════════════
Write-Banner

Write-Host "  scan path " -ForegroundColor $DG -NoNewline
Write-Host "(leave blank for .minecraft/mods)" -ForegroundColor $DG
Gap
Write-Host "  > " -ForegroundColor $R -NoNewline
$scanPath = (Read-Host).Trim().Trim('"')
if ([string]::IsNullOrWhiteSpace($scanPath)) {
    $scanPath = "$env:USERPROFILE\AppData\Roaming\.minecraft\mods"
}

if (-not (Test-Path $scanPath -PathType Container)) {
    Gap
    Write-Host "  error   " -ForegroundColor $R -NoNewline
    Write-Host "path not found: $scanPath" -ForegroundColor $DG
    Gap
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown"); exit 1
}

$jars = Get-ChildItem -Path $scanPath -Recurse -Filter "*.jar" -ErrorAction SilentlyContinue
if ($jars.Count -eq 0) {
    Gap
    Write-Host "  warn    " -ForegroundColor $DY -NoNewline
    Write-Host "no .jar files found in $scanPath" -ForegroundColor $DG
    Gap
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown"); exit 0
}

$ts        = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$totalSize = [math]::Round(($jars | Measure-Object -Property Length -Sum).Sum / 1MB, 2)

Section "SCAN  /  $ts"
KV "path         " $scanPath $DG $GR
KV "files        " "$($jars.Count) jar(s)  /  $totalSize MB"
KV "signatures   " "$($signatures.Count) loaded"
Gap

# ── Progress ──────────────────────────────────────────────────
$totalFlagged = 0; $totalClean = 0; $totalErrors = 0
$flaggedMods  = [System.Collections.Generic.List[PSCustomObject]]::new()
$i = 0

foreach ($jar in $jars) {
    $i++
    Write-ScanLine -Done $i -Total $jars.Count -Name $jar.Name
    $hits = Invoke-ScanJar -jarPath $jar.FullName
    if ($null -eq $hits) { $totalErrors++; continue }
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

$doneBar = "[" + ("#" * 50) + "]"
[Console]::Write("  " + $doneBar + "  100%  done" + (" " * 35) + "`r")
Write-Host ("  " + $doneBar + "  100%  done") -ForegroundColor $GN
Start-Sleep -Milliseconds 150
Clear-Host

# ══════════════════════════════════════════════════════════════
#   RESULTS
# ══════════════════════════════════════════════════════════════
Write-Banner

$flagColor = if ($totalFlagged -gt 0) { $R } else { $GN }

Section "RESULTS  /  $ts"
KV "path         " $scanPath $DG $GR
KV "scanned      " "$($jars.Count) file(s)  /  $totalSize MB"
KV "signatures   " "$($signatures.Count) in database"
Gap
KV "clean        " "$totalClean"   $DG $GN
KV "errors       " "$totalErrors"  $DG $(if ($totalErrors -gt 0) { $DY } else { $DG })
KV "flagged      " "$totalFlagged" $DG $flagColor
Gap

# ── Detections ────────────────────────────────────────────────
if ($flaggedMods.Count -gt 0) {

    Section "DETECTIONS  /  $($flaggedMods.Count) file(s) matched" $R

    $idx = 0
    foreach ($mod in $flaggedMods) {
        $idx++
        Gap
        Write-Host "  [$idx]  " -ForegroundColor $DG -NoNewline
        Write-Host $mod.Name -ForegroundColor $WH
        KV "  path     " $mod.Path $DG $GR
        KV "  size     " "$($mod.Size) KB"
        KV "  matches  " "$($mod.HitCount) signature(s)" $DG $R
        Gap

        $grouped = $mod.Hits | Group-Object -Property Entry | Sort-Object Name
        foreach ($group in $grouped) {
            foreach ($h in $group.Group) {
                Write-Host "    " -NoNewline
                Write-Host $h.Signature -ForegroundColor $YL
            }
        }

        if ($idx -lt $flaggedMods.Count) {
            Gap
            Write-Host ("  " + ("-" * 50)) -ForegroundColor $DG
        }
    }

    Gap
    Rule
    Write-Host "  verdict  " -ForegroundColor $R -NoNewline
    Write-Host "dqrkis fucked" -ForegroundColor $R

} else {
    Write-Host "  all clear  " -ForegroundColor $GN -NoNewline
    Write-Host "No Dqrkis signatures detected." -ForegroundColor $GR
}

# ── Footer ────────────────────────────────────────────────────
Gap
Rule
Write-Host "  discord: cheese_cat0  .  discord: mecz.exe  .  Special thanks to Nic" -ForegroundColor $DG
Rule
Gap
Write-Host "  press any key to exit" -ForegroundColor $DG
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
