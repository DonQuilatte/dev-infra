# Dev Infrastructure Restructuring Plan

## Executive Summary

Rename and restructure the ClawdBot repository to reflect its actual purpose: a comprehensive distributed development infrastructure system with MCP integration, multi-machine coordination, and Antigravity IDE patterns.

## Current State Analysis

### What We Have Now:

**Two Separate Repos:**
```
~/Development/Projects/dev-infrastructure/
  - Originally: clawdbot Docker wrapper
  - Actually: Multi-Mac infrastructure, Antigravity patterns, MCP reference
  - Misnamed and confusing purpose

~/Development/Projects/dev-infrastructure/mcp/
  - MCP environment deployment package
  - Should be integrated with main infrastructure
```

**Projects Using the Stack:**
- iphone-tco-planner ✅ MCP adopted
- ClawdBot (this repo) ✅ MCP adopted

### Problems with Current Structure:

1. **Confusing naming** - "ClawdBot" implies it's about clawdbot tool
2. **Split infrastructure** - MCP deployment separate from dev infrastructure
3. **No clear purpose** - README doesn't reflect actual use
4. **Hard to discover** - Team won't know this exists for new projects
5. **Duplicate documentation** - MCP docs in two places

---

## Proposed New Structure

### New Name: `dev-infrastructure`

**Location:** `/Users/jederlichman/Development/Projects/dev-infrastructure`

### Directory Structure:

```
dev-infrastructure/
├── README.md                           # Multi-machine dev environment overview
├── QUICK_START.md                      # Get started in 5 minutes
├── CHANGELOG.md                        # Version history
│
├── mcp/                                # MCP deployment system (merged from mcp-deployment)
│   ├── README.md                       # MCP system overview
│   ├── CHANGELOG.md                    # MCP version history
│   ├── scripts/
│   │   ├── global-setup.sh            # One-time machine setup
│   │   ├── project-setup.sh           # Per-project MCP deployment
│   │   └── validate-setup.sh          # Validation script
│   ├── templates/
│   │   ├── .antigravity/
│   │   │   └── config.json
│   │   ├── .envrc
│   │   └── wrapper-scripts/
│   └── docs/
│       ├── DEPLOYMENT.md
│       ├── TROUBLESHOOTING.md
│       └── SETUP_GUIDE.md
│
├── infrastructure/                     # Multi-machine setup
│   ├── README.md                       # Infrastructure overview
│   ├── main-mac/                       # This Mac configuration
│   │   ├── setup.sh
│   │   ├── .zshrc-additions
│   │   └── launchagents/
│   └── tw-mac/                         # Remote Mac (existing)
│       ├── README.md
│       ├── setup/
│       └── automation/
│
├── antigravity/                        # Antigravity IDE patterns
│   ├── README.md                       # Antigravity integration guide
│   ├── shell-integration.sh           # agy-* commands
│   ├── config-templates/              # Project config templates
│   └── workflows/                     # Common workflows
│
├── examples/                           # Reference implementations
│   ├── README.md                       # How to use examples
│   ├── basic-project/                 # Minimal MCP setup
│   │   ├── .antigravity/
│   │   ├── .envrc
│   │   └── scripts/
│   ├── full-stack-app/                # Complete setup (from iphone-tco-planner)
│   │   ├── .antigravity/
│   │   ├── .envrc
│   │   └── scripts/
│   └── custom-mcp-server/             # With custom MCP (from ClawdBot)
│       ├── .antigravity/
│       ├── .envrc
│       └── scripts/
│
├── scripts/                            # Global automation scripts
│   ├── deploy-to-project.sh          # One-command project setup
│   ├── health-check.sh                # System health monitoring
│   ├── sync-machines.sh               # Multi-Mac sync
│   └── lib/
│       └── common.sh
│
├── docs/                               # Comprehensive documentation
│   ├── INDEX.md                        # Documentation hub
│   ├── architecture/
│   │   ├── OVERVIEW.md                # System architecture
│   │   ├── MCP_DESIGN.md             # MCP integration design
│   │   └── MULTI_MAC_DESIGN.md       # Distributed setup
│   ├── guides/
│   │   ├── GETTING_STARTED.md        # New user guide
│   │   ├── MCP_DEPLOYMENT.md         # Deploy MCP to projects
│   │   ├── ANTIGRAVITY_SETUP.md      # Antigravity configuration
│   │   └── MULTI_MAC_SETUP.md        # Two-Mac setup
│   └── reference/
│       ├── MCP_SERVERS.md             # Available MCP servers
│       ├── COMMANDS.md                # Command reference
│       └── TROUBLESHOOTING.md         # Common issues
│
├── tests/                              # Test suite
│   ├── test-runner.sh
│   ├── unit/
│   └── integration/
│
└── .github/                            # GitHub configuration
    └── workflows/
        └── validate.yml                # CI validation
```

