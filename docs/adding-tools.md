# Adding New CLI Tools

Guide for creating and integrating new CLI tools into the collection.

## Prerequisites

- GitHub account with access to sftmlg organization
- Node.js 18+ and pnpm installed
- Git configured

## Step 1: Create Repository

```bash
# Create private repo
gh repo create sftmlg/{tool-name} --private --description "CLI tool for {purpose}"

# Add collaborators (if needed)
gh api -X PUT "repos/sftmlg/{tool-name}/collaborators/{username}" -f permission=push
```

## Step 2: Initialize Project

```bash
# Clone new repo
git clone https://github.com/sftmlg/{tool-name}.git
cd {tool-name}

# Initialize package
pnpm init

# Add TypeScript (recommended)
pnpm add -D typescript @types/node tsx

# Create structure
mkdir -p src
touch src/index.ts
```

## Step 3: Project Structure

Recommended layout:
```
{tool-name}/
├── src/
│   ├── index.ts           # Entry point
│   ├── commands/          # CLI commands
│   └── utils/             # Shared utilities
├── package.json
├── tsconfig.json
├── .gitignore
└── README.md
```

## Step 4: Token Reference

If tool needs authentication, reference sibling tokens folder:

```typescript
// src/config.ts
import { resolve } from 'path';

const TOKENS_DIR = resolve(__dirname, '../../tokens/{tool-name}');
const CREDENTIALS = resolve(__dirname, '../../tokens/credentials.json');

export { TOKENS_DIR, CREDENTIALS };
```

## Step 5: Essential .gitignore

```gitignore
# Dependencies
node_modules/
.pnpm-store/

# Environment
.env
.env.local

# Build
dist/
*.js
*.d.ts
!src/**/*.d.ts

# Tokens (redundant but safe)
tokens/
*.json
!package.json
!tsconfig.json

# IDE
.vscode/
.idea/
```

## Step 6: Package.json Template

```json
{
  "name": "{tool-name}",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "start": "tsx src/index.ts",
    "build": "tsc"
  },
  "dependencies": {},
  "devDependencies": {
    "@types/node": "^20.0.0",
    "tsx": "^4.0.0",
    "typescript": "^5.0.0"
  }
}
```

## Step 7: Add as Submodule

```bash
# From parent repo
git submodule add https://github.com/sftmlg/{tool-name}.git claude-code-cli-tools/{tool-name}
git commit -m "Add {tool-name} submodule"
```

## Step 8: Token Folder

If credentials needed:
```bash
mkdir -p tokens/{tool-name}
echo "# {tool-name} tokens" > tokens/{tool-name}/.gitkeep
```

## Step 9: Update Inventory

Add to `tools/inventory.md`:
```markdown
| {tool-name} | {Description} | sftmlg/{tool-name} |
```

## Step 10: Document Usage

Create tool's README.md:
```markdown
# {Tool Name}

{Brief description}

## Setup

```bash
pnpm install
```

## Authentication

See [Token Setup](../cli-tools-wiki/docs/token-setup.md)

## Commands

| Command | Description |
|---------|-------------|
| `pnpm start {cmd}` | {What it does} |

## Examples

```bash
# Example usage
pnpm start fetch --id 123
```
```

## Checklist

- [ ] Repository created on GitHub
- [ ] .gitignore includes tokens, node_modules, .env
- [ ] Token reference uses relative path `../../tokens/`
- [ ] No credentials in source code
- [ ] README documents all commands
- [ ] Added as submodule to parent
- [ ] Inventory updated
- [ ] Security verification passes

## Security Verification

After adding, run:
```bash
./scripts/verify-security.sh
```

Ensure:
- No hardcoded API keys
- No tokens tracked
- Proper .gitignore
- References sibling tokens folder
