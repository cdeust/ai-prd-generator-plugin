# Technical Specification: Influencing LLM Multi-Agent Dialogue via Policy-Parameterized Prompts

## Architecture Overview

This feature follows the project's ports/adapters (hexagonal) architecture. All new types adhere to the dependency rule: source code dependencies point inward toward the domain layer.

```
┌─────────────────────────────────────────────────────────────┐
│                    Composition Root                          │
│  library/Sources/Composition/Factories/                     │
│  MetaPromptingFactory.swift (wires PolicyPromptComposer)    │
├─────────────────────────────────────────────────────────────┤
│                    Adapter Layer                             │
│  MetaPromptingEngine/                                       │
│    PolicyPromptComposer.swift (implements port)             │
│    MetaPromptingEngine.swift (uses port)                    │
│    EnhancementOrchestrator.swift (threads policy)           │
│  OrchestrationEngine/                                       │
│    ThinkingOrchestratorUseCase.swift (propagates policy)    │
│    SectionStrategySelector.swift (policy boost)             │
│    StrategyEngineAdapter.swift (forwards policy)            │
├─────────────────────────────────────────────────────────────┤
│                    Domain Layer (Ports)                      │
│  SharedUtilities/Domain/Ports/                              │
│    PolicyPromptComposerPort.swift (NEW)                     │
│    FewShotPromptPort.swift (EXTENDED)                       │
│  MetaPromptingEngine/                                       │
│    MetaPromptingEngineProtocol.swift (EXTENDED)             │
├─────────────────────────────────────────────────────────────┤
│                    Domain Layer (Entities/VOs)               │
│  SharedUtilities/Domain/ValueObjects/Thinking/              │
│    PromptPolicy.swift (NEW)                                 │
│    DialoguePhase.swift (NEW)                                │
│    PolicyConstraints.swift (NEW)                            │
│    PolicyScopeLevel.swift (NEW)                             │
└─────────────────────────────────────────────────────────────┘
```

**Dependency Rule Compliance:**
- Domain value objects import only Foundation
- Ports reference only domain types (PromptPolicy, DialoguePhase)
- Adapters depend inward on ports; never on other adapters
- Composition root is the only place concrete types are instantiated

## Domain Models

### PromptPolicy (Value Object)

**Location:** `packages/AIPRDSharedUtilities/Sources/Domain/ValueObjects/Thinking/PromptPolicy.swift`

```swift
import Foundation

/// A first-class policy envelope that parameterizes prompt construction
/// across the multi-agent dialogue lifecycle.
///
/// Follows the existing parameterization pattern established by
/// `ResearchFrameworkContext` (frameworkId + researchBasis + preferredEnhancement).
public struct PromptPolicy: Sendable, Equatable, Codable {
    public let policyId: String
    public let constraints: PolicyConstraints
    public let phase: DialoguePhase?
    public let scopeLevel: PolicyScopeLevel
    public let metadata: [String: String]

    public init(
        policyId: String,
        constraints: PolicyConstraints = PolicyConstraints(),
        phase: DialoguePhase? = nil,
        scopeLevel: PolicyScopeLevel = .global,
        metadata: [String: String] = [:]
    ) {
        self.policyId = policyId
        self.constraints = constraints
        self.phase = phase
        self.scopeLevel = scopeLevel
        self.metadata = metadata
    }

    /// Resolves a hierarchy of policies into a single merged policy.
    /// Merge semantics:
    /// - `tone`, `persona`: last-writer-wins (highest specificity)
    /// - `directives`, `prohibitions`: union (accumulate)
    /// - `preferredStrategies`: highest-specificity level wins entirely
    /// - `phase`: highest-specificity non-nil wins
    /// - `policyId`: joined with "/" separator
    /// - `metadata`: merged, higher specificity wins per key
    public static func resolve(_ policies: [PromptPolicy]) -> PromptPolicy {
        guard !policies.isEmpty else {
            return PromptPolicy(policyId: "empty")
        }
        let sorted = policies.sorted { $0.scopeLevel < $1.scopeLevel }
        var mergedTone: String?
        var mergedPersona: String?
        var mergedDirectives: [String] = []
        var mergedProhibitions: [String] = []
        var mergedStrategies: [String] = []
        var mergedPhase: DialoguePhase?
        var mergedMetadata: [String: String] = [:]

        for policy in sorted {
            if let tone = policy.constraints.tone { mergedTone = tone }
            if let persona = policy.constraints.persona { mergedPersona = persona }
            mergedDirectives.append(contentsOf: policy.constraints.directives)
            mergedProhibitions.append(contentsOf: policy.constraints.prohibitions)
            if !policy.constraints.preferredStrategies.isEmpty {
                mergedStrategies = policy.constraints.preferredStrategies
            }
            if let phase = policy.phase { mergedPhase = phase }
            mergedMetadata.merge(policy.metadata) { _, new in new }
        }

        return PromptPolicy(
            policyId: sorted.map(\.policyId).joined(separator: "/"),
            constraints: PolicyConstraints(
                tone: mergedTone,
                persona: mergedPersona,
                directives: mergedDirectives,
                prohibitions: mergedProhibitions,
                preferredStrategies: mergedStrategies
            ),
            phase: mergedPhase,
            scopeLevel: sorted.last?.scopeLevel ?? .global,
            metadata: mergedMetadata
        )
    }
}
```

