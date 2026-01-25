# Clawdbot Docker Wrapper - Updated Reality

## 🎯 What This Repository Actually Is

This repository provides **enterprise-grade Docker security hardening** for [Clawdbot](https://clawd.bot), wrapping the official npm package in a secure container.

### ✅ **Verified Reality**

- **Clawdbot EXISTS**: https://github.com/clawdbot/clawdbot
- **Official Installation**: `npm install -g clawdbot@latest`
- **Current Version**: 2026.1.23-1
- **This Repository**: Provides secure Docker wrapper + hardening

## 🔄 **Architecture**

```
Official Clawdbot (npm) → Docker Wrapper (this repo) → Enterprise Security
```

### **What Clawdbot Is**

- WhatsApp/Telegram/Discord/iMessage gateway
- Claude AI integration via subscription or API key
- Node.js CLI tool that runs as system service
- Stores config in `~/.clawdbot/`

### **What This Repository Adds**

- Secure Docker containerization
- Read-only filesystem
- Non-root user enforcement
- Dropped capabilities
- Custom seccomp profile
- **Apple Silicon Optimized**: Native ARM64 support (M1/M2/M3)
- **macOS Feature Bridge**: Securely access Apple Notes and host data
- Automated deployment scripts
- Security verification tools

## 🚀 **Quick Start**

### **Option 1: Test Official Installation First** (Recommended)

```bash
# Install Clawdbot officially
npm install -g clawdbot@latest

# Verify
clawdbot --version

# Run onboarding
clawdbot onboard

# Test it works
clawdbot gateway --port 18789
```

### **Option 2: Use Secure Docker Wrapper** (Production)

```bash
# Clone this repository
git clone https://github.com/DonQuilatte/clawdbot-docker.git
cd clawdbot-docker

# Build secure container
docker compose --env-file .env -f config/docker-compose.secure.yml build

# Deploy with security hardening
./scripts/deploy-secure.sh

# Verify security
./scripts/verify-security.sh
```

## 📖 **Documentation**

See [docs/README.md](docs/README.md) for complete documentation on:

- Dockerizing Clawdbot with security hardening
- Configuration and deployment
- Security best practices
- Troubleshooting

## ⚠️ **Important Notes**

1. **This is a wrapper** - Clawdbot itself is maintained at https://github.com/clawdbot/clawdbot
2. **Official method works** - You can use Clawdbot without Docker
3. **This adds security** - Docker wrapper provides enterprise-grade hardening
4. **Active development** - Clawdbot is actively maintained (latest: 2026.1.23-1)

## 🔗 **Links**

- **Official Clawdbot**: https://clawd.bot
- **GitHub**: https://github.com/clawdbot/clawdbot
- **Documentation**: https://docs.clawd.bot
- **npm Package**: https://www.npmjs.com/package/clawdbot
- **This Repository**: https://github.com/DonQuilatte/clawdbot-docker

---

**Status**: ✅ Verified working with Clawdbot 2026.1.23-1  
**Last Updated**: 2026-01-25
