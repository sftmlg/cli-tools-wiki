# Claude Code CLI Tools Wiki

Shareable documentation and management system for Claude Code CLI tools.

**Clone this wiki first** → then clone tools into sibling folder → configure tokens.

## Quick Start

### 1. Clone Wiki

```bash
# Clone this as your tools management hub
git clone https://github.com/sftmlg/cli-tools-wiki.git
cd cli-tools-wiki
```

### 2. Setup Workspace

```bash
# Create sibling directories
./scripts/tool-wizard.sh setup

# Results in:
# parent-folder/
# ├── cli-tools-wiki/   (this wiki)
# ├── tools/            (your cloned tools)
# └── tokens/           (credentials - local only)
```

### 3. Clone Tools

```bash
# Interactive selection
./scripts/tool-wizard.sh clone

# Or list available tools first
./scripts/tool-wizard.sh list
```

### 4. Configure Tokens

See [docs/token-setup.md](docs/token-setup.md)

### 5. Run Maintenance

```bash
./scripts/maintenance.sh ../tools
```

---

## Structure

```
cli-tools-wiki/
├── README.md                    # This file
├── docs/
│   ├── token-setup.md           # Credential configuration
│   ├── submodule-usage.md       # Git submodule workflows
│   ├── adding-tools.md          # Creating new tools (templates)
│   ├── tool-maintenance.md      # Maintenance procedures
│   └── convert-to-repo.md       # Convert local code to repo
├── scripts/
│   ├── tool-wizard.sh           # Interactive tool management
│   ├── maintenance.sh           # Health check for tools
│   └── verify-security.sh       # Security verification
├── skills/
│   └── tool-setup.md            # Activation skill for Claude
└── tools/
    └── inventory.md             # Complete tools catalog
```

## Documentation Index

| Document | Purpose |
|----------|---------|
| [Token Setup](docs/token-setup.md) | Configure authentication tokens |
| [Adding Tools](docs/adding-tools.md) | Create new CLI tools with templates |
| [Tool Maintenance](docs/tool-maintenance.md) | Keep tools healthy and secure |
| [Convert to Repo](docs/convert-to-repo.md) | Turn local code into git repos |
| [Submodule Usage](docs/submodule-usage.md) | Git submodule workflows |
| [Tools Inventory](tools/inventory.md) | Complete catalog of available tools |

## Scripts

| Script | Usage | Purpose |
|--------|-------|---------|
| `tool-wizard.sh` | `./scripts/tool-wizard.sh [cmd]` | Interactive tool management |
| `maintenance.sh` | `./scripts/maintenance.sh [path]` | Health check for tools |
| `verify-security.sh` | `./scripts/verify-security.sh [path]` | Security verification |

### Tool Wizard Commands

```bash
./scripts/tool-wizard.sh setup    # Initial workspace setup
./scripts/tool-wizard.sh list     # List available tools
./scripts/tool-wizard.sh clone    # Clone tools interactively
./scripts/tool-wizard.sh create   # Create new tool with templates
```

## Integration with CLAUDE.md

### Tool Creation Hook

Add to your project's CLAUDE.md:

```markdown
### Tool Creation Hook
**TRIGGER**: "create tool", "new tool", "add tool", "tool setup"

**Behavior**:
1. Check `cli-tools-wiki/tools/inventory.md` for existing tool
2. If exists → clone it
3. If not → follow `cli-tools-wiki/docs/adding-tools.md`

→ See `cli-tools-wiki/skills/tool-setup.md` for full activation spec.
```

### Maintenance Integration

Add to maintenance skill:

```markdown
### CLI Tools Maintenance
When maintaining repository, include tools check:
- Run: `./cli-tools-wiki/scripts/maintenance.sh ./tools`
- Security: `./cli-tools-wiki/scripts/verify-security.sh ./tools`

→ See `cli-tools-wiki/docs/tool-maintenance.md` for procedures.
```

## Workspace Layout

After setup, your workspace looks like:

```
your-workspace/
├── cli-tools-wiki/              # This wiki
│   ├── docs/                    # All documentation
│   ├── scripts/                 # Management scripts
│   ├── skills/                  # Claude activation skills
│   └── tools/                   # Tool inventory
├── tools/                       # Cloned tools (sibling)
│   ├── email-manager/
│   ├── calendar-manager/
│   ├── drive-manager/
│   └── ...
└── tokens/                      # Credentials (sibling, local only)
    ├── credentials.json         # Shared Google OAuth
    ├── email-manager/
    │   └── business.json
    └── ...
```

## Design Principles

- **Wiki First**: Clone wiki before tools for management capabilities
- **Generic**: No project-specific paths or credentials
- **Secure**: Tokens in sibling folder, never committed
- **Modular**: Each tool works independently
- **Self-Documenting**: Full templates and procedures included

## Collaborators

All tools accessible by:
- sftmlg (owner)
- stydav (collaborator)

## License

MIT
