# Browser-Based Clawdbot Validation Tests

These tests are designed to be run by Claude in the browser chat interface to validate Clawdbot setup and connectivity.

---

## 🎯 Quick Validation Tests

Copy and paste these test commands to Claude in the browser chat. Claude will execute them and report results.

---

## Test 1: Gateway Status Check ✅

**Purpose:** Verify the Clawdbot gateway is running and accessible

**Command to give Claude:**

```
Check if the Clawdbot gateway is running by executing:
curl -s http://localhost:18789 | head -20

Expected: Should see HTML with "Clawdbot Control" in the output
```

**Expected Result:**

- HTML content containing "Clawdbot Control"
- Status 200 response
- Dashboard accessible

---

## Test 2: Node Connectivity Check 🔗

**Purpose:** Verify remote nodes are connected

**Command to give Claude:**

```
Check connected Clawdbot nodes by running:
curl -s http://localhost:18789/api/nodes | jq '.'

Expected: Should see JSON with node information including "TW" node
```

**Expected Result:**

- JSON response with node list
- At least one node (TW) visible
- Node status showing as connected

---

## Test 3: Gateway Process Verification 🔍

**Purpose:** Confirm gateway process is running

**Command to give Claude:**

```
Verify the Clawdbot gateway process is running:
ps aux | grep clawdbot-gateway | grep -v grep

Expected: Should see the clawdbot-gateway process
```

**Expected Result:**

- Process running as current user (not root)
- Process ID visible
- Command line showing node/clawdbot

---

## Test 4: Port Binding Check 🔌

**Purpose:** Verify gateway is listening on correct port

**Command to give Claude:**

```
Check if port 18789 is open and listening:
lsof -i :18789 | grep LISTEN

Expected: Should see gateway listening on *:18789 or 0.0.0.0:18789
```

**Expected Result:**

- Port 18789 in LISTEN state
- Bound to all interfaces (\*:18789)
- Process name includes "node" or "clawdbot"

---

## Test 5: Configuration File Check 📄

**Purpose:** Verify configuration files exist and are valid

**Command to give Claude:**

```
Check Clawdbot configuration:
cat ~/.clawdbot/clawdbot.json | jq '.'

Expected: Should see valid JSON with gateway configuration
```

**Expected Result:**

- Valid JSON format
- Contains "role": "gateway"
- Contains "token" field
- Contains "port": 18789

---

## Test 6: Remote Node SSH Test 🔐

**Purpose:** Test SSH connectivity to remote node

**Command to give Claude:**

```
Test SSH connection to remote node:
ssh -o ConnectTimeout=5 tywhitaker@192.168.1.245 "echo 'SSH connection successful'"

Expected: Should print "SSH connection successful"
```

**Expected Result:**

- No password prompt (key-based auth)
- Message "SSH connection successful"
- No errors

---

## Test 7: Remote Node Process Check 🖥️

**Purpose:** Verify remote node is running

**Command to give Claude:**

```
Check if remote node process is running:
ssh tywhitaker@192.168.1.245 "ps aux | grep clawdbot | grep -v grep"

Expected: Should see clawdbot process on remote Mac
```

**Expected Result:**

- Process running on remote system
- Process running as tywhitaker user
- Node process visible

---

## Test 8: WebSocket Connection Test 🔄

**Purpose:** Verify WebSocket connections are established

**Command to give Claude:**

```
Check for active WebSocket connections:
lsof -i :18789 | grep ESTABLISHED

Expected: Should see ESTABLISHED connections to port 18789
```

**Expected Result:**

- At least one ESTABLISHED connection
- Connection between gateway and remote node
- Both local and remote endpoints visible

---

## Test 9: Network Connectivity Test 🌐

**Purpose:** Test network path to remote node

**Command to give Claude:**

```
Test network connectivity to remote node:
nc -zv 192.168.1.245 22 2>&1

Expected: Should see "succeeded" in output
```

**Expected Result:**

- Connection succeeded
- Port 22 (SSH) is reachable
- No timeout errors

---

## Test 10: Dashboard API Test 🎛️

**Purpose:** Verify dashboard API is responding

**Command to give Claude:**

```
Test dashboard API endpoints:
curl -s http://localhost:18789/api/status

Expected: Should see JSON status response
```

**Expected Result:**

- JSON response
- Status information
- No errors

---

## Test 11: Service Discovery Test 📡

**Purpose:** Verify Bonjour/mDNS service discovery

**Command to give Claude:**

```
Test service discovery from remote node:
ssh tywhitaker@192.168.1.245 "clawdbot gateway discover 2>&1 | head -5"

Expected: Should discover gateway on local network
```

**Expected Result:**

- Gateway discovered via mDNS
- Shows gateway hostname/IP
- No errors

---

## Test 12: Log File Check 📝

**Purpose:** Verify logging is working

**Command to give Claude:**

```
Check recent gateway logs:
ls -lh ~/.clawdbot/logs/*.log | tail -3

Expected: Should see recent log files
```

**Expected Result:**

- Log files exist
- Recent timestamps
- Non-zero file sizes

---

## 🚀 Quick Test Suite (All-in-One)

**Command to give Claude:**

