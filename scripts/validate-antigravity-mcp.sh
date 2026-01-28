#!/usr/bin/env bash
set -e

# ============================================================
# Antigravity MCP Setup Validation
# ============================================================
# Validates that all Antigravity MCP components are properly
# configured and ready to use.
# ============================================================

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Antigravity MCP Setup Validation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ERRORS=0
WARNINGS=0

# ============================================================
# Test 1: Global direnvrc
# ============================================================
echo "Test 1: Global direnvrc configuration"
if [ -f "$HOME/.config/direnv/direnvrc" ]; then
  if [ -x "$HOME/.config/direnv/direnvrc" ]; then
    echo "  ✅ direnvrc exists and is executable"
  else
    echo "  ⚠️  direnvrc exists but is not executable"
    WARNINGS=$((WARNINGS + 1))
  fi
else
  echo "  ❌ direnvrc not found at ~/.config/direnv/direnvrc"
  ERRORS=$((ERRORS + 1))
fi
echo ""

# ============================================================
# Test 2: Project .envrc
# ============================================================
echo "Test 2: Project .envrc file"
if [ -f ".envrc" ]; then
  echo "  ✅ .envrc exists"
  if grep -q "PROJECT_ROOT" .envrc; then
    echo "  ✅ PROJECT_ROOT defined"
  else
    echo "  ❌ PROJECT_ROOT not defined in .envrc"
    ERRORS=$((ERRORS + 1))
  fi
else
  echo "  ❌ .envrc not found"
  ERRORS=$((ERRORS + 1))
fi
echo ""

# ============================================================
# Test 3: MCP Wrapper Scripts
# ============================================================
echo "Test 3: MCP wrapper scripts"
for script in mcp-gitkraken mcp-docker mcp-filesystem; do
  if [ -f "scripts/$script" ]; then
    if [ -x "scripts/$script" ]; then
      echo "  ✅ scripts/$script exists and is executable"
    else
      echo "  ❌ scripts/$script is not executable"
      ERRORS=$((ERRORS + 1))
    fi
  else
    echo "  ❌ scripts/$script not found"
    ERRORS=$((ERRORS + 1))
  fi
done
echo ""

# ============================================================
# Test 4: Antigravity Config
# ============================================================
echo "Test 4: Antigravity MCP configuration"
if [ -f ".antigravity/mcp_config.json" ]; then
  echo "  ✅ .antigravity/mcp_config.json exists"
  
  # Validate JSON
  if command -v jq >/dev/null 2>&1; then
    if jq empty .antigravity/mcp_config.json 2>/dev/null; then
      echo "  ✅ Valid JSON format"
      
      # Check server count
      SERVER_COUNT=$(jq '.mcpServers | length' .antigravity/mcp_config.json)
      echo "  ✅ MCP server count: $SERVER_COUNT"
      
      if [ "$SERVER_COUNT" -gt 25 ]; then
        echo "  ⚠️  Warning: $SERVER_COUNT servers exceeds recommended limit of 25"
        WARNINGS=$((WARNINGS + 1))
      fi
      
      # Check for absolute paths
      if jq -r '.mcpServers[].args[]' .antigravity/mcp_config.json | grep -q "^/"; then
        echo "  ✅ Using absolute paths"
      else
        echo "  ⚠️  Warning: Not all paths are absolute"
        WARNINGS=$((WARNINGS + 1))
      fi
    else
      echo "  ❌ Invalid JSON format"
      ERRORS=$((ERRORS + 1))
    fi
  else
    echo "  ⚠️  jq not installed, skipping JSON validation"
    WARNINGS=$((WARNINGS + 1))
  fi
else
  echo "  ❌ .antigravity/mcp_config.json not found"
  ERRORS=$((ERRORS + 1))
fi
echo ""

# ============================================================
# Test 5: Activation Script
# ============================================================
echo "Test 5: Activation script"
if [ -f "scripts/antigravity-activate" ]; then
  if [ -x "scripts/antigravity-activate" ]; then
    echo "  ✅ scripts/antigravity-activate exists and is executable"
  else
    echo "  ❌ scripts/antigravity-activate is not executable"
    ERRORS=$((ERRORS + 1))
  fi
else
  echo "  ❌ scripts/antigravity-activate not found"
  ERRORS=$((ERRORS + 1))
fi
echo ""

