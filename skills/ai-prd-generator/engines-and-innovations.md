# Engines & Innovations — Verification and Quality Systems

## Claim Verification (6 Algorithms + 15 Strategies)

**Every claim is verified using BOTH verification algorithms AND reasoning strategies.**

### MANDATORY: Complete Claim and Hypothesis Log

**The verification report MUST log EVERY individual claim and hypothesis. No exceptions.**

| What Must Be Logged | ID Pattern | Required Fields |
|---------------------|------------|-----------------|
| Functional Requirements | FR-001, FR-002, ... | Algorithm, Strategy, **Verdict** (from Rule 15 taxonomy), Confidence, Evidence |
| Non-Functional Requirements | NFR-001, NFR-002, ... | Algorithm, Strategy, **Verdict**, Confidence, Evidence |
| Acceptance Criteria | AC-001, AC-002, ... | Algorithm, Strategy, **Verdict**, Confidence, Evidence |
| Assumptions | A-001, A-002, ... | Source, Impact, Validation Status |
| Risks | R-001, R-002, ... | Severity, Mitigation, Reviewer |
| User Stories | US-001, US-002, ... | Algorithm, Strategy, **Verdict**, Confidence |
| Technical Specifications | TS-001, TS-002, ... | Algorithm, Strategy, **Verdict**, Confidence |

**Verdict Assignment Rules:**
- FR traceability, AC completeness, structural compliance → **PASS** (verifiable from document)
- NFR with specific runtime metric (latency, fps, throughput, storage) AND a test method specified → **SPEC-COMPLETE**
- NFR with specific runtime metric but NO test method → **NEEDS-RUNTIME**
- Claim depending on an open question (OQ-XXX) → **INCONCLUSIVE**
- Claim that contradicts another claim or has arithmetic error → **FAIL** (fix before delivery)

**Rule: The verification report is INCOMPLETE if any claim or hypothesis is missing from the log.**

**Completeness Check (MANDATORY at end of report):** Include a table showing each category's total items, logged count, missing count, and pass/fail status. Also include a **verdict distribution summary**: how many PASS, SPEC-COMPLETE, NEEDS-RUNTIME, INCONCLUSIVE, FAIL. If 100% are PASS, the report fails Rule 15.

---

### Algorithm Usage per Claim Type

| Claim Type | Primary Algorithm | Primary Strategy | Fallback Strategy | Why |
|------------|-------------------|------------------|-------------------|-----|
| Functional (FR-*) | KS Adaptive Consensus | Plan-and-Solve | Tree-of-Thoughts | Decompose → verify parts |
| Non-Functional (NFR-*) | Complexity-Aware | ReAct | Reflexion | Action-based validation |
| Technical Spec | Multi-Agent Debate | Tree-of-Thoughts | Graph-of-Thoughts | Multiple perspectives |
| Acceptance Criteria | Zero-LLM Graph | Self-Consistency | Collaborative Inference | Consistency check |
| User Stories | Atomic Decomposition | Few-Shot | Meta-Prompting | Pattern matching |

### Full Verification Log

**This log MUST be generated for EVERY claim, not just examples. The verification file contains the complete log of ALL claims.** Each claim entry includes: complexity score, algorithms used (with metrics), strategies used (with reasoning), **verdict from the 5-level taxonomy**, confidence range, and evidence. Assumptions include source, dependencies, impact if wrong, validation method, validator, and status. Risks include severity, probability, impact, mitigation, owner, and review status.

### Aggregate Metrics

**Algorithm Coverage:** Each of the 6 algorithms MUST show measurable contribution with claims processed, metric type, baseline, result, delta, and measurement method. Include an Algorithm Value Breakdown showing cost impact, accuracy impact, and what each algorithm does.

**Strategy Coverage:** Each of the 15 strategies MUST show claims processed, baseline confidence, final confidence, delta, and how it helped. If all strategies show positive deltas due to targeted routing, state: "Strategy assignment is optimized per-claim via research-weighted selection. Negative deltas are not expected in targeted routing — the selector avoids assigning strategies to claim types where they underperform." Include a Combined Effectiveness table comparing algorithms-only vs algorithms+strategies.

**Assumption & Hypothesis Tracking:** Log all assumptions with status (Validated/Pending/Needs Review/Invalidated), count, and examples. Log all risks with severity, count, and mitigation approval status.

