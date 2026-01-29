# MCP Stack Validation Instructions for Agent

## Objective
Validate that the ClawdBot project has successfully adopted the standardized MCP deployment stack and that all MCP servers are functioning correctly in Antigravity IDE.

## Context
We've just integrated the mcp-deployment package with ClawdBot. The project should now have:
- 3 MCP servers configured (github, filesystem, context7)
- Updated wrapper scripts with Homebrew PATH
- Antigravity config with auto-load enabled

## Validation Tasks

### Task 1: Visual Inspection - Antigravity MCP Panel

**Action:** Check the Antigravity MCP panel (usually in sidebar/settings)

**Expected Result:**
```
Project MCPs (.antigravity/config.json)
  ✓ github - connected
  ✓ filesystem - connected
  ✓ context7 - connected
```

**If servers show as "failed":**
- Note the exact error message
- Check Antigravity console/logs for details

---

### Task 2: Validate Configuration Files

Run these checks:

```bash
cd /Users/jederlichman/Development/Projects/ClawdBot

# 1. Verify Antigravity config exists and has MCP servers
cat .antigravity/config.json | grep -A 20 '"mcp"'

# Expected: Should show 3 servers (github, filesystem, context7)

# 2. Verify wrapper scripts have PATH export
grep "export PATH" scripts/mcp-gitkraken scripts/mcp-filesystem

# Expected: Both should show PATH export with Homebrew

# 3. Verify wrapper scripts are executable
ls -la scripts/mcp-* | grep "rwx"

# Expected: All scripts should be executable (rwxr-xr-x)
```

---

### Task 3: Test MCP Server Launch (Manual)

Test each wrapper launches successfully:

```bash
cd /Users/jederlichman/Development/Projects/ClawdBot

# Test filesystem server
bash scripts/mcp-filesystem &
FILESYSTEM_PID=$!
sleep 2

# Should see: "Secure MCP Filesystem Server running on stdio"
# Kill it: kill $FILESYSTEM_PID

# Test github server
bash scripts/mcp-gitkraken &
GITHUB_PID=$!
sleep 2

# Should start without errors
# Kill it: kill $GITHUB_PID

# Test context7 server
bash scripts/mcp-context7 &
CONTEXT7_PID=$!
sleep 2

# Should start without errors
# Kill it: kill $CONTEXT7_PID
```

**Success Criteria:** All 3 servers launch without "command not found" or "module not found" errors

---

### Task 4: Compare with Reference Implementation

Compare ClawdBot config with iphone-tco-planner (known working):

```bash
# Compare wrapper structure
diff /Users/jederlichman/Development/Projects/iphone-tco-planner/scripts/mcp-gitkraken \
     /Users/jederlichman/Development/Projects/ClawdBot/scripts/mcp-gitkraken

# Compare Antigravity configs
diff /Users/jederlichman/Development/Projects/iphone-tco-planner/.antigravity/config.json \
     /Users/jederlichman/Development/Projects/ClawdBot/.antigravity/config.json

# Expected differences:
# - ClawdBot has context7 server (unique to this project)
# - ClawdBot may have different setupScript
# - Server package names should match (filesystem, github)
```

---

### Task 5: Environment Variable Check

Verify direnv environment loading:

```bash
cd /Users/jederlichman/Development/Projects/ClawdBot

# Check if PROJECT_NAME is set
echo $PROJECT_NAME
# Expected: ClawdBot

# Check if .envrc exists
ls -la .envrc

# Check Docker socket detection
echo $DOCKER_HOST
# Should show socket path or be empty
```

---

### Task 6: Run Automated Validation

If validation script exists, run it:

```bash
cd /Users/jederlichman/Development/Projects/ClawdBot

# Check if validation script exists
if [ -f "scripts/validate-mcp.sh" ]; then
  bash scripts/validate-mcp.sh
else
  echo "⚠️  No validation script found (expected for this project)"
fi
```

---

## Troubleshooting Guide

### Issue: Servers show "failed" in Antigravity

**Check:**
1. Antigravity logs/console for error details
2. Run manual server launch test (Task 3)
3. Verify PATH includes Homebrew: `echo $PATH | grep homebrew`

**Fix:**
```bash
# If PATH missing, update wrappers:
cd /Users/jederlichman/Development/Projects/ClawdBot
# Re-run: bash ~/Development/mcp-deployment/scripts/project-setup.sh ClawdBot
```

---

### Issue: "npx: command not found"

**Diagnosis:** Wrapper scripts missing PATH export

**Fix:**
```bash
# Add PATH to wrappers
cd /Users/jederlichman/Development/Projects/ClawdBot/scripts

# Update mcp-gitkraken
sed -i.bak '6 i\
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"\
' mcp-gitkraken

# Update mcp-filesystem  
sed -i.bak '6 i\
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"\
' mcp-filesystem
```

---

### Issue: "Module not found" errors

**Diagnosis:** MCP server packages not installed

**Fix:**
```bash
# Test npx can resolve packages
/opt/homebrew/bin/npx -y @modelcontextprotocol/server-github --help
/opt/homebrew/bin/npx -y @modelcontextprotocol/server-filesystem --help

# If errors, check npm/node installation
which node npm npx
```

---

## Success Criteria Checklist

- [ ] Antigravity MCP panel shows 3 servers as "connected"
- [ ] `.antigravity/config.json` has mcp.servers section with 3 entries
- [ ] Wrapper scripts have `export PATH` statements
- [ ] Manual server launch test succeeds for all 3 servers
- [ ] No "command not found" or "module not found" errors
- [ ] Environment variables load correctly (PROJECT_NAME set)

## Report Template

After completing validation, provide report in this format:

```
## ClawdBot MCP Validation Report

**Date:** [DATE]
**Status:** [✅ PASS / ❌ FAIL / ⚠️ PARTIAL]

### Antigravity MCP Panel
- github: [connected/failed - error details]
- filesystem: [connected/failed - error details]  
- context7: [connected/failed - error details]

### Configuration Files
- .antigravity/config.json: [✅ Valid / ❌ Issues]
- Wrapper scripts PATH: [✅ Present / ❌ Missing]
- Scripts executable: [✅ Yes / ❌ No]

### Manual Server Tests
- filesystem: [✅ Launches / ❌ Error: ...]
- github: [✅ Launches / ❌ Error: ...]
- context7: [✅ Launches / ❌ Error: ...]

### Environment
- PROJECT_NAME: [set/not set]
- DOCKER_HOST: [set/not set]

### Issues Found
[List any issues discovered]

### Recommendations
[Suggest fixes for any issues]

### Overall Assessment
[Summary of ClawdBot MCP integration status]
```

---

## Next Steps After Validation

**If all tests pass:**
1. Document ClawdBot as reference implementation
2. Use this setup pattern for deploying to other projects
3. Update deployment package with any lessons learned

**If tests fail:**
1. Fix issues using troubleshooting guide
2. Re-run validation
3. Update deployment package to prevent issues in future deployments

---

**Priority:** HIGH - This validates our entire MCP deployment strategy
**Time Estimate:** 10-15 minutes for complete validation
