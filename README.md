# Claude Code CLI Tools Wiki

Shareable documentation for setting up and using Claude Code CLI tools. Clone this wiki alongside your tool repositories for consistent setup guidance.

## Quick Start

### 1. Clone This Wiki

```bash
git clone https://github.com/sftmlg/cli-tools-wiki.git
```

### 2. Setup Tokens

See [docs/token-setup.md](docs/token-setup.md) for credential configuration.

### 3. Get Tools

Clone individual tools or the full collection:

```bash
# Single tool
git clone https://github.com/sftmlg/{tool-name}.git

# Full collection with submodules
git clone --recurse-submodules https://github.com/sftmlg/claude-code-cli-tools.git
```

### 4. Verify Security

```bash
./scripts/verify-security.sh
```

## Structure

```
cli-tools-wiki/
├── README.md                    # This file
├── docs/
│   ├── token-setup.md           # Credential configuration
│   ├── submodule-usage.md       # Git submodule workflows
│   └── adding-tools.md          # Creating new tools
├── scripts/
│   └── verify-security.sh       # Security verification
└── tools/
    └── inventory.md             # Available tools catalog
```

## Documentation Index

| Document | Purpose |
|----------|---------|
| [Token Setup](docs/token-setup.md) | Configure authentication tokens for all tools |
| [Submodule Usage](docs/submodule-usage.md) | Clone, update, and manage tool submodules |
| [Adding Tools](docs/adding-tools.md) | Create and integrate new CLI tools |
| [Tools Inventory](tools/inventory.md) | Complete catalog of available tools |

## Integration with CLAUDE.md

Reference this wiki from your project's CLAUDE.md:

```markdown
### CLI Tools Wiki
See `cli-tools-wiki/` for:
- Token setup: `cli-tools-wiki/docs/token-setup.md`
- Available tools: `cli-tools-wiki/tools/inventory.md`
- Security verification: `cli-tools-wiki/scripts/verify-security.sh`
```

## Design Principles

- **Generic**: No project-specific paths or credentials
- **Shareable**: Clone as standalone wiki or submodule
- **Secure**: Tokens stored locally, never committed
- **Modular**: Each tool works independently

## License

MIT
