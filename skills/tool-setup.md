# Tool Setup Skill

**Purpose**: Activate when creating, maintaining, or managing CLI tools. All operations are LLM-based.

## Activation Triggers

- Keywords: "create tool", "new tool", "add tool", "tool setup", "setup tool"
- Keywords: "maintain tools", "clean tools", "tool maintenance"
- Keywords: "convert to repo", "make repo", "git init tool"
- File patterns: Working in `*-manager/`, `*-tool/`, `*-generator/`

## Pre-Action Checklist

**BEFORE creating a new tool:**

1. **Check inventory first**: Read `tools/inventory.md` for existing tool
2. **Check GitHub**: `gh repo view sftmlg/{potential-name}`
3. **Only create if no match** - prefer cloning existing over creating new

## Procedures (LLM-Based)

### Creating New Tool

Claude performs these steps:
1. Read `cli-tools-wiki/docs/adding-tools.md` for templates
2. Create required files:
   - `.gitignore` (required - blocks tokens)
   - `tsconfig.json`
   - `package.json`
   - `src/config.ts` (token reference)
   - `src/index.ts`
   - `README.md` with **Keywords section**
3. Create GitHub repo: `gh repo create sftmlg/{name} --private`
4. Add collaborators
5. Update inventory

### Cloning Existing Tools

Claude performs:
1. `gh repo clone sftmlg/{tool-name} claude-code-cli-tools/{tool-name}`
2. `mkdir -p tokens/{tool-name}`
3. Verify structure

### Converting Local Code to Repo

Claude performs:
1. Read `cli-tools-wiki/docs/convert-to-repo.md`
2. Verify no secrets: `grep -rE 'AIzaSy|sk-|ghp_' .`
3. Add required files (.gitignore, README with Keywords)
4. Create repo: `gh repo create sftmlg/{name} --source . --push`

### Running Maintenance

Claude performs (see `skills/maintenance.md`):
1. Read tool list from inventory
2. Verify each tool has required structure
3. Extract keywords from README
4. Verify back-links in root CLAUDE.md
5. Security check: `./scripts/verify-security.sh`

## Required Files for Every Tool

| File | Purpose | Template |
|------|---------|----------|
| `.gitignore` | Block secrets | adding-tools.md |
| `tsconfig.json` | TypeScript config | adding-tools.md |
| `package.json` | Dependencies | adding-tools.md |
| `src/config.ts` | Token paths | adding-tools.md |
| `src/index.ts` | Entry point | adding-tools.md |
| `README.md` | Documentation **with Keywords section** | adding-tools.md |

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
→ Activate cli-tools-wiki/skills/tool-setup.md
→ Check inventory before creating
→ Follow adding-tools.md templates
→ Ensure README has Keywords section
```

### Maintenance Skill Integration
```markdown
### CLI Tools Maintenance
→ Activate cli-tools-wiki/skills/maintenance.md
→ LLM-based verification process
→ Security check: ./scripts/verify-security.sh
```

## Quick Reference (LLM Commands)

Claude performs these operations when triggered:

| User Says | Claude Does |
|-----------|-------------|
| "list tools" | Reads `tools/inventory.md` |
| "clone email-manager" | `gh repo clone sftmlg/email-manager` |
| "create new tool" | Follows templates in `docs/adding-tools.md` |
| "run maintenance" | Activates `skills/maintenance.md` |
| "security check" | `./scripts/verify-security.sh ./claude-code-cli-tools` |

## Workspace Structure

```
software-moling/
├── cli-tools-wiki/           # Documentation wiki
│   ├── docs/                 # Templates
│   ├── scripts/              # verify-security.sh only
│   ├── skills/               # LLM-based skills
│   └── tools/                # Inventory
├── claude-code-cli-tools/    # Actual tools
│   ├── email-manager/
│   ├── calendar-manager/
│   ├── tokens/               # Centralized credentials
│   └── ...
```
