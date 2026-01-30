#!/bin/bash
# migrate-to-dev-infra.sh - Migrate TW Mac from clawdbot to dev-infra naming
# Run this ON TW Mac after pulling latest code
#
# Usage: ./migrate-to-dev-infra.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log_step() { echo -e "${BLUE}→${NC} $1"; }
log_done() { echo -e "${GREEN}✓${NC} $1"; }
log_warn() { echo -e "${YELLOW}!${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }

LAUNCHD_DIR="$HOME/Library/LaunchAgents"
PROJECT_DIR="$HOME/Development/Projects/dev-infra"

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  TW Mac Migration: clawdbot → dev-infra"
echo "═══════════════════════════════════════════════════════"
echo ""

# Pre-flight checks
log_step "Running pre-flight checks..."

if [ ! -d "$PROJECT_DIR" ]; then
    log_error "Project directory not found: $PROJECT_DIR"
    echo ""
    echo "First, clone or move the repo:"
    echo "  git clone git@github.com:DonQuilatte/dev-infra.git $PROJECT_DIR"
    echo ""
    echo "Or if you have the old clawdbot directory:"
    echo "  mv ~/Development/Projects/clawdbot $PROJECT_DIR"
    exit 1
fi

cd "$PROJECT_DIR"
log_done "Project directory found"

# Step 1: Stop old services
echo ""
log_step "Stopping old clawdbot services..."

OLD_SERVICES=(
    "com.clawdbot.node"
    "com.clawdbot.config-watcher"
    "com.clawdbot.connection-monitor"
    "com.clawdbot.scheduled-periodic"
    "com.clawdbot.scheduled-daily"
    "com.clawdbot.tw-health-monitor"
    "com.clawdbot.watchdog"
)

for service in "${OLD_SERVICES[@]}"; do
    PLIST="$LAUNCHD_DIR/$service.plist"
    if [ -f "$PLIST" ]; then
        launchctl unload "$PLIST" 2>/dev/null && log_done "Stopped $service" || log_warn "Could not stop $service"
    fi
done

# Step 2: Remove old plist files
echo ""
log_step "Removing old plist files..."

for service in "${OLD_SERVICES[@]}"; do
    PLIST="$LAUNCHD_DIR/$service.plist"
    if [ -f "$PLIST" ]; then
        rm "$PLIST" && log_done "Removed $service.plist" || log_warn "Could not remove $service.plist"
    fi
done

# Step 3: Update git remote if needed
echo ""
log_step "Checking git remote..."

CURRENT_REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
if [[ "$CURRENT_REMOTE" == *"clawdbot"* ]]; then
    git remote set-url origin git@github.com:DonQuilatte/dev-infra.git
    log_done "Updated git remote to dev-infra"
else
    log_done "Git remote already correct"
fi

# Step 4: Pull latest code
echo ""
log_step "Pulling latest code..."
git fetch origin
git pull origin main --ff-only || {
    log_warn "Could not fast-forward. You may have local changes."
    log_warn "Run: git stash && git pull && git stash pop"
}

# Step 5: Run install scripts
echo ""
log_step "Running installation scripts..."

SCRIPT_DIR="$PROJECT_DIR/infrastructure/tw-mac/automation"

if [ -x "$SCRIPT_DIR/install-automation.sh" ]; then
    "$SCRIPT_DIR/install-automation.sh"
else
    log_warn "install-automation.sh not found or not executable"
fi

if [ -x "$SCRIPT_DIR/install-monitoring.sh" ]; then
    "$SCRIPT_DIR/install-monitoring.sh"
else
    log_warn "install-monitoring.sh not found or not executable"
fi

# Step 6: Verify new services
echo ""
echo "═══════════════════════════════════════════════════════"
echo "  Migration Verification"
echo "═══════════════════════════════════════════════════════"
echo ""

NEW_SERVICES=(
    "com.dev-infra.config-watcher"
    "com.dev-infra.connection-monitor"
    "com.dev-infra.scheduled-periodic"
    "com.dev-infra.scheduled-daily"
)

ALL_RUNNING=true
for service in "${NEW_SERVICES[@]}"; do
    if launchctl list 2>/dev/null | grep -q "$service"; then
        log_done "$service running"
    else
        log_error "$service NOT running"
        ALL_RUNNING=false
    fi
done

# Step 7: Cleanup old directories/files
echo ""
log_step "Cleaning up old references..."

# Update shell config if needed
if grep -q "clawdbot" "$HOME/.zshrc" 2>/dev/null; then
    log_warn "Found clawdbot references in ~/.zshrc"
    echo "  Consider updating paths manually"
fi

if grep -q "clawdbot" "$HOME/.zprofile" 2>/dev/null; then
    log_warn "Found clawdbot references in ~/.zprofile"
    echo "  Consider updating paths manually"
fi

# Check for old project directory
if [ -d "$HOME/Development/Projects/clawdbot" ] && [ "$PROJECT_DIR" != "$HOME/Development/Projects/clawdbot" ]; then
    log_warn "Old clawdbot directory still exists"
    echo "  Consider removing: rm -rf ~/Development/Projects/clawdbot"
fi

# Summary
echo ""
echo "═══════════════════════════════════════════════════════"
if [ "$ALL_RUNNING" = true ]; then
    echo -e "  ${GREEN}Migration Complete!${NC}"
else
    echo -e "  ${YELLOW}Migration Complete with Warnings${NC}"
fi
echo "═══════════════════════════════════════════════════════"
echo ""
echo "New services: com.dev-infra.*"
echo "Project path: $PROJECT_DIR"
echo "Git remote:   $(git remote get-url origin)"
echo ""

if [ "$ALL_RUNNING" = false ]; then
    echo "Some services failed to start. Check:"
    echo "  launchctl list | grep dev-infra"
    echo "  cat /tmp/*.err"
    echo ""
fi

echo "Test connectivity from Controller Mac:"
echo "  ~/bin/tw status"
echo ""
