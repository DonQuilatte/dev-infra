#!/bin/bash
# Agent Control - Brain/Agent Distributed Development Interface
# Usage: agent [command] [agent-name] [args...]
#
# Mental Model:
#   Brain (this Mac) = Decision-making, orchestration, user interaction
#   Agents (workers) = Task execution, builds, long-running processes
#
# Default agent: alpha (TW Mac)

set -e

# Resolve symlinks to get actual script location
SCRIPT_PATH="${BASH_SOURCE[0]}"
while [ -L "$SCRIPT_PATH" ]; do
    SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
    SCRIPT_PATH="$(readlink "$SCRIPT_PATH")"
    [[ $SCRIPT_PATH != /* ]] && SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_PATH"
done
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Default agent when none specified
DEFAULT_AGENT="alpha"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Agent registry functions (Bash 3.x compatible)
get_host() {
    local agent="$1"
    case "$agent" in
        alpha) echo "tw" ;;
        *) echo "" ;;
    esac
}

get_mount() {
    local agent="$1"
    case "$agent" in
        alpha) echo "$HOME/tw-mac" ;;
        *) echo "" ;;
    esac
}

is_valid_agent() {
    local agent="$1"
    case "$agent" in
        alpha) return 0 ;;
        *) return 1 ;;
    esac
}

# Resolve agent name (defaults to alpha)
resolve_agent() {
    local input="$1"
    if [[ -z "$input" ]]; then
        echo "$DEFAULT_AGENT"
    elif is_valid_agent "$input"; then
        echo "$input"
    else
        echo ""
    fi
}

# Delegate to tw-control.sh (the actual implementation)
delegate_tw() {
    local cmd="$1"
    shift
    "$PROJECT_ROOT/infrastructure/tw-mac/tw-control.sh" "$cmd" "$@"
}

# List all configured agents
list_agents() {
    echo -e "${BLUE}=== Configured Agents ===${NC}"
    echo ""
    echo -e "${CYAN}alpha${NC}"
    echo "  Host:  tw"
    echo "  Mount: $HOME/tw-mac"
    echo "  Desc:  TW Mac - Primary worker node"
    echo ""
}

# Show status for one or all agents
status() {
    local agent="$1"

    if [[ -z "$agent" ]]; then
        # Status for all agents (currently just alpha)
        echo -e "${BLUE}=== Agent: alpha ===${NC}"
        delegate_tw status
        echo ""
    else
        # Status for specific agent
        echo -e "${BLUE}=== Agent: $agent ===${NC}"
        delegate_tw status
    fi
}

# Dispatch task to agent
dispatch() {
    local agent="$1"
    local task="$2"
    local session="${3:-task-$(date +%H%M%S)}"

    if [[ -z "$task" ]]; then
        echo -e "${RED}Error: Task description required${NC}"
        echo "Usage: agent dispatch [agent-name] \"task description\" [session-name]"
        return 1
    fi

    local host
    host=$(get_host "$agent")
    local mount
    mount=$(get_mount "$agent")

    echo -e "${BLUE}Dispatching to agent: $agent${NC}"

    # Check if SMB mount is available
    if [[ -d "$mount/handoffs" ]]; then
        # SMB mode: use existing handoff mechanism
        "$PROJECT_ROOT/infrastructure/tw-mac/tw-handoff.sh" "$task" \
            "Dispatched via 'agent dispatch' from Brain Mac" \
            "Complete the task and use report-back to send results"

        local handoff_id
        handoff_id=$(ls -t "$mount/handoffs/handoff-"*.md 2>/dev/null | head -1 | sed 's/.*handoff-//' | sed 's/.md//')

        if [[ -z "$handoff_id" ]]; then
            echo -e "${RED}Error: Failed to create handoff${NC}"
            return 1
        fi

        # Start tmux session with claude
        ssh "$host" "tmux new-session -d -s $session 'claude'" 2>/dev/null || true
        sleep 2
        ssh "$host" "tmux send-keys -t $session 'Read ~/handoffs/handoff-$handoff_id.md and complete the task. When done, use report-back $handoff_id \"summary\"' Enter" 2>/dev/null
    else
        # SSH-only mode: create handoff directly on agent
        echo -e "${YELLOW}SMB not mounted, using SSH-only mode${NC}"
        local handoff_id
        handoff_id=$(date +%Y%m%d-%H%M%S)

        # Create handoff file directly on agent via SSH
        ssh "$host" "mkdir -p ~/handoffs && cat > ~/handoffs/handoff-$handoff_id.md" << EOF
# Task Handoff: $handoff_id

## Task
$task

## Context
Dispatched via 'agent dispatch' from Brain Mac (SSH-only mode)

## Instructions
Complete the task and use report-back $handoff_id "summary" when done.

## Git State
$(git -C "$PROJECT_ROOT" log -1 --oneline 2>/dev/null || echo "Unknown")
$(git -C "$PROJECT_ROOT" branch --show-current 2>/dev/null || echo "Unknown branch")
EOF

        # Start tmux session with claude
        ssh "$host" "tmux new-session -d -s $session 'claude'" 2>/dev/null || true
        sleep 2
        ssh "$host" "tmux send-keys -t $session 'Read ~/handoffs/handoff-$handoff_id.md and complete the task. When done, use report-back $handoff_id \"summary\"' Enter" 2>/dev/null
    fi

    echo ""
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo -e "${GREEN}Task Dispatched${NC}"
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo "Agent:      $agent"
    echo "Session:    $session"
    echo "Handoff:    $handoff_id"
    echo ""
    echo "Monitor:    agent watch $agent $session"
    echo "Attach:     agent shell $agent"
    echo "Results:    agent results $agent"
}

# Collect results from agent
results() {
    local agent="$1"
    local mount
    mount=$(get_mount "$agent")

    echo -e "${BLUE}=== Results from agent: $agent ===${NC}"

    local responses
    responses=$(ls -t "$mount/handoffs/response-"*.md 2>/dev/null | head -5)

    if [[ -z "$responses" ]]; then
        echo -e "${YELLOW}No pending results${NC}"
        return 0
    fi

    for response in $responses; do
        echo ""
        echo -e "${CYAN}$(basename "$response")${NC}"
        echo "─────────────────────────────"
        head -20 "$response"
        echo "..."
        echo ""
    done
}

# Watch agent session output
watch_session() {
    local agent="$1"
    local session="$2"
    local host
    host=$(get_host "$agent")

    if [[ -z "$session" ]]; then
        echo -e "${RED}Error: Session name required${NC}"
        echo "Usage: agent watch <agent-name> <session-name>"
        return 1
    fi

    ssh "$host" "tmux capture-pane -t $session -p | tail -30"
}

# Open shell to agent
shell_agent() {
    local agent="$1"
    echo -e "${BLUE}Connecting to agent: $agent${NC}"
    delegate_tw shell
}

# Run command on agent
run_cmd() {
    local agent="$1"
    shift
    delegate_tw run "$@"
}

# Print usage
usage() {
    cat << 'EOF'
Agent Control - Brain/Agent Distributed Development

Usage: agent <command> [agent-name] [args...]

Commands:
  list                      List all configured agents
  status [agent]            Show agent status (default: all)
  dispatch <agent> "task"   Send task to agent
  results [agent]           Collect results from agent
  watch <agent> <session>   Watch session output
  shell [agent]             Open shell to agent
  run [agent] <cmd>         Run command on agent

Aliases (backward compatible):
  agent status         = tw status
  agent dispatch       = tw-handoff + tmux
  agent results        = tw-collect
  agent shell          = tw shell

Default agent: alpha (TW Mac)

Examples:
  agent status                    # Status of all agents
  agent status alpha              # Status of alpha (TW Mac)
  agent dispatch "run tests"      # Dispatch to default agent
  agent dispatch alpha "build"    # Dispatch to alpha specifically
  agent results                   # Get results from default agent
EOF
}

# Main dispatch
main() {
    local cmd="${1:-help}"
    shift || true

    case "$cmd" in
        list|ls)
            list_agents
            ;;
        status|s)
            local agent
            agent=$(resolve_agent "$1")
            status "$agent"
            ;;
        dispatch|d|send)
            local agent
            agent=$(resolve_agent "$1")
            if [[ -n "$agent" && "$1" == "$agent" ]]; then
                # First arg was agent name
                shift
            fi
            dispatch "${agent:-$DEFAULT_AGENT}" "$@"
            ;;
        results|r|collect)
            local agent
            agent=$(resolve_agent "${1:-$DEFAULT_AGENT}")
            results "$agent"
            ;;
        watch|w)
            local agent
            agent=$(resolve_agent "$1")
            shift || true
            watch_session "$agent" "$@"
            ;;
        shell|sh)
            local agent
            agent=$(resolve_agent "${1:-$DEFAULT_AGENT}")
            shell_agent "$agent"
            ;;
        run)
            local agent
            agent=$(resolve_agent "$1")
            if [[ -n "$agent" && "$1" == "$agent" ]]; then
                shift
            fi
            run_cmd "${agent:-$DEFAULT_AGENT}" "$@"
            ;;
        help|-h|--help)
            usage
            ;;
        *)
            echo -e "${RED}Unknown command: $cmd${NC}"
            usage
            return 1
            ;;
    esac
}

main "$@"