---

## Migration Steps

### Phase 1: Preparation (30 minutes)

**Step 1.1: Backup Everything**
```bash
# Backup current ClawdBot repo
cd /Users/jederlichman/Development/Projects
cp -r ClawdBot ClawdBot-backup-$(date +%Y%m%d)

# Backup mcp-deployment
cp -r ~/Development/Projects/dev-infrastructure/mcp mcp-deployment-backup-$(date +%Y%m%d)
```

**Step 1.2: Create Migration Branch**
```bash
cd ~/Development/Projects/dev-infrastructure
git checkout -b restructure-to-dev-infrastructure
git add -A
git commit -m "Checkpoint before restructure"
```

---

### Phase 2: Restructure (1 hour)

**Step 2.1: Rename Repository**
```bash
cd /Users/jederlichman/Development/Projects
mv ClawdBot dev-infrastructure
cd dev-infrastructure
```

**Step 2.2: Create New Directory Structure**
```bash
# Create top-level directories
mkdir -p mcp/{scripts,templates,docs}
mkdir -p infrastructure/{main-mac,tw-mac}
mkdir -p antigravity/{config-templates,workflows}
mkdir -p examples/{basic-project,full-stack-app,custom-mcp-server}
mkdir -p docs/{architecture,guides,reference}

# Move existing tw-mac infrastructure
mv infrastructure/tw-mac/* infrastructure/tw-mac-temp/
rmdir infrastructure/tw-mac
mv infrastructure/tw-mac-temp infrastructure/tw-mac
```

**Step 2.3: Merge mcp-deployment**
```bash
# Copy mcp-deployment content into mcp/
cp -r ~/Development/Projects/dev-infrastructure/mcp/scripts/* mcp/scripts/
cp -r ~/Development/Projects/dev-infrastructure/mcp/docs/* mcp/docs/
cp ~/Development/Projects/dev-infrastructure/mcp/{README.md,CHANGELOG.md} mcp/

# Copy templates
cp -r ~/Development/Projects/dev-infrastructure/mcp/templates/* mcp/templates/
```

**Step 2.4: Extract Antigravity Patterns**
```bash
# Move agy-* scripts
mv scripts/agy-* antigravity/
mv scripts/agy-shell-integration.sh antigravity/shell-integration.sh

# Create config templates
cp .antigravity/config.json antigravity/config-templates/standard.json
```

**Step 2.5: Create Examples**
```bash
# Basic project example
mkdir -p examples/basic-project/{.antigravity,scripts}
# Copy minimal config
cp antigravity/config-templates/standard.json examples/basic-project/.antigravity/config.json
# Copy basic wrappers
cp scripts/mcp-{gitkraken,filesystem} examples/basic-project/scripts/

# Full-stack example (from iphone-tco-planner)
mkdir -p examples/full-stack-app/{.antigravity,scripts}
# We'll reference iphone-tco-planner's actual files

# Custom MCP example (current ClawdBot setup)
mkdir -p examples/custom-mcp-server/{.antigravity,scripts}
cp .antigravity/config.json examples/custom-mcp-server/.antigravity/
cp scripts/mcp-* examples/custom-mcp-server/scripts/
```

**Step 2.6: Move Documentation**
```bash
# Architecture docs
mv docs/SYSTEM_STATUS.md docs/architecture/OVERVIEW.md
mv MCP_INTEGRATION.md docs/architecture/MCP_DESIGN.md

# Guides
mv VALIDATION_INSTRUCTIONS.md docs/guides/MCP_DEPLOYMENT.md
mv AGENT_HANDOFF.md docs/guides/VALIDATION_GUIDE.md

# Reference
mv QUICK_REFERENCE.md docs/reference/COMMANDS.md
cp docs/TROUBLESHOOTING.md docs/reference/TROUBLESHOOTING.md
```

