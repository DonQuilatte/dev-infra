# Codex CLI Review: Dev-Infra Phase 4 Verification

**Date:** 2026-01-31
**Repo:** dev-infra
**Branch:** awesome-sinoussi
**Reviewer:** Codex CLI

---

## Overview

Phases 0-3 of the dev-infra MCP secrets management system have been implemented. We request verification of the implementation against the RFC specifications.

---

## Implementation Summary

### Scripts Created

| Script | Purpose |
|--------|---------|
| `scripts/dev-infra` | Main CLI with subcommands |
| `scripts/secrets-refresh.sh` | Cache builder (encrypts secrets with age) |
| `scripts/mcp-launcher.sh` | Launches MCP servers with secrets injected |
| `scripts/secrets-refresh-wrapper.sh` | LaunchAgent wrapper (no hardcoded secrets) |

### Templates Created

| Template | Purpose |
|----------|---------|
| `templates/project/default/` | Basic project template |
| `templates/project/api/` | REST/GraphQL API template |
| `templates/project/cli/` | CLI tool template |
| `templates/project/library/` | npm package template |

### Configuration

| File | Purpose |
|------|---------|
| `~/.config/dev-infra/mcp-registry.json` | MCP server definitions with namespaced secrets |
| `~/.config/dev-infra/projects.json` | Project registry for refresh-all |
| `~/.config/dev-infra/age/identity.txt` | Age private key (600 perms) |
| `~/.config/dev-infra/age/recipient.txt` | Age public key (644 perms) |

---

## Review Requests

### 1. Age Keypair Implementation

**Files:** `scripts/secrets-refresh.sh`, `scripts/mcp-launcher.sh`

**RFC Spec:**
```bash
# Encrypt
age -r "$(cat "$AGE_RECIPIENT")" -o "$CACHE_DIR/secrets.enc"

# Decrypt
age -d -i "$AGE_IDENTITY" "$CACHE_DIR/secrets.enc"
```

**Verify:**
- [ ] Keypair generation correct (`age-keygen -o identity.txt`)
- [ ] Encrypt uses `-r` flag with recipient file
- [ ] Decrypt uses `-i` flag with identity file
- [ ] No passphrase prompts during operation

---

### 2. Per-Project Cache Isolation

**Files:** `scripts/secrets-refresh.sh`

**RFC Spec:**
- Cache key = sha256 hash of absolute project path (first 12 chars)
- Only enabled servers cached per project
- `.enabled-servers` + `.enabled-servers.local` merged

**Verify:**
```bash
# Expected cache structure
~/.cache/dev-infra/projects/<project-hash>/
├── secrets.enc   # Encrypted JSON
└── secrets.meta  # Epoch timestamps
```

- [ ] Project hash is sha256 of absolute path, not basename
- [ ] Only servers listed in `.enabled-servers` are cached
- [ ] `.enabled-servers.local` additions are merged (if exists)
- [ ] Cache directory has 700 permissions
- [ ] `secrets.enc` has 600 permissions

---

### 3. Namespaced Secrets

**Files:** `scripts/secrets-refresh.sh`, `scripts/mcp-launcher.sh`, `~/.config/dev-infra/mcp-registry.json`

**RFC Spec:**
- Keys stored as `server.ENV_VAR` in cache
- Launcher extracts `ENV_VAR` portion for export

**Verify:**
```bash
# In mcp-registry.json
"tiger": {
  "secrets": {
    "tiger.TIGER_API_KEY": "op://Developer/Tiger/api-key"
  }
}

# When launching tiger server, exports:
TIGER_API_KEY=<value>
```

- [ ] Registry uses namespaced keys (`server.ENV_VAR`)
- [ ] Cache stores namespaced keys
- [ ] Launcher strips namespace prefix for export

---

### 4. TTL Strategy

**Files:** `scripts/mcp-launcher.sh`

**RFC Spec:**
- Soft TTL: 4 hours (14400 seconds) - warn on stale, allow continuation
- Hard TTL: 24 hours (86400 seconds) - fail if refresh fails

**Verify:**
```bash
# In secrets.meta
{
  "refreshed_at": 1738339200,
  "soft_expires_at": 1738353600,
  "hard_expires_at": 1738425600
}
```

- [ ] Soft TTL triggers warning but allows stale cache
- [ ] Hard TTL forces refresh or fails
- [ ] Timestamps are epoch seconds (not ISO strings)
- [ ] Refresh logic handles all three states (fresh, soft-expired, hard-expired)

---

### 5. LaunchAgent Token Injection

**Files:** `scripts/secrets-refresh-wrapper.sh`

