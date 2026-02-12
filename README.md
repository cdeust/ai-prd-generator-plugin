# AI PRD Generator

Enterprise-grade Product Requirements Document generator for Claude Code and Cowork.

Produces implementation-ready PRDs with SQL DDL, API specs, domain models, JIRA tickets, test cases, and verification reports. Supports 8 PRD types, 15 thinking strategies with research-based prioritization, multi-round interactive clarification, codebase context analysis, and automated 4-file export.

## Installation

### From Plugin Directory

Search for **AI PRD Generator** in the Claude Code plugin directory.

### Manual Installation

```bash
claude plugin install ai-prd-generator
```

### Development Mode

```bash
git clone https://github.com/cdeust/ai-prd-generator-plugin.git
claude --plugin-dir ./ai-prd-generator-plugin
```

## Features

### 8 PRD Types

| Type | Focus | Sections |
|------|-------|----------|
| **Feature** | Full technical implementation | 11 sections with SQL DDL, API specs |
| **Bug** | Root cause analysis | 6 sections with regression tests |
| **Incident** | Deep forensic investigation | 8 sections with timeline + prevention |
| **Proposal** | Business case & ROI | 7 sections, stakeholder-facing |
| **MVP** | Core value, fastest to market | 8 sections with explicit cut list |
| **POC** | Feasibility validation | 5 sections with risk assessment |
| **Release** | Production readiness | 10 sections with rollback plan |
| **CI/CD** | Pipeline automation | 9 sections with deployment strategy |

### 4-File Export (Automated)

Every PRD generation produces four files:

| File | Audience | Contents |
|------|----------|----------|
| `PRD-{Name}.md` | Product/Stakeholders | Full PRD with specs, models, API routes |
| `PRD-{Name}-jira.md` | Project Management | JIRA-importable tickets with story points |
| `PRD-{Name}-tests.md` | QA Team | Unit, integration, e2e tests + traceability |
| `PRD-{Name}-verification.md` | Audit/Compliance | Claim-by-claim verification audit trail |

### 15 Thinking Strategies

Research-based strategy selection from MIT, Stanford, Harvard, Anthropic, OpenAI, and DeepSeek papers (2024-2026):

- **Tier 1**: Extended Thinking (TRM), Verified Reasoning, Self-Consistency
- **Tier 2**: Tree of Thoughts, Graph of Thoughts, ReAct, Reflexion
- **Tier 3**: Few-Shot, Meta-Prompting, Plan and Solve, Problem Analysis
- **Tier 4 (Free)**: Zero-Shot, Chain of Thought

### Multi-Judge Verification Engine

6 verification algorithms with adaptive consensus:

1. **KS Adaptive Consensus** — Early stopping when judges agree (saves 30-50% LLM calls)
2. **Zero-LLM Graph Verification** — Free structural analysis (cycles, orphans, conflicts)
3. **Multi-Agent Debate** — Converge on disputed claims
4. **Complexity-Aware Strategy** — Right-size verification per claim
5. **Atomic Claim Decomposition** — Split vague claims into verifiable atoms
6. **Unified Verification Pipeline** — Orchestrate all algorithms per section

### Codebase Context Analysis

When provided a local codebase directory, the generator:

- Extracts architecture patterns, domain entities, dependencies
- Finds baseline metrics from test assertions, monitoring code, SLA configs
- Uses real codebase data for goal-setting (not guesses)
- References specific files and line numbers in the PRD

### Interactive Clarification

- Infinite clarification rounds — user controls when to proceed
- Context-aware questions informed by codebase and mockup analysis
- Scope assessment with epic detection for large requests
- Structured multi-choice questions (never open-ended)

## Slash Commands

| Command | Description |
|---------|-------------|
| `/ai-prd-generator:generate-prd` | Generate a production-ready PRD |
| `/ai-prd-generator:validate-license` | Check license tier and activate keys |
| `/ai-prd-generator:index-codebase` | Analyze a codebase for RAG-enhanced generation |

## MCP Server Tools

The plugin includes a zero-dependency Node.js MCP server with tools for:

- License validation and activation (Ed25519 cryptographic verification)
- Configuration and skill config inspection
- Health checks with environment detection
- PRD context and strategy information

## License Tiers

### Free Tier

- 2 thinking strategies (Zero-Shot, Chain of Thought)
- 3 clarification rounds max
- Basic verification (single pass)
- Feature and Bug PRD types

### Licensed Tier

- All 15 thinking strategies with research-based prioritization
- Unlimited clarification rounds
- Full 6-algorithm verification engine
- All 8 PRD types
- Priority support

**Pricing**: $79/month or $499 lifetime license at [aiprd.dev](https://aiprd.dev)

## Use Cases

### 1. Feature PRD with Codebase Analysis

Share a project directory and describe a new feature. The generator analyzes existing architecture, extracts baseline metrics, asks targeted clarification questions referencing actual code patterns, then produces a full 11-section PRD with SQL DDL, domain models, API specs, Fibonacci story points, and JIRA-ready tickets.

### 2. Bug/Incident Root Cause Analysis

Describe a production bug or incident. The generator asks forensic questions (timeline, affected systems, error logs), then produces a focused PRD with root cause analysis, fix requirements, regression tests, and prevention measures — all verified claim-by-claim.

### 3. MVP with Scope Control

Submit an ambitious feature request. The generator detects excessive scope, offers a choice between full roadmap overview (T-shirt sizing) or focused epic PRD (full implementation specs). Choose one epic to get sprint-ready tickets while keeping the full vision documented.

## Environment Support

| Environment | Codebase Analysis | GitHub Access | RAG Database |
|-------------|-------------------|---------------|--------------|
| **CLI** (Claude Code) | Local dirs + GitHub URLs | Full (gh CLI or MCP tools) | PostgreSQL + pgvector |
| **Cowork** (Claude Desktop) | Local shared dirs only | Not available (network restricted) | File-based (Glob/Grep/Read) |

## Technical Details

- **MCP Server**: Zero-dependency Node.js (runs on Node.js 22 pre-installed in Cowork)
- **License Verification**: Ed25519 digital signatures, AES-256 encrypted persistence
- **Transport**: stdio (JSON-RPC 2.0)
- **Plugin Size**: ~160KB (SKILL.md + MCP server + config)

## Support

- Website: [aiprd.dev](https://aiprd.dev)
- Email: support@aiprd.dev
- Issues: [GitHub Issues](https://github.com/cdeust/ai-prd-generator-plugin/issues)
