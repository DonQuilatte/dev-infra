---
description: Security rules for secrets and credential handling
---

## Secrets Management

- **Never commit plaintext secrets** to the repository
- **Use `op://` references** for all credentials:
  ```
  ANTHROPIC_API_KEY=op://Developer/Anthropic Claude/API Key
  CLAWDBOT_GATEWAY_TOKEN=op://Private/Clawdbot Gateway Token/token
  ```
- **Check .gitignore** before adding any file that might contain sensitive data
- **Rotate credentials immediately** if exposed in logs or commits

## Validation

- Run `./scripts/verify-security.sh` before deployments
- Ensure `.env` files are gitignored
- Never hardcode secrets in scripts or configs

## Docker Security

- Use non-root users in containers
- Enable read-only rootfs where possible
- Apply seccomp profiles
- Drop unnecessary capabilities
