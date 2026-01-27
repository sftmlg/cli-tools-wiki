#!/bin/bash
# Security verification script for CLI tools
# Checks that no secrets are committed and tokens are properly configured
#
# Usage:
#   ./verify-security.sh                    # Run from cli-tools directory
#   ./verify-security.sh /path/to/cli-tools # Specify custom path

set -e

# Determine CLI tools directory
if [ -n "$1" ]; then
  CLI_TOOLS_DIR="$1"
elif [ -d "./tokens" ] && [ -d "./email-manager" ]; then
  # Running from cli-tools directory
  CLI_TOOLS_DIR="."
else
  # Try parent of script directory
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  CLI_TOOLS_DIR="$(dirname "$SCRIPT_DIR")"
fi

# Verify directory exists and looks like cli-tools
if [ ! -d "$CLI_TOOLS_DIR" ]; then
  echo "Error: CLI tools directory not found: $CLI_TOOLS_DIR"
  echo "Usage: $0 [path/to/cli-tools]"
  exit 1
fi

# Resolve to absolute path
CLI_TOOLS_DIR="$(cd "$CLI_TOOLS_DIR" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

echo "========================================"
echo "CLI Tools Security Verification"
echo "========================================"
echo "Scanning: $CLI_TOOLS_DIR"
echo ""

# 1. Check for hardcoded API keys in source code
echo "1. Checking for hardcoded API keys..."
PATTERNS='AIzaSy[a-zA-Z0-9_-]{33}|sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{36}|gho_[a-zA-Z0-9]{36}|github_pat_[a-zA-Z0-9_]{22,}|xox[baprs]-[a-zA-Z0-9-]+|AKIA[0-9A-Z]{16}'

FOUND=$(grep -rE "$PATTERNS" "$CLI_TOOLS_DIR" \
  --include="*.ts" --include="*.js" --include="*.mjs" --include="*.json" \
  --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=tokens \
  2>/dev/null || true)

if [ -n "$FOUND" ]; then
  echo -e "${RED}FAIL: Potential API keys found in source code:${NC}"
  echo "$FOUND" | head -10
  ERRORS=$((ERRORS + 1))
else
  echo -e "${GREEN}PASS: No hardcoded API keys detected${NC}"
fi

# 2. Check that tokens folder is not tracked in submodules
echo ""
echo "2. Checking tokens are not in submodule repos..."
for tool in "$CLI_TOOLS_DIR"/*/; do
  tool_name=$(basename "$tool")
  if [ -d "$tool/.git" ] || [ -f "$tool/.git" ]; then
    # Check if any token files are tracked
    TRACKED=$(cd "$tool" && git ls-files 2>/dev/null | grep -iE 'token.*\.json|\.env$|secret|credential.*\.json|api.key' | grep -v example | grep -v README || true)
    if [ -n "$TRACKED" ]; then
      echo -e "${RED}FAIL: $tool_name has sensitive files tracked: $TRACKED${NC}"
      ERRORS=$((ERRORS + 1))
    fi
  fi
done
echo -e "${GREEN}PASS: No tokens tracked in submodule repos${NC}"

# 3. Check tokens folder structure
echo ""
echo "3. Checking tokens folder structure..."
TOKENS_DIR="$CLI_TOOLS_DIR/tokens"
if [ -d "$TOKENS_DIR" ]; then
  echo -e "${GREEN}PASS: tokens/ folder exists${NC}"

  # Check if credentials.json exists
  if [ -f "$TOKENS_DIR/credentials.json" ]; then
    echo -e "${GREEN}PASS: Shared credentials.json exists${NC}"
  else
    echo -e "${YELLOW}WARN: credentials.json not found (needed for Google OAuth tools)${NC}"
    WARNINGS=$((WARNINGS + 1))
  fi

  # List token subfolders
  echo "   Token folders present:"
  for folder in "$TOKENS_DIR"/*/; do
    if [ -d "$folder" ]; then
      folder_name=$(basename "$folder")
      file_count=$(find "$folder" -type f 2>/dev/null | wc -l)
      echo "   - $folder_name/ ($file_count files)"
    fi
  done
else
  echo -e "${YELLOW}WARN: tokens/ folder not found - create it for credential storage${NC}"
  WARNINGS=$((WARNINGS + 1))
fi

# 4. Check .gitignore in each tool
echo ""
echo "4. Checking .gitignore configurations..."
MISSING_GITIGNORE=()
for tool in "$CLI_TOOLS_DIR"/*/; do
  tool_name=$(basename "$tool")
  [ "$tool_name" = "tokens" ] && continue
  [ "$tool_name" = "scripts" ] && continue
  [ "$tool_name" = "_metadata" ] && continue
  [ "$tool_name" = "wiki" ] && continue

  if [ -d "$tool/.git" ] || [ -f "$tool/.git" ]; then
    if [ ! -f "$tool/.gitignore" ]; then
      MISSING_GITIGNORE+=("$tool_name")
    else
      # Check for essential patterns
      if ! grep -q "node_modules" "$tool/.gitignore" 2>/dev/null && \
         ! grep -q "\.env" "$tool/.gitignore" 2>/dev/null; then
        echo -e "${YELLOW}WARN: $tool_name .gitignore may be incomplete${NC}"
        WARNINGS=$((WARNINGS + 1))
      fi
    fi
  fi
done

if [ ${#MISSING_GITIGNORE[@]} -gt 0 ]; then
  echo -e "${YELLOW}WARN: Tools missing .gitignore: ${MISSING_GITIGNORE[*]}${NC}"
  WARNINGS=$((WARNINGS + 1))
else
  echo -e "${GREEN}PASS: All tools have .gitignore${NC}"
fi

# 5. Check for .env files that shouldn't be committed
echo ""
echo "5. Checking for committed .env files..."
ENV_FOUND=0
for tool in "$CLI_TOOLS_DIR"/*/; do
  tool_name=$(basename "$tool")
  if [ -d "$tool/.git" ] || [ -f "$tool/.git" ]; then
    TRACKED_ENV=$(cd "$tool" && git ls-files 2>/dev/null | grep -E '^\.env$' || true)
    if [ -n "$TRACKED_ENV" ]; then
      echo -e "${RED}FAIL: $tool_name has .env tracked in git${NC}"
      ENV_FOUND=$((ENV_FOUND + 1))
    fi
  fi
done

if [ $ENV_FOUND -eq 0 ]; then
  echo -e "${GREEN}PASS: No .env files tracked${NC}"
else
  ERRORS=$((ERRORS + ENV_FOUND))
fi

# 6. Check tools reference sibling tokens folder
echo ""
echo "6. Checking tools reference tokens folder..."
TOOLS_WITH_TOKEN_REF=0
while IFS= read -r tool; do
  if grep -qE '\.\./tokens|\.\.\/\.\.\/tokens' "$tool" 2>/dev/null; then
    TOOLS_WITH_TOKEN_REF=$((TOOLS_WITH_TOKEN_REF + 1))
  fi
done < <(find "$CLI_TOOLS_DIR" -path "*/src/*.ts" -type f 2>/dev/null)
echo "   Tools referencing tokens folder: $TOOLS_WITH_TOKEN_REF"

# Summary
echo ""
echo "========================================"
echo "SUMMARY"
echo "========================================"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
  echo -e "${GREEN}All checks passed!${NC}"
  exit 0
elif [ $ERRORS -eq 0 ]; then
  echo -e "${YELLOW}Passed with $WARNINGS warning(s)${NC}"
  exit 0
else
  echo -e "${RED}Failed with $ERRORS error(s) and $WARNINGS warning(s)${NC}"
  exit 1
fi
