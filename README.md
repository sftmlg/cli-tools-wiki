# Claude Code CLI Tools Wiki

**Bounded Context**: CLI Tools Infrastructure Layer

→ **Architecture**: Domain-Driven Onion - this wiki documents the infrastructure layer
→ **Parent**: Root CLAUDE.md (Application Layer)
→ **Sub-Maintenance**: `skills/maintenance.md`

---

## Domain-Driven Onion Context

This wiki is part of the **infrastructure layer** in the DDD Onion Architecture:

```
Application Layer (Root CLAUDE.md)
    ↓ routes to
Domain Service (cli-tools-wiki/skills/maintenance.md)
    ↓ defines structure for
Infrastructure Layer (claude-code-cli-tools/{tool}/README.md)
```

**Context-First Principle**: Before using ANY tool, Claude loads context:
1. Keyword triggers → select tool folder
2. Read README.md → learn Quick Start invocation
3. Execute with correct parameters

---

## Philosophy: LLM-Native Tool Routing

**Core Concept**: When a user says "look at my calendar", Claude automatically knows to use `calendar-manager`.

This works through a **keyword-based routing system**:

1. **Each tool declares its keywords** in its README.md
2. **Root CLAUDE.md references** these keywords in a compact table
3. **Maintenance verifies** keywords are properly back-linked
4. **Result**: Natural language → tool routing

**This is LLM-based, not script-based**. Claude reads files, understands structure, and performs routing.

---

## Where To Read What

| Question | Location |
|----------|----------|
| What tools exist? | `tools/inventory.md` |
| How to create a tool? | `docs/adding-tools.md` |
| What structure must tools have? | `skills/maintenance.md` |
| How does keyword routing work? | This README + `skills/maintenance.md` |
| How to configure tokens? | `docs/token-setup.md` |
| Security verification? | `scripts/verify-security.sh` |

---

## How Keyword Routing Works

### Layer 1: Tool Level (Source of Truth)

Each tool's README.md has a Keywords section:

```markdown
## Keywords

`calendar`, `gcal`, `today`, `tomorrow`, `week`, `schedule`
```

### Layer 2: Root CLAUDE.md (Compact Reference)

Root has a keyword triggers table:

```markdown
| Keywords | Tool | Run Command |
|----------|------|-------------|
| calendar, gcal, today, week | calendar-manager | `node index.mjs <cmd>` |
```

### Layer 3: Maintenance (Verification)

Maintenance skill verifies all tool keywords are back-linked in root.

**Flow**: User says keyword → Claude checks root table → routes to tool

---

## Tool Structure Requirements

Every tool MUST have:

| File | Purpose |
|------|---------|
| `README.md` | Documentation with **Keywords section** |
| `package.json` | Dependencies and npm scripts |
| `.gitignore` | Block tokens, .env, node_modules |
| `src/index.ts` | CLI entry point |

### Keywords Section (Required)

```markdown
## Keywords

`keyword1`, `keyword2`, `keyword3`

These keywords trigger automatic routing to this tool.
```

→ Full structure spec: `skills/maintenance.md`

---

## Maintenance (LLM-Based)

Maintenance is performed by Claude, not scripts.

**Process**:
1. Read `tools/inventory.md` → get tool list
2. For each tool → verify structure, extract keywords
3. Compare to root CLAUDE.md → verify back-links
4. Report issues → suggest fixes

**Trigger**: "run maintenance", "check tools", "verify tools"

→ Full process: `skills/maintenance.md`

---

## Tool Creation (LLM-Based)

When creating new tools, Claude:

1. Checks inventory for existing similar tool
2. Creates structure using `docs/adding-tools.md` templates
3. Adds Keywords section to README
4. Updates inventory
5. Runs security verification

**Trigger**: "create tool", "new tool", "add tool"

→ Full process: `skills/tool-setup.md`

---

## Directory Structure

```
cli-tools-wiki/
├── README.md                    # Philosophy + routing explanation (this file)
├── docs/
│   ├── adding-tools.md          # Tool creation templates
│   ├── token-setup.md           # Credential configuration
│   ├── submodule-usage.md       # Git submodule workflows
│   └── convert-to-repo.md       # Convert local code to repo
├── scripts/
│   └── verify-security.sh       # Security verification (only script)
├── skills/
│   ├── maintenance.md           # LLM-based maintenance skill
│   └── tool-setup.md            # Tool creation skill
└── tools/
    └── inventory.md             # Tool catalog (names, descriptions)
```

---

## LLM-Based Operations

All operations except security verification are performed by Claude directly:

| Task | Method |
|------|--------|
| Security check | `scripts/verify-security.sh` (pattern matching) |
| Structure verification | Claude reads files |
| Keyword extraction | Claude parses README |
| Back-link verification | Claude compares files |
| Tool creation | Claude follows templates |
| Maintenance | Claude runs verification process |

---

## Integration Points

### From Root CLAUDE.md

```markdown
### CLI Tool Keyword Routing
When user mentions tool-related keywords:
→ Check keyword triggers table in this file
→ Route to appropriate tool from `claude-code-cli-tools/`

### Tool Creation Hook
When "create tool" or "new tool" mentioned:
→ Check `cli-tools-wiki/tools/inventory.md`
→ Follow `cli-tools-wiki/docs/adding-tools.md`

### Maintenance Integration
When running repository maintenance:
→ Activate `cli-tools-wiki/skills/maintenance.md`
→ Verify tool keywords are back-linked
```

### From Root Maintenance Skill

```markdown
### CLI Tools Maintenance
→ Activate `cli-tools-wiki/skills/maintenance.md`
→ Follow LLM-based verification process
```

---

## Quick Reference

**User says**: "check my calendar today"
**Claude does**:
1. Recognizes "calendar", "today" as keywords
2. Looks up in root CLAUDE.md keyword table
3. Routes to `calendar-manager`
4. Runs: `cd claude-code-cli-tools/calendar-manager && node index.mjs today`

**User says**: "run maintenance on tools"
**Claude does**:
1. Activates `cli-tools-wiki/skills/maintenance.md`
2. Reads inventory → gets tool list
3. Checks each tool's structure
4. Verifies keywords back-linked in root
5. Reports issues

---

## Collaborators

- sftmlg (owner)
- stydav (collaborator)

## License

MIT
