# Restructuring Plan - REVISED (Tightened Scope)

## Decision: Two-Phase Approach

**Phase A (This Session):** Mechanical Migration - 2 hours
**Phase B (Future Session):** Pattern Extraction & Polish - 2-3 hours

---

## PHASE A: MECHANICAL MIGRATION (Execute Now)

**Goal:** Rename + Consolidate + Validate
**Time:** 2 hours
**Risk:** Low (fully reversible)

### Global Acceptance Criteria

- [ ] Repo renamed and consolidates mcp-deployment
- [ ] All tests pass from clean checkout
- [ ] No hardcoded absolute paths (except documented)
- [ ] iphone-tco-planner still deploys successfully
- [ ] Rollback verified workable
- [ ] All references to "ClawdBot" updated or allowlisted
- [ ] README updated with new name and purpose

---

## Phase 0: Pre-Flight (15 minutes)

### Step 0.1: Dependency Inventory

**Create dependency map BEFORE touching anything:**

```bash
cd ~/Development/Projects/dev-infrastructure

# Find all absolute paths
grep -r "/Users/jederlichman" . --exclude-dir={node_modules,.git} > DEPENDENCY_INVENTORY.txt

# Find all "ClawdBot" references
grep -r "ClawdBot" . --exclude-dir={node_modules,.git} >> DEPENDENCY_INVENTORY.txt

# Find all mcp-deployment references
grep -r "mcp-deployment" . --exclude-dir={node_modules,.git} >> DEPENDENCY_INVENTORY.txt

# Review the inventory
cat DEPENDENCY_INVENTORY.txt
```

**Expected inventory items:**
- `.envrc` - PROJECT_ROOT path
- `scripts/*` - May reference absolute paths
- `docs/*` - References to repo location
- `.antigravity/config.json` - workspaceFolder variable (OK)

**Document in DEPENDENCY_INVENTORY.txt:**
```
MUST UPDATE:
- .envrc: PROJECT_ROOT (use relative or detect)
- scripts/agy-shell-integration.sh: Source path
- docs/: All absolute path references

SAFE TO KEEP:
- .antigravity/config.json: ${workspaceFolder} (IDE variable)
- Git history references (historical)
```

### Step 0.2: Backup Everything

```bash
cd /Users/jederlichman/Development/Projects
cp -r ClawdBot ClawdBot-backup-$(date +%Y%m%d-%H%M)
cp -r ~/Development/Projects/dev-infrastructure/mcp mcp-deployment-backup-$(date +%Y%m%d-%H%M)

# Verify backups
ls -ld *backup*
```

### Step 0.3: Create Migration Branch

```bash
cd ClawdBot
git checkout -b phase-a-mechanical-migration
git add -A
git commit -m "Pre-migration checkpoint"
git log --oneline -1  # Verify commit
```

**✅ Phase 0 Complete** - Safe to proceed

---

## Phase 1: Rename Repository (10 minutes)

### Step 1.1: Rename Folder

```bash
cd /Users/jederlichman/Development/Projects
mv ClawdBot dev-infrastructure
cd dev-infrastructure

# Verify
pwd  # Should show: .../Projects/dev-infrastructure
```

### Step 1.2: Update Git Remote (if applicable)

```bash
# If you have a remote, update it later
# For now, just local rename
```

### Step 1.3: Checkpoint Commit

```bash
git add -A
git commit -m "Phase 1: Rename ClawdBot → dev-infrastructure (folder only)"
```

**✅ Phase 1 Complete** - Repository renamed

---

## Phase 2: Consolidate mcp-deployment (20 minutes)

### Step 2.1: Create mcp/ Directory

```bash
cd /Users/jederlichman/Development/Projects/dev-infrastructure
mkdir -p mcp/{scripts,templates,docs}
```

### Step 2.2: Copy (Not Move) mcp-deployment Content

**Use cp instead of mv to keep original intact:**