**Cost Efficiency Analysis:** Show LLM calls, estimated cost, and verification time. Compare against an explicitly defined baseline with methodology stated. Use conditional language: "Compared to naive N-judge consensus (where N=3 judges evaluate every claim independently), the adaptive pipeline would use ~X% fewer calls." Do NOT present cost savings as fact against an unstated counterfactual.

**Issues Detected & Resolved:** Table of issue types (Orphan Requirements, Circular Dependencies, Contradictions, Ambiguities) with counts and resolutions.

**Quality Assurance Checklist:** Pass/fail status for each quality item.

**Enterprise Value Statement:** Table showing capabilities with verifiable gains across verification, consistency, RAG context, cost control, and audit trail.

---

## Limitations & Human Review Required

**Structural verification (SP arithmetic, graph checks, traceability) is deterministic and reproducible. Model-projected quality scores are advisory and self-assessed — they indicate internal consistency, NOT domain correctness.**

### What AI Verification CANNOT Validate:

| Area | Limitation | Required Human Action |
|------|------------|----------------------|
| Regulatory compliance | AI cannot interpret legal requirements | Legal review before implementation |
| Security architecture | Threat models need expert validation | Security engineer review |
| Business viability | Revenue/cost projections are estimates | Finance/stakeholder sign-off |
| Domain-specific rules | Industry regulations vary by jurisdiction | Domain expert review |
| Accessibility | WCAG compliance needs real user testing | Accessibility audit |

### Sections Flagged for Human Review:

| Section | Risk Level | Reason | Reviewer | Deadline |
|---------|------------|--------|----------|----------|
| [List sections with flags] | HIGH/MED | [Specific concern] | [Role] | [Before Sprint X] |

### Baselines Requiring Validation:

| Metric | Baseline Used | Source | Confidence | Action Needed |
|--------|---------------|--------|------------|---------------|
| [Metric] | [Value] | ESTIMATED/BENCHMARK | LOW | Measure in Sprint 0 |
| [Metric] | [Value] | MEASURED | HIGH | None |

### Assumptions Log:

All assumptions made during PRD generation that require stakeholder validation.

| ID | Assumption | Section | Impact if Wrong | Validator |
|----|------------|---------|-----------------|-----------|
| A-001 | [Assumption text] | [Section] | [Impact] | [Who validates] |

---

## PATENTABLE INNOVATIONS (12+ Features)

### Verification Engine (6 Innovations)

#### Algorithm 1: KS Adaptive Consensus

Stops verification early when judges agree, saving 30-50% LLM calls:
- Collect 3+ judge scores
- Calculate KS statistic (distribution stability)
- If stable (ks < 0.1 or variance < 0.02): STOP EARLY

#### Algorithm 2: Zero-LLM Graph Verification

FREE structural verification before expensive LLM calls:
- Build graph from claims and relationships
- Detect cycles (circular dependencies)
- Detect conflicts (contradictions)
- Find orphans (unimplemented requirements)
- Calculate importance via PageRank

#### Algorithm 3: Multi-Agent Debate

When judges disagree (variance > 0.1):
- Round 1: Independent evaluation
- Round 2+: Share opinions, ask for reassessment
- Stop when variance < 0.05 (converged)
- Max 3 rounds

#### Algorithm 4: Complexity-Aware Strategy Selection

Routes claims by complexity score: SIMPLE (< 0.30) basic verification, MODERATE (< 0.55) adds graph, COMPLEX (< 0.75) adds NLI entailment, CRITICAL (>= 0.75) activates multi-agent debate.

#### Algorithm 5: Atomic Claim Decomposition

Decompose content into verifiable atoms before verification:
- Self-contained (understandable alone)
- Factual (verifiable true/false)
- Atomic (cannot split further)

#### Algorithm 6: Unified Verification Pipeline

Every section goes through:
1. Complexity analysis → strategy selection
2. Atomic claim decomposition
3. Graph verification (FREE)
4. Judge evaluation with KS consensus
5. NLI entailment (if complex)
6. Debate (if critical + disagreement)
7. Final consensus

### Audit Flag Engine (Declarative Rules — 19 Families, 67 Rules)

