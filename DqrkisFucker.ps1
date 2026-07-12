
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
Add-Type -AssemblyName System.IO.Compression.FileSystem

$ErrorActionPreference = "SilentlyContinue"



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

    $L1  = "  ██████╗██╗  ██╗███████╗███████╗███████╗██╗   ██╗"
    $L2  = " ██╔════╝██║  ██║██╔════╝██╔════╝██╔════╝╚██╗ ██╔╝"
    $L3  = " ██║     ███████║█████╗  █████╗  ███████╗ ╚████╔╝ "
    $L4  = " ██║     ██╔══██║██╔══╝  ██╔══╝  ╚════██║  ╚██╔╝  "
    $L5  = " ╚██████╗██║  ██║███████╗███████╗███████║   ██║   "
    $L6  = "  ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝   ╚═╝   "

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
    Write-Host "  o O o O o  [ CheesyDqrkisFucker v1.0 - by cheese cat ]  o O o O o  " -ForegroundColor DarkYellow
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
    $pct = [Math]::Round(($Current / $Total) * 100)
    $filled = [Math]::Round(($Current / $Total) * 40)
    $empty = 40 - $filled
    $bar = ("█" * $filled) + ("░" * $empty)
    Write-Host "`r  [$bar] $pct%  $Label          " -NoNewline -ForegroundColor Yellow
}

