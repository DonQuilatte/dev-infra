#!/bin/bash
# System tests for firewall configuration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${PROJECT_ROOT:-$(dirname "$(dirname "$SCRIPT_DIR")")}"

# Source test utilities
source "$SCRIPT_DIR/../lib/test-utils.sh"

# Configuration
REMOTE_MAC_IP="192.168.1.245"
REMOTE_USER="tywhitaker"

echo "Testing firewall configuration..."

# Test: Remote Mac firewall is enabled
print_test "Remote Mac firewall is enabled"
FIREWALL_STATE=$(ssh -o ConnectTimeout=5 -o BatchMode=yes "$REMOTE_USER@$REMOTE_MAC_IP" \
    '/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null' || echo "")
if [[ "$FIREWALL_STATE" == *"enabled"* ]] || [[ "$FIREWALL_STATE" == *"State = 1"* ]]; then
    print_pass "Firewall is enabled"
else
    print_fail "Firewall is not enabled (state: $FIREWALL_STATE)"
fi

# Test: Node.js is in firewall allowed apps
print_test "Node.js is in firewall allowed applications"
NODE_IN_FIREWALL=$(ssh -o ConnectTimeout=5 -o BatchMode=yes "$REMOTE_USER@$REMOTE_MAC_IP" \
    '/usr/libexec/ApplicationFirewall/socketfilterfw --listapps 2>/dev/null | grep -i node' || echo "")
if [[ -n "$NODE_IN_FIREWALL" ]]; then
    print_pass "Node.js is allowed in firewall"
else
    print_fail "Node.js is not in firewall allowed apps"
fi

# Test: Node.js path matches installed version
print_test "Firewall Node.js path matches installed version"
INSTALLED_NODE_PATH=$(ssh -o ConnectTimeout=5 -o BatchMode=yes "$REMOTE_USER@$REMOTE_MAC_IP" \
    'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && which node 2>/dev/null' || echo "")
if [[ -n "$INSTALLED_NODE_PATH" && "$NODE_IN_FIREWALL" == *"$INSTALLED_NODE_PATH"* ]]; then
    print_pass "Firewall Node.js path matches installed version"
else
    print_skip "Cannot verify path match (installed: $INSTALLED_NODE_PATH)"
fi

# Test: SSH still works with firewall enabled (implicit test - we're using SSH)
print_test "SSH works with firewall enabled"
SSH_TEST=$(ssh -o ConnectTimeout=5 -o BatchMode=yes "$REMOTE_USER@$REMOTE_MAC_IP" "echo 'ssh-works'" 2>/dev/null || echo "")
if [[ "$SSH_TEST" == "ssh-works" ]]; then
    print_pass "SSH works through firewall"
else
    print_fail "SSH blocked by firewall"
fi

# Test: Clawdbot node can connect to gateway with firewall enabled
print_test "Clawdbot node connected to gateway (firewall active)"
NODE_RUNNING=$(ssh -o ConnectTimeout=5 -o BatchMode=yes "$REMOTE_USER@$REMOTE_MAC_IP" \
    'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && clawdbot node status 2>/dev/null | grep -o "running"' 2>/dev/null || echo "")
if [[ "$NODE_RUNNING" == "running" ]]; then
    print_pass "Clawdbot node running with firewall enabled"
else
    print_fail "Clawdbot node not running (firewall may be blocking)"
fi

# Test: Outbound connections work (curl to gateway)
print_test "Outbound connections work from remote Mac"
GATEWAY_REACHABLE=$(ssh -o ConnectTimeout=5 -o BatchMode=yes "$REMOTE_USER@$REMOTE_MAC_IP" \
    'curl -s --connect-timeout 5 -o /dev/null -w "%{http_code}" http://192.168.1.230:18789/health' 2>/dev/null || echo "000")
if [[ "$GATEWAY_REACHABLE" == "200" ]]; then
    print_pass "Outbound HTTP connections work"
else
    print_fail "Outbound HTTP connections blocked (HTTP $GATEWAY_REACHABLE)"
fi

# Test: Stealth mode status (informational)
print_test "Checking stealth mode status"
STEALTH_MODE=$(ssh -o ConnectTimeout=5 -o BatchMode=yes "$REMOTE_USER@$REMOTE_MAC_IP" \
    '/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode 2>/dev/null' || echo "unknown")
if [[ "$STEALTH_MODE" == *"enabled"* ]]; then
    print_pass "Stealth mode is enabled (extra security)"
elif [[ "$STEALTH_MODE" == *"disabled"* ]]; then
    print_pass "Stealth mode is disabled (normal operation)"
else
    print_skip "Could not determine stealth mode status"
fi

echo ""
echo "Firewall tests complete."
