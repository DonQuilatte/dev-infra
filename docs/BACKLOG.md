# Backlog

## Open Items

*No open items*

---

## Resolved

### Consolidate docs/ files

**Priority:** Low

**Resolution:** ✅ Reduced from 35 to 14 top-level docs. Merged QUICK_REFERENCE with DISTRIBUTED_QUICK_REFERENCE. Archived 21 historical/session docs.

**Resolved:** 2026-01-31

---

### Update CHANGELOG.md

**Priority:** Low

**Resolution:** ✅ Updated [Unreleased] to [2.0.0] with Brain/Agent infrastructure changes.

**Resolved:** 2026-01-31

---

### Add version tag

**Priority:** Low

**Resolution:** ✅ Tagged v2.0.0 (v2.0.0-alpha already existed from Phase 6 migration).

**Resolved:** 2026-01-31

---

### Code review cleanup

**Priority:** Low

**Resolution:** ✅ Fixed 5 scripts - added strict mode to `agy-notify` and `start-node.sh.template`, refactored `agy-init`, `agy-sync-mcp`, and `dispatch-all.sh` to source `common.sh` with fallback.

**Resolved:** 2026-01-31

---

### Verify shellcheck CI locally

**Priority:** Low

**Resolution:** ✅ Fixed 5 bugs (shebang, trap quoting, redirect order, declare/assign). 13 remaining warnings are intentional (unused vars, style). Commit 799d9de.

**Resolved:** 2026-01-31

---

### Agent Alpha connectivity

**Priority:** Medium

**Resolution:** ✅ Verified - SSH works, `agent status/list` functional, symlink resolution fixed (179e4f0). SMB mount optional (use Finder: Cmd+K → smb://192.168.1.245/tywhitaker).

**Resolved:** 2026-01-31

---

### Antigravity IDE Path 3 Integration (Zero-Command)

**Priority:** Critical

**Resolution:** Closed - Full implementation of Zero-Command project environment complete. Includes dynamic MCP registration, auto-setup hooks, and self-healing diagnostics.

**Investigated:** 2026-01-30
