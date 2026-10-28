@echo off
rem ============================================================
rem   MuseBridge - one-click setup
rem   Double-click this file. It installs everything MuseBridge
rem   needs into its own private folder. Nothing else on your PC
rem   is changed. You only need to run this once.
rem ============================================================
title MuseBridge setup
cd /d "%~dp0"

echo.
echo   Setting up MuseBridge...
echo.

rem 1) Find Python
where python >nul 2>nul
if errorlevel 1 (
  echo   [X] Python is not installed, or not on your PATH.
  echo       Install it from https://www.python.org/downloads/ and
  echo       TICK "Add python.exe to PATH" during install, then run this again.
  echo.
  pause
  exit /b 1
)

rem 2) Create a private virtual environment
if not exist ".venv\Scripts\python.exe" (
  echo   - Creating a private Python environment (.venv)...
  python -m venv .venv
)

rem 3) Install the one dependency + the browser it drives
echo   - Installing dependencies...
".venv\Scripts\python.exe" -m pip install --upgrade pip >nul
".venv\Scripts\python.exe" -m pip install -r requirements.txt
echo   - Downloading the browser MuseBridge drives (first time only)...
".venv\Scripts\python.exe" -m playwright install chromium

echo.
echo   [OK] Setup complete!
echo.
echo   Next steps:
echo     1) Double-click  login_to_muse.bat     and sign in to Muse.
echo     2) Double-click  start_muse_bridge_venv.bat  to start the bridge.
echo     3) Point OpenCode or ZadLoop at  http://127.0.0.1:8765
echo        (see the README for the exact settings).
echo.
pause
