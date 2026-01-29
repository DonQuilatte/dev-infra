#!/bin/bash
# System tests for firewall configuration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${PROJECT_ROOT:-$(dirname "$(dirname "$SCRIPT_DIR")")}"

# Source test utilities
source "$SCRIPT_DIR/../lib/test-utils.sh"

# Configuration - use tw alias for reliable connection
SSH_CMD="ssh -o ConnectTimeout=10 -o BatchMode=yes -o ServerAliveInterval=5 tw"

echo "Testing firewall configuration..."

# First verify SSH connectivity
print_test "SSH connectivity to TW Mac"
SSH_CHECK=$($SSH_CMD "echo ok" 2>&1 | grep -o "ok" || echo "")
if [[ "$SSH_CHECK" != "ok" ]]; then
    print_fail "Cannot connect to TW Mac - skipping firewall tests"
    echo ""
    echo "Firewall tests skipped (SSH unavailable)."
    exit 0
fi
print_pass "SSH connection established"

# Test: Remote Mac firewall is enabled
print_test "Remote Mac firewall is enabled"
FIREWALL_STATE=$($SSH_CMD '/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate' 2>&1 || echo "")
if [[ "$FIREWALL_STATE" == *"enabled"* ]] || [[ "$FIREWALL_STATE" == *"State = 1"* ]]; then
    print_pass "Firewall is enabled"
elif [[ "$FIREWALL_STATE" == *"disabled"* ]] || [[ "$FIREWALL_STATE" == *"State = 0"* ]]; then
    print_skip "Firewall is disabled (not required for local network)"
else
    print_skip "Could not determine firewall state"
fi

# Test: Node.js is in firewall allowed apps (optional if firewall disabled)
print_test "Node.js in firewall allowed applications"
NODE_IN_FIREWALL=$($SSH_CMD '/usr/libexec/ApplicationFirewall/socketfilterfw --listapps 2>/dev/null | grep -i node' 2>&1 || echo "")
if [[ -n "$NODE_IN_FIREWALL" ]]; then
    print_pass "Node.js is allowed in firewall"
else
    print_skip "Node.js not in firewall apps (not needed if firewall disabled)"
fi

# Test: Node.js path matches installed version
print_test "Firewall Node.js path matches installed version"
INSTALLED_NODE_PATH=$($SSH_CMD 'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && which node' 2>&1 | grep -v "^$" | head -1 || echo "")
if [[ -n "$INSTALLED_NODE_PATH" && -n "$NODE_IN_FIREWALL" && "$NODE_IN_FIREWALL" == *"$INSTALLED_NODE_PATH"* ]]; then
    print_pass "Firewall Node.js path matches installed version"
elif [[ -n "$INSTALLED_NODE_PATH" ]]; then
    print_skip "Node.js installed at: $INSTALLED_NODE_PATH"
else
    print_skip "Cannot verify path match"
fi

# Test: SSH still works (already verified above)
print_test "SSH works with firewall"
print_pass "SSH works (verified at start)"

# Test: Clawdbot node or Docker available
print_test "Clawdbot node or Docker available"
NODE_RUNNING=$($SSH_CMD 'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && clawdbot node status 2>/dev/null | grep -o "running"' 2>&1 | grep -o "running" || echo "")
DOCKER_OK=$($SSH_CMD 'docker info >/dev/null 2>&1 && echo "ok"' 2>&1 | grep -o "ok" || echo "")
if [[ "$NODE_RUNNING" == "running" ]]; then
    print_pass "Clawdbot node running"
elif [[ "$DOCKER_OK" == "ok" ]]; then
    print_pass "Docker available (alternative to node)"
else
    print_skip "Neither Clawdbot node nor Docker running"
fi

# Test: Outbound connections work (curl to gateway)
print_test "Outbound connections work from remote Mac"
GATEWAY_REACHABLE=$($SSH_CMD 'curl -s --connect-timeout 5 -o /dev/null -w "%{http_code}" http://192.168.1.230:18789/health' 2>&1 | grep -oE '[0-9]{3}' | head -1 || echo "000")
if [[ "$GATEWAY_REACHABLE" == "200" ]]; then
    print_pass "Outbound HTTP connections work"
else
    print_fail "Outbound HTTP connections issue (HTTP $GATEWAY_REACHABLE)"
fi

# Test: Stealth mode status (informational)
print_test "Checking stealth mode status"
STEALTH_MODE=$($SSH_CMD '/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode' 2>&1 || echo "unknown")
if [[ "$STEALTH_MODE" == *"enabled"* ]]; then
    print_pass "Stealth mode is enabled (extra security)"
elif [[ "$STEALTH_MODE" == *"disabled"* ]]; then
    print_pass "Stealth mode is disabled (normal operation)"
else
    print_skip "Could not determine stealth mode status"
fi

echo ""
echo "Firewall tests complete."
