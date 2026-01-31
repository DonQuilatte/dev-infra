# Architecture Evaluation: 1Password & Headless Agent Operations

**Date:** 2026-01-31
**Evaluator:** Claude (requested by J. Ederlichman)
**Scope:** Brain/Agent distributed development infrastructure

---

## Executive Summary

The Brain/Agent architecture is well-designed and functional for interactive use. However, **headless/automated operations on Agent Alpha (TW Mac) are broken** due to missing 1Password Service Account configuration. This blocks any automation that requires secrets.

**Severity:** High
**Effort to fix:** Low (< 1 hour)

---

## Current Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         BRAIN (Main Mac)                        │
│  - User interaction, orchestration, decision-making             │
│  - 1Password: Service Account token at ~/.config/op/claude-dev-token │
│  - Secrets injected via wrapper functions in .zshrc             │
└─────────────────────────────────────────────────────────────────┘
                              │
                    SSH / SMB / Tailscale
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    AGENT ALPHA (TW Mac)                         │
│  - Task execution, builds, long-running processes               │
│  - 1Password: ❌ Token file MISSING                             │
│  - LaunchAgents: Hardcoded tokens (ClawdBot only)               │
│  - Interactive shells: op CLI prompts GUI approval ⚠️           │
└─────────────────────────────────────────────────────────────────┘
```

---

## Problem Statement

### Symptoms
- TW Mac shows 1Password GUI approval dialogs during headless operations
- Automated tasks requiring secrets hang or fail silently
- `op read` commands fail unless user is logged in via GUI

### Root Cause
1. **Missing token file:** `~/.config/op/claude-dev-token` exists on Brain but not on TW Mac
2. **Code without data:** TW Mac `.zshrc` has the injection logic but no token to inject
3. **LaunchAgents bypass:** Services like ClawdBot have hardcoded tokens, masking the systemic issue

### What Works (Accidentally)
| Component | Status | Why |
|-----------|--------|-----|
| ClawdBot Gateway | ✅ Works | Token hardcoded in plist |
| SSH dispatch | ✅ Works | No secrets needed |
| Manual `op read` | ⚠️ Prompts GUI | Falls back to interactive auth |
| Automated secrets | ❌ Broken | No service account token |

---

## Evidence

### Brain (Correctly Configured)
```bash
$ cat ~/.config/op/claude-dev-token | head -c 20
ops_eyJzaWduSW5BZGRy...  # Token present
```

### TW Mac (Missing Configuration)
```bash
$ cat ~/.config/op/claude-dev-token
TOKEN FILE MISSING

$ env | grep OP_
# (empty)

$ ls ~/.config/op/
config
op-daemon.sock
# No token file
```

### TW Mac .zshrc (Has Logic, No Token)
```bash
_op_inject_secrets() {
    local token_file="$HOME/.config/op/claude-dev-token"
    if [[ -f "$token_file" ]]; then  # ❌ File doesn't exist
        export OP_SERVICE_ACCOUNT_TOKEN="$(cat "$token_file")"
    fi
    ...
}
```

---

## Recommendation

### Immediate Fix (5 minutes)

Deploy the service account token to TW Mac:

```bash
# From Brain
scp ~/.config/op/claude-dev-token tw:~/.config/op/
ssh tw "chmod 600 ~/.config/op/claude-dev-token"
```

Verify:
```bash
ssh tw "export OP_SERVICE_ACCOUNT_TOKEN=\$(cat ~/.config/op/claude-dev-token) && op read 'op://Developer/OpenProject/credential'"
```

### Production Hardening (Optional, 30 min)

1. **LaunchAgent integration** - Add `OP_SERVICE_ACCOUNT_TOKEN` to all LaunchAgents that need secrets:
   ```xml
   <key>EnvironmentVariables</key>
   <dict>
       <key>OP_SERVICE_ACCOUNT_TOKEN</key>
       <string>ops_...</string>
   </dict>
   ```

2. **Remove hardcoded tokens** - ClawdBot Gateway has `CLAWDBOT_GATEWAY_TOKEN` hardcoded. Move to 1Password:
   ```xml
   <!-- Before: hardcoded -->
   <string>dc300ff6840007d7ce6fe700f42a95f8736435eee183a491</string>

   <!-- After: reference (requires wrapper script) -->
   <!-- Use op:// in .envrc and launch via wrapper -->
   ```

3. **Sync script** - Add token sync to `tw-env-sync`:
   ```bash
   # In tw-env-sync.sh
   scp ~/.config/op/claude-dev-token tw:~/.config/op/
   ```

---

## Security Considerations

| Concern | Mitigation |
|---------|------------|
| Token at rest on TW Mac | File permissions 600, in user home |
| Token scope | Service Account scoped to Developer vault only |
| Token rotation | Rotate via 1Password console, redeploy |
| Network exposure | Token never transmitted after initial scp |

**Acceptable risk:** The service account is already scoped to Developer vault (non-sensitive API keys). The token file approach matches Brain's existing pattern.

---

## Action Items

| Priority | Task | Owner | Status |
|----------|------|-------|--------|
| P0 | Deploy token to TW Mac | — | ⬜ Not started |
| P1 | Verify headless `op read` works | — | ⬜ Blocked |
| P2 | Add to tw-env-sync | — | ⬜ Not started |
| P3 | Audit LaunchAgents for hardcoded secrets | — | ⬜ Not started |

---

## Appendix: Files Reviewed

- `~/.config/op/claude-dev-token` (Brain) - Present ✅
- `~/.config/op/claude-dev-token` (TW Mac) - Missing ❌
- `~/.zshrc` (both machines) - Logic present, token missing on TW
- `~/.claude/orchestration/agents.json` - Agent registry
- `~/Library/LaunchAgents/com.clawdbot.gateway.plist` - Hardcoded token
- `/Users/jederlichman/bin/agent*`, `/Users/jederlichman/bin/tw*` - Control scripts
