#!/bin/bash
# Tool Wizard - Interactive CLI for managing tools
#
# Usage:
#   ./tool-wizard.sh clone     # Clone tools interactively
#   ./tool-wizard.sh create    # Create new tool with templates
#   ./tool-wizard.sh list      # List available tools
#   ./tool-wizard.sh setup     # Initial workspace setup

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WIKI_DIR="$(dirname "$SCRIPT_DIR")"
TOOLS_DIR="${TOOLS_DIR:-$(dirname "$WIKI_DIR")/tools}"
TOKENS_DIR="${TOKENS_DIR:-$(dirname "$WIKI_DIR")/tokens}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Available tools (from inventory)
TOOLS=(
  "bank-integration:Bank sync with sevDesk"
  "calendar-manager:Google Calendar management"
  "course-extractor:Course download + transcription"
  "document-generator:PDF invoices/contracts"
  "drive-manager:Google Drive operations"
  "email-manager:Gmail send/draft/fetch"
  "freelance-scout:Multi-platform job scouting"
  "ftp-explorer:FTP/SFTP file operations"
  "getmyinvoices-manager:GetMyInvoices API"
  "guide-creator:PDF guide generation"
  "image-editor:Image manipulation"
  "linkedin-tool:LinkedIn messaging/posts"
  "nano-banana:Gemini image generation"
  "profile-generator:Profile generation"
  "seo-audit:SEO/performance audit"
  "sharepoint-manager:SharePoint/OneDrive sync"
  "skool-manager:Skool community management"
  "transcriber:Unified transcription"
  "upwork-manager:Upwork API integration"
  "video-generator:Video generation pipeline"
  "website-fetcher:Website download for AI"
  "whatsapp-manager:WhatsApp message processing"
  "youtube-research:YouTube transcription"
)

show_header() {
  echo ""
  echo -e "${BLUE}=======================================${NC}"
  echo -e "${BLUE}        CLI Tools Wizard               ${NC}"
  echo -e "${BLUE}=======================================${NC}"
  echo ""
}

show_help() {
  show_header
  echo "Usage: $0 <command>"
  echo ""
  echo "Commands:"
  echo "  clone     Clone tools interactively to ./tools/"
  echo "  create    Create new tool with boilerplate"
  echo "  list      List all available tools"
  echo "  setup     Initial workspace setup"
  echo "  help      Show this help"
  echo ""
  echo "Environment:"
  echo "  TOOLS_DIR   Target directory for tools (default: ../tools)"
  echo "  TOKENS_DIR  Token storage directory (default: ../tokens)"
}

list_tools() {
  show_header
  echo "Available Tools:"
  echo ""
  printf "%-25s %s\n" "TOOL" "DESCRIPTION"
  printf "%-25s %s\n" "----" "-----------"
  for tool_info in "${TOOLS[@]}"; do
    name="${tool_info%%:*}"
    desc="${tool_info#*:}"
    printf "%-25s %s\n" "$name" "$desc"
  done
  echo ""
  echo "Total: ${#TOOLS[@]} tools"
}

