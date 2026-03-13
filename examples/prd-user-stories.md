# User Stories: Influencing LLM Multi-Agent Dialogue via Policy-Parameterized Prompts

## Story Map

| Epic | Stories | Total SP |
|------|---------|----------|
| EPIC-001: Policy Domain Foundation | STORY-001, STORY-002 | 8 |
| EPIC-002: Policy-Aware Prompt Construction | STORY-003, STORY-004 | 16 |
| EPIC-003: Orchestration Integration & Observability | STORY-005, STORY-006 | 10 |
| **Grand Total** | **6 stories** | **34** |

---

## EPIC-001: Policy Domain Foundation (8 SP)

### STORY-001: Policy Domain Model (3 SP)

**As a** pipeline operator,
**I want to** define prompt policies as first-class domain objects with typed constraints, dialogue phase, and scope level,
**so that** dialogue influence parameters are expressed declaratively rather than embedded in prompt strings.

**Implements:** FR-001 (PromptPolicy), FR-002 (DialoguePhase), FR-003 (PolicyConstraints)

**Acceptance Criteria:**

- **AC-001:** GIVEN a `PromptPolicy` with `policyId="sec-audit"`, `constraints.tone="analytical"`, `constraints.persona="security-auditor"`, `phase=.refinement`, `scopeLevel=.section`, and `metadata=["domain": "security"]`, WHEN serialized to JSON via `JSONEncoder`, THEN the payload is < 2KB AND when decoded via `JSONDecoder` all fields round-trip to equal values.
  - **Baseline:** N/A — new capability
  - **Target:** 100% field round-trip fidelity, < 2KB serialized
  - **Measurement:** Unit test with `JSONEncoder`/`JSONDecoder` + byte count assertion
  - **Business Impact:** BG-001

- **AC-012:** GIVEN a `PromptPolicy` instance created on the main actor, WHEN accessed concurrently from 10 async tasks via `TaskGroup`, THEN no data races occur (Sendable conformance enforced at compile time).
  - **Baseline:** N/A — new type
  - **Target:** Zero TSan violations
  - **Measurement:** Compile with `-strict-concurrency=complete`; Thread Sanitizer in CI
  - **Business Impact:** NFR-003

- **AC-002:** GIVEN `DialoguePhase.convergence`, WHEN accessing `systemDirective` computed property, THEN the returned string contains convergence-specific language (e.g., "synthesize", "final", "commit").
  - **Baseline:** N/A — new capability
  - **Target:** Each of 4 phases returns distinct, non-empty directive text
  - **Measurement:** Unit test asserting each phase's directive contains expected keywords
  - **Business Impact:** BG-002

---

### STORY-002: Port Extensions for Policy Parameterization (5 SP)

**As a** meta-prompting engine consumer,
**I want to** pass a PromptPolicy when executing thinking strategies and selecting few-shot examples,
**so that** prompt construction incorporates policy constraints without modifying existing call sites.

**Implements:** FR-004 (FewShotPromptPort), FR-005 (MetaPromptingEngineProtocol), FR-006 (PolicyPromptComposerPort)

**Acceptance Criteria:**

- **AC-003:** GIVEN `FewShotPromptPort.selectExamples(similarTo: "analyze security", count: 5, category: "security", policy: refinementPolicy)` where `refinementPolicy.phase = .refinement`, WHEN the adapter filters examples, THEN only examples whose metadata includes a `"dialoguePhase"` key matching `"refinement"` are returned (or all examples if none are phase-tagged).
  - **Baseline:** Current `selectExamples` returns examples by similarity only (no phase filtering)
  - **Target:** Phase-matching examples returned when available; graceful fallback otherwise
  - **Improvement:** Policy-relevant example selection vs. generic selection
  - **Measurement:** Unit test with mock port returning phase-tagged and untagged examples
  - **Business Impact:** BG-004

