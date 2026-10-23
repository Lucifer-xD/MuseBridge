@echo off
rem Runs Claude Code against the local Muse bridge, for this window only.
rem Your global ~/.claude/settings.json and the Claude desktop app are untouched.
set "ANTHROPIC_BASE_URL=http://127.0.0.1:8765"
set "ANTHROPIC_API_KEY=muse-bridge-local"
set "ANTHROPIC_AUTH_TOKEN="
claude %*
