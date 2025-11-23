.PHONY: help sync clean install check list

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)AI Config - Makefile Commands$(NC)"
	@echo ""
	@echo "Available commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-12s$(NC) %s\n", $$1, $$2}'
	@echo ""

sync: ## Sync shared configs to all tools (Claude, Copilot, Gemini)
	@echo "$(BLUE)Syncing configurations...$(NC)"
	@./scripts/sync-configs.sh

clean: ## Remove all generated configs in localcfg/
	@echo "$(YELLOW)Cleaning generated configs...$(NC)"
	@rm -rf localcfg/.claude localcfg/.copilot localcfg/.gemini
	@echo "$(GREEN)Done! Run 'make sync' to regenerate.$(NC)"

check: ## Verify configuration setup
	@echo "$(BLUE)Checking configuration...$(NC)"
	@echo ""
	@echo "Generated configs:"
	@if [ -d "localcfg/.claude/agents" ]; then \
		echo "  $(GREEN)✓$(NC) Claude Code (.claude)"; \
	else \
		echo "  $(YELLOW)✗$(NC) Claude Code (.claude) - Run 'make sync'"; \
	fi
	@if [ -d "localcfg/.copilot/agents" ]; then \
		echo "  $(GREEN)✓$(NC) GitHub Copilot (.copilot)"; \
	else \
		echo "  $(YELLOW)✗$(NC) GitHub Copilot (.copilot) - Run 'make sync'"; \
	fi
	@if [ -d "localcfg/.gemini/commands" ]; then \
		echo "  $(GREEN)✓$(NC) Gemini CLI (.gemini)"; \
	else \
		echo "  $(YELLOW)✗$(NC) Gemini CLI (.gemini) - Run 'make sync'"; \
	fi
	@echo ""
	@echo "Installed configs:"
	@if [ -L "$$HOME/.claude" ] || [ -d "$$HOME/.claude" ]; then \
		echo "  $(GREEN)✓$(NC) ~/.claude exists"; \
	else \
		echo "  $(YELLOW)✗$(NC) ~/.claude not found - Run 'make install' for instructions"; \
	fi
	@if [ -L "$$HOME/.copilot" ] || [ -d "$$HOME/.copilot" ]; then \
		echo "  $(GREEN)✓$(NC) ~/.copilot exists"; \
	else \
		echo "  $(YELLOW)✗$(NC) ~/.copilot not found - Run 'make install' for instructions"; \
	fi
	@if [ -L "$$HOME/.gemini" ] || [ -d "$$HOME/.gemini" ]; then \
		echo "  $(GREEN)✓$(NC) ~/.gemini exists"; \
	else \
		echo "  $(YELLOW)✗$(NC) ~/.gemini not found - Run 'make install' for instructions"; \
	fi
	@echo ""

list: ## List all available agents and commands
	@echo "$(BLUE)Available Agents:$(NC)"
	@echo ""
	@for agent in shared/agents/*.md; do \
		if [ -f "$$agent" ]; then \
			name=$$(grep '^name:' "$$agent" | sed 's/^name: *//'); \
			desc=$$(grep '^description:' "$$agent" | sed 's/^description: *//'); \
			printf "  $(GREEN)%-20s$(NC) %s\n" "$$name" "$$desc"; \
		fi \
	done
	@echo ""
	@echo "$(BLUE)Available Commands:$(NC)"
	@echo ""
	@for cmd in shared/commands/*.md; do \
		if [ -f "$$cmd" ]; then \
			name=$$(basename "$$cmd" .md); \
			printf "  $(GREEN)%-20s$(NC) %s\n" "/$$name" "Custom command"; \
		fi \
	done
	@echo ""