---

### Phase 3: Create New Documentation (1 hour)

**Step 3.1: New README.md**
```bash
# Create comprehensive new README
# (content provided in next section)
```

**Step 3.2: Quick Start Guide**
```bash
# Create QUICK_START.md
# (content provided in next section)
```

**Step 3.3: Documentation Index**
```bash
# Create docs/INDEX.md
# Central hub for all documentation
```

---

### Phase 4: Update Scripts (30 minutes)

**Step 4.1: Create Master Deployment Script**
```bash
# scripts/deploy-to-project.sh
# Wrapper that calls mcp/scripts/project-setup.sh
# Plus Antigravity integration
```

**Step 4.2: Update Path References**
```bash
# Update all scripts with new paths
# Old: ~/Development/mcp-deployment/scripts/project-setup.sh
# New: ~/Development/Projects/dev-infrastructure/mcp/scripts/project-setup.sh
```

**Step 4.3: Create Health Check Script**
```bash
# scripts/health-check.sh
# Validate entire dev infrastructure
```

---

### Phase 5: Update Projects (30 minutes)

**Step 5.1: Update iphone-tco-planner**
```bash
cd /Users/jederlichman/Development/Projects/iphone-tco-planner

# Update any references to mcp-deployment
# Add note about new location
echo "# Dev Infrastructure: ~/Development/Projects/dev-infrastructure" >> README.md
```

**Step 5.2: Update Current Project (dev-infrastructure itself)**
```bash
cd /Users/jederlichman/Development/Projects/dev-infrastructure

# Self-reference updates
# This project IS the infrastructure
```

---

### Phase 6: Testing & Validation (1 hour)

**Step 6.1: Validate Structure**
```bash
cd /Users/jederlichman/Development/Projects/dev-infrastructure

# Run structure validation
tree -L 2 > STRUCTURE_VALIDATION.txt

# Verify all key files exist
ls -la mcp/scripts/project-setup.sh
ls -la infrastructure/tw-mac/
ls -la examples/
ls -la docs/INDEX.md
```

**Step 6.2: Test MCP Deployment**
```bash
# Create test project
mkdir -p ~/Development/test-project
cd ~/Development/test-project

# Deploy using new structure
bash ~/Development/Projects/dev-infrastructure/scripts/deploy-to-project.sh test-project

# Validate deployment
bash scripts/validate-mcp.sh
```

**Step 6.3: Test Multi-Mac Coordination**
```bash
# Verify tw-mac scripts still work
ssh tw-mac "echo 'Connection test'"

# Test monitoring
bash scripts/health-check.sh
```

---

### Phase 7: Cleanup & Commit (30 minutes)

**Step 7.1: Remove Old Files**
```bash
cd /Users/jederlichman/Development/Projects/dev-infrastructure

# Remove clawdbot-specific files that are no longer relevant
# (Keep config/ if it has useful Docker patterns)

# Remove duplicate documentation
# Remove old README references to clawdbot
```

**Step 7.2: Git Commit**
```bash
git add -A
git commit -m "Restructure: ClawdBot → dev-infrastructure

BREAKING CHANGES:
- Renamed repository to reflect actual purpose
- Merged mcp-deployment into mcp/ subdirectory  
- Reorganized into clear functional areas
- Created comprehensive documentation structure
- Added reference examples

MAJOR UPDATES:
- New README reflecting distributed dev infrastructure
- Consolidated MCP deployment system
- Extracted Antigravity patterns
- Created example projects
- Updated all documentation

MIGRATION:
- Old: ~/Development/Projects/ClawdBot
- New: ~/Development/Projects/dev-infrastructure
- Old: ~/Development/mcp-deployment  
- New: ~/Development/Projects/dev-infrastructure/mcp/

See MIGRATION.md for full details"
```

