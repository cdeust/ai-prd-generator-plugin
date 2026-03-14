# Enterprise-Grade Output Requirements

## Enterprise-Grade Output Standards

| Section | What This Delivers |
|---------|-------------------|
| SQL DDL | Complete: constraints, indexes, RLS, materialized views, triggers |
| Domain Models | Full Swift/TS with validation, error types, business rules |
| API Specification | Exact REST routes, request/response schemas, rate limits |
| Requirements | FR-001 through FR-050+ with exact acceptance criteria |
| Story Points | Fibonacci with task breakdown per story |
| Non-Functional | Exact metrics: "<500ms p95", "100 reads/min", "AES-256" |

**Rule: The Functional Requirements table (Section 3.1) MUST NOT include a story points (SP) column. Story points belong ONLY in the Implementation Roadmap and JIRA file, where they are assigned at the story level. Including per-FR story points creates a misleading total that contradicts the story-level SP total. The FR table columns are: ID, Requirement, Priority, Depends On, Source.**

**Rule: Every FR MUST have a Source column value tracing it to: `User Request`, `Clarification QN`, `Codebase: {file:line}`, `Mockup: {element}`, or `[SUGGESTED]`. FRs marked `[SUGGESTED]` MUST be in a separate "Suggested Additions" subsection, not the main FR table. See HARD OUTPUT RULE #11.**

## SQL DDL Requirements

**I MUST generate complete PostgreSQL DDL including:**

**Rule: Every ENUM, table, index, and type created in the DDL MUST be used somewhere. Do NOT create orphaned enums or types. If a table uses a FK reference to a lookup table instead of an ENUM, do NOT also create an unused ENUM for the same purpose.**

**Rule: Do NOT use `NOW()` in partial index WHERE clauses. `NOW()` in a partial index is evaluated once at index creation time, not at query time. For time-based partial indexes, use only non-volatile conditions (e.g., `WHERE deleted_at IS NOT NULL`). The time filtering belongs in the query, not the index predicate.**

**Required DDL elements:** Tables with constraints (PK, FK with ON DELETE, CHECK, NOT NULL), lookup tables (use ENUM or lookup, NEVER both for same concept), GIN indexes for full-text search, partial indexes with stable predicates only, Row-Level Security policies, and materialized views where appropriate.

## Domain Model Requirements

**I MUST generate complete models with validation:**

**Rule: Only use types from Swift Foundation or types defined within the PRD. NEVER use third-party types like `AnyCodable`, `AnyJSON`, or `JSONValue` without explicitly defining them or declaring the dependency. For JSONB payload fields, use `[String: String]`, `Data`, or define a custom `JSONValue` enum within the PRD.**

**Required model elements:** All properties typed, static business rule constants, computed properties, throwing initializer with validation, error enum with descriptive cases. For JSONB payload fields, define a custom `JSONValue` enum within the PRD (with string/int/double/bool/array/object/null cases).

## Architecture Requirements (MANDATORY — See HARD OUTPUT RULE #12)

**The Technical Specification MUST follow ports/adapters (hexagonal) architecture using the 3-layer Pipeline packages:**

**Layer 0: Domain (PipelineDomain) — Pure Business Logic:**
- Pure business entities (structs/classes with **zero framework imports**)
- Protocol definitions (ports) for all external dependencies (repositories, services, gateways)
- Value objects, domain events, error types
- **ZERO imports** of UIKit, SwiftUI, Foundation networking, database frameworks, or third-party SDKs
- **Example ports:** `SnippetRepository`, `SearchService`, `EmbeddingProvider`, `Clock`, `UUIDGenerator`
- **Dependencies:** None — this is Layer 0 (foundational)

**Layer 1: Adapters (PipelineAdapters) — Infrastructure Implementations:**
- Concrete implementations of domain ports defined in PipelineDomain
- Framework-specific code lives HERE (CoreData, URLSession, SwiftUI bindings, PostgreSQL, AWS Bedrock, etc.)
- Each adapter depends **inward** on domain ports (PipelineDomain), **outward** on frameworks
- **Example adapters:** `PostgresSnippetRepository`, `BedrockEmbeddingProvider`, `OpenAISearchService`, `SystemClock`, `FoundationUUIDGenerator`
- **Dependencies:** PipelineDomain only (Clean Architecture compliance)