```
Run this comprehensive test to validate the entire Clawdbot setup:

echo "=== Clawdbot Browser Validation Tests ==="
echo ""

echo "1. Gateway Status:"
curl -s http://localhost:18789 | grep -q "Clawdbot" && echo "✅ PASS" || echo "❌ FAIL"

echo "2. Gateway Process:"
ps aux | grep -q "[c]lawdbot-gateway" && echo "✅ PASS" || echo "❌ FAIL"

echo "3. Port Binding:"
lsof -i :18789 | grep -q LISTEN && echo "✅ PASS" || echo "❌ FAIL"

echo "4. Configuration:"
test -f ~/.clawdbot/clawdbot.json && echo "✅ PASS" || echo "❌ FAIL"

echo "5. SSH Connectivity:"
ssh -o ConnectTimeout=5 tywhitaker@192.168.1.245 "echo '✅ PASS'" 2>/dev/null || echo "❌ FAIL"

echo "6. Remote Node Process:"
ssh tywhitaker@192.168.1.245 "ps aux | grep -q '[c]lawdbot' && echo '✅ PASS' || echo '❌ FAIL'" 2>/dev/null

echo "7. WebSocket Connection:"
lsof -i :18789 | grep -q ESTABLISHED && echo "✅ PASS" || echo "❌ FAIL"

echo "8. Log Files:"
ls ~/.clawdbot/logs/*.log >/dev/null 2>&1 && echo "✅ PASS" || echo "❌ FAIL"

echo ""
echo "=== Test Complete ==="
```

**Expected Output:**

```
=== Clawdbot Browser Validation Tests ===

1. Gateway Status: ✅ PASS
2. Gateway Process: ✅ PASS
3. Port Binding: ✅ PASS
4. Configuration: ✅ PASS
5. SSH Connectivity: ✅ PASS
6. Remote Node Process: ✅ PASS
7. WebSocket Connection: ✅ PASS
8. Log Files: ✅ PASS

=== Test Complete ===
```

---

## 🎨 Visual Dashboard Test

**Command to give Claude:**

```
Open the Clawdbot dashboard in your browser and verify:

1. Navigate to: http://localhost:18789
2. Check that you see:
   - "Clawdbot Control" header
   - List of connected nodes
   - "TW" node visible
   - Node status showing as "connected"
   - Green status indicators

Take a screenshot and confirm all elements are visible.
```

---

## 🔧 Troubleshooting Tests

### If Gateway Not Running:

```
Start the gateway:
clawdbot gateway start

Wait 5 seconds, then verify:
ps aux | grep clawdbot-gateway
```

### If Remote Node Not Connected:

```
Check remote node status:
ssh tywhitaker@192.168.1.245 "clawdbot node status"

Restart if needed:
ssh tywhitaker@192.168.1.245 "clawdbot node restart"
```

### If Port Not Listening:

```
Check what's using port 18789:
lsof -i :18789

Kill and restart if needed:
pkill -f clawdbot-gateway
clawdbot gateway start
```

---

## 📊 Success Criteria

All tests should show:

- ✅ Gateway running and accessible
- ✅ Remote node connected
- ✅ WebSocket connections established
- ✅ Configuration files valid
- ✅ Logs being written
- ✅ Dashboard accessible
- ✅ API endpoints responding

---

## 🎯 Quick Copy-Paste Test

**Single command to validate everything:**

```bash
echo "🔍 Clawdbot Quick Validation" && \
echo "Gateway: $(curl -s http://localhost:18789 | grep -q Clawdbot && echo '✅' || echo '❌')" && \
echo "Process: $(ps aux | grep -q [c]lawdbot-gateway && echo '✅' || echo '❌')" && \
echo "Port: $(lsof -i :18789 | grep -q LISTEN && echo '✅' || echo '❌')" && \
echo "SSH: $(ssh -o ConnectTimeout=3 tywhitaker@192.168.1.245 'echo ✅' 2>/dev/null || echo '❌')" && \
echo "Remote: $(ssh tywhitaker@192.168.1.245 'ps aux | grep -q [c]lawdbot && echo ✅ || echo ❌' 2>/dev/null)" && \
echo "WebSocket: $(lsof -i :18789 | grep -q ESTABLISHED && echo '✅' || echo '❌')" && \
echo "✨ Validation Complete"
```

---

## 💡 Usage Tips

1. **Copy the command** from any test above
2. **Paste into Claude chat** in browser
3. **Wait for Claude to execute** and report results
4. **Review the output** - all should show ✅ PASS
5. **If any fail**, use the troubleshooting tests

---

## 📝 Test Results Template

When Claude runs tests, ask for results in this format:

```
Clawdbot Validation Results:

✅ Gateway Status: PASS - Dashboard accessible
✅ Gateway Process: PASS - Running as user
✅ Port Binding: PASS - Listening on *:18789
✅ Configuration: PASS - Valid JSON config
✅ SSH Connectivity: PASS - Passwordless auth working
✅ Remote Node: PASS - Process running on TW
✅ WebSocket: PASS - Connection established
✅ Logs: PASS - Recent logs present

Overall Status: ✅ ALL TESTS PASSED
System Ready: YES
```

---

**Created:** 2026-01-27  
**Purpose:** Browser-based validation for Clawdbot setup  
**Usage:** Copy commands to Claude in browser chat