**Step 7.3: Tag Release**
```bash
git tag -a v2.0.0 -m "v2.0.0: Restructured as dev-infrastructure

Complete overhaul from ClawdBot-specific to general purpose
distributed development infrastructure system."

git push origin restructure-to-dev-infrastructure
git push origin v2.0.0
```

---

## New Documentation Content

### README.md (Main)

```markdown
# Distributed Development Infrastructure

**Multi-machine development environment with standardized MCP integration, Antigravity IDE patterns, and distributed compute coordination.**

## What This Provides

### 🏗️ Multi-Machine Development Cluster
- **Main Mac** (controller) + **tw-mac** (worker)
- Distributed job execution and monitoring
- Shared development environment
- Auto-sync and health monitoring

### 🔌 Standardized MCP Stack  
- Project-scoped MCP server configurations
- Secure credential management (1Password)
- Automatic environment switching (direnv)
- IDE integration (Antigravity, Cursor, VS Code, Claude Code)

### 🚀 Antigravity IDE Integration
- Auto-loading MCP servers per project
- Remote execution capabilities
- Shell integration (`agy` commands)
- Workflow automation

### 📦 Reference Implementations
- Basic project template
- Full-stack application pattern
- Custom MCP server integration

## Quick Start

### 1. Deploy MCP Stack to a Project

```bash
cd ~/Development/Projects/your-project
bash ~/Development/Projects/dev-infrastructure/scripts/deploy-to-project.sh your-project
```

### 2. Verify Setup

```bash
bash scripts/validate-mcp.sh
```

### 3. Open in Antigravity

```bash
antigravity .
# MCP servers auto-load from .antigravity/config.json
```

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  Development Cluster                     │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Main Mac                          tw-mac               │
│  ┌──────────────────┐             ┌──────────────────┐ │
│  │ Antigravity IDE  │◄───────────►│ Remote Executor  │ │
│  │ MCP Servers      │   Tailscale │ Docker Services  │ │
│  │ Project Files    │             │ Background Jobs  │ │
│  └──────────────────┘             └──────────────────┘ │
│          │                                 │            │
│          └────────── Coordination ─────────┘            │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## Components

| Component | Purpose | Location |
|-----------|---------|----------|
| **MCP System** | MCP server deployment & management | `mcp/` |
| **Infrastructure** | Multi-Mac setup & coordination | `infrastructure/` |
| **Antigravity** | IDE integration patterns | `antigravity/` |
| **Examples** | Reference implementations | `examples/` |
| **Scripts** | Automation & deployment | `scripts/` |
| **Docs** | Comprehensive guides | `docs/` |

## Projects Using This Stack

- ✅ **iphone-tco-planner** - Full-stack SvelteKit app
- ✅ **dev-infrastructure** (this repo) - Infrastructure reference
- 🔄 **[Your project here]** - Deploy with `scripts/deploy-to-project.sh`

## Documentation

- **[Quick Start](QUICK_START.md)** - Get running in 5 minutes
- **[Documentation Index](docs/INDEX.md)** - All guides and references
- **[MCP Deployment Guide](docs/guides/MCP_DEPLOYMENT.md)** - Deploy to projects
- **[Multi-Mac Setup](docs/guides/MULTI_MAC_SETUP.md)** - Two-machine configuration
- **[Architecture Overview](docs/architecture/OVERVIEW.md)** - System design

## Version

**Current Version:** 2.0.0  
**MCP Stack Version:** 1.1.0  
**Status:** ✅ Production Ready

---

**Previously:** ClawdBot Docker wrapper  
**Now:** Comprehensive distributed development infrastructure
```

### QUICK_START.md

```markdown
# Quick Start - 5 Minutes to Working MCP Stack

## Prerequisites

- macOS (tested on 10.15+)
- Homebrew installed
- Antigravity IDE installed (optional but recommended)

## Step 1: Clone Repository (if not already present)

```bash
# This repo should be at:
# /Users/jederlichman/Development/Projects/dev-infrastructure
cd ~/Development/Projects/dev-infrastructure
```

## Step 2: Deploy to Your Project

```bash
# Navigate to your project
cd ~/Development/Projects/your-project

