---
description: deploy - Secure deployment workflow for dev-infra
---

Execute the secure deployment process with full verification.

### 1. Pre-flight Security Audit

Run the security verification script to ensure no vulnerabilities:

```bash
./scripts/verify-security.sh
```

If any checks fail, resolve them before proceeding.

### 2. Deploy

Run the secure deployment script:

```bash
./scripts/deploy-secure.sh
```

### 3. Post-deployment Verification

Verify container health and security posture:

```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
docker inspect --format='{{.State.Running}}' $(docker ps -q) 2>/dev/null || echo "No containers running"
```

### 4. Report Status

Summarize:
- Containers deployed
- Security checks passed/failed
- Any warnings or issues requiring attention