- **AC-004:** GIVEN `MetaPromptingEngineProtocol.executeStrategy(problem: "...", context: "...", strategy: .chainOfThought, researchContext: nil, promptPolicy: analyticalPolicy)` where `analyticalPolicy.constraints.tone = "analytical"`, WHEN the engine builds the internal prompt, THEN the prompt string sent to `AIProviderPort.generateText` contains the substring `"analytical"` positioned before the problem statement.
  - **Baseline:** Current `executeStrategy` has no policy parameter; prompt contains only research context + problem
  - **Target:** Policy constraints injected into prompt context
  - **Improvement:** Policy-driven prompt framing vs. static framing
  - **Measurement:** Spy on `AIProviderPort.generateText` captured prompt; assert substring ordering
  - **Business Impact:** BG-002

- **AC-005:** GIVEN any existing call site using `executeStrategy(problem:context:strategy:)` or `executeStrategy(problem:context:strategy:researchContext:)`, WHEN compiled against the updated protocol, THEN compilation succeeds with zero changes (default protocol extension provides nil policy).
  - **Baseline:** All existing call sites compile and pass tests
  - **Target:** Zero compilation errors, zero test failures
  - **Improvement:** N/A — backward compatibility preservation
  - **Measurement:** Full `swift build` + `swift test` across all 9 packages
  - **Business Impact:** BG-003

---

## EPIC-002: Policy-Aware Prompt Construction (16 SP)

### STORY-003: Policy Prompt Composer Adapter (8 SP)

**As the** enhancement orchestrator,
**I want** a dedicated adapter that composes policy constraints into prompts following a deterministic ordering,
**so that** policy directives are consistently positioned regardless of which enhancement or strategy invokes composition.

**Implements:** FR-007 (PolicyPromptComposer)

**Acceptance Criteria:**

- **AC-006:** GIVEN `PolicyPromptComposer.compose(basePrompt: "Analyze this code", policy: expertPolicy, phase: .refinement)` where `expertPolicy.constraints.persona = "domain-expert"` and `expertPolicy.constraints.tone = "precise"`, THEN the returned string follows the ordering: persona directive → tone directive → phase system directive → base prompt → prohibitions footer.
  - **Baseline:** N/A — new adapter
  - **Target:** Deterministic ordering verified across 10 policy configurations
  - **Measurement:** Unit test: split output by known delimiters, verify ordering
  - **Business Impact:** BG-002

- **AC-005 (partial):** GIVEN `PolicyPromptComposer.compose(basePrompt: "Analyze this code", policy: emptyPolicy, phase: nil)` where `emptyPolicy` has all-nil constraints, THEN the returned string equals the base prompt with no additions.
  - **Baseline:** N/A — new adapter
  - **Target:** Empty policy = identity function on prompt
  - **Measurement:** Unit test: `#expect(result == basePrompt)`
  - **Business Impact:** BG-003

---

### STORY-004: Enhancement Stack Policy Threading (8 SP)

**As the** enhancement orchestrator,
**I want** policy constraints threaded through each enhancement in the stack,
**so that** collaborative inference, metacognitive monitoring, and TRM refinement all respect dialogue policy.

**Implements:** FR-008 (EnhancementOrchestrator threading)

**Acceptance Criteria:**

- **AC-007:** GIVEN `EnhancementOrchestrator.executeWithFullStack(problem: "...", context: "...", promptPolicy: securityPolicy, baseExecutor: executor)` where `securityPolicy.constraints.persona = "security-auditor"`, WHEN the full 5-enhancement stack runs (ThoughtBuffer → AdaptiveExpansion → CollaborativeInference → Metacognitive → TRM), THEN each enhancement's internal prompt contains `"security-auditor"`.
  - **Baseline:** Current `executeWithFullStack` has no policy parameter; enhancements receive raw problem/context
  - **Target:** All 5 enhancements receive policy-composed prompts
  - **Improvement:** Policy propagation through entire enhancement stack vs. none
  - **Measurement:** Spy on `baseExecutor` closure; assert all 5 invocations contain persona text
  - **Business Impact:** BG-002