# Deploy MCP stack
bash ~/Development/Projects/dev-infrastructure/scripts/deploy-to-project.sh your-project
```

**What this creates:**
- `.antigravity/config.json` - Antigravity MCP servers
- `.envrc` - Environment variables
- `scripts/mcp-*` - MCP wrapper scripts
- `.cursor/mcp.json` - Cursor IDE config
- `.vscode/mcp.json` - VS Code config
- `.claude/mcp.json` - Claude Code config

## Step 3: Verify

```bash
bash scripts/validate-mcp.sh
```

**Expected:** 8/8 tests pass

## Step 4: Open in Antigravity

```bash
antigravity .
```

**Check MCP panel:**
- ✓ github - connected
- ✓ filesystem - connected

## Done! 🎉

Your project now has:
- ✅ Workspace-scoped MCP servers
- ✅ Auto-loading in Antigravity
- ✅ Environment variable management ready
- ✅ Multi-IDE support

## Next Steps

- **Configure 1Password secrets:** Edit `.envrc`
- **Add custom MCP servers:** See `examples/custom-mcp-server/`
- **Set up tw-mac:** See `docs/guides/MULTI_MAC_SETUP.md`

## Troubleshooting

**MCP servers not showing?**
```bash
# Check wrapper scripts
bash scripts/mcp-filesystem
# Should start without errors
```

**Still issues?**
See [docs/reference/TROUBLESHOOTING.md](docs/reference/TROUBLESHOOTING.md)
```

---

## Migration Risks & Mitigation

### Risk 1: Breaking Existing Projects

**Risk:** iphone-tco-planner references old paths

**Mitigation:**
- Keep mcp-deployment as symlink initially
- Update projects gradually
- Test thoroughly before removing old location

```bash
# Temporary symlink during migration
ln -s ~/Development/Projects/dev-infrastructure/mcp ~/Development/mcp-deployment
```

### Risk 2: Git History Loss

**Risk:** Renaming loses commit history

**Mitigation:**
- Git tracks renames automatically
- Use `git mv` for moves within repo
- Tag v2.0.0 as clear marker

### Risk 3: Documentation Link Rot

**Risk:** Old README links break

**Mitigation:**
- Create MIGRATION.md with redirects
- Update all internal links
- Add deprecation notices in old files

---

## Timeline

**Total Time:** ~4-5 hours

| Phase | Duration | Can be Done Async |
|-------|----------|-------------------|
| Phase 1: Preparation | 30 min | No - must be first |
| Phase 2: Restructure | 1 hour | No - sequential |
| Phase 3: Documentation | 1 hour | Yes - can parallelize |
| Phase 4: Update Scripts | 30 min | Yes - after Phase 2 |
| Phase 5: Update Projects | 30 min | Yes - after Phase 2 |
| Phase 6: Testing | 1 hour | No - must be thorough |
| Phase 7: Cleanup | 30 min | No - must be last |

**Recommended Approach:** Do in one focused session to avoid inconsistent state

---

## Success Criteria

- [ ] Repository renamed to dev-infrastructure
- [ ] mcp-deployment merged into mcp/ subdirectory
- [ ] Infrastructure organized by function
- [ ] Examples created for all patterns
- [ ] Documentation restructured and complete
- [ ] All tests pass in test project
- [ ] iphone-tco-planner still works
- [ ] Git history preserved
- [ ] v2.0.0 tagged and pushed

---

## Post-Migration Tasks

1. **Update Team:**
   - Announce new repo name and location
   - Share QUICK_START.md
   - Schedule demo/walkthrough

2. **Update External References:**
   - Update any bookmarks
   - Update shell aliases
   - Update documentation links

3. **Archive Old Structure:**
   - Keep backups for 30 days
   - Document what was moved where
   - Remove after validation period

4. **Monitor for Issues:**
   - Watch for broken references
   - Track feedback from team
   - Iterate on documentation

---

## Questions Before Starting?

1. **Should we keep "ClawdBot" in git history?**
   - Recommendation: Yes, git tracks renames

2. **What about existing clawdbot Docker configs?**
   - Keep in `legacy/` or `archive/` directory
   - Or move to separate clawdbot-docker repo if still needed

3. **Timeline flexibility?**
   - Can split documentation phase if needed
   - Core restructure should be atomic

---

**Ready to Execute?** Start with Phase 1 backups, then proceed sequentially through phases.