# ============================================================
# Test 6: Active Config
# ============================================================
echo "Test 6: Active Antigravity configuration"
if [ -L "$HOME/.gemini/mcp_config.json" ]; then
  TARGET=$(readlink "$HOME/.gemini/mcp_config.json")
  echo "  ✅ ~/.gemini/mcp_config.json is a symlink"
  echo "  ✅ Points to: $TARGET"
  
  if [ "$TARGET" = "$PROJECT_ROOT/.antigravity/mcp_config.json" ]; then
    echo "  ✅ Correctly linked to this project"
  else
    echo "  ⚠️  Linked to different project: $TARGET"
    WARNINGS=$((WARNINGS + 1))
  fi
elif [ -f "$HOME/.gemini/mcp_config.json" ]; then
  echo "  ⚠️  ~/.gemini/mcp_config.json exists but is not a symlink"
  echo "  ℹ️  Run: ./scripts/antigravity-activate"
  WARNINGS=$((WARNINGS + 1))
else
  echo "  ⚠️  ~/.gemini/mcp_config.json not found"
  echo "  ℹ️  Run: ./scripts/antigravity-activate"
  WARNINGS=$((WARNINGS + 1))
fi
echo ""

# ============================================================
# Test 7: Documentation
# ============================================================
echo "Test 7: Documentation files"
for doc in docs/ANTIGRAVITY-MCP-SETUP.md docs/ANTIGRAVITY-MCP-QUICKREF.md ANTIGRAVITY-SETUP-COMPLETE.md; do
  if [ -f "$doc" ]; then
    echo "  ✅ $doc exists"
  else
    echo "  ⚠️  $doc not found"
    WARNINGS=$((WARNINGS + 1))
  fi
done
echo ""

# ============================================================
# Test 8: .gitignore
# ============================================================
echo "Test 8: .gitignore configuration"
if grep -q ".envrc.local" .gitignore 2>/dev/null; then
  echo "  ✅ .envrc.local in .gitignore"
else
  echo "  ⚠️  .envrc.local not in .gitignore"
  WARNINGS=$((WARNINGS + 1))
fi

if grep -q ".direnv/" .gitignore 2>/dev/null; then
  echo "  ✅ .direnv/ in .gitignore"
else
  echo "  ⚠️  .direnv/ not in .gitignore"
  WARNINGS=$((WARNINGS + 1))
fi

if grep -q ".antigravity/\*\.backup" .gitignore 2>/dev/null; then
  echo "  ✅ .antigravity/*.backup* in .gitignore"
else
  echo "  ⚠️  .antigravity/*.backup* not in .gitignore"
  WARNINGS=$((WARNINGS + 1))
fi
echo ""

# ============================================================
# Test 9: Environment Tools
# ============================================================
echo "Test 9: Required tools"
for tool in direnv op jq; do
  if command -v "$tool" >/dev/null 2>&1; then
    VERSION=$("$tool" --version 2>&1 | head -n1 || echo "unknown")
    echo "  ✅ $tool installed ($VERSION)"
  else
    if [ "$tool" = "jq" ]; then
      echo "  ⚠️  $tool not installed (optional)"
      WARNINGS=$((WARNINGS + 1))
    else
      echo "  ❌ $tool not installed (required)"
      ERRORS=$((ERRORS + 1))
    fi
  fi
done
echo ""

# ============================================================
# Test 10: direnv Hook
# ============================================================
echo "Test 10: direnv shell integration"
if grep -q "direnv hook" ~/.zshrc 2>/dev/null; then
  echo "  ✅ direnv hook configured in ~/.zshrc"
else
  echo "  ⚠️  direnv hook not found in ~/.zshrc"
  echo "  ℹ️  Add: eval \"\$(direnv hook zsh)\""
  WARNINGS=$((WARNINGS + 1))
fi
echo ""

# ============================================================
# Summary
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Validation Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
  echo "✅ All tests passed!"
  echo ""
  echo "Next steps:"
  echo "1. Restart Antigravity IDE"
  echo "2. Verify MCP servers are loaded"
  echo "3. Test MCP functionality"
  echo ""
  exit 0
elif [ $ERRORS -eq 0 ]; then
  echo "⚠️  Setup complete with $WARNINGS warning(s)"
  echo ""
  echo "Next steps:"
  echo "1. Review warnings above"
  echo "2. Restart Antigravity IDE"
  echo "3. Verify MCP servers are loaded"
  echo ""
  exit 0
else
  echo "❌ Setup incomplete: $ERRORS error(s), $WARNINGS warning(s)"
  echo ""
  echo "Please fix the errors above and run validation again."
  echo ""
  exit 1
fi
