#!/bin/bash
# Tools Maintenance Script
# Comprehensive health check for CLI tools collection
#
# Usage:
#   ./maintenance.sh                    # Run from tools directory
#   ./maintenance.sh /path/to/tools     # Specify path
#   ./maintenance.sh --quick            # Quick check only

set -e

# Determine tools directory
if [ -n "$1" ] && [ "$1" != "--quick" ]; then
  TOOLS_DIR="$1"
  shift
elif [ -d "./email-manager" ] || [ -d "./calendar-manager" ]; then
  TOOLS_DIR="."
else
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  TOOLS_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")/tools"
fi

QUICK_MODE=false
[ "$1" = "--quick" ] && QUICK_MODE=true

if [ ! -d "$TOOLS_DIR" ]; then
  echo "Error: Tools directory not found: $TOOLS_DIR"
  echo "Usage: $0 [path/to/tools] [--quick]"
  exit 1
fi

TOOLS_DIR="$(cd "$TOOLS_DIR" && pwd)"
TOKENS_DIR="$(dirname "$TOOLS_DIR")/tokens"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

echo "========================================"
echo "CLI Tools Maintenance Check"
echo "========================================"
echo "Tools: $TOOLS_DIR"
echo "Tokens: $TOKENS_DIR"
echo "Mode: $([ "$QUICK_MODE" = true ] && echo 'Quick' || echo 'Full')"
echo ""

# 1. Security Check
echo -e "${BLUE}1. Security Verification${NC}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/verify-security.sh" ]; then
  if "$SCRIPT_DIR/verify-security.sh" "$TOOLS_DIR" > /tmp/security-check.txt 2>&1; then
    echo -e "   ${GREEN}✓ Security check passed${NC}"
  else
    echo -e "   ${RED}✗ Security check failed${NC}"
    cat /tmp/security-check.txt | grep -E "FAIL|WARN" | head -5
    ERRORS=$((ERRORS + 1))
  fi
else
  echo -e "   ${YELLOW}⚠ verify-security.sh not found${NC}"
  WARNINGS=$((WARNINGS + 1))
fi

# 2. Git Status
echo ""
echo -e "${BLUE}2. Git Status${NC}"
UNCOMMITTED=0
for tool in "$TOOLS_DIR"/*/; do
  tool_name=$(basename "$tool")
  [ "$tool_name" = "tokens" ] && continue
  [ "$tool_name" = "scripts" ] && continue

  if [ -d "$tool/.git" ] || [ -f "$tool/.git" ]; then
    status=$(cd "$tool" && git status --porcelain 2>/dev/null | wc -l)
    if [ "$status" -gt 0 ]; then
      echo -e "   ${YELLOW}⚠ $tool_name has $status uncommitted changes${NC}"
      UNCOMMITTED=$((UNCOMMITTED + 1))
    fi
  fi
done

if [ $UNCOMMITTED -eq 0 ]; then
  echo -e "   ${GREEN}✓ All tools clean${NC}"
else
  echo -e "   ${YELLOW}⚠ $UNCOMMITTED tools have uncommitted changes${NC}"
  WARNINGS=$((WARNINGS + UNCOMMITTED))
fi

# 3. Token Structure
echo ""
echo -e "${BLUE}3. Token Structure${NC}"
if [ -d "$TOKENS_DIR" ]; then
  echo -e "   ${GREEN}✓ tokens/ exists${NC}"

  # Check credentials.json
  if [ -f "$TOKENS_DIR/credentials.json" ]; then
    echo -e "   ${GREEN}✓ credentials.json present${NC}"
  else
    echo -e "   ${YELLOW}⚠ credentials.json missing${NC}"
    WARNINGS=$((WARNINGS + 1))
  fi

  # Count token folders
  token_count=$(find "$TOKENS_DIR" -maxdepth 1 -type d | wc -l)
  token_count=$((token_count - 1))
  echo "   Token folders: $token_count"
else
  echo -e "   ${RED}✗ tokens/ not found${NC}"
  ERRORS=$((ERRORS + 1))
fi

# 4. Structure Verification
echo ""
echo -e "${BLUE}4. Tool Structure${NC}"
MISSING_FILES=0
for tool in "$TOOLS_DIR"/*/; do
  tool_name=$(basename "$tool")
  [ "$tool_name" = "tokens" ] && continue
  [ "$tool_name" = "scripts" ] && continue
  [ "$tool_name" = "_metadata" ] && continue

  if [ -d "$tool/.git" ] || [ -f "$tool/.git" ]; then
    missing=""
    [ ! -f "$tool/package.json" ] && missing="$missing package.json"
    [ ! -f "$tool/.gitignore" ] && missing="$missing .gitignore"
    [ ! -f "$tool/README.md" ] && missing="$missing README.md"

    if [ -n "$missing" ]; then
      echo -e "   ${YELLOW}⚠ $tool_name missing:$missing${NC}"
      MISSING_FILES=$((MISSING_FILES + 1))
    fi
  fi
