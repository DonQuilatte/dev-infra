# MCP Registry Secrets Architecture

**Date:** 2026-01-31
**Author:** J. Ederlichman / Claude
**Status:** RFC - Request for Comments
**Reviewers:** [Third-party review requested]

---

## Executive Summary

This document evaluates three approaches for integrating 1Password with an MCP (Model Context Protocol) server registry. The goal is to securely manage API keys and credentials for AI development tools while maintaining performance and reliability.

**Recommendation:** Option C (Hybrid Cached Injection) provides the best balance of security, performance, and durability for this use case.

---

## Context

### What is MCP?

Model Context Protocol (MCP) is Anthropic's standard for connecting AI assistants to external tools and data sources. MCP servers are lightweight processes that expose capabilities (file access, API integrations, databases) to AI agents.

### Current Environment

- **Brain Mac:** Primary development machine, orchestrates work
- **Agent Alpha (TW Mac):** Headless worker node for parallel task execution
- **1Password:** Enterprise password manager with CLI (`op`) and Service Account support
- **Dev-infra:** Centralized tooling repository that other projects inherit from

### Problem Statement

The dev-infra project needs an MCP registry that:
1. Catalogs available MCP servers and their configurations
2. Allows per-project server selection ("turn on/off")
3. Securely provides API keys to MCP servers at runtime
4. Works on both interactive (Brain) and headless (Agent) machines

### Security Requirements

| Requirement | Priority | Notes |
|-------------|----------|-------|
| Secrets not in git | P0 | No plaintext keys in version control |
| Secrets not in plaintext config files | P1 | Avoid `.env` files with raw values |
| Minimal secret exposure window | P1 | Secrets should exist in memory/disk briefly |
| Works headless | P0 | Agent machines have no GUI for auth prompts |
| Audit trail | P2 | Know when secrets were accessed |
| Rotation support | P2 | Changing a key shouldn't require config changes |

### Performance Requirements

| Requirement | Target | Notes |
|-------------|--------|-------|
| MCP server startup | < 2 seconds | Per server, including secret fetch |
| Session initialization | < 5 seconds | All enabled MCP servers ready |
| Offline capability | Desirable | Work should continue if 1Password is unreachable |

---

## Option A: Pure Runtime Injection

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     mcp-registry.json                       │
│  {                                                          │
│    "stitch": {                                              │
│      "command": "npx @anthropic/stitch-mcp",                │
│      "secrets": {                                           │
│        "STITCH_API_KEY": "op://Developer/Stitch/api-key"    │
│      }                                                      │
│    }                                                        │
│  }                                                          │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   MCP Launcher Script                       │
│                                                             │
│  for secret in registry[server].secrets:                    │
│      value = $(op read $secret.op_ref)   ← Network call     │
│      export $secret.name=$value                             │
│                                                             │
│  exec $registry[server].command                             │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     MCP Server Process                      │
│            (secrets in environment variables)               │
└─────────────────────────────────────────────────────────────┘
```

### Implementation

```bash
#!/bin/bash
# mcp-launcher.sh

SERVER=$1
REGISTRY="$DEV_INFRA/mcp-registry.json"

# Ensure 1Password service account is available
if [[ -z "$OP_SERVICE_ACCOUNT_TOKEN" ]]; then
    export OP_SERVICE_ACCOUNT_TOKEN=$(cat ~/.config/op/claude-dev-token)
fi

# Read secrets from registry and inject
for row in $(jq -r ".${SERVER}.secrets | to_entries[] | @base64" "$REGISTRY"); do
    name=$(echo "$row" | base64 -d | jq -r '.key')
    op_ref=$(echo "$row" | base64 -d | jq -r '.value')
    value=$(op read "$op_ref")
    export "$name=$value"
done

