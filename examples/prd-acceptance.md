# Acceptance Criteria: Influencing LLM Multi-Agent Dialogue via Policy-Parameterized Prompts

## Acceptance Criteria with KPIs

### AC-001: PromptPolicy Serialization Fidelity

**Story:** STORY-001 | **FR:** FR-001 | **Priority:** P0

**GIVEN** a `PromptPolicy` with:
- `policyId = "sec-audit"`
- `constraints.tone = "analytical"`
- `constraints.persona = "security-auditor"`
- `constraints.directives = ["cite specific code locations", "prioritize security implications"]`
- `constraints.prohibitions = ["do not suggest breaking API changes"]`
- `constraints.preferredStrategies = ["verifiedReasoning", "chainOfThought"]`
- `phase = .refinement`
- `scopeLevel = .section`
- `metadata = ["domain": "security", "version": "1.0"]`

**WHEN** serialized to JSON via `JSONEncoder` and decoded via `JSONDecoder`

**THEN:**
- All fields round-trip to `.==` equal values
- Serialized byte count < 2048

| Metric | Baseline | Target | Measurement | Impact |
|--------|----------|--------|-------------|--------|
| Field fidelity | N/A — new type | 100% round-trip | Unit test: encode → decode → assert equal | BG-001 |
| Payload size | N/A — new type | < 2KB | `JSONEncoder().encode(policy).count < 2048` | NFR-004 |

---

### AC-002: DialoguePhase System Directives

**Story:** STORY-001 | **FR:** FR-002 | **Priority:** P0

**GIVEN** `DialoguePhase.convergence`

**WHEN** accessing `systemDirective` computed property

**THEN** the returned string contains at least one of: "synthesize", "final", "commit", "concrete", "actionable"

**AND** each of the 4 phases (`.exploration`, `.refinement`, `.consensus`, `.convergence`) returns a distinct, non-empty directive string.

| Metric | Baseline | Target | Measurement | Impact |
|--------|----------|--------|-------------|--------|
| Directive distinctness | N/A — new type | 4 unique non-empty strings | Unit test: `Set` of all directives has count 4 | BG-002 |

---

### AC-003: Policy-Filtered Few-Shot Example Selection

**Story:** STORY-002 | **FR:** FR-004 | **Priority:** P0

**GIVEN** `FewShotPromptPort.selectExamples(similarTo: "analyze security", count: 5, category: "security", policy: refinementPolicy)` where `refinementPolicy.phase = .refinement`

**WHEN** the adapter filters examples from a corpus containing:
- 3 examples with `metadata["dialoguePhase"] = "refinement"`
- 5 examples with `metadata["dialoguePhase"] = "exploration"`
- 2 examples with no phase metadata

**THEN** the returned examples prioritize phase-matching examples (refinement-tagged first), filling remaining slots from untagged examples if needed.

| Metric | Baseline | Target | Measurement | Impact |
|--------|----------|--------|-------------|--------|
| Phase relevance | No phase filtering (similarity only) | Phase-matching examples prioritized | Mock port with tagged corpus; assert ordering | BG-004 |

---

### AC-004: Policy Constraints in Strategy Prompt

**Story:** STORY-002 | **FR:** FR-005 | **Priority:** P0

**GIVEN** `MetaPromptingEngineProtocol.executeStrategy(problem: "Analyze module coupling", context: "SwiftUI app with 3 modules", strategy: .chainOfThought, researchContext: nil, promptPolicy: analyticalPolicy)` where `analyticalPolicy.constraints.tone = "analytical"` and `analyticalPolicy.constraints.persona = "architect"`

**WHEN** the engine builds and sends the prompt to `AIProviderPort.generateText`

**THEN** the prompt string contains both `"analytical"` and `"architect"` positioned before the problem statement `"Analyze module coupling"`.

| Metric | Baseline | Target | Measurement | Impact |
|--------|----------|--------|-------------|--------|
| Policy in prompt | No policy in prompt context | Policy constraints present before problem | Spy AIProviderPort; assert substring positions | BG-002 |

