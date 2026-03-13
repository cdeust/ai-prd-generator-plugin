---
name: generate-prd
description: Generate a production-ready PRD with verification and business KPIs
allowed-tools: Bash, Read, Write, Glob, Grep, WebFetch, WebSearch
argument-hint: "[project-description]"
---

# Generate PRD

## Step 1 — Detect mode

Check your available tools list. If a tool named `mcp__ai-prd-generator__check_health` exists, you are in **Cowork mode**. Otherwise you are in **CLI Terminal mode**.

**Cowork mode:**

Call `check_health` MCP tool. Note the `environment` field:
- `environment: "cowork"` → The plugin analyzes your codebase from **locally shared directories** using Glob, Grep, and Read tools. GitHub API and `gh` CLI are blocked. If no project folder is shared, ask the user to share one before proceeding with codebase analysis. WebFetch on public GitHub URLs is available as a fallback but may time out.
- `environment: "cli"` → Full access. Use `gh` CLI or MCP GitHub tools for repo analysis.

## Step 2 — Load the full skill instructions

**MANDATORY**: Use the Read tool to read the file `~/.claude/skills/ai-prd-generator/SKILL.md`. This file contains the complete PRD generation workflow with all rules, confidence thresholds, clarification loop behavior, section generation, and verification logic. You MUST read it and follow every rule in it.

If the user provided a project description in `$ARGUMENTS`, use it as the initial input. Otherwise, ask for a project description.

Then follow the SKILL.md instructions from the beginning (starting at "CRITICAL WORKFLOW RULES") to execute the full workflow. Do NOT generate any PRD content without first completing the clarification loop as defined in the skill.