clone_tools() {
  show_header
  echo "Clone Tools to: $TOOLS_DIR"
  echo ""

  # Ensure tools directory exists
  mkdir -p "$TOOLS_DIR"

  echo "Select tools to clone (space-separated numbers, or 'all'):"
  echo ""

  i=1
  for tool_info in "${TOOLS[@]}"; do
    name="${tool_info%%:*}"
    desc="${tool_info#*:}"

    # Check if already cloned
    if [ -d "$TOOLS_DIR/$name" ]; then
      echo -e "  $i) ${GREEN}[cloned]${NC} $name - $desc"
    else
      echo "  $i) $name - $desc"
    fi
    ((i++))
  done

  echo ""
  echo -n "Selection (e.g., '1 3 5' or 'all'): "
  read -r selection

  if [ "$selection" = "all" ]; then
    selection=$(seq 1 ${#TOOLS[@]})
  fi

  echo ""
  for num in $selection; do
    idx=$((num - 1))
    if [ $idx -ge 0 ] && [ $idx -lt ${#TOOLS[@]} ]; then
      tool_info="${TOOLS[$idx]}"
      name="${tool_info%%:*}"

      if [ -d "$TOOLS_DIR/$name" ]; then
        echo -e "${YELLOW}Skipping $name (already exists)${NC}"
      else
        echo -e "${BLUE}Cloning $name...${NC}"
        if gh repo clone "sftmlg/$name" "$TOOLS_DIR/$name" 2>/dev/null; then
          echo -e "${GREEN}✓ Cloned $name${NC}"

          # Create token folder
          mkdir -p "$TOKENS_DIR/$name"
        else
          echo -e "${RED}✗ Failed to clone $name${NC}"
        fi
      fi
    fi
  done

  echo ""
  echo -e "${GREEN}Done!${NC}"
  echo ""
  echo "Next steps:"
  echo "  1. Configure tokens: see docs/token-setup.md"
  echo "  2. Install dependencies: cd $TOOLS_DIR/{tool} && pnpm install"
}

create_tool() {
  show_header
  echo "Create New Tool"
  echo ""

  echo -n "Tool name (lowercase, hyphenated): "
  read -r name

  echo -n "Brief description: "
  read -r desc

  echo -n "Needs Google OAuth? (y/n): "
  read -r needs_oauth

  echo ""
  echo "Creating $name..."

  # Create GitHub repo
  echo -e "${BLUE}Creating GitHub repo...${NC}"
  if ! gh repo create "sftmlg/$name" --private --description "$desc"; then
    echo -e "${RED}Failed to create repo${NC}"
    exit 1
  fi

  # Add collaborator
  gh api -X PUT "repos/sftmlg/$name/collaborators/stydav" -f permission=push 2>/dev/null || true

  # Clone it
  echo -e "${BLUE}Cloning...${NC}"
  gh repo clone "sftmlg/$name" "$TOOLS_DIR/$name"
  cd "$TOOLS_DIR/$name"

  # Create structure
  mkdir -p src/commands src/utils

  # Create files from templates
  echo -e "${BLUE}Creating boilerplate...${NC}"

  # .gitignore
  cat > .gitignore << 'GITIGNORE'
node_modules/
.pnpm-store/
.env
.env.*
!.env.example
dist/
build/
*.js
*.d.ts
*.js.map
tokens/
*token*.json
*credential*.json
*.json
!package.json
!tsconfig.json
.vscode/
.idea/
*.log
GITIGNORE

  # package.json
  cat > package.json << PACKAGE
{
  "name": "$name",
  "version": "1.0.0",
  "description": "$desc",
  "type": "module",
  "scripts": {
    "start": "tsx src/index.ts",
    "build": "tsc",
    "dev": "tsx watch src/index.ts",
    "typecheck": "tsc --noEmit"
  },
  "author": "sftmlg",
  "license": "MIT",
  "devDependencies": {
    "@types/node": "^20.0.0",
    "tsx": "^4.0.0",
    "typescript": "^5.0.0"
  }
}
PACKAGE

  # tsconfig.json
  cat > tsconfig.json << 'TSCONFIG'
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
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
TSCONFIG

  # src/config.ts
  cat > src/config.ts << CONFIG
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';
import { existsSync } from 'fs';

const __dirname = dirname(fileURLToPath(import.meta.url));

const TOOL_NAME = '$name';
const TOKENS_BASE = resolve(__dirname, '../../tokens');
const TOOL_TOKENS = resolve(TOKENS_BASE, TOOL_NAME);
const CREDENTIALS_PATH = resolve(TOKENS_BASE, 'credentials.json');

export const config = {
  tokensDir: TOOL_TOKENS,
  credentialsPath: CREDENTIALS_PATH,

  getTokenPath(name: string): string {
    return resolve(TOOL_TOKENS, \`\${name}.json\`);
  },

  hasCredentials(): boolean {
    return existsSync(CREDENTIALS_PATH);
  },

  hasToken(name: string): boolean {
    return existsSync(this.getTokenPath(name));
  }
};

export default config;
CONFIG

  # src/index.ts
  cat > src/index.ts << 'INDEX'
#!/usr/bin/env node
import { config } from './config.js';

const [,, command, ...args] = process.argv;

async function main() {
  switch (command) {
    case 'help':
    default:
      showHelp();
  }
}

function showHelp() {
  console.log(`
Tool Name - Description

Commands:
  help    Show this help

Examples:
  pnpm start help
`);
}

main().catch(console.error);
INDEX

  # README.md
  cat > README.md << README
# $name

$desc

## Setup

\`\`\`bash
pnpm install
\`\`\`

## Authentication

See [Token Setup](https://github.com/sftmlg/cli-tools-wiki/blob/main/docs/token-setup.md)

## Commands

| Command | Description |
|---------|-------------|
| \`help\` | Show help |

## License

MIT
README

  # Install dependencies
  echo -e "${BLUE}Installing dependencies...${NC}"
  pnpm install

  # Create token folder
  mkdir -p "$TOKENS_DIR/$name"

  # Initial commit
  git add .
  git commit -m "Initial tool setup"
  git push origin main

  echo ""
  echo -e "${GREEN}✓ Created $name${NC}"
  echo ""
  echo "Tool location: $TOOLS_DIR/$name"
  echo "Token folder: $TOKENS_DIR/$name"
  echo ""
  echo "Next steps:"
  echo "  1. Edit src/index.ts to add commands"
  echo "  2. Update README.md"
  echo "  3. Add to inventory: cli-tools-wiki/tools/inventory.md"
}

setup_workspace() {
  show_header
  echo "Initial Workspace Setup"
  echo ""

  # Create directories
  echo -e "${BLUE}Creating directories...${NC}"
  mkdir -p "$TOOLS_DIR"
  mkdir -p "$TOKENS_DIR"

  echo "  ✓ Created $TOOLS_DIR"
  echo "  ✓ Created $TOKENS_DIR"

  # Check gh auth
  echo ""
  echo -e "${BLUE}Checking GitHub authentication...${NC}"
  if gh auth status 2>/dev/null | grep -q "Logged in"; then
    echo -e "  ${GREEN}✓ GitHub CLI authenticated${NC}"
  else
    echo -e "  ${RED}✗ GitHub CLI not authenticated${NC}"
    echo "    Run: gh auth login"
  fi

  echo ""
  echo -e "${GREEN}Workspace ready!${NC}"
  echo ""
  echo "Structure:"
  echo "  $(dirname "$WIKI_DIR")/"
  echo "  ├── cli-tools-wiki/   (this wiki)"
  echo "  ├── tools/            (cloned tools)"
  echo "  └── tokens/           (credentials)"
  echo ""
  echo "Next: $0 clone"
}

# Main
case "${1:-help}" in
  clone)
    clone_tools
    ;;
  create)
    create_tool
    ;;
  list)
    list_tools
    ;;
  setup)
    setup_workspace
    ;;
  help|--help|-h)
    show_help
    ;;
  *)
    echo -e "${RED}Unknown command: $1${NC}"
    show_help
    exit 1
    ;;
esac