**Layer 1: AI Orchestration (PipelineIntelligenceEngine) — Multi-Step Workflows:**
- Coordinates complex AI workflows using domain ports
- Multi-step reasoning, dependency resolution, strategy orchestration
- Depends **only** on PipelineDomain ports — no direct framework imports
- **Example workflows:** `PRDGenerationOrchestrator`, `ClarificationCoordinator`, `MultiJudgeVerificationWorkflow`
- **Dependencies:** PipelineDomain only (uses ports, not concrete implementations)

**Composition Root (Application/Composition Layer):**
- Single location that creates concrete adapters and injects them into domain ports
- Wires PipelineAdapters → PipelineDomain ports → PipelineIntelligenceEngine workflows
- The ONLY place that knows about all concrete types
- Factory methods or DI container configuration

**MANDATORY: When generating Technical Specifications, I MUST:**

1. **Define domain models in PipelineDomain style:**
   - Pure Swift types with zero framework imports
   - Ports (protocols) for all I/O operations
   - Example:
     ```swift
     // PipelineDomain — Ports
     protocol SnippetRepository {
         func save(_ snippet: Snippet) async throws
         func findByTag(_ tag: String) async throws -> [Snippet]
     }

     protocol EmbeddingProvider {
         func embed(_ text: String) async throws -> [Float]
     }
     ```

2. **Define adapters in PipelineAdapters style:**
   - Concrete implementations using real frameworks
   - Example:
     ```swift
     // PipelineAdapters — Implementations
     final class PostgresSnippetRepository: SnippetRepository {
         private let connection: PostgresConnection

         func save(_ snippet: Snippet) async throws {
             // PostgresNIO framework code here
         }
     }

     final class BedrockEmbeddingProvider: EmbeddingProvider {
         private let client: BedrockRuntimeClient

         func embed(_ text: String) async throws -> [Float] {
             // AWS Bedrock SDK code here
         }
     }
     ```

3. **Define orchestration in PipelineIntelligenceEngine style:**
   - Multi-step workflows coordinating domain services
   - Example:
     ```swift
     // PipelineIntelligenceEngine — AI Workflows
     final class PRDGenerationOrchestrator {
         private let repository: SnippetRepository  // Port, not concrete
         private let embedding: EmbeddingProvider   // Port, not concrete

         func generatePRD(request: PRDRequest) async throws -> PRD {
             // Multi-step workflow using ports
             let context = try await repository.findByTag(request.tag)
             let vectors = try await embedding.embed(request.description)
             // ... orchestrate generation
         }
     }
     ```

4. **Show composition root wiring:**
   - Example:
     ```swift
     // Composition Root
     let postgresRepo = PostgresSnippetRepository(connection: pgConnection)
     let bedrockEmbedding = BedrockEmbeddingProvider(client: bedrockClient)
     let orchestrator = PRDGenerationOrchestrator(
         repository: postgresRepo,
         embedding: bedrockEmbedding
     )
     ```

**Rule: I NEVER generate service classes that directly call databases, network APIs, or UI frameworks from the domain layer. Business logic goes in PipelineDomain; I/O goes in PipelineAdapters; workflows go in PipelineIntelligenceEngine. If I detect the codebase already uses this pattern (via RAG), I match its exact naming conventions (e.g., `FooRepository` for ports, `PostgresFooRepository` for adapters). This produces identical architectural output regardless of whether I'm running in CLI or Cowork mode.**

**When RAGEngine detects existing Clean Architecture patterns in the codebase, I MUST:**
- Extract the existing port naming convention (e.g., `ServicePort` vs `Service` vs `IService`)
- Extract the existing adapter naming convention (e.g., `ConcreteService` vs `ServiceImpl` vs `PostgresService`)
- Mirror the exact pattern in the PRD's Technical Specification
- Reference the existing codebase patterns in the Architecture section: "Following existing pattern from `{file}:{line}`"

## Apple Intelligence Engine Integration (iOS/macOS PRDs)

**When generating PRDs for iOS or macOS applications, I MUST invoke AppleIntelligenceEngine to provide native platform recommendations.**

**Detection Criteria (when to activate AppleIntelligenceEngine):**
- User request mentions: "iOS", "macOS", "SwiftUI", "UIKit", "Apple platform", "iPhone", "iPad", "Mac"
- Codebase analysis (RAG) detects Swift code with `import SwiftUI` or `import UIKit`
- Mockup analysis (Vision) shows iOS/macOS UI patterns (navigation bars, tab bars, SF Symbols)

