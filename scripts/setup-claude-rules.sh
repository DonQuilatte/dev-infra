#!/bin/bash
# setup-claude-rules.sh - Add CLAUDE.md to a project
# Usage: ./setup-claude-rules.sh <project-name>

set -e

PROJECTS_DIR="$HOME/Development/Projects"
TEMPLATE="$HOME/Development/Projects/clawdbot/CLAUDE.md"

if [ -z "$1" ]; then
    echo "Usage: ./setup-claude-rules.sh <project-name>"
    echo ""
    echo "Available projects:"
    ls -1 "$PROJECTS_DIR" 2>/dev/null | grep -v clawdbot | sed 's/^/  /'
    exit 1
fi

PROJECT_NAME="$1"
PROJECT_PATH="$PROJECTS_DIR/$PROJECT_NAME"

if [ ! -d "$PROJECT_PATH" ]; then
    echo "Error: Project '$PROJECT_NAME' not found"
    exit 1
fi

if [ -f "$PROJECT_PATH/CLAUDE.md" ]; then
    echo "⚠️  CLAUDE.md already exists in $PROJECT_NAME"
    read -p "Overwrite? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

cp "$TEMPLATE" "$PROJECT_PATH/CLAUDE.md"
echo "✅ Copied CLAUDE.md to $PROJECT_NAME"
echo ""
echo "Next steps:"
echo "1. Edit $PROJECT_PATH/CLAUDE.md for project-specific context"
echo "2. Update 'Project Overview' section"
echo "3. List key files and commands"
echo "4. Test: cd $PROJECT_PATH && agy"
