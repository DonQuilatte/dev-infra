#!/bin/bash
# Post-restart setup for Clawdbot Docker container
# Run this after container recreation to restore authentication

set -e

# shellcheck source=lib/common.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/lib/common.sh" ]; then
    source "$SCRIPT_DIR/lib/common.sh"
else
    # Fallback if common.sh not found
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    NC='\033[0m'
fi

COMPOSE_FILE="config/docker-compose.secure.yml"
CONTAINER_NAME="clawdbot-gateway-secure"

# Configuration
MAX_WAIT_SECONDS=60
HEALTH_CHECK_INTERVAL=2

# SECURITY: Token must be set - no weak default
if [ -z "${CLAWDBOT_GATEWAY_TOKEN:-}" ]; then
    # Try to load from .env file
    if [ -f .env ]; then
        TOKEN=$(grep "^CLAWDBOT_GATEWAY_TOKEN=" .env 2>/dev/null | cut -d= -f2)
    fi
    if [ -z "${TOKEN:-}" ]; then
        echo -e "${RED}❌ CLAWDBOT_GATEWAY_TOKEN not set${NC}"
        echo "   Set it in .env or export CLAWDBOT_GATEWAY_TOKEN=<token>"
        exit 1
    fi
else
    TOKEN="$CLAWDBOT_GATEWAY_TOKEN"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Clawdbot Post-Restart Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if container is running
if ! docker ps --filter "name=$CONTAINER_NAME" --format "{{.Names}}" | grep -q "$CONTAINER_NAME"; then
    echo -e "${RED}❌ Container $CONTAINER_NAME is not running${NC}"
    echo "   Start it with: docker compose -f $COMPOSE_FILE up -d clawdbot-gateway"
    exit 1
fi

echo -e "${GREEN}✅ Container is running${NC}"

# Set remote token to match auth token
echo ""
echo "🔐 Configuring gateway token..."
docker exec "$CONTAINER_NAME" clawdbot config set gateway.remote.token "$TOKEN" >/dev/null 2>&1
echo -e "${GREEN}✅ Token configured (hidden for security)${NC}"

# Restart to apply config
echo ""
echo "🔄 Restarting gateway to apply config..."
docker compose -f "$COMPOSE_FILE" restart clawdbot-gateway

# OPTIMIZATION: Poll for health instead of fixed sleep
echo "⏳ Waiting for gateway to become healthy..."
waited=0
while [ $waited -lt $MAX_WAIT_SECONDS ]; do
    # Check container health status
    health=$(docker inspect --format='{{.State.Health.Status}}' "$CONTAINER_NAME" 2>/dev/null || echo "starting")

    if [ "$health" = "healthy" ]; then
        echo -e "${GREEN}✅ Gateway is healthy${NC}"
        break
    fi

    # Also check if we can hit the health endpoint directly
    if curl -sf --connect-timeout 2 "http://127.0.0.1:18789/health" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Gateway health endpoint responding${NC}"
        break
    fi

    sleep "$HEALTH_CHECK_INTERVAL"
    waited=$((waited + HEALTH_CHECK_INTERVAL))
    echo "   Waiting... ($waited/${MAX_WAIT_SECONDS}s) - status: $health"
done

if [ $waited -ge $MAX_WAIT_SECONDS ]; then
    echo "⚠️  Gateway may still be starting (timeout reached)"
fi

# Check for pending device pairings
echo ""
echo "📱 Checking device pairings..."
PENDING=$(docker exec "$CONTAINER_NAME" clawdbot devices list 2>&1)
echo "$PENDING"

# Extract pending request IDs
PENDING_IDS=$(echo "$PENDING" | grep -E "^│ [a-f0-9-]{36}" | awk '{print $2}' | head -5)

if [ -n "$PENDING_IDS" ]; then
    echo ""
    echo "🔔 Found pending device requests. Approve them?"
    read -rp "   Auto-approve all pending devices? (y/N): " APPROVE

    if [[ "$APPROVE" =~ ^[Yy]$ ]]; then
        for ID in $PENDING_IDS; do
            echo "   Approving $ID..."
            if ! docker exec "$CONTAINER_NAME" clawdbot devices approve "$ID" 2>&1; then
                echo "   ⚠️  Warning: Failed to approve device $ID (may already be approved)"
            fi
        done
        echo -e "${GREEN}✅ Device approval complete${NC}"
    else
        echo "ℹ️  To approve manually:"
        echo "   docker exec $CONTAINER_NAME clawdbot devices approve <request-id>"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Setup Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Gateway URL:  http://127.0.0.1:18789/"
echo "Token:        (set in .env - not displayed for security)"
echo ""
echo "Useful commands:"
echo "  docker logs -f $CONTAINER_NAME          # View logs"
echo "  docker exec $CONTAINER_NAME clawdbot devices list  # List devices"
echo "  docker compose -f $COMPOSE_FILE down    # Stop gateway"