### PolicyConstraints (Value Object)

**Location:** `packages/AIPRDSharedUtilities/Sources/Domain/ValueObjects/Thinking/PolicyConstraints.swift`

```swift
import Foundation

/// Dialogue-influencing constraints carried by a PromptPolicy.
/// All fields are optional to enable incremental override in the policy hierarchy.
public struct PolicyConstraints: Sendable, Equatable, Codable {
    /// Desired response tone (e.g., "analytical", "creative", "precise", "adversarial").
    public let tone: String?

    /// Agent persona to adopt (e.g., "security-auditor", "domain-expert", "devil's-advocate").
    public let persona: String?

    /// Positive directives injected into the prompt (e.g., "cite specific code locations").
    public let directives: [String]

    /// Negative constraints appended as prohibitions (e.g., "do not suggest breaking changes").
    public let prohibitions: [String]

    /// Strategy names that should receive a selection boost (e.g., ["verifiedReasoning"]).
    public let preferredStrategies: [String]

    public init(
        tone: String? = nil,
        persona: String? = nil,
        directives: [String] = [],
        prohibitions: [String] = [],
        preferredStrategies: [String] = []
    ) {
        self.tone = tone
        self.persona = persona
        self.directives = directives
        self.prohibitions = prohibitions
        self.preferredStrategies = preferredStrategies
    }
}
```

### DialoguePhase (Value Object)

**Location:** `packages/AIPRDSharedUtilities/Sources/Domain/ValueObjects/Thinking/DialoguePhase.swift`

```swift
import Foundation

/// Lifecycle phase of a multi-agent dialogue.
/// Each phase carries a system directive that frames the agent's behavior.
public enum DialoguePhase: String, Sendable, Codable, CaseIterable {
    /// Initial broad exploration of the problem space.
    case exploration
    /// Focused refinement of promising approaches.
    case refinement
    /// Multi-agent consensus building across competing perspectives.
    case consensus
    /// Final synthesis and commitment to a solution.
    case convergence

    /// Phase-specific system directive injected into prompts.
    public var systemDirective: String {
        switch self {
        case .exploration:
            return "Explore the problem space broadly. Consider multiple perspectives, generate diverse hypotheses, and identify key dimensions without committing to a single approach."
        case .refinement:
            return "Refine the most promising approaches. Deepen analysis, evaluate trade-offs, strengthen arguments with evidence, and narrow toward high-confidence conclusions."
        case .consensus:
            return "Seek convergence across perspectives. Identify areas of agreement, resolve contradictions through principled reasoning, and synthesize complementary viewpoints."
        case .convergence:
            return "Synthesize final conclusions. Commit to specific recommendations with supporting evidence. Produce actionable, concrete output ready for downstream consumption."
        }
    }
}
```