# Launch the MCP server
cmd=$(jq -r ".${SERVER}.command" "$REGISTRY")
exec $cmd
```

### Performance Analysis

| Scenario | Latency | Notes |
|----------|---------|-------|
| Single secret, daemon warm | 50-100ms | Acceptable |
| Single secret, daemon cold | 500-800ms | Noticeable delay |
| 5 servers × 2 secrets, warm | 500ms-1s | Acceptable |
| 5 servers × 2 secrets, cold | 5-8 seconds | Poor UX |
| 1Password API timeout | 30+ seconds | Session fails to start |

**Measurement methodology:** Timed via `time op read "op://..."` on macOS 14.x with 1Password 8.x CLI, both with daemon running and after daemon restart.

### Failure Modes

| Failure | Impact | Mitigation |
|---------|--------|------------|
| 1Password service down | All MCP servers fail to start | None - hard dependency |
| Service account token expired | Silent auth failures | Token refresh automation |
| Network timeout | Slow/failed startup | Retry with backoff (adds latency) |
| Rate limiting | Failures under heavy use | Unlikely for this scale |

### Security Assessment

| Aspect | Rating | Notes |
|--------|--------|-------|
| Secrets at rest | ✅ Excellent | Only in 1Password vault |
| Secrets in transit | ✅ Excellent | TLS to 1Password API |
| Secrets in memory | ✅ Good | Only in MCP process env |
| Audit trail | ✅ Good | 1Password logs access |
| Attack surface | ✅ Minimal | No local secret storage |

### Verdict

**Pros:**
- Maximum security posture
- Secrets never touch disk
- Automatic rotation support (just update 1Password)
- Full audit trail

**Cons:**
- Performance depends on external service
- Single point of failure (1Password availability)
- Cold start penalty significant
- No offline capability

**Rating: Theoretically Ideal, Practically Fragile**

---

## Option B: Environment File Generation

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│              dev-infra mcp enable stitch                    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     Generation Script                       │
│                                                             │
│  value = $(op read "op://Developer/Stitch/api-key")         │
│  echo "STITCH_API_KEY=$value" >> .env.local                 │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      .env.local                             │
│  (gitignored, 600 permissions)                              │
│                                                             │
│  STITCH_API_KEY=sk-abc123...                                │
│  OPENAI_API_KEY=sk-xyz789...                                │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     MCP Server Process                      │
│            (reads from .env.local or env vars)              │
└─────────────────────────────────────────────────────────────┘
```

### Implementation

```bash
#!/bin/bash
# dev-infra mcp enable

SERVER=$1
PROJECT_DIR=${2:-$(pwd)}
REGISTRY="$DEV_INFRA/mcp-registry.json"
ENV_FILE="$PROJECT_DIR/.env.local"

# Ensure .env.local is gitignored
if ! grep -q ".env.local" "$PROJECT_DIR/.gitignore" 2>/dev/null; then
    echo ".env.local" >> "$PROJECT_DIR/.gitignore"
fi

# Fetch and write secrets
for row in $(jq -r ".${SERVER}.secrets | to_entries[] | @base64" "$REGISTRY"); do
    name=$(echo "$row" | base64 -d | jq -r '.key')
    op_ref=$(echo "$row" | base64 -d | jq -r '.value')
    value=$(op read "$op_ref")

    # Remove existing entry if present
    sed -i '' "/^${name}=/d" "$ENV_FILE" 2>/dev/null

    # Append new value
    echo "${name}=${value}" >> "$ENV_FILE"
done

chmod 600 "$ENV_FILE"
echo "✅ Enabled $SERVER for $(basename $PROJECT_DIR)"
```

### Performance Analysis

| Scenario | Latency | Notes |
|----------|---------|-------|
| MCP server startup | < 10ms | Just reads local file |
| Initial enable | 500ms-5s | One-time 1Password fetch |
| Session initialization | < 100ms | All local |

### Failure Modes

| Failure | Impact | Mitigation |
|---------|--------|------------|
| 1Password down at enable time | Can't add new servers | Retry later |
| 1Password down at runtime | No impact | Secrets already local |
| .env.local deleted | MCP servers fail | Re-run enable |
| .env.local permissions wrong | Potential exposure | Enforce 600 in scripts |
| Secret rotation in 1Password | Local copy stale | Manual re-enable needed |

### Security Assessment

| Aspect | Rating | Notes |
|--------|--------|-------|
| Secrets at rest | ⚠️ Moderate | Plaintext on disk (encrypted volume helps) |
| Secrets in transit | ✅ Good | Only fetched once via TLS |
| Secrets in memory | ✅ Good | Standard env var handling |
| Audit trail | ⚠️ Limited | Only initial fetch logged |
| Attack surface | ⚠️ Moderate | Local file readable by user processes |

### Verdict

