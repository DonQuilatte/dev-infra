# 🌐 Browser-Based Clawdbot Testing

Quick validation tests you can run through Claude in your browser chat.

---

## 🚀 Quick Start

### Option 1: Single Command Test (Recommended)

Copy and paste this into Claude browser chat:

```bash
~/Development/Projects/clawdbot/scripts/browser-validate.sh
```

**What it does:**

- Runs 10 comprehensive validation tests
- Shows visual results with ✅/❌ indicators
- Takes ~10 seconds to complete
- Reports overall system status

**Expected Output:**

```
╔════════════════════════════════════════╗
║   Clawdbot Validation Test Suite      ║
╚════════════════════════════════════════╝

1️⃣  Gateway Dashboard......... ✅ PASS
2️⃣  Gateway Process........... ✅ PASS
3️⃣  Port 18789 Listening...... ✅ PASS
4️⃣  Configuration File........ ✅ PASS
5️⃣  SSH to Remote Node........ ✅ PASS
6️⃣  Remote Node Process....... ✅ PASS
7️⃣  WebSocket Connection...... ✅ PASS
8️⃣  Log Files................. ✅ PASS
9️⃣  API Endpoint.............. ✅ PASS
🔟 Service Discovery......... ✅ PASS

╔════════════════════════════════════════╗
║            Test Results                ║
╠════════════════════════════════════════╣
║  ✅ Passed: 10                         ║
║  ❌ Failed: 0                          ║
╠════════════════════════════════════════╣
║  Status: 🎉 ALL TESTS PASSED          ║
║  System: ✅ READY FOR USE              ║
╚════════════════════════════════════════╝
```

---

## 📋 Individual Tests

### Test 1: Check Gateway Dashboard

```bash
curl -s http://localhost:18789 | grep "Clawdbot" && echo "✅ Dashboard OK" || echo "❌ Dashboard not accessible"
```

### Test 2: Verify Gateway Process

```bash
ps aux | grep "[c]lawdbot-gateway" && echo "✅ Process running" || echo "❌ Process not found"
```

### Test 3: Check Port Binding

```bash
lsof -i :18789 | grep LISTEN && echo "✅ Port listening" || echo "❌ Port not listening"
```

### Test 4: Test SSH Connection

```bash
ssh -o ConnectTimeout=5 tywhitaker@192.168.1.245 "echo '✅ SSH connected'" || echo "❌ SSH failed"
```

### Test 5: Check Remote Node

```bash
ssh tywhitaker@192.168.1.245 "ps aux | grep '[c]lawdbot' && echo '✅ Remote node running' || echo '❌ Remote node not running'"
```

### Test 6: Verify WebSocket

```bash
lsof -i :18789 | grep ESTABLISHED && echo "✅ WebSocket connected" || echo "❌ No WebSocket connection"
```

---

## 🎯 One-Liner Super Quick Test

```bash
echo "Gateway: $(curl -s http://localhost:18789 | grep -q Clawdbot && echo ✅ || echo ❌) | Process: $(ps aux | grep -q [c]lawdbot-gateway && echo ✅ || echo ❌) | SSH: $(ssh -o ConnectTimeout=3 tywhitaker@192.168.1.245 'echo ✅' 2>/dev/null || echo ❌) | Remote: $(ssh tywhitaker@192.168.1.245 'ps aux | grep -q [c]lawdbot && echo ✅ || echo ❌' 2>/dev/null) | WebSocket: $(lsof -i :18789 | grep -q ESTABLISHED && echo ✅ || echo ❌)"
```

**Expected:** All show ✅

---

## 🔍 What Each Test Validates

| Test                 | What It Checks         | Why It Matters            |
| -------------------- | ---------------------- | ------------------------- |
| 1️⃣ Gateway Dashboard | HTTP server responding | Users can access UI       |
| 2️⃣ Gateway Process   | Process is running     | Core service active       |
| 3️⃣ Port Binding      | Port 18789 listening   | Network accessible        |
| 4️⃣ Configuration     | Config file exists     | System configured         |
| 5️⃣ SSH Connection    | Can reach remote Mac   | Network path clear        |
| 6️⃣ Remote Process    | Node running on remote | Distributed setup OK      |
| 7️⃣ WebSocket         | Active connection      | Real-time comm working    |
| 8️⃣ Log Files         | Logs being written     | Monitoring active         |
| 9️⃣ API Endpoint      | REST API responding    | Programmatic access OK    |
| 🔟 Discovery         | mDNS working           | Auto-discovery functional |