### PolicyScopeLevel (Value Object)

**Location:** `packages/AIPRDSharedUtilities/Sources/Domain/ValueObjects/Thinking/PolicyScopeLevel.swift`

```swift
import Foundation

/// Scope level in the policy hierarchy. Higher specificity wins in merges.
public enum PolicyScopeLevel: String, Sendable, Codable, CaseIterable, Comparable {
    case global
    case engine
    case stage
    case section

    public static func < (lhs: PolicyScopeLevel, rhs: PolicyScopeLevel) -> Bool {
        let order: [PolicyScopeLevel] = [.global, .engine, .stage, .section]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else { return false }
        return lhsIndex < rhsIndex
    }
}
```

## Port Definitions

### PolicyPromptComposerPort (New Port)

**Location:** `packages/AIPRDSharedUtilities/Sources/Domain/Ports/PolicyPromptComposerPort.swift`

```swift
import Foundation

/// Port for composing policy constraints into prompt strings.
/// Adapters implement deterministic ordering of policy directives.
public protocol PolicyPromptComposerPort: Sendable {
    /// Composes policy constraints into the base prompt.
    ///
    /// Ordering contract:
    /// 1. Persona directive (if present)
    /// 2. Tone directive (if present)
    /// 3. Phase system directive (if present)
    /// 4. Base prompt (unchanged)
    /// 5. Prohibitions footer (if any)
    ///
    /// Returns base prompt unchanged when policy has all-nil constraints and no phase.
    func compose(
        basePrompt: String,
        policy: PromptPolicy,
        phase: DialoguePhase?
    ) -> String
}
```

### FewShotPromptPort Extension

**Location:** `packages/AIPRDSharedUtilities/Sources/Domain/Ports/FewShotPromptPort.swift` (modified)

```swift
// Added to existing FewShotPromptPort protocol:

/// Selects few-shot examples filtered by optional policy constraints.
/// When policy specifies a dialogue phase, only examples tagged for that phase
/// are returned (falling back to unfiltered selection if no phase-tagged examples exist).
func selectExamples(
    similarTo input: String,
    count: Int,
    category: String?,
    policy: PromptPolicy?
) async throws -> [FewShotPromptExample]

// Default extension for backward compatibility:
extension FewShotPromptPort {
    public func selectExamples(
        similarTo input: String,
        count: Int,
        category: String?,
        policy: PromptPolicy?
    ) async throws -> [FewShotPromptExample] {
        try await selectExamples(similarTo: input, count: count, category: category)
    }
}
```

### MetaPromptingEngineProtocol Extension

**Location:** `packages/AIPRDMetaPromptingEngine/Sources/MetaPromptingEngineProtocol.swift` (modified)

```swift
// Added to existing MetaPromptingEngineProtocol:

/// Executes a thinking strategy with optional prompt policy parameterization.
/// When promptPolicy is provided, policy constraints are composed into the
/// strategy's prompt context before execution.
func executeStrategy(
    problem: String,
    context: String,
    strategy: ThinkingStrategy,
    researchContext: ResearchFrameworkContext?,
    promptPolicy: PromptPolicy?
) async throws -> ThinkingResult

// Default extension for backward compatibility:
extension MetaPromptingEngineProtocol {
    public func executeStrategy(
        problem: String,
        context: String,
        strategy: ThinkingStrategy,
        researchContext: ResearchFrameworkContext?,
        promptPolicy: PromptPolicy?
    ) async throws -> ThinkingResult {
        try await executeStrategy(
            problem: problem,
            context: context,
            strategy: strategy,
            researchContext: researchContext
        )
    }
}
```

## Adapter Implementations

### PolicyPromptComposer

**Location:** `packages/AIPRDMetaPromptingEngine/Sources/Services/PolicyPromptComposer.swift`

