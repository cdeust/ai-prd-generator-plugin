# AI PRD Generator

**Stop writing PRDs from scratch.** This Claude Code plugin generates verified Product Requirements Documents — nine files covering requirements, technical design, user stories, JIRA tickets, test cases, and a claim-by-claim verification report.

```
/plugin marketplace add cdeust/ai-prd-generator-plugin
/plugin install ai-prd-generator
```

Then run `/ai-prd-generator` from any project. Free, open source, no account needed.

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

## How It Works

1. **You describe what you need** — "auth system with OAuth2", "migrate from REST to GraphQL", or paste a Slack thread
2. **Clarification loop** — The plugin asks structured questions until it reaches 90%+ confidence (or you say "proceed")
3. **Strategy selection** — Picks from 15 thinking strategies based on your PRD type and complexity
4. **Generation + verification** — Writes every section, then verifies each claim against 6 independent algorithms
5. **Nine files land in your directory** — ready for review, handoff, or sprint planning

## Why This Exists

Most PRD tools run one prompt and hand you a rough draft. This one:

- **Asks before assuming** — Confidence-driven clarification catches gaps before generation starts
- **Verifies its own output** — Multi-judge consensus, graph analysis, atomic claim decomposition
- **Reads your codebase** — Index your project first (`/ai-prd-generator:index-codebase /path`) and the PRD references your actual architecture, files, and patterns
- **Ships work, not drafts** — 9 files: requirements, tech spec, user stories, roadmap, JIRA tickets, test cases, acceptance criteria, verification report

## Quick Start

### Install (2 commands)

```
/plugin marketplace add cdeust/ai-prd-generator-plugin
/plugin install ai-prd-generator
```

### Generate a PRD

```
/ai-prd-generator:generate-prd
```

Or just describe what you need in natural language — the plugin detects intent.

### Generate with codebase context

```
/ai-prd-generator:index-codebase /path/to/your/project
/ai-prd-generator:generate-prd
```

The PRD will reference your actual files, architecture patterns, and dependencies.

### Manual setup (alternative)

```bash
git clone https://github.com/cdeust/ai-prd-generator-plugin.git
cd ai-prd-generator-plugin
./scripts/setup.sh
```

## Under the Hood

| | |
|---|---|
| **PRD types** | 8 — Feature, Bug, Incident, Proposal, MVP, POC, Release, CI/CD |
| **Thinking strategies** | 15 — from MIT, Stanford, Harvard, Anthropic, OpenAI, DeepSeek research (2024-2026) |
| **Verification algorithms** | 6 — adaptive consensus, zero-LLM graph verification, multi-agent debate, atomic claim decomposition |
| **Output rules** | 64 hard rules enforced per section |
| **Stack support** | Python, TypeScript, Go, Rust, Java, Kotlin, Swift |

## Part of a Bigger System

This plugin handles PRD generation — Stage 4 of a 10-stage autonomous development pipeline.

**[ai-architect-feedback-loop](https://github.com/cdeust/ai-architect-feedback-loop)** is the full pipeline: it takes a research finding through impact analysis, PRD generation, implementation, gate enforcement, verification, and deployment — all autonomous, all verified.

If you're using this plugin and thinking "I wish this continued into implementation," that's the other repo.

## Commands

| Command | What it does |
|---------|-------------|
| `/ai-prd-generator` | Full PRD generation workflow |
| `/ai-prd-generator:generate-prd` | Generate a PRD with interactive clarification |
| `/ai-prd-generator:index-codebase /path` | Index a codebase for context-aware generation |

## System Requirements

- macOS 14+ (Sonoma) on Apple Silicon (M1/M2/M3/M4)
- Node.js 18+
- Claude Code (Anthropic)

## Troubleshooting

**Commands not found** — Run `./scripts/setup.sh` again. Check that `~/.claude/skills/ai-prd-generator/` exists.

**Clarification loop won't end** — Say "proceed" to skip to generation at any point.

---

Built by [Clement Deust](https://ai-architect.tools)