**RFC Spec:**
- Wrapper reads token from `~/.config/op/service-account-token`
- No secrets in plist file
- Token file has 600 permissions

**Verify:**
```bash
# Wrapper script
if [[ -f "$HOME/.config/op/service-account-token" ]]; then
    export OP_SERVICE_ACCOUNT_TOKEN=$(cat "$HOME/.config/op/service-account-token")
fi
exec "$HOME/Development/Projects/dev-infra/scripts/dev-infra" secrets refresh-all
```

- [ ] Plist contains no secrets (only wrapper path)
- [ ] Wrapper loads token from file, not environment
- [ ] Token file permissions are 600

---

### 6. Array-Safe Command Execution

**Files:** `scripts/mcp-launcher.sh`

**RFC Spec:**
```bash
# Preserves argument boundaries
readarray -t cmd < <(jq -r ".servers.\"$SERVER\".command[]" "$REGISTRY")
exec "${cmd[@]}"
```

**Verify:**
- [ ] Commands with spaces in arguments work correctly
- [ ] `readarray` used instead of subshell word-splitting
- [ ] `exec` uses array expansion `"${cmd[@]}"`

---

### 7. Project Registry

**Files:** `~/.config/dev-infra/projects.json`, `scripts/dev-infra`

**RFC Spec:**
```json
{
  "projects": [
    { "name": "project-a", "path": "/Users/jederlichman/Development/Projects/project-a" }
  ]
}
```

**Verify:**
- [ ] `dev-infra projects list` reads from registry
- [ ] `dev-infra projects add --path <dir>` adds to registry
- [ ] `dev-infra secrets refresh-all` iterates registry (no filesystem scanning)
- [ ] Absolute paths stored, not relative

---

## Test Scenarios

### Scenario 1: Fresh Cache Build

```bash
# Setup
mkdir -p /tmp/test-project
echo "tiger" > /tmp/test-project/.enabled-servers

# Test
dev-infra secrets refresh --path /tmp/test-project

# Expected
# - Cache created at ~/.cache/dev-infra/projects/<hash>/
# - secrets.enc contains only tiger secrets
# - secrets.meta has correct timestamps
```

### Scenario 2: MCP Server Launch

```bash
# Test
cd /tmp/test-project
dev-infra mcp tiger

# Expected
# - Cache checked/refreshed if needed
# - TIGER_API_KEY exported (not tiger.TIGER_API_KEY)
# - Server process started
```

### Scenario 3: Soft TTL Exceeded

```bash
# Manually set soft_expires_at to past timestamp
# Then launch server

# Expected
# - Warning message about stale cache
# - Refresh attempted
# - Server still starts (even if refresh fails)
```

### Scenario 4: Hard TTL Exceeded

```bash
# Manually set hard_expires_at to past timestamp
# Then launch server

# Expected
# - Error if refresh fails
# - Server does NOT start if refresh fails
```

### Scenario 5: Headless Operation (TW Mac)

```bash
# On TW Mac (Agent Alpha)
ssh tw "dev-infra secrets refresh --path /path/to/project"

# Expected
# - No GUI prompts
# - Token loaded from ~/.config/op/service-account-token
# - Cache built successfully
```

---

## File Locations

```
/Users/jederlichman/.claude-worktrees/dev-infra/awesome-sinoussi/
├── scripts/
│   ├── dev-infra                    # Main CLI
│   ├── secrets-refresh.sh           # Cache builder
│   ├── mcp-launcher.sh              # MCP launcher
│   └── secrets-refresh-wrapper.sh   # LaunchAgent wrapper
├── templates/
│   └── project/
│       ├── default/
│       ├── api/
│       ├── cli/
│       └── library/
└── docs/
    ├── MCP_SECRETS_ARCHITECTURE.md  # RFC v2.1
    ├── DEV_INFRA_IMPLEMENTATION_PLAN.md
    └── CODEX_REVIEW_PHASE4.md       # This file
```

---

## Response Format

Please provide feedback in this format:

```
## Verification Results

### Passed
- [x] Item that passed verification

### Issues Found
- [Severity]: [file:lines] [Description]

### Recommendations
- [Suggestion for improvement]

### Test Results
- Scenario 1: PASS/FAIL [notes]
- Scenario 2: PASS/FAIL [notes]
...

## Summary
[Overall assessment and next steps]
```

---

## Access

```bash
# Pull the branch
git fetch origin awesome-sinoussi
git checkout awesome-sinoussi

# Or view files directly
ls -la /Users/jederlichman/.claude-worktrees/dev-infra/awesome-sinoussi/scripts/
```

---

*Thank you for the thorough reviews on v1.0 and v2.0. Your feedback significantly improved the design.*