```swift
import Foundation
import AIPRDSharedUtilities

/// Composes policy constraints into prompts following deterministic ordering.
/// Implements PolicyPromptComposerPort from the domain layer.
struct PolicyPromptComposer: PolicyPromptComposerPort {
    func compose(
        basePrompt: String,
        policy: PromptPolicy,
        phase: DialoguePhase?
    ) -> String {
        var sections: [String] = []

        if let persona = policy.constraints.persona {
            sections.append("[Persona] You are acting as: \(persona).")
        }

        if let tone = policy.constraints.tone {
            sections.append("[Tone] Respond in a \(tone) manner.")
        }

        let effectivePhase = phase ?? policy.phase
        if let phase = effectivePhase {
            sections.append("[Phase: \(phase.rawValue)] \(phase.systemDirective)")
        }

        if !policy.constraints.directives.isEmpty {
            let joined = policy.constraints.directives.map { "- \($0)" }.joined(separator: "\n")
            sections.append("[Directives]\n\(joined)")
        }

        // Base prompt is always included, positioned after policy preamble
        sections.append(basePrompt)

        if !policy.constraints.prohibitions.isEmpty {
            let joined = policy.constraints.prohibitions.map { "- \($0)" }.joined(separator: "\n")
            sections.append("[Constraints — Do NOT]\n\(joined)")
        }

        return sections.joined(separator: "\n\n")
    }
}
```

### MetaPromptingEngine Modification

**Location:** `packages/AIPRDMetaPromptingEngine/Sources/MetaPromptingEngine.swift` (modified)

```swift
// Add PolicyPromptComposerPort as optional dependency:
private let policyComposer: PolicyPromptComposerPort?

// Updated initializer (backward compatible):
public init(
    aiProvider: AIProviderPort,
    ragEngine: RAGEngineProtocol,
    thinkingStrategyPort: ThinkingStrategyPort? = nil,
    policyComposer: PolicyPromptComposerPort? = nil
) {
    self.aiProvider = aiProvider
    self.ragEngine = ragEngine
    self.thinkingStrategyPort = thinkingStrategyPort
    self.policyComposer = policyComposer
}

// New protocol method implementation:
public func executeStrategy(
    problem: String,
    context: String,
    strategy: ThinkingStrategy,
    researchContext: ResearchFrameworkContext?,
    promptPolicy: PromptPolicy?
) async throws -> ThinkingResult {
    // Compose policy into context if both policy and composer are available
    let effectiveContext: String
    if let policy = promptPolicy, let composer = policyComposer {
        effectiveContext = composer.compose(
            basePrompt: context,
            policy: policy,
            phase: policy.phase
        )
    } else {
        effectiveContext = context
    }

    // Delegate to existing execution path
    var result = try await executeStrategy(
        problem: problem,
        context: effectiveContext,
        strategy: strategy,
        researchContext: researchContext
    )

    // Record policy metadata (FR-011)
    if let policy = promptPolicy {
        result = ThinkingResult(
            problem: result.problem,
            strategyUsed: result.strategyUsed,
            conclusion: result.conclusion,
            confidence: result.confidence,
            metadata: result.metadata.merging([
                "promptPolicyId": policy.policyId,
                "promptPolicyPhase": policy.phase?.rawValue ?? "none"
            ]) { _, new in new }
        )
    }

    return result
}
```

### EnhancementOrchestrator Modification

**Location:** `packages/AIPRDMetaPromptingEngine/Sources/Services/Enhancements/EnhancementOrchestrator.swift` (modified)

