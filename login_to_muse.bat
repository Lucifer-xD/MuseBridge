@echo off
rem Opens a browser window to sign in to Muse. Log in, open the chat you
rem want, then just CLOSE the window - your login is saved automatically.
title Muse login
cd /d "%~dp0"
".venv\Scripts\python.exe" "login_close_to_save.py"
