# dev-infra

Distributed development infrastructure for Mac environments.

## What's Included

- **MCP Stack** (`mcp/`) - Model Context Protocol server deployment
- **Docker Security** - Hardened container configurations
- **Agent Dispatch** - Parallel agent task system
- **TW Mac Integration** - Dual-Mac distributed development

## Quick Start

```bash
# Deploy MCP to a project
bash mcp/scripts/project-setup.sh <project-name>

# Dispatch parallel agents
npm run agents:wave1
```

## AntiGravity Scripts

Project engagement automation for local and distributed Claude sessions.

### `agy` - Smart Router

Auto-detects context and routes to appropriate handler.

```bash
# Smart mode - auto-detect project from current directory
cd ~/Development/Projects/myapp && agy

# Local execution (default)
agy myapp                      # Start Claude in project
agy myapp "analyze code"       # Start with prompt
agy git@github.com:you/repo    # Clone + start local

# Remote execution (TW Mac with job tracking)
agy -r myapp "implement feature"
agy -r status                  # View all remote jobs
```

**Flags:**
- `-r, --remote` - Execute on TW Mac with job tracking
- `-l, --local` - Force local execution (default)

### `agy-local` - Local Engagement

Engage projects locally with Claude.

```bash
agy-local myapp                          # Open existing project
agy-local git@github.com:you/myapp.git   # Clone + open
agy-local myapp "Review code"            # Open with prompt
agy-local myapp --tw                     # Proxy to TW Mac
```

**What it does:**
1. Clones repo if URL provided (or pulls latest if exists)
2. Runs `scripts/project-setup.sh` if present
3. Configures direnv if `.envrc` exists
4. Starts Claude in project directory

### `agy-project` - Remote Execution (TW Mac)

Clone and engage projects on TW Mac with full job tracking.

```bash
# Start jobs
agy-project git@github.com:you/repo "review security"
agy-project myapp "implement feature X"

# Job management
agy-project status              # View all jobs
agy-project logs <job-id>       # View job logs
agy-project result <job-id>     # Get structured result
agy-project attach <job-id>     # Attach to live session
```

**Features:**
- Job ID tracking (`project-YYYYMMDD-HHMMSS`)
- Metadata stored in `~/Development/.agy-jobs/`
- macOS notifications on job start
- tmux session per job for attachment
- Input sanitization (command injection protection)

### `agy-jobs` - Job Management (TW Mac)

Runs on TW Mac to manage job state.

```bash
agy-jobs status           # List all jobs with status
agy-jobs logs <job-id>    # View job log file
agy-jobs result <job-id>  # Get structured result
```

### `agy-notify` - Notifications (TW Mac)

Sends notifications for job events.

```bash
agy-notify "Job Started" "myapp-20260129-1423"
```

**Outputs to:**
- macOS notification center
- Log file: `~/Development/.agy-jobs/notifications.log`
- Slack webhook (if `SLACK_WEBHOOK_URL` is set)

### Shell Integration

Add to `~/.zshrc` for auto-detection when entering project directories:

```bash
source ~/Development/Projects/dev-infra/scripts/agy-shell-integration.sh
```

**Provides:**
- Auto-notification when entering project directories
- Alias `a` for `agy`
- Alias `agys` for `agy -r status`

## Previously: ClawdBot

This repository was previously named ClawdBot. See MIGRATION.md for transition details.
