# Restructuring Execution Plan v2 - TIGHTENED

**Scope:** Mechanical migration ONLY - rename, consolidate, test  
**Duration:** 2-3 hours (constrained scope)  
**Post-migration:** Pattern extraction is separate follow-on project

---

## GLOBAL ACCEPTANCE CRITERIA

**Migration is complete when ALL of these are true:**

- [ ] Repo builds/runs from clean checkout on fresh terminal
- [ ] All automated tests pass (validate-mcp.sh in both test projects)
- [ ] No references to "ClawdBot" except in git history and MIGRATION.md
- [ ] No absolute paths in configs (or documented exceptions in .env.example)
- [ ] README.md + QUICK_START.md exist and work
- [ ] mcp-deployment fully merged, original location can be deleted
- [ ] Rollback tested and documented
- [ ] iphone-tco-planner still deploys and validates

---

## PHASE 0: Dependency Inventory (15 min) - NEW

**Purpose:** Identify everything that breaks from rename/move

**Execute:**

```bash
cd /Users/jederlichman/Development/Projects/ClawdBot

# Find absolute paths
grep -r "/Users/jederlichman" . --exclude-dir=node_modules --exclude-dir=.git > DEPENDENCY_INVENTORY.txt

# Find ClawdBot references
grep -r "ClawdBot" . --exclude-dir=node_modules --exclude-dir=.git >> DEPENDENCY_INVENTORY.txt

# Find mcp-deployment references
grep -r "mcp-deployment" . --exclude-dir=node_modules --exclude-dir=.git >> DEPENDENCY_INVENTORY.txt

# Check for launch agents
ls ~/Library/LaunchAgents/*clawdbot* 2>/dev/null >> DEPENDENCY_INVENTORY.txt || true
ls ~/Library/LaunchAgents/*ClawdBot* 2>/dev/null >> DEPENDENCY_INVENTORY.txt || true

# Check for cron jobs
crontab -l | grep -i clawdbot >> DEPENDENCY_INVENTORY.txt 2>/dev/null || true

# Check for shell aliases
grep -i clawdbot ~/.zshrc >> DEPENDENCY_INVENTORY.txt 2>/dev/null || true
```

**Review DEPENDENCY_INVENTORY.txt and create must-update list:**

```
MUST UPDATE:
- [ ] File: [path] - Line: [#] - Reason: [absolute path / clawdbot ref]
- [ ] LaunchAgent: [name]
- [ ] Cron job: [description]
- [ ] Shell alias: [name]
```

**Success Criteria:**
- [ ] DEPENDENCY_INVENTORY.txt created
- [ ] Must-update list documented
- [ ] No surprises - know what will break

---

## PHASE 1: Preparation (20 min)

**1.1: Backups**
```bash
cd /Users/jederlichman/Development/Projects
cp -r ClawdBot ClawdBot-backup-$(date +%Y%m%d-%H%M)
cp -r /Users/jederlichman/Development/mcp-deployment mcp-deployment-backup-$(date +%Y%m%d-%H%M)

echo "Backups created at:"
ls -ld *backup*
```

**1.2: Create branch**
```bash
cd ClawdBot
git checkout -b restructure-to-dev-infrastructure
git add -A
git commit -m "Phase 1 checkpoint: Before restructure"
git log -1 --oneline
```

**Success Criteria:**
- [ ] Backups exist with timestamps
- [ ] Git branch created
- [ ] Clean working directory

---

## PHASE 2: Mechanical Migration (45 min)

**2.1: DRY RUN - List what will move**
```bash
cd /Users/jederlichman/Development/Projects

# Show rename operation
echo "WILL RENAME:"
echo "  ClawdBot → dev-infrastructure"
echo ""
echo "WILL CREATE:"
tree -L 1 -d ClawdBot | sed 's/ClawdBot/dev-infrastructure/g'
```

**2.2: Execute rename**
```bash
cd /Users/jederlichman/Development/Projects
mv ClawdBot dev-infrastructure
cd dev-infrastructure

# Checkpoint
git add -A
git commit -m "Phase 2.1: Renamed ClawdBot → dev-infrastructure"
```