---

### AC-005: Backward Compatibility Preservation

**Story:** STORY-002 | **FR:** FR-004, FR-005 | **Priority:** P0

**GIVEN** all existing call sites using:
- `executeStrategy(problem:context:strategy:)`
- `executeStrategy(problem:context:strategy:researchContext:)`
- `selectExamples(similarTo:count:category:)`

**WHEN** compiled against updated protocols with new policy-accepting overloads

**THEN:**
- Zero compilation errors across all 9 packages
- Zero existing test failures
- Default protocol extensions provide nil policy to new method signatures

| Metric | Baseline | Target | Measurement | Impact |
|--------|----------|--------|-------------|--------|
| Compilation | All packages compile | All packages compile (zero new errors) | `swift build` for all packages | BG-003 |
| Test suite | All tests pass | All tests pass (zero new failures) | `swift test` for all packages | BG-003 |

---

### AC-006: Deterministic Prompt Composition Ordering

**Story:** STORY-003 | **FR:** FR-007 | **Priority:** P1

**GIVEN** `PolicyPromptComposer.compose(basePrompt: "Analyze this code", policy: fullPolicy, phase: .refinement)` where `fullPolicy` has:
- `constraints.persona = "domain-expert"`
- `constraints.tone = "precise"`
- `constraints.directives = ["cite sources"]`
- `constraints.prohibitions = ["avoid speculation"]`

**WHEN** the composer generates the output

**THEN** the output follows strict ordering:
1. `[Persona]` section (contains "domain-expert")
2. `[Tone]` section (contains "precise")
3. `[Phase: refinement]` section (contains phase.systemDirective)
4. Base prompt ("Analyze this code")
5. `[Constraints — Do NOT]` section (contains "avoid speculation")

| Metric | Baseline | Target | Measurement | Impact |
|--------|----------|--------|-------------|--------|
| Ordering consistency | N/A — new adapter | Verified across 10 policy variations | Unit test: index-based section ordering assertions | BG-002 |

---

### AC-007: Full Enhancement Stack Policy Threading

**Story:** STORY-004 | **FR:** FR-008 | **Priority:** P1

**GIVEN** `EnhancementOrchestrator.executeWithFullStack(problem: "Design API", context: "REST service", promptPolicy: securityPolicy, baseExecutor: spyExecutor)` where `securityPolicy.constraints.persona = "security-auditor"`

**WHEN** the full 5-enhancement stack runs (ThoughtBuffer → AdaptiveExpansion → CollaborativeInference → Metacognitive → TRM)

**THEN** the `spyExecutor` captures that all invocations received a context string containing `"security-auditor"`.

| Metric | Baseline | Target | Measurement | Impact |
|--------|----------|--------|-------------|--------|
| Policy propagation | No policy through enhancements | All enhancement prompts contain policy | Spy executor: assert all captured contexts contain persona | BG-002 |

---

### AC-008: Orchestrator-to-Engine Policy Forwarding

**Story:** STORY-005 | **FR:** FR-009 | **Priority:** P1

**GIVEN** `ThinkingOrchestratorUseCase.execute(problem: "Design auth", sectionType: "technical", promptPolicy: analyticalPolicy)` with a `MetaPromptingEngineProtocol` mock spy

**WHEN** orchestration completes

**THEN** the spy's captured `executeStrategy` invocation includes `promptPolicy` equal to `analyticalPolicy`.

| Metric | Baseline | Target | Measurement | Impact |
|--------|----------|--------|-------------|--------|
| Policy forwarding | No policy parameter exists | Policy forwarded without modification | Mock spy: assert captured policy == input policy | BG-002 |

---

### AC-009: Policy-Driven Strategy Boost

**Story:** STORY-005 | **FR:** FR-010 | **Priority:** P2

