# Implementation Roadmap: Influencing LLM Multi-Agent Dialogue via Policy-Parameterized Prompts

## Phase Summary

| Phase | Weeks | Stories | SP | Focus |
|-------|-------|---------|-----|-------|
| Phase 1: Domain Foundation | 1–2 | STORY-001, STORY-002 | 8 | Value objects, port extensions, backward compat |
| Phase 2: Adapter & Enhancement | 3–4 | STORY-003, STORY-004 | 16 | PolicyPromptComposer, enhancement stack threading |
| Phase 3: Orchestration & Observability | 5 | STORY-005, STORY-006 | 10 | ThinkingOrchestrator propagation, hierarchy resolution |
| **Total** | **5 weeks** | **6 stories** | **34** | |

---

## Phase 1: Domain Foundation (Weeks 1–2, 8 SP)

### Week 1: Domain Value Objects (STORY-001, 3 SP)

**Package:** AIPRDSharedUtilities

| Task | File | Effort |
|------|------|--------|
| Create `PromptPolicy` struct with Sendable/Equatable/Codable conformance | `Domain/ValueObjects/Thinking/PromptPolicy.swift` | 1 SP |
| Create `PolicyConstraints` struct with all-optional initializer | `Domain/ValueObjects/Thinking/PolicyConstraints.swift` | 0.5 SP |
| Create `DialoguePhase` enum with `systemDirective` computed property | `Domain/ValueObjects/Thinking/DialoguePhase.swift` | 0.5 SP |
| Create `PolicyScopeLevel` enum with Comparable conformance | `Domain/ValueObjects/Thinking/PolicyScopeLevel.swift` | 0.25 SP |
| Implement `PromptPolicy.resolve(_:)` hierarchy merge | `Domain/ValueObjects/Thinking/PromptPolicy.swift` | 0.5 SP |
| Write unit tests for all domain types | Test target | 0.25 SP |

**Exit Criteria:** All domain types compile, tests pass, `swift build` succeeds for AIPRDSharedUtilities.

### Week 2: Port Extensions (STORY-002, 5 SP)

**Packages:** AIPRDSharedUtilities, AIPRDMetaPromptingEngine

| Task | File | Effort |
|------|------|--------|
| Create `PolicyPromptComposerPort` protocol | `Domain/Ports/PolicyPromptComposerPort.swift` | 1 SP |
| Extend `FewShotPromptPort` with `policy:` parameter + default extension | `Domain/Ports/FewShotPromptPort.swift` | 1 SP |
| Extend `MetaPromptingEngineProtocol` with `promptPolicy:` parameter + default extension | `MetaPromptingEngineProtocol.swift` | 1 SP |
| Verify backward compatibility: `swift build` all 9 packages | — | 1 SP |
| Write tests for default extension behavior (nil policy = existing behavior) | Test targets | 1 SP |

**Exit Criteria:** All packages compile without modification to existing call sites. Default extensions verified.

**Phase 1 Risks:**

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Default protocol extension conflicts with existing conformances | Low | High | Test all existing conformers compile and pass |
| PromptPolicy serialization exceeds 2KB with max fields | Low | Medium | Unit test with maximally-populated policy asserts < 2KB |

---

## Phase 2: Adapter & Enhancement (Weeks 3–4, 16 SP)

### Week 3: PolicyPromptComposer Adapter (STORY-003, 8 SP)

**Package:** AIPRDMetaPromptingEngine

| Task | File | Effort |
|------|------|--------|
| Implement `PolicyPromptComposer` conforming to `PolicyPromptComposerPort` | `Services/PolicyPromptComposer.swift` | 2 SP |
| Add `policyComposer: PolicyPromptComposerPort?` to `MetaPromptingEngine.init` | `MetaPromptingEngine.swift` | 1 SP |
| Implement `executeStrategy(... promptPolicy:)` in `MetaPromptingEngine` | `MetaPromptingEngine.swift` | 2 SP |
| Record policy metadata in `ThinkingResult.metadata` (FR-011) | `MetaPromptingEngine.swift` | 0.5 SP |
| Wire `PolicyPromptComposer` in `MetaPromptingFactory` | `Factories/MetaPromptingFactory.swift` | 0.5 SP |
| Write BDD tests for composition ordering, metadata recording | Test target | 2 SP |

