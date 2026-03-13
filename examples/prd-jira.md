# JIRA Tickets: Influencing LLM Multi-Agent Dialogue via Policy-Parameterized Prompts

**Project:** AI-PRD Builder
**Date:** 2026-03-12
**Total Story Points:** 34
**Estimated Duration:** 5 weeks (3 phases)

---

## EPIC-001: Policy Domain Foundation

**Epic SP Total:** 8 (STORY-001: 3 + STORY-002: 5)
**Priority:** P0
**Labels:** `domain-model`, `policy`, `foundation`

---

### STORY-001: Policy Domain Model (3 SP)

**Type:** Story | **Priority:** P0 | **SP:** 3
**Sprint:** Phase 1 (Week 1)
**Labels:** `domain-model`, `value-object`, `shared-utilities`

**User Story:**
As a pipeline operator, I want to define prompt policies as first-class domain objects with typed constraints, dialogue phase, and scope level, so that dialogue influence parameters are expressed declaratively rather than embedded in prompt strings.

**Acceptance Criteria:**

- **AC-001:** GIVEN a `PromptPolicy` with `policyId="sec-audit"`, `constraints.tone="analytical"`, `constraints.persona="security-auditor"`, `phase=.refinement`, `scopeLevel=.section`, `metadata=["domain":"security"]`, WHEN serialized to JSON, THEN payload < 2KB AND all fields round-trip correctly.
  - Baseline: N/A — new type
  - Target: 100% fidelity, < 2KB
  - Measurement: Unit test encode/decode + byte count
  - Impact: BG-001

- **AC-002:** GIVEN `DialoguePhase.convergence`, WHEN accessing `systemDirective`, THEN returned string contains convergence-specific language AND all 4 phases return distinct directives.
  - Baseline: N/A — new type
  - Target: 4 unique directive strings
  - Measurement: Unit test with Set count assertion
  - Impact: BG-002

- **AC-012:** GIVEN a `PromptPolicy` instance, WHEN accessed concurrently from 10 async tasks, THEN zero data races (Sendable conformance).
  - Baseline: N/A — new type
  - Target: Zero TSan violations
  - Measurement: Compile `-strict-concurrency=complete`
  - Impact: NFR-003

**Task Breakdown:**

| Task | Estimate |
|------|----------|
| Create `PromptPolicy.swift` with init, Codable, resolve() | 1 SP |
| Create `PolicyConstraints.swift`, `DialoguePhase.swift`, `PolicyScopeLevel.swift` | 1 SP |
| Write unit tests (serialization, directive distinctness, Sendable) | 1 SP |

**Dependencies:** None
**Depends On:** —

---

### STORY-002: Port Extensions for Policy Parameterization (5 SP)

**Type:** Story | **Priority:** P0 | **SP:** 5
**Sprint:** Phase 1 (Week 2)
**Labels:** `port`, `protocol-extension`, `backward-compat`

**User Story:**
As a meta-prompting engine consumer, I want to pass a PromptPolicy when executing thinking strategies and selecting few-shot examples, so that prompt construction incorporates policy constraints without modifying existing call sites.

**Acceptance Criteria:**

- **AC-003:** GIVEN `FewShotPromptPort.selectExamples(similarTo:count:category:policy:)` with `policy.phase=.refinement`, WHEN filtering from a mixed-phase corpus, THEN phase-matching examples are prioritized.
  - Baseline: Similarity-only selection
  - Target: Phase-matching prioritized
  - Measurement: Mock port with tagged corpus
  - Impact: BG-004

- **AC-004:** GIVEN `MetaPromptingEngineProtocol.executeStrategy(... promptPolicy: analyticalPolicy)` with `analyticalPolicy.constraints.tone="analytical"`, WHEN the prompt is built, THEN `"analytical"` appears before the problem statement.
  - Baseline: No policy in prompt
  - Target: Policy constraints in prompt
  - Measurement: Spy on AIProviderPort
  - Impact: BG-002

- **AC-005:** GIVEN existing call sites using `executeStrategy(problem:context:strategy:)`, WHEN compiled against updated protocols, THEN zero compilation errors and zero test failures.
  - Baseline: All compile, all pass
  - Target: All compile, all pass
  - Measurement: `swift build` + `swift test` all packages
  - Impact: BG-003

**Task Breakdown:**

| Task | Estimate |
|------|----------|
| Create `PolicyPromptComposerPort.swift` in SharedUtilities | 1 SP |
| Extend `FewShotPromptPort` with policy parameter + default extension | 1 SP |
| Extend `MetaPromptingEngineProtocol` with promptPolicy parameter + default extension | 1 SP |
| Verify backward compat: `swift build` all 9 packages | 1 SP |
| Write tests for default extension delegation | 1 SP |

**Dependencies:** STORY-001
**Depends On:** STORY-001

---