**2.3: Create directory structure**
```bash
mkdir -p mcp/{scripts,templates,docs}
mkdir -p infrastructure/main-mac

# Checkpoint
git add -A
git commit -m "Phase 2.2: Created base directory structure"
```

**2.4: Merge mcp-deployment (with dry run)**
```bash
# DRY RUN
echo "WILL COPY:"
ls -la /Users/jederlichman/Development/mcp-deployment/

# Execute
cp -rv /Users/jederlichman/Development/mcp-deployment/scripts/* mcp/scripts/
cp -rv /Users/jederlichman/Development/mcp-deployment/docs/* mcp/docs/
cp -v /Users/jederlichman/Development/mcp-deployment/{README.md,CHANGELOG.md,DEPLOYMENT_FIXES.md} mcp/

# Checkpoint
git add -A
git commit -m "Phase 2.3: Merged mcp-deployment into mcp/"
```

**2.5: Update path references**
```bash
# Replace mcp-deployment references
find . -type f -not -path "*/node_modules/*" -not -path "*/.git/*" \
  -exec sed -i.bak 's|~/Development/mcp-deployment|~/Development/Projects/dev-infrastructure/mcp|g' {} \;

find . -type f -not -path "*/node_modules/*" -not -path "*/.git/*" \
  -exec sed -i.bak 's|/Users/jederlichman/Development/mcp-deployment|/Users/jederlichman/Development/Projects/dev-infrastructure/mcp|g' {} \;

# Remove backup files
find . -name "*.bak" -delete

# Checkpoint
git add -A
git commit -m "Phase 2.4: Updated path references"
```

**2.6: Replace absolute paths with relative/env vars**
```bash
# Create .env.example
cat > .env.example << 'EOF'
# Dev Infrastructure Environment Variables
# Copy to .env and customize

# Project root (auto-detected in scripts)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Main Mac hostname
MAIN_MAC_HOST="192.168.1.230"

# Remote Mac hostname  
REMOTE_MAC_HOST="192.168.1.245"

# MCP deployment path
MCP_PATH="${PROJECT_ROOT}/mcp"
EOF

# Checkpoint
git add .env.example
git commit -m "Phase 2.5: Added .env.example for path configuration"
```

**Success Criteria:**
- [ ] Repository renamed
- [ ] mcp-deployment merged
- [ ] Path references updated
- [ ] .env.example created
- [ ] All changes committed

---

## PHASE 3: Minimal Documentation (30 min)

**Scope:** Just enough to be functional - NOT full rewrite

**3.1: Create minimal README.md**
```bash
cat > README.md << 'EOF'
# dev-infrastructure

Distributed development infrastructure with MCP integration and multi-Mac coordination.

**Formerly:** ClawdBot project - renamed to reflect actual purpose

## Quick Start

Deploy MCP stack to a project:

```bash
cd ~/Development/Projects/your-project
bash ~/Development/Projects/dev-infrastructure/mcp/scripts/project-setup.sh your-project
```

## What's Included

- **mcp/** - MCP environment deployment system
- **infrastructure/** - Multi-Mac setup (main + tw-mac)
- **scripts/** - Automation and deployment
- **docs/** - Documentation (being reorganized)

## Projects Using This

- ✅ iphone-tco-planner
- ✅ dev-infrastructure (this repo)

## Migration Notes

This repo was renamed from ClawdBot to dev-infrastructure on [DATE].

See MIGRATION.md for details.

## Documentation

- MCP Deployment: `mcp/README.md`
- Multi-Mac Setup: `infrastructure/tw-mac/README.md`
- Full documentation reorganization: In progress

**Version:** 2.0.0
EOF

git add README.md
git commit -m "Phase 3.1: Created minimal README.md"
```

