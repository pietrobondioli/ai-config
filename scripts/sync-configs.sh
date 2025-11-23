#!/usr/bin/env bash
#
# sync-configs.sh - Synchronize AI tool configurations from shared/ to tool-specific directories
#
# This script copies and converts agent and command definitions from the shared/ directory
# to tool-specific formats for Claude Code, GitHub Copilot, and Gemini CLI.
#
# Usage: ./scripts/sync-configs.sh
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Base directory (script location parent)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# Source and destination directories
SHARED_AGENTS="$BASE_DIR/shared/agents"
SHARED_COMMANDS="$BASE_DIR/shared/commands"
SHARED_DOCS="$BASE_DIR/shared/docs"

CLAUDE_DIR="$BASE_DIR/localcfg/.claude"
COPILOT_DIR="$BASE_DIR/localcfg/.copilot"
GEMINI_DIR="$BASE_DIR/localcfg/.gemini"

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create directory structure
create_directories() {
    log_info "Creating directory structure..."

    mkdir -p "$CLAUDE_DIR/agents" "$CLAUDE_DIR/commands"
    mkdir -p "$COPILOT_DIR/agents" "$COPILOT_DIR/commands"
    mkdir -p "$GEMINI_DIR/commands"

    log_success "Directories created"
}

# Sync agents for Claude Code
sync_claude_agents() {
    log_info "Syncing agents for Claude Code..."

    if [ ! -d "$SHARED_AGENTS" ] || [ -z "$(ls -A "$SHARED_AGENTS" 2>/dev/null)" ]; then
        log_warn "No agents found in $SHARED_AGENTS"
        return
    fi

    for agent in "$SHARED_AGENTS"/*.md; do
        [ -e "$agent" ] || continue
        filename=$(basename "$agent")

        # For Claude, we can use the same format as Copilot
        # Just copy the file directly
        cp "$agent" "$CLAUDE_DIR/agents/$filename"
        log_success "  ✓ Claude agent: $filename"
    done
}

# Sync agents for GitHub Copilot
sync_copilot_agents() {
    log_info "Syncing agents for GitHub Copilot..."

    if [ ! -d "$SHARED_AGENTS" ] || [ -z "$(ls -A "$SHARED_AGENTS" 2>/dev/null)" ]; then
        log_warn "No agents found in $SHARED_AGENTS"
        return
    fi

    for agent in "$SHARED_AGENTS"/*.md; do
        [ -e "$agent" ] || continue
        filename=$(basename "$agent")

        # Copy directly - Copilot uses YAML frontmatter + markdown
        cp "$agent" "$COPILOT_DIR/agents/$filename"
        log_success "  ✓ Copilot agent: $filename"
    done
}

# Convert and sync agents for Gemini CLI
sync_gemini_agents() {
    log_info "Converting agents for Gemini CLI..."

    if [ ! -d "$SHARED_AGENTS" ] || [ -z "$(ls -A "$SHARED_AGENTS" 2>/dev/null)" ]; then
        log_warn "No agents found in $SHARED_AGENTS"
        return
    fi

    for agent in "$SHARED_AGENTS"/*.md; do
        [ -e "$agent" ] || continue
        filename=$(basename "$agent" .md)

        # Extract frontmatter and content
        # Gemini uses TOML format, so we convert YAML frontmatter to TOML

        # Extract name and description from YAML frontmatter
        name=$(grep '^name:' "$agent" | sed 's/^name: *//' | tr -d '"' | tr -d "'")
        description=$(grep '^description:' "$agent" | sed 's/^description: *//' | tr -d '"' | tr -d "'")

        # Extract markdown content (everything after the closing ---)
        content=$(awk '/^---$/{if(++count==2){flag=1;next}}flag' "$agent")

        # Create TOML file for Gemini
        cat > "$GEMINI_DIR/commands/${filename}.toml" <<EOF
# Gemini CLI agent configuration for: $name
# Generated from shared agent definition

[metadata]
name = "$name"
description = "$description"
type = "agent"

[prompt]
content = """
$content
"""
EOF

        log_success "  ✓ Gemini agent: ${filename}.toml"
    done
}

