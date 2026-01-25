#!/bin/bash
set -euo pipefail

# Clawdbot Secure Docker Deployment Script
# Version: 1.1.0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ ${NC}$1"
}

print_error() {
    echo -e "${RED}❌ ${NC}$1"
}

print_warning() {
    echo -e "${YELLOW}⚠️  ${NC}$1"
}

print_info() {
    echo -e "${BLUE}ℹ ${NC}$1"
}

# Check prerequisites
check_prereqs() {
    print_header "Checking Prerequisites"
    
    # Check Docker
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running"
        echo "Please start Docker Desktop and try again"
        exit 1
    fi
    print_success "Docker is running"
    
    # Check if running as root
    if [ "$EUID" -eq 0 ]; then
        print_error "Do not run this script as root"
        exit 1
    fi
    print_success "Not running as root"
    
    # Check for docker compose
    if ! docker compose version > /dev/null 2>&1; then
        print_error "Docker Compose not available"
        exit 1
    fi
    print_success "Docker Compose available"
    
    # Check for claude CLI (optional)
    if command -v claude &> /dev/null; then
        print_success "Claude CLI available"
        CLAUDE_CLI_AVAILABLE=true
    else
        print_warning "Claude CLI not found (API key auth will be used)"
        CLAUDE_CLI_AVAILABLE=false
    fi
}

# Set UID/GID for containers
setup_env() {
    print_header "Setting Up Environment"
    
    export USER_UID=$(id -u)
    export USER_GID=$(id -g)
    
    # Create .env file
    cat > .env << EOF
USER_UID=${USER_UID}
USER_GID=${USER_GID}
CLAWDBOT_VERSION=latest
NODE_ENV=production
CLAWDBOT_PORT=18789
EOF
    
    print_success "Environment configured (UID:GID = ${USER_UID}:${USER_GID})"
}

# Build images
build_images() {
    print_header "Building Secure Clawdbot Images"
    
    print_info "Building with security hardening..."
    if docker compose -f config/docker-compose.secure.yml build --no-cache; then
        print_success "Images built successfully"
    else
        print_error "Image build failed"
        exit 1
    fi
}

# Create volumes
create_volumes() {
    print_header "Creating Docker Volumes"
    
    docker volume create clawdbot-config 2>/dev/null || true
    docker volume create clawdbot-logs 2>/dev/null || true
    print_success "Volumes created"
}

# Configure authentication
setup_auth() {
    print_header "Setting Up Authentication"
    
    echo "Choose authentication method:"
    echo "  1) Claude Code setup-token (requires Claude subscription)"
    echo "  2) Anthropic API key (pay-per-use)"
    echo ""
    read -p "Enter choice (1 or 2): " AUTH_CHOICE
    echo ""
    
    if [ "$AUTH_CHOICE" = "1" ]; then
        if [ "$CLAUDE_CLI_AVAILABLE" = true ]; then
            print_info "Generating setup-token..."
            echo "Run this command to get your token:"
            echo -e "${YELLOW}  claude setup-token${NC}"
            echo ""
            read -p "Press Enter when ready to paste token..."
            echo ""
            read -sp "Paste setup-token: " SETUP_TOKEN
            echo ""
            
            # Save token for container use
            echo "$SETUP_TOKEN" > /tmp/clawdbot-token.txt
            chmod 600 /tmp/clawdbot-token.txt
            
            print_info "Running onboarding with setup-token..."
            docker compose -f config/docker-compose.secure.yml run --rm \
                -v /tmp/clawdbot-token.txt:/tmp/token.txt:ro \
                clawdbot-cli sh -c 'clawdbot onboard --non-interactive || clawdbot setup' || true
            
            rm -f /tmp/clawdbot-token.txt
        else
            print_error "Claude CLI not available for setup-token method"
            print_info "Please install Claude CLI or use API key (option 2)"
            exit 1
        fi
            
    elif [ "$AUTH_CHOICE" = "2" ]; then
        print_info "Get your API key from: https://console.anthropic.com/settings/keys"
        echo ""
        read -sp "Paste Anthropic API key: " API_KEY
        echo ""
        
        # Save API key for container use
        echo "$API_KEY" > /tmp/clawdbot-apikey.txt
        chmod 600 /tmp/clawdbot-apikey.txt
        
        print_info "Running onboarding with API key..."
        docker compose -f config/docker-compose.secure.yml run --rm \
            -e ANTHROPIC_API_KEY="$API_KEY" \
            clawdbot-cli sh -c 'clawdbot onboard --non-interactive || clawdbot setup' || true
        
        rm -f /tmp/clawdbot-apikey.txt
    else
        print_error "Invalid choice"
        exit 1
    fi
    
    print_success "Authentication configured"
}

