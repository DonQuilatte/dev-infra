# Antigravity MCP - Quick Reference

## 🚀 Daily Commands

```bash
# Activate clawdbot MCP config
cd ~/Development/Projects/clawdbot
./scripts/antigravity-activate
# Then restart Antigravity

# Check active config
cat ~/.gemini/mcp_config.json

# Reload environment
direnv allow

# Check environment variables
echo $PROJECT_ROOT
echo $DOCKER_HOST
```

## 📊 Status Checks

```bash
# MCP server count
jq '.mcpServers | length' ~/.gemini/mcp_config.json

# List active MCP servers
jq -r '.mcpServers | keys[]' ~/.gemini/mcp_config.json

# Verify absolute paths
grep -r "args" ~/.gemini/mcp_config.json

# Check direnv status
direnv status

# Test 1Password integration
op whoami
```

## 🔧 Maintenance

```bash
# Update MCP wrapper scripts
vim scripts/mcp-gitkraken
chmod +x scripts/mcp-*

# Edit environment
vim .envrc
direnv allow

# Edit MCP config
vim .antigravity/mcp_config.json
./scripts/antigravity-activate

# Backup current config
cp ~/.gemini/mcp_config.json ~/.gemini/mcp_config.json.backup
```

## 🐛 Quick Fixes

```bash
# MCP servers not loading?
./scripts/antigravity-activate
# Restart Antigravity

# Environment not loading?
direnv allow

# Docker socket not found?
echo 'export DOCKER_HOST="unix:///Users/jederlichman/.orbstack/run/docker.sock"' > .envrc.local
direnv allow

# 1Password not working?
op signin
# Enable CLI integration in 1Password app
```

## 📁 Key Files

| File                           | Purpose                                 |
| ------------------------------ | --------------------------------------- |
| `~/.config/direnv/direnvrc`    | Global direnv config                    |
| `~/.gemini/mcp_config.json`    | Active Antigravity MCP config (symlink) |
| `.envrc`                       | Project environment variables           |
| `.antigravity/mcp_config.json` | Project MCP configuration               |
| `scripts/antigravity-activate` | Config activation script                |
| `scripts/mcp-*`                | MCP wrapper scripts                     |

## 🎯 MCP Servers

- **gitkraken-clawdbot**: Git operations, PR management
- **docker-clawdbot**: Docker container management
- **filesystem-clawdbot**: File system operations

## 🔄 Project Switching

```bash
# From clawdbot to other-project
cd ~/Development/Projects/other-project
./scripts/antigravity-activate
# Restart Antigravity

# Back to clawdbot
cd ~/Development/Projects/clawdbot
./scripts/antigravity-activate
# Restart Antigravity
```

## ⚠️ Remember

- ✅ Always restart Antigravity after activating config
- ✅ Use absolute paths (no `${workspaceFolder}`)
- ✅ Keep MCP count ≤ 25 (currently: 3)
- ✅ Name servers with project suffix (`-clawdbot`)
- ✅ Run `direnv allow` after editing `.envrc`
