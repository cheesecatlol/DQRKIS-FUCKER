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

    # CHEESY
    $L1  = "  ██████╗██╗  ██╗███████╗███████╗███████╗██╗   ██╗"
    $L2  = " ██╔════╝██║  ██║██╔════╝██╔════╝██╔════╝╚██╗ ██╔╝"
    $L3  = " ██║     ███████║█████╗  █████╗  ███████╗ ╚████╔╝ "
    $L4  = " ██║     ██╔══██║██╔══╝  ██╔══╝  ╚════██║  ╚██╔╝  "
    $L5  = " ╚██████╗██║  ██║███████╗███████╗███████║   ██║   "
    $L6  = "  ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝   ╚═╝   "

    # DQRKIS FUCKER
    $L7  = "  ██████╗  ██████╗ ██████╗ ██╗  ██╗██╗███████╗"
    $L8  = "  ██╔══██╗██╔═══██╗██╔══██╗██║ ██╔╝██║██╔════╝"
    $L9  = "  ██║  ██║██║   ██║██████╔╝█████╔╝ ██║███████╗"
    $L10 = "  ██║  ██║██║▄▄ ██║██╔══██╗██╔═██╗ ██║╚════██║"
    $L11 = "  ██████╔╝╚██████╔╝██║  ██║██║  ██╗██║███████║"
    $L12 = "  ╚═════╝  ╚══▀▀═╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝"

    $L13 = "  ███████╗██╗   ██╗ ██████╗██╗  ██╗███████╗██████╗ "
    $L14 = "  ██╔════╝██║   ██║██╔════╝██║ ██╔╝██╔════╝██╔══██╗"
    $L15 = "  █████╗  ██║   ██║██║     █████╔╝ █████╗  ██████╔╝"
    $L16 = "  ██╔══╝  ██║   ██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗"
    $L17 = "  ██║     ╚██████╔╝╚██████╗██║  ██╗███████╗██║  ██║"
    $L18 = "  ╚═╝      ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝"

    $cheese = @(
        "                        .::::. ",
        "                      .:  o   :.",
        "                     :  o   o  :",
        "                    :___________:"
    )

    Write-Animated -Lines @($L1,$L2,$L3,$L4,$L5,$L6) -Color Yellow -DelayMs 18
    Write-Host ""
    Write-Animated -Lines @($L7,$L8,$L9,$L10,$L11,$L12) -Color Red -DelayMs 18
    Write-Host ""
    Write-Animated -Lines @($L13,$L14,$L15,$L16,$L17,$L18) -Color DarkRed -DelayMs 18
    Write-Host ""
    foreach ($line in $cheese) {
        Write-Host $line -ForegroundColor Yellow
        Start-Sleep -Milliseconds 30
    }
    Write-Host ""
    Write-Host "  " -NoNewline
    Write-Host "  o O o O o  [ CheesyDqrkisFucker v1.0 — by cheese cat ]  o O o O o  " -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host ("  " + "~" * 64) -ForegroundColor DarkYellow
    Write-Host ""
}

function Write-SectionHeader {
    param([string]$Title, [ConsoleColor]$Color = "Yellow")
    Write-Host ""
    Write-Host ("  " + "~" * 64) -ForegroundColor DarkYellow
    Write-Host "  $Title" -ForegroundColor $Color
    Write-Host ("  " + "~" * 64) -ForegroundColor DarkYellow
    Write-Host ""
}