Pattern-level quality signals that fill the gap between hard output rules (provably wrong, 0% FPR) and "everything else is PASS." Flags are metadata annotations — they NEVER change verdicts or scores.

**Architecture:** Standalone package (`AIPRDAuditFlagEngine`, Layer 1) with zero per-rule Swift code. All 67 rules are defined in 19 YAML files. Adding a rule = editing YAML. Adding a family = creating a new YAML file.

**Two rule types:**
- **Pattern rules (~80%):** Regex detect + context-aware suppress (same_row, nearby_lines, same_section, any_section) + claim counting
- **Pipeline rules (~20%):** Composable operations (extract → count → aggregate → ratio → flag_if) with NSPredicate condition evaluation

**19 Rule Families:**

| Code | Family | Rules | Primary Persona |
|------|--------|-------|-----------------|
| CITE | Citation Support | 3 | PM, BA |
| PREC | Precision Hygiene | 4 | QA, CTO |
| STAT | Statistical Plausibility | 4 | QA, CTO |
| MISMATCH | Verdict-Evidence Mismatch | 5 | QA, CTO |
| CONS | Cross-Section Consistency | 3 | QA, CTO |
| TEST | Testability | 5 | QA |
| BA | Business Analysis | 3 | BA |
| PO | Product Owner | 3 | PO |
| PM | Product Manager | 3 | PM |
| SM | Scrum Master | 3 | SM |
| STAKE | Stakeholder | 3 | Stakeholder |
| CEO | CEO | 2 | CEO |
| TECH | Technical Depth | 4 | CTO, Architect |
| DEV | Developer | 4 | Developer |
| OPS | Operations | 4 | DevOps |
| UX | UX | 3 | Designer |
| MLAI | ML/AI | 7 | ML Engineer |
| FREE | Freelancer | 2 | Freelancer |
| CM | Community | 2 | CM |

**Flag rate interpretation:** 0% on >5 claims = suspiciously clean; 10-20% = expected; >50% = needs work.

---

### Pipeline Architecture (Clean Architecture — 3 Packages)

The PRD builder follows **hexagonal/ports-and-adapters** architecture with three dedicated packages:

#### AIPRDPipelineDomain (Layer 0 — Pure Business Logic)
- **No dependencies** — zero external framework imports
- Defines domain models, value objects, and business rules
- Declares **ports** (protocols) for external dependencies
- Platform: macOS 26+ (Swift 6.2)
- **Principle:** Domain layer owns the interfaces, infrastructure implements them

#### AIPRDPipelineAdapters (Layer 1 — Infrastructure Implementations)
- **Depends on:** PipelineDomain only
- Implements domain ports with concrete adapters (file I/O, AI providers, databases)
- Includes embedded resources (prompts, config YAML)
- **Principle:** Adapters point inward to domain contracts, never the reverse

#### AIPRDPipelineIntelligenceEngine (Layer 1 — AI Orchestration)
- **Depends on:** PipelineDomain only
- Coordinates multi-step AI workflows using domain ports
- No direct framework dependencies — delegates to adapters via ports
- **Principle:** Use cases orchestrate entities and ports, stay framework-agnostic

**Wiring:** The Composition layer (in `library/Sources/Composition/`) wires adapters to ports at runtime. This ensures domain code can be tested without real I/O and can swap implementations (e.g., mock AI provider for tests, real Bedrock for production) without domain layer changes.

---

### Apple Intelligence Engine (Native Platform Integration)

#### AIPRDAppleIntelligenceEngine
- **Depends on:** SharedUtilities only
- Provides native Apple Intelligence API integration
- Platform: macOS 13+, iOS 16+ (Swift 5.9)
- **Capabilities:** On-device model inference, Apple ML framework integration
- **Use case:** Privacy-preserving AI features using Apple's Neural Engine

---

### Meta-Prompting Engine (6 Innovations)

#### Algorithm 7: Signal Bus Cross-Enhancement Coordination

Reactive pub/sub architecture for cross-enhancement communication:
- Enhancements publish signals (stall detected, consensus reached, confidence drop)
- Other enhancements subscribe and react in real-time
- Enables emergent coordination without hardcoded dependencies

#### Algorithm 8: Confidence Fusion with Learned Weights