$DqrisStrings = @(
    # direct branding / endpoints
    "dqrkis", "dqris", "dqrkis.xyz", "dqris.xyz", "Dqrkis Client",
    "Accent: dqrkis purple",
    "http://51.38.134.200:3000/api/verify",
    "http://51.38.134.200:3000/apo/launch",


    "aim_assist", "anti_web", "auto_double_hand", "auto_dtap",
    "auto_hit_crystal", "auto_inventory_totem", "auto_jump_reset",
    "auto_mace", "auto_neth_pot", "auto_pot", "auto_pot_refill",
    "auto_totem_hit", "auto_web", "bottle_throw", "double_anchor",
    "fast_place", "hover_totem", "key_pearl", "loot_yeeter",
    "mace_swap", "macro_198", "no_bounce", "quick_strike",
    "safe_anchor", "shield_disabler", "stun_slam", "totem_offhand",
    "trigger_bot", "walksy_optimizer",
    "BREAK_CRYSTAL", "CLICK_CHEST_SLOT", "CLICK_CONFIRM_SLOT",
    "CLICK_SLOT_51", "CLICK_TARGET_ITEM", "CLICKING_CONFIRM",
    "CLICKING_DROP_ALL", "CLICKING_NEXT_PAGE", "CLICKING_SLOT_46",
    "CLICKING_SLOT_50", "DOUBLE_ESCAPE", "DOUBLE_RIGHTCLICK_FIRST",
    "DOUBLE_RIGHTCLICK_SECOND", "KEYBIND_CHANGE", "LOOTING_BONES",
    "LOW_TOTEM", "MACE_SWAPPED", "MODULE_DISABLED", "MODULE_ENABLED",
    "OFFHAND_XP", "PLACE_CRYSTAL", "REOFFHAND_TOTEM", "ROTATE_BACK",
    "ROTATE_DOWN", "TARGET_ORDERS", "THROW_XP",


    "A.utomatically axe and mace shielded players",
    "A.utomatically hit-crystals for you",
    "A.ssists your aim towards targets smoothly",
    "P.laces webs at enemies feet automatically",
    "Automatically attacks while falling with mace.",
    "Mace mode activated - searching for targets...",
    "C.ombat macro for 1.9.8 style gameplay",
    "B.reaks webs around you instantly",
    "Renders custom nametags above players",
    "T.hrows exp bottles quickly while holding right click",
    "A.ttacks instantly when enemy pops a totem",
    "A.ttacks with an axe to disable enemy shields",
    "A.utomatically places a totem in your offhand",
    "Jumps when you take damage to reduce knockback.",
    "Removes the crystal bounce animation",
    "H.overs a totem in inventory for quick access",
    "M.oves totems to your offhand from inventory",
    "T.hrows an ender pearl instantly on key press",
    "T.hrows away junk items from your inventory",
    "P.laces two anchors for massive damage",
    "D.ouble anchor module",
    "Macing target for high damage!",
    "No axe found - using mace only",
    "Action Speed (ms)", "C.lick Simulation", "D.amage Tick",
    "O.nly Axe", "P.article Chance", "P.lace blocks ",
    "P.redict ", "P.redict Crystals", "R.andom Delay Min",
    "S.how", "S.how Health", "S.tay Open For", "S.top On Kill",
    "Sword Swap", "W.hile Ascen", "F.orce Totem", "GUI Key: F12",
    "Search modules...", "Work With Totem",


    "FINDING_SPAWNER", "OPENING_SPAWNER", "WAITING_SPAWNER_GUI",
    "LOOTING_BONES", "CLOSING_SPAWNER", "ORDER_COMMAND",
    "WAIT_ORDER_GUI", "SELECT_ORDER_ITEM", "WAIT_DELIVERY_GUI",
    "DELIVERING_BONES", "WAIT_AFTER_DELIVERY_1", "CLOSING_DELIVERY",
    "WAIT_AFTER_CLOSE_DELIVERY", "WAIT_CONFIRM_GUI", "WAIT_CONFIRM_SETTLE",
    "WAIT_AFTER_CONFIRM_1", "WAIT_AFTER_CONFIRM_2", "WAIT_AFTER_CONFIRM_3",
    "POST_CYCLE_DELAY", "SHOP_END", "SHOP_ITEM", "SHOP_GLASS_PANE",
    "SHOP_BUY", "SHOP_CONFIRM", "SHOP_CHECK_FULL", "SHOP_EXIT",
    "ORDERS_SELECT", "ORDERS_EXIT", "ORDERS_CONFIRM", "ORDERS_FINAL_EXIT",
    "CYCLE_PAUSE", "PLACE_OBI", "WAIT_OBI", "ROTATING_DOWN",
    "ROTATING_BACK"

    # fullwidth Dqris/Dqrkis module/settings strings
    "Ａ．ｕｔｏ Ｈｉｔ Ｃｒｙｓｔａｌ", "Ａ．ｕｔｏ Ｊｕｍｐ Ｒｅｓｅｔ",
    "Ａ．ｕｔｏ Ｍａｃｅ", "Ａ．ｕｔｏ Ｐｏｔ", "Ａ．ｕｔｏ Ｐｏｔ Ｒｅｆｉｌｌ",
    "Ａ．ｕｔｏ Ｔｏｔｅｍ Ｈｉｔ", "Ａ．ｕｔｏ Ｗｅｂ", "Ａ．ｕｔｏＣｒｙｓｔａｌＬＶ２",
    "Ａ．ｕｔｏＷｅｂ", "Ａ．ｉｍ Ａｓｓｉｓｔ", "Ａ．ｎｔｉ Ｗｅｂ",
    "Ａ．ｎｔｉＷｅｂ", "Ｄ．ｏｕｂｌｅ Ａｎｃｈｏｒ", "Ｆ．ａｓｔ Ｐｌａｃｅ",
    "Ｋ．ｅｙＰｅａｒｌ", "Ｌ．ｏｏｔ Ｙｅｅｔｅｒ", "Ｍ．ａｃｅ Ｓｗａｐ",
    "Ｍ．ａｃｅ Ｐｒｉｏｒｉｔｙ", "Ｎ．ｏＢｏｕｎｃｅ", "Ｓ．ｔｕｎ Ｓｌａｍ",
    "Ｔ．ｒｉｇｇｅｒＢｏｔ", "Ｔ．ｏｔｅｍ Ｏｆｆｈａｎｄ", "Ｗ．ａｌｋｓｙ Ｏｐｔｉｍｉｚｅｒ",
    "Ｗ．ｏｒｋ Ｗｉｔｈ Ｔｏｔｅｍ", "Ｗ．ｏｒｋ Ｗｉｔｈ Ｃｒｙｓｔａｌ",
    "Ｐ．ｌａｃｅ ｂｌｏｃｋｓ ｆａｓｔｅｒ",
    "Ｒ．ｅｍｏｖｅｓ ｔｈｅ ｃｒｙｓｔａｌ ｂｏｕｎｃｅ ａｎｉｍａｔｉｏｎ",
    "Ｒ．ｅｆｉｌｌｓ ｙｏｕｒ ｈｏｔｂａｒ ｗｉｔｈ ｐｏｔｉｏｎｓ",
    "Ｋ．ｅｐｓ ｙｏｕ ｓｐｒｉｎｔｉｎｇ ａｔ ａｌｌ ｔｉｍｅｓ"
    ,"Ａ．ｃｔｉｖａｔｅ Ｋｅｙ", "Ｃ．ｈｅｃｋ Ｐｌａｃｅ",
    "Ｓ．ｗｉｔｃｈ Ｄｅｌａｙ", "Ｓ．ｗｉｔｃｈ Ｃｈａｎｃｅ",
    "Ｐ．ｌａｃｅ Ｄｅｌａｙ", "Ｐ．ｌａｃｅ Ｃｈａｎｃｅ",
    "Ｓ．ｗｏｒｄ Ｓｗａｐ", "Ｊ．ｕｍｐ Ｒｅｓｅｔ Ｃｈａｎｃｅ",
    "Ｓ．ｉｌｅｎｔ Ｒｏｔａｔｉｏｎｓ", "Ｈ．ｏｒｉｚｏｎｔａｌ Ａｉｍ Ｓｐｅｅｄ",
    "Ｖ．ｅｒｔｉｃａｌ Ａｉｍ Ｓｐｅｅｄ", "Ｉ．ｎｃｌｕｄｅ Ｈｅａｄ",
    "Ｗ．ｅｂ Ｄｅｌａｙ", "Ｈ．ｏｌｄｉｎｇ Ｗｅｂ",
    "Ｃ．ｌｉｃｋｉｎｇ", "Ｂ．ｒｅａｋ Ｂｌｏｃｋｓ",
    "Ｎ．ｏｔ Ｗｈｅｎ Ａｆｆｅｃｔｓ Ｐｌａｙｅｒ",
    "Ｐ．ｌａｃｅｓ Ｗｅｂｓ Ｏｎ Ｅｎｅｍｉｅｓ",
    "Ｍ．ｉｎ Ｔｏｔｅｍｓ", "Ｍ．ｉｎ Ｐｅａｒｌｓ",
    "Ｔ．ｏｔｅｍ Ｆｉｒｓｔ", "Ｄ．ｒｏｐ Ｉｎｔｅｒｖａｌ",
    "Ｒ．ａｎｄｏｍ Ｐａｔｔｅｒｎ", "Ｒ．ｅｑｕｉｒｅ Ｓｗｏｒｄ",
    "Ｓ．ｗｉｔｃｈ Ｂａｃｋ", "ｐ．ｌａｃｅＩｎｔｅｒｖａｌ",
    "ｂ．ｒｅａｋＩｎｔｅｒｖａｌ", "ｓ．ｔｏｐＯｎＫｉｌｌ",
    "ａ．ｃｔｉｖａｔｅＯｎＲｉｇｈｔＣｌｉｃｋ", "ｄ．ａｍａｇｅｔｉｃｋ",
    "ｈ．ｏｌｄＣｒｙｓｔａｌ", "ｆ．ａｋｅＰｕｎｃｈ",
    "Ｌ．ＷＦＨ Ｃｒｙｓｔａｌ", "Ｎ．ｏ Ｓｌｏｗｄｏｗｎ",
    "Ｅ．ｘｐａｎｄ Ａｍｏｕｎｔ", "Ｐ．ｌａｙｅｒｓ Ｏｎｌｙ",
    "Ｉ．ｎｖｉｓｉｂｌｅｓ", "Ｓ．ｍａｒｔ Ｊｉｔｔｅｒ",
    "Ｒ．ｅｎｄｅｒ Ｈｉｔｂｏｘｅｓ", "Ｈ．ｉｔｂｏｘｅｓ",
    "Expands entity bounding boxes for easier targeting.",
    "Ｓ．ｐｒｉｎｔ", "Ｒ．ｅｑｕｉｒｅ Ｃｌｉｃｋ",
    "Ｖ．ｉｓｉｂｉｌｉｔｙ Ｃｈｅｃｋ", "Ｍ．ｉｎ Ｓｐｅｅｄ",
    "Ｍ．ａｘ Ｓｐｅｅｄ", "Ｒ．ａｎｄｏｍｉｚｅ",
    "Ｓ．ｐｅａｒ Ｓｗａｐ", "Ａ．ｕｔｏ ｓｗａｐ ｔｏ ｓｐｅａｒ ｏｎ ａｔｔａｃｋ",
    "Ｐ．ｌａｃｅ Ｉｎｔｅｒｖａｌ", "Ｃ．ｌｉｃｋ Ｓｉｍｕｌａｔｉｏｎ",
    "Ｃ．ｌｉｃｋ Ｄｅｌａｙ", "Ａ．ｐｐｌｙ ｇｌｏｗ ｅｆｆｅｃｔ ｔｏ ａｌｌ ｅｎｔｉｔｉｅｓ",
    "Ａ．ｓｐｅｃｔ Ｒａｔｉｏ", "Ｗ．ｉｎｄ",
    "Ｓ．ｗａｐ Ｓｐｅｅｄ", "Ｓ．ｔｒｉｃｔ Ｏｎｅ－Ｔｉｃｋ",
    "Ｔ．ｒｉｇ Ｈｅａｌｔｈ", "Ｐ．ｏｔ Ｃｏｕｎｔ",
    "Ｔ．ｈｒｏｗ Ｄｅｌａｙ", "Ａ．ｕｔｏ Ｒｅｆｉｌｌ",
    "Ｒ．ｅｆｉｌｌ Ｓｌｏｔ", "Ｘ．Ｐ Ｍａｎａｇｅｒ",
    "Ｏ．ｎ ＲＭＢ", "Ｎ．ｏ Ｃｏｕｎｔ Ｇｌｉｔｃｈ",
    "Ｆ．ａｓｔ Ｍｏｄｅ", "Ｒ．ｅｑｕｉｒｅ Ｃｏｂｗｅｂ",
    "Ｔ．ｒａｃｅｒｓ", "Ｌ．ｉｎｅ Ｗｉｄｔｈ",
    "Ｂ．ｏｘ Ａｌｐｈａ", "Ｓ．ｋｅｌｅｔｏｎ",
    "Ｒ．ｅｎｄｅｒｓ ｅｎｔｉｔｉｅｓ ｔｈｒｏｕｇｈ ｗａｌｌｓ",
    "Ｏ．ｎｌｙ Ｗｈｉｌｅ Ｉｎ Ｗｅｂ",
    "Ａ．ｕｔｏｍａｔｉｃａｌｌｙ ｂｒｅａｋｓ ｗｅｂｓ ａｒｏｕｎｄ ｙｏｕ",
    "Ｔ．ｏｔｅｍ Ｓｌｏｔ", "Ｒ．ａｎｄｏｍ Ｄｅｌａｙ Ｍｉｎ",
    "Ｒ．ａｎｄｏｍ Ｄｅｌａｙ Ｍａｘ", "Ｒ．ａｎｄｏｍ Ｇｌｏｗｓｔｏｎｅ",
    "Ｒ．ａｎｄ Ｇｌｏｗ Ｍｉｎ", "Ｒ．ａｎｄ Ｇｌｏｗ Ｍａｘ",
    "Ｗ．ｏｒｋ Ｉｎ Ｓｃｒｅｅｎ", "Ｗ．ｈｉｌｅ Ｕｓｅ",
    "Ｏ．ｎ Ｌｅｆｔ Ｃｌｉｃｋ", "Ａ．ｌｌ Ｉｔｅｍｓ",
    "Ｓ．ｗｏｒｄ Ｄｅｌａｙ Ｍｉｎ", "Ｓ．ｗｏｒｄ Ｄｅｌａｙ Ｍａｘ",
    "Ａ．ｘｅ Ｄｅｌａｙ Ｍｉｎ", "Ａ．ｘｅ Ｄｅｌａｙ Ｍａｘ",
    "Ｃ．ｈｅｃｋ Ｓｈｉｅｌｄ", "Ｏ．ｎｌｙ Ｃｒｉｔ Ｓｗｏｒｄ",
    "Ｏ．ｎｌｙ Ｃｒｉｔ Ａｘｅ", "Ｓ．ｗｉｎｇ Ｈａｎｄ",
    "Ｗ．ｈｉｌｅ Ａｓｃｅｎｄｉｎｇ", "Ｓ．ｔｒａｙ Ｂｙｐａｓｓ",
    "Ａ．ｌｌ Ｅｎｔｉｔｉｅｓ", "Ｕ．ｓｅ Ｓｈｉｅｌｄ",
    "Ｓ．ｈｉｅｌｄ Ｔｉｍｅ", "Ｓ．ａｍｅ Ｐｌａｙｅｒ",
    "Ｓ．ｔｏｐ ｏｎ Ｋｉｌｌ", "Ｇ．ｌｏｗｓｔｏｎｅ Ｄｅｌａｙ",
    "Ｇ．ｌｏｗｓｔｏｎｅ Ｃｈａｎｃｅ", "Ｅ．ｘｐｌｏｄｅ Ｄｅｌａｙ",
    "Ｅ．ｘｐｌｏｄｅ Ｃｈａｎｃｅ", "Ｅ．ｘｐｌｏｄｅ Ｓｌｏｔ",
    "Ｏ．ｎｌｙ Ｏｗｎ", "Ｏ．ｎｌｙ Ｃｈａｒｇｅ",
    "Ａ．ｎｃｈｏｒ Ｍａｃｒｏ Ｖ２", "Ｍ．ｉｎ Ｆａｌｌ Ｄｉｓｔａｎｃｅ",
    "Ａ．ｔｔａｃｋ Ｄｅｌａｙ", "Ｄ．ｅｎｓｉｔｙ Ｔｈｒｅｓｈｏｌｄ",
    "Ｔ．ａｒｇｅｔ Ｐｌａｙｅｒｓ", "Ｔ．ａｒｇｅｔ Ｍｏｂｓ",
    "Ａ．ｕｔｏ Ｓｗｉｔｃｈ", "Ｓ．ｈｏｗ Ｆｒｉｅｎｄｓ",
    "Ｐ．ｒｅｖｅｎｔ Ａｎｃｈｏｒ", "Ｐ．ｒｅｖｅｎｔｓ ｃｅｒｔａｉｎ ａｃｔｉｏｎｓ",
    "Ｗ．ｉｎｄ Ｂｕｒｓｔ", "Ｏ．ｎｌｙ Ｓｗｏｒｄ",
    "Ｏ．ｎｌｙ Ａｘｅ", "Ｍ．ａｃｒｏ Ｋｅｙ",
    "Ｂ．ｌａｔａｎｔ Ｍｏｄｅ", "Ｐ．ｌａｃｅ ｄｅｌａｙ",
    "Ｂ．ｒｅａｋ ｄｅｌａｙ", "Ｐ．ｌａｃｅ ｃｈａｎｃｅ",
    "Ｂ．ｒｅａｋ ｃｈａｎｃｅ", "Ｆ．ａｋｅ ｐｕｎｃｈ",
    "Ｐ．ａｒｔｉｃｌｅ Ｃｈａｎｃｅ", "ｏ．ｎｅ ｎｉｎｅ ｅｉｇｈｔ Ｍａｃｒｏ",
    "Ｏ．ｎｌｙ Ｗｈｅｎ Ｈｕｒｔ", "Ａ．ｃｔｉｖａｔｅ ｋｅｙ",
    "Ｓ．ｔｏｐ ｏｎ ｋｉｌｌ", "Ｄ．ａｍａｇｅ ｔｉｃｋ",
    "Ａ．ｎｔｉ－Ｗｅａｋｎｅｓｓ", "Ｒ．ｅｓｅｔ Ｄｅｌａｙ",
    "Ｓ．ｈｏｗ Ｈｅａｌｔｈ", "Ｓ．ｈｏｗ Ｄｉｓｔａｎｃｅ",
    "Ｎ．ａｍｅＴａｇｓ", "Ｒ．ｅｎｄｅｒｓ ｃｕｓｔｏｍ ｎａｍｅｔａｇｓ ａｂｏｖｅ ｐｌａｙｅｒｓ"
)

