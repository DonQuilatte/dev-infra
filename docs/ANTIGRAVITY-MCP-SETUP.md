# Antigravity MCP Setup - Clawdbot Project

## ✅ Setup Complete!

Your clawdbot project is now configured for Antigravity IDE with MCP (Model Context Protocol) support.

---

## 📋 What Was Configured

### **Global Setup (One-Time)**

- ✅ **direnvrc**: `~/.config/direnv/direnvrc`
  - 1Password integration (`op_export` function)
  - Docker socket detection

### **Project-Specific Setup**

- ✅ **Environment**: `.envrc`
  - Project variables (PROJECT_NAME, PROJECT_ROOT)
  - Docker configuration
  - 1Password secret placeholders
- ✅ **MCP Wrapper Scripts**: `scripts/mcp-*`
  - `mcp-gitkraken` - GitKraken MCP server
  - `mcp-docker` - Docker MCP server
  - `mcp-filesystem` - Filesystem MCP server
- ✅ **Antigravity Config**: `.antigravity/mcp_config.json`
  - Uses absolute paths (no `${workspaceFolder}`)
  - Named with project suffix (`-clawdbot`)
- ✅ **Activation Script**: `scripts/antigravity-activate`
  - Easy switching between projects
- ✅ **Git Configuration**: `.gitignore`
  - Ignores `.envrc.local`, `.direnv/`, backup files
  - Tracks `.envrc` and `.antigravity/mcp_config.json`

---

## 🚀 How to Use

### **First Time Setup**

1. **Activate the configuration** (already done):

   ```bash
   ./scripts/antigravity-activate
   ```

2. **Restart Antigravity IDE**

   - Quit Antigravity completely
   - Relaunch Antigravity
   - Open the clawdbot project

3. **Verify MCP servers are loaded**:
   - Check Antigravity's MCP panel/status
   - You should see:
     - `gitkraken-clawdbot`
     - `docker-clawdbot`
     - `filesystem-clawdbot`

### **Daily Workflow**

When working on clawdbot:

```bash
cd ~/Development/Projects/clawdbot
# direnv will automatically load environment
# MCP config is already active (symlinked)
```

### **Switching Between Projects**

When you have multiple projects with MCP:

```bash
# Switch to another project
cd ~/Development/Projects/other-project
./scripts/antigravity-activate

# Restart Antigravity
# Now MCP servers for 'other-project' are active

# Switch back to clawdbot
cd ~/Development/Projects/clawdbot
./scripts/antigravity-activate

# Restart Antigravity
# Now MCP servers for 'clawdbot' are active
```

---

## 🔧 Configuration Details

### **MCP Servers**

| Server                | Purpose                       | Command                                   |
| --------------------- | ----------------------------- | ----------------------------------------- |
| `gitkraken-clawdbot`  | Git operations, PR management | `@gitkraken/mcp-server`                   |
| `docker-clawdbot`     | Docker container management   | `@docker/mcp-server`                      |
| `filesystem-clawdbot` | File system operations        | `@modelcontextprotocol/server-filesystem` |

### **Environment Variables**

Available in `.envrc`:

- `PROJECT_NAME` - "clawdbot"
- `PROJECT_ROOT` - Absolute path to project
- `DOCKER_HOST` - Auto-detected Docker socket
- `DC_LOG_LEVEL` - Docker Compose log level
- `DC_CONFIG_DIR` - Docker Compose config directory

### **1Password Integration** (Optional)

To use 1Password secrets, uncomment these lines in `.envrc`:

```bash
op_export GITHUB_TOKEN "op://Development/GitHub Token/credential"
op_export GITKRAKEN_TOKEN "op://Development/GitKraken Token/credential"
op_export OPENAI_API_KEY "op://Development/OpenAI/api_key"
```

Then:

1. Ensure 1Password app is running and unlocked
2. Enable CLI integration in 1Password settings
3. Run `direnv allow` to reload

---

## 🧪 Testing & Validation

### **Test 1: Verify Config Activation**

```bash
cat ~/.gemini/mcp_config.json
# Should show clawdbot MCP servers
```

### **Test 2: Check Absolute Paths**

```bash
cat .antigravity/mcp_config.json | grep "args"
# Should show full paths like:
# "/Users/jederlichman/Development/Projects/clawdbot/scripts/mcp-gitkraken"
```

### **Test 3: Environment Inheritance**

```bash
cd ~/Development/Projects/clawdbot
echo $PROJECT_ROOT
# Should output: /Users/jederlichman/Development/Projects/clawdbot

echo $DOCKER_HOST
# Should output Docker socket path (e.g., unix:///Users/jederlichman/.orbstack/run/docker.sock)
```

### **Test 4: MCP Server Count**

```bash
cat ~/.gemini/mcp_config.json | jq '.mcpServers | length'
# Should output: 3 (well under the 25 recommended limit)
```

### **Test 5: Wrapper Scripts**

```bash
ls -lh scripts/mcp-*
# All should be executable (rwxr-xr-x)
```

---

## 🔄 Updating Configuration

### **Add a New MCP Server**