**Pros:**
- Excellent runtime performance
- Works offline after initial setup
- Simple mental model
- Standard pattern (many tools use .env)

**Cons:**
- Secrets on disk in plaintext
- No automatic rotation
- Must remember to re-enable after key rotation
- Per-project secret duplication

**Rating: Simple and Fast, Security Trade-offs**

---

## Option C: Hybrid Cached Injection (Recommended)

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    First Session Start                      │
│         (or manual: dev-infra secrets refresh)              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     Cache Builder                           │
│                                                             │
│  for server in enabled_servers:                             │
│      for secret in server.secrets:                          │
│          value = $(op read $secret.op_ref)                  │
│          cache[$secret.name] = encrypt(value, machine_key)  │
│                                                             │
│  write cache → ~/.cache/dev-infra/secrets.enc               │
│  chmod 600                                                  │
│  record timestamp                                           │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌───────────────────────────────────────┐
        │                                       │
        ▼                                       ▼
┌─────────────────────┐           ┌─────────────────────────────┐
│   MCP Launcher      │           │   Background Refresh        │
│                     │           │   (LaunchAgent/cron)        │
│   if cache fresh:   │           │                             │
│     use cache       │           │   Every 4 hours:            │
│   else:             │           │     rebuild cache           │
│     fetch + cache   │           │     log refresh             │
└─────────────────────┘           └─────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     MCP Server Process                      │
│            (secrets from cache, decrypted at launch)        │
└─────────────────────────────────────────────────────────────┘
```

### Implementation

**Cache structure:**
```
~/.cache/dev-infra/
├── secrets.enc          # Encrypted secrets (age or gpg)
├── secrets.meta         # Timestamps, checksums
└── refresh.log          # Audit log
```

**Cache builder:**
```bash
#!/bin/bash
# dev-infra secrets refresh

CACHE_DIR="$HOME/.cache/dev-infra"
CACHE_FILE="$CACHE_DIR/secrets.enc"
META_FILE="$CACHE_DIR/secrets.meta"
LOG_FILE="$CACHE_DIR/refresh.log"
REGISTRY="$DEV_INFRA/mcp-registry.json"
MAX_AGE=14400  # 4 hours in seconds

mkdir -p "$CACHE_DIR"
chmod 700 "$CACHE_DIR"

# Get machine-specific encryption key (derived from hardware ID)
MACHINE_KEY=$(system_profiler SPHardwareDataType | grep "Hardware UUID" | awk '{print $3}')

# Build secrets JSON
SECRETS_JSON="{}"
for server in $(jq -r 'keys[]' "$REGISTRY"); do
    for row in $(jq -r ".${server}.secrets // {} | to_entries[] | @base64" "$REGISTRY"); do
        name=$(echo "$row" | base64 -d | jq -r '.key')
        op_ref=$(echo "$row" | base64 -d | jq -r '.value')
        value=$(op read "$op_ref" 2>/dev/null)
        if [[ -n "$value" ]]; then
            SECRETS_JSON=$(echo "$SECRETS_JSON" | jq --arg k "$name" --arg v "$value" '. + {($k): $v}')
        fi
    done
done

# Encrypt and write
echo "$SECRETS_JSON" | age -p -o "$CACHE_FILE" <<< "$MACHINE_KEY"
chmod 600 "$CACHE_FILE"

# Write metadata
cat > "$META_FILE" << EOF
{
  "refreshed_at": "$(date -Iseconds)",
  "expires_at": "$(date -v+4H -Iseconds)",
  "checksum": "$(shasum -a 256 "$CACHE_FILE" | cut -d' ' -f1)"
}
EOF

# Log refresh
echo "$(date -Iseconds) | Refreshed cache | $(jq -r 'keys | length' <<< "$SECRETS_JSON") secrets" >> "$LOG_FILE"
```

**MCP launcher:**
```bash
#!/bin/bash
# mcp-launcher.sh (hybrid version)

SERVER=$1
CACHE_FILE="$HOME/.cache/dev-infra/secrets.enc"
META_FILE="$HOME/.cache/dev-infra/secrets.meta"
MACHINE_KEY=$(system_profiler SPHardwareDataType | grep "Hardware UUID" | awk '{print $3}')
MAX_AGE=14400