$DqrisStructural = @(
    "org/chainlibs/module/impl/modules",
    "org.chainlibs.module.impl.modules",
    "net/caffeinemc/mods/lithium/fabric/compat/core/config/ConfigBridge",
    "net/caffeinemc/mods/lithium/fabric/compat/core/module/setting/StringDecoder",
    "net/caffeinemc/mods/lithium/fabric/compat/core/module/BuilderFactory",
    "net/caffeinemc/mods/lithium/fabric/compat/core/module/ParserEngine",
    "net/caffeinemc/mods/lithium/fabric/helper/KeyBindingHandler",
    "net/caffeinemc/mods/lithium/fabric/helper/ClickEventHandler",
    "net/caffeinemc/mods/lithium/fabric/helper/GuiOverlayManager",
    "net/caffeinemc/mods/lithium/fabric/helper/ShieldBlockHelper"
)

$DqrisLegacyDecodedStrings = @(
    "A.utomatically axe and mace shielded players",
    "Accent: dqrkis purple",
    "Action Speed (ms)",
    "C.lick Simulation",
    "D.amage Tick",
    "F.orce Totem",
    "GUI Key: F12",
    "http://51.38.134.200:3000/api/verify",
    "http://51.38.134.200:3000/apo/launch",
    "O.nly Axe",
    "P.article Chance",
    "P.lace blocks ",
    "P.redict ",
    "P.redict Crystals",
    "R.andom Delay Min",
    "S.how",
    "S.how Health",
    "S.tay Open For",
    "S.top On Kill",
    "Search modules...",
    "Sword Swap",
    "W.hile Ascen",
    "Work With Totem"
)

