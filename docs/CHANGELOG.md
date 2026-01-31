# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-01-31

### Added

- **Brain/Agent distributed architecture** - Multi-Mac orchestration with Brain (decision-making) and Agent Alpha (task execution)
- `agent` command family for distributed operations (`status`, `dispatch`, `results`, `shell`, `list`)
- SSH-only dispatch mode when SMB not mounted
- Brain/Agent E2E system test with manual CI trigger
- Google Stitch MCP server configuration
- Comprehensive distributed system documentation

### Changed

- Migrated from monolithic to Brain/Agent architecture (Phase 6 complete)
- Connectivity tests now use Tailscale-first routing
- Scripts refactored to source `common.sh` with fallback

### Fixed

- Resolved symlinks in `agent-control.sh` for correct PROJECT_ROOT detection
- Added strict mode to `agy-notify` and `start-node.sh.template`
- Fixed shellcheck warnings across all scripts (SC2155, SC2162, etc.)
- Quoted values with spaces in `.env.example`

### Documentation

- Consolidated 35 docs into focused guides
- Added DISTRIBUTED_QUICK_REFERENCE.md for Brain/Agent operations
- Updated CLAUDE.md with Brain/Agent workflow rules

## [1.1.1] - 2026-01-25

### Fixed

- Fixed 48 docker compose commands to include `--env-file .env` flag
- Fixed shellcheck warnings in `deploy-secure.sh` (SC2155, SC2162)
- Fixed docker compose path consistency in `verify-security.sh`

### Added

- Added `docs/REVIEW_REPORT.md` - Comprehensive code review documentation
- Added `docs/OPTIMIZATION_SUMMARY.md` - Summary of optimizations applied
- Enhanced `.gitignore` with IDE, temp, and 1Password cache entries

### Changed

- All docker compose commands now consistently use `--env-file .env -f config/docker-compose.secure.yml`
- `deploy-secure.sh` now passes shellcheck with 0 warnings

## [1.1.0] - 2026-01-25

### Added

- 1Password integration for secrets management
- macOS-specific Docker compose configuration
- Seccomp profile for enhanced container security
- Comprehensive security verification script

### Security

- Restricted 1Password access to Developer vault only
- Removed all hardcoded credentials
- Added read-only filesystem enforcement
- Added capability dropping (ALL)
- Added no-new-privileges flag

## [1.0.0] - 2026-01-25

### Added

- Initial release of Clawdbot Docker setup
- Docker Compose configuration with gateway and CLI services
- Automated `docker-setup.sh` script with prerequisite checks
- Environment variable configuration via `.env` file
- Persistent data volume management
- Health check configuration
- Resource limits (CPU and memory)
- Network isolation with bridge networking
- Comprehensive documentation:
  - Main README with quick start guide
  - QUICK_REFERENCE.md with essential commands
  - SECURITY.md with security best practices
  - TROUBLESHOOTING.md with common issues and solutions
  - DOCKER_GUIDE.md with detailed configuration reference
  - FILE_STRUCTURE.md with repository overview
- Security features:
  - Strict sandbox mode
  - Localhost-only binding
  - Restrictive tool policies
  - Audit logging
  - Prompt injection protection
  - Rate limiting
- Support for multiple AI providers:
  - Anthropic (Claude) via setup-token
  - Google Antigravity via OAuth
- CLI commands for:
  - Configuration management
  - Provider authentication
  - Health diagnostics
  - Plugin management

### Security

- Default configuration uses strict sandbox mode
- Gateway binds to localhost only by default
- Docker socket mounted read-only
- Comprehensive security documentation
- Audit logging capabilities

### Documentation

- Complete setup guide for macOS
- Step-by-step authentication instructions
- Security best practices
- Troubleshooting for common issues
- Docker configuration reference
- Quick reference for daily operations

## Version History

### [1.0.0] - 2026-01-25

- Initial release

---

## Release Notes Template

Use this template for future releases:

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added

- New features

### Changed

- Changes in existing functionality

### Deprecated

- Soon-to-be removed features

### Removed

- Removed features

### Fixed

- Bug fixes

### Security

- Security improvements
```

## Upgrade Guide

### From 0.x to 1.0.0

This is the initial release. No upgrade path needed.

### Future Upgrades

Upgrade instructions will be added here for future versions.

---

## Contributing

When making changes:

1. Update this CHANGELOG.md
2. Update relevant documentation
3. Update version numbers in:
   - docker-compose.yml (image tags)
   - README.md (if applicable)
4. Tag releases in git:
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```

## Links

- [Repository](https://github.com/clawdbot/clawdbot)
- [Documentation](https://docs.clawd.bot)
- [Issues](https://github.com/clawdbot/clawdbot/issues)
- [Releases](https://github.com/clawdbot/clawdbot/releases)
