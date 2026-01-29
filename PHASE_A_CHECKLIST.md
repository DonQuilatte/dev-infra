# Phase A Execution Checklist - MECHANICAL MIGRATION ONLY

**Scope:** Rename + Consolidate + Validate  
**Duration:** 2 hours  
**Risk:** Low (fully reversible)

---

## GLOBAL ACCEPTANCE (Must ALL be checked)

- [ ] Repo renamed and consolidates mcp-deployment
- [ ] All tests pass from clean checkout  
- [ ] No hardcoded absolute paths (or documented)
- [ ] iphone-tco-planner still deploys successfully
- [ ] Rollback verified workable
- [ ] README updated with new name

---

## PHASE 0: Pre-Flight ⏱️ 15 min

- [ ] **Create dependency inventory**
  ```bash
  cd /Users/jederlichman/Development/Projects/ClawdBot
  grep -r "/Users/jederlichman" . --exclude-dir={node_modules,.git} > DEPENDENCY_INVENTORY.txt
  grep -r "ClawdBot" . --exclude-dir={node_modules,.git} >> DEPENDENCY_INVENTORY.txt
  grep -r "mcp-deployment" . --exclude-dir={node_modules,.git} >> DEPENDENCY_INVENTORY.txt
  cat DEPENDENCY_INVENTORY.txt
  ```

- [ ] **Review inventory and create must-update list**
  - Document what MUST change
  - Document what's SAFE to keep

- [ ] **Backup ClawdBot**
  ```bash
  cd /Users/jederlichman/Development/Projects
  cp -r ClawdBot ClawdBot-backup-$(date +%Y%m%d-%H%M)
  ls -ld ClawdBot-backup*
  ```

- [ ] **Backup mcp-deployment**
  ```bash
  cp -r /Users/jederlichman/Development/mcp-deployment mcp-deployment-backup-$(date +%Y%m%d-%H%M)
  ls -ld mcp-deployment-backup*
  ```

- [ ] **Create migration branch**
  ```bash
  cd ClawdBot
  git checkout -b phase-a-mechanical-migration
  git add -A
  git commit -m "Pre-migration checkpoint"
  git log --oneline -1
  ```

**✅ Checkpoint:** Dependency inventory complete, backups exist, branch created

---

## PHASE 1: Rename Repository ⏱️ 10 min

- [ ] **Rename folder**
  ```bash
  cd /Users/jederlichman/Development/Projects
  mv ClawdBot dev-infrastructure
  cd dev-infrastructure
  pwd  # Verify: .../Projects/dev-infrastructure
  ```

- [ ] **Commit rename**
  ```bash
  git add -A
  git commit -m "Phase 1: Rename ClawdBot → dev-infrastructure (folder)"
  ```

**✅ Checkpoint:** Repository renamed

---

## PHASE 2: Consolidate mcp-deployment ⏱️ 20 min

- [ ] **Create mcp/ directory**
  ```bash
  mkdir -p mcp/{scripts,templates,docs}
  ```

- [ ] **Copy mcp-deployment (not move)**
  ```bash
  cp /Users/jederlichman/Development/mcp-deployment/scripts/* mcp/scripts/
  cp /Users/jederlichman/Development/mcp-deployment/docs/* mcp/docs/ 2>/dev/null || true
  cp /Users/jederlichman/Development/mcp-deployment/{README.md,CHANGELOG.md} mcp/
  cp -r /Users/jederlichman/Development/mcp-deployment/templates/* mcp/templates/ 2>/dev/null || true
  ```

- [ ] **Verify copy**
  ```bash
  ls -la mcp/scripts/project-setup.sh
  ls -la mcp/README.md
  find mcp/ -type f | wc -l
  ```

- [ ] **Commit consolidation**
  ```bash
  git add mcp/
  git commit -m "Phase 2: Consolidate mcp-deployment into mcp/"
  ```

**✅ Checkpoint:** mcp-deployment merged

---

## PHASE 3: Update Path References ⏱️ 30 min

- [ ] **Create path update script**
  ```bash
  cat > scripts/update-paths.sh << 'SCRIPT'
#!/usr/bin/env bash
find . -type f -not -path "*/node_modules/*" -not -path "*/.git/*" \
  -exec sed -i.bak 's|/Users/jederlichman/Development/mcp-deployment|~/Development/Projects/dev-infrastructure/mcp|g' {} \;
find . -type f -not -path "*/node_modules/*" -not -path "*/.git/*" \
  -exec sed -i.bak 's|/Users/jederlichman/Development/Projects/ClawdBot|~/Development/Projects/dev-infrastructure|g' {} \;
find . -name "*.bak" -delete
echo "✅ Paths updated"
SCRIPT
  chmod +x scripts/update-paths.sh
  ```

- [ ] **Run path updates**
  ```bash
  bash scripts/update-paths.sh
  ```

- [ ] **Manual review of critical files**
  ```bash
  cat .envrc | grep PROJECT_ROOT
  grep -r "ClawdBot" docs/ 2>/dev/null | head -5
  ```

- [ ] **Update .envrc to auto-detect**
  ```bash
  # Edit .envrc to use: export PROJECT_ROOT="$(pwd)"
  # See PHASE_A_MECHANICAL_MIGRATION.md for template
  ```

- [ ] **Commit path updates**
  ```bash
  git add -A
  git commit -m "Phase 3: Update path references, remove hardcoding"
  ```

**✅ Checkpoint:** Paths updated and validated

---

## PHASE 4: Update README ⏱️ 15 min