1. Create wrapper script:

   ```bash
   cat > scripts/mcp-newserver << 'EOF'
   #!/usr/bin/env bash
   set -e
   cd "/Users/jederlichman/Development/Projects/clawdbot"
   exec npx -y @some/mcp-server
   EOF
   chmod +x scripts/mcp-newserver
   ```

2. Update `.antigravity/mcp_config.json`:

   ```json
   {
     "mcpServers": {
       "newserver-clawdbot": {
         "command": "bash",
         "args": [
           "/Users/jederlichman/Development/Projects/clawdbot/scripts/mcp-newserver"
         ]
       }
     }
   }
   ```

3. Reactivate and restart:
   ```bash
   ./scripts/antigravity-activate
   # Restart Antigravity
   ```

### **Modify Environment Variables**

1. Edit `.envrc`:

   ```bash
   vim .envrc
   # or
   code .envrc
   ```

2. Reload direnv:
   ```bash
   direnv allow
   ```

---

## 🆚 Antigravity vs Cursor/VS Code

| Feature              | Cursor/VS Code        | Antigravity       | Workaround                    |
| -------------------- | --------------------- | ----------------- | ----------------------------- |
| Workspace config     | ✅ `.cursor/mcp.json` | ❌ Global only    | ✅ Use activation script      |
| `${workspaceFolder}` | ✅ Supported          | ❌ Not supported  | ✅ Use absolute paths         |
| Auto-switching       | ✅ Automatic          | ❌ Manual         | ✅ Run `antigravity-activate` |
| Tool limit           | ✅ Unlimited          | ⚠️ 25 recommended | ✅ Keep minimal (3 servers)   |
| Env inheritance      | ✅ Reliable           | ⚠️ Verify         | ✅ Use direnv                 |
| Team sharing         | ✅ Git commits        | ⚠️ Manual setup   | ✅ Share setup pattern        |

---

## 📁 File Structure

```
clawdbot/
├── .antigravity/
│   └── mcp_config.json          # Antigravity MCP configuration
├── .envrc                        # Project environment variables
├── .gitignore                    # Updated with direnv/Antigravity entries
├── scripts/
│   ├── mcp-gitkraken            # GitKraken MCP wrapper
│   ├── mcp-docker               # Docker MCP wrapper
│   ├── mcp-filesystem           # Filesystem MCP wrapper
│   └── antigravity-activate     # Config activation script
└── ...

~/.config/direnv/
└── direnvrc                      # Global direnv configuration

~/.gemini/
└── mcp_config.json              # Symlink to .antigravity/mcp_config.json
```

---

## 🐛 Troubleshooting

### **MCP Servers Not Loading**

1. Check if config is active:

   ```bash
   ls -la ~/.gemini/mcp_config.json
   # Should be a symlink to your project config
   ```

2. Verify absolute paths:

   ```bash
   cat ~/.gemini/mcp_config.json
   # All paths should be absolute, not relative
   ```

3. Restart Antigravity completely:
   - Quit Antigravity (Cmd+Q)
   - Wait 5 seconds
   - Relaunch

### **Environment Variables Not Loading**

1. Check direnv is allowed:

   ```bash
   cd ~/Development/Projects/clawdbot
   direnv status
   ```

2. Reload direnv:

   ```bash
   direnv allow
   ```

3. Check direnvrc exists:
   ```bash
   cat ~/.config/direnv/direnvrc
   ```

### **1Password Integration Failing**

1. Verify 1Password CLI:

   ```bash
   op whoami
   ```

2. Enable CLI integration:

   - Open 1Password app
   - Settings → Developer
   - Enable "Integrate with 1Password CLI"

3. Test secret reading:
   ```bash
   op read "op://Development/GitHub Token/credential"
   ```

### **Docker Socket Not Found**

1. Check Docker is running:

   ```bash
   docker ps
   ```

2. Manually set DOCKER_HOST in `.envrc.local`:
   ```bash
   echo 'export DOCKER_HOST="unix:///Users/jederlichman/.orbstack/run/docker.sock"' > .envrc.local
   direnv allow
   ```

---

## 📚 Additional Resources

- **MCP Documentation**: https://modelcontextprotocol.io/
- **GitKraken MCP**: https://github.com/gitkraken/mcp-server
- **Docker MCP**: https://github.com/docker/mcp-server
- **direnv**: https://direnv.net/
- **1Password CLI**: https://developer.1password.com/docs/cli/

---

## 🎯 Next Steps

1. **Restart Antigravity** to load the MCP configuration
2. **Test MCP servers** by using GitKraken, Docker, and filesystem commands
3. **Configure 1Password secrets** (optional) for enhanced security
4. **Set up other projects** using the same pattern

---

## ✨ Benefits

- ✅ **Secure**: Secrets managed via 1Password, not committed to git
- ✅ **Portable**: Absolute paths work across different machines
- ✅ **Minimal**: Only 3 MCP servers (well under 25 limit)
- ✅ **Flexible**: Easy to switch between projects
- ✅ **Team-friendly**: Configuration can be shared via git
- ✅ **Docker-aware**: Auto-detects OrbStack, Docker Desktop, Colima, etc.

---

**Setup completed on**: 2026-01-28  
**Antigravity version**: Latest  
**Project**: clawdbot