```swift
// Extended execute method signature:
public func execute<T: RefinableResult>(
    problem: String,
    context: String,
    enhancement: EnhancementType,
    promptPolicy: PromptPolicy? = nil,
    baseExecutor: @escaping (String, String) async throws -> T
) async throws -> EnhancedExecutionResult<T> {
    // Wrap baseExecutor to apply policy composition
    let policyAwareExecutor: (String, String) async throws -> T
    if let policy = promptPolicy, let composer = policyComposer {
        policyAwareExecutor = { problem, context in
            let composedContext = composer.compose(
                basePrompt: context,
                policy: policy,
                phase: policy.phase
            )
            return try await baseExecutor(problem, composedContext)
        }
    } else {
        policyAwareExecutor = baseExecutor
    }

    // Delegate to existing enhancement execution with policy-aware executor
    return try await executeInternal(
        problem: problem,
        context: context,
        enhancement: enhancement,
        baseExecutor: policyAwareExecutor
    )
}

// Extended full stack method:
public func executeWithFullStack<T: RefinableResult>(
    problem: String,
    context: String,
    promptPolicy: PromptPolicy? = nil,
    baseExecutor: @escaping (String, String) async throws -> T
) async throws -> EnhancedExecutionResult<T> {
    try await execute(
        problem: problem,
        context: context,
        enhancement: .composite(enhancements: [
            .thoughtBuffering(config: .balanced),
            .adaptiveExpansion(config: .balanced),
            .collaborativeInference(config: .balanced),
            .metacognitiveMonitoring(config: .balanced),
            .trmRefinement(config: .balanced)
        ]),
        promptPolicy: promptPolicy,
        baseExecutor: baseExecutor
    )
}
```

### ThinkingOrchestratorUseCase Modification

**Location:** `packages/AIPRDOrchestrationEngine/Sources/ThinkingOrchestratorUseCase.swift` (modified)

```swift
// Extended execute method:
public func execute(
    problem: String,
    context: String,
    sectionType: String,
    codebaseId: String? = nil,
    preferredStrategy: ThinkingStrategy? = nil,
    prdContext: PRDContext = .feature,
    promptPolicy: PromptPolicy? = nil
) async throws -> ThinkingResult {
    // ... existing strategy selection logic unchanged ...

    // Forward policy to MetaPromptingEngine
    let result = try await metaPromptingEngine.executeStrategy(
        problem: problem,
        context: context,
        strategy: selectedStrategy,
        researchContext: researchContext,
        promptPolicy: promptPolicy
    )

    return result
}
```

### SectionStrategySelector Modification

**Location:** `packages/AIPRDOrchestrationEngine/Sources/Services/PRD/SectionStrategySelector.swift` (modified)

```swift
// Extended selectStrategy method:
public func selectStrategy(
    for sectionType: String,
    problem: String,
    context: String,
    promptPolicy: PromptPolicy? = nil
) -> ThinkingStrategy {
    var scores = computeBaseScores(for: sectionType, problem: problem, context: context)

    // Apply policy-driven boost (FR-010)
    if let preferredStrategies = promptPolicy?.constraints.preferredStrategies,
       !preferredStrategies.isEmpty {
        for strategyName in preferredStrategies {
            if let index = scores.firstIndex(where: { $0.name == strategyName }) {
                scores[index].score += 0.15
            }
        }
    }

    scores.sort { $0.score > $1.score }
    return scores.first?.strategy ?? .chainOfThought
}
```

## Composition Root Wiring

### MetaPromptingFactory Modification

**Location:** `library/Sources/Composition/Factories/MetaPromptingFactory.swift` (modified)

```swift
func createMetaPromptingEngine(
    aiProvider: AIProviderPort,
    ragEngine: RAGEngineProtocol
) -> MetaPromptingEngineResult {
    let policyComposer = PolicyPromptComposer()

    let engine = MetaPromptingEngine(
        aiProvider: aiProvider,
        ragEngine: ragEngine,
        policyComposer: policyComposer
    )

    return .engine(engine)
}
```

## Data Flow Diagram

```
Pipeline Operator
  │
  ▼
PromptPolicy (from PipelinePolicy.yaml or programmatic construction)
  │
  ▼
ThinkingOrchestratorUseCase.execute(... promptPolicy:)
  │
  ├── SectionStrategySelector.selectStrategy(... promptPolicy:)
  │   └── Applies +0.15 boost to preferredStrategies
  │
  ├── StrategyEngineAdapter.selectStrategy(...)
  │   └── Returns research-weighted strategy + ResearchFrameworkContext
  │
  ▼
MetaPromptingEngine.executeStrategy(... promptPolicy:)
  │
  ├── PolicyPromptComposer.compose(basePrompt:policy:phase:)
  │   └── Returns: persona → tone → phase directive → prompt → prohibitions
  │
  ├── EnhancementOrchestrator.executeWithFullStack(... promptPolicy:)
  │   └── Each enhancement receives policy-composed prompt via wrapped executor
  │       ├── ThoughtBuffer (pre-execution buffering)
  │       ├── AdaptiveExpansion (dynamic depth)
  │       ├── CollaborativeInference (multi-path consensus)
  │       ├── MetacognitiveMonitoring (quality check)
  │       └── TRM Refinement (convergence)
  │
  ├── AIProviderPort.generateText(prompt:...)
  │   └── Receives fully policy-composed prompt
  │
  ▼
ThinkingResult
  ├── .conclusion (policy-influenced output)
  ├── .confidence
  └── .metadata
      ├── "promptPolicyId": "sec-001"
      ├── "promptPolicyPhase": "refinement"
      ├── "researchFrameworkId": "mit_discipl"
      └── "effectivenessMetrics": "{...}"
```