```bash
# Scripts
cp ~/Development/Projects/dev-infrastructure/mcp/scripts/* mcp/scripts/

# Documentation  
cp ~/Development/Projects/dev-infrastructure/mcp/docs/* mcp/docs/ 2>/dev/null || true

# Root files
cp ~/Development/Projects/dev-infrastructure/mcp/README.md mcp/
cp ~/Development/Projects/dev-infrastructure/mcp/CHANGELOG.md mcp/

# Templates
cp -r ~/Development/Projects/dev-infrastructure/mcp/templates/* mcp/templates/ 2>/dev/null || true
```

### Step 2.3: Verify Copy

```bash
# Verify key files copied
ls -la mcp/scripts/project-setup.sh
ls -la mcp/scripts/global-setup.sh
ls -la mcp/README.md

# Count files
find mcp/ -type f | wc -l
```

### Step 2.4: Checkpoint Commit

```bash
git add mcp/
git commit -m "Phase 2: Consolidate mcp-deployment into mcp/"
```

**✅ Phase 2 Complete** - mcp-deployment merged

---

## Phase 3: Update Path References (30 minutes)

### Step 3.1: Create Path Update Script

```bash
cat > scripts/update-paths.sh << 'EOF'
#!/usr/bin/env bash
# Update all path references

# Update mcp-deployment paths
find . -type f -not -path "*/node_modules/*" -not -path "*/.git/*" \
  -exec sed -i.bak 's|~/Development/Projects/dev-infrastructure/mcp|~/Development/Projects/dev-infrastructure/mcp|g' {} \;

# Update ClawdBot references in paths
find . -type f -not -path "*/node_modules/*" -not -path "*/.git/*" \
  -exec sed -i.bak 's|~/Development/Projects/dev-infrastructure|~/Development/Projects/dev-infrastructure|g' {} \;

# Clean up .bak files
find . -name "*.bak" -delete

echo "✅ Path references updated"
EOF

chmod +x scripts/update-paths.sh
```

### Step 3.2: Run Path Updates

```bash
bash scripts/update-paths.sh
```

### Step 3.3: Manual Review of Critical Files

```bash
# Review .envrc
cat .envrc | grep PROJECT_ROOT

# Review shell integration
cat scripts/agy-shell-integration.sh 2>/dev/null | grep -i clawdbot

# Review any docs
grep -r "ClawdBot" docs/ --exclude-dir=archive 2>/dev/null | head -10
```

### Step 3.4: Update .envrc to Use Detection

```bash
# Make PROJECT_ROOT self-detecting
cat > .envrc << 'EOF'
#!/usr/bin/env bash

# Auto-detect project root
export PROJECT_NAME="dev-infrastructure"
export PROJECT_ROOT="$(pwd)"

detect_docker_socket

# 1Password credential loading (update vault references as needed)
op_export GITHUB_TOKEN "op://Development/GitHub Token/credential"
op_export OPENAI_API_KEY "op://Development/OpenAI/api_key"
op_export GEMINI_API_KEY "op://Development/Gemini/api_key"

export DC_LOG_LEVEL="info"
export DC_CONFIG_DIR="$PROJECT_ROOT/config"
EOF
```

### Step 3.5: Checkpoint Commit

```bash
git add -A
git commit -m "Phase 3: Update path references and remove hardcoding"
```

**✅ Phase 3 Complete** - Paths updated

---

## Phase 4: Update README (Minimal) (15 minutes)

### Step 4.1: Create New README

```bash
cat > README.md << 'EOF'
# Distributed Development Infrastructure

Multi-machine development environment with MCP integration, Antigravity IDE patterns, and distributed compute.

## What This Provides

1. **MCP Deployment System** - Deploy standardized MCP stack to projects
2. **Multi-Mac Infrastructure** - Main Mac + tw-mac coordination  
3. **Antigravity Integration** - IDE configuration patterns

## Quick Start

Deploy MCP stack to a project:

```bash
cd ~/Development/Projects/your-project
bash ~/Development/Projects/dev-infrastructure/mcp/scripts/project-setup.sh your-project
```

Verify:

```bash
bash scripts/validate-mcp.sh
```

## Structure

- `mcp/` - MCP deployment system (formerly separate mcp-deployment repo)
- `infrastructure/tw-mac/` - Remote Mac setup and automation
- `scripts/` - Global automation and shell integration
- `docs/` - Documentation and guides

## Projects Using This Stack

- ✅ iphone-tco-planner
- ✅ dev-infrastructure (this repo as reference)

## Version

**Version:** 2.0.0-alpha  
**Status:** Migration in progress

**Previously:** ClawdBot Docker wrapper  
**Now:** Distributed development infrastructure
EOF
```

