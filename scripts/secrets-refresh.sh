#!/bin/bash
# secrets-refresh.sh - Build/refresh the secrets cache from 1Password
# Called by dev-infra CLI and LaunchAgent

set -e

SECRETS_CACHE="${XDG_RUNTIME_DIR:-/tmp}/dev-infra-secrets"
SECRETS_MANIFEST="${SECRETS_MANIFEST:-$HOME/.config/dev-infra/secrets.manifest}"
LOG_FILE="${LOG_FILE:-/tmp/secrets-refresh.log}"

log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
    echo "$msg" | tee -a "$LOG_FILE"
}

# Ensure 1Password is authenticated
ensure_op_auth() {
    # Check for service account token
    if [ -n "$OP_SERVICE_ACCOUNT_TOKEN" ]; then
        return 0
    fi

    # Try to load from file
    local token_file="$HOME/.config/op/service-account-token"
    if [ -f "$token_file" ]; then
        export OP_SERVICE_ACCOUNT_TOKEN=$(cat "$token_file")
        return 0
    fi

    # Fall back to claude-dev-token
    token_file="$HOME/.config/op/claude-dev-token"
    if [ -f "$token_file" ]; then
        export OP_SERVICE_ACCOUNT_TOKEN=$(cat "$token_file")
        return 0
    fi

    log "ERROR: No 1Password authentication available"
    return 1
}

# Refresh a single secret
refresh_secret() {
    local ref="$1"
    local cache_key=$(echo "$ref" | md5 -q)
    local cache_file="$SECRETS_CACHE/$cache_key"

    if value=$(op read "$ref" 2>/dev/null); then
        echo "$value" > "$cache_file"
        chmod 600 "$cache_file"
        log "Cached: $ref"
        return 0
    else
        log "WARN: Failed to read: $ref"
        return 1
    fi
}

# Default secrets to cache (common across projects)
default_secrets() {
    cat << 'EOF'
op://Developer/Anthropic Claude/API Key
op://Private/Clawdbot Gateway Token/token
op://Developer/GitHub/token
op://Developer/npm/token
EOF
}

# Load secrets manifest
load_manifest() {
    if [ -f "$SECRETS_MANIFEST" ]; then
        cat "$SECRETS_MANIFEST"
    else
        default_secrets
    fi
}

# Main
main() {
    log "Starting secrets refresh..."

    # Ensure authentication
    ensure_op_auth || exit 1

    # Verify authentication works
    if ! op whoami &>/dev/null; then
        log "ERROR: 1Password authentication failed"
        exit 1
    fi

    # Create cache directory
    mkdir -p "$SECRETS_CACHE"
    chmod 700 "$SECRETS_CACHE"

    # Track stats
    local total=0
    local success=0
    local failed=0

    # Refresh each secret
    while IFS= read -r ref || [ -n "$ref" ]; do
        # Skip empty lines and comments
        [[ -z "$ref" || "$ref" == \#* ]] && continue

        total=$((total + 1))
        if refresh_secret "$ref"; then
            success=$((success + 1))
        else
            failed=$((failed + 1))
        fi
    done < <(load_manifest)

    log "Refresh complete: $success/$total succeeded, $failed failed"

    # Also refresh any project-specific secrets
    if [ -f ".env.op" ]; then
        log "Found .env.op - refreshing project secrets..."
        while IFS='=' read -r key ref || [ -n "$key" ]; do
            [[ -z "$key" || "$key" == \#* ]] && continue
            refresh_secret "$ref" || true
        done < ".env.op"
    fi

    log "Secrets cache ready: $SECRETS_CACHE"
}

# Run if not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