## API Specification

This is a Swift library (not a REST service). The "API" is the set of public protocol methods and types.

### New Public Types

| Type | Package | Kind | Access |
|------|---------|------|--------|
| `PromptPolicy` | SharedUtilities | Struct (VO) | `public` (cross-package) |
| `PolicyConstraints` | SharedUtilities | Struct (VO) | `public` (cross-package) |
| `DialoguePhase` | SharedUtilities | Enum (VO) | `public` (cross-package) |
| `PolicyScopeLevel` | SharedUtilities | Enum (VO) | `public` (cross-package) |
| `PolicyPromptComposerPort` | SharedUtilities | Protocol | `public` (cross-package) |
| `PolicyPromptComposer` | MetaPromptingEngine | Struct (Adapter) | `internal` (single-package) |

### Modified Protocol Methods

| Protocol | Method | Change | Backward Compatible |
|----------|--------|--------|---------------------|
| `FewShotPromptPort` | `selectExamples(similarTo:count:category:policy:)` | New overload with default extension | Yes — default delegates to existing method |
| `MetaPromptingEngineProtocol` | `executeStrategy(problem:context:strategy:researchContext:promptPolicy:)` | New overload with default extension | Yes — default delegates to existing method |

### Modified Concrete Methods

| Type | Method | Change | Backward Compatible |
|------|--------|--------|---------------------|
| `MetaPromptingEngine` | `init(...)` | Added `policyComposer: PolicyPromptComposerPort? = nil` | Yes — optional with nil default |
| `EnhancementOrchestrator` | `execute(...)`, `executeWithFullStack(...)` | Added `promptPolicy: PromptPolicy? = nil` | Yes — optional with nil default |
| `ThinkingOrchestratorUseCase` | `execute(...)` | Added `promptPolicy: PromptPolicy? = nil` | Yes — optional with nil default |
| `SectionStrategySelector` | `selectStrategy(...)` | Added `promptPolicy: PromptPolicy? = nil` | Yes — optional with nil default |

## Security Considerations

| Concern | Mitigation |
|---------|------------|
| Prompt injection via policy fields | PolicyConstraints uses typed fields (not raw prompt strings); persona and tone are descriptive labels composed by `PolicyPromptComposer` with bracketed delimiters |
| Policy payload size | NFR-004 enforces < 2KB serialized; `PolicyPromptComposer` does not amplify payload |
| Unauthorized policy override | Policy hierarchy resolution is deterministic (pure function); access control follows existing `PipelinePolicy` patterns |
| Metadata leakage | Policy metadata in `ThinkingResult` uses the same key-value pattern as existing `researchFrameworkId`; no additional PII exposure |

## Migration Path

**Phase 1 (Zero-change deployment):** Ship all new types and protocol extensions with default nil parameters. All existing code continues to work without modification. Composition root optionally wires `PolicyPromptComposer`.

**Phase 2 (Opt-in adoption):** Callers that want policy-driven dialogue begin passing `PromptPolicy` to `ThinkingOrchestratorUseCase.execute()`. No changes required for callers that do not use policies.

**Phase 3 (Pipeline integration):** `PipelinePolicy` YAML gains an optional `promptPolicies` section. `PolicySource.load()` extracts and provides policies to the orchestrator.