- [ ] **Create new README.md**
  ```bash
  # Use template from PHASE_A_MECHANICAL_MIGRATION.md
  # Key points: new name, what it provides, quick start
  ```

- [ ] **Create MIGRATION.md**
  ```bash
  # Use template from PHASE_A_MECHANICAL_MIGRATION.md  
  # Document: old paths, new paths, update instructions
  ```

- [ ] **Commit documentation**
  ```bash
  git add README.md MIGRATION.md
  git commit -m "Phase 4: Update README and create MIGRATION guide"
  ```

**✅ Checkpoint:** Minimal docs updated

---

## PHASE 5: Validation ⏱️ 30 min

- [ ] **Clean checkout test**
  ```bash
  cd /Users/jederlichman/Development
  git clone /Users/jederlichman/Development/Projects/dev-infrastructure dev-infrastructure-test
  cd dev-infrastructure-test
  git checkout phase-a-mechanical-migration
  ls -la mcp/scripts/project-setup.sh
  ```

- [ ] **Deploy to test project**
  ```bash
  mkdir -p ~/Development/test-migration-validation
  cd ~/Development/test-migration-validation
  bash ~/Development/Projects/dev-infrastructure/mcp/scripts/project-setup.sh test-migration
  ls -la .antigravity/config.json scripts/mcp-*
  ```

- [ ] **Validate test deployment**
  ```bash
  bash scripts/validate-mcp.sh
  # MUST: 8/8 tests pass
  ```

- [ ] **Verify iphone-tco-planner**
  ```bash
  cd /Users/jederlichman/Development/Projects/iphone-tco-planner
  bash scripts/validate-mcp.sh
  # MUST: still pass
  ```

- [ ] **Test rollback (don't execute, just verify)**
  ```bash
  ls -ld ~/Development/Projects/ClawdBot-backup*
  ls -ld ~/Development/mcp-deployment-backup*
  ls ~/Development/Projects/ClawdBot-backup*/scripts/ | head
  ```

**✅ Checkpoint:** All validations pass

---

## PHASE 6: Finalize ⏱️ 15 min

- [ ] **Create reference allowlist**
  ```bash
  cat > CLAWDBOT_REFERENCES_ALLOWLIST.txt << 'EOF'
Git history: OK
docs/archive/: OK
MIGRATION.md: OK
CHANGELOG.md: OK
README.md: OK (one "Previously" reference)
EOF
  ```

- [ ] **Verify no unwanted references**
  ```bash
  grep -r "ClawdBot" . --exclude-dir={node_modules,.git,*backup*} \
    --exclude="*.md" --exclude="CLAWDBOT_REFERENCES_ALLOWLIST.txt"
  # Should be minimal
  ```

- [ ] **Create transition symlink**
  ```bash
  cd /Users/jederlichman/Development
  ln -s Projects/dev-infrastructure/mcp mcp-deployment-redirect
  ls -la mcp-deployment-redirect
  ```

- [ ] **Final commit**
  ```bash
  cd ~/Development/Projects/dev-infrastructure
  git add -A
  git commit -m "Phase 6: Finalize mechanical migration

✅ Repository renamed
✅ mcp-deployment consolidated  
✅ Paths updated and validated
✅ Clean checkout tested
✅ Existing projects work
✅ Rollback verified"
  ```

- [ ] **Tag alpha release**
  ```bash
  git tag -a v2.0.0-alpha -m "v2.0.0-alpha: Mechanical migration complete"
  ```

**✅ Checkpoint:** Migration finalized, tagged

---

## GLOBAL ACCEPTANCE - FINAL CHECK

**Verify ALL criteria before considering Phase A complete:**

- [ ] Repo renamed and consolidates mcp-deployment
- [ ] All tests pass from clean checkout
- [ ] No hardcoded absolute paths (or documented in .env.example)
- [ ] iphone-tco-planner still deploys successfully  
- [ ] Rollback verified workable
- [ ] README updated with new name and purpose
- [ ] v2.0.0-alpha tagged

**ALL CHECKED?** ✅ Phase A Complete

**NOT ALL CHECKED?** Fix issues, re-validate

---

## POST-MIGRATION Cleanup

- [ ] **Remove test artifacts**
  ```bash
  rm -rf ~/Development/test-migration-validation
  rm -rf ~/Development/dev-infrastructure-test
  ```

- [ ] **Document in MIGRATION.md**
  - Transition symlink location
  - 30-day cleanup timeline
  - Phase B preview

---

## EXECUTION LOG

**Record any deviations:**

```
[Timestamp] - Phase X - Issue: [what] - Resolution: [how fixed]
```

---

## DECISION LOG

**Record decisions made during execution:**

```
[Timestamp] - Decision: [what] - Rationale: [why]
```

---

## ROLLBACK (if needed)

If acceptance criteria fail:

```bash
cd /Users/jederlichman/Development/Projects
rm -rf dev-infrastructure
mv ClawdBot-backup-YYYYMMDD-HHMM ClawdBot
mv mcp-deployment-backup-YYYYMMDD-HHMM /Users/jederlichman/Development/mcp-deployment
```

Then investigate, fix plan, retry.

---

## NEXT: Phase B (Future Session)

After Phase A is stable:
- Extract Antigravity patterns
- Create reference examples  
- Rebuild comprehensive docs

Estimated: 2-3 hours in separate session

---

**Time Budget: 2 hours total**
**Risk: LOW** (mechanical only, fully reversible)
**Ready?** Start Phase 0
