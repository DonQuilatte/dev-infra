#!/bin/bash
# Unit Tests for Docker/OrbStack Configuration
# Tests Docker configuration files and settings validation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PASS=0
FAIL=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    ((PASS++))
}

log_fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    ((FAIL++))
}

log_skip() {
    echo -e "${YELLOW}○ SKIP${NC}: $1"
}

echo "=========================================="
echo "Docker/OrbStack Configuration Unit Tests"
echo "=========================================="
echo ""

# Test 1: Docker context configuration
echo "--- Test: Docker context exists ---"
if docker context ls 2>/dev/null | grep -q "orbstack\|tw-mac"; then
    log_pass "Docker context configured"
else
    log_skip "No remote Docker context (local only)"
fi

# Test 2: OrbStack CLI linkage
echo "--- Test: OrbStack CLI linked ---"
if command -v orbctl &>/dev/null || [ -f /Applications/OrbStack.app/Contents/MacOS/orbctl ]; then
    log_pass "OrbStack CLI accessible"
else
    log_skip "OrbStack not installed locally (expected)"
fi

# Test 3: Docker socket configuration
echo "--- Test: Docker socket path ---"
DOCKER_HOST="${DOCKER_HOST:-}"
if [ -n "$DOCKER_HOST" ] || [ -S /var/run/docker.sock ] || [ -S "$HOME/.orbstack/run/docker.sock" ]; then
    log_pass "Docker socket path valid"
else
    log_skip "No local Docker socket"
fi

# Test 4: Memory limit configuration check
echo "--- Test: Memory limit awareness ---"
# This checks if the TW Mac has appropriate memory settings
TW_MEM_OUTPUT=$(ssh -o ConnectTimeout=5 -o BatchMode=yes tywhitaker@192.168.1.245 \
    'sysctl -n hw.memsize 2>/dev/null' 2>/dev/null || echo "0")
if [ "$TW_MEM_OUTPUT" != "0" ]; then
    TW_MEM_GB=$((TW_MEM_OUTPUT / 1024 / 1024 / 1024))
    if [ "$TW_MEM_GB" -ge 8 ]; then
        log_pass "TW Mac has sufficient memory: ${TW_MEM_GB}GB"
    else
        log_fail "TW Mac memory too low: ${TW_MEM_GB}GB (need 8GB+)"
    fi
else
    log_skip "Could not check TW Mac memory"
fi

# Test 5: Docker version format validation
echo "--- Test: Docker version format ---"
DOCKER_VERSION=$(ssh -o ConnectTimeout=5 -o BatchMode=yes tywhitaker@192.168.1.245 \
    'docker version --format "{{.Server.Version}}" 2>/dev/null' 2>/dev/null || echo "")
if [[ "$DOCKER_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    log_pass "Docker version format valid: $DOCKER_VERSION"
else
    log_fail "Docker version format invalid: $DOCKER_VERSION"
fi

# Summary
echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo -e "${GREEN}Passed: $PASS${NC}"
echo -e "${RED}Failed: $FAIL${NC}"
echo ""

if [ $FAIL -gt 0 ]; then
    exit 1
fi
exit 0