**GIVEN** `SectionStrategySelector.selectStrategy(for: "technical", problem: "Design API", context: "...", promptPolicy: boostPolicy)` where `boostPolicy.constraints.preferredStrategies = ["verifiedReasoning", "chainOfThought"]`

**WHEN** the selector computes strategy scores

**THEN** `verifiedReasoning` and `chainOfThought` each receive a +0.15 additive boost compared to the same call without a policy.

| Metric | Baseline | Target | Measurement | Impact |
|--------|----------|--------|-------------|--------|
| Score boost | No policy influence on scores | +0.15 for preferred strategies | Compare scores with/without policy; assert delta = 0.15 | BG-002 |

---

### AC-010: Policy Metadata in ThinkingResult

**Story:** STORY-006 | **FR:** FR-011 | **Priority:** P2

**GIVEN** `MetaPromptingEngine.executeStrategy(... promptPolicy: policy)` where `policy.policyId = "sec-001"` and `policy.phase = .refinement`

**WHEN** strategy execution completes and returns a `ThinkingResult`

**THEN:**
- `result.metadata["promptPolicyId"] == "sec-001"`
- `result.metadata["promptPolicyPhase"] == "refinement"`

| Metric | Baseline | Target | Measurement | Impact |
|--------|----------|--------|-------------|--------|
| Metadata presence | No policy fields in metadata | Both keys present with correct values | Unit test: assert metadata key/value pairs | BG-001 |

---

### AC-011: Policy Hierarchy Resolution

**Story:** STORY-006 | **FR:** FR-012 | **Priority:** P2

**GIVEN** a 4-level policy hierarchy:
- `globalPolicy`: tone="formal", directives=["be thorough"], scopeLevel=.global
- `enginePolicy`: persona="analyst", directives=["cite data"], scopeLevel=.engine
- `stagePolicy`: prohibitions=["no speculation"], scopeLevel=.stage
- `sectionPolicy`: tone="analytical", preferredStrategies=["verifiedReasoning"], scopeLevel=.section

**WHEN** resolved via `PromptPolicy.resolve([globalPolicy, enginePolicy, stagePolicy, sectionPolicy])`

**THEN:**
- `resolved.constraints.tone == "analytical"` (section overrides global)
- `resolved.constraints.persona == "analyst"` (engine-level, no higher override)
- `resolved.constraints.directives == ["be thorough", "cite data"]` (accumulated)
- `resolved.constraints.prohibitions == ["no speculation"]` (accumulated)
- `resolved.constraints.preferredStrategies == ["verifiedReasoning"]` (section wins entirely)
- Resolution time < 5ms at p95 (measured over 100 iterations)

| Metric | Baseline | Target | Measurement | Impact |
|--------|----------|--------|-------------|--------|
| Merge correctness | N/A — new capability | All merge semantics verified | Unit test: assert each field per merge rule | NFR-001, BG-001 |
| Resolution latency | N/A — new capability | < 5ms at p95 | 100 iterations, sort, assert index 95 < 5ms | NFR-001 |

---

### AC-012: Sendable Compliance Under Concurrency

**Story:** STORY-001 | **FR:** FR-001 | **Priority:** P0

**GIVEN** a `PromptPolicy` instance

**WHEN** passed concurrently to 10 tasks in a `TaskGroup`, each reading all fields

**THEN** the program compiles with `-strict-concurrency=complete` and exhibits zero data races under Thread Sanitizer.

| Metric | Baseline | Target | Measurement | Impact |
|--------|----------|--------|-------------|--------|
| Concurrency safety | N/A — new type | Sendable conformance, zero TSan violations | Compile flag + TSan CI gate | NFR-003 |

---

## HUMAN REVIEW REQUIRED

| Section | Reason | Reviewer | Deadline |
|---------|--------|----------|----------|
| Policy Constraints Design | Domain-specific tone/persona vocabulary may need alignment with organizational standards | Domain Expert / Product Owner | Before Sprint 2 start |
| Prompt Injection Surface | Policy fields composed into LLM prompts — security review of composition boundaries | Security Engineer | Before production deployment |