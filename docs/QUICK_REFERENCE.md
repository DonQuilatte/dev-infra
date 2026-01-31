# Quick Reference

Essential commands for daily operations.

---

## 🧠 Brain/Agent Architecture

| Role | Machine | Purpose |
|------|---------|---------|
| **Brain** | Main Mac (192.168.1.230) | Decision-making, orchestration, user interaction |
| **Agent Alpha** | TW Mac (192.168.1.245) | Task execution, builds, long-running processes |

### Agent Commands

```bash
agent status              # Check all agent connectivity
agent dispatch "task"     # Send task to agent
agent results             # Collect results from agent
agent shell               # Open shell to agent
agent list                # Show configured agents
```

### Legacy Commands (Still Work)

```bash
tw status                 # Check TW Mac connectivity
tw run '<cmd>'            # Execute command on TW Mac
tw-handoff                # Create task handoff
```

---

## 🚀 Daily Operations

### Start Everything

```bash
# 1. Start gateway on main Mac
clawdbot gateway start

# 2. Verify remote node connected
clawdbot gateway status

# 3. Open dashboard
open http://localhost:18789
```

### Quick Status Check

```bash
# Full health check
echo "Gateway: $(curl -s http://localhost:18789/health > /dev/null && echo ✅ || echo ❌)"
echo "SSH: $(ssh -o ConnectTimeout=3 tywhitaker@192.168.1.245 'echo OK' 2>/dev/null && echo ✅ || echo ❌)"
```

---

## 🐳 Docker Commands

### Gateway Control

```bash
# Start
docker compose --env-file .env -f config/docker-compose.secure.yml up -d

# Stop
docker compose --env-file .env -f config/docker-compose.secure.yml down

# Status
docker compose --env-file .env -f config/docker-compose.secure.yml ps

# Logs
docker compose --env-file .env -f config/docker-compose.secure.yml logs -f
```

### Maintenance

```bash
# Update images
docker compose pull

# Clean system
docker system prune

# Check disk usage
docker system df
```

---

## 📊 Status Commands

### Main Mac (Gateway)

```bash
clawdbot gateway status   # Gateway status
clawdbot gateway logs     # View logs
clawdbot gateway logs -f  # Follow logs
curl http://localhost:18789/health  # Health check
```

### Remote Mac (Node)

```bash
ssh tywhitaker@192.168.1.245 'clawdbot node status'  # Node status
ssh tywhitaker@192.168.1.245 'clawdbot node logs'    # Node logs
ssh tywhitaker@192.168.1.245 'launchctl list | grep clawdbot'  # Auto-restart
```

---

## 🔧 Restart Commands

```bash
# Gateway
clawdbot gateway restart

# Remote Node
ssh tywhitaker@192.168.1.245 'clawdbot node restart'

# Auto-start Service
ssh tywhitaker@192.168.1.245 'launchctl unload ~/Library/LaunchAgents/com.clawdbot.node.plist && launchctl load ~/Library/LaunchAgents/com.clawdbot.node.plist'
```

---

## 🔍 Troubleshooting

### Network Tests

```bash
curl -s http://localhost:18789/health  # Gateway reachable
ping -c 1 192.168.1.245                # Remote reachable
ssh -o ConnectTimeout=5 tywhitaker@192.168.1.245 'echo OK'  # SSH works
```

### Process Checks

```bash
pgrep -fl clawdbot        # Gateway processes
lsof -i :18789            # Port usage
ssh tywhitaker@192.168.1.245 'pgrep -fl clawdbot'  # Remote processes
```

### Log Checks

```bash
clawdbot gateway logs | grep -i error  # Gateway errors
ssh tywhitaker@192.168.1.245 'tail -20 ~/.clawdbot/logs/startup.log'  # Remote log
```

---

## 🔒 Security Commands

```bash
# Run security verification
./scripts/verify-security.sh

# Deploy with security hardening
./scripts/deploy-secure.sh
```

---

## 📁 Important Paths

### Main Mac

| Path | Description |
|------|-------------|
| `~/.clawdbot/clawdbot.json` | Gateway configuration |
| `~/.ssh/config` | SSH configuration |
| `~/Development/Projects/dev-infra/` | Project directory |

### Remote Mac

| Path | Description |
|------|-------------|
| `~/.clawdbot/clawdbot.json` | Node configuration |
| `~/.clawdbot/logs/` | Node logs |
| `~/Library/LaunchAgents/com.clawdbot.node.plist` | Auto-start config |

---

## 🌐 Network Info

| Resource | Address |
|----------|---------|
| Main Mac | 192.168.1.230 |
| Remote Mac | 192.168.1.245 |
| Gateway Port | 18789 |
| Dashboard | http://localhost:18789 |

---

## 🆘 Emergency

```bash
# Kill all processes
pkill -f clawdbot
ssh tywhitaker@192.168.1.245 'pkill -f clawdbot'

# Clear locks and restart
rm -f ~/.clawdbot/*.lock
clawdbot gateway start
```

---

## 📚 Documentation

- [Deployment Guide](DEPLOYMENT.md)
- [Security Guide](SECURITY.md)
- [Troubleshooting](TROUBLESHOOTING.md)
- [Docker Guide](DOCKER_GUIDE.md)

---

**Last Updated:** 2026-01-31