# Sync commands for Claude Code
sync_claude_commands() {
    log_info "Syncing commands for Claude Code..."

    if [ ! -d "$SHARED_COMMANDS" ] || [ -z "$(ls -A "$SHARED_COMMANDS" 2>/dev/null)" ]; then
        log_warn "No commands found in $SHARED_COMMANDS"
        return
    fi

    for command in "$SHARED_COMMANDS"/*.md; do
        [ -e "$command" ] || continue
        filename=$(basename "$command")

        cp "$command" "$CLAUDE_DIR/commands/$filename"
        log_success "  ✓ Claude command: $filename"
    done
}

# Sync commands for GitHub Copilot
sync_copilot_commands() {
    log_info "Syncing commands for GitHub Copilot..."

    if [ ! -d "$SHARED_COMMANDS" ] || [ -z "$(ls -A "$SHARED_COMMANDS" 2>/dev/null)" ]; then
        log_warn "No commands found in $SHARED_COMMANDS"
        return
    fi

    for command in "$SHARED_COMMANDS"/*.md; do
        [ -e "$command" ] || continue
        filename=$(basename "$command")

        cp "$command" "$COPILOT_DIR/commands/$filename"
        log_success "  ✓ Copilot command: $filename"
    done
}

# Convert and sync commands for Gemini CLI
sync_gemini_commands() {
    log_info "Converting commands for Gemini CLI..."

    if [ ! -d "$SHARED_COMMANDS" ] || [ -z "$(ls -A "$SHARED_COMMANDS" 2>/dev/null)" ]; then
        log_warn "No commands found in $SHARED_COMMANDS"
        return
    fi

    for command in "$SHARED_COMMANDS"/*.md; do
        [ -e "$command" ] || continue
        filename=$(basename "$command" .md)

        # For commands, we just need the content
        content=$(cat "$command")

        # Create TOML file for Gemini command
        cat > "$GEMINI_DIR/commands/${filename}.toml" <<EOF
# Gemini CLI command: $filename
# Generated from shared command definition

[metadata]
name = "$filename"
type = "command"

[prompt]
content = """
$content
"""
EOF

        log_success "  ✓ Gemini command: ${filename}.toml"
    done
}

# Copy documentation files
sync_docs() {
    log_info "Copying documentation files..."

    if [ -d "$SHARED_DOCS" ] && [ -n "$(ls -A "$SHARED_DOCS" 2>/dev/null)" ]; then
        cp -r "$SHARED_DOCS"/* "$CLAUDE_DIR/" 2>/dev/null || true
        cp -r "$SHARED_DOCS"/* "$COPILOT_DIR/" 2>/dev/null || true
        log_success "Documentation files copied"
    else
        log_warn "No documentation files found in $SHARED_DOCS"
    fi
}

# Main execution
main() {
    echo ""
    log_info "Starting AI configuration sync..."
    log_info "Base directory: $BASE_DIR"
    echo ""

    create_directories
    echo ""

    # Sync Claude Code
    log_info "=== Claude Code ==="
    sync_claude_agents
    sync_claude_commands
    echo ""

    # Sync GitHub Copilot
    log_info "=== GitHub Copilot ==="
    sync_copilot_agents
    sync_copilot_commands
    echo ""

    # Sync Gemini CLI
    log_info "=== Gemini CLI ==="
    sync_gemini_agents
    sync_gemini_commands
    echo ""

    # Sync docs
    sync_docs
    echo ""

    log_success "Configuration sync complete!"
    echo ""
    log_info "Next steps:"
    echo "  1. Review the generated configs in localcfg/"
    echo "  2. Use NixOS to symlink localcfg/.claude -> ~/.claude"
    echo "  3. Use NixOS to symlink localcfg/.copilot -> ~/.copilot"
    echo "  4. Use NixOS to symlink localcfg/.gemini -> ~/.gemini"
    echo ""
}

# Run main function
main "$@"
