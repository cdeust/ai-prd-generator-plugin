<div align="center">

# AI PRD Generator

### Production-ready PRDs from Claude Code

[![License: Commercial](https://img.shields.io/badge/License-Commercial-blue.svg)](LICENSE)
[![Node.js 18+](https://img.shields.io/badge/node-18+-blue.svg)](https://nodejs.org)
[![MCP Server](https://img.shields.io/badge/MCP-compatible-green.svg)](https://modelcontextprotocol.io)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/cdeust/ai-prd-generator-plugin/pulls)

**Stop writing PRDs from scratch.** One command generates nine verified files — requirements, technical spec, user stories, roadmap, JIRA tickets, test cases, and a claim-by-claim verification report.

[Install](#install) | [What you get](#what-you-get) | [How it works](#how-it-works) | [Commands](#commands) | [Under the hood](#under-the-hood)

</div>

---

## Install

### One-command setup (Claude Code, Cowork, VS Code)

```bash
claude plugin marketplace add cdeust/ai-prd-generator-plugin
claude plugin install ai-prd-generator
```

That's it. The plugin registers its MCP server (7 tools) and 3 commands. Restart Claude Code and you're running.

### What gets installed

| Component | What it does | Automatic? |
|---|---|---|
| **MCP Server** | 7 tools for license validation, config, health checks, strategy listing | Yes |
| **3 Commands** | `/ai-prd-generator:generate-prd`, `/ai-prd-generator:index-codebase`, `/ai-prd-generator:validate-license` | Yes |
| **Skill** | Full PRD generation workflow with 64 hard output rules | Yes |

### Alternative install methods

<details>
<summary>Local development (--plugin-dir)</summary>

```bash
git clone https://github.com/cdeust/ai-prd-generator-plugin.git
claude --plugin-dir ./ai-prd-generator-plugin
```

</details>

<details>
<summary>Manual setup</summary>

```bash
git clone https://github.com/cdeust/ai-prd-generator-plugin.git
cd ai-prd-generator-plugin
./scripts/setup.sh
```

</details>

---

## What You Get

One command produces nine files:

| File | What's inside |
|------|---------------|
| `prd-overview.md` | Executive summary, goals, scope, and strategic context |
| `prd-requirements.md` | Functional and non-functional requirements with traceability |
| `prd-user-stories.md` | User stories with acceptance criteria mapped to requirements |
| `prd-technical.md` | Technical specification — architecture, data models, API contracts |
| `prd-acceptance.md` | Detailed acceptance criteria with test conditions |
| `prd-roadmap.md` | Implementation phases, milestones, and dependency ordering |
| `prd-jira.md` | Story-pointed epics and tickets, ready to import |
| `prd-tests.md` | Unit, integration, and e2e test cases mapped to requirements |
| `prd-verification.md` | Claim-by-claim audit — structural integrity, consistency, completeness |

See a real example in [`examples/`](examples/) — a 2,766-line PRD for a policy-parameterized prompt system, with 24/24 structural integrity checks passed.

---

## How It Works

1. **You describe what you need** — "auth system with OAuth2", "migrate from REST to GraphQL", or paste a Slack thread
2. **Clarification loop** — The plugin asks structured questions until it reaches 90%+ confidence (or you say "proceed")
3. **Strategy selection** — Picks from 15 thinking strategies based on your PRD type and complexity
4. **Generation + verification** — Writes every section, then verifies each claim against 6 independent algorithms
5. **Nine files land in your directory** — ready for review, handoff, or sprint planning

---

## Commands

| Command | What it does |
|---------|-------------|
| `/ai-prd-generator:generate-prd` | Generate a PRD with interactive clarification |
| `/ai-prd-generator:index-codebase /path` | Index a codebase for context-aware generation |
| `/ai-prd-generator:validate-license [key]` | Check license tier or activate a license key |

### Generate with codebase context

```
/ai-prd-generator:index-codebase /path/to/your/project
/ai-prd-generator:generate-prd
```

The PRD will reference your actual files, architecture patterns, and dependencies.

---

## Under the Hood

| | |
|---|---|
| **PRD types** | 8 — Feature, Bug, Incident, Proposal, MVP, POC, Release, CI/CD |
| **Thinking strategies** | 15 — from MIT, Stanford, Harvard, Anthropic, OpenAI, DeepSeek research (2024-2026) |
| **Verification algorithms** | 6 — adaptive consensus, zero-LLM graph verification, multi-agent debate, atomic claim decomposition |
| **Output rules** | 64 hard rules enforced per section |
| **Stack support** | Python, TypeScript, Go, Rust, Java, Kotlin, Swift |

### MCP Tools

<details>
<summary>7 tools reference</summary>

| Tool | What it does |
|---|---|
| `validate_license` | Validate or activate an AIPRD license key |
| `get_license_features` | Get available features for current license tier |
| `get_config` | Read skill configuration sections |
| `read_skill_config` | Read the full skill config |
| `check_health` | Health check — environment, version, config status |
| `get_prd_context_info` | Get PRD type configuration (sections, clarification range, RAG hops) |
| `list_available_strategies` | List available thinking strategies for current tier |

</details>

### License Tiers

| Feature | Free | Licensed |
|---|---|---|
| PRD types | Feature, Bug | All 8 |
| Thinking strategies | 2 (zero-shot, chain-of-thought) | All 15 |
| Verification | Basic | Full multi-judge |
| Clarification rounds | 3 max | Unlimited |
| Business KPIs | Summary only | Full |

---

## Part of a Bigger System

This plugin handles PRD generation — Stage 4 of a 10-stage autonomous development pipeline.

**[ai-architect-feedback-loop](https://github.com/cdeust/ai-architect-feedback-loop)** is the full pipeline: it takes a research finding through impact analysis, PRD generation, implementation, gate enforcement, verification, and deployment — all autonomous, all verified.

---

## System Requirements

### Cowork Plugin (Claude Desktop)

- Claude Desktop (macOS or Windows) with a paid plan (Pro, Max, Team, or Enterprise)
- No additional dependencies — the plugin runs inside Cowork's sandboxed VM

### CLI Terminal Mode

- macOS, Windows, or Linux
- Node.js 18+
- Claude Code (Anthropic)

---

## Troubleshooting

| Issue | Solution |
|---|---|
| **Commands not found** | Run `/reload-plugins` or restart Claude Code |
| **MCP server not starting** | Verify Node.js 18+ is installed: `node --version` |
| **Plugin not visible in Cowork** | Cowork only runs on Claude Desktop (macOS/Windows) |
| **Clarification loop won't end** | Say "proceed" to skip to generation |
| **License key rejected** | Check the key starts with `AIPRD-` and try again |

---

Built by [Clement Deust](https://ai-architect.tools)
