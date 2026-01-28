#!/bin/bash
# System tests for distributed Clawdbot connectivity

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${PROJECT_ROOT:-$(dirname "$(dirname "$SCRIPT_DIR")")}"

# Source test utilities
source "$SCRIPT_DIR/../lib/test-utils.sh"

# Configuration
MAIN_MAC_IP="192.168.1.230"
REMOTE_MAC_IP="192.168.1.245"
REMOTE_USER="tywhitaker"
GATEWAY_PORT="18789"

echo "Testing distributed system connectivity..."

# Test: Main Mac gateway is reachable
print_test "Main Mac gateway is reachable on port $GATEWAY_PORT"
if curl -s --connect-timeout 5 "http://$MAIN_MAC_IP:$GATEWAY_PORT" &>/dev/null; then
    print_pass "Gateway is reachable"
else
    print_fail "Gateway is not reachable"
fi

# Test: Gateway health endpoint responds
print_test "Gateway health endpoint responds"
HEALTH_RESPONSE=$(curl -s --connect-timeout 5 "http://localhost:$GATEWAY_PORT/health" 2>/dev/null || echo "")
if [[ -n "$HEALTH_RESPONSE" ]]; then
    print_pass "Health endpoint responds"
else
    print_fail "Health endpoint not responding"
fi

# Test: SSH to remote Mac works
print_test "SSH to remote Mac ($REMOTE_USER@$REMOTE_MAC_IP)"
if ssh -o ConnectTimeout=5 -o BatchMode=yes "$REMOTE_USER@$REMOTE_MAC_IP" "echo ok" &>/dev/null; then
    print_pass "SSH connection works"
else
    print_fail "SSH connection failed"
fi

# Test: Remote Mac can reach gateway
print_test "Remote Mac can reach gateway"
REMOTE_HEALTH=$(ssh -o ConnectTimeout=5 -o BatchMode=yes "$REMOTE_USER@$REMOTE_MAC_IP" \
    "curl -s --connect-timeout 5 -o /dev/null -w '%{http_code}' http://$MAIN_MAC_IP:$GATEWAY_PORT/health" 2>/dev/null || echo "000")
if [[ "$REMOTE_HEALTH" == "200" ]]; then
    print_pass "Remote Mac can reach gateway (HTTP 200)"
else
    print_fail "Remote Mac cannot reach gateway (HTTP $REMOTE_HEALTH)"
fi

# Test: Clawdbot node service is running on remote
print_test "Clawdbot node service is running on remote Mac"
NODE_STATUS=$(ssh -o ConnectTimeout=5 -o BatchMode=yes "$REMOTE_USER@$REMOTE_MAC_IP" \
    'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && clawdbot node status 2>/dev/null | grep -o "running"' 2>/dev/null || echo "")
if [[ "$NODE_STATUS" == "running" ]]; then
    print_pass "Clawdbot node is running"
else
    print_fail "Clawdbot node is not running"
fi

# Test: Remote node has clawdbot installed
print_test "Clawdbot is installed on remote Mac"
CLAWDBOT_VERSION=$(ssh -o ConnectTimeout=5 -o BatchMode=yes "$REMOTE_USER@$REMOTE_MAC_IP" \
    'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && clawdbot --version 2>/dev/null' || echo "")
if [[ -n "$CLAWDBOT_VERSION" ]]; then
    print_pass "Clawdbot installed: $CLAWDBOT_VERSION"
else
    print_fail "Clawdbot is not installed on remote"
fi

# Test: Remote node config exists
print_test "Remote node config file exists"
CONFIG_EXISTS=$(ssh -o ConnectTimeout=5 -o BatchMode=yes "$REMOTE_USER@$REMOTE_MAC_IP" \
    'test -f ~/.clawdbot/clawdbot.json && echo "yes"' 2>/dev/null || echo "no")
if [[ "$CONFIG_EXISTS" == "yes" ]]; then
    print_pass "Config file exists"
else
    print_fail "Config file missing"
fi

# Test: Remote node configured for remote gateway mode
print_test "Remote node configured for gateway mode"
GATEWAY_MODE=$(ssh -o ConnectTimeout=5 -o BatchMode=yes "$REMOTE_USER@$REMOTE_MAC_IP" \
    'grep -o "\"mode\": \"remote\"" ~/.clawdbot/clawdbot.json 2>/dev/null' || echo "")
if [[ -n "$GATEWAY_MODE" ]]; then
    print_pass "Remote node configured for remote gateway mode"
else
    print_fail "Remote node not configured for remote gateway mode"
fi

# Test: LaunchAgent is installed on remote
print_test "LaunchAgent auto-restart is installed on remote"
LAUNCHAGENT_EXISTS=$(ssh -o ConnectTimeout=5 -o BatchMode=yes "$REMOTE_USER@$REMOTE_MAC_IP" \
    'test -f ~/Library/LaunchAgents/com.clawdbot.node.plist && echo "yes"' 2>/dev/null || echo "no")
if [[ "$LAUNCHAGENT_EXISTS" == "yes" ]]; then
    print_pass "LaunchAgent is installed"
else
    print_fail "LaunchAgent is not installed"
fi

echo ""
echo "Connectivity tests complete."
