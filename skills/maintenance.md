# CLI Tools Maintenance Skill

**Domain Service** for the CLI Tools bounded context - structure verification and keyword routing.

→ **Architecture**: Domain-Driven Onion - Layer 1 Domain Service
→ **Parent (Application Layer)**: Root maintenance skill (`.claude/skills/maintenance.md`)
→ **Wiki Documentation**: `cli-tools-wiki/README.md`
→ **Infrastructure Layer**: `claude-code-cli-tools/{tool}/README.md`

---

## Context-First Principle

**CRITICAL**: Before using ANY CLI tool, Claude MUST load context first.

```
User mentions keyword (e.g., "email")
    ↓
Keyword Routing → Select tool folder (email-manager/)
    ↓
Context Loading → Read README.md Quick Start section
    ↓
Domain Understanding → Learn invocation pattern
    ↓
Correct Execution → Run `pnpm start fetch business` (not guessed syntax)
```

**Why**: Without context loading, parameterization errors occur (e.g., `pnpm fetch --query` instead of `pnpm start fetch business`).

---

## Activation Triggers

- Keywords: "maintain tools", "tool maintenance", "check tools", "verify tools"
- Keywords: "run maintenance", "tools health check"
- Context: Working in `claude-code-cli-tools/` or `cli-tools-wiki/`
- Referenced from: Root maintenance skill (automatic sub-onion activation)

---

## Tool Structure Requirements

Each tool MUST have these files:

| File | Purpose | Required |
|------|---------|----------|
| `README.md` | Documentation with Keywords section | YES |
| `package.json` | Dependencies and scripts | YES |
| `.gitignore` | Block tokens, node_modules, .env | YES |
| `src/index.ts` | Entry point | YES |
| `src/config.ts` | Token path configuration | If uses tokens |
| `tsconfig.json` | TypeScript configuration | If TypeScript |

### Keywords Section Requirement

**CRITICAL**: Every tool's README.md MUST have a Keywords section:

```markdown
## Keywords

`keyword1`, `keyword2`, `keyword3`

These keywords trigger automatic routing to this tool when mentioned in user requests.
```

### Quick Start Section Requirement

**CRITICAL**: Every tool's README.md MUST have a Quick Start section in the first 20 lines:

```markdown
## Quick Start

**Invocation Pattern**: `pnpm start <command> [args]`

### Common Commands
\`\`\`bash
pnpm start auth personal                                       # Authenticate
pnpm start fetch business --query "from:client.com" --max 50  # With options
\`\`\`

**Need help?** `pnpm start help`
```

**Why**: This enables correct execution without reading source code. Documentation IS the interface for LLM agents.

→ **Full template**: `cli-tools-wiki/CLI_TOOL_README_TEMPLATE.md`

---

## LLM-Based Maintenance Process

When running maintenance, Claude performs these checks:

### 1. Get Tool List

Read `cli-tools-wiki/tools/inventory.md` to get list of known tools.

### 2. For Each Tool, Verify Structure

```
For each tool in inventory:
  1. Check README.md exists
  2. Check README.md has "## Keywords" section
  3. Extract keywords from that section
  4. Check package.json exists
  5. Check .gitignore exists
  6. Report any missing files
```

### 3. Keyword Back-Link Verification

```
For each tool's keywords:
  1. Read root CLAUDE.md "CLI Tools Keyword Triggers" section
  2. Verify tool is listed with its keywords
  3. Report any keywords NOT back-linked in root
```

### 4. Generate Report

```markdown
## Maintenance Report

### Structure Check
- tool-a: ✅ All files present
- tool-b: ⚠️ Missing Keywords section in README
- tool-c: ❌ Missing .gitignore

### Keyword Back-Link Check
- calendar-manager: ✅ All keywords linked (calendar, gcal, today, week)
- new-tool: ⚠️ Keywords not in root CLAUDE.md: `newkeyword1`, `newkeyword2`

### Actions Needed
1. Add Keywords section to tool-b/README.md
2. Add .gitignore to tool-c
3. Update root CLAUDE.md with new-tool keywords
```

---

## Maintenance Commands (LLM Executes)

### Quick Structure Check

```bash
# List tools and check for README.md
for tool in claude-code-cli-tools/*/; do
  [ -f "$tool/README.md" ] && echo "✅ $(basename $tool)" || echo "❌ $(basename $tool): missing README"
done
```

### Extract Keywords from Tool

```bash
# Read Keywords section from a tool's README
grep -A 5 "^## Keywords" claude-code-cli-tools/{tool}/README.md
```

### Security Check (Script - OK to use)

```bash
./cli-tools-wiki/scripts/verify-security.sh ./claude-code-cli-tools
```

---

## Integration with Root Maintenance

The root maintenance skill references this skill:

```markdown
### CLI Tools Maintenance
When running repository maintenance:
→ Activate `cli-tools-wiki/skills/maintenance.md`
→ Follow LLM-based maintenance process
→ Update root CLAUDE.md keyword table if needed
```

---

## Tool Creation (LLM-Based)

When creating new tools, Claude:

1. **Check inventory** - Does similar tool exist?
2. **Create structure** - Use templates from `docs/adding-tools.md`
3. **Add Keywords section** - Required in README.md
4. **Update inventory** - Add to `tools/inventory.md`
5. **Verify security** - Run `verify-security.sh`

### Keywords Section Template

When creating README.md for new tool:

```markdown
## Keywords

`keyword1`, `keyword2`, `keyword3`

These keywords trigger automatic routing to this tool when mentioned in user requests.
```

---

## Relationship to Scripts

| Task | Method |
|------|--------|
| Structure verification | LLM reads files |
| Keyword extraction | LLM parses README |
| Back-link verification | LLM compares to root CLAUDE.md |
| Security check | `verify-security.sh` (script OK) |
| Tool creation | LLM follows templates |

**Note**: `maintenance.sh` and `tool-wizard.sh` are legacy scripts. The maintenance process is now LLM-based - Claude reads files and performs verification directly.

---

## Example Maintenance Session

**User**: "Run maintenance on CLI tools"

**Claude**:
1. Reads `cli-tools-wiki/tools/inventory.md` → Gets tool list
2. For each tool:
   - Reads `{tool}/README.md` → Checks structure
   - Extracts Keywords section
3. Reads root `CLAUDE.md` → Gets keyword triggers table
4. Compares → Reports missing back-links
5. Suggests updates if needed

**Output**:
```
## CLI Tools Maintenance Report

### Tools Checked: 21

### Structure Issues
- content-generation: ⚠️ No Keywords section

### Keyword Back-Links
All tools properly linked in root CLAUDE.md ✅

### Security
Running verify-security.sh...
✅ No security issues found
```