**AppleIntelligenceEngine Provides:**

1. **FoundationModels Framework Recommendations (macOS 26+):**
   - On-device model inference using Apple's Neural Engine
   - Privacy-preserving AI features (no data leaves the device)
   - Structured generation with `@Generable` macro for type-safe outputs
   - Example use cases: Local text summarization, entity extraction, classification

2. **Liquid Glass Design System:**
   - Latest Apple design guidelines (2026)
   - Vibrancy effects, materials, dynamic type support
   - Accessibility-first component recommendations
   - SF Symbols 6.0 recommendations for iconography

3. **Platform-Specific Performance Optimizations:**
   - Main actor isolation recommendations for SwiftUI
   - Async/await patterns for network operations
   - Metal acceleration recommendations for graphics-intensive features
   - Background task scheduling using BackgroundTasks framework

4. **Native Framework Integration:**
   - CoreML for on-device ML models
   - Vision framework for image analysis
   - NaturalLanguage framework for text processing
   - CoreData or SwiftData for local persistence

**MANDATORY: When AppleIntelligenceEngine is active, Technical Specification MUST include:**

1. **Platform Requirements Section:**
   ```markdown
   ### Platform Requirements
   - **Minimum iOS Version:** iOS 17.0 (or macOS 14.0 for Mac)
   - **Recommended iOS Version:** iOS 18.0+ (for FoundationModels support)
   - **Swift Version:** Swift 6.0+
   - **Xcode Version:** Xcode 16.0+
   - **Frameworks Required:** SwiftUI, Combine, CoreData, FoundationModels (macOS 26+)
   ```

2. **On-Device ML Recommendations (when applicable):**
   ```swift
   // Example: Using FoundationModels for on-device inference (macOS 26+)
   import FoundationModels

   @Generable
   struct PRDSummary {
       let title: String
       let keyFeatures: [String]
       let complexity: ComplexityLevel
   }

   final class OnDevicePRDAnalyzer {
       func summarize(_ prdText: String) async throws -> PRDSummary {
           // FoundationModels inference here
       }
   }
   ```

3. **SwiftUI Architecture with MVVM:**
   ```swift
   // PipelineDomain — View Model Protocol (Port)
   protocol SnippetListViewModel {
       var snippets: [Snippet] { get }
       func loadSnippets() async throws
   }

   // PipelineAdapters — SwiftUI Adapter
   @MainActor
   final class SwiftUISnippetListViewModel: ObservableObject, SnippetListViewModel {
       @Published private(set) var snippets: [Snippet] = []
       private let repository: SnippetRepository  // Port, not concrete

       func loadSnippets() async throws {
           snippets = try await repository.findAll()
       }
   }

   // View (Presentation Layer)
   struct SnippetListView: View {
       @StateObject private var viewModel: SwiftUISnippetListViewModel

       var body: some View {
           List(viewModel.snippets) { snippet in
               SnippetRow(snippet: snippet)
           }
           .task { try? await viewModel.loadSnippets() }
       }
   }
   ```

4. **Accessibility Requirements (mandatory for iOS/macOS):**
   - VoiceOver support specifications
   - Dynamic Type support (minimum: Large, recommended: XXXL)
   - Color contrast ratios (WCAG AA minimum, AAA recommended)
   - Keyboard navigation support (macOS)
   - Haptic feedback patterns (iOS)

5. **Platform-Specific Testing Requirements:**
   - UI tests using XCUITest framework
   - Performance tests for 60fps target (120fps for ProMotion devices)
   - Accessibility audit using Accessibility Inspector
   - Memory leak detection using Instruments
   - On-device model performance benchmarks (FoundationModels)

**AppleIntelligenceEngine Decision Matrix:**

| Feature Type | Recommendation | Framework | Why |
|--------------|---------------|-----------|-----|
| Text classification | On-device (FoundationModels) | FoundationModels (macOS 26+) | Privacy-preserving, no API costs |
| Semantic search | Hybrid (on-device embeddings + backend) | CoreML + Bedrock | Balance privacy and capability |
| Image analysis | Vision framework | Vision + CoreML | Native performance, offline support |
| Natural language processing | NaturalLanguage framework | NaturalLanguage | Built-in, optimized for Apple Silicon |
| Large-scale generation | Cloud-based (Bedrock/OpenAI) | AWS SDK / OpenAI SDK | Capability exceeds on-device models |

