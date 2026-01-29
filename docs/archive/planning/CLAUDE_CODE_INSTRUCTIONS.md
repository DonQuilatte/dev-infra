# Claude Code Execution Instructions

## Environment Setup

You're executing this in **Claude Code**, which gives you:
- Direct file system access via Desktop Commander
- Bash execution capabilities
- Git operations
- File creation/editing tools

## Key Differences from Web Claude

### ✅ Use Desktop Commander Tools

**For file operations:**
```bash
# Use Desktop Commander tools, NOT bash_tool
Desktop Commander:read_file
Desktop Commander:write_file
Desktop Commander:start_process
Desktop Commander:list_directory
```

**Why:** Desktop Commander persists to your Mac filesystem. bash_tool writes to ephemeral container.

### ✅ Verify All File Writes

**After EVERY file creation/modification:**
```bash
ls -la <path>
cat <path> | head -20
```

**Always verify:**
- File exists on disk
- File has content
- Path is correct

### ✅ Use start_process for Commands

**For shell commands:**
```bash
Desktop Commander:start_process
{
  "command": "cd /path && git status",
  "timeout_ms": 5000
}
```

**Not:** bash_tool (ephemeral container)

## Claude Code-Specific Workflow

### Phase 0: Dependency Inventory

```bash
# Use start_process
Desktop Commander:start_process
{
  "command": "cd ~/Development/Projects/dev-infrastructure && grep -r '/Users/jederlichman' . --exclude-dir={node_modules,.git} > DEPENDENCY_INVENTORY.txt",
  "timeout_ms": 10000
}

# Verify it was created
Desktop Commander:read_file
{
  "path": "~/Development/Projects/dev-infrastructure/DEPENDENCY_INVENTORY.txt"
}
```

### Creating Backups

```bash
Desktop Commander:start_process
{
  "command": "cd /Users/jederlichman/Development/Projects && cp -r ClawdBot ClawdBot-backup-$(date +%Y%m%d-%H%M) && ls -ld *backup*",
  "timeout_ms": 30000
}
```

### Git Operations

```bash
# Create branch
Desktop Commander:start_process
{
  "command": "cd ~/Development/Projects/dev-infrastructure && git checkout -b phase-a-mechanical-migration && git add -A && git commit -m 'Pre-migration checkpoint'",
  "timeout_ms": 10000
}

# Verify
Desktop Commander:start_process
{
  "command": "cd ~/Development/Projects/dev-infrastructure && git log --oneline -1",
  "timeout_ms": 3000
}
```

### File Operations

```bash
# Read file
Desktop Commander:read_file
{
  "path": "~/Development/Projects/dev-infrastructure/.envrc",
  "length": 50
}

# Write file
Desktop Commander:write_file
{
  "path": "/Users/jederlichman/Development/Projects/dev-infrastructure/README.md",
  "content": "[content here]",
  "mode": "rewrite"
}

# ALWAYS verify after write
Desktop Commander:start_process
{
  "command": "ls -la /Users/jederlichman/Development/Projects/dev-infrastructure/README.md",
  "timeout_ms": 2000
}
```

### Directory Operations

```bash
# Create directories
Desktop Commander:start_process
{
  "command": "cd /Users/jederlichman/Development/Projects/dev-infrastructure && mkdir -p mcp/{scripts,templates,docs}",
  "timeout_ms": 5000
}

# List directory
Desktop Commander:list_directory
{
  "path": "/Users/jederlichman/Development/Projects/dev-infrastructure/mcp",
  "depth": 2
}
```

## Checkpoint Pattern for Claude Code

**After each phase:**

```bash
# 1. Add all changes
Desktop Commander:start_process
{
  "command": "cd /Users/jederlichman/Development/Projects/dev-infrastructure && git add -A",
  "timeout_ms": 5000
}

# 2. Commit with message
Desktop Commander:start_process
{
  "command": "cd /Users/jederlichman/Development/Projects/dev-infrastructure && git commit -m 'Phase X: Description'",
  "timeout_ms": 5000
}

# 3. Verify commit
Desktop Commander:start_process
{
  "command": "cd /Users/jederlichman/Development/Projects/dev-infrastructure && git log --oneline -1",
  "timeout_ms": 3000
}
```

## Validation in Claude Code

### Test Deployment

```bash
# Create test directory
Desktop Commander:start_process
{
  "command": "mkdir -p ~/Development/test-migration-validation",
  "timeout_ms": 3000
}

# Deploy
Desktop Commander:start_process
{
  "command": "cd ~/Development/test-migration-validation && bash ~/Development/Projects/dev-infrastructure/mcp/scripts/project-setup.sh test-migration",
  "timeout_ms": 30000
}

# Validate
Desktop Commander:start_process
{
  "command": "cd ~/Development/test-migration-validation && bash scripts/validate-mcp.sh",
  "timeout_ms": 15000
}
```

### Existing Project Validation

```bash
Desktop Commander:start_process
{
  "command": "cd /Users/jederlichman/Development/Projects/iphone-tco-planner && bash scripts/validate-mcp.sh",
  "timeout_ms": 15000
}
```

## Common Pitfalls in Claude Code

### ❌ DON'T: Use bash_tool

```bash
# WRONG - writes to container, not Mac
bash_tool: "echo 'test' > /Users/jederlichman/file.txt"
```

### ✅ DO: Use Desktop Commander

```bash
# CORRECT - writes to Mac filesystem
Desktop Commander:write_file or Desktop Commander:start_process
```

### ❌ DON'T: Assume file was written

```bash
# WRONG - no verification
Desktop Commander:write_file(path, content)
# [assume success]
```

