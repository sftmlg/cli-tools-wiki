# Adding New CLI Tools

Complete guide for creating and integrating new CLI tools.

## Before Creating: Check Inventory First

**CRITICAL**: Before writing new code, check if a tool already exists:

1. Review [tools/inventory.md](../tools/inventory.md)
2. Check if tool can be cloned: `gh repo view sftmlg/{tool-name}`
3. Only create new if no existing tool matches your need

## Prerequisites

- GitHub account (sftmlg or stydav)
- Node.js 18+ and pnpm installed
- Git configured
- gh CLI authenticated: `gh auth status`

## Quick Start: Use the Wizard

```bash
# Interactive tool creation
./scripts/tool-wizard.sh create
```

Or follow the manual steps below.

---

## Step 1: Create Repository

```bash
# Create private repo
gh repo create sftmlg/{tool-name} --private --description "CLI tool for {purpose}"

# Add collaborators
gh api -X PUT "repos/sftmlg/{tool-name}/collaborators/stydav" -f permission=push
gh api -X PUT "repos/sftmlg/{tool-name}/collaborators/sftmlg" -f permission=admin
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
mkdir -p src/commands src/utils
touch src/index.ts src/config.ts
```

## Step 3: Project Structure

```
{tool-name}/
├── src/
│   ├── index.ts           # Entry point + CLI routing
│   ├── config.ts          # Token paths and configuration
│   ├── commands/          # CLI command handlers
│   │   ├── auth.ts        # Authentication command
│   │   └── {command}.ts   # Feature commands
│   └── utils/             # Shared utilities
│       └── api.ts         # API client
├── package.json
├── tsconfig.json
├── .gitignore
└── README.md
```

## Step 4: Complete File Templates

### .gitignore (REQUIRED)

```gitignore
# Dependencies
node_modules/
.pnpm-store/

# Environment & Secrets
.env
.env.*
!.env.example
*.pem
*.key

# Build output
dist/
build/
*.js
*.d.ts
*.js.map
!*.config.js

# Tokens (redundant but critical)
tokens/
*token*.json
*credential*.json
*secret*
*.json
!package.json
!tsconfig.json
!*.config.json

# IDE
.vscode/
.idea/
*.swp
*.swo
.DS_Store

# Logs
*.log
npm-debug.log*
pnpm-debug.log*
```

### tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

### package.json

```json
{
  "name": "{tool-name}",
  "version": "1.0.0",
  "description": "CLI tool for {purpose}",
  "type": "module",
  "main": "dist/index.js",
  "scripts": {
    "start": "tsx src/index.ts",
    "build": "tsc",
    "dev": "tsx watch src/index.ts",
    "typecheck": "tsc --noEmit"
  },
  "keywords": ["cli", "automation"],
  "author": "sftmlg",
  "license": "MIT",
  "dependencies": {},
  "devDependencies": {
    "@types/node": "^20.0.0",
    "tsx": "^4.0.0",
    "typescript": "^5.0.0"
  }
}
```

### src/config.ts (Token Reference)

```typescript
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';
import { existsSync } from 'fs';

const __dirname = dirname(fileURLToPath(import.meta.url));

// Tokens stored in sibling folder: ../tokens/{tool-name}/
const TOOL_NAME = '{tool-name}';
const TOKENS_BASE = resolve(__dirname, '../../tokens');
const TOOL_TOKENS = resolve(TOKENS_BASE, TOOL_NAME);

// Shared Google OAuth credentials
const CREDENTIALS_PATH = resolve(TOKENS_BASE, 'credentials.json');

export const config = {
  tokensDir: TOOL_TOKENS,
  credentialsPath: CREDENTIALS_PATH,

  getTokenPath(name: string): string {
    return resolve(TOOL_TOKENS, `${name}.json`);
  },

  hasCredentials(): boolean {
    return existsSync(CREDENTIALS_PATH);
  },

  hasToken(name: string): boolean {
    return existsSync(this.getTokenPath(name));
  }
};

export default config;
```

### src/index.ts (CLI Entry Point)

```typescript
#!/usr/bin/env node
import { config } from './config.js';

const [,, command, ...args] = process.argv;

async function main() {
  switch (command) {
    case 'auth':
      const { auth } = await import('./commands/auth.js');
      await auth(args[0]);
      break;

    // Add more commands here

    case 'help':
    default:
      showHelp();
  }
}

function showHelp() {
  console.log(`
{Tool Name} - {Brief description}

