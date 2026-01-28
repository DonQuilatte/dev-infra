#!/bin/bash
# Unit tests for script files

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${PROJECT_ROOT:-$(dirname "$(dirname "$SCRIPT_DIR")")}"

# Source test utilities
source "$SCRIPT_DIR/../lib/test-utils.sh"

echo "Testing script files..."

# List of scripts that should exist and be executable
SCRIPTS=(
    "scripts/deploy-secure.sh"
    "scripts/verify-security.sh"
    "scripts/verify-connection.sh"
    "scripts/fix-auto-restart.sh"
    "scripts/setup-tailscale.sh"
    "scripts/setup-mcp.sh"
    "scripts/install-orbstack-remote.sh"
    "scripts/post-restart-setup.sh"
    "scripts/lib/common.sh"
    "config/docker-setup.sh"
    "config/preflight-check.sh"
    "config/install-aliases.sh"
)

# Test: All scripts exist
print_test "All required scripts exist"
all_exist=true
for script in "${SCRIPTS[@]}"; do
    if [[ ! -f "$PROJECT_ROOT/$script" ]]; then
        print_fail "Script missing: $script"
        all_exist=false
    fi
done
if $all_exist; then
    print_pass "All required scripts exist"
fi

# Test: All scripts are executable (except common.sh which is sourced)
print_test "Scripts are executable"
all_executable=true
for script in "${SCRIPTS[@]}"; do
    if [[ "$script" == *"/lib/"* ]]; then
        # Skip library files - they're sourced, not executed
        continue
    fi
    if [[ -f "$PROJECT_ROOT/$script" && ! -x "$PROJECT_ROOT/$script" ]]; then
        print_fail "Script not executable: $script"
        all_executable=false
    fi
done
if $all_executable; then
    print_pass "All scripts are executable"
fi

# Test: Scripts have proper shebang
print_test "Scripts have proper shebang"
all_shebang=true
for script in "${SCRIPTS[@]}"; do
    if [[ -f "$PROJECT_ROOT/$script" ]]; then
        first_line=$(head -1 "$PROJECT_ROOT/$script")
        if [[ "$first_line" != "#!/bin/bash"* && "$first_line" != "#!/usr/bin/env bash"* ]]; then
            print_fail "Script missing proper shebang: $script"
            all_shebang=false
        fi
    fi
done
if $all_shebang; then
    print_pass "All scripts have proper shebang"
fi

# Test: No syntax errors in scripts
print_test "Scripts have no syntax errors"
all_syntax_ok=true
for script in "${SCRIPTS[@]}"; do
    if [[ -f "$PROJECT_ROOT/$script" ]]; then
        if ! bash -n "$PROJECT_ROOT/$script" 2>/dev/null; then
            print_fail "Syntax error in: $script"
            all_syntax_ok=false
        fi
    fi
done
if $all_syntax_ok; then
    print_pass "All scripts pass syntax check"
fi

# Test: Configuration files exist
print_test "Configuration files exist"
CONFIG_FILES=(
    "config/docker-compose.yml"
    "config/docker-compose.secure.yml"
    "config/Dockerfile.secure"
    "config/seccomp-profile.json"
    "config/.env.example"
)
all_config_exist=true
for config in "${CONFIG_FILES[@]}"; do
    if [[ ! -f "$PROJECT_ROOT/$config" ]]; then
        print_fail "Config file missing: $config"
        all_config_exist=false
    fi
done
if $all_config_exist; then
    print_pass "All configuration files exist"
fi

# Test: JSON files are valid
print_test "JSON files are valid"
JSON_FILES=(
    "config/seccomp-profile.json"
    ".mcp.json"
)
all_json_valid=true
for json_file in "${JSON_FILES[@]}"; do
    if [[ -f "$PROJECT_ROOT/$json_file" ]]; then
        if ! python3 -m json.tool "$PROJECT_ROOT/$json_file" &>/dev/null; then
            print_fail "Invalid JSON: $json_file"
            all_json_valid=false
        fi
    fi
done
if $all_json_valid; then
    print_pass "All JSON files are valid"
fi

# Test: YAML files are valid (basic check)
print_test "YAML files are valid"
YAML_FILES=(
    "config/docker-compose.yml"
    "config/docker-compose.secure.yml"
    ".mcp-project.yaml"
)
all_yaml_valid=true
for yaml_file in "${YAML_FILES[@]}"; do
    if [[ -f "$PROJECT_ROOT/$yaml_file" ]]; then
        # Basic check - ensure file is not empty and starts with valid YAML
        if [[ ! -s "$PROJECT_ROOT/$yaml_file" ]]; then
            print_fail "Empty YAML: $yaml_file"
            all_yaml_valid=false
        fi
    fi
done
if $all_yaml_valid; then
    print_pass "All YAML files appear valid"
fi

echo ""
echo "Script tests complete."
