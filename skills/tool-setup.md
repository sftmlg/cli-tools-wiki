# Tool Setup Skill

**Purpose**: Activate when creating, maintaining, or managing CLI tools.

## Activation Triggers

- Keywords: "create tool", "new tool", "add tool", "tool setup", "setup tool"
- Keywords: "maintain tools", "clean tools", "tool maintenance"
- Keywords: "convert to repo", "make repo", "git init tool"
- File patterns: Working in `*-manager/`, `*-tool/`, `*-generator/`

## Pre-Action Checklist

**BEFORE creating a new tool:**

1. **Check inventory first**: Search `tools/inventory.md` for existing tool
2. **Check GitHub**: `gh repo view sftmlg/{potential-name}`
3. **Only create if no match** - prefer cloning existing over creating new

## Procedures

### Creating New Tool

1. Load: `cli-tools-wiki/docs/adding-tools.md`
2. Or run: `./cli-tools-wiki/scripts/tool-wizard.sh create`
3. Follow templates for:
   - .gitignore (required)
   - tsconfig.json
   - package.json
   - src/config.ts (token reference)
   - src/index.ts
   - README.md

### Cloning Existing Tools

1. Run wizard: `./cli-tools-wiki/scripts/tool-wizard.sh clone`
2. Or manual: `gh repo clone sftmlg/{tool-name} tools/{tool-name}`
3. Create token folder: `mkdir -p tokens/{tool-name}`

### Converting Local Code to Repo

1. Load: `cli-tools-wiki/docs/convert-to-repo.md`
2. Verify no secrets: `grep -rE 'AIzaSy|sk-|ghp_' .`
3. Add required files (.gitignore, README)
4. Create repo: `gh repo create sftmlg/{name} --source . --push`

### Running Maintenance

1. Full check: `./cli-tools-wiki/scripts/maintenance.sh ./tools`
2. Security only: `./cli-tools-wiki/scripts/verify-security.sh ./tools`
3. Quick check: `./cli-tools-wiki/scripts/maintenance.sh ./tools --quick`

## Required Files for Every Tool

| File | Purpose | Template |
|------|---------|----------|
| `.gitignore` | Block secrets | adding-tools.md |
| `tsconfig.json` | TypeScript config | adding-tools.md |
| `package.json` | Dependencies | adding-tools.md |
| `src/config.ts` | Token paths | adding-tools.md |
| `src/index.ts` | Entry point | adding-tools.md |
| `README.md` | Documentation | adding-tools.md |

## Token Configuration Rules

- Tokens stored in sibling `tokens/` folder
- Tools reference via relative path: `../../tokens/{tool-name}/`
- Never commit tokens to git
- Shared `credentials.json` for Google OAuth tools

## Security Rules

- No hardcoded API keys in source
- No .env files committed
- .gitignore must block: `*.json`, `.env`, `tokens/`
- Run `verify-security.sh` before pushing

## Integration Points

### Root CLAUDE.md Reference
```markdown
### Tool Creation Hook
When "create tool" or "new tool" mentioned:
→ Activate cli-tools-wiki skill
→ Check inventory before creating
→ Follow adding-tools.md templates
```

### Maintenance Skill Integration
```markdown
### CLI Tools Maintenance
Run wiki maintenance as part of repo maintenance:
→ ./cli-tools-wiki/scripts/maintenance.sh ./tools
```

## Quick Reference

```bash
# List available tools
./cli-tools-wiki/scripts/tool-wizard.sh list

# Clone tools interactively
./cli-tools-wiki/scripts/tool-wizard.sh clone

# Create new tool
./cli-tools-wiki/scripts/tool-wizard.sh create

# Run maintenance
./cli-tools-wiki/scripts/maintenance.sh ./tools

# Security check
./cli-tools-wiki/scripts/verify-security.sh ./tools
```

## Workspace Structure

```
workspace/
├── cli-tools-wiki/          # This wiki (clone first)
│   ├── docs/                # Documentation
│   ├── scripts/             # Wizard, maintenance, security
│   ├── skills/              # This skill file
│   └── tools/               # Inventory
├── tools/                    # Cloned tools (sibling)
│   ├── email-manager/
│   ├── calendar-manager/
│   └── ...
└── tokens/                   # Credentials (sibling)
    ├── credentials.json     # Shared Google OAuth
    ├── email-manager/
    └── ...
```