Commands:
  auth <account>    Authenticate with account
  help              Show this help

Examples:
  pnpm start auth business
  pnpm start {command} --option value
`);
}

main().catch(console.error);
```

### README.md Template

````markdown
# {Tool Name}

{Brief description of what this tool does}

## Setup

```bash
pnpm install
```

## Authentication

See [Token Setup](https://github.com/sftmlg/cli-tools-wiki/blob/main/docs/token-setup.md)

```bash
# Authenticate
pnpm start auth business
```

## Commands

| Command | Description |
|---------|-------------|
| `auth <account>` | Authenticate with account |
| `{cmd}` | {Description} |
| `help` | Show help |

## Examples

```bash
# Basic usage
pnpm start {command}

# With options
pnpm start {command} --option value
```

## Configuration

Tokens stored in `../tokens/{tool-name}/`

## License

MIT
````

---

## Step 5: Add as Submodule (if part of collection)

```bash
# From parent repo
cd /path/to/software-moling
git submodule add https://github.com/sftmlg/{tool-name}.git claude-code-cli-tools/{tool-name}
git commit -m "Add {tool-name} submodule"
```

## Step 6: Create Token Folder

```bash
mkdir -p tokens/{tool-name}
touch tokens/{tool-name}/.gitkeep
```

## Step 7: Update Inventory

Add to [tools/inventory.md](../tools/inventory.md):

```markdown
| {tool-name} | {Description} | {Auth Type} |
```

## Step 8: Initial Commit

```bash
cd {tool-name}
git add .
git commit -m "Initial tool setup with TypeScript config"
git push origin main
```

---

## Checklist

### Required
- [ ] Repository created on GitHub (sftmlg org)
- [ ] Both sftmlg and stydav have access
- [ ] .gitignore blocks tokens, node_modules, .env, *.json
- [ ] Token paths use relative `../../tokens/`
- [ ] No credentials in source code
- [ ] tsconfig.json configured for ES2022/NodeNext
- [ ] README documents all commands

### If Submodule
- [ ] Added to claude-code-cli-tools/
- [ ] tokens/{tool-name}/ created
- [ ] Inventory updated
- [ ] Root CLAUDE.md keyword triggers updated (if applicable)

### Security Verification

```bash
# From wiki directory
./scripts/verify-security.sh ../tools

# Or from tools directory
../cli-tools-wiki/scripts/verify-security.sh .
```

---

## Common Patterns

### Google OAuth Tool

```typescript
// src/commands/auth.ts
import { google } from 'googleapis';
import { readFileSync, writeFileSync, existsSync } from 'fs';
import { config } from '../config.js';

export async function auth(account: string) {
  if (!config.hasCredentials()) {
    console.error('Missing credentials.json - see token-setup.md');
    process.exit(1);
  }

  const credentials = JSON.parse(readFileSync(config.credentialsPath, 'utf-8'));
  const { client_id, client_secret, redirect_uris } = credentials.installed;

  const oauth2Client = new google.auth.OAuth2(
    client_id, client_secret, redirect_uris[0]
  );

  // Generate auth URL and handle callback...
  const tokenPath = config.getTokenPath(account);
  // Save token to tokenPath
}
```

### API Client Pattern

```typescript
// src/utils/api.ts
export class ApiClient {
  constructor(private baseUrl: string, private apiKey?: string) {}

  async get<T>(path: string): Promise<T> {
    const response = await fetch(`${this.baseUrl}${path}`, {
      headers: this.apiKey ? { 'Authorization': `Bearer ${this.apiKey}` } : {}
    });
    if (!response.ok) throw new Error(`API error: ${response.status}`);
    return response.json();
  }
}
```

### Environment Variables

If tool uses env vars instead of token files:

```typescript
// src/config.ts
export const config = {
  apiKey: process.env.{TOOL}_API_KEY,

  validate() {
    if (!this.apiKey) {
      console.error('Missing {TOOL}_API_KEY environment variable');
      process.exit(1);
    }
  }
};
```

With `.env.example`:
```
{TOOL}_API_KEY=your-api-key-here
```