---

## 🎨 Visual Dashboard Check

Ask Claude to:

```
Open http://localhost:18789 in a browser and describe what you see
```

**Should see:**

- "Clawdbot Control" header
- Connected nodes list
- "TW" node visible
- Green status indicators
- Recent activity logs

---

## 🔧 Troubleshooting Commands

### If Gateway Not Running:

```bash
clawdbot gateway start && sleep 3 && ps aux | grep clawdbot-gateway
```

### If Remote Node Disconnected:

```bash
ssh tywhitaker@192.168.1.245 "clawdbot node restart"
```

### Check Logs:

```bash
tail -20 ~/.clawdbot/logs/gateway.log
```

### Full System Status:

```bash
~/Development/Projects/clawdbot/scripts/test-clawdbot-system-fast.sh
```

---

## 📊 Success Criteria

All tests should show ✅ for:

- ✅ Gateway accessible at http://localhost:18789
- ✅ Gateway process running
- ✅ Port 18789 listening
- ✅ SSH to remote Mac working
- ✅ Remote node process active
- ✅ WebSocket connection established
- ✅ Logs being written
- ✅ API responding
- ✅ Service discovery working

---

## 💡 Tips for Browser Claude

1. **Copy the entire command** including the path
2. **Paste directly** into Claude chat
3. **Wait for execution** (usually 5-10 seconds)
4. **Review the output** - look for ✅ symbols
5. **If any ❌ appear**, run individual tests to diagnose

---

## 🎯 Quick Commands for Claude

### "Run a quick validation"

```bash
~/Development/Projects/clawdbot/scripts/browser-validate.sh
```

### "Check if everything is working"

```bash
curl -s http://localhost:18789 | grep -q Clawdbot && ps aux | grep -q [c]lawdbot-gateway && ssh tywhitaker@192.168.1.245 'ps aux | grep -q [c]lawdbot' && echo "✅ All systems operational" || echo "❌ Some systems down"
```

### "Show me the dashboard"

```bash
curl -s http://localhost:18789 | grep -o '<title>.*</title>'
```

### "List connected nodes"

```bash
curl -s http://localhost:18789/api/nodes | jq '.[] | {name: .name, status: .status}'
```

---

## 📝 Test Results Template

When Claude reports results, expect this format:

```
Clawdbot Browser Validation Results:

✅ Gateway Dashboard: PASS
✅ Gateway Process: PASS
✅ Port Binding: PASS
✅ Configuration: PASS
✅ SSH Connection: PASS
✅ Remote Node: PASS
✅ WebSocket: PASS
✅ Log Files: PASS
✅ API Endpoint: PASS
✅ Service Discovery: PASS

Overall: 10/10 tests passed
Status: ✅ SYSTEM READY
```

---

## 🚨 Common Issues

### Issue: Gateway not accessible

**Solution:**

```bash
clawdbot gateway start
```

### Issue: Remote node not connected

**Solution:**

```bash
ssh tywhitaker@192.168.1.245 "clawdbot node restart"
```

### Issue: Port already in use

**Solution:**

```bash
lsof -ti :18789 | xargs kill -9
clawdbot gateway start
```

---

## 📚 Related Documentation

- **Full Test Suite:** `~/Development/Projects/clawdbot/scripts/test-clawdbot-system-fast.sh`
- **Testing Guide:** `~/Development/Projects/clawdbot/docs/TESTING-GUIDE.md`
- **Detailed Tests:** `~/Development/Projects/clawdbot/docs/BROWSER-VALIDATION-TESTS.md`

---

**Created:** 2026-01-27  
**Purpose:** Quick browser-based validation for Claude  
**Usage:** Copy commands to Claude in browser chat
