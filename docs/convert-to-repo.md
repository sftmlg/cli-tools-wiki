# Converting Existing Code to Git Repository

Guide for taking existing tool code (not yet a repo) and making it a proper GitHub repository.

## When to Use

- You have a working tool that was developed locally
- The code exists but isn't tracked in git
- You want to add the tool to the collection

## Prerequisites

- Working tool code in a local folder
- GitHub CLI authenticated: `gh auth status`
- No sensitive data in the code (tokens, API keys)

## Step-by-Step Conversion

### Step 1: Prepare the Code

Before creating a repo, ensure the code is clean:

```bash
cd {existing-tool-folder}

# Remove any sensitive files
rm -f .env *.json tokens/* credentials*

# Remove build artifacts
rm -rf dist/ node_modules/ .pnpm-store/
```

### Step 2: Verify No Secrets

```bash
# Search for potential secrets
grep -rE 'AIzaSy|sk-|ghp_|password|secret|api.key' . \
  --include="*.ts" --include="*.js" --include="*.json"
```

If secrets found, remove them and use the config.ts pattern from [adding-tools.md](adding-tools.md).

### Step 3: Add Required Files

Ensure these files exist (copy templates from adding-tools.md):

```bash
# Check for required files
[ ! -f ".gitignore" ] && echo "Missing .gitignore"
[ ! -f "tsconfig.json" ] && echo "Missing tsconfig.json"
[ ! -f "README.md" ] && echo "Missing README.md"
[ ! -f "src/config.ts" ] && echo "Missing src/config.ts"
```

Add missing files using templates from [adding-tools.md](adding-tools.md#step-4-complete-file-templates).

### Step 4: Initialize Git Locally

```bash
# Initialize git
git init
git branch -m main

# Add all files
git add .

# Verify what will be committed
git status

# Make sure no secrets are staged!
git diff --cached --name-only | xargs grep -l "AIzaSy\|sk-\|ghp_\|password" 2>/dev/null
```

### Step 5: Create GitHub Repository

```bash
# Create repo and push
gh repo create sftmlg/{tool-name} --private \
  --description "CLI tool for {purpose}" \
  --source . \
  --push

# Add collaborator
gh api -X PUT "repos/sftmlg/{tool-name}/collaborators/stydav" -f permission=push
```

### Step 6: Verify Push

```bash
# Check repo exists and has content
gh repo view sftmlg/{tool-name}

# Verify no secrets in remote
gh api repos/sftmlg/{tool-name}/contents/src/config.ts | jq -r '.content' | base64 -d | grep -E 'AIzaSy|sk-|ghp_'
```

### Step 7: Add to Collection (Optional)

If this should be part of the tools collection:

```bash
# From parent repo root
cd /path/to/software-moling

# Add as submodule
git submodule add https://github.com/sftmlg/{tool-name}.git claude-code-cli-tools/{tool-name}

# Create token folder if needed
mkdir -p claude-code-cli-tools/tokens/{tool-name}

# Commit
git commit -m "Add {tool-name} to tools collection"
```

### Step 8: Update Inventory

Add to `cli-tools-wiki/tools/inventory.md`:

```markdown
| {tool-name} | {Description} | {Auth Type} |
```

---

## Quick Conversion Script

For a tool that already has proper structure:

```bash
#!/bin/bash
# Usage: ./convert-to-repo.sh {tool-folder} {repo-name} "{description}"

FOLDER=$1
NAME=$2
DESC=$3

cd "$FOLDER"

# Initialize
git init
git branch -m main

# Create repo and push
gh repo create "sftmlg/$NAME" --private --description "$DESC" --source . --push

# Add collaborator
gh api -X PUT "repos/sftmlg/$NAME/collaborators/stydav" -f permission=push

echo "Done! Repo: https://github.com/sftmlg/$NAME"
```

---

## Common Issues

### "fatal: not a git repository"

You're not in the right directory:
```bash
cd {tool-folder}
git init
```

### "error: src refance 'main': not found"

No commits yet:
```bash
git add .
git commit -m "Initial commit"
git push -u origin main
```

### Repository Already Exists

```bash
# Delete and recreate
gh repo delete sftmlg/{tool-name} --yes
gh repo create sftmlg/{tool-name} --private --source . --push
```

### Accidentally Pushed Secrets

```bash
# IMMEDIATELY rotate the compromised credentials

# Remove from git history
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch {file-with-secrets}" \
  --prune-empty --tag-name-filter cat -- --all

# Force push (requires confirmation)
git push origin --force --all
```

---

## Checklist

### Before Creating Repo
- [ ] No .env files in folder
- [ ] No token/credential files
- [ ] No hardcoded secrets in code
- [ ] .gitignore created with proper patterns
- [ ] README.md exists

### After Creating Repo
- [ ] Repo accessible at github.com/sftmlg/{name}
- [ ] Collaborators added (stydav)
- [ ] Inventory updated
- [ ] Security verification passes
- [ ] Tool works when cloned fresh

---

## Related

- [Adding Tools](adding-tools.md) - Full templates for new tools
- [Tool Maintenance](tool-maintenance.md) - Keeping tools healthy
- [Security Verification](../scripts/verify-security.sh) - Check for secrets
