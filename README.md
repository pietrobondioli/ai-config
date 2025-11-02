# AI Configuration

This repository contains configuration files for various AI tools including GitHub Copilot CLI.

## Setup with GNU Stow

To sync configurations to your home directory:

```bash
cd ~/personal/ai-tooling
stow -t ~ localcfg
```

This will create symlinks from ~/.copilot to this repository's .copilot directory.

## Structure

- `.copilot/agents/` - User-level custom agents for Copilot CLI

## Contents

### SearXNG Docker

This directory contains a self-hosted SearXNG search engine setup using Docker.
