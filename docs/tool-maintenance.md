# Tool Maintenance Guide

Procedures for maintaining CLI tools collection health, security, and consistency.

## Overview

Tool maintenance covers:
1. **Security** - No leaked secrets, proper .gitignore
2. **Tokens** - Valid structure, accessible credentials
3. **Data** - Clean repositories, no orphan files
4. **Consistency** - Standard structure across all tools

## Quick Health Check

```bash
# From wiki directory (tools as sibling)
./scripts/maintenance.sh ../tools

# From tools directory
../cli-tools-wiki/scripts/maintenance.sh .
```

## Maintenance Tasks

### Daily/As-Needed

| Task | Command | Description |
|------|---------|-------------|
| Security check | `./scripts/verify-security.sh` | Check for leaked secrets |
| Status check | `git submodule foreach 'git status -s'` | Uncommitted changes |

### Weekly

| Task | Command | Description |
|------|---------|-------------|
| Full maintenance | `./scripts/maintenance.sh` | All health checks |
| Update tools | `git submodule update --remote` | Pull latest |

### Monthly

| Task | Description |
|------|-------------|
| Inventory audit | Verify inventory.md matches actual tools |
| Token cleanup | Remove unused token folders |
| Dependency updates | Update pnpm packages in each tool |

## Security Verification

### What It Checks

1. **Hardcoded API Keys** - Patterns like `AIzaSy...`, `sk-...`, `ghp_...`
2. **Tracked Tokens** - Token files in git history
3. **Token Folder Structure** - Correct sibling placement
4. **.gitignore Coverage** - Essential patterns present
5. **Committed .env Files** - Should never be tracked
6. **Token References** - Tools using relative paths

### Running Security Check

```bash
# Verbose output
./scripts/verify-security.sh ./tools

# Expected output:
# ========================================
# CLI Tools Security Verification
# ========================================
# 1. Checking for hardcoded API keys...
# PASS: No hardcoded API keys detected
# 2. Checking tokens are not in submodule repos...
# PASS: No tokens tracked in submodule repos
# ...
```

### Fixing Security Issues

**Hardcoded API Key Found**:
```bash
cd {tool}
# Remove the key, use config.ts pattern instead
# See docs/adding-tools.md for config template
git add -u
git commit -m "Remove hardcoded credentials"
```

**Token File Tracked**:
```bash
cd {tool}
git rm --cached {token-file}
echo "{token-file}" >> .gitignore
git commit -m "Remove tracked token, update gitignore"
```

**Missing .gitignore**:
```bash
cd {tool}
# Copy standard .gitignore from docs/adding-tools.md
git add .gitignore
git commit -m "Add standard gitignore"
```

## Token Maintenance

### Verify Token Structure

```bash
# List token folders
ls -la tokens/

# Check for orphan folders (no matching tool)
for folder in tokens/*/; do
  tool=$(basename "$folder")
  [ ! -d "tools/$tool" ] && echo "Orphan: $folder"
done
```

### Token Expiration

Google tokens refresh automatically, but if auth fails:

```bash
cd {tool}
pnpm start auth {account}
```

### Cross-Machine Sync

See [token-setup.md](token-setup.md) for sync procedures.

## Data Cleanup

### Find Large Files

```bash
# In tools directory
find . -type f -size +1M -not -path "*/node_modules/*" 2>/dev/null
```

### Clean Node Modules

```bash
# Remove all node_modules for fresh install
find . -name "node_modules" -type d -prune -exec rm -rf {} +

# Reinstall
for tool in */; do
  (cd "$tool" && [ -f "package.json" ] && pnpm install)
done
```

### Remove Build Artifacts

```bash
# Clean dist folders
find . -name "dist" -type d -prune -exec rm -rf {} +
```

## Consistency Checks

### Verify Standard Structure

Each tool should have:
- `src/index.ts` - Entry point
- `src/config.ts` - Token configuration
- `package.json` - With standard scripts
- `tsconfig.json` - TypeScript config
- `.gitignore` - Blocking tokens/env
- `README.md` - Documentation

```bash
# Check for missing files
for tool in */; do
  [ ! -f "$tool/src/index.ts" ] && echo "$tool: missing src/index.ts"
  [ ! -f "$tool/src/config.ts" ] && echo "$tool: missing src/config.ts"
  [ ! -f "$tool/package.json" ] && echo "$tool: missing package.json"
  [ ! -f "$tool/.gitignore" ] && echo "$tool: missing .gitignore"
  [ ! -f "$tool/README.md" ] && echo "$tool: missing README.md"
done
```

### Verify Token Reference Pattern

Tools should reference tokens via relative path:

```bash
# Find tools with hardcoded token paths
grep -r "home/david" */src/*.ts 2>/dev/null && echo "WARN: Hardcoded paths found"

# Verify relative pattern used
grep -l "../tokens\|../../tokens" */src/config.ts
```

## Integration with Root Maintenance

This wiki's maintenance integrates with the root repository:

```markdown
# In root CLAUDE.md maintenance skill reference:

### CLI Tools Maintenance
When maintaining tools, run wiki maintenance:
→ See `cli-tools-wiki/docs/tool-maintenance.md`

Commands:
- Full check: `./cli-tools-wiki/scripts/maintenance.sh ./claude-code-cli-tools`
- Security only: `./cli-tools-wiki/scripts/verify-security.sh ./claude-code-cli-tools`
```

## Troubleshooting

### Tool Won't Run
```bash
# Check dependencies
cd {tool}
pnpm install

# Check TypeScript
pnpm typecheck
```

### Auth Failures
```bash
# Re-authenticate
pnpm start auth {account}

# Check credentials.json exists
ls -la ../tokens/credentials.json
```

### Submodule Issues
```bash
# Detached HEAD
cd {tool}
git checkout main

# Missing commits
git fetch origin
git reset --hard origin/main
```

## Maintenance Checklist

### Quick Check (5 min)
- [ ] `./scripts/verify-security.sh` passes
- [ ] `git submodule status` shows no + or - prefixes
- [ ] No uncommitted changes in tools

### Full Audit (30 min)
- [ ] All security checks pass
- [ ] Inventory matches actual tools
- [ ] All tools have standard structure
- [ ] No orphan token folders
- [ ] Dependencies up to date
- [ ] All READMEs accurate