done

if [ $MISSING_FILES -eq 0 ]; then
  echo -e "   ${GREEN}✓ All tools have required files${NC}"
else
  WARNINGS=$((WARNINGS + MISSING_FILES))
fi

if [ "$QUICK_MODE" = false ]; then
  # 5. Dependency Health
  echo ""
  echo -e "${BLUE}5. Dependency Health${NC}"
  OUTDATED=0
  for tool in "$TOOLS_DIR"/*/; do
    tool_name=$(basename "$tool")
    [ "$tool_name" = "tokens" ] && continue
    [ "$tool_name" = "scripts" ] && continue

    if [ -f "$tool/package.json" ]; then
      if [ ! -d "$tool/node_modules" ]; then
        echo -e "   ${YELLOW}⚠ $tool_name: node_modules missing (run pnpm install)${NC}"
        OUTDATED=$((OUTDATED + 1))
      fi
    fi
  done

  if [ $OUTDATED -eq 0 ]; then
    echo -e "   ${GREEN}✓ All dependencies installed${NC}"
  else
    WARNINGS=$((WARNINGS + OUTDATED))
  fi

  # 6. Large Files
  echo ""
  echo -e "${BLUE}6. Large Files Check${NC}"
  large_files=$(find "$TOOLS_DIR" -type f -size +5M \
    -not -path "*/node_modules/*" \
    -not -path "*/.git/*" 2>/dev/null | wc -l)

  if [ "$large_files" -gt 0 ]; then
    echo -e "   ${YELLOW}⚠ Found $large_files files >5MB${NC}"
    find "$TOOLS_DIR" -type f -size +5M \
      -not -path "*/node_modules/*" \
      -not -path "*/.git/*" 2>/dev/null | head -3
    WARNINGS=$((WARNINGS + 1))
  else
    echo -e "   ${GREEN}✓ No large files${NC}"
  fi

  # 7. Inventory Check
  echo ""
  echo -e "${BLUE}7. Inventory Sync${NC}"
  WIKI_DIR="$(dirname "$SCRIPT_DIR")"
  INVENTORY="$WIKI_DIR/tools/inventory.md"

  if [ -f "$INVENTORY" ]; then
    missing_from_inventory=0
    for tool in "$TOOLS_DIR"/*/; do
      tool_name=$(basename "$tool")
      [ "$tool_name" = "tokens" ] && continue
      [ "$tool_name" = "scripts" ] && continue
      [ "$tool_name" = "_metadata" ] && continue

      if [ -d "$tool/.git" ] || [ -f "$tool/.git" ]; then
        if ! grep -q "$tool_name" "$INVENTORY" 2>/dev/null; then
          echo -e "   ${YELLOW}⚠ $tool_name not in inventory${NC}"
          missing_from_inventory=$((missing_from_inventory + 1))
        fi
      fi
    done

    if [ $missing_from_inventory -eq 0 ]; then
      echo -e "   ${GREEN}✓ Inventory up to date${NC}"
    else
      WARNINGS=$((WARNINGS + missing_from_inventory))
    fi
  else
    echo -e "   ${YELLOW}⚠ Inventory file not found${NC}"
    WARNINGS=$((WARNINGS + 1))
  fi
fi

# Summary
echo ""
echo "========================================"
echo "SUMMARY"
echo "========================================"

tool_count=$(find "$TOOLS_DIR" -maxdepth 1 -type d \( -name "*.git" -prune -o -print \) | wc -l)
tool_count=$((tool_count - 1))
echo "Tools scanned: $tool_count"

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
