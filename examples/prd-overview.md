# PRD: Influencing LLM Multi-Agent Dialogue via Policy-Parameterized Prompts

**Finding ID:** ai-agents-tool-ecosystems_influencing-llm-multi-agent-dialogue-via
**Category:** Prompting
**Priority Score:** 0.86 | **Compound Impact Score:** 0.95
**Date:** 2026-03-12
**Status:** Draft
**Engines Affected:** MetaPromptingEngine (primary), OrchestrationEngine (secondary)

---

## Executive Summary

The AI-PRD Builder's multi-agent reasoning pipeline currently constructs prompts through ad hoc string assembly — research framework metadata is prepended to context strings, enhancement parameters are wired through closures, and dialogue-influencing constraints (tone, persona, phase directives) have no first-class representation. This finding introduces **PromptPolicy** as a domain value object that parameterizes prompt construction across the multi-agent dialogue lifecycle, enabling declarative policy-driven influence over how LLM agents frame their reasoning, select examples, and compose responses.

The existing infrastructure provides strong foundations: `ResearchFrameworkContext` parameterizes strategy execution by research origin, `ThinkingStrategyContext` adapts few-shot examples to codebase context, `EnhancementOrchestrator` stacks five research-backed enhancements, and `CollaborativeInferenceConfig` governs multi-path consensus. However, none of these mechanisms accept a unified policy envelope that could steer dialogue tone, constrain agent personas, or adapt behavior by dialogue phase (exploration → refinement → consensus → convergence). The result is that prompt influence is scattered across configuration objects rather than expressed through a coherent policy abstraction.

This PRD specifies the domain models, port extensions, adapter implementations, and integration points required to thread policy-parameterized prompts through the MetaPromptingEngine and OrchestrationEngine, with full backward compatibility and zero breaking changes to existing callers.

## Goals and Objectives

### Primary Goals

| ID | Goal | Success Metric | Business Impact |
|----|------|----------------|-----------------|
| BG-001 | Introduce `PromptPolicy` as a first-class domain concept for dialogue influence | All 12 FRs implemented with passing tests | Enables declarative prompt steering without code changes |
| BG-002 | Thread policy parameterization through the MetaPromptingEngine strategy execution pipeline | Policy constraints appear in generated prompts when policy is provided | Improved PRD section quality through targeted dialogue framing |
| BG-003 | Maintain full backward compatibility with existing callers | Zero existing test failures after integration | No regression risk for current pipeline consumers |
| BG-004 | Enable policy-driven few-shot example selection | Examples filtered by dialogue phase and agent role when policy is specified | More contextually relevant in-context learning |

### Non-Goals

- **Runtime policy hot-reloading** — Policies are resolved at call time from the hierarchy; live mutation during execution is out of scope.
- **Policy authoring UI** — This PRD covers the domain model and engine integration; no UI for policy creation.
- **VerificationEngine policy integration** — The debate judge system (`DebatePromptBuilder`, `DebateJudgeEvaluator`) already has round-aware prompt construction; policy integration for verification is a separate finding.
- **New LLM provider capabilities** — `AIProviderPort` is not modified; policy composition happens before the provider call, not inside it.

## Scope

### In Scope

| Package | Changes |
|---------|---------|
| AIPRDSharedUtilities | New value objects (`PromptPolicy`, `DialoguePhase`, `PolicyConstraints`, `PolicyScopeLevel`), new port (`PolicyPromptComposerPort`), extensions to `FewShotPromptPort` |
| AIPRDMetaPromptingEngine | Protocol extension (`MetaPromptingEngineProtocol`), adapter implementation (`PolicyPromptComposer`), `EnhancementOrchestrator` policy threading |
| AIPRDOrchestrationEngine | `ThinkingOrchestratorUseCase` policy propagation, `SectionStrategySelector` policy-driven boosting, `StrategyEngineAdapter` policy forwarding |
| library (Composition) | Factory wiring for `PolicyPromptComposer` in `MetaPromptingFactory` |

### Out of Scope

- AIPRDVerificationEngine (debate policy is a separate finding)
- AIPRDRAGEngine (no direct prompt policy surface)
- AIPRDStrategyEngine (consumed via adapter; no direct modification needed)
- AIPRDEncryptionEngine, AIPRDVisionEngine, AIPRDAuditFlagEngine (unaffected)
- Package.swift files (no dependency changes — all new types in existing packages)