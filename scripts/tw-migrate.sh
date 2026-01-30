#!/bin/bash
# tw-migrate.sh - Run migration on TW Mac from Controller Mac
# Usage: ./scripts/tw-migrate.sh

set -e

TW_HOST="tywhitaker@tw.local"
TW_IP="100.81.110.81"  # Tailscale IP fallback

echo "TW Mac Migration: clawdbot → dev-infra"
echo "======================================="
echo ""

# Try to connect
echo "Connecting to TW Mac..."
if ssh -o ConnectTimeout=5 "$TW_HOST" "echo ok" >/dev/null 2>&1; then
    TARGET="$TW_HOST"
elif ssh -o ConnectTimeout=5 "tywhitaker@$TW_IP" "echo ok" >/dev/null 2>&1; then
    TARGET="tywhitaker@$TW_IP"
else
    echo "ERROR: Cannot connect to TW Mac"
    echo "Check: ~/bin/tw status"
    exit 1
fi

echo "Connected via: $TARGET"
echo ""

# Step 1: Ensure repo exists and is updated
echo "Step 1: Updating repository on TW Mac..."
ssh "$TARGET" << 'REMOTE_SCRIPT'
set -e
PROJECT_DIR="$HOME/Development/Projects/dev-infra"
OLD_DIR="$HOME/Development/Projects/clawdbot"

# Check if we need to rename the directory
if [ -d "$OLD_DIR" ] && [ ! -d "$PROJECT_DIR" ]; then
    echo "Moving clawdbot → dev-infra..."
    mv "$OLD_DIR" "$PROJECT_DIR"
fi

# Ensure directory exists
if [ ! -d "$PROJECT_DIR" ]; then
    echo "Cloning repository..."
    mkdir -p "$HOME/Development/Projects"
    git clone git@github.com:DonQuilatte/dev-infra.git "$PROJECT_DIR"
fi

cd "$PROJECT_DIR"

# Update remote URL if needed
REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
if [[ "$REMOTE" == *"clawdbot"* ]]; then
    git remote set-url origin git@github.com:DonQuilatte/dev-infra.git
    echo "Updated git remote"
fi

# Pull latest
git fetch origin
git pull origin main --ff-only || echo "Warning: Could not fast-forward"

echo "Repository updated"
REMOTE_SCRIPT

echo ""
echo "Step 2: Running migration script..."
ssh "$TARGET" "cd ~/Development/Projects/dev-infra && ./infrastructure/tw-mac/migrate-to-dev-infra.sh"

echo ""
echo "Step 3: Verifying from Controller Mac..."
if ~/bin/tw run 'echo ok' >/dev/null 2>&1; then
    echo "✓ TW Mac connection verified"
else
    echo "⚠ TW Mac connection issue - check manually"
fi

echo ""
echo "Migration complete!"
echo ""
echo "Test commands:"
echo "  ~/bin/tw status"
echo "  agy -r status"
