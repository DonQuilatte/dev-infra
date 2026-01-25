# 🍎 Clawdbot Docker with macOS Integration

## Overview

This configuration gives your secure Docker container access to macOS features while maintaining security hardening.

## What's Different

### Standard Secure Deployment

- ✅ Fully isolated container
- ✅ No host access
- ✅ Maximum security
- ❌ No macOS-specific tools

### macOS-Integrated Deployment

- ✅ Maintains security hardening
- ✅ Access to Homebrew tools
- ✅ Access to macOS system utilities
- ✅ Can use Apple Notes and other macOS features
- ⚠️ Slightly reduced isolation (read-only mounts)

## Comparison & The SQLite Bridge

We have implemented a **Hybrid Bridge** that allows the **Standard Secure Deployment** to access Apple Notes without full host path exposure:

| Feature     | Standard Secure (Bridge) | macOS-Integrated (Full)   |
| ----------- | ------------------------ | ------------------------- |
| Isolation   | **Maximum**              | High                      |
| Apple Notes | ✅ (via SQLite mount)    | ✅ (via native tool)      |
| Homebrew    | ❌ (Internal shim only)  | ✅ (Read-only host mount) |
| Security    | Hardened                 | Enterprise                |

### The SQLite Bridge

Instead of mounting your entire system, we only mount the Notes database:

- Path: `/home/node/.notes/NoteStore.sqlite`
- Access: **Read-Only**
- Usage: Ask the agent to query this file directly.

## Security Trade-offs

### What's Still Secure

- ✅ Read-only root filesystem
- ✅ Non-root user
- ✅ All capabilities dropped
- ✅ No privileged mode
- ✅ Resource limits
- ✅ Network isolation

### What's Different

- ⚠️ Host paths mounted (read-only)
- ⚠️ Access to Homebrew binaries
- ⚠️ Access to system utilities
- ⚠️ Potential access to user data (Notes)

**Security Level**: Still enterprise-grade, but with controlled host access

## Deployment

### Stop Current Container

```bash
docker compose --env-file .env -f config/docker-compose.secure.yml down
```

### Start macOS-Integrated Container

```bash
docker compose -f config/docker-compose.macos.yml up -d clawdbot-gateway
```

### Verify Access

```bash
# Check if Homebrew is accessible
docker compose -f config/docker-compose.macos.yml exec clawdbot-gateway which brew

# Check available tools
docker compose -f config/docker-compose.macos.yml exec clawdbot-gateway brew list
```

## Using macOS Features

### Apple Notes

Once deployed, the apple-notes skill should work:

1. Open http://127.0.0.1:18789/skills
2. Find "apple-notes" skill
3. Click "Install" or "Enable"
4. The skill should now work with your macOS Notes

### Other macOS Tools

Any Homebrew-installed tool will be available:

```bash
# Example: Using a Homebrew tool
docker compose -f config/docker-compose.macos.yml exec clawdbot-gateway <tool-name>
```

## Management Commands

```bash
# Start
docker compose -f config/docker-compose.macos.yml up -d

# Stop
docker compose -f config/docker-compose.macos.yml down

# Logs
docker compose -f config/docker-compose.macos.yml logs -f

# Restart
docker compose -f config/docker-compose.macos.yml restart

# CLI
docker compose -f config/docker-compose.macos.yml run --rm clawdbot-cli
```

## Switching Between Modes

### To Standard Secure Mode

```bash
docker compose -f config/docker-compose.macos.yml down
docker compose --env-file .env -f config/docker-compose.secure.yml up -d
```

### To macOS-Integrated Mode

```bash
docker compose --env-file .env -f config/docker-compose.secure.yml down
docker compose -f config/docker-compose.macos.yml up -d
```

## Mounted Paths

The following host paths are mounted (read-only):

- `/opt/homebrew` → Homebrew installation
- `/usr/local/bin` → Local binaries
- `/usr/bin` → System binaries (as `/host/usr/bin`)
- `/bin` → Core binaries (as `/host/bin`)
- `~/Library/Group Containers/group.com.apple.notes` → Apple Notes data

## Troubleshooting

### Skill Still Blocked

If a skill is still blocked after deployment:

1. Restart the container
2. Check the skill requirements
3. Verify the tool is installed on your Mac
4. Check container logs for errors

### Permission Issues

If you get permission errors:

```bash
# Check file permissions
ls -la /opt/homebrew/bin/

# Ensure your user can read the files
# The container runs as UID 1000, which should match your user
```

### Tool Not Found

If a tool isn't found in the container:

```bash
# Check if it's in PATH
docker compose -f config/docker-compose.macos.yml exec clawdbot-gateway echo $PATH

# Check if the binary exists
docker compose -f config/docker-compose.macos.yml exec clawdbot-gateway ls -la /opt/homebrew/bin/
```

## Security Recommendations

1. **Use for personal/development** - This mode is best for personal use
2. **Use standard mode for production** - For production, use the fully isolated mode
3. **Monitor access** - Keep an eye on what the container accesses
4. **Review mounted paths** - Only mount what you need

## Comparison

| Feature         | Standard Secure | macOS-Integrated     |
| --------------- | --------------- | -------------------- |
| Isolation       | Maximum         | High                 |
| macOS Tools     | ❌              | ✅                   |
| Homebrew Access | ❌              | ✅ (read-only)       |
| Apple Notes     | ❌              | ✅                   |
| Security Level  | Maximum         | Enterprise           |
| Use Case        | Production      | Development/Personal |

## Next Steps

1. Deploy with macOS integration
2. Enable Apple Notes skill
3. Test macOS-specific features
4. Monitor performance and access

---

**Status**: Ready to deploy  
**Security**: Enterprise-grade with controlled host access  
**Compatibility**: macOS only
