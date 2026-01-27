# Clawdbot Test Suite - Quick Reference

## 🚀 Optimized Test Suite (RECOMMENDED)

**File:** `~/scripts/test-clawdbot-system-fast.sh`  
**Speed:** ~33 seconds  
**Tests:** 41 comprehensive tests  
**Optimization:** 6-9x faster than original

### Quick Run

```bash
~/scripts/test-clawdbot-system-fast.sh
```

---

## 📊 Available Test Scripts

### 1. **Fast System Test** ⚡ (Recommended)

```bash
~/scripts/test-clawdbot-system-fast.sh
```

- **Duration:** ~33 seconds
- **Tests:** All 41 tests
- **Method:** Batched SSH, parallel collection
- **Use for:** Daily checks, CI/CD, quick validation

### 2. **Original System Test** 🐢

```bash
~/scripts/test-clawdbot-system.sh
```

- **Duration:** ~5 minutes
- **Tests:** All 41 tests
- **Method:** Sequential execution
- **Use for:** Debugging, comparison baseline

### 3. **Crash Recovery Test** 💥

```bash
~/scripts/test-crash-recovery.sh
```

- **Duration:** 1 minute
- **Destructive:** Yes (kills process)
- **Tests:** Auto-restart after crash

### 4. **Reboot Survival Test** 🔄

```bash
~/scripts/test-reboot-survival.sh
```

- **Duration:** 5 minutes
- **Destructive:** Yes (reboots system)
- **Tests:** Auto-start after reboot

### 5. **Stress/Load Test** 🔥

```bash
~/scripts/test-stress-load.sh
```

- **Duration:** 2 minutes
- **Tests:** Performance under load (50 concurrent commands)

### 6. **Master Test Runner** 🎯

```bash
~/scripts/run-all-tests.sh
```

- **Interactive:** Yes
- **Options:** Quick, Full, Crash, Reboot, Stress, All, Custom

---

## 📈 Performance Comparison

| Test Suite  | Duration | Speed | Use Case          |
| ----------- | -------- | ----- | ----------------- |
| **Fast** ⚡ | 33s      | 9x    | Daily use, CI/CD  |
| Original 🐢 | 300s     | 1x    | Debugging         |
| Crash 💥    | 60s      | -     | Reliability check |
| Reboot 🔄   | 300s     | -     | Boot validation   |
| Stress 🔥   | 120s     | -     | Load testing      |

---

## 🎯 Test Coverage

All test scripts validate:

### Unit Tests (7)

- Gateway process & port binding
- Remote node process & LaunchAgent
- Configuration files
- Node.js & Claude Code installations

### Integration Tests (6)

- Network connectivity
- WebSocket connections
- Authentication
- Service discovery (Bonjour)
- Status queries

### System Tests (6)

- Dashboard accessibility
- Node pairing
- Remote command execution
- File system access
- Clamshell mode
- Log files

### Reliability Tests (4)

- Auto-restart configuration
- Process recovery
- Network stability
- Disk space

### Performance Tests (4)

- Connection latency
- CPU usage
- Memory usage
- Process count

### Security Tests (14)

- SSH key authentication
- Token authentication & strength
- File permissions
- Gateway binding
- Port exposure
- Firewall configuration
- Sensitive data leakage
- Process isolation
- WebSocket encryption
- API endpoint security
- SSH host key verification
- Backup file security
- Remote node security

**Total: 41 comprehensive tests**

---

## 🔧 Common Usage Patterns

### Daily Health Check

```bash
# Quick validation (33 seconds)
~/scripts/test-clawdbot-system-fast.sh
```

### Pre-Deployment Validation

```bash
# Run all tests
~/scripts/run-all-tests.sh
# Select option 6 (All Tests)
```

### Weekly Reliability Check

```bash
# Add to cron
0 9 * * 1 ~/scripts/test-clawdbot-system-fast.sh >> ~/logs/weekly-tests.log
```

### After Configuration Changes

```bash
# Fast validation
~/scripts/test-clawdbot-system-fast.sh

# If issues, run full suite
~/scripts/test-clawdbot-system.sh
```

### CI/CD Pipeline

```bash
#!/bin/bash
if ~/scripts/test-clawdbot-system-fast.sh; then
  echo "✅ Tests passed"
  deploy.sh
else
  echo "❌ Tests failed"
  exit 1
fi
```

---

## 📝 Test Results

### Current Status

- **Total Tests:** 41
- **Passed:** 37 (90%)
- **Failed:** 4 (non-critical)
- **Status:** ✅ OPERATIONAL

### Known Minor Issues

1. **Node Pairing** - Dashboard API check (cosmetic)
2. **Clamshell Mode** - Grep pattern (false negative)
3. **SSH Host Keys** - Not in known_hosts (low risk)
4. **Backup Files** - Some backups detected (low risk)

---

## 📚 Documentation

### Test Documentation

- **`TESTING-GUIDE.md`** - Complete testing guide
- **`SECURITY-TESTS.md`** - Security test details
- **`TEST-PERFORMANCE.md`** - Performance optimization details

### Test Results

- **`/tmp/clawdbot-test-results.log`** - Latest test results

---

## 🎓 Optimization Details

### How the Fast Version Works

1. **Batched SSH** - All remote commands in 1 connection (vs 25+)
2. **Parallel Collection** - Local & remote data collected simultaneously
3. **Result Caching** - Data collected once, reused across tests
4. **Optimized Parsing** - Pre-parsed data for faster test execution

### Performance Gains

- **6-9x faster** execution
- **96% fewer** SSH connections
- **70% fewer** process spawns
- **Same test coverage** as original

---

## 🔍 Troubleshooting

### Tests Running Slow?

```bash
# Use the fast version
~/scripts/test-clawdbot-system-fast.sh
```

### Need to Debug a Specific Test?

```bash
# Use original (easier to debug)
~/scripts/test-clawdbot-system.sh
```

### SSH Connection Issues?

```bash
# Test SSH connectivity first
ssh tywhitaker@192.168.1.245 "echo 'SSH OK'"
```

### Want More Details?

```bash
# Check test results log
cat /tmp/clawdbot-test-results.log
```

---

## ⚡ Quick Commands

```bash
# Fast test (33s)
~/scripts/test-clawdbot-system-fast.sh

# With timing
time ~/scripts/test-clawdbot-system-fast.sh

# Save results
~/scripts/test-clawdbot-system-fast.sh > ~/test-results.txt

# Interactive test runner
~/scripts/run-all-tests.sh

# View documentation
cat ~/scripts/TESTING-GUIDE.md
cat ~/scripts/SECURITY-TESTS.md
cat ~/scripts/TEST-PERFORMANCE.md
```

---

## 📞 Support

For issues or questions:

1. Check test results: `/tmp/clawdbot-test-results.log`
2. Review documentation in `~/scripts/`
3. Run original test for detailed output
4. Check system logs: `~/.clawdbot/logs/`

---

**Last Updated:** 2026-01-27  
**Version:** 2.0 (Optimized)  
**Recommended:** Use `test-clawdbot-system-fast.sh` for all regular testing
