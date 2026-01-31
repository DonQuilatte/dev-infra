#!/bin/bash
# secrets-refresh-wrapper.sh - LaunchAgent wrapper for secrets refresh
# Handles logging, error recovery, and periodic refresh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$HOME/.local/log/dev-infra"
LOG_FILE="$LOG_DIR/secrets-refresh.log"
LOCK_FILE="/tmp/secrets-refresh.lock"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Prevent concurrent runs
acquire_lock() {
    if [ -f "$LOCK_FILE" ]; then
        local pid=$(cat "$LOCK_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            log "Another instance running (PID $pid), skipping"
            exit 0
        fi
    fi
    echo $$ > "$LOCK_FILE"
    trap 'rm -f "$LOCK_FILE"' EXIT
}

# Main
main() {
    acquire_lock

    log "=== Secrets refresh started ==="

    # Set up 1Password auth
    if [ -f "$HOME/.config/op/claude-dev-token" ]; then
        export OP_SERVICE_ACCOUNT_TOKEN=$(cat "$HOME/.config/op/claude-dev-token")
    elif [ -f "$HOME/.config/op/service-account-token" ]; then
        export OP_SERVICE_ACCOUNT_TOKEN=$(cat "$HOME/.config/op/service-account-token")
    else
        log "ERROR: No 1Password token found"
        exit 1
    fi

    # Run the refresh
    export LOG_FILE
    if "$SCRIPT_DIR/secrets-refresh.sh" >> "$LOG_FILE" 2>&1; then
        log "=== Secrets refresh completed successfully ==="
    else
        local exit_code=$?
        log "=== Secrets refresh failed (exit code: $exit_code) ==="

        # Optional: Send notification on failure
        if command -v osascript &>/dev/null; then
            osascript -e 'display notification "Secrets refresh failed - check logs" with title "Dev Infrastructure"' 2>/dev/null || true
        fi

        exit $exit_code
    fi

    # Rotate log if too large (>10MB)
    if [ -f "$LOG_FILE" ] && [ $(stat -f%z "$LOG_FILE") -gt 10485760 ]; then
        mv "$LOG_FILE" "$LOG_FILE.old"
        log "Log rotated"
    fi
}

main "$@"