### Step 4.2: Create MIGRATION.md

```bash
cat > MIGRATION.md << 'EOF'
# Migration Guide

## What Changed

**Repository renamed:** ClawdBot → dev-infrastructure

**Consolidated:** mcp-deployment merged into `mcp/` subdirectory

## Path Updates

### Old Paths:
```
~/Development/Projects/dev-infrastructure
~/Development/Projects/dev-infrastructure/mcp
```

### New Paths:
```
/Users/jederlichman/Development/Projects/dev-infrastructure
/Users/jederlichman/Development/Projects/dev-infrastructure/mcp/
```

## Update Your Projects

If you referenced old paths:

```bash
# Update shell aliases
# Old: alias deploy-mcp='bash ~/Development/mcp-deployment/scripts/project-setup.sh'
# New: alias deploy-mcp='bash ~/Development/Projects/dev-infrastructure/mcp/scripts/project-setup.sh'

# Update existing projects (if they hardcoded paths)
cd your-project
# Check for old references
grep -r "mcp-deployment" .
grep -r "ClawdBot" .
```

## Rollback

Backups available at:
- `ClawdBot-backup-YYYYMMDD-HHMM/`
- `mcp-deployment-backup-YYYYMMDD-HHMM/`

## Questions?

See RESTRUCTURE_PLAN.md for full details.
EOF
```

### Step 4.3: Checkpoint Commit

```bash
git add README.md MIGRATION.md
git commit -m "Phase 4: Update README and create MIGRATION guide"
```

**✅ Phase 4 Complete** - Minimal docs updated

---

## Phase 5: Validation (30 minutes)

### Step 5.1: Clean Checkout Test

```bash
# Test from fresh clone simulation
cd /Users/jederlichman/Development
git clone /Users/jederlichman/Development/Projects/dev-infrastructure dev-infrastructure-test
cd dev-infrastructure-test

# Switch to migration branch
git checkout phase-a-mechanical-migration

# Verify structure
ls -la mcp/scripts/project-setup.sh
ls -la infrastructure/tw-mac/
```

### Step 5.2: Deploy to Test Project

```bash
mkdir -p ~/Development/test-migration-validation
cd ~/Development/test-migration-validation

# Deploy using new path
bash ~/Development/Projects/dev-infrastructure/mcp/scripts/project-setup.sh test-migration

# Should create all files
ls -la .antigravity/config.json
ls -la scripts/mcp-*
```

### Step 5.3: Validate Test Deployment

```bash
bash scripts/validate-mcp.sh
# Must pass 8/8 tests
```

### Step 5.4: Verify iphone-tco-planner Still Works

```bash
cd /Users/jederlichman/Development/Projects/iphone-tco-planner
bash scripts/validate-mcp.sh
# Must still pass
```

### Step 5.5: Test Rollback

```bash
# Don't actually rollback, just verify process works
cd /Users/jederlichman/Development/Projects

# Verify backups exist and are complete
ls -ld ClawdBot-backup*
ls -ld mcp-deployment-backup*

# Verify they contain expected files
ls ClawdBot-backup*/scripts/ | head
ls mcp-deployment-backup*/scripts/ | head
```

**✅ Phase 5 Complete** - All validations pass

---

## Phase 6: Finalize (15 minutes)

### Step 6.1: Create Allowlist for "ClawdBot"

```bash
cat > CLAWDBOT_REFERENCES_ALLOWLIST.txt << 'EOF'
# Acceptable "ClawdBot" references (historical/legacy)

Git history: OK - historical commits
docs/archive/: OK - archived documentation  
MIGRATION.md: OK - explaining the rename
CHANGELOG.md: OK - version history
README.md: OK - "Previously: ClawdBot"

All other references should be updated or removed.
EOF
```

