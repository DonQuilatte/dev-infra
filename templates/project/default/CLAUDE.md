# Claude Rules: {{PROJECT_NAME}}

## Project Overview

**Purpose:** [Describe project purpose]
**Tech Stack:** [List technologies]

## Workflow Rules

### File Operations
- Use dev-infra for secrets management
- Never commit secrets - use `op://` references

### Commands

```bash
# Development
npm run dev        # Start development server
npm run test       # Run tests
npm run lint       # Check code style

# Secrets
dev-infra secret "op://vault/item/field"  # Get secret
dev-infra secrets refresh                  # Refresh cache
```

## Project Structure

```
{{PROJECT_NAME}}/
├── src/           # Source code
├── tests/         # Test files
├── scripts/       # Utility scripts
├── .envrc         # direnv config
└── CLAUDE.md      # This file
```
