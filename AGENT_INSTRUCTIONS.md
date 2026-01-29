# Agent Instructions: Phase A Mechanical Migration

## Mission Brief

Execute the mechanical migration of ClawdBot → dev-infrastructure. This is a **rename and consolidate operation ONLY**. No pattern extraction, no documentation overhaul - just clean mechanical changes.

**Your Role:** Execute Phase A checklist step-by-step  
**Your Success:** All global acceptance criteria checked  
**Your Safety Net:** Full backups + git branch + rollback plan

---

## CRITICAL: Read This First

### What You're Doing

1. Renaming repository: ClawdBot → dev-infrastructure
2. Consolidating mcp-deployment into mcp/ subdirectory
3. Updating all path references
4. Validating everything still works

### What You're NOT Doing (Phase B - Future)

❌ Extracting Antigravity patterns
❌ Creating reference examples
❌ Rebuilding comprehensive documentation
❌ Creating new automation scripts

**If you find yourself doing "extra" work, STOP. That's Phase B.**

---

## Your Checklist: PHASE_A_CHECKLIST.md

**Location:** `~/Development/Projects/dev-infrastructure/PHASE_A_CHECKLIST.md`

This is your step-by-step execution guide. Follow it exactly.

---

## Quick Reference: 6 Phases

```
Phase 0: Pre-Flight            [15 min] - Dependency inventory + backups
Phase 1: Rename Repository     [10 min] - mv ClawdBot → dev-infrastructure  
Phase 2: Consolidate           [20 min] - Merge mcp-deployment into mcp/
Phase 3: Update Paths          [30 min] - Remove hardcoded paths
Phase 4: Update README         [15 min] - Minimal documentation
Phase 5: Validation            [30 min] - Test everything
Phase 6: Finalize              [15 min] - Commit, tag v2.0.0-alpha

Total: ~2 hours
```

---

## Global Acceptance Criteria (Your "Done" Bar)

**Phase A is complete ONLY when ALL of these are true:**

- [ ] Repository renamed and consolidates mcp-deployment
- [ ] All tests pass from clean checkout
- [ ] No hardcoded absolute paths (except documented in .env.example)
- [ ] iphone-tco-planner still deploys successfully
- [ ] Rollback procedure verified workable
- [ ] README.md updated with new name and purpose

**If ANY is unchecked, Phase A is NOT complete.**

---

## Critical Commands Reference

### Phase 0: Dependency Inventory

```bash
cd ~/Development/Projects/dev-infrastructure

# Find all absolute paths
grep -r "/Users/jederlichman" . --exclude-dir={node_modules,.git} > DEPENDENCY_INVENTORY.txt

# Find all ClawdBot references
grep -r "ClawdBot" . --exclude-dir={node_modules,.git} >> DEPENDENCY_INVENTORY.txt

# Find all mcp-deployment references  
grep -r "mcp-deployment" . --exclude-dir={node_modules,.git} >> DEPENDENCY_INVENTORY.txt

# Review
cat DEPENDENCY_INVENTORY.txt
```

### Backup Commands

```bash
cd /Users/jederlichman/Development/Projects
cp -r ClawdBot ClawdBot-backup-$(date +%Y%m%d-%H%M)
cp -r ~/Development/Projects/dev-infrastructure/mcp mcp-deployment-backup-$(date +%Y%m%d-%H%M)
```

### Test Commands

```bash
# Test new deployment
mkdir -p ~/Development/test-migration-validation
cd ~/Development/test-migration-validation
bash ~/Development/Projects/dev-infrastructure/mcp/scripts/project-setup.sh test-migration
bash scripts/validate-mcp.sh  # MUST: 8/8 pass

# Test existing project
cd /Users/jederlichman/Development/Projects/iphone-tco-planner
bash scripts/validate-mcp.sh  # MUST: still pass
```

---

## Checkpoint Strategy

**After EACH phase:**

```bash
git add -A
git commit -m "Phase X: [description]"
git log --oneline -1  # Verify
```

**Why:** Makes rollback trivial - just `git reset --hard` to previous checkpoint

---

## Red Flags - When to STOP

**STOP and report if:**

1. **Any test fails** - Don't proceed to next phase
2. **Clean checkout doesn't work** - Hidden dependency issue
3. **iphone-tco-planner breaks** - Path update problem
4. **Can't find backup files** - Safety net missing
5. **DEPENDENCY_INVENTORY.txt shows surprises** - Unknown dependencies

**When you stop:** Document in EXECUTION_LOG what failed, don't try to fix it yourself.

---

## Validation Gates

### After Phase 2 (Consolidate)

```bash
# Verify mcp-deployment copied successfully
ls -la mcp/scripts/project-setup.sh
ls -la mcp/README.md
find mcp/ -type f | wc -l  # Should be ~10-20 files
```

### After Phase 3 (Path Updates)

```bash
# No absolute paths should remain
grep -r "~/Development/Projects/dev-infrastructure/mcp" . --exclude-dir={node_modules,.git}
# Should return: empty or only comments/docs

grep -r "~/Development/Projects/dev-infrastructure" . --exclude-dir={node_modules,.git}
# Should return: empty or only comments/docs
```

### After Phase 5 (Validation) - CRITICAL

**ALL must pass:**

