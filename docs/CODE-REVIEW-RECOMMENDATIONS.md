# Code Review Recommendations

> Generated from code review session. These improvements can be implemented incrementally.

## Priority: HIGH - Error Handling

**Issue:** 48+ scripts lack `set -euo pipefail`

**Fix:** Add to top of each bash script:
```bash
set -euo pipefail
```

Scripts needing this:
- agy-sync, agy-health, agy-local, agy-project
- run-all-tests.sh, weekly-health-check.sh
- test-*.sh (all test scripts)
- browser-validate.sh, monitor-tw.sh, sync-token.sh
- tw-node-watchdog.sh, validate-token-config.sh
- setup-automated-testing.sh, test-shell-integration.sh

## Priority: HIGH - Shellcheck CI

**Issue:** No automated shell script linting

**Fix:** Create `.github/workflows/shellcheck.yml`:
```yaml
name: Shellcheck
on:
  push:
    paths: ['scripts/**', 'config/*.sh']
  pull_request:
    paths: ['scripts/**', 'config/*.sh']
jobs:
  shellcheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: sudo apt-get install -y shellcheck
      - run: find scripts -type f -name "*.sh" | xargs shellcheck --severity=warning
```

## Priority: MEDIUM - Color Duplication

**Issue:** 12 scripts duplicate color definitions instead of sourcing common.sh

**Fix:** Replace color definitions with:
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/lib/common.sh" ]]; then
    source "$SCRIPT_DIR/lib/common.sh"
fi
```

## Priority: MEDIUM - Enhance common.sh

Add `init_strict_mode()`, `require_cmd()`, `retry()` helpers.

## Priority: LOW

- Pre-commit shellcheck hook
- TypeScript migration for complex scripts
- Script dependency graph

---
*Last updated: 2026-01-31*