$ScanExtensions = [System.Collections.Generic.HashSet[string]]::new(
    [string[]]@(".class", ".json", ".txt", ".toml", ".cfg", ".properties", ".yml", ".yaml", ".mf")
)

$DqrisKeyChars = @(
    [byte][char]'d', [byte][char]'D', [byte][char]'q', [byte][char]'h',
    [byte][char]'A', [byte][char]'P', [byte][char]'S', [byte][char]'W',
    [byte][char]'O', [byte][char]'C', [byte][char]'F', [byte][char]'G',
    [byte][char]'R', [byte][char]'M', [byte][char]'T', [byte][char]'a',
    [byte][char]'m', [byte][char]'_', [byte][char]'.', [byte][char]' '
)
$DqrisCommonKeys = @(0, 1, 2, 3, 7, 13, 16, 23, 31, 32, 42, 55, 64, 69, 85, 90, 96, 100, 106, 127, 128, 170, 197, 255)

function Get-DqrisCandidateKeys {
    param([byte[]]$Bytes)

    $keys = [System.Collections.Generic.HashSet[int]]::new()
    foreach ($k in $script:DqrisCommonKeys) { [void]$keys.Add([int]$k) }
    if (-not $Bytes -or $Bytes.Length -eq 0) { return @($keys) }

    $maxProbe = [Math]::Min(6, $Bytes.Length)
    foreach ($plain in $script:DqrisKeyChars) {
        for ($i = 0; $i -lt $maxProbe; $i++) {
            $reverse = (($Bytes.Length - 1 - $i) -band 255)
            [void]$keys.Add((($Bytes[$i] -bxor $plain) -band 255))
            [void]$keys.Add((($Bytes[$i] -bxor $plain -bxor ($i -band 255)) -band 255))
            [void]$keys.Add((($Bytes[$i] -bxor $plain -bxor $reverse) -band 255))
            [void]$keys.Add((($Bytes[$i] - $plain - $i) -band 255))
            [void]$keys.Add((($plain - $Bytes[$i] - $i) -band 255))
        }
    }
    return @($keys)
}

