# Claude Code: Rewrite Dev-Infra Scripts to Match RFC

## Context

The current implementation in `5fa2fe6` doesn't match the RFC specs. Rewrite the scripts to implement the reviewed and approved architecture.

## Reference Documents

Read these first:
- `docs/MCP_SECRETS_ARCHITECTURE.md` - RFC v2.1 (the source of truth)
- `docs/DEV_INFRA_IMPLEMENTATION_PLAN.md` - Implementation details
- `docs/CODEX_REVIEW_PHASE4.md` - Verification checklist

## Scripts to Rewrite

### 1. `scripts/secrets-refresh.sh`

**Current:** Plaintext cache in `/tmp`, global scope, md5 filenames
**Required:**
- age encryption with keypair (`-r` for encrypt, `-i` for decrypt)
- Per-project cache: `~/.cache/dev-infra/projects/<hash>/secrets.enc`
- Cache key = sha256 of absolute project path (first 12 chars)
- Only cache secrets for servers in `.enabled-servers` + `.enabled-servers.local`
- Create `secrets.meta` with epoch timestamps:
  ```json
  {
    "refreshed_at": <epoch>,
    "soft_expires_at": <epoch + 14400>,
    "hard_expires_at": <epoch + 86400>
  }
  ```
- Namespaced keys: `server.ENV_VAR` format in encrypted cache
- Support `--path <dir>` flag (default: current directory)
- Read server definitions from `~/.config/dev-infra/mcp-registry.json`

### 2. `scripts/mcp-launcher.sh`

**Current:** Hard-coded MCP_ENV, string exec, no TTL check
**Required:**
- Check cache TTL before launch:
  - Fresh (< soft TTL): proceed
  - Soft expired (4-24hr): warn, attempt refresh, proceed anyway
  - Hard expired (> 24hr): attempt refresh, fail if refresh fails
- Decrypt secrets with `age -d -i <identity>`
- Extract secrets for requested server only
- Strip namespace prefix for export (`server.ENV_VAR` → `ENV_VAR`)
- Array-safe command execution:
  ```bash
  readarray -t cmd < <(jq -r ".servers.\"$SERVER\".command[]" "$REGISTRY")
  exec "${cmd[@]}"
  ```
- Support `--path <dir>` flag

### 3. `scripts/dev-infra`

**Current:** Limited subcommands, no project registry, no --path
**Required CLI surface:**
```
dev-infra secrets refresh [--path <dir>]     # Refresh single project
dev-infra secrets refresh-all                # Refresh all in projects.json
dev-infra secrets clear [--path <dir>]       # Clear project cache
dev-infra secrets status [--path <dir>]      # Show cache status/TTL

dev-infra mcp <server> [--path <dir>]        # Launch MCP server
dev-infra mcp list                           # List available servers
dev-infra mcp enable <server> [--path <dir>] # Add to .enabled-servers
dev-infra mcp disable <server> [--path <dir>]# Remove from .enabled-servers

dev-infra projects list                      # List registered projects
dev-infra projects add [--path <dir>]        # Add to projects.json
dev-infra projects remove [--path <dir>]     # Remove from projects.json

dev-infra init <name> [template]             # Scaffold new project
dev-infra health                             # Check infrastructure
dev-infra sync <agent>                       # Sync to agent
```

### 4. `scripts/secrets-refresh-wrapper.sh`

**Current:** Prefers `claude-dev-token`, calls `secrets-refresh.sh` directly
**Required:**
```bash
#!/usr/bin/env bash
set -euo pipefail

# Load service account token (headless operation)
if [[ -f "$HOME/.config/op/service-account-token" ]]; then
    export OP_SERVICE_ACCOUNT_TOKEN=$(cat "$HOME/.config/op/service-account-token")
fi

# Refresh all registered projects
exec "$HOME/Development/Projects/dev-infra/scripts/dev-infra" secrets refresh-all
```

## Templates to Update

### All templates (`templates/project/{default,api,cli,library}/`)

Add to each template directory:
```
.enabled-servers        # Empty file or with default servers
```

Update `.gitignore` in each template:
```
# Dev-infra local overrides
.enabled-servers.local
```

## Configuration Files

Ensure these exist at `~/.config/dev-infra/`:

### `mcp-registry.json`
```json
{
  "servers": {
    "tiger": {
      "command": ["npx", "-y", "@anthropic/tiger-mcp"],
      "secrets": {
        "tiger.TIGER_API_KEY": "op://Developer/Tiger/api-key"
      }
    }
  }
}
```

### `projects.json`
```json
{
  "projects": []
}
```

### `age/identity.txt` and `age/recipient.txt`
```bash
# Generate if missing
mkdir -p ~/.config/dev-infra/age
age-keygen -o ~/.config/dev-infra/age/identity.txt 2>&1 | \
  grep "public key:" | awk '{print $3}' > ~/.config/dev-infra/age/recipient.txt
chmod 600 ~/.config/dev-infra/age/identity.txt
chmod 644 ~/.config/dev-infra/age/recipient.txt
```

## Verification

After implementation, run these checks:

```bash
# 1. Age keypair exists
ls -la ~/.config/dev-infra/age/

# 2. Fresh cache build
mkdir -p /tmp/test-project
echo "tiger" > /tmp/test-project/.enabled-servers
dev-infra secrets refresh --path /tmp/test-project
ls -la ~/.cache/dev-infra/projects/

# 3. Cache structure correct
# Should see: <12-char-hash>/secrets.enc, <12-char-hash>/secrets.meta

# 4. MCP launch works
cd /tmp/test-project
dev-infra mcp tiger
# Should export TIGER_API_KEY (not tiger.TIGER_API_KEY)

# 5. Project registry
dev-infra projects add --path /tmp/test-project
dev-infra projects list
dev-infra secrets refresh-all
```

## Commit Message

```
feat: rewrite secrets management to match RFC v2.1

- Age keypair encryption for cached secrets
- Per-project cache isolation (sha256 hash of path)
- Soft/hard TTL strategy (4hr warn, 24hr fail)
- Namespaced secrets (server.ENV_VAR)
- Project registry with refresh-all
- Array-safe command execution
- Full CLI surface (secrets, mcp, projects subcommands)
- Template scaffolding for .enabled-servers

Addresses findings from Codex CLI review.
```

## Do NOT

- Leave any plaintext secrets in cache
- Use md5 for cache keys (use sha256)
- Hard-code server definitions in scripts
- Use string exec (use array exec)
- Skip TTL checks in launcher
- Forget `--path` support on relevant commands