**When AppleIntelligenceEngine detects existing iOS/macOS patterns via RAG:**
- Reference existing SwiftUI view structure: "Following MVVM pattern from `ContentView.swift:12`"
- Reference existing on-device ML usage: "Extending CoreML model approach from `TextClassifier.swift:45`"
- Reference existing design system: "Using established SF Symbol naming from `DesignSystem.swift:8`"

## API Specification Requirements

**I MUST specify exact REST routes:**

**Required API elements:** Service name and port, all CRUD routes, search/filter routes, version/rollback routes, admin routes, rate limits per user, and auth requirements.

## Non-Functional Requirements

**I MUST specify exact metrics for every NFR** — numbered NFR-001+, each with a specific measurable target (latency in ms at percentile, throughput limits, encryption standards, etc.). No vague words like "fast" or "secure".

## Testable Acceptance Criteria with KPIs (MANDATORY)

**Every AC MUST be testable AND linked to business metrics. I NEVER write ACs without KPI context.**

Every AC MUST go beyond testability to include business context: baseline measurement with source, target threshold, improvement delta, production measurement method, and business impact link (BG-XXX or NFR). A bare "GIVEN/WHEN/THEN" without KPI context is insufficient.

**AC-to-KPI Linkage Rules:**

Every AC in the PRD MUST include:

| Field | Description | Required |
|-------|-------------|----------|
| **Baseline** | Current state measurement with SOURCE | YES |
| **Baseline Source** | How baseline was obtained (see below) | YES |
| **Target** | Specific threshold to achieve | YES |
| **Improvement** | % or absolute delta from baseline | YES (if baseline exists) |
| **Measurement** | How to verify in production (tool, dashboard, query) | YES |
| **Business Impact** | Link to Business Goal (BG-XXX) or KPI | YES |
| **Validation Dataset** | For ML/search: describe test data | IF APPLICABLE |
| **Human Review Flag** | If regulatory, security, or domain-specific | IF APPLICABLE |

**Baseline Sources (from PRD generation inputs):**

Baselines are derived from the THREE inputs to PRD generation:

| Source | What It Provides | Example Baseline |
|--------|------------------|------------------|
| **Codebase Analysis (RAG)** | Actual metrics from existing code, configs, logs | "Current search: 2.1s (from `SearchService.swift:45` timeout config)" |
| **Mockup Analysis (Vision)** | Current UI state, user flows, interaction patterns | "Current flow: 5 steps (from mockup analysis)" |
| **User Clarification** | Stakeholder-provided data, business context | "Current conversion: 12% (per user in clarification round 2)" |

**Targets are based on current state of the art (Q1 2026):**

I reference the LATEST academic research and industry benchmarks, not outdated papers.

| Algorithm/Technique | State of the Art Reference | Expected Improvement |
|---------------------|---------------------------|---------------------|
| Contextual Retrieval | Latest Anthropic/OpenAI retrieval research | +40-60% precision vs vanilla methods |
| Hybrid Search (RRF) | Current vector DB benchmarks (Pinecone, Weaviate, pgvector) | +20-35% vs single-method |
| Adaptive Consensus | Latest multi-agent verification literature | 30-50% LLM call reduction |
| Multi-Agent Debate | Current LLM factuality research (2025-2026) | +15-25% factual accuracy |

**Rule: I cite the most recent benchmarks available, not historical papers.**

When generating verification reports, I:
1. Reference current year benchmarks (2025-2026)
2. Use latest industry reports (Gartner, Forrester, vendor benchmarks)
3. Acknowledge when research is evolving: "Based on Q1 2026 benchmarks; field evolving rapidly"

**When no baseline exists:**

| Situation | Approach |
|-----------|----------|
| New feature, no prior code | "N/A - new capability" + target from academic benchmarks |
| User doesn't know current metrics | Flag for Sprint 0 measurement: "Baseline TBD - measure before committing" |
| No relevant academic benchmark | Use industry standards with citation |

**AC Format:** Each AC follows the pattern: `AC-XXX: {Title}`, GIVEN-WHEN-THEN, then a Metric/Value table with Baseline (with source), Target, Improvement, Measurement (tool/dashboard/script), and Business Impact (BG-XXX or NFR link).