function Write-ProgressBar {
    param([int]$Current, [int]$Total, [string]$Label)
    if ($Total -eq 0) { return }
    $pct   = [Math]::Round(($Current / $Total) * 100)
    $filled = [Math]::Round(($Current / $Total) * 40)
    $empty  = 40 - $filled
    $bar    = ("█" * $filled) + ("░" * $empty)
    Write-Host "`r  [$bar] $pct%  $Label          " -NoNewline -ForegroundColor Yellow
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
    "bottle_throw","trigger_bot","auto_web",

    # Shop macro states
    "SHOP_END","SHOP_ITEM","SHOP_GLASS_PANE","SHOP_BUY",
    "SHOP_CONFIRM","SHOP_CHECK_FULL","SHOP_EXIT",

    # Order macro states
    "TARGET_ORDERS","ORDERS_SELECT","ORDERS_EXIT","ORDERS_CONFIRM","ORDERS_FINAL_EXIT","CYCLE_PAUSE",

    # Crystal / obi / farming automation
    "PLACE_OBI","WAIT_OBI","PLACE_CRYSTAL","BREAK_CRYSTAL",
    "ROTATING_DOWN","ROTATING_BACK","REFILLING",
    "PLANTING","BONEMEALING",

    # Internal class / obfuscation signatures
    "ParseJ.a","CacheE.MISC","CacheE.RENDER","CacheE.CT",
    "CheckC","CoreH","cn`$MacroState","co`$State",

    # Fullwidth obfuscated module config strings
    "Ａ．ｃｔｉｖａｔｅ Ｋｅｙ","Ｃ．ｈｅｃｋ Ｐｌａｃｅ","Ｓ．ｗｉｔｃｈ Ｄｅｌａｙ","Ｓ．ｗｉｔｃｈ Ｃｈａｎｃｅ",
    "Ｐ．ｌａｃｅ Ｄｅｌａｙ","Ｐ．ｌａｃｅ Ｃｈａｎｃｅ","Ｗ．ｏｒｋ Ｗｉｔｈ Ｔｏｔｅｍ","Ｗ．ｏｒｋ Ｗｉｔｈ Ｃｒｙｓｔａｌ",
    "Ｓ．ｗｏｒｄ Ｓｗａｐ","Ａ．ｕｔｏ Ｈｉｔ Ｃｒｙｓｔａｌ","A.utomatically hit-crystals for you",
    "Ｊ．ｕｍｐ Ｒｅｓｅｔ Ｃｈａｎｃｅ","Ａ．ｕｔｏ Ｊｕｍｐ Ｒｅｓｅｔ","Ｓ．ｉｌｅｎｔ Ｒｏｔａｔｉｏｎｓ",
    "Ｈ．ｏｒｉｚｏｎｔａｌ Ａｉｍ Ｓｐｅｅｄ","Ｖ．ｅｒｔｉｃａｌ Ａｉｍ Ｓｐｅｅｄ","Ｉ．ｎｃｌｕｄｅ Ｈｅａｄ",
    "Ｗ．ｅｂ Ｄｅｌａｙ","Ｈ．ｏｌｄｉｎｇ Ｗｅｂ","Ｃ．ｌｉｃｋｉｎｇ","Ｂ．ｒｅａｋ Ｂｌｏｃｋｓ",
    "Ｎ．ｏｔ Ｗｈｅｎ Ａｆｆｅｃｔｓ Ｐｌａｙｅｒ","Ａ．ｕｔｏＷｅｂ","Ｐ．ｌａｃｅｓ Ｗｅｂｓ Ｏｎ Ｅｎｅｍｉｅｓ",
    "Ｍ．ｉｎ Ｔｏｔｅｍｓ","Ｍ．ｉｎ Ｐｅａｒｌｓ","Ｔ．ｏｔｅｍ Ｆｉｒｓｔ","Ｄ．ｒｏｐ Ｉｎｔｅｒｖａｌ",
    "Ｒ．ａｎｄｏｍ Ｐａｔｔｅｒｎ","Ｌ．ｏｏｔ Ｙｅｅｔｅｒ","Ｒ．ｅｑｕｉｒｅ Ｓｗｏｒｄ","Ｓ．ｗｉｔｃｈ Ｂａｃｋ",
    "Ａ．ｕｔｏ Ｔｏｔｅｍ Ｈｉｔ","ｐ．ｌａｃｅＩｎｔｅｒｖａｌ","ｂ．ｒｅａｋＩｎｔｅｒｖａｌ","ｓ．ｔｏｐＯｎＫｉｌｌ",
    "ａ．ｃｔｉｖａｔｅＯｎＲｉｇｈｔＣｌｉｃｋ","ｄ．ａｍａｇｅｔｉｃｋ","ｈ．ｏｌｄＣｒｙｓｔａｌ","ｆ．ａｋｅＰｕｎｃｈ",
    "Ｌ．ＷＦＨ Ｃｒｙｓｔａｌ","Ｎ．ｏ Ｓｌｏｗｄｏｗｎ","Ａ．ｎｔｉ Ｗｅｂ","Ｅ．ｘｐａｎｄ Ａｍｏｕｎｔ",
    "Ｐ．ｌａｙｅｒｓ Ｏｎｌｙ","Ｉ．ｎｖｉｓｉｂｌｅｓ","Ｓ．ｍａｒｔ Ｊｉｔｔｅｒ","Ｒ．ｅｎｄｅｒ Ｈｉｔｂｏｘｅｓ",
    "Ｈ．ｉｔｂｏｘｅｓ","Expands entity bounding boxes for easier targeting.",
    "Ｎ．ｏＢｏｕｎｃｅ","Ｒ．ｅｍｏｖｅｓ ｔｈｅ ｃｒｙｓｔａｌ ｂｏｕｎｃｅ ａｎｉｍａｔｉｏｎ",
    "Ｓ．ｐｒｉｎｔ","Ｋ．ｅｐｓ ｙｏｕ ｓｐｒｉｎｔｉｎｇ ａｔ ａｌｌ ｔｉｍｅｓ",
    "Ｒ．ｅｑｕｉｒｅ Ｃｌｉｃｋ","Ｖ．ｉｓｉｂｉｌｉｔｙ Ｃｈｅｃｋ","Ｍ．ｉｎ Ｓｐｅｅｄ","Ｍ．ａｘ Ｓｐｅｅｄ",
    "Ｒ．ａｎｄｏｍｉｚｅ","Ａ．ｉｍ Ａｓｓｉｓｔ","Ｓ．ｐｅａｒ Ｓｗａｐ","Ａ．ｕｔｏ ｓｗａｐ ｔｏ ｓｐｅａｒ ｏｎ ａｔｔａｃｋ",
    "Ｐ．ｌａｃｅ Ｉｎｔｅｒｖａｌ","Ｃ．ｌｉｃｋ Ｓｉｍｕｌａｔｉｏｎ","Ｃ．ｌｉｃｋ Ｄｅｌａｙ","Ｗ．ａｌｋｓｙ Ｏｐｔｉｍｉｚｅｒ",
    "Ａ．ｕｔｏ Ｐｏｔ","Ａ．ｐｐｌｙ ｇｌｏｗ ｅｆｆｅｃｔ ｔｏ ａｌｌ ｅｎｔｉｔｉｅｓ","Ａ．ｓｐｅｃｔ Ｒａｔｉｏ",
    "Ｍ．ａｃｅ Ｐｒｉｏｒｉｔｙ","Ｗ．ｉｎｄ","Ｓ．ｗａｐ Ｓｐｅｅｄ","Ｓ．ｔｒｉｃｔ Ｏｎｅ－Ｔｉｃｋ",
    "Ｓ．ｔｕｎ Ｓｌａｍ","Ａ．ｕｔｏｍａｔｉｃａｌｌｙ ａｘｅ ａｎｄ ｍａｃｅ ｓｈｉｅｌｄｅｄ ｐｌａｙｅｒｓ",
    "Ｔ．ｒｉｇ Ｈｅａｌｔｈ","Ｐ．ｏｔ Ｃｏｕｎｔ","Ｔ．ｈｒｏｗ Ｄｅｌａｙ","Ａ．ｕｔｏ Ｒｅｆｉｌｌ","Ｒ．ｅｆｉｌｌ Ｓｌｏｔ",
    "Ｋ．ｅｙＰｅａｒｌ","Ｘ．Ｐ Ｍａｎａｇｅｒ","Ｏ．ｎ ＲＭＢ","Ｎ．ｏ Ｃｏｕｎｔ Ｇｌｉｔｃｈ","Ｆ．ａｓｔ Ｍｏｄｅ",
    "Ａ．ｕｔｏＣｒｙｓｔａｌＬＶ２","Ｒ．ｅｑｕｉｒｅ Ｃｏｂｗｅｂ","Ａ．ｕｔｏ Ｗｅｂ","Ｔ．ｒａｃｅｒｓ",
    "Ｌ．ｉｎｅ Ｗｉｄｔｈ","Ｂ．ｏｘ Ａｌｐｈａ","Ｓ．ｋｅｌｅｔｏｎ","Ｒ．ｅｎｄｅｒｓ ｅｎｔｉｔｉｅｓ ｔｈｒｏｕｇｈ ｗａｌｌｓ",
    "Ｏ．ｎｌｙ Ｗｈｉｌｅ Ｉｎ Ｗｅｂ","Ａ．ｎｔｉＷｅｂ","Ａ．ｕｔｏｍａｔｉｃａｌｌｙ ｂｒｅａｋｓ ｗｅｂｓ ａｒｏｕｎｄ ｙｏｕ",
    "Ｔ．ｏｔｅｍ Ｓｌｏｔ","Ｒ．ａｎｄｏｍ Ｄｅｌａｙ Ｍｉｎ","Ｒ．ａｎｄｏｍ Ｄｅｌａｙ Ｍａｘ","Ｒ．ａｎｄｏｍ Ｇｌｏｗｓｔｏｎｅ",
    "Ｒ．ａｎｄ Ｇｌｏｗ Ｍｉｎ","Ｒ．ａｎｄ Ｇｌｏｗ Ｍａｘ","Ｄ．ｏｕｂｌｅ Ａｎｃｈｏｒ","Ｗ．ｏｒｋ Ｉｎ Ｓｃｒｅｅｎ",
    "Ｗ．ｈｉｌｅ Ｕｓｅ","Ｏ．ｎ Ｌｅｆｔ Ｃｌｉｃｋ","Ａ．ｌｌ Ｉｔｅｍｓ","Ｓ．ｗｏｒｄ Ｄｅｌａｙ Ｍｉｎ",
    "Ｓ．ｗｏｒｄ Ｄｅｌａｙ Ｍａｘ","Ａ．ｘｅ Ｄｅｌａｙ Ｍｉｎ","Ａ．ｘｅ Ｄｅｌａｙ Ｍａｘ","Ｃ．ｈｅｃｋ Ｓｈｉｅｌｄ",
    "Ｏ．ｎｌｙ Ｃｒｉｔ Ｓｗｏｒｄ","Ｏ．ｎｌｙ Ｃｒｉｔ Ａｘｅ","Ｓ．ｗｉｎｇ Ｈａｎｄ","Ｗ．ｈｉｌｅ Ａｓｃｅｎｄｉｎｇ",
    "Ｓ．ｔｒａｙ Ｂｙｐａｓｓ","Ａ．ｌｌ Ｅｎｔｉｔｉｅｓ","Ｕ．ｓｅ Ｓｈｉｅｌｄ","Ｓ．ｈｉｅｌｄ Ｔｉｍｅ",
    "Ｓ．ａｍｅ Ｐｌａｙｅｒ","Ｔ．ｒｉｇｇｅｒＢｏｔ","Ｓ．ｔｏｐ ｏｎ Ｋｉｌｌ","Ｇ．ｌｏｗｓｔｏｎｅ Ｄｅｌａｙ",
    "Ｇ．ｌｏｗｓｔｏｎｅ Ｃｈａｎｃｅ","Ｅ．ｘｐｌｏｄｅ Ｄｅｌａｙ","Ｅ．ｘｐｌｏｄｅ Ｃｈａｎｃｅ","Ｅ．ｘｐｌｏｄｅ Ｓｌｏｔ",
    "Ｏ．ｎｌｙ Ｏｗｎ","Ｏ．ｎｌｙ Ｃｈａｒｇｅ","Ａ．ｎｃｈｏｒ Ｍａｃｒｏ Ｖ２","Ｍ．ｉｎ Ｆａｌｌ Ｄｉｓｔａｎｃｅ",
    "Ａ．ｔｔａｃｋ Ｄｅｌａｙ","Ｄ．ｅｎｓｉｔｙ Ｔｈｒｅｓｈｏｌｄ","Ｔ．ａｒｇｅｔ Ｐｌａｙｅｒｓ","Ｔ．ａｒｇｅｔ Ｍｏｂｓ",
    "Ａ．ｕｔｏ Ｓｗｉｔｃｈ","Ａ．ｕｔｏ Ｍａｃｅ","Automatically attacks while falling with mace.",
    "Ｓ．ｈｏｗ Ｆｒｉｅｎｄｓ","Ｆ．ａｓｔ Ｐｌａｃｅ","Ｐ．ｌａｃｅ ｂｌｏｃｋｓ ｆａｓｔｅｒ",
    "Ｐ．ｒｅｖｅｎｔ Ａｎｃｈｏｒ","Ｐ．ｒｅｖｅｎｔｓ ｃｅｒｔａｉｎ ａｃｔｉｏｎｓ","Ｗ．ｉｎｄ Ｂｕｒｓｔ",
    "Ｏ．ｎｌｙ Ｓｗｏｒｄ","Ｏ．ｎｌｙ Ａｘｅ","Ｍ．ａｃｅ Ｓｗａｐ","Ｍ．ａｃｒｏ Ｋｅｙ","Ｂ．ｌａｔａｎｔ Ｍｏｄｅ",
    "Ｐ．ｌａｃｅ ｄｅｌａｙ","Ｂ．ｒｅａｋ ｄｅｌａｙ","Ｐ．ｌａｃｅ ｃｈａｎｃｅ","Ｂ．ｒｅａｋ ｃｈａｎｃｅ","Ｆ．ａｋｅ ｐｕｎｃｈ",
    "Ｐ．ａｒｔｉｃｌｅ Ｃｈａｎｃｅ","ｏ．ｎｅ ｎｉｎｅ ｅｉｇｈｔ Ｍａｃｒｏ","Ａ．ｕｔｏ Ｐｏｔ Ｒｅｆｉｌｌ",
    "Ｏ．ｎｌｙ Ｗｈｅｎ Ｈｕｒｔ","Ｔ．ｏｔｅｍ Ｏｆｆｈａｎｄ","Ａ．ｃｔｉｖａｔｅ ｋｅｙ","Ｓ．ｔｏｐ ｏｎ ｋｉｌｌ",
    "Ｄ．ａｍａｇｅ ｔｉｃｋ","Ａ．ｎｔｉ－Ｗｅａｋｎｅｓｓ","Ｒ．ｅｓｅｔ Ｄｅｌａｙ","Ｓ．ｈｏｗ Ｈｅａｌｔｈ",
    "Ｓ．ｈｏｗ Ｄｉｓｔａｎｃｅ","Ｎ．ａｍｅＴａｇｓ","Ｒ．ｅｎｄｅｒｓ ｃｕｓｔｏｍ ｎａｍｅｔａｇｓ ａｂｏｖｅ ｐｌａｙｅｒｓ",
    "Ｒ．ｅｆｉｌｌｓ ｙｏｕｒ ｈｏｔｂａｒ ｗｉｔｈ ｐｏｔｉｏｎｓ"
)