**Exit Criteria:** PolicyPromptComposer passes all ordering tests. MetaPromptingEngine passes new + existing tests.

### Week 4: Enhancement Stack Threading (STORY-004, 8 SP)

**Package:** AIPRDMetaPromptingEngine

| Task | File | Effort |
|------|------|--------|
| Add `promptPolicy:` parameter to `EnhancementOrchestrator.execute()` | `Services/Enhancements/EnhancementOrchestrator.swift` | 2 SP |
| Add `promptPolicy:` parameter to `EnhancementOrchestrator.executeWithFullStack()` | `Services/Enhancements/EnhancementOrchestrator.swift` | 1 SP |
| Wrap `baseExecutor` with policy-composed context in enhancement dispatcher | `Services/Enhancements/EnhancementOrchestrator.swift` | 2 SP |
| Write BDD tests verifying all 5 enhancements receive policy context | Test target | 3 SP |

**Exit Criteria:** Full stack execution with policy passes. All existing enhancement tests still pass.

**Phase 2 Risks:**

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Enhancement internal prompts double-apply policy via nested executor wrapping | Medium | High | Test: assert policy appears exactly once per enhancement invocation |
| EnhancementOrchestrator generic constraint `RefinableResult` conflicts with policy threading | Low | Medium | Policy wrapping stays at executor level, not result level |

---

## Phase 3: Orchestration & Observability (Week 5, 10 SP)

### Week 5a: Orchestration Propagation (STORY-005, 5 SP)

**Package:** AIPRDOrchestrationEngine

| Task | File | Effort |
|------|------|--------|
| Add `promptPolicy:` to `ThinkingOrchestratorUseCase.execute()` | `ThinkingOrchestratorUseCase.swift` | 1 SP |
| Forward policy to `MetaPromptingEngine.executeStrategy()` | `ThinkingOrchestratorUseCase.swift` | 0.5 SP |
| Add `promptPolicy:` to `SectionStrategySelector.selectStrategy()` | `Services/PRD/SectionStrategySelector.swift` | 1 SP |
| Implement +0.15 additive boost for `preferredStrategies` | `Services/PRD/SectionStrategySelector.swift` | 1 SP |
| Write BDD tests for propagation and boost | Test target | 1.5 SP |

### Week 5b: Hierarchy & Observability (STORY-006, 5 SP)

**Package:** AIPRDSharedUtilities, AIPRDOrchestrationEngine

| Task | File | Effort |
|------|------|--------|
| Add `PromptPolicy.resolve(_:)` comprehensive tests (4-level hierarchy) | Test target | 2 SP |
| Verify metadata recording end-to-end (orchestrator → engine → result) | Test target | 1.5 SP |
| Benchmark hierarchy resolution: 100 iterations, assert p95 < 5ms | Test target | 1 SP |
| Integration test: full pipeline path with policy | Test target | 0.5 SP |

**Exit Criteria:** All orchestration tests pass. Hierarchy resolution < 5ms at p95. End-to-end policy metadata present in ThinkingResult.

**Phase 3 Risks:**

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| ThinkingOrchestratorUseCase already has many parameters — ergonomic concern | Medium | Low | Policy is optional nil-default; doesn't affect existing call sites |
| Strategy boost interacts with adaptive effectiveness weighting | Low | Medium | Boost is additive (+0.15) not multiplicative; capped by existing score normalization |

---

## Deployment Strategy

### Rollout Plan

1. **Internal testing (Week 5):** Deploy with nil policies; verify zero behavioral change
2. **Opt-in adoption (Week 6+):** Enable policy for specific pipeline runs via `PipelinePolicy` YAML
3. **Full integration:** Wire policy loading from `PolicySource.load()` → orchestrator

