# CheesyDqrkisFucker

A PowerShell tool that scans Minecraft `.jar` mod files for known **dqrkis client** strings.

---

## What it does

- Finds all `.jar` files in a given mods folder
- Opens each jar and scans every file.
- Matches against a list of known dqrkis/cheat strings.
- Reports exactly which strings were found and in which mod

---

## How to run

Paste this into CMD prompt as admin and hit Enter:

```powershell
powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/cheesecatlol/DQRKIS-FUCKER/refs/heads/main/DqrkisFucker.ps1')"
```

Then enter the path to your mods folder when prompted, e.g.:

```
C:\Users\you\AppData\Roaming\.minecraft\mods
```

---

## Requirements

- Windows with PowerShell 5.1 or later
- Internet connection

---

## Credits

| | |
|---|---|
| **cheese cat** | Discord: `cheese_cat0` · GitHub: [cheesecatlol](https://github.com/cheesecatlol) |
| **nic** | Discord: `mecz.exe` · GitHub: [Nickk196](https://github.com/Nickk196) |
