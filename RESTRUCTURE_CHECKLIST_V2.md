# Restructure Execution Checklist v2 - TIGHTENED

**Scope:** Mechanical migration ONLY  
**Duration:** 2-3 hours  
**Status:** Ready to execute

---

## GLOBAL ACCEPTANCE (check when ALL true)

- [ ] Repo works from clean checkout
- [ ] All tests pass (validate-mcp.sh)
- [ ] No "ClawdBot" except history
- [ ] No absolute paths (or in .env.example)
- [ ] README.md + MIGRATION.md complete
- [ ] mcp-deployment merged and working
- [ ] Rollback documented
- [ ] iphone-tco-planner validates

---

## PHASE 0: Dependency Inventory ⏱️ 15 min

- [ ] Find absolute paths
  ```bash
  cd ~/Development/Projects/dev-infrastructure
  grep -r "/Users/jederlichman" . --exclude-dir={node_modules,.git} > DEPENDENCY_INVENTORY.txt
  ```

- [ ] Find ClawdBot references
  ```bash
  grep -r "ClawdBot" . --exclude-dir={node_modules,.git} >> DEPENDENCY_INVENTORY.txt
  ```

- [ ] Find mcp-deployment references
  ```bash
  grep -r "mcp-deployment" . --exclude-dir={node_modules,.git} >> DEPENDENCY_INVENTORY.txt
  ```

- [ ] Check LaunchAgents
  ```bash
  ls ~/Library/LaunchAgents/*clawdbot* 2>/dev/null || true
  ```

- [ ] Check cron jobs
  ```bash
  crontab -l | grep -i clawdbot || true
  ```

- [ ] Check shell aliases
  ```bash
  grep -i clawdbot ~/.zshrc || true
  ```

- [ ] Review DEPENDENCY_INVENTORY.txt

- [ ] Create must-update list

**Checkpoint:** Must-update list documented

---

## PHASE 1: Preparation ⏱️ 20 min

- [ ] Backup ClawdBot
  ```bash
  cd /Users/jederlichman/Development/Projects
  cp -r ClawdBot ClawdBot-backup-$(date +%Y%m%d-%H%M)
  ls -ld *backup*
  ```

- [ ] Backup mcp-deployment
  ```bash
  cp -r ~/Development/Projects/dev-infrastructure/mcp mcp-deployment-backup-$(date +%Y%m%d-%H%M)
  ```

- [ ] Create git branch
  ```bash
  cd ClawdBot
  git checkout -b restructure-to-dev-infrastructure
  git add -A
  git commit -m "Phase 1: Before restructure checkpoint"
  git log -1 --oneline
  ```

**Checkpoint:** Backups exist, branch created

---

## PHASE 2: Mechanical Migration ⏱️ 45 min

- [ ] DRY RUN - Show what will change
  ```bash
  echo "WILL RENAME: ClawdBot → dev-infrastructure"
  ```

- [ ] Rename repository
  ```bash
  cd /Users/jederlichman/Development/Projects
  mv ClawdBot dev-infrastructure
  cd dev-infrastructure
  ```

- [ ] Commit rename
  ```bash
  git add -A
  git commit -m "Phase 2.1: Renamed ClawdBot → dev-infrastructure"
  ```

- [ ] Create directories
  ```bash
  mkdir -p mcp/{scripts,templates,docs}
  mkdir -p infrastructure/main-mac
  git add -A
  git commit -m "Phase 2.2: Created directory structure"
  ```

- [ ] DRY RUN - List mcp-deployment contents
  ```bash
  ls -la ~/Development/Projects/dev-infrastructure/mcp/
  ```

- [ ] Merge mcp-deployment
  ```bash
  cp -rv ~/Development/Projects/dev-infrastructure/mcp/scripts/* mcp/scripts/
  cp -rv ~/Development/Projects/dev-infrastructure/mcp/docs/* mcp/docs/
  cp -v ~/Development/Projects/dev-infrastructure/mcp/{README.md,CHANGELOG.md,DEPLOYMENT_FIXES.md} mcp/
  git add -A
  git commit -m "Phase 2.3: Merged mcp-deployment"
  ```

- [ ] Update path references
  ```bash
  find . -type f -not -path "*/node_modules/*" -not -path "*/.git/*" \
    -exec sed -i.bak 's|~/Development/mcp-deployment|~/Development/Projects/dev-infrastructure/mcp|g' {} \;
  find . -type f -not -path "*/node_modules/*" -not -path "*/.git/*" \
    -exec sed -i.bak 's|~/Development/Projects/dev-infrastructure/mcp|/Users/jederlichman/Development/Projects/dev-infrastructure/mcp|g' {} \;
  find . -name "*.bak" -delete
  git add -A
  git commit -m "Phase 2.4: Updated path references"
  ```

- [ ] Create .env.example
  ```bash
  # Use template from RESTRUCTURE_EXECUTION_V2.md
  git add .env.example
  git commit -m "Phase 2.5: Added .env.example"
  ```

**Checkpoint:** Repository renamed, mcp merged, paths updated

