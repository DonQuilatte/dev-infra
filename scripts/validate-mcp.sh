#!/usr/bin/env bash

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  ClawdBot MCP Stack Validation                             ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

PROJECT_ROOT="${PWD}"
PASS_COUNT=0
FAIL_COUNT=0

echo "🔍 Test 1: MCP wrapper scripts"
if [ -x "scripts/mcp-gitkraken" ] && [ -x "scripts/mcp-filesystem" ] && [ -x "scripts/mcp-context7" ]; then
  echo "✅ All 3 wrapper scripts exist and are executable"
  ((PASS_COUNT++))
else
  echo "❌ Wrapper scripts missing or not executable"
  ((FAIL_COUNT++))
fi

echo ""
echo "🔍 Test 2: Wrappers have Homebrew PATH"
MISSING_PATH=0
for script in scripts/mcp-gitkraken scripts/mcp-filesystem; do
  if ! grep -q 'export PATH="/opt/homebrew/bin' "$script" 2>/dev/null; then
    echo "❌ $script missing PATH export"
    MISSING_PATH=1
  fi
done

if [ $MISSING_PATH -eq 0 ]; then
  echo "✅ Wrappers export Homebrew PATH"
  ((PASS_COUNT++))
else
  ((FAIL_COUNT++))
fi

echo ""
echo "🔍 Test 3: Antigravity MCP config"
if [ -f ".antigravity/config.json" ]; then
  echo "✅ .antigravity/config.json exists"
  ((PASS_COUNT++))
  
  if grep -q '"github"' .antigravity/config.json && \
     grep -q '"filesystem"' .antigravity/config.json && \
     grep -q '"context7"' .antigravity/config.json; then
    echo "✅ Config has all 3 MCP servers (github, filesystem, context7)"
    ((PASS_COUNT++))
  else
    echo "❌ Config missing one or more servers"
    ((FAIL_COUNT++))
  fi
else
  echo "❌ .antigravity/config.json missing"
  ((FAIL_COUNT++))
  ((FAIL_COUNT++))
fi

echo ""
echo "🔍 Test 4: Environment configuration"
if [ -f ".envrc" ]; then
  echo "✅ .envrc exists"
  ((PASS_COUNT++))
  
  if grep -q "PROJECT_NAME=" .envrc; then
    echo "✅ .envrc has PROJECT_NAME"
    ((PASS_COUNT++))
  else
    echo "❌ .envrc missing PROJECT_NAME"
    ((FAIL_COUNT++))
  fi
else
  echo "❌ .envrc missing"
  ((FAIL_COUNT++))
  ((FAIL_COUNT++))
fi

echo ""
echo "🔍 Test 5: Compare with iphone-tco-planner (reference)"
REF_PROJECT="/Users/jederlichman/Development/Projects/iphone-tco-planner"
if [ -f "$REF_PROJECT/scripts/mcp-gitkraken" ]; then
  if diff -q <(grep "export PATH" scripts/mcp-gitkraken) \
              <(grep "export PATH" "$REF_PROJECT/scripts/mcp-gitkraken") &>/dev/null; then
    echo "✅ PATH export matches reference implementation"
    ((PASS_COUNT++))
  else
    echo "⚠️  PATH export differs from reference (may be OK)"
  fi
else
  echo "⚠️  Reference project not found (skipping comparison)"
fi

echo ""
echo "🔍 Test 6: Server package names"
if grep -q "@modelcontextprotocol/server-github" scripts/mcp-gitkraken 2>/dev/null; then
  echo "✅ Using correct github server package"
  ((PASS_COUNT++))
else
  echo "❌ Incorrect github server package"
  ((FAIL_COUNT++))
fi

if grep -q "@modelcontextprotocol/server-filesystem" scripts/mcp-filesystem 2>/dev/null; then
  echo "✅ Using correct filesystem server package"
  ((PASS_COUNT++))
else
  echo "❌ Incorrect filesystem server package"
  ((FAIL_COUNT++))
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "RESULTS: $PASS_COUNT passed, $FAIL_COUNT failed"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
  echo "✅ ALL AUTOMATED TESTS PASSED"
  echo ""
  echo "Next steps:"
  echo "  1. Check Antigravity MCP panel"
  echo "  2. Should see: github, filesystem, context7 (all connected)"
  echo "  3. Test MCP tools functionality"
  echo ""
  echo "📄 See VALIDATION_INSTRUCTIONS.md for manual validation steps"
  exit 0
else
  echo "❌ SOME TESTS FAILED"
  echo ""
  echo "Fix issues above, then re-run validation"
  echo "📄 See VALIDATION_INSTRUCTIONS.md for troubleshooting"
  exit 1
fi
