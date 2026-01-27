# Git Submodule Usage

CLI tools are organized as Git submodules for independent versioning and selective cloning.

## Initial Clone

### Full Collection
```bash
git clone --recurse-submodules https://github.com/sftmlg/claude-code-cli-tools.git
```

### Single Tool Only
```bash
git clone https://github.com/sftmlg/{tool-name}.git
```

## After Cloning

If submodules appear empty:
```bash
git submodule update --init --recursive
```

## Updating Tools

### Pull All Changes
```bash
git pull && git submodule update --recursive
```

### Update Specific Tool
```bash
cd {tool-name}
git pull origin main
cd ..
git add {tool-name}
git commit -m "Update {tool-name}"
```

### Update All Submodules to Latest
```bash
git submodule update --remote --merge
```

## Working with Submodules

### Check Submodule Status
```bash
git submodule status
```

Output format:
- ` ` (space): Submodule at recorded commit
- `+`: Submodule ahead of recorded commit
- `-`: Submodule not initialized
- `U`: Submodule has merge conflicts

### Make Changes in Submodule
```bash
cd {tool-name}
# Make changes
git add .
git commit -m "Your changes"
git push origin main

# Update parent reference
cd ..
git add {tool-name}
git commit -m "Update {tool-name} reference"
```

## Common Workflows

### Add New Submodule
```bash
git submodule add https://github.com/sftmlg/{tool-name}.git {tool-name}
git commit -m "Add {tool-name} submodule"
```

### Remove Submodule
```bash
git submodule deinit -f {tool-name}
rm -rf .git/modules/{tool-name}
git rm -f {tool-name}
git commit -m "Remove {tool-name} submodule"
```

### Reset Submodule to Recorded Commit
```bash
git submodule update --init {tool-name}
```

## Push Safety Rule

**CRITICAL**: Always push submodule commits before parent commits.

Failure causes clone errors on other machines:
```
fatal: Could not resolve to a Repository: https://github.com/sftmlg/{tool-name}
```

### Validation Before Push
```bash
git submodule foreach --recursive 'UNPUSHED=$(git log origin/$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)..HEAD --oneline 2>/dev/null | wc -l); [ "$UNPUSHED" -gt 0 ] && echo "WARNING: $name has $UNPUSHED unpushed"'
```

### Push All Submodules First
```bash
git submodule foreach --recursive 'git push origin $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main) 2>/dev/null || true'
```

## Troubleshooting

### Submodule Not Initialized
```bash
git submodule update --init --recursive
```

### Detached HEAD in Submodule
```bash
cd {tool-name}
git checkout main
```

### Submodule Points to Non-existent Commit
```bash
# Reset to remote
cd {tool-name}
git fetch origin
git reset --hard origin/main
```

### Clone Fails with Submodule Error
```bash
# Clone without submodules first
git clone https://github.com/sftmlg/claude-code-cli-tools.git --no-recurse-submodules
cd claude-code-cli-tools

# Initialize submodules one by one
git submodule update --init {tool-name}
```

## Best Practices

1. **Always commit submodule changes before parent changes**
2. **Push submodules before pushing parent**
3. **Use `--recurse-submodules` for clone and pull**
4. **Check `git submodule status` before committing**
5. **Document submodule dependencies in README**
