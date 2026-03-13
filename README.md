# AI PRD Generator

Free and open-source PRD generation plugin for Claude Code. Generates verified Product Requirements Documents with 15 thinking strategies, 6 verification algorithms, JIRA tickets, test cases, and claim-by-claim verification reports.

## Verification, Not Just Generation

Most PRD tools generate a document from a single prompt and call it done. This one asks clarification questions first, selects from 15 research-based thinking strategies, and verifies every claim with 6 independent algorithms. The output is a verified specification with JIRA tickets, test cases, and an audit trail — not a rough draft.

**Deliverables per generation:**

- `prd.md` — main specification
- `jira-tickets.md` — task breakdown with story points and acceptance criteria
- `test-cases.md` — unit, integration, and e2e QA coverage
- `verification-report.md` — audit trail with verified claims, contradiction checks, multi-judge consensus

## Features

| Capability | Details |
|------------|---------|
| Thinking Strategies | 15 — research-based selection from MIT, Stanford, Harvard, Anthropic, OpenAI, and DeepSeek papers (2024–2026) |
| Verification Algorithms | 6 — adaptive consensus, zero-LLM graph verification, multi-agent debate, atomic claim decomposition |
| PRD Types | 8 — Feature, Bug, Incident, Proposal, MVP, POC, Release, CI/CD |
| Hard Output Rules | 64 |
| Stack Support | Python, TypeScript, Go, Rust, Java, Kotlin, Swift |

**Interactive Clarification** — Confidence-driven loop with structured multi-choice questions. Continues until the threshold is reached or the user says "proceed".

**Codebase Context Analysis** — Extracts architecture patterns, domain entities, dependencies, and baseline metrics from your codebase. References specific files and line numbers in the generated PRD.

## Installation

### Via Claude Code Marketplace (recommended)

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

The script installs the skill and commands into `~/.claude/skills/` and `~/.claude/commands/`, so they're available globally in Claude Code. It also builds the Cowork plugin ZIP if applicable.

Start `claude` from any directory — no flags needed.

### Cowork (Claude Desktop)

The setup script builds a `dist/ai-prd-generator-plugin.zip` file. Upload that ZIP as a local plugin in Cowork.

**Known limitation:** Cowork runs plugins in a sandboxed virtual environment. It cannot access your codebase from outside that sandbox. To get codebase-aware PRDs, start the plugin from within your project folder so the files are available to the sandbox. For full codebase analysis, we recommend using Claude Code (terminal) instead.

### Full Pipeline

If you're using the [ai-architect-feedback-loop](https://github.com/cdeust/ai-architect-feedback-loop) pipeline, the setup process handles this dependency automatically. The PRD Generator runs at Stage 4 of the 10-stage autonomous pipeline.

## Usage

### Generate a PRD

```
/ai-prd-generator:generate-prd
```

Or describe what you need directly:

```
generate a PRD for a user authentication system with OAuth2
```

The plugin detects your project type, asks clarification questions, and generates all four deliverables when ready.

### With codebase context

```
/ai-prd-generator:index-codebase /path/to/your/project
```

Then generate a PRD. The plugin uses your codebase architecture, patterns, and existing code to produce more accurate specs.

## Commands

| Command | Description |
|---------|-------------|
| `/ai-prd-generator` | Main skill — full PRD generation workflow |
| `/ai-prd-generator:generate-prd` | Generate a PRD through the interactive workflow |
| `/ai-prd-generator:index-codebase /path` | Index a codebase for context-aware generation |

## How It Works

1. **Input analysis** — Detects PRD type, scope, and complexity from your description. If a codebase was indexed, incorporates architecture context.
2. **Clarification loop** — Asks multi-choice questions in rounds. Confidence score increases each round. Continues until the threshold is reached or you say "proceed".
3. **Strategy selection** — Selects from 15 thinking strategies based on PRD type and complexity.
4. **Generation** — Produces all PRD sections with section-by-section verification against 64 hard output rules.
5. **Export** — Writes four deliverable files to the current directory.

## System Requirements

- macOS 14+ (Sonoma) on Apple Silicon (M1, M2, M3, or M4)
- Node.js 18+
- Claude Code or Cowork subscription (Anthropic)
- Advanced VisionEngine features (on-device Foundation Models) require macOS 26+ (Tahoe)

Intel Macs, Linux, and Windows are not currently supported — the Swift verification, RAG, and strategy engines require ARM64 macOS.

## Examples

See the `examples/` directory for a complete 4-file PRD output (Snippet Library CRUD feature):

- `PRD-SnippetLibraryCRUD.md` — Full PRD with 11 sections
- `PRD-SnippetLibraryCRUD-jira.md` — JIRA tickets with story points
- `PRD-SnippetLibraryCRUD-tests.md` — Unit, integration, and e2e test cases
- `PRD-SnippetLibraryCRUD-verification.md` — Claim-by-claim verification report

## Troubleshooting

**Commands not found after setup** — Run `./scripts/setup.sh` again. Verify symlinks exist at `~/.claude/skills/ai-prd-generator/` and `~/.claude/commands/ai-prd-generator/`.

**Clarification loop stuck** — At 95%+ confidence, say "proceed" to start generation.

## Source Code

Both projects are open source on GitHub:

- **Pipeline:** [github.com/cdeust/ai-architect-feedback-loop](https://github.com/cdeust/ai-architect-feedback-loop)
- **PRD Skill:** [github.com/cdeust/ai-prd-generator-plugin](https://github.com/cdeust/ai-prd-generator-plugin)

## Author

Clement Deust ([ai-architect.tools](https://ai-architect.tools))
