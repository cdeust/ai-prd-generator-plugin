# RAG Engine & Reference — Strategies, Judges, Quality, KPIs

## 15 RAG-Enhanced Thinking Strategies

**All strategies now support codebase context via RAG integration.**

When a `codebaseId` is provided, each strategy:
1. Retrieves relevant code patterns from the RAG engine
2. Extracts domain entities and architectural patterns
3. Generates contextual examples from actual codebase
4. Enriches reasoning with project-specific knowledge

### Research-Based Strategy Prioritization

**Based on MIT/Stanford/Harvard/Anthropic/OpenAI/DeepSeek research (2024-2025):**

| Tier | Strategies | Research Basis |
|------|------------|----------------|
| **Tier 1 (Most Effective)** | TRM, verified_reasoning, self_consistency | Anthropic extended thinking, OpenAI o1/o3 test-time compute |
| **Tier 2 (Highly Effective)** | tree_of_thoughts, graph_of_thoughts, react, reflexion | Stanford ToT paper, MIT GoT research, DeepSeek R1 |
| **Tier 3 (Contextual)** | few_shot, meta_prompting, plan_and_solve, problem_analysis | RAG-enhanced example generation, Meta AI research |
| **Tier 4 (Basic)** | zero_shot, chain_of_thought | Direct prompting (baseline) |

### Strategy Details with RAG Integration

| Strategy | Use Case | RAG Enhancement |
|----------|----------|-----------------|
| **TRM** | Extended thinking with statistical halting | Uses codebase patterns for confidence calibration |
| **Verified-Reasoning** | Integration with verification engine | RAG context for claim verification |
| **Self-Consistency** | Multiple paths with voting | Codebase examples guide path generation |
| **Tree-of-Thoughts** | Branching exploration with evaluation | Domain entities inform branch scoring |
| **Graph-of-Thoughts** | Multi-hop reasoning with connections | Architecture patterns enrich graph nodes |
| **ReAct** | Reasoning + Action cycles | Code patterns inform action selection |
| **Reflexion** | Self-reflection with memory | Historical patterns guide reflection |
| **Few-Shot** | Example-based reasoning | **RAG-generated examples from codebase** |
| **Meta-Prompting** | Dynamic strategy selection | Context-aware strategy routing |
| **Plan-and-Solve** | Structured planning with verification | Existing code guides plan decomposition |
| **Problem-Analysis** | Deep problem decomposition | Codebase structure informs analysis |
| **Generate-Knowledge** | Knowledge generation before reasoning | RAG provides domain knowledge |
| **Prompt-Chaining** | Sequential prompt execution | Chain steps informed by patterns |
| **Multimodal-CoT** | Vision-integrated reasoning | Combines vision + codebase context |
| **Zero-Shot** | Direct reasoning without examples | Baseline strategy |
| **Chain-of-Thought** | Step-by-step reasoning | Baseline strategy |

---

## RAG ENGINE (Contextual BM25 - +49% Precision)

### The Innovation

Prepend LLM-generated context to chunks BEFORE indexing. This allows BM25 to match semantic queries (e.g., "authentication" matches `func login(...)`) that vanilla keyword search would miss.

### Hybrid Search

- Vector similarity: 70% weight
- BM25 full-text: 30% weight
- Reciprocal Rank Fusion (k=60)
- Critical mass limits: 5-10 chunks optimal, max 25

### Integration with All 15 Thinking Strategies

**Every thinking strategy accepts a `codebaseId` parameter for RAG enrichment.**

**RAG-Enhanced Features per Strategy:**

| Strategy | RAG Feature Used |
|----------|-----------------|
| Few-Shot | Generates contextual examples from actual code patterns |
| Self-Consistency | Uses codebase patterns to diversify reasoning paths |
| Generate-Knowledge | Retrieves domain knowledge from indexed codebase |
| Tree-of-Thoughts | Domain entities inform branch exploration |
| Graph-of-Thoughts | Architecture patterns enrich node connections |
| Problem-Analysis | Codebase structure guides decomposition |

**Pattern Extraction from RAG Context:**

The RAG engine extracts and provides:
- **Architectural Patterns**: Repository, Service, Factory, Observer, Strategy, MVVM, Clean Architecture
- **Domain Entities**: Structs, classes, protocols, enums from the codebase
- **Code Patterns**: REST API, Event-Driven, CRUD operations

---

## JUDGES CONFIGURATION

Zero-config: Claude (this session) + Apple Intelligence (on-device, macOS 26+). Optional additional judges via API keys: OpenAI (OPENAI_API_KEY), Gemini (GEMINI_API_KEY), Bedrock (AWS_ACCESS_KEY_ID + AWS_SECRET_ACCESS_KEY), OpenRouter (OPENROUTER_API_KEY).