### Step 6.2: Verify No Unwanted References

```bash
# Find remaining ClawdBot references
grep -r "ClawdBot" . --exclude-dir={node_modules,.git,*backup*} \
  --exclude="*.md" --exclude="CLAWDBOT_REFERENCES_ALLOWLIST.txt"

# Should return minimal results (git history, allowlisted files)
```

### Step 6.3: Create Temporary Symlink

```bash
# For transition period, create symlink for old mcp-deployment path
cd /Users/jederlichman/Development
ln -s Projects/dev-infrastructure/mcp mcp-deployment-redirect

# Document in MIGRATION.md
echo "
## Temporary Symlink (30-day transition)

A symlink exists at ~/Development/mcp-deployment-redirect pointing to
the new location. This will be removed after 30 days.
" >> ~/Development/Projects/dev-infrastructure/MIGRATION.md
```

### Step 6.4: Final Commit

```bash
cd ~/Development/Projects/dev-infrastructure
git add -A
git commit -m "Phase 6: Finalize mechanical migration

✅ Repository renamed: ClawdBot → dev-infrastructure
✅ mcp-deployment consolidated into mcp/
✅ All paths updated and validated
✅ Clean checkout tested
✅ Existing projects still work
✅ Rollback verified

See MIGRATION.md for details."
```

### Step 6.5: Tag Alpha Release

```bash
git tag -a v2.0.0-alpha -m "v2.0.0-alpha: Mechanical migration complete

Repository renamed and consolidated.
Pattern extraction and documentation polish deferred to Phase B."
```

**✅ Phase 6 Complete** - Migration finalized

---

## Phase A Complete - Decision Point

### What We Accomplished

✅ Repository renamed: ClawdBot → dev-infrastructure
✅ mcp-deployment consolidated into mcp/
✅ All hardcoded paths removed/updated
✅ Validated with clean checkout
✅ Existing projects still work
✅ Rollback verified workable

### What We Deferred to Phase B

- Extract Antigravity patterns into antigravity/
- Create reference examples in examples/
- Rebuild comprehensive documentation
- Create master deployment script

### Global Acceptance Criteria Status

- [x] Repo renamed and consolidates mcp-deployment
- [x] All tests pass from clean checkout
- [x] No hardcoded absolute paths (except documented)
- [x] iphone-tco-planner still deploys successfully
- [x] Rollback verified workable
- [x] README updated with new name and purpose
- [ ] Pattern extraction (Phase B)
- [ ] Full documentation (Phase B)

### Safe to Push?

```bash
# Review all changes
git log --oneline phase-a-mechanical-migration

# Push when ready
git push origin phase-a-mechanical-migration
git push origin v2.0.0-alpha
```

### Clean Up Test Artifacts

```bash
# Remove test project
rm -rf ~/Development/test-migration-validation
rm -rf ~/Development/dev-infrastructure-test
```

---

## PHASE B: PATTERN EXTRACTION (Future Session)

**To be executed separately after Phase A is stable**

Scope:
- Extract Antigravity patterns
- Create reference examples
- Rebuild comprehensive documentation  
- Polish and refine

Timeline: 2-3 hours in separate session

---

## Rollback Procedure (If Needed)

```bash
# 1. Remove new repo
cd /Users/jederlichman/Development/Projects
rm -rf dev-infrastructure

# 2. Restore from backup
mv ClawdBot-backup-YYYYMMDD-HHMM ClawdBot
mv mcp-deployment-backup-YYYYMMDD-HHMM ~/Development/Projects/dev-infrastructure/mcp

# 3. Verify restoration
cd ClawdBot
git status
git log --oneline -5

# 4. Test
bash scripts/validate-mcp.sh
```

---

## Success Metrics

**Phase A considered successful when:**
- [ ] All 6 phases completed
- [ ] All global acceptance criteria met
- [ ] Clean checkout test passes
- [ ] No deployment failures in existing projects
- [ ] Rollback tested and documented
- [ ] v2.0.0-alpha tagged

**Time Budget:** 2 hours (vs 4-5 for full restructure)
**Risk Level:** LOW (fully reversible, no pattern extraction complexity)