**AC Categories (I cover ALL with KPIs):**

| Category | What to Specify | KPI Link Example |
|----------|-----------------|------------------|
| **Performance** | Latency/throughput + baseline | "p95 2.1s → 500ms (BG-001)" |
| **Relevance** | Precision/recall + validation set | "P@10 0.52 → 0.75 (BG-002)" |
| **Security** | Access control + audit method | "0 leaks (NFR-008)" |
| **Reliability** | Uptime + error rates | "99.9% uptime (NFR-011)" |
| **Scalability** | Capacity + load test | "1000 snippets/user (TG-001)" |
| **Usability** | Task completion + user study | "< 3 clicks to insert (PG-002)" |

**For each User Story, I generate minimum 3 ACs with KPIs:**
1. Happy path with performance baseline/target
2. Error case with reliability metrics
3. Edge case with scalability limits

---

## Human Review Requirements (MANDATORY)

**I NEVER claim 100% confidence on complex domains. High scores can mask critical errors.**

**Sections Requiring Mandatory Human Review:**

| Domain | Why AI Verification is Insufficient | Human Reviewer |
|--------|-------------------------------------|----------------|
| **Regulatory/Compliance** | GDPR, HIPAA, SOC2 have legal implications AI cannot validate | Legal/Compliance Officer |
| **Security** | Threat models, penetration testing require domain expertise | Security Engineer |
| **Financial** | Pricing, revenue projections need business validation | Finance/Business |
| **Domain-Specific** | Industry regulations vary by jurisdiction | Domain Expert |
| **Accessibility** | WCAG compliance needs real user testing | Accessibility Specialist |

**Human Review Flags in PRD:**

When I generate content in these areas, I MUST add:

```markdown
**HUMAN REVIEW REQUIRED**
- **Section:** Security Requirements (NFR-007 to NFR-012)
- **Reason:** Security architecture decisions have compliance implications
- **Reviewer:** Security Engineer
- **Before:** Sprint 1 kickoff
```

**Over-Trust Warning:**

Even when all structural checks pass and model-projected quality is high, the PRD may contain:
- Domain-specific errors the AI judges cannot detect
- Regulatory requirements that need legal validation
- Edge cases that only domain experts would identify
- Assumptions that need stakeholder confirmation
- Performance claims marked SPEC-COMPLETE that will fail under real load

**Structural checks (Tier 1) are facts. Model-projected scores (Tier 6) are opinions. Never conflate them.**

---

## Edge Cases & Ambiguity Handling

**Complex requirements I flag for human clarification:**

| Pattern | Example | Action |
|---------|---------|--------|
| **Ambiguous scope** | "Support international users" | Flag: Which countries? Languages? Currencies? |
| **Implicit assumptions** | "Fast search" | Flag: What's fast? Current baseline? Target? |
| **Regulatory triggers** | "Store user data" | Flag: GDPR? CCPA? Data residency? |
| **Security-sensitive** | "Authentication" | Flag: MFA? SSO? Password policy? |
| **Integration unknowns** | "Connect to existing system" | Flag: API available? Auth method? SLA? |

**I add an "Assumptions & Risks" section to every PRD:**

```markdown
## Assumptions & Risks

### Assumptions (Require Stakeholder Validation)
| ID | Assumption | Impact if Wrong | Owner to Validate |
|----|------------|-----------------|-------------------|
| A-001 | Existing API supports required endpoints | +4 weeks if custom development needed | Tech Lead |
| A-002 | User base is <10K for MVP | Architecture redesign if >100K | Product |

### Risks Requiring Human Review
| ID | Risk | Severity | Mitigation | Reviewer |
|----|------|----------|------------|----------|
| R-001 | GDPR compliance not fully addressed | HIGH | Legal review before Sprint 2 | Legal |
| R-002 | Performance baseline is estimated | MEDIUM | Measure in Sprint 0 | Engineering |
```

## JIRA Ticket Requirements

**I MUST include story points (Fibonacci) and task breakdowns.** Each story has: SP, tasks, ACs with KPI tables referencing PRD AC-XXX IDs, dependencies, and labels.

## Implementation Roadmap

**I MUST include phases with week ranges, SP per phase, and total estimate with team size.** SP distribution across phases MUST be uneven (reflecting actual complexity).
