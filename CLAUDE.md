# AI PRD Generator Plugin

This is the ai-prd-generator plugin repository for Claude Code.

## Installation

### Via Marketplace (recommended)
```
/plugin marketplace add cdeust/ai-prd-generator-plugin
/plugin install ai-prd-generator
```

### Manual Setup
```bash
git clone https://github.com/cdeust/ai-prd-generator-plugin.git
cd ai-prd-generator-plugin
./scripts/setup.sh
```

## Cowork Mode — IMPORTANT

When running in **Cowork** (Claude's hosted VM environment), the plugin analyzes your codebase from **locally shared directories**. GitHub API and `gh` CLI are blocked in Cowork VMs.

**Before using any PRD generation or codebase indexing command in Cowork, you MUST share your project folder** with the Cowork session. The plugin uses Glob, Grep, and Read tools on the shared directory to analyze your codebase — no GitHub access needed.

If no project folder is shared, the plugin cannot perform codebase analysis and will ask you to either share a directory or paste code manually.

## Slash Commands

After installation, the following slash commands are available from any Claude Code session:

- `/ai-prd-generator:generate-prd` — generate a PRD
- `/ai-prd-generator:index-codebase` — index a codebase for RAG
- `/ai-prd-generator` — main skill (full PRD generation workflow)
