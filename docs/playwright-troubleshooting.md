# Playwright MCP Troubleshooting

Common issues and solutions for Playwright MCP browser automation.

## Chrome Already in Use Error

### Symptoms
```
Error: browserType.launchPersistentContext: Failed to launch the browser process.
[pid=XXXXX][out] Opening in existing browser session.
[pid=XXXXX] <process did exit: exitCode=0, signal=null>
```

### Root Cause

Chrome's **SingletonLock mechanism** prevents multiple instances using the same profile. When Playwright MCP tries to launch Chrome with a profile that's already in use (or has stale lock files), Chrome:
1. Detects the existing SingletonLock file
2. Sends a message to the existing instance
3. Exits with code 0 instead of launching

**Key files involved:**
```
~/.cache/ms-playwright/mcp-chrome-{hash}/
├── SingletonLock    # Symlink to HOSTNAME-PID
├── SingletonSocket  # IPC socket
└── SingletonCookie  # Session identifier
```

### Solutions

#### Quick Fix (Immediate)
```bash
# Remove singleton files
rm -f ~/.cache/ms-playwright/mcp-chrome-*/SingletonLock
rm -f ~/.cache/ms-playwright/mcp-chrome-*/SingletonSocket
rm -f ~/.cache/ms-playwright/mcp-chrome-*/SingletonCookie

# Kill any orphaned Chrome MCP processes
pkill -f "chrome.*mcp-chrome"
```

#### Prevention

1. **Always close browsers explicitly**
   - Use `mcp__playwright__browser_close` at the end of Playwright sessions
   - Don't leave browser sessions hanging

2. **Cleanup script** (add to `~/.local/bin/cleanup-playwright-chrome.sh`):
```bash
#!/bin/bash
pkill -f "chrome.*mcp-chrome" 2>/dev/null
for dir in ~/.cache/ms-playwright/mcp-chrome*/; do
    rm -f "$dir/SingletonLock" "$dir/SingletonSocket" "$dir/SingletonCookie" 2>/dev/null
done
echo "Playwright Chrome cleanup complete"
```

3. **Nuclear option**: If all else fails, restart Claude Code to reset MCP state.

### WSL2 Note

This is NOT a WSL2-Windows interaction issue. The problem is purely about Chrome profile locking within WSL2. Windows Chrome (`/mnt/c/.../chrome.exe`) is not involved when using `/opt/google/chrome/chrome`.

---

## Browser Not Installed

### Symptoms
```
Error: Browser not installed
```

### Solution
```
mcp__playwright__browser_install
```

---

## Cloudflare Turnstile Bypass

For sites protected by Cloudflare (Upwork, etc.), Playwright MCP handles it automatically:

```typescript
mcp__playwright__browser_navigate({ url: "https://protected-site.com" })
mcp__playwright__browser_wait_for({ time: 2 })  // Let Turnstile complete
mcp__playwright__browser_snapshot()  // Get page data
```

See `../.claude/skills/playwright-mcp-cloudflare.md` for full documentation.

---

## References

- [GitHub Issue #891](https://github.com/microsoft/playwright-mcp/issues/891) - Browser lock error
- [GitHub Issue #1245](https://github.com/microsoft/playwright-mcp/issues/1245) - State not released after close
- [Playwright BrowserType API](https://playwright.dev/docs/api/class-browsertype)