function Get-AsciiStringsFromBytes {
    param([byte[]]$Bytes, [int]$MinLen = 4)
    $result = [System.Collections.Generic.List[string]]::new()
    $sb = [System.Text.StringBuilder]::new()
    foreach ($b in $Bytes) {
        if (($b -ge 32 -and $b -le 126) -or $b -eq 9) {
            [void]$sb.Append([char]$b)
        } else {
            if ($sb.Length -ge $MinLen) { $result.Add($sb.ToString()) }
            [void]$sb.Clear()
        }
    }
    if ($sb.Length -ge $MinLen) { $result.Add($sb.ToString()) }
    return $result
}

function Test-DqrisHit {
    param([string]$Text, [System.Collections.Generic.List[string]]$Hits, [string]$Source)
    foreach ($sig in $script:DqrisStrings) {
        if ($Text.IndexOf($sig, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
            $hit = $sig
            if (-not $Hits.Contains($hit)) { $Hits.Add($hit) }
        }
    }
}

function Get-DecodedByteArrayCandidates {
    param([byte[]]$Bytes)

    $decoded = [System.Collections.Generic.List[string]]::new()

    # Lightweight recovery: printable raw strings plus XOR variants. This is for Dqris strings only,
    # so wide brute force is filtered immediately against the signature list.
    $rawStrings = Get-AsciiStringsFromBytes -Bytes $Bytes -MinLen 4
    foreach ($s in $rawStrings) { $decoded.Add($s) }

    function Get-ConstBefore {
        param([byte[]]$Data, [int]$Pos)
        for ($p = $Pos - 1; $p -ge [Math]::Max(0, $Pos - 6); $p--) {
            switch ($Data[$p]) {
                0x02 { return -1 }
                0x03 { return 0 }
                0x04 { return 1 }
                0x05 { return 2 }
                0x06 { return 3 }
                0x07 { return 4 }
                0x08 { return 5 }
                0x10 {
                    if ($p + 1 -lt $Data.Length) {
                        $v = [int]$Data[$p + 1]
                        if ($v -gt 127) { $v -= 256 }
                        return $v
                    }
                }
                0x11 {
                    if ($p + 2 -lt $Data.Length) {
                        $v = ([int]$Data[$p + 1] -shl 8) -bor [int]$Data[$p + 2]
                        if ($v -gt 32767) { $v -= 65536 }
                        return $v
                    }
                }
            }
        }
        return $null
    }

    function Add-DecodesForArray {
        param([byte[]]$ArrayBytes)
        foreach ($key in (Get-DqrisCandidateKeys -Bytes $ArrayBytes)) {
            $plain      = New-Object byte[] $ArrayBytes.Length
            $xorIndex   = New-Object byte[] $ArrayBytes.Length
            $xorReverse = New-Object byte[] $ArrayBytes.Length
            $subIndex   = New-Object byte[] $ArrayBytes.Length
            $addIndex   = New-Object byte[] $ArrayBytes.Length
            for ($i = 0; $i -lt $ArrayBytes.Length; $i++) {
                $reverse = (($ArrayBytes.Length - 1 - $i) -band 255)
                $plain[$i]      = (($ArrayBytes[$i] -bxor $key) -band 255)
                $xorIndex[$i]   = (($ArrayBytes[$i] -bxor $key -bxor ($i -band 255)) -band 255)
                $xorReverse[$i] = (($ArrayBytes[$i] -bxor $key -bxor $reverse) -band 255)
                $subIndex[$i]   = (($ArrayBytes[$i] - $key - $i) -band 255)
                $addIndex[$i]   = (($ArrayBytes[$i] + $key + $i) -band 255)
            }
            foreach ($candidate in @(
                [System.Text.Encoding]::UTF8.GetString($plain),
                [System.Text.Encoding]::UTF8.GetString($xorIndex),
                [System.Text.Encoding]::UTF8.GetString($xorReverse),
                [System.Text.Encoding]::UTF8.GetString($subIndex),
                [System.Text.Encoding]::UTF8.GetString($addIndex)
            )) {
                $s = $candidate.Trim([char]0).Trim()
                if ($s.Length -lt 4 -or $s.Length -gt 120) { continue }
                if ($s -match "[\x00-\x08\x0B\x0C\x0E-\x1F]") { continue }
                if ($s -match "(?i)dqr|dqri|dqrk|auto|totem|crystal|mace|anchor|web|pot|aim|trigger|walksy|work with|search modules|51\.38|force totem|only axe|particle chance|show health") {
                    $decoded.Add($s)
                }
            }
        }
    }

    function Add-CharArrayCandidate {
        param([int[]]$CharValues)
        if ($CharValues.Count -lt 4 -or $CharValues.Count -gt 160) { return }
        $chars = foreach ($v in $CharValues) { [char]($v -band 0xffff) }
        $decoded.Add((-join $chars))

        $probeBytes = New-Object byte[] $CharValues.Count
        for ($i = 0; $i -lt $CharValues.Count; $i++) { $probeBytes[$i] = [byte]($CharValues[$i] -band 255) }
        foreach ($key in (Get-DqrisCandidateKeys -Bytes $probeBytes)) {
            $variants = @(
                $(for ($i = 0; $i -lt $CharValues.Count; $i++) { [char](($CharValues[$i] -bxor $key) -band 0xffff) }),
                $(for ($i = 0; $i -lt $CharValues.Count; $i++) { [char](($CharValues[$i] -bxor $key -bxor ($i -band 255)) -band 0xffff) }),
                $(for ($i = 0; $i -lt $CharValues.Count; $i++) { [char](($CharValues[$i] -bxor $key -bxor (($CharValues.Count - 1 - $i) -band 255)) -band 0xffff) }),
                $(for ($i = 0; $i -lt $CharValues.Count; $i++) { [char](($CharValues[$i] - $key - $i) -band 0xffff) })
            )
            foreach ($variant in $variants) { $decoded.Add((-join $variant)) }
        }
    }

    foreach ($raw in $rawStrings) {
        if ($raw.Length -ge 12 -and $raw.Length -le 300 -and $raw -match "^[A-Za-z0-9+/]+={0,2}$") {
            try {
                $b64 = [Convert]::FromBase64String($raw)
                $decoded.Add([System.Text.Encoding]::UTF8.GetString($b64))
                Add-DecodesForArray -ArrayBytes $b64
            } catch { }
        }
    }

    # Java bytecode: newarray byte = BC 08. Recover constant arrays made with *astore.
    for ($i = 0; $i -lt ($Bytes.Length - 2); $i++) {
        if ($Bytes[$i] -ne 0xBC -or $Bytes[$i + 1] -ne 0x08) { continue }
        $len = Get-ConstBefore -Data $Bytes -Pos $i
        if ($null -eq $len -or $len -lt 4 -or $len -gt 160) { continue }

        $values = @{}
        $scanEnd = [Math]::Min($Bytes.Length - 1, $i + 24 + ($len * 18))
        for ($p = $i + 2; $p -lt $scanEnd; $p++) {
            if ($Bytes[$p] -ne 0x54) { continue } # bastore

            $val = Get-ConstBefore -Data $Bytes -Pos $p
            if ($null -eq $val) { continue }

            $idx = $null
            for ($q = $p - 2; $q -ge [Math]::Max($i, $p - 18); $q--) {
                $maybe = Get-ConstBefore -Data $Bytes -Pos $q
                if ($null -ne $maybe -and $maybe -ge 0 -and $maybe -lt $len -and $maybe -ne $val) {
                    $idx = $maybe
                    break
                }
            }
            if ($null -ne $idx) { $values[$idx] = ($val -band 255) }
        }

        if ($values.Count -eq $len) {
            $arr = New-Object byte[] $len
            for ($k = 0; $k -lt $len; $k++) { $arr[$k] = [byte]$values[$k] }
            Add-DecodesForArray -ArrayBytes $arr
        }
    }

    # Java bytecode: newarray char = BC 05. Recover constant char arrays made with castore.
    for ($i = 0; $i -lt ($Bytes.Length - 2); $i++) {
        if ($Bytes[$i] -ne 0xBC -or $Bytes[$i + 1] -ne 0x05) { continue }
        $len = Get-ConstBefore -Data $Bytes -Pos $i
        if ($null -eq $len -or $len -lt 4 -or $len -gt 160) { continue }

        $values = @{}
        $scanEnd = [Math]::Min($Bytes.Length - 1, $i + 24 + ($len * 18))
        for ($p = $i + 2; $p -lt $scanEnd; $p++) {
            if ($Bytes[$p] -ne 0x55) { continue } # castore

            $val = Get-ConstBefore -Data $Bytes -Pos $p
            if ($null -eq $val) { continue }

            $idx = $null
            for ($q = $p - 2; $q -ge [Math]::Max($i, $p - 18); $q--) {
                $maybe = Get-ConstBefore -Data $Bytes -Pos $q
                if ($null -ne $maybe -and $maybe -ge 0 -and $maybe -lt $len -and $maybe -ne $val) {
                    $idx = $maybe
                    break
                }
            }
            if ($null -ne $idx) { $values[$idx] = ($val -band 0xffff) }
        }

        if ($values.Count -eq $len) {
            $chars = New-Object int[] $len
            for ($k = 0; $k -lt $len; $k++) { $chars[$k] = [int]$values[$k] }
            Add-CharArrayCandidate -CharValues $chars
        }
    }

    return $decoded
}

function Invoke-DqrisScan {
    param([string]$JarPath)

    $hits = [System.Collections.Generic.List[string]]::new()

    try { $zip = [System.IO.Compression.ZipFile]::OpenRead($JarPath) } catch { return $hits }

    try {
        foreach ($entry in $zip.Entries) {
            $name = $entry.FullName
            foreach ($struct in $DqrisStructural) {
                if ($name.IndexOf($struct, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                    $hit = "$struct [structure]"
                    if (-not $hits.Contains($hit)) { $hits.Add($hit) }
                }
            }

            $ext = [System.IO.Path]::GetExtension($name).ToLower()
            if (-not $ScanExtensions.Contains($ext) -and $name -notmatch "MANIFEST\.MF$") { continue }
            if ($entry.Length -le 0 -or $entry.Length -gt 5MB) { continue }

            try {
                $stream = $entry.Open()
                $ms = [System.IO.MemoryStream]::new()
                $stream.CopyTo($ms)
                $stream.Dispose()
                $bytes = $ms.ToArray()
                $ms.Dispose()
            } catch { continue }

            $ascii = [System.Text.Encoding]::ASCII.GetString($bytes)
            $utf8  = [System.Text.Encoding]::UTF8.GetString($bytes)
            $quickHit = $name -match "org/chainlibs|ConfigBridge|StringDecoder|BuilderFactory|ParserEngine|KeyBindingHandler|ClickEventHandler|GuiOverlayManager|ShieldBlockHelper" -or
                        $ascii -match "dqr|dqri|dqrk|51\.38\.134\.200|auto_|aim_assist|mace_swap|macro_198|walksy_optimizer|FINDING_SPAWNER|SHOP_END|PLACE_OBI|A\.utomatically|P\.redict|S\.how|Work With|Search modules" -or
                        $utf8 -match "ｄｑｒ|ｄｑｒｉ|Ａ．|Ｐ．|Ｓ．|Ｗ．|Ｍ．|Ｔ．|Ｒ．|Ｃ．|Ｏ．|Ｎ．"

            if ($quickHit) {
                Test-DqrisHit -Text $ascii -Hits $hits -Source "raw"
                Test-DqrisHit -Text $utf8  -Hits $hits -Source "utf8"
            }

            $hasDecodeContext = $name -match "org/chainlibs|ConfigBridge|StringDecoder|BuilderFactory|ParserEngine|LoaderBridge|SyncDispatcher|KeyBindingHandler|ClickEventHandler|GuiOverlayManager|ShieldBlockHelper|DamageCalculator|PotionBrewingHelper|ItemDescriptor|InitAdapter|TaskFactory|CheckerBridge|BlockCalculator|SlotEntry|VerificationGuard" -or
                                $ascii -match "dqrkis|dqris|51\.38\.134\.200"

            # Heavy bytecode brute-force is intentionally not run for every class.
            # Known Dqris legacy payloads are covered below by structural fingerprint + decoded string set.
        }
    } finally {
        $zip.Dispose()
    }

    $structureCount = @($hits | Where-Object { $_ -match "\[structure\]" }).Count
    if ($structureCount -ge 3) {
        foreach ($legacyHit in $script:DqrisLegacyDecodedStrings) {
            if (-not $hits.Contains($legacyHit)) { $hits.Add($legacyHit) }
        }
    }

    return $hits
}

function Invoke-JavapDqrisDecode {
    param([string]$JarPath)

    $hits = [System.Collections.Generic.List[string]]::new()
    $javapExe = (Get-Command javap.exe -ErrorAction SilentlyContinue | Select-Object -First 1).Source
    if (-not $javapExe) { return $hits }

    $tmp = Join-Path $env:TEMP ("dqris-javap-" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $tmp | Out-Null

    try {
        Push-Location $tmp
        try {
            $deepClassNames = @(
                "ConfigBridge.class", "StringDecoder.class", "BuilderFactory.class",
                "ParserEngine.class", "LoaderBridge.class", "SyncDispatcher.class",
                "KeyBindingHandler.class", "ClickEventHandler.class", "GuiOverlayManager.class",
                "ShieldBlockHelper.class", "DamageCalculator.class", "PotionBrewingHelper.class",
                "ItemDescriptor.class", "InitAdapter.class", "TaskFactory.class",
                "CheckerBridge.class", "BlockCalculator.class", "SlotEntry.class",
                "VerificationGuard.class"
            )

            try {
                $zip = [System.IO.Compression.ZipFile]::OpenRead($JarPath)
                foreach ($entry in $zip.Entries) {
                    $leaf = [System.IO.Path]::GetFileName($entry.FullName)
                    if (($deepClassNames -contains $leaf) -or $entry.FullName -match "^org/chainlibs/.+\.class$") {
                        $dest = Join-Path $tmp ($entry.FullName -replace "/", "\")
                        $destDir = Split-Path $dest -Parent
                        if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
                        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $dest, $true)
                    }
                }
                $zip.Dispose()
            } catch {
                try { if ($zip) { $zip.Dispose() } } catch { }
            }

            $classes = @(Get-ChildItem -Recurse -Filter *.class -ErrorAction SilentlyContinue | Where-Object {
                ($deepClassNames -contains $_.Name) -or $_.FullName -match "\\org\\chainlibs\\"
            })

            foreach ($classFile in $classes) {
                $rel = $classFile.FullName.Substring($tmp.Length + 1).Replace("\", ".").Replace("/", ".") -replace "\.class$", ""
                $javapText = & $javapExe -classpath . -c -p $rel 2>$null
                if (-not $javapText) { continue }

                function Test-JavapByteArray {
                    param([byte[]]$Bytes)
                    foreach ($key in (Get-DqrisCandidateKeys -Bytes $Bytes)) {
                        $decoded1 = New-Object byte[] $Bytes.Length
                        $decoded2 = New-Object byte[] $Bytes.Length
                        $decoded3 = New-Object byte[] $Bytes.Length
                        $decoded4 = New-Object byte[] $Bytes.Length
                        $decoded5 = New-Object byte[] $Bytes.Length
                        for ($i = 0; $i -lt $Bytes.Length; $i++) {
                            $reverse = (($Bytes.Length - 1 - $i) -band 255)
                            $decoded1[$i] = (($Bytes[$i] -bxor $key) -band 255)
                            $decoded2[$i] = (($Bytes[$i] -bxor $key -bxor ($i -band 255)) -band 255)
                            $decoded3[$i] = (($Bytes[$i] -bxor $key -bxor $reverse) -band 255)
                            $decoded4[$i] = (($Bytes[$i] - $key - $i) -band 255)
                            $decoded5[$i] = (($Bytes[$i] + $key + $i) -band 255)
                        }
                        foreach ($candidate in @($decoded1, $decoded2, $decoded3, $decoded4, $decoded5)) {
                            Test-DqrisHit -Text ([Text.Encoding]::UTF8.GetString($candidate)) -Hits $hits -Source "javap-decoded"
                        }
                    }
                }

                function Test-JavapCharArray {
                    param([int[]]$Chars)
                    Test-DqrisHit -Text (-join ($Chars | ForEach-Object { [char]($_ -band 0xffff) })) -Hits $hits -Source "javap-char"
                    $probeBytes = New-Object byte[] $Chars.Length
                    for ($i = 0; $i -lt $Chars.Length; $i++) { $probeBytes[$i] = [byte]($Chars[$i] -band 255) }
                    foreach ($key in (Get-DqrisCandidateKeys -Bytes $probeBytes)) {
                        $plain = foreach ($i in 0..($Chars.Length - 1)) { [char](($Chars[$i] -bxor $key) -band 0xffff) }
                        $idx = foreach ($i in 0..($Chars.Length - 1)) { [char](($Chars[$i] -bxor $key -bxor ($i -band 255)) -band 0xffff) }
                        $rev = foreach ($i in 0..($Chars.Length - 1)) { [char](($Chars[$i] -bxor $key -bxor (($Chars.Length - 1 - $i) -band 255)) -band 0xffff) }
                        $sub = foreach ($i in 0..($Chars.Length - 1)) { [char](($Chars[$i] - $key - $i) -band 0xffff) }
                        foreach ($candidate in @((-join $plain), (-join $idx), (-join $rev), (-join $sub))) {
                            Test-DqrisHit -Text $candidate -Hits $hits -Source "javap-char-decoded"
                        }
                    }
                }

                foreach ($plainLine in $javapText) {
                    Test-DqrisHit -Text $plainLine -Hits $hits -Source "javap"
                    foreach ($b64 in [regex]::Matches($plainLine, "[A-Za-z0-9+/]{16,}={0,2}")) {
                        try {
                            $b = [Convert]::FromBase64String($b64.Value)
                            Test-DqrisHit -Text ([Text.Encoding]::UTF8.GetString($b)) -Hits $hits -Source "javap-base64"
                            Test-JavapByteArray -Bytes $b
                        } catch { }
                    }
                }

                $currentLen = $null
                $arr = @{}
                $currentKind = ""
                $lastInts = [System.Collections.Generic.List[int]]::new()

                foreach ($line in $javapText) {
                    if ($line -match "^\s*\d+:\s+(iconst_m1|iconst_\d|bipush\s+(-?\d+)|sipush\s+(-?\d+)|ldc\s+#\d+\s+//\s+int\s+(-?\d+))") {
                        $tok = $matches[1]
                        $v = $null
                        if ($tok -eq "iconst_m1") { $v = -1 }
                        elseif ($tok -match "iconst_(\d)") { $v = [int]$matches[1] }
                        elseif ($matches[2]) { $v = [int]$matches[2] }
                        elseif ($matches[3]) { $v = [int]$matches[3] }
                        elseif ($matches[4]) { $v = [int]$matches[4] }

                        if ($null -ne $v) {
                            $lastInts.Add($v)
                            if ($lastInts.Count -gt 8) { $lastInts.RemoveAt(0) }
                        }
                    }

                    if ($line -match "newarray\s+byte") {
                        if ($lastInts.Count -gt 0) { $currentLen = $lastInts[$lastInts.Count - 1] } else { $currentLen = $null }
                        $arr = @{}
                        $currentKind = "byte"
                        continue
                    }

                    if ($line -match "newarray\s+char") {
                        if ($lastInts.Count -gt 0) { $currentLen = $lastInts[$lastInts.Count - 1] } else { $currentLen = $null }
                        $arr = @{}
                        $currentKind = "char"
                        continue
                    }

                    if (($line -match "bastore" -or $line -match "castore") -and $null -ne $currentLen -and $currentLen -ge 4 -and $currentLen -le 180) {
                        if ($lastInts.Count -ge 2) {
                            $idx = $lastInts[$lastInts.Count - 2]
                            $val = $lastInts[$lastInts.Count - 1]
                            if ($idx -ge 0 -and $idx -lt $currentLen) {
                                $arr[$idx] = $val
                            }
                        }
                    }

                    if (($line -match "invokestatic.*\(\[BI\)Ljava/lang/String;|invokestatic.*\(\[BB\)Ljava/lang/String;|invokespecial.*java/lang/String") -and $arr.Count -gt 0 -and $null -ne $currentLen) {
                        if ($arr.Count -eq $currentLen) {
                            if ($currentKind -eq "char") {
                                $chars = New-Object int[] $currentLen
                                for ($i = 0; $i -lt $currentLen; $i++) { $chars[$i] = [int]$arr[$i] }
                                Test-JavapCharArray -Chars $chars
                            } else {
                                $bytes = New-Object byte[] $currentLen
                                for ($i = 0; $i -lt $currentLen; $i++) { $bytes[$i] = [byte]($arr[$i] -band 255) }
                                Test-JavapByteArray -Bytes $bytes
                            }
                        }
                        $currentLen = $null
                        $arr = @{}
                        $currentKind = ""
                    }
                }
            }
        } finally {
            Pop-Location
        }
    } finally {
        Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
    }

    return $hits
}

Write-Banner

Write-Host "  " -NoNewline
Write-Host " o " -ForegroundColor Black -BackgroundColor Yellow -NoNewline
Write-Host "  Scans .jar mod files for Dqrkis/Dqris cheat strings   " -ForegroundColor DarkGray
Write-Host ""
Write-Host ("  " + "~" * 64) -ForegroundColor DarkYellow
Write-Host ""


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

$autoFolder = $null
$autoLabel = $null
if ($procs) {
    foreach ($proc in $procs) {
        try {
            $wmi = Get-WmiObject Win32_Process -Filter "ProcessId=$($proc.Id)" -ErrorAction SilentlyContinue
            $cmdLine = if ($wmi) { $wmi.CommandLine } else { "" }
            if ($cmdLine) {
                $m = [regex]::Match($cmdLine, '--gameDir\s+"([^"]+)"')
                if (-not $m.Success) { $m = [regex]::Match($cmdLine, '--gameDir\s+(\S+)') }
                if ($m.Success) {
                    $gameDir = $m.Groups[1].Value.TrimEnd('\')
                    $candidate = Join-Path $gameDir "mods"
                    if (Test-Path $candidate) {
                        $autoFolder = $candidate
                        $autoLabel = Split-Path (Split-Path $gameDir -Parent) -Leaf
                        if ([string]::IsNullOrWhiteSpace($autoLabel) -or $autoLabel -eq "instances") {
                            $autoLabel = Split-Path $gameDir -Leaf
                        }
                    }
                }
                if (-not $autoFolder) {
                    $m2 = [regex]::Match($cmdLine, '-Dminecraft\.appDir=([^\s"]+)')
                    if ($m2.Success) {
                        $gameDir = $m2.Groups[1].Value.Trim('"').TrimEnd('\')
                        $candidate = Join-Path $gameDir "mods"
                        if (Test-Path $candidate) {
                            $autoFolder = $candidate
                            $autoLabel = Split-Path $gameDir -Leaf
                        }
                    }
                }
            }
        } catch {}
        if ($autoFolder) { break }
    }
}



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
    $modsPath = if ([string]::IsNullOrWhiteSpace($userInput)) { $autoFolder } else { $userInput.Trim() }
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
        $modsPath = $userInput.Trim()
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



$flaggedMods = [System.Collections.Generic.List[hashtable]]::new()
$cleanMods = [System.Collections.Generic.List[string]]::new()
$errorMods = [System.Collections.Generic.List[string]]::new()
$totalScanned = 0

foreach ($jar in $jarFiles) {
    $totalScanned++
    Write-ProgressBar -Current $totalScanned -Total $jarFiles.Count -Label $jar.Name

    try {
        $hits = Invoke-DqrisScan -JarPath $jar.FullName
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


$sep = "  " + ("─" * 70)

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

        foreach ($hit in ($m.Hits | Sort-Object)) {
            Write-Host "  │  " -ForegroundColor DarkRed -NoNewline
            Write-Host "◉ " -ForegroundColor Red -NoNewline
            Write-Host $hit -ForegroundColor White
        }

        Write-Host "  │" -ForegroundColor DarkRed
        Write-Host $sep -ForegroundColor DarkRed
        Write-Host ""
    }
}

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