### ✅ DO: Always verify

```bash
# CORRECT - verify after write
Desktop Commander:write_file(path, content)
Desktop Commander:start_process("ls -la " + path)
```

### ❌ DON'T: Chain complex commands in one call

```bash
# WRONG - hard to debug if fails
"cd /path && command1 && command2 && command3 && command4"
```

### ✅ DO: Break into logical steps

```bash
# CORRECT - checkpoint after each step
step1: "cd /path && command1"
verify1: "test step1 output"
step2: "cd /path && command2"
verify2: "test step2 output"
```

## Path Update Script in Claude Code

**Don't create script file, just run directly:**

```bash
Desktop Commander:start_process
{
  "command": "cd /Users/jederlichman/Development/Projects/dev-infrastructure && find . -type f -not -path '*/node_modules/*' -not -path '*/.git/*' -exec sed -i.bak 's|~/Development/Projects/dev-infrastructure/mcp|~/Development/Projects/dev-infrastructure/mcp|g' {} \\; && find . -name '*.bak' -delete",
  "timeout_ms": 30000
}
```

## README Creation in Claude Code

**Use Desktop Commander:write_file:**

```bash
Desktop Commander:write_file
{
  "path": "/Users/jederlichman/Development/Projects/dev-infrastructure/README.md",
  "content": "# dev-infrastructure\n\nDistributed development infrastructure...",
  "mode": "rewrite"
}
```

## Progress Reporting

**After each phase, report status:**

```markdown
## Phase X Complete

**Status:** ✅ PASS / ⚠️ ISSUES / ❌ FAIL

**Actions taken:**
- [list what you did]

**Verification:**
- [what you checked]

**Issues found:**
- [none / list issues]

**Next:** Proceeding to Phase Y / Stopped for review
```

## Error Handling

**If command fails:**

```bash
# 1. Capture error output
Desktop Commander:read_process_output(pid)

# 2. Report to user
"Phase X failed with error: [error message]"

# 3. DO NOT proceed to next phase
"Stopping execution. Please review error."

# 4. Document in execution log
EXECUTION_LOG:
[timestamp] - Phase X - Issue: [error] - Status: Blocked
```

## Final Validation Checklist for Claude Code

**Run these in sequence, MUST ALL PASS:**

```bash
# 1. Clean checkout test
Desktop Commander:start_process
{
  "command": "cd ~/Development && git clone /Users/jederlichman/Development/Projects/dev-infrastructure dev-infrastructure-test && cd dev-infrastructure-test && git checkout phase-a-mechanical-migration && ls -la mcp/scripts/project-setup.sh",
  "timeout_ms": 30000
}

# 2. Test deployment
Desktop Commander:start_process
{
  "command": "mkdir -p ~/Development/test-migration-validation && cd ~/Development/test-migration-validation && bash ~/Development/Projects/dev-infrastructure/mcp/scripts/project-setup.sh test-migration && bash scripts/validate-mcp.sh",
  "timeout_ms": 45000
}

# 3. Existing project validation
Desktop Commander:start_process
{
  "command": "cd /Users/jederlichman/Development/Projects/iphone-tco-planner && bash scripts/validate-mcp.sh",
  "timeout_ms": 15000
}
```

**ALL must output: 8/8 tests pass**

## Success Report Template for Claude Code

**After Phase 6:**

```markdown
## Phase A Mechanical Migration - COMPLETE ✅

**Execution Environment:** Claude Code
**Duration:** [X hours Y minutes]
**Date:** [YYYY-MM-DD HH:MM]

### Global Acceptance Criteria
- [x] Repository renamed and mcp-deployment consolidated
- [x] All tests pass from clean checkout
- [x] No hardcoded absolute paths
- [x] iphone-tco-planner validates successfully
- [x] Rollback procedure verified
- [x] README.md updated

### Verification Results
**Clean Checkout:** ✅ PASS
- Path: ~/Development/dev-infrastructure-test
- Verified: mcp/scripts/project-setup.sh exists

**Test Deployment:** ✅ PASS
- Output: 8/8 tests passed
- Location: ~/Development/test-migration-validation

**iphone-tco-planner:** ✅ PASS
- Output: 8/8 tests passed
- No regression detected

### Git Status
- Branch: phase-a-mechanical-migration
- Tag: v2.0.0-alpha
- Commits: [list commit hashes]

### Files Modified
[List key files changed]

### Issues Encountered
[None / List with resolutions]

### Recommendations
Ready for production use. Phase B can be scheduled separately.

### Artifacts Created
- Backups: ClawdBot-backup-[timestamp], mcp-deployment-backup-[timestamp]
- New repo: /Users/jederlichman/Development/Projects/dev-infrastructure
- Git tag: v2.0.0-alpha

**Status:** ✅ COMPLETE - All acceptance criteria met
```

## Quick Reference: Tool Selection

| Task | Tool | Example |
|------|------|---------|
| Run command | `Desktop Commander:start_process` | Git, mkdir, cp, etc. |
| Read file | `Desktop Commander:read_file` | View configs |
| Write file | `Desktop Commander:write_file` | Create/update files |
| List dir | `Desktop Commander:list_directory` | View structure |
| Edit file | `Desktop Commander:edit_block` | Targeted edits |

## Remember

1. **Always use absolute paths** - No relative paths
2. **Always verify writes** - ls/cat after file operations
3. **Checkpoint frequently** - Git commit after each phase
4. **Report progress** - Update after each phase
5. **Stop on errors** - Don't proceed if validation fails

---

**Ready to execute?** Start with Phase 0 in PHASE_A_CHECKLIST.md using Desktop Commander tools!
