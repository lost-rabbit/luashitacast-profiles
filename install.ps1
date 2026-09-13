# Staves installer for HorizonXI (Ashita v4 + LuAshitaCast).
# Finds the game folder, asks for your character name and the jobs you want,
# puts the profile where LuAshitaCast looks for it, and makes sure the addon
# loads with the game. Safe to run again: it just refreshes the files.
#
#   powershell -ExecutionPolicy Bypass -File install.ps1
#   install.ps1 -Name Eveebevee -Jobs "WHM BLM RDM"     no questions asked
#   install.ps1 -Game "D:\HorizonXI\Game"                if it cannot find the game
#
# Creation assisted by ADA.

param(
    [string]$Name = '',
    [string]$Jobs = '',
    [string]$Game = ''
)
$ErrorActionPreference = 'Stop'
$repo = 'lost-rabbit/luashitacast-profiles'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Say($t) { Write-Host $t }
function Good($t) { Write-Host $t -ForegroundColor Green }
function Warn($t) { Write-Host $t -ForegroundColor Yellow }
function Fail($t) { Write-Host ''; Write-Host "  $t" -ForegroundColor Red; Write-Host ''; exit 1 }

Say ''
Say '  Staves: elemental staff on cast, Dark Staff while resting'
Say '  ---------------------------------------------------------'
Say ''

# ---- 1. the game folder ----
if ($Game -and (Test-Path (Join-Path $Game 'addons'))) {
    $game = $Game
} else {
    $candidates = @(
        (Join-Path $env:APPDATA 'HorizonXI-Launcher\HorizonXI\Game'),
        (Join-Path $env:LOCALAPPDATA 'HorizonXI-Launcher\HorizonXI\Game')
    )
    $game = $null
    foreach ($c in $candidates) { if (Test-Path (Join-Path $c 'addons')) { $game = $c; break } }
    if (-not $game) {
        Warn '  Could not find the HorizonXI Game folder on its own.'
        $typed = Read-Host '  Paste the full path to your HorizonXI "Game" folder (the one that holds "addons")'
        if ($typed -and (Test-Path (Join-Path $typed 'addons'))) { $game = $typed }
        else { Fail 'That folder has no "addons" inside it. Nothing installed.' }
    }
}
Say "  Game folder: $game"
if (-not (Test-Path (Join-Path $game 'addons\luashitacast'))) {
    Warn '  LuAshitaCast is not in your addons folder. Install it first (it ships with the HorizonXI launcher; check the launcher addon list), then run this again.'
}

# ---- 2. the profile file: next to this script if present, otherwise the latest from GitHub ----
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$src = Join-Path $here 'Staves.lua'
if (-not (Test-Path $src)) {
    $src = Join-Path $env:TEMP 'Staves.lua'
    Say '  Fetching the latest Staves.lua from GitHub'
    Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/$repo/main/Staves.lua" -OutFile $src
}
$firstLine = Get-Content $src -TotalCount 1
if ($firstLine -notmatch '^--\[\[') { Fail 'The downloaded Staves.lua does not look right. Try again in a minute.' }

# ---- 3. who and which jobs ----
while (-not ($Name -match '^[A-Za-z]{3,15}$')) {
    if ($Name) { Warn '  Letters only, 3 to 15 of them.' }
    $Name = (Read-Host '  Your character name, exactly as it shows in game').Trim()
}
$Name = $Name.Substring(0, 1).ToUpper() + $Name.Substring(1).ToLower()
$known = @('WHM', 'BLM', 'RDM', 'SMN', 'BRD', 'BLU', 'SCH', 'GEO', 'PLD', 'DRK', 'NIN', 'RUN', 'WAR', 'MNK', 'THF', 'BST', 'RNG', 'SAM', 'DRG', 'COR', 'PUP', 'DNC')
# PowerShell variable names ignore case, so the list gets its own name
$jobList = @()
$typedJobs = $Jobs
while ($jobList.Count -eq 0) {
    if (-not $typedJobs) { $typedJobs = Read-Host '  Jobs to put it on, separated by spaces (Enter for WHM BLM RDM SMN)' }
    if (-not $typedJobs.Trim()) { $typedJobs = 'WHM BLM RDM SMN' }
    $jobList = @($typedJobs.ToUpper() -split '[\s,]+' | Where-Object { $_ } | Select-Object -Unique)
    $bad = @($jobList | Where-Object { $known -notcontains $_ })
    if ($bad.Count) { Warn ("  Not a job: " + ($bad -join ', ') + ". Use three-letter codes like WHM BLM RDM."); $jobList = @(); $typedJobs = '' }
}

# ---- 4. where LuAshitaCast looks ----
# It checks config\addons\luashitacast\<Name>_<Id>\<JOB>.lua first, then the
# flat config\addons\luashitacast\<Name>_<JOB>.lua. If a per character folder
# exists (from /lac newlua) the files go there, so nothing older shadows them.
$lacCfg = Join-Path $game 'config\addons\luashitacast'
New-Item -ItemType Directory -Force -Path $lacCfg | Out-Null
$charDir = Get-ChildItem $lacCfg -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match ("^" + [regex]::Escape($Name) + "_\d+$") } | Select-Object -First 1
$installed = @()
foreach ($job in $jobList) {
    if ($charDir) {
        $dest = Join-Path $charDir.FullName "$job.lua"
    } else {
        $dest = Join-Path $lacCfg "${Name}_$job.lua"
    }
    if ((Test-Path $dest) -and ((Get-Content $dest -TotalCount 1) -notmatch '^--\[\[')) {
        Copy-Item $dest "$dest.bak" -Force
        Say "  Kept your old $(Split-Path $dest -Leaf) as $(Split-Path $dest -Leaf).bak"
    }
    Copy-Item $src $dest -Force
    $installed += $dest
}
foreach ($f in $installed) { Good "  Installed $f" }

# ---- 5. load with the game ----
$script = Join-Path $game 'scripts\default.txt'
if (Test-Path $script) {
    $lines = Get-Content $script
    if (-not ($lines | Where-Object { $_ -match '^\s*/addon\s+load\s+luashitacast\s*$' })) {
        Add-Content -Path $script -Value "`r`n/addon load luashitacast"
        Good '  Added "/addon load luashitacast" to scripts\default.txt, so it loads with the game.'
    } else {
        Say '  LuAshitaCast already loads with the game.'
    }
} else {
    Warn '  No scripts\default.txt found. Type /addon load luashitacast in game.'
}

Say ''
Good '  Done. In game type:  /lac load'
Say '  Or change jobs. The staff swaps start with your next cast.'
Say '  To change your everyday weapon, open the installed file and set IDLE_MAIN near the top.'
Say ''
exit 0