---

## OUTPUT QUALITY CHECKLIST

**FINAL GATE — Before delivering PRD, I re-verify ALL HARD OUTPUT RULES (top of document) plus:**

**SQL DDL:**
- [ ] CREATE TABLE with constraints
- [ ] Foreign keys with ON DELETE
- [ ] CHECK constraints
- [ ] Custom ENUMs (each one referenced by a table column — no orphans)
- [ ] GIN index (full-text)
- [ ] HNSW index (vectors)
- [ ] Row-Level Security
- [ ] Materialized views
- [ ] No NOW()/CURRENT_TIMESTAMP in partial index WHERE clauses

**Domain Models:**
- [ ] All properties typed
- [ ] Static business rule constants
- [ ] Computed properties
- [ ] Throwing initializer
- [ ] Error enum with cases
- [ ] No AnyCodable/AnyEncodable/AnyDecodable (use concrete types or custom JSONValue)

**API:**
- [ ] Exact REST routes
- [ ] All CRUD + search
- [ ] Rate limits specified
- [ ] Auth requirements

**Requirements:**
- [ ] Numbered FR-001+
- [ ] Priority [P0/P1/P2]
- [ ] NFRs with metrics
- [ ] Every FR has Source column (User Request / Clarification QN / Codebase / Mockup / [SUGGESTED])
- [ ] No [SUGGESTED] FRs in main table (they go in separate "Suggested Additions" subsection)
- [ ] No invented requirements passed off as user-requested

**Acceptance Criteria (with KPIs):**
- [ ] Every AC uses GIVEN-WHEN-THEN format
- [ ] Every AC has quantified success metric
- [ ] Every AC has Baseline (or "N/A - new feature")
- [ ] Every AC has Target threshold
- [ ] Every AC has Measurement method (tool/dashboard/script)
- [ ] Every AC links to Business Goal (BG-XXX) or NFR
- [ ] Happy path, error, and edge case ACs present
- [ ] No vague words ("efficient", "fast", "proper")

**JIRA:**
- [ ] Story points (fibonacci)
- [ ] Task breakdowns
- [ ] Acceptance checkboxes
- [ ] SP totals verified (manually sum every story → must match stated total)
- [ ] No story depends on itself
- [ ] AC IDs match PRD AC-XXX numbering (no independent JIRA AC numbering)
- [ ] SP distribution is uneven (reflects real complexity differences)

**Architecture (Technical Spec):**
- [ ] Domain layer has ZERO framework imports
- [ ] Ports (protocols) defined in domain for all external deps
- [ ] Adapters implement ports (not the other way around)
- [ ] Composition root wires adapters to ports
- [ ] No service classes that mix business logic with I/O
- [ ] Architecture matches codebase patterns (if RAG context available)
- [ ] Code examples use injected ports (ClockPort, UUIDGeneratorPort), NOT Foundation types (Date(), UUID()) in domain layer

**Roadmap:**
- [ ] Phases with weeks
- [ ] SP per phase
- [ ] Total estimate

**Codebase Analysis (when codebase provided):**
- [ ] Codebase was actually analyzed (not skipped due to tool unavailability)
- [ ] PRD references real files, patterns, and metrics from the codebase
- [ ] In Cowork mode: local shared directory used first (Glob/Grep/Read), then WebFetch/WebSearch fallback, then ask user
- [ ] No generic assumptions where codebase data should be cited

**Verification Report:**
- [ ] Leads with structural integrity checks (not quality scores)
- [ ] Verdict taxonomy applied — NOT 100% PASS (some SPEC-COMPLETE, NEEDS-RUNTIME, or INCONCLUSIVE)
- [ ] NFR performance claims (latency, fps, throughput) use SPEC-COMPLETE or NEEDS-RUNTIME, not PASS
- [ ] Cost savings use conditional language against explicitly defined counterfactual
- [ ] Model-projected scores in separate section, clearly labeled as advisory
- [ ] No false precision (round to one decimal or whole percent)

**Test Traceability (tests file):**
- [ ] Every test name in traceability matrix (Part C) exists in test code (Parts A/B)
- [ ] Every AC-to-test mapping describes what the test actually tests (not a different behavior)
- [ ] AC mapped count matches reality (manually count)
- [ ] Performance tests use iteration-based p95 measurement, not single-run XCTest timeout
- [ ] Tests do not silently resolve open questions (OQ-XXX) — flag assumptions

**JIRA Cross-References:**
- [ ] Every "Impact: FR-XXX" in JIRA matches the correct FR in the PRD table
- [ ] Every AC reference in JIRA matches the correct AC in the PRD