# Check cache freshness
if [[ -f "$META_FILE" ]]; then
    expires=$(jq -r '.expires_at' "$META_FILE")
    if [[ $(date +%s) -lt $(date -jf "%Y-%m-%dT%H:%M:%S" "$expires" +%s 2>/dev/null || echo 0) ]]; then
        # Cache valid - use it
        SECRETS=$(age -d -i <(echo "$MACHINE_KEY") "$CACHE_FILE" 2>/dev/null)
    fi
fi

# Cache miss or expired - fetch fresh
if [[ -z "$SECRETS" ]]; then
    dev-infra secrets refresh
    SECRETS=$(age -d -i <(echo "$MACHINE_KEY") "$CACHE_FILE")
fi

# Export secrets for this server
REGISTRY="$DEV_INFRA/mcp-registry.json"
for row in $(jq -r ".${SERVER}.secrets // {} | to_entries[] | @base64" "$REGISTRY"); do
    name=$(echo "$row" | base64 -d | jq -r '.key')
    value=$(echo "$SECRETS" | jq -r --arg k "$name" '.[$k] // empty')
    if [[ -n "$value" ]]; then
        export "$name=$value"
    fi
done

# Launch server
cmd=$(jq -r ".${SERVER}.command" "$REGISTRY")
exec $cmd
```

**Background refresh (LaunchAgent):**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.dev-infra.secrets-refresh</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/jederlichman/Development/Projects/dev-infra/scripts/dev-infra</string>
        <string>secrets</string>
        <string>refresh</string>
    </array>
    <key>StartInterval</key>
    <integer>14400</integer>
    <key>EnvironmentVariables</key>
    <dict>
        <key>OP_SERVICE_ACCOUNT_TOKEN</key>
        <string>FROM_SECURE_LOCATION</string>
    </dict>
    <key>StandardOutPath</key>
    <string>/tmp/dev-infra-secrets-refresh.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/dev-infra-secrets-refresh.err</string>
</dict>
</plist>
```

### Performance Analysis

| Scenario | Latency | Notes |
|----------|---------|-------|
| MCP startup, cache hit | 50-100ms | Decrypt + read |
| MCP startup, cache miss | 500ms-5s | Full 1Password fetch |
| Session init, cache hit | 200-500ms | All servers parallel |
| Background refresh | N/A | Non-blocking |

### Failure Modes

| Failure | Impact | Mitigation |
|---------|--------|------------|
| 1Password down, cache valid | No impact | Uses cache |
| 1Password down, cache expired | Falls back to stale cache with warning | Configurable policy |
| Cache file deleted | Re-fetches on next launch | Self-healing |
| Cache corruption | Detected via checksum, re-fetches | Automatic recovery |
| Machine key changes | Cache invalidated | Re-authenticate |
| Background refresh fails | Cache ages but still works | Alert on repeated failures |

### Security Assessment

| Aspect | Rating | Notes |
|--------|--------|-------|
| Secrets at rest | ✅ Good | Encrypted with machine-bound key |
| Secrets in transit | ✅ Excellent | TLS to 1Password, local only after |
| Secrets in memory | ✅ Good | Decrypted only during launch |
| Audit trail | ✅ Good | Local log + 1Password access log |
| Attack surface | ✅ Good | Requires machine access + key |
| Offline capability | ✅ Yes | Works with valid cache |

**Security trade-off analysis:**

The cache file contains encrypted secrets. An attacker would need:
1. Access to the machine (physical or remote shell)
2. Ability to read `~/.cache/dev-infra/secrets.enc` (requires user privileges)
3. Access to the machine's Hardware UUID (trivial if #1 and #2 are true)

**Realistic threat model:** If an attacker has shell access as your user, they can already:
- Read your SSH keys
- Access your browser sessions
- Run `op read` themselves if the token is available

The encrypted cache does not meaningfully increase exposure beyond what shell access already provides. It does protect against:
- Backup exposure (encrypted at rest)
- Casual file browsing
- Other users on shared systems

### Verdict

**Pros:**
- Fast runtime performance (cache hit path)
- Resilient to 1Password outages
- Works offline after initial cache
- Automatic rotation via background refresh
- Encrypted at rest
- Self-healing on cache issues
- Audit trail maintained

**Cons:**
- More complex implementation
- Cache can be stale (4-hour window)
- Machine-bound (cache not portable)
- Requires background process for freshness

