#!/bin/bash
# mcp-launcher.sh - Launch MCP servers with secrets injected
# Reads secrets from cache, falls back to 1Password if needed

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SECRETS_CACHE="${XDG_RUNTIME_DIR:-/tmp}/dev-infra-secrets"
MCP_CONFIGS_DIR="${MCP_CONFIGS_DIR:-$HOME/.config/dev-infra/mcp}"

# Get secret from cache or 1Password
get_secret() {
    local ref="$1"
    local cache_key=$(echo "$ref" | md5 -q)
    local cache_file="$SECRETS_CACHE/$cache_key"

    if [ -f "$cache_file" ]; then
        cat "$cache_file"
        return 0
    fi

    # Fall back to 1Password directly
    if [ -n "$OP_SERVICE_ACCOUNT_TOKEN" ] || [ -f "$HOME/.config/op/claude-dev-token" ]; then
        [ -z "$OP_SERVICE_ACCOUNT_TOKEN" ] && export OP_SERVICE_ACCOUNT_TOKEN=$(cat "$HOME/.config/op/claude-dev-token")
        op read "$ref" 2>/dev/null
    else
        echo "ERROR: Secret not cached and no 1Password auth: $ref" >&2
        return 1
    fi
}

# MCP server configurations
declare -A MCP_SERVERS
MCP_SERVERS=(
    ["github"]="npx -y @modelcontextprotocol/server-github"
    ["filesystem"]="npx -y @anthropic-ai/mcp-server-filesystem"
    ["gitkraken"]="npx -y gitkraken-mcp-server"
    ["context7"]="npx -y @anthropic-ai/mcp-server-context7"
    ["docker"]="docker run -i --rm -v /var/run/docker.sock:/var/run/docker.sock mcp/docker"
    ["postgres"]="npx -y @anthropic-ai/mcp-server-postgres"
    ["sqlite"]="npx -y @anthropic-ai/mcp-server-sqlite"
)

# Environment variables needed per server
declare -A MCP_ENV
MCP_ENV=(
    ["github"]="GITHUB_PERSONAL_ACCESS_TOKEN=op://Developer/GitHub/token"
    ["postgres"]="DATABASE_URL=op://Developer/PostgreSQL/connection_string"
)

# Launch MCP server
launch_server() {
    local server="$1"
    shift

    local cmd="${MCP_SERVERS[$server]}"
    if [ -z "$cmd" ]; then
        echo "Unknown MCP server: $server" >&2
        echo "Available: ${!MCP_SERVERS[*]}" >&2
        exit 1
    fi

    # Set up environment from secrets
    local env_spec="${MCP_ENV[$server]:-}"
    if [ -n "$env_spec" ]; then
        for spec in $env_spec; do
            local var_name="${spec%%=*}"
            local secret_ref="${spec#*=}"
            local value=$(get_secret "$secret_ref")
            export "$var_name=$value"
        done
    fi

    # Check for custom config
    local config_file="$MCP_CONFIGS_DIR/$server.json"
    if [ -f "$config_file" ]; then
        # Some MCP servers accept config via stdin or args
        exec $cmd --config "$config_file" "$@"
    else
        exec $cmd "$@"
    fi
}

# List available servers
list_servers() {
    echo "Available MCP servers:"
    for server in "${!MCP_SERVERS[@]}"; do
        echo "  $server"
    done
}

# Main
case "${1:-}" in
    list|--list|-l)
        list_servers
        ;;
    help|--help|-h)
        echo "Usage: mcp-launcher.sh <server> [args...]"
        echo
        list_servers
        echo
        echo "Secrets are loaded from cache or 1Password automatically."
        ;;
    "")
        echo "Error: No server specified" >&2
        list_servers >&2
        exit 1
        ;;
    *)
        launch_server "$@"
        ;;
esac