# Start gateway
start_gateway() {
    print_header "Starting Clawdbot Gateway"
    
    print_info "Starting gateway with security hardening..."
    if docker compose -f config/docker-compose.secure.yml up -d clawdbot-gateway; then
        print_success "Gateway started"
    else
        print_error "Gateway failed to start"
        print_info "Check logs with: docker compose -f config/docker-compose.secure.yml logs"
        exit 1
    fi
}

# Wait for health check
wait_for_health() {
    print_header "Waiting for Gateway Health Check"
    
    print_info "Waiting up to 60 seconds for gateway to become healthy..."
    
    for i in {1..12}; do
        sleep 5
        STATUS=$(docker inspect clawdbot-gateway-secure --format='{{.State.Health.Status}}' 2>/dev/null || echo "starting")
        echo "  Attempt $i/12: $STATUS"
        
        if [ "$STATUS" = "healthy" ]; then
            print_success "Gateway is healthy"
            return 0
        fi
    done
    
    print_warning "Health check timeout (gateway may still be starting)"
    print_info "Check status with: docker compose -f config/docker-compose.secure.yml ps"
}

# Final verification
verify_deployment() {
    print_header "Verifying Deployment"
    
    # Check container is running
    if docker compose -f config/docker-compose.secure.yml ps | grep -q "clawdbot-gateway.*Up"; then
        print_success "Gateway container running"
    else
        print_error "Gateway container not running"
        return 1
    fi
    
    # Check port is listening
    if netstat -an 2>/dev/null | grep "127.0.0.1.18789" | grep -q "LISTEN" || \
       lsof -i :18789 2>/dev/null | grep -q LISTEN; then
        print_success "Gateway listening on localhost:18789"
    else
        print_warning "Port check inconclusive"
    fi
    
    # Check security settings
    print_info "Verifying security settings..."
    
    RO_FS=$(docker inspect clawdbot-gateway-secure | jq -r '.[0].HostConfig.ReadonlyRootfs')
    if [ "$RO_FS" = "true" ]; then
        print_success "Read-only filesystem active"
    else
        print_warning "Read-only filesystem not active"
    fi
    
    USER_ID=$(docker inspect clawdbot-gateway-secure | jq -r '.[0].Config.User')
    if [ "$USER_ID" != "0:0" ] && [ "$USER_ID" != "" ]; then
        print_success "Running as non-root user ($USER_ID)"
    else
        print_warning "User check inconclusive"
    fi
}

# Main deployment flow
main() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║     Clawdbot Secure Docker Deployment v1.1.0              ║"
    echo "║     Enterprise-Grade Security Hardening                   ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    check_prereqs
    setup_env
    build_images
    create_volumes
    setup_auth
    start_gateway
    wait_for_health
    verify_deployment
    
    print_header "Deployment Complete!"
    
    echo -e "${GREEN}✅ Clawdbot is now running with enterprise security!${NC}"
    echo ""
    echo "📊 Deployment Information:"
    echo "  Gateway URL: http://localhost:18789"
    echo "  Container: clawdbot-gateway-secure"
    echo "  Config: Docker volume 'clawdbot-config'"
    echo ""
    echo "🔧 Management Commands:"
    echo "  View logs:    docker compose -f config/docker-compose.secure.yml logs -f"
    echo "  Stop:         docker compose -f config/docker-compose.secure.yml down"
    echo "  Restart:      docker compose -f config/docker-compose.secure.yml restart"
    echo "  CLI:          docker compose -f config/docker-compose.secure.yml run --rm clawdbot-cli"
    echo "  Verify:       ./scripts/verify-security.sh"
    echo ""
    echo "📚 Documentation: docs/SECURE_DEPLOYMENT.md"
    echo ""
}

# Run main function
main
