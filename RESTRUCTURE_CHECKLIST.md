# Restructuring Execution Checklist

**Estimated Time:** 4-5 hours  
**Status:** Ready to Execute

---

## Pre-Flight Check

- [ ] Read RESTRUCTURE_PLAN.md completely
- [ ] Verify no uncommitted changes in ClawdBot
- [ ] Verify no uncommitted changes in mcp-deployment
- [ ] Close Antigravity/IDEs with these projects open
- [ ] Schedule uninterrupted time block

---

## Phase 1: Preparation ⏱️ 30 min

- [ ] **Backup ClawdBot**
  ```bash
  cd /Users/jederlichman/Development/Projects
  cp -r ClawdBot ClawdBot-backup-$(date +%Y%m%d)
  ```

- [ ] **Backup mcp-deployment**
  ```bash
  cp -r ~/Development/Projects/dev-infrastructure/mcp mcp-deployment-backup-$(date +%Y%m%d)
  ```

- [ ] **Create migration branch**
  ```bash
  cd ClawdBot
  git checkout -b restructure-to-dev-infrastructure
  git add -A
  git commit -m "Checkpoint before restructure"
  ```

**✅ Phase 1 Complete** - Backups created, safe to proceed

---

## Phase 2: Restructure ⏱️ 1 hour

- [ ] **2.1 Rename repository**
  ```bash
  cd /Users/jederlichman/Development/Projects
  mv ClawdBot dev-infrastructure
  cd dev-infrastructure
  ```

- [ ] **2.2 Create directory structure**
  ```bash
  mkdir -p mcp/{scripts,templates,docs}
  mkdir -p infrastructure/main-mac
  mkdir -p antigravity/{config-templates,workflows}
  mkdir -p examples/{basic-project,full-stack-app,custom-mcp-server}
  mkdir -p docs/{architecture,guides,reference}
  ```

- [ ] **2.3 Merge mcp-deployment**
  ```bash
  cp -r ~/Development/Projects/dev-infrastructure/mcp/scripts/* mcp/scripts/
  cp -r ~/Development/Projects/dev-infrastructure/mcp/docs/* mcp/docs/
  cp ~/Development/Projects/dev-infrastructure/mcp/{README.md,CHANGELOG.md} mcp/
  cp -r ~/Development/Projects/dev-infrastructure/mcp/templates/* mcp/templates/
  ```

- [ ] **2.4 Extract Antigravity patterns**
  ```bash
  mv scripts/agy-* antigravity/ 2>/dev/null || true
  mv scripts/agy-shell-integration.sh antigravity/shell-integration.sh 2>/dev/null || true
  cp .antigravity/config.json antigravity/config-templates/standard.json
  ```

- [ ] **2.5 Create examples**
  ```bash
  # Basic
  mkdir -p examples/basic-project/{.antigravity,scripts}
  cp antigravity/config-templates/standard.json examples/basic-project/.antigravity/config.json
  cp scripts/mcp-{gitkraken,filesystem} examples/basic-project/scripts/ 2>/dev/null || true
  
  # Custom MCP
  mkdir -p examples/custom-mcp-server/{.antigravity,scripts}
  cp .antigravity/config.json examples/custom-mcp-server/.antigravity/
  cp scripts/mcp-* examples/custom-mcp-server/scripts/
  ```

- [ ] **2.6 Reorganize documentation**
  ```bash
  # Architecture
  mkdir -p docs/architecture
  cp docs/SYSTEM_STATUS.md docs/architecture/OVERVIEW.md 2>/dev/null || true
  cp MCP_INTEGRATION.md docs/architecture/MCP_DESIGN.md 2>/dev/null || true
  
  # Guides
  mkdir -p docs/guides
  cp VALIDATION_INSTRUCTIONS.md docs/guides/MCP_DEPLOYMENT.md 2>/dev/null || true
  
  # Reference
  mkdir -p docs/reference
  cp QUICK_REFERENCE.md docs/reference/COMMANDS.md 2>/dev/null || true
  ```

**✅ Phase 2 Complete** - Structure created, files moved

---

## Phase 3: Documentation ⏱️ 1 hour

- [ ] **3.1 Create new README.md**
  - Use template from RESTRUCTURE_PLAN.md
  - Update with actual paths and status

- [ ] **3.2 Create QUICK_START.md**
  - Use template from RESTRUCTURE_PLAN.md
  - Test commands before including

- [ ] **3.3 Create docs/INDEX.md**
  - Central hub linking all docs
  - Organized by topic

- [ ] **3.4 Create MIGRATION.md**
  - Document what moved where
  - Provide redirect guidance

**✅ Phase 3 Complete** - Documentation updated

---

## Phase 4: Scripts ⏱️ 30 min

- [ ] **4.1 Create master deployment script**
  ```bash
  # scripts/deploy-to-project.sh
  # Wrapper calling mcp/scripts/project-setup.sh
  ```

- [ ] **4.2 Update path references**
  - Search for "mcp-deployment" in all scripts
  - Replace with "dev-infrastructure/mcp"

- [ ] **4.3 Create health check**
  ```bash
  # scripts/health-check.sh
  # Validates entire system
  ```