**3.2: Create MIGRATION.md**
```bash
cat > MIGRATION.md << 'EOF'
# Migration Guide: ClawdBot → dev-infrastructure

## What Changed

**Repository Name:**
- Old: `ClawdBot`
- New: `dev-infrastructure`

**Location:**
- Old: `/Users/jederlichman/Development/Projects/ClawdBot`
- New: `/Users/jederlichman/Development/Projects/dev-infrastructure`

**MCP Deployment:**
- Old: `/Users/jederlichman/Development/mcp-deployment` (separate repo)
- New: `/Users/jederlichman/Development/Projects/dev-infrastructure/mcp/`

## Update Your Projects

### If you reference old paths in scripts:

```bash
# Find references
grep -r "ClawdBot" your-project/
grep -r "mcp-deployment" your-project/

# Update to:
~/Development/Projects/dev-infrastructure/mcp/scripts/project-setup.sh
```

### If you have shell aliases:

```bash
# Update ~/.zshrc references from:
alias deploy-mcp='bash ~/Development/mcp-deployment/scripts/project-setup.sh'

# To:
alias deploy-mcp='bash ~/Development/Projects/dev-infrastructure/mcp/scripts/project-setup.sh'
```

## Rollback (if needed)

Backups created: `ClawdBot-backup-[TIMESTAMP]`

## Timeline

- Restructure: [DATE]
- Testing period: 30 days
- Old backup cleanup: [DATE + 30]
EOF

git add MIGRATION.md
git commit -m "Phase 3.2: Created MIGRATION.md"
```

**Success Criteria:**
- [ ] README.md exists and accurate
- [ ] MIGRATION.md documents changes
- [ ] No promises of features not yet delivered

---

## PHASE 4: Testing & Validation (45 min)

**4.1: Clean checkout test**
```bash
# Simulate fresh clone
cd ~/Development
mkdir -p test-clean-checkout
cd test-clean-checkout
cp -r ~/Development/Projects/dev-infrastructure .

cd dev-infrastructure
# Should be able to run scripts
ls -la mcp/scripts/project-setup.sh
```

**4.2: Deploy to test project**
```bash
mkdir -p ~/Development/test-restructure-deploy
cd ~/Development/test-restructure-deploy

bash ~/Development/Projects/dev-infrastructure/mcp/scripts/project-setup.sh test-restructure

# Validate
bash scripts/validate-mcp.sh
```

**Expected:** 8/8 tests pass

**4.3: Verify existing project still works**
```bash
cd /Users/jederlichman/Development/Projects/iphone-tco-planner
bash scripts/validate-mcp.sh
```

**Expected:** Still passes

**4.4: Test in Antigravity**
- Open test project in Antigravity
- Verify MCP panel shows servers
- Test one MCP operation

**4.5: Document test results**
```bash
cd ~/Development/Projects/dev-infrastructure

cat > TEST_RESULTS.md << EOF
# Restructure Test Results

**Date:** $(date)

## Clean Checkout Test
- [ ] Pass/Fail
- Notes:

## Test Deploy
- [ ] Pass/Fail  
- Validation: X/8 tests passed
- Notes:

## Existing Project (iphone-tco-planner)
- [ ] Pass/Fail
- Validation: X/8 tests passed
- Notes:

## Antigravity Test
- [ ] Pass/Fail
- MCP servers visible: Yes/No
- Notes:

## Issues Found
[List any issues]

## Overall Status
[PASS / FAIL / NEEDS FIXES]
EOF

git add TEST_RESULTS.md
git commit -m "Phase 4: Test results documented"
```

**Success Criteria:**
- [ ] Clean checkout works
- [ ] Test deployment passes validation
- [ ] Existing projects unaffected
- [ ] Antigravity integration works
- [ ] TEST_RESULTS.md completed

---

## PHASE 5: Rollback Verification (15 min)