**Self-Check (BLOCKING):**
- [ ] All 24 HARD OUTPUT RULES verified against final output
- [ ] Self-check result reported in chat summary

---

## BUSINESS KPIs (8 METRIC SYSTEMS)

**All PRD generation tracks measurable business value:**

| Metric System | Key KPIs | Baseline Comparison |
|---------------|----------|---------------------|
| **BusinessKPIs** | timeSavingsPercent, qualityImprovementPercent, costSavingsPercent, tokenEfficiencyRatio | Manual PRD: 4-8 hrs (industry avg), Structural checks: X/24 passed |
| **BaselineDefinitions** | ManualWritingTime, QualityBaseline, TokenBaseline, LLMCallBaseline | Industry benchmarks (documented) |
| **TemplateBusinessKPIs** | Template timeSavings, qualityImprovement, tokensSaved, templateHitRate | With vs without templates |
| **StrategyBusinessKPIs** | qualityImprovementPercent, costMultiplier, efficiencyScore, isWorthTheCost | vs zero-shot baseline |
| **VisionBusinessKPIs** | precision, recall, f1Score, timeSavingsPercent, costSavingsPercent | vs manual mockup docs (25 min/mockup) |
| **ReasoningEnhancementMetrics** | 30+ KPIs: accuracy, cost, efficiency, templates, stall recovery, signals | vs baseline strategies |
| **ProviderMetrics** | successRate, averageDuration, averageConfidence | Per-provider tracking |
| **StrategyEffectivenessTracker** | expectedImprovement vs actualGain, complianceRate | Research-based expectations |

Business KPI reports summarize time savings, quality improvement, cost efficiency, and token efficiency vs baselines.

---

## UPCOMING UNIQUE FEATURES (PHASE 8)

### Video-RAG Integration
- **Concept**: Use MP4 video frames as context retrieval alternative to vector DB
- **Research**: Based on VideoRAG (ACL 2025)
- **Approach**: Keyframe extraction → Vision embedding → Frame retrieval for PRD context
- **Use Case**: Video walkthroughs of features instead of text descriptions

### DeepSeek-OCR Context Compression
- **Concept**: 10x text compression via optical encoding for context memory
- **Research**: Based on DeepSeek-OCR — praised by Andrej Karpathy
- **Approach**: Recent PRDs = full text, older PRDs = compressed images (97% accuracy at 10x)
- **Use Case**: Infinite context memory without token limits

---

## VERSION HISTORY

- **v1.0.0**: Unified release — Dual-mode MCP server (CLI + Cowork), 5 utility tools, marketplace-ready plugin, unified naming as AI Architect PRD Generator
- **v7.0.0**: Phase 7 complete - Vision Engine + Business KPIs (8 metric systems) with documented baselines
- **v6.0.0**: Business KPIs research, Video-RAG research, DeepSeek-OCR research
- **v5.0.0**: VisionEngine (Apple Foundation Models, 180+ components, multi-provider)
- **v4.5.0**: Complete 8-type PRD context system (added CI/CD) - final template set for BAs and PMs
- **v4.4.0**: Extended context-aware PRD generation to 7 types (added poc/mvp/release)
- **v4.3.0**: Context-aware PRD generation (proposal/feature/bug/incident)
- **v4.2.0**: Real-time LLM streaming across all 15 thinking strategies
- **v4.1.0**: RAG integration for all 15 strategies + Research-based prioritization
- **v4.0.0**: Meta-Prompting Engine with 15 strategies + 6 cross-enhancement innovations + 30+ KPIs
- **v3.0.0**: Enterprise output + 6 verification algorithms
- **v2.0.0**: Contextual BM25 RAG (+49% precision)
- **v1.0.0**: Foundation

---

**PRD Context Types (8):**
- **Proposal**: 7 sections, business-focused, light RAG (1 hop)
- **Feature**: 11 sections, full technical depth, deep RAG (3 hops)
- **Bug**: 6 sections, root cause analysis, focused RAG (3 hops)
- **Incident**: 8 sections, forensic investigation, exhaustive RAG (4 hops)
- **POC**: 5 sections, feasibility validation, moderate RAG (2 hops)
- **MVP**: 8 sections, core value focus, moderate RAG (2 hops)
- **Release**: 10 sections, production readiness, deep RAG (3 hops)
- **CI/CD**: 9 sections, pipeline automation, deep RAG (3 hops)

**Features:** All 15 RAG-enhanced strategies with research-based prioritization, unlimited clarification, full verification engine, context-aware depth adaptation, all 8 PRD types.