Multi-source confidence aggregation with bias correction:
- Track per-source accuracy over time
- Learn optimal weights dynamically
- Apply bias correction based on historical over/under-confidence
- Produce calibrated final confidence with uncertainty bounds

#### Algorithm 9: Template-Guided Expansion

Buffer of Thoughts templates configure adaptive expansion:
- Templates specify depth modifier (0.8-1.2x)
- Templates control pruning aggressiveness
- High-confidence templates boost path scores
- Feedback loop: successful paths improve template weights

#### Algorithm 10: Cross-Enhancement Stall Recovery

When reasoning stalls, coordinated recovery:
- Metacognitive detects stall → emits signal
- Signal Bus notifies Buffer of Thoughts
- Template search for recovery patterns
- Adaptive Expansion applies recovery (depth increase, breadth expansion)
- Recovery success rate: >75%

#### Algorithm 11: Bidirectional Feedback Loops

Templates <-> Expansion <-> Metacognitive <-> Collaborative:
- Each enhancement produces feedback events
- Events flow bidirectionally through Signal Bus
- System learns from cross-enhancement outcomes
- Enables continuous self-improvement

#### Algorithm 12: Verifiable KPIs (ReasoningEnhancementMetrics)

30+ metrics for patentability evidence:

| Category | Metrics | Expected Gains |
|----------|---------|----------------|
| Accuracy | confidenceGainPercent, fusedConfidencePoint | +12-22% |
| Cost | tokenSavingsPercent, llmCallSavingsPercent | 35-55% |
| Efficiency | earlyTerminationRate, iterationsSaved | 40-60% |
| Templates | templateHitRate, avgTemplateRelevance | >60% |
| Stall Recovery | stallRecoveryRate, recoveryMethodsUsed | >75% |
| Signals | signalEffectivenessRate, crossEnhancementEvents | >60% |

---

### Strategy Engine (5 Innovations) - Phase 5

**Core Innovation:** Encodes peer-reviewed research findings as selection criteria, forcing research-optimal strategies instead of allowing LLM preference/bias.

**Research Sources:** MIT, Stanford, Harvard, ETH Zurich, Princeton, Google, Anthropic, OpenAI, DeepSeek (2023-2025)

#### Algorithm 13: Research Evidence Database

Machine-readable database of peer-reviewed findings:
- Strategy effectiveness benchmarks with confidence intervals
- Claim characteristic mappings
- Research-backed tier assignments
- Citation tracking for audit trails

| Strategy | Research Source | Benchmark Improvement |
|----------|----------------|----------------------|
| TRM/Extended Thinking | DeepSeek R1, OpenAI o1 | +32-74% on MATH/AIME |
| Verified Reasoning | Stanford/Anthropic CoV | +18% factuality |
| Graph-of-Thoughts | ETH Zurich | +62% on complex tasks |
| Self-Consistency | Google Research | +17.9% on GSM8K |
| Reflexion | MIT/Northeastern | +21% on HumanEval |

#### Algorithm 14: Research-Weighted Selector

Data-driven strategy selection based on claim analysis:
- Analyzes claim characteristics (complexity, domain, structure)
- Matches to research evidence for optimal strategy
- Calculates weighted scores based on peer-reviewed improvements
- Returns ranked strategy assignments with expected improvement

#### Algorithm 15: Strategy Enforcement Engine

Injects strategy guidance directly into prompts:
- Builds structured prompt sections for required strategies
- Adds validation rules for response structure
- Calculates overhead and compliance requirements
- Supports strict, conservative, and lenient modes

#### Algorithm 16: Strategy Compliance Validator

Validates LLM responses follow required strategy structure:
- Checks for required structural elements
- Detects violations with severity levels
- Triggers retry prompts for non-compliant responses
- Supports configurable strictness levels

#### Algorithm 17: Strategy Effectiveness Tracker

Feedback loop for continuous improvement:
- Records actual confidence gains vs expected
- Detects underperformance (>15% below expected)
- Detects overperformance (>15% above expected)
- Generates effectiveness reports for strategy tuning

**KPIs Tracked:**

| Metric | Description | Expected |
|--------|-------------|----------|
| Strategy Hit Rate | Correct strategy selected | >85% |
| Compliance Rate | Responses follow structure | >90% |
| Improvement Delta | Actual vs expected gain | +/-10% |
| Underperformance Alerts | Strategy not working | <5% |