**Test that rollback works** (don't actually rollback unless needed)

**5.1: Document rollback procedure**
```bash
cat > ROLLBACK.md << 'EOF'
# Rollback Procedure

If restructure needs to be reversed:

## Step 1: Restore from backup

```bash
cd ~/Development/Projects

# Remove restructured version
rm -rf dev-infrastructure

# Restore ClawdBot backup
cp -r ClawdBot-backup-[TIMESTAMP] ClawdBot
```

## Step 2: Restore mcp-deployment

```bash
# Remove symlinks if any
rm ~/Development/mcp-deployment-redirect

# Restore mcp-deployment backup
cp -r ~/Development/mcp-deployment-backup-[TIMESTAMP] ~/Development/mcp-deployment
```

## Step 3: Reset git

```bash
cd ~/Development/Projects/ClawdBot
git checkout main
git branch -D restructure-to-dev-infrastructure
```

## Step 4: Verify

```bash
cd ~/Development/Projects/ClawdBot
git status
ls -la

cd ~/Development/mcp-deployment
ls -la
```

## Tested: [YES/NO]
EOF

git add ROLLBACK.md
git commit -m "Phase 5: Documented rollback procedure"
```

**Success Criteria:**
- [ ] Rollback procedure documented
- [ ] Understand how to revert if needed

---

## PHASE 6: Finalize & Tag (15 min)

**6.1: Final commit**
```bash
cd ~/Development/Projects/dev-infrastructure

git add -A
git commit -m "Phase 6: Restructure complete - v2.0.0

BREAKING CHANGES:
- Renamed ClawdBot → dev-infrastructure
- Merged mcp-deployment into mcp/ subdirectory
- Updated all path references

SCOPE:
- Mechanical migration only
- Pattern extraction deferred to follow-on

TESTED:
- Clean checkout: PASS
- Test deploy: PASS
- Existing projects: PASS
- Antigravity: PASS

See MIGRATION.md and TEST_RESULTS.md for details"
```

**6.2: Tag release**
```bash
git tag -a v2.0.0 -m "v2.0.0: Restructured as dev-infrastructure

Mechanical migration complete and tested.
Pattern extraction and documentation reorganization
will be handled in v2.1.0+"
```

**6.3: Push** (if remote exists)
```bash
# Check if remote exists
git remote -v

# If remote exists:
git push origin restructure-to-dev-infrastructure
git push origin v2.0.0
```

**Success Criteria:**
- [ ] Final commit includes all changes
- [ ] v2.0.0 tagged with clear message
- [ ] Pushed to remote (if applicable)

---

## POST-MIGRATION: Transition Period (30 days)

**Immediate (Day 1):**

```bash
# Create symlink for gradual transition
ln -s ~/Development/Projects/dev-infrastructure/mcp ~/Development/mcp-deployment-redirect

# Add to .zshrc
echo "# Temporary redirect during restructure (remove after 30 days)" >> ~/.zshrc
echo "alias old-mcp='echo \"mcp-deployment moved to: ~/Development/Projects/dev-infrastructure/mcp/\"'" >> ~/.zshrc
```

**Week 2:**
- Monitor for issues
- Update any discovered dependencies
- Document lessons learned

**Day 30:**
- Remove backups if no issues
- Remove symlinks
- Remove transition aliases
- Mark migration complete

---

## PHASE 7 (FUTURE): Pattern Extraction

**Separate project - DO NOT include in migration:**

- Extract Antigravity patterns
- Create reference examples
- Rebuild comprehensive documentation
- Create templates

**Estimated:** 3-4 hours as separate effort

**Plan:** Create separate GitHub issue/plan

---

## EXECUTION LOG

**Use this space to record deviations from plan:**

```
[Timestamp] - Phase X - Issue: [description] - Resolution: [what you did]
```

---

## DECISION LOG

**Record any decisions made during execution:**

```
[Timestamp] - Decision: [what] - Rationale: [why]
```

---

## FINAL CHECKLIST - Global Acceptance

- [ ] Repo builds/runs from clean checkout
- [ ] All automated tests pass
- [ ] No "ClawdBot" refs except history/MIGRATION.md
- [ ] No absolute paths (or documented in .env.example)
- [ ] README.md + MIGRATION.md exist
- [ ] mcp-deployment fully merged
- [ ] Rollback tested and documented
- [ ] iphone-tco-planner still works
- [ ] v2.0.0 tagged
- [ ] TEST_RESULTS.md shows PASS

**When ALL checked:** Migration complete ✅

---

**Duration:** 2-3 hours (constrained scope)  
**Risk:** LOW (mechanical changes, well-tested, rollback ready)  
**Follow-on:** Pattern extraction (v2.1.0+)
