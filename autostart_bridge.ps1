# Starts the Muse bridge in the background and restarts it if it stops.
# Launched hidden at logon by the "MuseBridge" shortcut in the Startup folder.
# Log: bridge.log next to this script (git-ignored via *.log).

$ErrorActionPreference = "Continue"
$dir = $PSScriptRoot
$python = Join-Path $dir ".venv\Scripts\python.exe"
$bridge = Join-Path $dir "muse_bridge.py"
$log = Join-Path $dir "bridge.log"
$port = 8765

function Write-Log($msg) {
    Add-Content -Path $log -Value ("[{0}] [autostart] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $msg) -Encoding utf8
}

# One bridge at a time: if something already listens on the port, leave it alone.
if (Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue) {
    Write-Log "port $port already in use; another bridge is running, exiting"
    exit 0
}

# Keep the log from growing forever.
if ((Test-Path $log) -and ((Get-Item $log).Length -gt 5MB)) {
    Move-Item $log "$log.old" -Force
}

$env:PYTHONIOENCODING = "utf-8"
$env:PYTHONUNBUFFERED = "1"
Set-Location $dir

while ($true) {
    Write-Log "starting bridge"
    # cmd handles the redirect: PowerShell 5.1 would wrap each stderr line in error records.
    cmd /c "`"$python`" `"$bridge`" serve >> `"$log`" 2>&1"
    Write-Log "bridge exited with code $LASTEXITCODE; restarting in 15s"
    Start-Sleep -Seconds 15
}