```bash
# 1. Clean checkout test
cd ~/Development
git clone /Users/jederlichman/Development/Projects/dev-infrastructure dev-infrastructure-test
cd dev-infrastructure-test && git checkout phase-a-mechanical-migration
ls -la mcp/scripts/project-setup.sh  # Must exist

# 2. Test deployment
mkdir -p ~/Development/test-migration-validation && cd ~/Development/test-migration-validation
bash ~/Development/Projects/dev-infrastructure/mcp/scripts/project-setup.sh test-migration
bash scripts/validate-mcp.sh
# OUTPUT MUST BE: 8/8 tests pass

# 3. Existing project validation  
cd /Users/jederlichman/Development/Projects/iphone-tco-planner
bash scripts/validate-mcp.sh
# OUTPUT MUST BE: 8/8 tests pass (or whatever it was before)
```

---

## Execution Logs

**Use these sections in PHASE_A_CHECKLIST.md:**

### EXECUTION LOG
Record any deviations from plan:
```
[Timestamp] - Phase X - Issue: [description] - Resolution: [what you did]
```

### DECISION LOG
Record decisions you made:
```
[Timestamp] - Decision: [what] - Rationale: [why]
```

---

## Rollback Procedure (Emergency)

**If something goes wrong:**

```bash
cd /Users/jederlichman/Development/Projects
rm -rf dev-infrastructure  # Remove broken state

# Restore ClawdBot
mv ClawdBot-backup-YYYYMMDD-HHMM ClawdBot

# Restore mcp-deployment
mv mcp-deployment-backup-YYYYMMDD-HHMM ~/Development/Projects/dev-infrastructure/mcp

# Verify
cd ClawdBot && git status
cd ~/Development/Projects/dev-infrastructure/mcp && ls -la
```

**Then:** Document what went wrong, wait for human review.

---

## Common Issues & Fixes

### Issue: "No such file or directory" during consolidation

**Cause:** mcp-deployment doesn't have all expected directories

**Fix:** 
```bash
# Check what actually exists
ls -la ~/Development/Projects/dev-infrastructure/mcp/

# Only copy what exists, use 2>/dev/null to ignore missing
cp ~/Development/Projects/dev-infrastructure/mcp/docs/* mcp/docs/ 2>/dev/null || true
```

### Issue: Path update script finds too many references

**Cause:** Lots of files to update

**Expected:** This is normal if there are many docs/scripts

**Action:** Review a sample before running full update:
```bash
# Preview what will change
grep -r "~/Development/Projects/dev-infrastructure/mcp" . --exclude-dir={node_modules,.git} | head -10
```

### Issue: Clean checkout test fails - "command not found"

**Cause:** Absolute paths still exist

**Fix:** 
```bash
# Find remaining absolute paths
grep -r "/Users/jederlichman" dev-infrastructure-test/ --exclude-dir={node_modules,.git}

# These need to be relative or use environment variables
```

---

## Success Report Template

**After Phase 6, provide this report:**

```markdown
## Phase A Mechanical Migration - COMPLETE

**Date:** [YYYY-MM-DD HH:MM]
**Duration:** [X hours Y minutes]
**Agent:** [Your identifier]

### Global Acceptance Criteria

- [x] Repository renamed and consolidates mcp-deployment
- [x] All tests pass from clean checkout
- [x] No hardcoded absolute paths (or documented)
- [x] iphone-tco-planner still deploys successfully  
- [x] Rollback procedure verified workable
- [x] README.md updated

### Test Results

**Clean Checkout:** ✅ PASS
**Test Deployment:** ✅ 8/8 tests pass
**iphone-tco-planner:** ✅ Still works (8/8 tests pass)
**Rollback Verification:** ✅ Backups complete and verified

### Issues Encountered

[None / List any issues and how resolved]

### Deviations from Plan

[None / List any deviations]

### Git Status

- Branch: `phase-a-mechanical-migration`
- Tag: `v2.0.0-alpha`
- Commits: [X commits]
- Final commit hash: [hash]

### Files Modified

- Repository renamed: ✅
- mcp/ directory created: ✅
- Paths updated: ✅
- README.md updated: ✅
- MIGRATION.md created: ✅

### Recommendations

[Ready for Phase B / Issues to address / etc.]

### Overall Status

✅ Phase A COMPLETE - Ready for production use
```

---

## Phase B Preview (Don't Execute)

**After Phase A is stable, Phase B will:**
- Extract Antigravity patterns into antigravity/
- Create reference examples in examples/
- Rebuild comprehensive documentation
- Create master deployment script

**Estimated:** 2-3 hours in separate session

**You don't need to worry about this now.**

---

## Key Takeaways

1. **Follow PHASE_A_CHECKLIST.md exactly** - Don't improvise
2. **Checkpoint after every phase** - Git commit is your safety net
3. **Stop if validation fails** - Don't proceed to next phase
4. **Use execution logs** - Document deviations and decisions
5. **Verify global acceptance criteria** - Your final quality gate

---

## Human Handoff Points

**Report back to human if:**

- ✅ Phase A complete (provide success report)
- ❌ Any validation gate fails (provide failure details)
- ⚠️ Unexpected dependencies discovered in Phase 0
- 🤔 Decision needed (not covered in plan)

---

## Quick Start

**Ready to begin?**

1. Open `~/Development/Projects/dev-infrastructure/PHASE_A_CHECKLIST.md`
2. Start with Phase 0: Pre-Flight
3. Check off each item as you complete it
4. Report status after Phase 6

**Estimated time:** 2 hours  
**Risk level:** LOW (fully reversible)

Good luck! 🚀
