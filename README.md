# dev-infrastructure

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

### `agy`

Quick launcher for Claude engagement.

- Local (default): `agy` or `agy "prompt"`
- Remote (TW Mac): `agy -r "prompt"`

### `agy-local`

Engage current project directory with Claude locally.

```bash
cd ~/Development/Projects/myproject
agy-local "analyze this codebase"
```

### `agy-project`

Clone and engage a project on TW Mac.

```bash
agy-project https://github.com/user/repo "review security"
```

Creates tmux session, clones repo, runs Claude headlessly.

## Previously: ClawdBot

This repository was previously named ClawdBot. See MIGRATION.md for transition details.
