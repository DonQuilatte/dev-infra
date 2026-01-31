---
description: Core project constraints for dev-infra development
---

## File Organization

- **Never save files to root folder** - use appropriate subdirectories (`src/`, `scripts/`, `docs/`, `config/`)
- **Always use absolute paths** starting with `/Users/jederlichman/`
- **Verify file operations succeeded** with `ls -la` or `cat` after writes
- **Report actual file sizes/paths** after writes

## Code Standards

- **Modular design**: Keep files under 500 lines
- **Prefer editing existing files** over creating new ones
- **Never create documentation files** unless explicitly requested
- **Bash scripts**: Use `set -e`, validate inputs, log steps
- **Docker configs**: Pin versions, drop capabilities, read-only rootfs

## Architecture

- **Brain** (Main Mac, 192.168.1.230): Decision-making, orchestration
- **Agent Alpha** (TW Mac, 192.168.1.245): Task execution, builds

## Build Commands

```bash
npm run build      # Build
npm run test       # Test
npm run lint       # Lint
```