### Rollback Plan

- All new parameters have nil defaults — removing policy wiring in `MetaPromptingFactory` reverts to pre-change behavior
- No database migrations, no schema changes, no external service dependencies
- Git revert of composition root wiring is sufficient for full rollback

### Monitoring

- Existing `print("[MetaPrompting] ...")` observability pattern extended for policy events
- `ThinkingResult.metadata["promptPolicyId"]` enables post-hoc audit queries
- No new infrastructure required for monitoring

---

## Open Questions

| ID | Question | Impact | Owner | Deadline |
|----|----------|--------|-------|----------|
| OQ-001 | Should `PolicyConstraints.preferredStrategies` use `ThinkingStrategy` enum cases directly, or String names for forward compatibility? | FR-010 boost implementation | Tech Lead | Phase 1 start |
| OQ-002 | What is the maximum number of `directives` and `prohibitions` before prompt context window impact becomes significant? | NFR-004 payload size | ML Engineer | Phase 2 start |
| OQ-003 | Should policy hierarchy resolution be eager (resolved once at pipeline start) or lazy (resolved per-call)? | FR-012 performance characteristic | Architect | Phase 1 start |
| OQ-004 | Should `DialoguePhase` progression be automatic (based on enhancement position in stack) or explicitly set by caller? | FR-002 phase management | Product Owner | Phase 2 start |

---

## Appendix A: File Change Manifest

### New Files (6)

| File | Package | Type |
|------|---------|------|
| `Domain/ValueObjects/Thinking/PromptPolicy.swift` | SharedUtilities | Value Object |
| `Domain/ValueObjects/Thinking/PolicyConstraints.swift` | SharedUtilities | Value Object |
| `Domain/ValueObjects/Thinking/DialoguePhase.swift` | SharedUtilities | Value Object |
| `Domain/ValueObjects/Thinking/PolicyScopeLevel.swift` | SharedUtilities | Value Object |
| `Domain/Ports/PolicyPromptComposerPort.swift` | SharedUtilities | Port Protocol |
| `Services/PolicyPromptComposer.swift` | MetaPromptingEngine | Adapter |

### Modified Files (7)

| File | Package | Change Type |
|------|---------|-------------|
| `Domain/Ports/FewShotPromptPort.swift` | SharedUtilities | Add method + default extension |
| `MetaPromptingEngineProtocol.swift` | MetaPromptingEngine | Add method + default extension |
| `MetaPromptingEngine.swift` | MetaPromptingEngine | Add init param + method impl |
| `Services/Enhancements/EnhancementOrchestrator.swift` | MetaPromptingEngine | Add param to execute/executeWithFullStack |
| `ThinkingOrchestratorUseCase.swift` | OrchestrationEngine | Add param + forward policy |
| `Services/PRD/SectionStrategySelector.swift` | OrchestrationEngine | Add param + boost logic |
| `Factories/MetaPromptingFactory.swift` | library (Composition) | Wire PolicyPromptComposer |

### Must Not Change

| File | Reason |
|------|--------|
| `library/Package.swift` | No new dependencies |
| All engine `Package.swift` files | No new inter-package dependencies |
| `Makefile` | No build system changes |

## Appendix B: Dependency Graph Delta

```
Before:
  SharedUtilities ← MetaPromptingEngine ← OrchestrationEngine

After (same graph — no new edges):
  SharedUtilities ← MetaPromptingEngine ← OrchestrationEngine

  New types in SharedUtilities: PromptPolicy, PolicyConstraints, DialoguePhase, PolicyScopeLevel, PolicyPromptComposerPort
  New adapter in MetaPromptingEngine: PolicyPromptComposer
  Modified types in MetaPromptingEngine: MetaPromptingEngine, MetaPromptingEngineProtocol, EnhancementOrchestrator
  Modified types in OrchestrationEngine: ThinkingOrchestratorUseCase, SectionStrategySelector
```

No new package-level dependencies. No new edges in the engine dependency graph.