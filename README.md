# AI Config

Shared configuration for **Claude Code**, **GitHub Copilot**, and **Gemini CLI**.

One set of agents, three AI tools. Edit once in `shared/`, sync to all tools.

## Quick Start

```bash
make sync      # Generate configs for all tools
```

Then configure symlinks to home directories, I make this using nix, but you can do manually:

```bash
symlink localcfg/.claude/ → ~/.claude
```

```

## Structure

```

shared/
├── agents/     # 6 custom agents (edit these)
├── commands/   # Custom slash commands
└── docs/       # Documentation

localcfg/       # Generated (don't edit)
├── .claude/    # → ~/.claude
├── .copilot/   # → ~/.copilot
└── .gemini/    # → ~/.gemini

```

## Custom Agents

| Agent | Purpose |
|-------|---------|
| **architect** | Design systems, no code |
| **developer** | Implement with zero lint errors |
| **debugger** | Investigate bugs systematically |
| **quality-reviewer** | Review for critical issues |
| **adr-writer** | Write Architecture Decision Records |
| **technical-writer** | Write concise docs |

## Usage

**Claude Code:**

```bash
claude
# "Use the architect agent to design this"
```

**GitHub Copilot:**

```bash
copilot
/agent architect
```

**Gemini CLI:**

```bash
gemini -i architect
```

## Adding New Agents

1. Create `shared/agents/your-agent.md`:

   ```yaml
   ---
   name: your-agent
   description: What it does
   color: blue
   ---
   System prompt here...
   ```

2. Run `make sync`

3. Done! Agent now works in all three tools.

## Makefile Commands

```bash
make sync      # Sync shared configs to all tools
make clean     # Remove generated configs
make help      # Show all commands
```
