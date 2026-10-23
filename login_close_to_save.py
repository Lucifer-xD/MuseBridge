#!/usr/bin/env python3
"""
Same as `muse_bridge.py login`, minus the "press ENTER" step:
log in, open your chat, then just close the browser window to save.
"""
import json
import sys
import time

from playwright.sync_api import sync_playwright

import muse_bridge as mb

EXAMPLE_SELECTORS = {
    "composer": "textarea[placeholder='Message'], textarea",
    "send_button": "button[aria-label='Send'], button[aria-label*='Send' i]",
    "message_list": "main, [role='log'], div[class*='chat' i]",
    "message": ".hatch-chat-groupable-bubble",
}


def main() -> None:
    cfg = mb.load_config()
    target_url = cfg.get("chat_url") or "https://muse.ai"

    print("=" * 60)
    print("MUSE LOGIN  (no ENTER needed)")
    print("=" * 60)
    print("1. Log in to your Muse account in the browser window.")
    print("2. Open the chat you want to use with Claude Code.")
    print("3. CLOSE THE BROWSER WINDOW. That saves everything.")
    print("-" * 60, flush=True)

    with sync_playwright() as p:
        browser, ctx = mb._launch_browser_and_context(p, cfg, headless=False, with_storage=False)
        page = ctx.new_page()
        page.goto(target_url)

        last_url = page.url
        last_state = None
        selectors = {}
        checked_url = None

        # Snapshot while the window is open; the last snapshot wins once it closes.
        while ctx.pages:
            try:
                cur = ctx.pages[-1]
                last_url = cur.url or last_url
                last_state = ctx.storage_state()
                if last_url != checked_url:
                    checked_url = last_url
                    found = mb.detect_selectors(cur)
                    if found.get("composer"):
                        selectors = found
            except Exception:
                pass
            time.sleep(2)

        try:
            last_state = ctx.storage_state()
        except Exception:
            pass
        try:
            browser.close()
        except Exception:
            pass

    if not last_state or not last_state.get("cookies"):
        sys.exit("\n[!] No login cookies captured. Run this again and log in before closing the window.")

    mb.STATE_FILE.write_text(json.dumps(last_state), encoding="utf-8")
    cfg["chat_url"] = last_url
    # Auto-detection guessed wrong on the Muse home screen ("article"); keep the known-good selectors.
    cfg["selectors"] = dict(EXAMPLE_SELECTORS)
    mb.save_config(cfg)

    print(f"\n[OK] Login saved to {mb.STATE_FILE.name}")
    print(f"[OK] Chat URL: {last_url}")
    print(f"[OK] Config written to {mb.CONFIG_FILE.name}")
    print("You can close this tab now.")


if __name__ == "__main__":
    main()