# Clean version without escapes for display (identical — no PS escape chars in fullwidth strings)
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
    "bottle_throw","trigger_bot","auto_web",
    "SHOP_END","SHOP_ITEM","SHOP_GLASS_PANE","SHOP_BUY",
    "SHOP_CONFIRM","SHOP_CHECK_FULL","SHOP_EXIT",
    "TARGET_ORDERS","ORDERS_SELECT","ORDERS_EXIT","ORDERS_CONFIRM","ORDERS_FINAL_EXIT","CYCLE_PAUSE",
    "PLACE_OBI","WAIT_OBI","PLACE_CRYSTAL","BREAK_CRYSTAL",
    "ROTATING_DOWN","ROTATING_BACK","REFILLING",
    "PLANTING","BONEMEALING",
    "ParseJ.a","CacheE.MISC","CacheE.RENDER","CacheE.CT",
    "CoreH","cn`$MacroState","co`$State",
    "Ａ．ｃｔｉｖａｔｅ Ｋｅｙ","Ｃ．ｈｅｃｋ Ｐｌａｃｅ","Ｓ．ｗｉｔｃｈ Ｄｅｌａｙ","Ｓ．ｗｉｔｃｈ Ｃｈａｎｃｅ",
    "Ｐ．ｌａｃｅ Ｄｅｌａｙ","Ｐ．ｌａｃｅ Ｃｈａｎｃｅ","Ｗ．ｏｒｋ Ｗｉｔｈ Ｔｏｔｅｍ","Ｗ．ｏｒｋ Ｗｉｔｈ Ｃｒｙｓｔａｌ",
    "Ｓ．ｗｏｒｄ Ｓｗａｐ","Ａ．ｕｔｏ Ｈｉｔ Ｃｒｙｓｔａｌ","A.utomatically hit-crystals for you",
    "Ｊ．ｕｍｐ Ｒｅｓｅｔ Ｃｈａｎｃｅ","Ａ．ｕｔｏ Ｊｕｍｐ Ｒｅｓｅｔ","Ｓ．ｉｌｅｎｔ Ｒｏｔａｔｉｏｎｓ",
    "Ｈ．ｏｒｉｚｏｎｔａｌ Ａｉｍ Ｓｐｅｅｄ","Ｖ．ｅｒｔｉｃａｌ Ａｉｍ Ｓｐｅｅｄ","Ｉ．ｎｃｌｕｄｅ Ｈｅａｄ",
    "Ｗ．ｅｂ Ｄｅｌａｙ","Ｈ．ｏｌｄｉｎｇ Ｗｅｂ","Ｃ．ｌｉｃｋｉｎｇ","Ｂ．ｒｅａｋ Ｂｌｏｃｋｓ",
    "Ｎ．ｏｔ Ｗｈｅｎ Ａｆｆｅｃｔｓ Ｐｌａｙｅｒ","Ａ．ｕｔｏＷｅｂ","Ｐ．ｌａｃｅｓ Ｗｅｂｓ Ｏｎ Ｅｎｅｍｉｅｓ",
    "Ｍ．ｉｎ Ｔｏｔｅｍｓ","Ｍ．ｉｎ Ｐｅａｒｌｓ","Ｔ．ｏｔｅｍ Ｆｉｒｓｔ","Ｄ．ｒｏｐ Ｉｎｔｅｒｖａｌ",
    "Ｒ．ａｎｄｏｍ Ｐａｔｔｅｒｎ","Ｌ．ｏｏｔ Ｙｅｅｔｅｒ","Ｒ．ｅｑｕｉｒｅ Ｓｗｏｒｄ","Ｓ．ｗｉｔｃｈ Ｂａｃｋ",
    "Ａ．ｕｔｏ Ｔｏｔｅｍ Ｈｉｔ","ｐ．ｌａｃｅＩｎｔｅｒｖａｌ","ｂ．ｒｅａｋＩｎｔｅｒｖａｌ","ｓ．ｔｏｐＯｎＫｉｌｌ",
    "ａ．ｃｔｉｖａｔｅＯｎＲｉｇｈｔＣｌｉｃｋ","ｄ．ａｍａｇｅｔｉｃｋ","ｈ．ｏｌｄＣｒｙｓｔａｌ","ｆ．ａｋｅＰｕｎｃｈ",
    "Ｌ．ＷＦＨ Ｃｒｙｓｔａｌ","Ｎ．ｏ Ｓｌｏｗｄｏｗｎ","Ａ．ｎｔｉ Ｗｅｂ","Ｅ．ｘｐａｎｄ Ａｍｏｕｎｔ",
    "Ｐ．ｌａｙｅｒｓ Ｏｎｌｙ","Ｉ．ｎｖｉｓｉｂｌｅｓ","Ｓ．ｍａｒｔ Ｊｉｔｔｅｒ","Ｒ．ｅｎｄｅｒ Ｈｉｔｂｏｘｅｓ",
    "Ｈ．ｉｔｂｏｘｅｓ","Expands entity bounding boxes for easier targeting.",
    "Ｎ．ｏＢｏｕｎｃｅ","Ｒ．ｅｍｏｖｅｓ ｔｈｅ ｃｒｙｓｔａｌ ｂｏｕｎｃｅ ａｎｉｍａｔｉｏｎ",
    "Ｓ．ｐｒｉｎｔ","Ｋ．ｅｐｓ ｙｏｕ ｓｐｒｉｎｔｉｎｇ ａｔ ａｌｌ ｔｉｍｅｓ",
    "Ｒ．ｅｑｕｉｒｅ Ｃｌｉｃｋ","Ｖ．ｉｓｉｂｉｌｉｔｙ Ｃｈｅｃｋ","Ｍ．ｉｎ Ｓｐｅｅｄ","Ｍ．ａｘ Ｓｐｅｅｄ",
    "Ｒ．ａｎｄｏｍｉｚｅ","Ａ．ｉｍ Ａｓｓｉｓｔ","Ｓ．ｐｅａｒ Ｓｗａｐ","Ａ．ｕｔｏ ｓｗａｐ ｔｏ ｓｐｅａｒ ｏｎ ａｔｔａｃｋ",
    "Ｐ．ｌａｃｅ Ｉｎｔｅｒｖａｌ","Ｃ．ｌｉｃｋ Ｓｉｍｕｌａｔｉｏｎ","Ｃ．ｌｉｃｋ Ｄｅｌａｙ","Ｗ．ａｌｋｓｙ Ｏｐｔｉｍｉｚｅｒ",
    "Ａ．ｕｔｏ Ｐｏｔ","Ａ．ｐｐｌｙ ｇｌｏｗ ｅｆｆｅｃｔ ｔｏ ａｌｌ ｅｎｔｉｔｉｅｓ","Ａ．ｓｐｅｃｔ Ｒａｔｉｏ",
    "Ｍ．ａｃｅ Ｐｒｉｏｒｉｔｙ","Ｗ．ｉｎｄ","Ｓ．ｗａｐ Ｓｐｅｅｄ","Ｓ．ｔｒｉｃｔ Ｏｎｅ－Ｔｉｃｋ",
    "Ｓ．ｔｕｎ Ｓｌａｍ","Ａ．ｕｔｏｍａｔｉｃａｌｌｙ ａｘｅ ａｎｄ ｍａｃｅ ｓｈｉｅｌｄｅｄ ｐｌａｙｅｒｓ",
    "Ｔ．ｒｉｇ Ｈｅａｌｔｈ","Ｐ．ｏｔ Ｃｏｕｎｔ","Ｔ．ｈｒｏｗ Ｄｅｌａｙ","Ａ．ｕｔｏ Ｒｅｆｉｌｌ","Ｒ．ｅｆｉｌｌ Ｓｌｏｔ",
    "Ｋ．ｅｙＰｅａｒｌ","Ｘ．Ｐ Ｍａｎａｇｅｒ","Ｏ．ｎ ＲＭＢ","Ｎ．ｏ Ｃｏｕｎｔ Ｇｌｉｔｃｈ","Ｆ．ａｓｔ Ｍｏｄｅ",
    "Ａ．ｕｔｏＣｒｙｓｔａｌＬＶ２","Ｒ．ｅｑｕｉｒｅ Ｃｏｂｗｅｂ","Ａ．ｕｔｏ Ｗｅｂ","Ｔ．ｒａｃｅｒｓ",
    "Ｌ．ｉｎｅ Ｗｉｄｔｈ","Ｂ．ｏｘ Ａｌｐｈａ","Ｓ．ｋｅｌｅｔｏｎ","Ｒ．ｅｎｄｅｒｓ ｅｎｔｉｔｉｅｓ ｔｈｒｏｕｇｈ ｗａｌｌｓ",
    "Ｏ．ｎｌｙ Ｗｈｉｌｅ Ｉｎ Ｗｅｂ","Ａ．ｎｔｉＷｅｂ","Ａ．ｕｔｏｍａｔｉｃａｌｌｙ ｂｒｅａｋｓ ｗｅｂｓ ａｒｏｕｎｄ ｙｏｕ",
    "Ｔ．ｏｔｅｍ Ｓｌｏｔ","Ｒ．ａｎｄｏｍ Ｄｅｌａｙ Ｍｉｎ","Ｒ．ａｎｄｏｍ Ｄｅｌａｙ Ｍａｘ","Ｒ．ａｎｄｏｍ Ｇｌｏｗｓｔｏｎｅ",
    "Ｒ．ａｎｄ Ｇｌｏｗ Ｍｉｎ","Ｒ．ａｎｄ Ｇｌｏｗ Ｍａｘ","Ｄ．ｏｕｂｌｅ Ａｎｃｈｏｒ","Ｗ．ｏｒｋ Ｉｎ Ｓｃｒｅｅｎ",
    "Ｗ．ｈｉｌｅ Ｕｓｅ","Ｏ．ｎ Ｌｅｆｔ Ｃｌｉｃｋ","Ａ．ｌｌ Ｉｔｅｍｓ","Ｓ．ｗｏｒｄ Ｄｅｌａｙ Ｍｉｎ",
    "Ｓ．ｗｏｒｄ Ｄｅｌａｙ Ｍａｘ","Ａ．ｘｅ Ｄｅｌａｙ Ｍｉｎ","Ａ．ｘｅ Ｄｅｌａｙ Ｍａｘ","Ｃ．ｈｅｃｋ Ｓｈｉｅｌｄ",
    "Ｏ．ｎｌｙ Ｃｒｉｔ Ｓｗｏｒｄ","Ｏ．ｎｌｙ Ｃｒｉｔ Ａｘｅ","Ｓ．ｗｉｎｇ Ｈａｎｄ","Ｗ．ｈｉｌｅ Ａｓｃｅｎｄｉｎｇ",
    "Ｓ．ｔｒａｙ Ｂｙｐａｓｓ","Ａ．ｌｌ Ｅｎｔｉｔｉｅｓ","Ｕ．ｓｅ Ｓｈｉｅｌｄ","Ｓ．ｈｉｅｌｄ Ｔｉｍｅ",
    "Ｓ．ａｍｅ Ｐｌａｙｅｒ","Ｔ．ｒｉｇｇｅｒＢｏｔ","Ｓ．ｔｏｐ ｏｎ Ｋｉｌｌ","Ｇ．ｌｏｗｓｔｏｎｅ Ｄｅｌａｙ",
    "Ｇ．ｌｏｗｓｔｏｎｅ Ｃｈａｎｃｅ","Ｅ．ｘｐｌｏｄｅ Ｄｅｌａｙ","Ｅ．ｘｐｌｏｄｅ Ｃｈａｎｃｅ","Ｅ．ｘｐｌｏｄｅ Ｓｌｏｔ",
    "Ｏ．ｎｌｙ Ｏｗｎ","Ｏ．ｎｌｙ Ｃｈａｒｇｅ","Ａ．ｎｃｈｏｒ Ｍａｃｒｏ Ｖ２","Ｍ．ｉｎ Ｆａｌｌ Ｄｉｓｔａｎｃｅ",
    "Ａ．ｔｔａｃｋ Ｄｅｌａｙ","Ｄ．ｅｎｓｉｔｙ Ｔｈｒｅｓｈｏｌｄ","Ｔ．ａｒｇｅｔ Ｐｌａｙｅｒｓ","Ｔ．ａｒｇｅｔ Ｍｏｂｓ",
    "Ａ．ｕｔｏ Ｓｗｉｔｃｈ","Ａ．ｕｔｏ Ｍａｃｅ","Automatically attacks while falling with mace.",
    "Ｓ．ｈｏｗ Ｆｒｉｅｎｄｓ","Ｆ．ａｓｔ Ｐｌａｃｅ","Ｐ．ｌａｃｅ ｂｌｏｃｋｓ ｆａｓｔｅｒ",
    "Ｐ．ｒｅｖｅｎｔ Ａｎｃｈｏｒ","Ｐ．ｒｅｖｅｎｔｓ ｃｅｒｔａｉｎ ａｃｔｉｏｎｓ","Ｗ．ｉｎｄ Ｂｕｒｓｔ",
    "Ｏ．ｎｌｙ Ｓｗｏｒｄ","Ｏ．ｎｌｙ Ａｘｅ","Ｍ．ａｃｅ Ｓｗａｐ","Ｍ．ａｃｒｏ Ｋｅｙ","Ｂ．ｌａｔａｎｔ Ｍｏｄｅ",
    "Ｐ．ｌａｃｅ ｄｅｌａｙ","Ｂ．ｒｅａｋ ｄｅｌａｙ","Ｐ．ｌａｃｅ ｃｈａｎｃｅ","Ｂ．ｒｅａｋ ｃｈａｎｃｅ","Ｆ．ａｋｅ ｐｕｎｃｈ",
    "Ｐ．ａｒｔｉｃｌｅ Ｃｈａｎｃｅ","ｏ．ｎｅ ｎｉｎｅ ｅｉｇｈｔ Ｍａｃｒｏ","Ａ．ｕｔｏ Ｐｏｔ Ｒｅｆｉｌｌ",
    "Ｏ．ｎｌｙ Ｗｈｅｎ Ｈｕｒｔ","Ｔ．ｏｔｅｍ Ｏｆｆｈａｎｄ","Ａ．ｃｔｉｖａｔｅ ｋｅｙ","Ｓ．ｔｏｐ ｏｎ ｋｉｌｌ",
    "Ｄ．ａｍａｇｅ ｔｉｃｋ","Ａ．ｎｔｉ－Ｗｅａｋｎｅｓｓ","Ｒ．ｅｓｅｔ Ｄｅｌａｙ","Ｓ．ｈｏｗ Ｈｅａｌｔｈ",
    "Ｓ．ｈｏｗ Ｄｉｓｔａｎｃｅ","Ｎ．ａｍｅＴａｇｓ","Ｒ．ｅｎｄｅｒｓ ｃｕｓｔｏｍ ｎａｍｅｔａｇｓ ａｂｏｖｅ ｐｌａｙｅｒｓ",
    "Ｒ．ｅｆｉｌｌｓ ｙｏｕｒ ｈｏｔｂａｒ ｗｉｔｈ ｐｏｔｉｏｎｓ"
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
Write-Host " o " -ForegroundColor Black -BackgroundColor Yellow -NoNewline
Write-Host "  Scans .jar mod files for dqrkis cheat strings   " -ForegroundColor DarkGray
Write-Host ""
Write-Host ("  " + "~" * 64) -ForegroundColor DarkYellow
Write-Host ""