---

## EPIC-003: Orchestration Integration & Observability (10 SP)

### STORY-005: Orchestration Policy Propagation (5 SP)

**As a** thinking orchestrator,
**I want** automatic policy propagation from the orchestration layer to the meta-prompting engine and strategy selector,
**so that** policy-driven dialogue influence is transparent to section generators.

**Implements:** FR-009 (ThinkingOrchestratorUseCase), FR-010 (SectionStrategySelector boost)

**Acceptance Criteria:**

- **AC-008:** GIVEN `ThinkingOrchestratorUseCase.execute(problem: "...", sectionType: "technical", promptPolicy: analyticalPolicy)` with a `MetaPromptingEngineProtocol` spy, WHEN orchestration completes, THEN the spy's captured `executeStrategy` call includes `promptPolicy: analyticalPolicy`.
  - **Baseline:** Current `execute()` has no policy parameter; MetaPromptingEngine receives no policy
  - **Target:** Policy forwarded without modification
  - **Improvement:** End-to-end policy propagation vs. manual wiring
  - **Measurement:** Mock spy captures `promptPolicy` argument; assert equality
  - **Business Impact:** BG-002

- **AC-009:** GIVEN `SectionStrategySelector` with `analyticalPolicy.constraints.preferredStrategies = ["verifiedReasoning", "chainOfThought"]`, WHEN selecting strategy for a `"technical"` section type, THEN `verifiedReasoning` and `chainOfThought` each receive a +0.15 additive boost to their selection scores.
  - **Baseline:** Current strategy selection uses context boosts only; no policy influence
  - **Target:** Preferred strategies receive measurable boost
  - **Improvement:** +0.15 additive boost for policy-preferred strategies
  - **Measurement:** Unit test: compare scores with and without policy; assert delta = 0.15
  - **Business Impact:** BG-002

---

### STORY-006: Policy Observability & Hierarchy (5 SP)

**As a** pipeline observer,
**I want** policy metadata recorded on every LLM interaction and policy hierarchy resolved with deterministic merge semantics,
**so that** dialogue influence is auditable and predictable.

**Implements:** FR-011 (metadata recording), FR-012 (hierarchy resolution)

**Acceptance Criteria:**

- **AC-010:** GIVEN a `ThinkingResult` produced by `MetaPromptingEngine.executeStrategy(... promptPolicy: policy)` where `policy.policyId = "sec-001"`, THEN `result.metadata["promptPolicyId"] == "sec-001"` AND `result.metadata["promptPolicyPhase"]` equals the phase's raw value.
  - **Baseline:** Current `ThinkingResult.metadata` contains `"researchFrameworkId"` but no policy fields
  - **Target:** Policy ID and phase recorded in metadata
  - **Improvement:** Policy observability from zero to full audit trail
  - **Measurement:** Unit test: assert metadata keys and values
  - **Business Impact:** BG-001

- **AC-011:** GIVEN a 4-level policy hierarchy `[globalPolicy, enginePolicy, stagePolicy, sectionPolicy]` where `globalPolicy.constraints.tone = "formal"`, `enginePolicy.constraints.tone = nil`, `stagePolicy.constraints.tone = nil`, `sectionPolicy.constraints.tone = "analytical"`, WHEN resolved via `PromptPolicy.resolve(_:)`, THEN the resolved policy has `constraints.tone = "analytical"` (section wins) AND resolution completes in < 5ms at p95 (100 iterations).
  - **Baseline:** N/A — new capability
  - **Target:** Correct merge semantics + < 5ms at p95
  - **Measurement:** Unit test: verify merged fields; benchmark: 100 iterations, sort, assert position 95 < 5ms
  - **Business Impact:** NFR-001, BG-001