# 🤖 AGENT HANDOFF CARD - Claude Code Edition

**Mission:** Execute Phase A Mechanical Migration  
**Target:** ClawdBot → dev-infrastructure  
**Duration:** 2 hours  
**Risk:** LOW  
**Environment:** Claude Code (Desktop Commander tools)

---

## START HERE

**1. Read:** **CLAUDE_CODE_INSTRUCTIONS.md** (Claude Code specific)  
**2. Read:** **AGENT_INSTRUCTIONS.md** (General guide)  
**3. Execute:** **PHASE_A_CHECKLIST.md** (Step-by-step)

---

## ⚠️ CRITICAL: Claude Code Specifics

### ✅ Use Desktop Commander Tools

```bash
# CORRECT - Persists to Mac
Desktop Commander:start_process
Desktop Commander:write_file
Desktop Commander:read_file

# WRONG - Ephemeral container
bash_tool
create_file
```

### ✅ Always Verify File Operations

```bash
# After EVERY write:
Desktop Commander:start_process("ls -la /path/to/file")
Desktop Commander:read_file("/path/to/file")
```

### ✅ Use Absolute Paths

```bash
# CORRECT
~/Development/Projects/dev-infrastructure

# WRONG
~/Development/Projects/ClawdBot
./ClawdBot
```

---

## Quick Brief

You're renaming a repository and consolidating two repos. Mechanical changes only - no creative work.

**What changes:**
- `ClawdBot` → `dev-infrastructure`
- `~/Development/Projects/dev-infrastructure/mcp` → `dev-infrastructure/mcp/`
- All path references updated

**What stays safe:**
- iphone-tco-planner project (must keep working)
- Git history preserved
- Full backups exist

---

## Your Checklist

```
□ Phase 0: Pre-Flight         [15 min] - Dependency inventory
□ Phase 1: Rename             [10 min] - mv ClawdBot → dev-infrastructure
□ Phase 2: Consolidate        [20 min] - Merge mcp-deployment
□ Phase 3: Update Paths       [30 min] - Remove hardcoding
□ Phase 4: Update README      [15 min] - Minimal docs
□ Phase 5: Validation         [30 min] - Test everything
□ Phase 6: Finalize           [15 min] - Commit & tag
```

---

## Success Means ALL These Pass

- [ ] Repository renamed and mcp-deployment merged
- [ ] Tests pass from clean checkout
- [ ] No hardcoded absolute paths
- [ ] iphone-tco-planner still works (8/8 tests)
- [ ] Rollback verified
- [ ] README updated

---

## Red Flags - STOP and Report

- ❌ Any test fails
- ❌ Clean checkout doesn't work
- ❌ iphone-tco-planner breaks
- ❌ Backups missing
- ❌ File write not verified on disk

---

## Key Commands (Claude Code)

### Backup (Phase 0)
```bash
Desktop Commander:start_process
{
  "command": "cd /Users/jederlichman/Development/Projects && cp -r ClawdBot ClawdBot-backup-$(date +%Y%m%d-%H%M)",
  "timeout_ms": 30000
}
```

### Git Checkpoint (After Each Phase)
```bash
Desktop Commander:start_process
{
  "command": "cd /Users/jederlichman/Development/Projects/dev-infrastructure && git add -A && git commit -m 'Phase X: Description'",
  "timeout_ms": 10000
}
```

### Test (Phase 5)
```bash
Desktop Commander:start_process
{
  "command": "cd ~/Development/test-migration-validation && bash scripts/validate-mcp.sh",
  "timeout_ms": 15000
}
# MUST: 8/8 pass
```

### Verify File Write
```bash
# After EVERY Desktop Commander:write_file
Desktop Commander:start_process
{
  "command": "ls -la /path/to/file && cat /path/to/file | head -10",
  "timeout_ms": 3000
}
```

---

## Progress Reporting

**After each phase:**

```markdown
## Phase X Complete

Status: ✅ PASS / ⚠️ ISSUES / ❌ FAIL
Actions: [what you did]
Verification: [what you checked]
Issues: [none / list]
Next: [proceeding / stopped]
```

---

## Tool Reference

| Task | Use This |
|------|----------|
| Run command | `Desktop Commander:start_process` |
| Read file | `Desktop Commander:read_file` |
| Write file | `Desktop Commander:write_file` |
| List directory | `Desktop Commander:list_directory` |
| Edit file | `Desktop Commander:edit_block` |

---

## Documents to Reference

1. **CLAUDE_CODE_INSTRUCTIONS.md** - Claude Code specifics
2. **AGENT_INSTRUCTIONS.md** - Complete guide
3. **PHASE_A_CHECKLIST.md** - Execution checklist
4. **PHASE_A_MECHANICAL_MIGRATION.md** - Technical reference

---

## After Phase 6

Provide success report using template in CLAUDE_CODE_INSTRUCTIONS.md

---

**Ready?** 

1. Open **CLAUDE_CODE_INSTRUCTIONS.md**
2. Review Claude Code tool usage
3. Start Phase 0 in **PHASE_A_CHECKLIST.md**

🚀 **Let's execute!**
