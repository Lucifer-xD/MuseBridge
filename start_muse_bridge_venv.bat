@echo off
title Muse AI Bridge Daemon
rem Same as start_muse_bridge.bat, but uses the project's .venv (which has Playwright installed).
"%~dp0.venv\Scripts\python.exe" "%~dp0muse_bridge.py" serve %*
pause
