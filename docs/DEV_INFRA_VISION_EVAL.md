# Dev-Infra Vision Evaluation

**Date:** 2026-01-31
**Purpose:** Assess alignment between intended vision and current implementation

---

## Stated Vision

> Dev-infra is scaffolding and tooling supporting other projects. It should be equipped with tools (e.g., MCP) that can be turned on/off or optimized for project contexts. It's where we add new capabilities that other projects can leverage, avoiding multiple devops/tooling infrastructures.

**In essence:** A shared platform layer that projects inherit from, not copy.

---

## Vision Assessment: ✅ Sound, but Incomplete Implementation

The vision is architecturally correct. Centralized tooling that projects can selectively adopt is better than:
- Copy-pasting configs into each project
- Maintaining N versions of the same scripts
- Per-project MCP server sprawl

**This is the right pattern.** The question is execution.

---

## Current State Analysis

### What Exists

| Capability | Implementation | Reusability |
|------------|----------------|-------------|
| Agent dispatch (Brain/Agent) | `infrastructure/agents/`, `tw-mac/` | ✅ Generic |
| MCP deployment scripts | `mcp/scripts/` | ✅ Generic |
| Antigravity (Claude engage) | `scripts/agy*` | ✅ Generic |
| Docker security configs | `config/docker-*` | ⚠️ ClawdBot-specific |
| MCP server wrappers | `scripts/mcp-*` | ✅ Generic |
| Project templates | `templates/` | ❌ Minimal (only dependabot) |
| Test harnesses | `tests/` | ⚠️ ClawdBot-specific |

### MCP Server Inventory

**Configured in .antigravity/mcp_config.json:**
- `filesystem-dev-infra`
- `gitkraken-dev-infra`

**Wrapper scripts exist for:**
- `mcp-context7`
- `mcp-docker`
- `mcp-filesystem`
- `mcp-gitkraken`

**Not yet integrated:**
- Stitch (UI generation)
- Database servers (Tiger, etc.)
- Any domain-specific servers

---

## Gap Analysis

### Gap 1: No Project Inheritance Mechanism ❌

**Problem:** Other projects don't inherit from dev-infra. They'd need to manually copy/reference files.

**Evidence:**
```bash
grep -r "dev-infra" ~/Development/Projects/*/CLAUDE.md
# Only dev-infra itself references dev-infra
```

**What's needed:**
- A `dev-infra init <project>` command that scaffolds a project with:
  - Symlinked or copied MCP config
  - .envrc that sources dev-infra helpers
  - CLAUDE.md template with dev-infra skill references
- Or: A shared config location (e.g., `~/.config/dev-infra/`) that all projects can reference

### Gap 2: MCP "Menu" Doesn't Exist ❌

**Problem:** Vision says "tools that can be turned on/off." No mechanism for this exists.

**Current state:** Each project has its own `.mcp.json` or `.antigravity/mcp_config.json`. To "turn on" an MCP server for a project, you manually edit that project's config.

**What's needed:**
- A registry of available MCP servers in dev-infra
- A command like `dev-infra mcp enable stitch --project myapp`
- Or: A layered config system (base + project overrides)

### Gap 3: No Versioning or Sync ❌

**Problem:** When you update a script in dev-infra, other projects don't get the update.

**What's needed:**
- Either: Projects symlink to dev-infra (updates automatic)
- Or: A `dev-infra sync <project>` command
- Or: Publish dev-infra as an npm/brew package projects install

### Gap 4: Project Templates Are Minimal ⚠️

**Current templates:**
- `templates/dependabot/` - GitHub dependabot config
- `scripts/templates/` - ClawdBot-specific LaunchAgent templates

**Missing:**
- New project scaffold (CLAUDE.md, .envrc, .mcp.json)
- MCP config templates per project type
- Test harness templates

### Gap 5: Documentation Assumes dev-infra Context ⚠️

**Problem:** README shows commands like `npm run agents:wave1` but other projects wouldn't have those npm scripts.

**What's needed:**
- Docs on how OTHER projects use dev-infra
- Clear separation: "developing dev-infra" vs "using dev-infra from another project"

---

## Recommendation

### Option A: Symlink-Based (Simple, Immediate)

Projects symlink to dev-infra's configs:

```bash
# In project setup
ln -s ~/Development/Projects/dev-infra/mcp/configs/base.mcp.json .mcp.json
source ~/Development/Projects/dev-infra/scripts/lib/helpers.sh
```

**Pros:** Simple, updates propagate automatically
**Cons:** Tight coupling, breaks if dev-infra moves

### Option B: Config Layering (Flexible, More Work)

```
~/.config/dev-infra/
├── mcp-registry.json      # All available MCP servers
├── mcp-profiles/          # Preset combinations
│   ├── frontend.json      # Stitch, filesystem, browser
│   ├── backend.json       # Database, docker, API
│   └── full.json          # Everything
└── active/                # Currently enabled configs
```

Projects reference profiles or build custom selections.

**Pros:** Maximum flexibility, clean separation
**Cons:** More infrastructure to build

### Option C: Hybrid (Recommended)

1. **Immediate:** Add `dev-infra scaffold <project>` command that creates:
   - `.envrc` with `source ~/Development/Projects/dev-infra/scripts/lib/common.sh`
   - `.mcp.json` symlinked or copied from template
   - `CLAUDE.md` with dev-infra reference

2. **Short-term:** Build MCP registry in dev-infra:
   - `dev-infra mcp list` - show available servers
   - `dev-infra mcp enable <server>` - add to current project
   - `dev-infra mcp sync` - update project from dev-infra

3. **Later:** Consider publishing if this scales beyond your machines

---

## Immediate Actions

| Priority | Action | Rationale |
|----------|--------|-----------|
| P0 | Fix 1Password token on TW Mac | Blocks automation (from prior eval) |
| P1 | Create `dev-infra scaffold` command | Enable the vision for other projects |
| P1 | Document MCP server registry | Know what's available before adding more |
| P2 | Add Stitch MCP to registry | Once mechanism exists, adding servers is trivial |
| P3 | Create project type profiles | frontend, backend, full-stack presets |

---

## Conclusion

**Vision: ✅ Correct**
**Implementation: ⚠️ 60% there**

Dev-infra has the tooling but lacks the distribution mechanism. It's a library without a package manager. Before adding more capabilities (Stitch, etc.), build the system that lets other projects easily consume what already exists.

The Stitch integration request is valid, but it should go into the MCP registry, not be hardwired. First, build the registry.