- [ ] **4.4 Update shell integration**
  - Verify agy-* commands still work
  - Update paths if needed

**✅ Phase 4 Complete** - Scripts updated and tested

---

## Phase 5: Update Projects ⏱️ 30 min

- [ ] **5.1 Test deployment on test project**
  ```bash
  mkdir -p ~/Development/test-mcp-restructure
  cd ~/Development/test-mcp-restructure
  bash ~/Development/Projects/dev-infrastructure/scripts/deploy-to-project.sh test-mcp
  ```

- [ ] **5.2 Verify test deployment**
  ```bash
  bash scripts/validate-mcp.sh
  # Should pass 8/8 tests
  ```

- [ ] **5.3 Update iphone-tco-planner reference**
  ```bash
  cd /Users/jederlichman/Development/Projects/iphone-tco-planner
  # Add note about new location
  echo "# Infrastructure: ~/Development/Projects/dev-infrastructure" >> README.md
  ```

**✅ Phase 5 Complete** - Projects updated

---

## Phase 6: Testing ⏱️ 1 hour

- [ ] **6.1 Structure validation**
  ```bash
  cd ~/Development/Projects/dev-infrastructure
  tree -L 2 > STRUCTURE_VALIDATION.txt
  cat STRUCTURE_VALIDATION.txt
  ```

- [ ] **6.2 Verify key files exist**
  ```bash
  ls -la mcp/scripts/project-setup.sh
  ls -la infrastructure/tw-mac/
  ls -la antigravity/
  ls -la examples/
  ls -la docs/INDEX.md
  ```

- [ ] **6.3 Test MCP deployment end-to-end**
  ```bash
  mkdir -p ~/Development/test-full-deploy
  cd ~/Development/test-full-deploy
  bash ~/Development/Projects/dev-infrastructure/scripts/deploy-to-project.sh test-full
  bash scripts/validate-mcp.sh
  ```

- [ ] **6.4 Test in Antigravity**
  - Open test project in Antigravity
  - Verify MCP panel shows servers
  - Test MCP tools work

- [ ] **6.5 Verify existing projects still work**
  ```bash
  cd /Users/jederlichman/Development/Projects/iphone-tco-planner
  bash scripts/validate-mcp.sh
  # Should still pass
  ```

**✅ Phase 6 Complete** - All tests pass

---

## Phase 7: Cleanup & Commit ⏱️ 30 min

- [ ] **7.1 Remove obsolete files**
  ```bash
  cd ~/Development/Projects/dev-infrastructure
  # Remove clawdbot-specific files no longer needed
  # Keep useful Docker configs in legacy/ if needed
  ```

- [ ] **7.2 Git status check**
  ```bash
  git status
  # Review all changes
  ```

- [ ] **7.3 Commit restructure**
  ```bash
  git add -A
  git commit -m "Restructure: ClawdBot → dev-infrastructure

BREAKING CHANGES:
- Renamed repository to reflect actual purpose
- Merged mcp-deployment into mcp/ subdirectory
- Reorganized into functional areas
- Comprehensive documentation overhaul

See RESTRUCTURE_PLAN.md and MIGRATION.md for details"
  ```

- [ ] **7.4 Tag release**
  ```bash
  git tag -a v2.0.0 -m "v2.0.0: Restructured as dev-infrastructure"
  ```

- [ ] **7.5 Push changes**
  ```bash
  git push origin restructure-to-dev-infrastructure
  git push origin v2.0.0
  ```

**✅ Phase 7 Complete** - Changes committed and tagged

---

## Post-Migration

- [ ] **Create symlink for transition period**
  ```bash
  ln -s ~/Development/Projects/dev-infrastructure/mcp ~/Development/mcp-deployment-redirect
  ```

- [ ] **Update shell aliases** (if any reference old paths)

- [ ] **Test from fresh terminal**
  - Source .zshrc
  - Test agy commands
  - Deploy to another test project

- [ ] **Document lessons learned**
  - Any issues encountered?
  - Updates needed to RESTRUCTURE_PLAN.md?

- [ ] **Schedule cleanup** (in 30 days)
  - Remove backup directories
  - Remove symlinks
  - Archive old documentation

---

## Rollback Plan (if needed)

If something goes wrong:

```bash
# 1. Restore from backup
cd /Users/jederlichman/Development/Projects
rm -rf dev-infrastructure
mv ClawdBot-backup-YYYYMMDD ClawdBot

# 2. Restore mcp-deployment
rm -rf mcp-deployment
mv mcp-deployment-backup-YYYYMMDD mcp-deployment

# 3. Reset git
cd ClawdBot
git reset --hard HEAD~1
git branch -D restructure-to-dev-infrastructure
```

---

## Success Criteria

- [x] All phases completed
- [ ] No failing tests
- [ ] Test project deploys successfully
- [ ] Existing projects (iphone-tco-planner) still work
- [ ] Documentation complete and accurate
- [ ] Git history preserved
- [ ] v2.0.0 tagged
- [ ] Changes pushed to remote

---

## Notes / Issues Encountered

*Use this space to document any issues or deviations from plan:*

```
[Add notes here as you execute]
```

---

**Ready?** Start with Phase 1 backups!