## EPIC-002: Policy-Aware Prompt Construction

**Epic SP Total:** 16 (STORY-003: 8 + STORY-004: 8)
**Priority:** P1
**Labels:** `adapter`, `prompt-composition`, `enhancement`

---

### STORY-003: Policy Prompt Composer Adapter (8 SP)

**Type:** Story | **Priority:** P1 | **SP:** 8
**Sprint:** Phase 2 (Week 3)
**Labels:** `adapter`, `meta-prompting`, `composition-root`

**User Story:**
As the enhancement orchestrator, I want a dedicated adapter that composes policy constraints into prompts following deterministic ordering, so that policy directives are consistently positioned regardless of which enhancement or strategy invokes composition.

**Acceptance Criteria:**

- **AC-006:** GIVEN `PolicyPromptComposer.compose(basePrompt:policy:phase:)` with full policy (persona, tone, directives, prohibitions), THEN output follows ordering: persona → tone → phase → base → prohibitions.
  - Baseline: N/A — new adapter
  - Target: Deterministic ordering across 10 configurations
  - Measurement: Unit test section ordering
  - Impact: BG-002

- **AC-010:** GIVEN `MetaPromptingEngine.executeStrategy(... promptPolicy: policy)` with `policy.policyId="sec-001"`, THEN `result.metadata["promptPolicyId"]=="sec-001"`.
  - Baseline: No policy fields in metadata
  - Target: Policy ID and phase in metadata
  - Measurement: Unit test metadata assertions
  - Impact: BG-001

- **AC-005 (empty policy):** GIVEN `PolicyPromptComposer.compose(basePrompt:policy:phase:)` with empty policy (all-nil constraints, nil phase), THEN returned string equals base prompt.
  - Baseline: N/A — new adapter
  - Target: Empty policy = identity function
  - Measurement: `#expect(result == basePrompt)`
  - Impact: BG-003

**Task Breakdown:**

| Task | Estimate |
|------|----------|
| Implement `PolicyPromptComposer` struct | 2 SP |
| Add `policyComposer` to `MetaPromptingEngine.init` | 1 SP |
| Implement `executeStrategy(... promptPolicy:)` with metadata recording | 2 SP |
| Wire in `MetaPromptingFactory` | 0.5 SP |
| Write BDD tests for ordering, metadata, identity | 2.5 SP |

**Dependencies:** STORY-002
**Depends On:** STORY-002

---

### STORY-004: Enhancement Stack Policy Threading (8 SP)

**Type:** Story | **Priority:** P1 | **SP:** 8
**Sprint:** Phase 2 (Week 4)
**Labels:** `enhancement`, `meta-prompting`, `threading`

**User Story:**
As the enhancement orchestrator, I want policy constraints threaded through each enhancement in the stack, so that collaborative inference, metacognitive monitoring, and TRM refinement all respect dialogue policy.

**Acceptance Criteria:**

- **AC-007:** GIVEN `EnhancementOrchestrator.executeWithFullStack(... promptPolicy: securityPolicy)` where `securityPolicy.constraints.persona="security-auditor"`, WHEN the full 5-enhancement stack runs, THEN each enhancement's prompt contains `"security-auditor"`.
  - Baseline: No policy through enhancements
  - Target: All 5 enhancements receive policy
  - Measurement: Spy executor capturing all invocations
  - Impact: BG-002

**Task Breakdown:**

| Task | Estimate |
|------|----------|
| Add `promptPolicy:` to `EnhancementOrchestrator.execute()` | 2 SP |
| Add `promptPolicy:` to `executeWithFullStack()` | 1 SP |
| Implement executor wrapping with policy composition | 2 SP |
| Write BDD tests verifying all 5 enhancements | 3 SP |

**Dependencies:** STORY-001, STORY-003
**Depends On:** STORY-001, STORY-003

---

## EPIC-003: Orchestration Integration & Observability

**Epic SP Total:** 10 (STORY-005: 5 + STORY-006: 5)
**Priority:** P1–P2
**Labels:** `orchestration`, `observability`, `integration`

---

### STORY-005: Orchestration Policy Propagation (5 SP)

**Type:** Story | **Priority:** P1 | **SP:** 5
**Sprint:** Phase 3 (Week 5)
**Labels:** `orchestration`, `propagation`, `strategy-selection`

**User Story:**
As a thinking orchestrator, I want automatic policy propagation from the orchestration layer to the meta-prompting engine and strategy selector, so that policy-driven dialogue influence is transparent to section generators.

**Acceptance Criteria:**

- **AC-008:** GIVEN `ThinkingOrchestratorUseCase.execute(... promptPolicy: analyticalPolicy)` with a MetaPromptingEngine spy, THEN the spy's `executeStrategy` call includes the policy.
  - Baseline: No policy forwarding
  - Target: Policy forwarded without modification
  - Measurement: Mock spy assertion
  - Impact: BG-002

