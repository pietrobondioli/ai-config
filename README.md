# AI Configuration Repository

Central repository for managing AI tool configurations across **Claude Code**, **GitHub Copilot**, and **Gemini CLI**.

This repository uses a **shared agent/command library** that syncs to tool-specific formats, providing a consistent experience across all AI CLI tools.

## Features

- **6 Custom Agents**: architect, developer, debugger, quality-reviewer, adr-writer, technical-writer
- **Shared Library**: Single source of truth for agent definitions
- **Multi-Tool Support**: Automatic conversion to Claude, Copilot, and Gemini formats
- **Sync Script**: One command to update all tool configurations
- **NixOS Ready**: Designed for declarative home-manager configuration

## Quick Start

### 1. Sync Configurations

Generate tool-specific configs from shared definitions:

```bash
./scripts/sync-configs.sh
```

This will:
- Copy agents to `.claude/` and `.copilot/` (YAML + Markdown)
- Convert agents to `.gemini/` (TOML format)
- Sync commands for all three tools

### 2. Install Configurations

Link the generated configs to your home directory using NixOS home-manager or manually:

```nix
# NixOS home-manager example
home.file.".claude".source = ./personal/ai-config/localcfg/.claude;
home.file.".copilot".source = ./personal/ai-config/localcfg/.copilot;
home.file.".gemini".source = ./personal/ai-config/localcfg/.gemini;
```

Or manually with symlinks:
```bash
ln -s ~/personal/ai-config/localcfg/.claude ~/.claude
ln -s ~/personal/ai-config/localcfg/.copilot ~/.copilot
ln -s ~/personal/ai-config/localcfg/.gemini ~/.gemini
```

## Repository Structure

```
ai-config/
├── shared/                    # Source of truth
│   ├── agents/               # Shared agent definitions (YAML + MD)
│   │   ├── adr-writer.md
│   │   ├── architect.md
│   │   ├── debugger.md
│   │   ├── developer.md
│   │   ├── quality-reviewer.md
│   │   └── technical-writer.md
│   ├── commands/             # Shared command templates
│   │   └── plan-execution.md
│   └── docs/                 # Documentation
│       └── prompt-engineering.md
├── localcfg/                 # Generated configs (DO NOT EDIT)
│   ├── .claude/              # Claude Code CLI
│   ├── .copilot/             # GitHub Copilot CLI
│   └── .gemini/              # Gemini CLI
├── scripts/
│   └── sync-configs.sh       # Sync script
└── README.md
```

## Custom Agents

All agents are specialized AI assistants designed for specific tasks in your development workflow:

| Agent | Purpose | Key Features |
|-------|---------|--------------|
| **architect** | System design & architecture | No implementation code, design-only |
| **developer** | Code implementation | Zero linting violations, test-driven |
| **debugger** | Bug investigation | Evidence-based, systematic analysis |
| **quality-reviewer** | Code review | Production-critical issues only |
| **adr-writer** | Architecture Decision Records | Structured ADR creation & updates |
| **technical-writer** | Documentation | Token-limited, concise docs |

### Agent Usage

**Claude Code:**
```bash
claude
# Auto-delegated by main agent or explicitly:
# "Use the architect agent to design this feature"
```

**GitHub Copilot:**
```bash
copilot
# Use slash commands:
/agent architect
/delegate developer
```

**Gemini CLI:**
```bash
gemini -i architect  # Interactive mode with agent
```

## Custom Commands

### `/plan-execution`

Project Manager protocol for implementing analyzed plans with delegation to specialized agents.

**Features:**
- TodoWrite-based tracking
- Multi-agent delegation protocol
- Evidence-based error handling
- Strict acceptance testing

## Workflow

### Making Changes

1. **Edit shared definitions**: Modify files in `shared/agents/` or `shared/commands/`
2. **Run sync script**: `./scripts/sync-configs.sh`
3. **Commit changes**: Git commit the `shared/` directory
4. **NixOS users**: Rebuild home-manager config

### Adding New Agents

1. Create `shared/agents/your-agent.md`:
```yaml
---
name: your-agent
description: Brief description of the agent
color: blue
---
Your agent's system prompt goes here...
```

2. Run sync script: `./scripts/sync-configs.sh`
3. Agent is now available in all three tools!

## Tool-Specific Notes

### Claude Code
- Supports custom agents, commands, hooks, and MCP servers
- Location: `~/.claude/`
- Format: YAML frontmatter + Markdown
- Auto-delegation support

### GitHub Copilot
- Supports custom agents and commands
- Location: `~/.copilot/`
- Format: YAML frontmatter + Markdown
- Manual delegation via `/agent` and `/delegate`

### Gemini CLI
- Supports custom commands and extensions
- Location: `~/.gemini/commands/`
- Format: TOML
- More prompt-based approach

## Project Standards

Agents reference `CLAUDE.md` in your projects for:
- Language-specific conventions
- Error handling patterns
- Testing requirements
- Build/linting commands
- Code style guidelines

Create a `CLAUDE.md` in your project root with these standards for consistent agent behavior.

## Related Tools

### SearXNG Docker
This directory may contain a self-hosted SearXNG search engine setup using Docker (excluded from git).