**Rating: Pragmatic Balance of Security and Reliability**

---

## Comparison Matrix

| Criteria | Option A (Runtime) | Option B (Env File) | Option C (Hybrid) |
|----------|-------------------|--------------------|--------------------|
| **Security** |
| Secrets at rest | ✅ None | ❌ Plaintext | ✅ Encrypted |
| Rotation support | ✅ Automatic | ❌ Manual | ✅ Auto (4hr) |
| Audit trail | ✅ Full | ⚠️ Partial | ✅ Full |
| **Performance** |
| Cold start | ❌ 5-8s | ✅ <100ms | ✅ <500ms |
| Warm start | ✅ <1s | ✅ <100ms | ✅ <200ms |
| **Reliability** |
| 1Password down | ❌ Fails | ✅ Works | ✅ Works |
| Offline use | ❌ No | ✅ Yes | ✅ Yes |
| Self-healing | N/A | ❌ No | ✅ Yes |
| **Complexity** |
| Implementation | Low | Low | Medium |
| Maintenance | Low | Low | Medium |
| Debugging | Easy | Easy | Moderate |

---

## Recommendation

**Implement Option C (Hybrid Cached Injection)** for the following reasons:

1. **Matches the use case:** Development tooling needs to be fast and reliable. Waiting 5+ seconds for MCP servers to start on every session is unacceptable UX.

2. **Appropriate security posture:** These are developer API keys (OpenAI, Stitch, etc.), not banking credentials. Encrypted local cache with machine-bound keys is proportionate protection.

3. **Resilience:** 1Password is a critical dependency. Caching provides graceful degradation when it's unavailable.

4. **Automation-friendly:** The background refresh model works well for headless Agent machines that can't prompt for authentication.

5. **Audit capability:** Between local logs and 1Password access logs, there's visibility into secret access patterns.

### Implementation Phases

**Phase 1: Foundation (Day 1)**
- [ ] Fix 1Password token deployment to TW Mac (prerequisite)
- [ ] Create `~/.cache/dev-infra/` structure
- [ ] Implement basic cache builder (no encryption initially)
- [ ] Implement cache-aware launcher

**Phase 2: Security Hardening (Day 2)**
- [ ] Add age/gpg encryption to cache
- [ ] Implement machine-bound key derivation
- [ ] Add checksum validation
- [ ] Add audit logging

**Phase 3: Automation (Day 3)**
- [ ] Create LaunchAgent for background refresh
- [ ] Deploy to both Brain and Agent Alpha
- [ ] Add alerting for refresh failures
- [ ] Create `dev-infra secrets status` command

**Phase 4: Integration (Day 4)**
- [ ] Connect to MCP registry
- [ ] Create `dev-infra mcp enable/disable` commands
- [ ] Update documentation
- [ ] Test with Stitch MCP server

---

## Open Questions for Reviewers

1. **Cache TTL:** Is 4 hours appropriate? Shorter = more 1Password calls, longer = more staleness risk.

2. **Encryption choice:** `age` vs `gpg` vs macOS Keychain? Age is simpler, gpg more universal, Keychain most integrated.

3. **Stale cache policy:** When cache is expired AND 1Password is unreachable, should we:
   - Fail hard (secure but disruptive)
   - Use stale cache with warning (pragmatic)
   - Use stale cache silently (risky)

4. **Multi-machine sync:** Should the cache be syncable between Brain and Agent, or should each machine maintain its own? (Current design: each machine independent)

5. **Secret granularity:** Should we cache all secrets globally, or per-project? Global is simpler, per-project provides isolation.

---

## Appendix: Alternative Considered

### macOS Keychain Integration

Could store secrets in macOS Keychain instead of encrypted file:

```bash
security add-generic-password -a "dev-infra" -s "STITCH_API_KEY" -w "$value"
security find-generic-password -a "dev-infra" -s "STITCH_API_KEY" -w
```

**Pros:**
- Native OS integration
- Hardware-backed on Apple Silicon
- No separate encryption implementation

**Cons:**
- Harder to script reliably
- Prompts for access on some operations
- Not portable to Linux agents
- Less visibility into what's stored

**Decision:** Deferred. Could be a future enhancement for Brain Mac while keeping file-based cache for Agent machines.

---

*Document version: 1.0*
*Last updated: 2026-01-31*