- **AC-009:** GIVEN `SectionStrategySelector` with `preferredStrategies=["verifiedReasoning","chainOfThought"]`, WHEN selecting strategy for "technical", THEN those strategies get +0.15 boost.
  - Baseline: No policy influence on scores
  - Target: +0.15 for preferred
  - Measurement: Compare scores with/without policy
  - Impact: BG-002

**Task Breakdown:**

| Task | Estimate |
|------|----------|
| Add `promptPolicy:` to `ThinkingOrchestratorUseCase.execute()` | 1 SP |
| Forward policy to MetaPromptingEngine | 0.5 SP |
| Add `promptPolicy:` to `SectionStrategySelector.selectStrategy()` | 1 SP |
| Implement +0.15 boost for preferredStrategies | 1 SP |
| Write BDD tests | 1.5 SP |

**Dependencies:** STORY-002, STORY-004
**Depends On:** STORY-002, STORY-004

---

### STORY-006: Policy Observability & Hierarchy (5 SP)

**Type:** Story | **Priority:** P2 | **SP:** 5
**Sprint:** Phase 3 (Week 5)
**Labels:** `observability`, `hierarchy`, `testing`

**User Story:**
As a pipeline observer, I want policy metadata recorded on every LLM interaction and policy hierarchy resolved with deterministic merge semantics, so that dialogue influence is auditable and predictable.

**Acceptance Criteria:**

- **AC-011:** GIVEN a 4-level hierarchy `[global, engine, stage, section]` with mixed overrides, WHEN resolved via `PromptPolicy.resolve()`, THEN section tone wins, directives accumulate, preferredStrategies from section wins, AND resolution < 5ms at p95.
  - Baseline: N/A — new capability
  - Target: Correct merge + < 5ms at p95
  - Measurement: Unit test + 100-iteration benchmark
  - Impact: NFR-001, BG-001

**Task Breakdown:**

| Task | Estimate |
|------|----------|
| Comprehensive hierarchy resolution tests (4-level) | 2 SP |
| End-to-end metadata recording verification | 1.5 SP |
| Benchmark hierarchy resolution (100 iterations, p95) | 1 SP |
| Integration test: full pipeline path with policy | 0.5 SP |

**Dependencies:** STORY-001
**Depends On:** STORY-001

---

## Summary Table

| Epic | Story | SP | Sprint | Priority | Depends On |
|------|-------|----|--------|----------|------------|
| EPIC-001 | STORY-001: Policy Domain Model | 3 | Phase 1 / Week 1 | P0 | — |
| EPIC-001 | STORY-002: Port Extensions | 5 | Phase 1 / Week 2 | P0 | STORY-001 |
| EPIC-002 | STORY-003: PolicyPromptComposer | 8 | Phase 2 / Week 3 | P1 | STORY-002 |
| EPIC-002 | STORY-004: Enhancement Threading | 8 | Phase 2 / Week 4 | P1 | STORY-001, STORY-003 |
| EPIC-003 | STORY-005: Orchestration Propagation | 5 | Phase 3 / Week 5 | P1 | STORY-002, STORY-004 |
| EPIC-003 | STORY-006: Hierarchy & Observability | 5 | Phase 3 / Week 5 | P2 | STORY-001 |

**SP Verification:**
- EPIC-001: 3 + 5 = 8 ✓
- EPIC-002: 8 + 8 = 16 ✓
- EPIC-003: 5 + 5 = 10 ✓
- **Grand Total: 8 + 16 + 10 = 34 ✓**

**Sprint Distribution:** Phase 1: 8 SP | Phase 2: 16 SP | Phase 3: 10 SP (ratio 8:16:10 — uneven ✓)

---

## CSV Export

```csv
Epic,Story,Type,Priority,SP,Sprint,Depends On,Labels
EPIC-001,STORY-001: Policy Domain Model,Story,P0,3,Phase 1 / Week 1,,domain-model;value-object;shared-utilities
EPIC-001,STORY-002: Port Extensions,Story,P0,5,Phase 1 / Week 2,STORY-001,port;protocol-extension;backward-compat
EPIC-002,STORY-003: PolicyPromptComposer,Story,P1,8,Phase 2 / Week 3,STORY-002,adapter;meta-prompting;composition-root
EPIC-002,STORY-004: Enhancement Threading,Story,P1,8,Phase 2 / Week 4,STORY-001;STORY-003,enhancement;meta-prompting;threading
EPIC-003,STORY-005: Orchestration Propagation,Story,P1,5,Phase 3 / Week 5,STORY-002;STORY-004,orchestration;propagation;strategy-selection
EPIC-003,STORY-006: Hierarchy & Observability,Story,P2,5,Phase 3 / Week 5,STORY-001,observability;hierarchy;testing
```