---

## PHASE 3: Minimal Documentation ⏱️ 30 min

- [ ] Create minimal README.md
  ```bash
  # Use template from RESTRUCTURE_EXECUTION_V2.md
  git add README.md
  git commit -m "Phase 3.1: Created minimal README"
  ```

- [ ] Create MIGRATION.md
  ```bash
  # Use template from RESTRUCTURE_EXECUTION_V2.md
  git add MIGRATION.md
  git commit -m "Phase 3.2: Created MIGRATION.md"
  ```

**Checkpoint:** Basic documentation in place

---

## PHASE 4: Testing & Validation ⏱️ 45 min

- [ ] Clean checkout test
  ```bash
  cd ~/Development
  mkdir -p test-clean-checkout
  cp -r ~/Development/Projects/dev-infrastructure test-clean-checkout/
  cd test-clean-checkout/dev-infrastructure
  ls -la mcp/scripts/project-setup.sh
  ```

- [ ] Deploy to test project
  ```bash
  mkdir -p ~/Development/test-restructure-deploy
  cd ~/Development/test-restructure-deploy
  bash ~/Development/Projects/dev-infrastructure/mcp/scripts/project-setup.sh test-restructure
  ```

- [ ] Validate test deploy
  ```bash
  bash scripts/validate-mcp.sh
  # Expected: 8/8 pass
  ```

- [ ] Verify iphone-tco-planner
  ```bash
  cd /Users/jederlichman/Development/Projects/iphone-tco-planner
  bash scripts/validate-mcp.sh
  # Expected: still passes
  ```

- [ ] Test in Antigravity
  - Open test project
  - Check MCP panel
  - Test one operation

- [ ] Document test results
  ```bash
  cd ~/Development/Projects/dev-infrastructure
  # Create TEST_RESULTS.md (template in plan)
  git add TEST_RESULTS.md
  git commit -m "Phase 4: Test results"
  ```

**Checkpoint:** All tests pass, documented

---

## PHASE 5: Rollback Verification ⏱️ 15 min

- [ ] Create ROLLBACK.md
  ```bash
  # Use template from RESTRUCTURE_EXECUTION_V2.md
  git add ROLLBACK.md
  git commit -m "Phase 5: Rollback procedure"
  ```

- [ ] Verify you understand rollback steps

**Checkpoint:** Rollback documented

---

## PHASE 6: Finalize & Tag ⏱️ 15 min

- [ ] Final commit
  ```bash
  cd ~/Development/Projects/dev-infrastructure
  git add -A
  git commit -m "Phase 6: Restructure complete - v2.0.0

See RESTRUCTURE_EXECUTION_V2.md for details"
  ```

- [ ] Tag v2.0.0
  ```bash
  git tag -a v2.0.0 -m "v2.0.0: Restructured as dev-infrastructure

Mechanical migration complete and tested"
  ```

- [ ] Push (if remote exists)
  ```bash
  git remote -v
  # If exists:
  git push origin restructure-to-dev-infrastructure
  git push origin v2.0.0
  ```

**Checkpoint:** Tagged and pushed

---

## POST-MIGRATION: Transition ⏱️ 5 min

- [ ] Create symlink
  ```bash
  ln -s ~/Development/Projects/dev-infrastructure/mcp ~/Development/mcp-deployment-redirect
  ```

- [ ] Add transition note to .zshrc
  ```bash
  echo "# Restructure transition (remove after 30 days)" >> ~/.zshrc
  echo "alias old-mcp='echo \"Moved to: ~/Development/Projects/dev-infrastructure/mcp/\"'" >> ~/.zshrc
  ```

- [ ] Source .zshrc
  ```bash
  source ~/.zshrc
  ```

**Checkpoint:** Transition helpers in place

---

## EXECUTION LOG

```
[Record deviations here]
```

---

## DECISION LOG  

```
[Record decisions here]
```

---

## FINAL ACCEPTANCE CHECK

**When migration complete, verify ALL global criteria:**

- [ ] Repo works from clean checkout
- [ ] All tests pass
- [ ] No "ClawdBot" except history
- [ ] No absolute paths (or documented)
- [ ] README.md + MIGRATION.md done
- [ ] mcp-deployment merged
- [ ] Rollback ready
- [ ] iphone-tco-planner works
- [ ] v2.0.0 tagged
- [ ] TEST_RESULTS.md shows PASS

**ALL CHECKED?** ✅ Migration complete

**NOT ALL CHECKED?** Fix issues and re-validate

---

## ROLLBACK (if needed)

If any acceptance criteria fail:

1. Stop immediately
2. Open ROLLBACK.md
3. Execute rollback procedure
4. Document what went wrong
5. Fix plan and retry later

---

**Time Budget:**
- Phase 0: 15 min
- Phase 1: 20 min  
- Phase 2: 45 min
- Phase 3: 30 min
- Phase 4: 45 min
- Phase 5: 15 min
- Phase 6: 15 min
- Post: 5 min
**Total: ~3 hours**

**Ready?** Start Phase 0