# ================================================================
#  INSTANCE AUTO-DETECTION
# ================================================================

$procs = Get-Process -Name "java","javaw" -ErrorAction SilentlyContinue

if ($procs) {
    Write-Host "  >> Minecraft is RUNNING" -ForegroundColor Yellow
    foreach ($p in $procs) {
        try {
            $up = (Get-Date) - $p.StartTime
            Write-Host "     $($p.Name) (PID $($p.Id))  |  Started: $($p.StartTime.ToString('HH:mm:ss'))  |  Uptime: $([int]$up.TotalHours)h $($up.Minutes)m" -ForegroundColor DarkYellow
        } catch {}
    }
    Write-Host ""
}

$autoFolder = $null; $autoLabel = $null
if ($procs) {
    foreach ($proc in $procs) {
        try {
            $wmi = Get-WmiObject Win32_Process -Filter "ProcessId=$($proc.Id)" -ErrorAction SilentlyContinue
            $cmdLine = if ($wmi) { $wmi.CommandLine } else { "" }
            if ($cmdLine) {
                $m = [regex]::Match($cmdLine, '--gameDir\s+"([^"]+)"')
                if (-not $m.Success) { $m = [regex]::Match($cmdLine, '--gameDir\s+(\S+)') }
                if ($m.Success) {
                    $gameDir  = $m.Groups[1].Value.TrimEnd('\')
                    $candidate = Join-Path $gameDir "mods"
                    if (Test-Path $candidate) {
                        $autoFolder = $candidate
                        $autoLabel  = Split-Path (Split-Path $gameDir -Parent) -Leaf
                        if ([string]::IsNullOrWhiteSpace($autoLabel) -or $autoLabel -eq "instances") {
                            $autoLabel = Split-Path $gameDir -Leaf
                        }
                    }
                }
                if (-not $autoFolder) {
                    $m2 = [regex]::Match($cmdLine, '-Dminecraft\.appDir=([^\s"]+)')
                    if ($m2.Success) {
                        $gameDir   = $m2.Groups[1].Value.Trim('"').TrimEnd('\')
                        $candidate = Join-Path $gameDir "mods"
                        if (Test-Path $candidate) { $autoFolder = $candidate; $autoLabel = Split-Path $gameDir -Leaf }
                    }
                }
            }
        } catch {}
        if ($autoFolder) { break }
    }
}

# ----------------------------------------------------------------
#  PATH RESOLUTION
# ----------------------------------------------------------------

if ($autoFolder) {
    Write-Host "  " -NoNewline
    Write-Host " ACTIVE INSTANCE DETECTED " -ForegroundColor Black -BackgroundColor Yellow
    Write-Host ""
    Write-Host "  " -NoNewline
    Write-Host " >> " -ForegroundColor Black -BackgroundColor DarkYellow -NoNewline
    Write-Host "  $autoLabel" -NoNewline -ForegroundColor Yellow
    Write-Host "  " -NoNewline
    Write-Host $autoFolder -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Press " -NoNewline -ForegroundColor DarkGray
    Write-Host "Enter" -NoNewline -ForegroundColor Yellow
    Write-Host " to scan this instance, or type a custom path to override:" -ForegroundColor DarkGray
    Write-Host ""
    $userInput = Read-Host "  Choice"
    $modsPath  = if ([string]::IsNullOrWhiteSpace($userInput)) { $autoFolder } else { $userInput.Trim() }
} else {
    if ($procs) {
        Write-Host "  " -NoNewline
        Write-Host " Minecraft is running but the instance path could not be detected. " -ForegroundColor Black -BackgroundColor DarkYellow
        Write-Host ""
    } else {
        Write-Host "  " -NoNewline
        Write-Host " Minecraft is not running. " -ForegroundColor Black -BackgroundColor DarkGray
        Write-Host ""
    }
    Write-Host "  Enter the path to your mods folder:" -ForegroundColor Yellow
    Write-Host ""
    do {
        $userInput = Read-Host "  Path"
        $modsPath  = $userInput.Trim()
        if ([string]::IsNullOrWhiteSpace($modsPath)) {
            Write-Host "  " -NoNewline
            Write-Host " ERROR " -ForegroundColor White -BackgroundColor DarkRed -NoNewline
            Write-Host "  No path entered. Please enter the full path to your mods folder." -ForegroundColor Red
        }
    } while ([string]::IsNullOrWhiteSpace($modsPath))
}

Write-Host ""

if (-not (Test-Path $modsPath)) {
    Write-Host "  " -NoNewline
    Write-Host " ERROR " -ForegroundColor White -BackgroundColor DarkRed -NoNewline
    Write-Host "  Path does not exist: $modsPath" -ForegroundColor Red
    Write-Host ""
    Read-Host "  Press Enter to exit"
    exit 1
}

$jarFiles = @(Get-ChildItem -Path $modsPath -Filter "*.jar" -ErrorAction SilentlyContinue)

if ($jarFiles.Count -eq 0) {
    Write-Host "  " -NoNewline
    Write-Host " o " -ForegroundColor Black -BackgroundColor DarkYellow -NoNewline
    Write-Host "  No .jar files found in: $modsPath" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "  Press Enter to exit"
    exit 0
}

Write-Host ("  " + "~" * 64) -ForegroundColor DarkYellow
Write-Host "  Scanning : " -NoNewline -ForegroundColor DarkGray
Write-Host $modsPath -ForegroundColor Yellow
Write-Host "  Found    : " -NoNewline -ForegroundColor DarkGray
Write-Host "$($jarFiles.Count) jar file(s)" -ForegroundColor White
Write-Host ("  " + "~" * 64) -ForegroundColor DarkYellow
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



# --- ERRORS ---
if ($errorMods.Count -gt 0) {
    Write-Host ""
    Write-Host ("  " + "~" * 64) -ForegroundColor DarkYellow
    Write-Host "  " -NoNewline
    Write-Host " o " -ForegroundColor Black -BackgroundColor DarkYellow -NoNewline
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
Write-Host $sumSep -ForegroundColor DarkYellow
Write-Host "  SUMMARY" -ForegroundColor Yellow
Write-Host $sumSep -ForegroundColor DarkYellow
Write-Host ""
Write-Host "  Total scanned  : " -NoNewline -ForegroundColor DarkGray; Write-Host "$totalScanned" -ForegroundColor White
Write-Host "  Flagged mods   : " -NoNewline -ForegroundColor DarkGray
if ($flaggedMods.Count -gt 0) { Write-Host "$($flaggedMods.Count)" -ForegroundColor Red } else { Write-Host "0" -ForegroundColor Green }
Write-Host "  Clean mods     : " -NoNewline -ForegroundColor DarkGray; Write-Host "$($cleanMods.Count)" -ForegroundColor Green
Write-Host "  Errored        : " -NoNewline -ForegroundColor DarkGray
if ($errorMods.Count -gt 0) { Write-Host "$($errorMods.Count)" -ForegroundColor Yellow } else { Write-Host "0" -ForegroundColor Green }
Write-Host ""
Write-Host $sumSep -ForegroundColor DarkYellow
Write-Host ""

if ($flaggedMods.Count -gt 0) {
    Write-Host "  " -NoNewline
    Write-Host " dqrkis fucked " -ForegroundColor White -BackgroundColor DarkRed
} else {
    Write-Host "  " -NoNewline
    Write-Host " No dqrkis found " -ForegroundColor Black -BackgroundColor DarkGreen
}

Write-Host ""
Write-Host "  Analysis complete! Thanks for using CheesyDqrkisFucker " -NoNewline -ForegroundColor White
Write-Host "o" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Created by  : " -NoNewline -ForegroundColor DarkGray
Write-Host "cheese cat" -ForegroundColor Yellow
Write-Host "  Discord     : " -NoNewline -ForegroundColor DarkGray
Write-Host "cheese_cat0" -ForegroundColor Yellow
Write-Host "  GitHub      : " -NoNewline -ForegroundColor DarkGray
Write-Host "github.com/cheesecatlol" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Created by  : " -NoNewline -ForegroundColor DarkGray
Write-Host "nic" -ForegroundColor Yellow
Write-Host "  Discord     : " -NoNewline -ForegroundColor DarkGray
Write-Host "mecz.exe" -ForegroundColor Yellow
Write-Host "  GitHub      : " -NoNewline -ForegroundColor DarkGray
Write-Host "github.com/Nickk196" -ForegroundColor Yellow
Write-Host ""
Write-Host $sumSep -ForegroundColor DarkYellow
Write-Host ""
Read-Host "  Press Enter to exit"
