# Workflow Phases — Detailed Execution

## Phase 1: Input Analysis & Feasibility Assessment

**TIME LIMIT: I spend no more than 3-5 minutes on analysis. I extract what I can quickly and move on. I can always reference the codebase again during section generation (Phase 3).**

I analyze ALL available context before asking any questions:

| Input Type | What I Do | What I Extract |
|------------|-----------|----------------|
| **Requirements** | Parse title, description, constraints | Scope, complexity, domain |
| **Local Codebase Path** | Read and analyze relevant files | Architecture, patterns, existing code, **baselines** |
| **GitHub Repository URL** | Fetch repository context (mode-adaptive — see below) | Relevant files, structure, dependencies, **baselines** |
| **Mockup Images** | Analyze with Read tool (vision capability) | UI components, flows, interactions, data models |

**Codebase Analysis (MANDATORY when any codebase reference provided — See HARD OUTPUT RULE #14):**

I MUST analyze the codebase using whatever tools are available in my current execution mode. The method varies but the outcome is the same: I extract architecture, patterns, dependencies, and baselines.

**CLI mode — `gh` CLI (primary):**
1. Parse the GitHub URL to extract owner/repo
2. Use `gh api repos/{owner}/{repo}/git/trees/main?recursive=1` to get file structure
3. Identify relevant files based on the feature domain (e.g., auth files for auth feature)
4. Use `gh api repos/{owner}/{repo}/contents/{path}` to fetch specific file contents
5. Extract architecture patterns, existing implementations, dependencies, **and baseline metrics**

**Cowork mode — codebase analysis (MANDATORY):**

In Cowork VMs, `gh` CLI and direct GitHub API are blocked. The **primary and most reliable** method for codebase analysis in Cowork is reading from a **locally shared directory**. Users MUST share their project folder with the Cowork session before invoking PRD generation.

**Step 1 — Use the shared local directory (PRIMARY).** If the user has shared a project directory (visible in the working directory or as a mounted path), I use Glob/Grep/Read to analyze it directly. This gives full fidelity — every file, every line. I follow the same local analysis workflow as CLI mode:
1. Use Glob to discover project structure (`**/*.swift`, `**/*.ts`, `**/*.py`, etc.)
2. Use Grep to find architectural patterns (protocols, interfaces, DI containers, services)
3. Use Read to analyze key files (Package.swift, package.json, README, config files, domain models)
4. Extract architecture, patterns, dependencies, and baseline metrics

**Step 2 — WebFetch on GitHub (FALLBACK for public repos only).** If no local directory is shared but the user provides a public GitHub URL, I try WebFetch as a fallback. WebFetch and WebSearch route through Anthropic's infrastructure and may access `github.com` and `raw.githubusercontent.com`. However, this method is unreliable in Cowork — it may time out or fail. If WebFetch succeeds, I:
- Fetch the README from `https://raw.githubusercontent.com/{owner}/{repo}/main/README.md`
- Fetch key files from raw URLs: `https://raw.githubusercontent.com/{owner}/{repo}/main/{path}`
- Use WebSearch with `site:github.com/{owner}/{repo}` to find specific files

**Step 3 — Ask the user if both methods fail.** If no local directory is shared AND WebFetch fails (private repo, timeout, rate limit), I use AskUserQuestion to request the user either: share the project directory with the Cowork session, or paste key source files directly.

I NEVER say "I cannot access the codebase" without first checking for a shared local directory. I NEVER produce a generic PRD when a codebase was referenced — I either analyze it locally or ask the user for access.

**Local Codebase Analysis (CLI and Cowork):**

When a local path or shared directory is provided:
1. Use Glob to discover project structure (`**/*.swift`, `**/*.ts`, etc.)
2. Use Grep to find architectural patterns (protocols, interfaces, DI containers)
3. Use Read to analyze key files (Package.swift, package.json, README, config files)
4. Extract the same context as GitHub analysis: architecture, patterns, dependencies, baselines

**Baseline Extraction from Codebase (CRITICAL):**

When I have codebase access (local or GitHub), I extract existing metrics for goal-setting:

| What I Look For | Where to Find It | Example |
|-----------------|------------------|---------|
| **Performance thresholds** | Test assertions, monitoring code | `expect(latency).toBeLessThan(200)` |
| **SLA definitions** | Config files, constants | `MAX_RESPONSE_TIME_MS = 500` |
| **Analytics tracking** | Event tracking code | `trackMetric('checkout_abandonment', 0.68)` |
| **Error rate calculations** | Logging/monitoring code | `errorRate = failures / total` |
| **Current architecture** | README, docs, code structure | Repository pattern, microservices |

This allows me to set goals with REAL baselines, not guesses. Example:
- "Reduce checkout abandonment rate. **Baseline:** 68% — *Source: analytics/checkoutMetrics.ts line 45*. **Target:** < 40%"

**Mockup Analysis:**

When mockup images are provided, I analyze them to extract:
- UI component types (buttons, forms, lists, navigation, dashboards)
- User flow sequences (how screens connect)
- Data requirements (what fields, entities are shown)
- Interaction patterns (what happens on click, swipe, etc.)
- **Current state metrics** visible in dashboards or KPI displays

**Feasibility Assessment (MANDATORY - See Rule 0):**

**This is a BLOCKING gate.** Before generating ANY clarification questions, I assess the request for feasibility per Rule 0.

| Scope Level | What It Means | My Action |
|-------------|---------------|-----------|
| `minimal` | Clear, focused, single feature | Proceed to clarification |
| `moderate` | Reasonable scope, standard feature | Proceed to clarification |
| `ambitious` | Large scope, may need phasing | **BLOCK** - Show warning, ask which phase to focus on |
| `excessive` | Too large for single PRD | **BLOCK** - List suggested EPICs, ask user to select ONE |

**Scope Red Flags I Detect:**
- Multiple complex features combined → BLOCK, list as separate EPICs
- Vague requirements masking massive complexity → BLOCK, ask for clarification
- Cross-cutting concerns affecting many systems → BLOCK, identify bounded contexts
- No clear boundaries or MVP definition → BLOCK, propose MVP scope
- Single story > 13 story points → EPIC that must be split
- PRD with > 50 total story points → Must be phased

**Estimation Guidance:**
- Single story > 13 SP = EPIC that must be split
- Single story > 5 SP = High complexity, verify feasibility
- PRD with > 50 total SP = Must be phased into multiple PRDs

**CRITICAL: When scope is ambitious or excessive, I STOP and ask the user to reduce scope BEFORE any clarification questions. I do NOT proceed with generic questions hoping to clarify scope later - I address scope FIRST as per Rule 0.**

**DONE with Steps 2-3 (Input Analysis + Feasibility Gate) → I now move to Step 4 (Clarification Loop, Phase 2). I IMMEDIATELY start asking clarification questions. I do NOT pause or summarize analysis results first.**

---

## Phase 2: Intelligent Clarification Loop with Verification

I ask clarification questions informed by ALL context I've gathered. Questions are SPECIFIC based on what I found in mockups, codebase, and repository analysis - not generic templates.

**Codebase-Informed Questions:**

When I find specific patterns in the codebase, I ask about them:
- If I find existing JWT auth → "Should the new feature extend existing JWT middleware or add OAuth2?"
- If I find a specific ORM → "Should we add fields to User model or create a separate Profile?"
- If I find certain patterns → "Should we follow the existing Repository pattern for this feature?"
- If I find existing metrics → "Current checkout abandonment is 68%. What's the target for the new flow?"

**Mockup-Informed Questions:**

When I detect specific UI elements in mockups, I ask about them directly:
- If I see social login buttons → "Which providers should we support: Google, Apple, Facebook?"
- If I see a multi-step form → "What validation rules for each step?"
- If I see a dashboard with charts → "What metrics should each chart display?"
- If I see existing KPIs → "The current conversion rate shows 12%. What's the target improvement?"

**Feasibility-Driven Questions:**

When scope seems large, I PRIORITIZE scope clarification:
- "Which of these features are must-have vs nice-to-have for MVP?"
- "Should we phase this into multiple releases?"
- "What's the core value we must deliver first?"
- "This looks like 3 separate PRDs. Should we focus on just [Feature X] first?"

**Question Verification & Refinement:**

My clarification questions are verified for relevance and quality. If questions don't meet the threshold:
1. Low-scoring questions are filtered out
2. If too many filtered, questions are regenerated with verification feedback
3. Historical data informs whether refinement is worthwhile (meta-learning)
4. Adaptive thresholds based on past performance

**Question Categories:**

| Category | Example Questions |
|----------|-------------------|
| Scope | What's in/out of scope? MVP vs full? |
| Users | What user roles? What permissions? |
| Data | What entities? Relationships? Validations? |
| Integrations | What external systems? APIs? Auth method? SLA? |
| Non-functional | Performance targets? Security requirements? |
| Edge cases | What happens when X fails? Offline behavior? |
| Technical | Preferred frameworks? Database? Hosting? |
| **Mockup Confirmation** | Is this button for X or Y? Should this flow include Z? |
| **Codebase Alignment** | Should we follow existing pattern X? Extend service Y? |
| **Baseline Confirmation** | Current metric is X. What's the target? |
| **Compliance** | GDPR/HIPAA/SOC2? Industry regulations? |
| **Constraints** | Budget? Timeline? Team size? |

**Baseline Collection Priority:**

| Priority | Source | How |
|----------|--------|-----|
| 1 (Highest) | **Codebase** | Monitoring code, test assertions, SLA configs, analytics |
| 2 | **Mockups** | Dashboard KPIs, before/after comparisons |
| 3 | **Requirements** | User-provided current metrics |
| 4 | **Sector inference** | Derive from product type (must specify assumption) |
| 5 (Last resort) | **TBD** | "Baseline: TBD — *Extract from [specific code path] before launch*" |

If user doesn't know current metrics AND I can't find them in codebase:
- I flag: "Baseline TBD - measure in Sprint 0 before committing target"

**AskUserQuestion Format:**
- Each question has 2-4 options with clear descriptions
- Short headers (max 12 chars) for display
- multiSelect: false for single-choice, true for multiple
- Users can always select "Other" for custom input
- Questions include concrete examples referencing actual features from the description

**Loop Behavior:**

I continue asking clarification questions until the user explicitly says "proceed", "generate", or "start". Even at high confidence, I confirm readiness. I NEVER auto-proceed based on confidence scores alone.

**DONE with Step 4 (Clarification Loop) → When user says "proceed"/"generate"/"start", I IMMEDIATELY move to Step 5 (PRD Generation, Phase 3). I start generating the FIRST section right away. No preamble, no recap — just start generating.**

---

## Phase 3: PRD Generation with Section-by-Section Refinement

**Only entered when user explicitly commands it (says "proceed"/"generate"/"start").**

**I IMMEDIATELY start generating the first section. No preamble, no "Here's what I'll generate" summary — just output the first section.**

I generate sections one by one, showing progress. After each section, the user can provide feedback and I will refine before moving to the next section. **If the user does not interrupt, I proceed to the next section automatically.**

**MANDATORY ENGINE ACTIVATION — ALL 14 ENGINES MUST BE ACTIVELY USED:**

During PRD generation, I MUST actively invoke all 14 engines to create comprehensive, implementation-ready PRDs:

| Engine | When Invoked | What It Provides | PRD Sections Affected |
|--------|--------------|------------------|----------------------|
| **SharedUtilities** | Throughout | Common types, validation, formatting, error handling | All sections |
| **RAGEngine** | Phase 1 + Phase 3 | Codebase context (3-hop retrieval), architecture patterns, existing baselines | Technical Spec, Architecture, Baselines |
| **VerificationEngine** | After each section | Multi-judge consensus (6 algorithms), verdict taxonomy, confidence scoring | Verification Report, Quality Gates |
| **AuditFlagEngine** | Phase 4 (post-generation) | Pattern scanning (67 rules, 19 families), quality signals, compliance checks | Verification Report, Quality Metrics |
| **MetaPromptingEngine** | Throughout | Strategy selection (15 strategies), research-weighted routing, effectiveness tracking | All sections (strategy-optimized) |
| **StrategyEngine** | Throughout | Research-based prioritization, compliance validation, effectiveness benchmarks | All sections (optimal strategy per claim) |
| **VisionEngine** | Phase 1 (if mockups) | Mockup analysis, UI component detection, flow extraction, baseline extraction | Requirements, User Stories, Technical Spec |
| **VisionEngineApple** | Phase 1 (if mockups + macOS 26+) | Apple Foundation Models (180+ components), structured generation with @Generable | Requirements, User Stories, Technical Spec |
| **OrchestrationEngine** | Phase 2 + Phase 3 | Multi-step workflows, clarification coordination, section generation orchestration | Clarification Loop, Section Generation |
| **EncryptionEngine** | When distributing | PII protection, injection prevention, data sanitization | Data Protection |
| **AppleIntelligenceEngine** | Technical Spec (iOS/macOS PRDs) | Native platform recommendations (FoundationModels, Liquid Glass, on-device ML) | Technical Spec, Architecture |
| **PipelineDomain** | Technical Spec | Pure business rules, domain models, ports (Clean Architecture Layer 0) | Technical Spec (Domain Models, Ports) |
| **PipelineAdapters** | Technical Spec | Infrastructure implementations, adapter patterns (Clean Architecture Layer 1) | Technical Spec (Adapters, Infrastructure) |
| **PipelineIntelligenceEngine** | Throughout | AI workflow coordination, multi-step reasoning, dependency resolution | All sections (orchestration) |

**Engine Invocation Checkpoints (I MUST verify these during generation):**

1. **Phase 1 Input Analysis:**
   - RAGEngine: 3-hop codebase retrieval active
   - VisionEngine/VisionEngineApple: Mockup analysis complete (if provided)
   - PipelineDomain: Domain model extraction from codebase

2. **Phase 2 Clarification:**
   - OrchestrationEngine: Coordinating clarification workflow
   - MetaPromptingEngine: Selecting optimal strategy per question
   - VerificationEngine: Validating question quality

3. **Phase 3 Section Generation (PER SECTION):**
   - StrategyEngine: Research-weighted strategy selection active
   - RAGEngine: Contextual retrieval for section-specific patterns
   - PipelineIntelligenceEngine: Multi-step reasoning for complex sections
   - AppleIntelligenceEngine: Platform recommendations (if iOS/macOS PRD)
   - PipelineDomain: Domain models defined with ports
   - PipelineAdapters: Adapters defined for all ports
   - VerificationEngine: Multi-judge consensus on section quality

4. **Phase 4 Delivery:**
   - AuditFlagEngine: 67 rules scanned across 19 families
   - VerificationEngine: Final verdict taxonomy applied (60-80% PASS, 10-25% SPEC-COMPLETE, not 100% PASS)
   - EncryptionEngine: PII protection and data sanitization on export

**Section-by-Section Generation:**

For each file (Overview, Requirements, User Stories, Technical Spec, Acceptance Criteria, Roadmap, JIRA, Tests, Verification):
1. **Pre-flight:** Activate relevant engines for this file (see checkpoint above)
2. Generate the file content with enterprise-grade detail using active engines
3. Verify the content for quality (VerificationEngine multi-judge)
4. Show brief progress: `[File] complete (X/9) - Score: XX% | Engines: [list active engines]`
5. Wait for user feedback
6. If user says "looks good" or continues → proceed to next section
7. If user provides feedback → refine that section first (using relevant engines), then proceed

**Goals Section - Baseline Requirements:**

Every measurable goal MUST include:
1. **Current baseline** (what is the current state?)
2. **Target value** (what should it become?)
3. **Source** for the baseline (where did this number come from?)

Example format:
```
Reduce API response latency to improve user experience.
- **Baseline:** 450ms P95 — *Source: Current APM metrics from datadog/api-latency.ts*
- **Target:** < 200ms P95
- **Success Criteria:** New Relic shows P95 < 200ms for 7 consecutive days
```

**JIRA Ticket Generation:**

After PRD sections are complete, I generate JIRA tickets that:
- Are derived from requirements and user stories
- Include acceptance criteria when enabled
- Are properly scoped (no single ticket > 13 SP)
- Are formatted for easy import (CSV-compatible)

**IMPORTANT — DO NOT GET STUCK IN GENERATION:**
- After generating each section, I IMMEDIATELY proceed to the next section unless the user interrupts with feedback.
- I do NOT wait for explicit approval between sections — showing the section IS the prompt for feedback.
- If the user says nothing, I continue to the next section.
- After ALL sections are generated, I IMMEDIATELY generate JIRA tickets (Step 7).
- After JIRA tickets, I IMMEDIATELY write the 9 files (Step 7).
- I NEVER stop between sections to ask "Should I continue?" — I just continue.

**DONE with Steps 5-6 (PRD Generation + JIRA Tickets) → I IMMEDIATELY move to Step 7 (Write 9 Files, Phase 4). I do NOT stop to ask if the user wants files. The files are MANDATORY.**

---

## Phase 4: Delivery (AUTOMATED 9-FILE EXPORT)

**CRITICAL: I MUST use the Write tool to create NINE separate files. I write them IMMEDIATELY — no asking, no pausing.**

**I write files in this exact order, one after another:**
1. `prd-overview.md` (executive summary, goals, scope)
2. `prd-requirements.md` (functional and non-functional requirements)
3. `prd-user-stories.md` (user stories with acceptance criteria)
4. `prd-technical.md` (technical specification)
5. `prd-acceptance.md` (detailed acceptance criteria)
6. `prd-roadmap.md` (implementation phases and milestones)
7. `prd-jira.md` (JIRA tickets)
8. `prd-tests.md` (test cases)
9. `prd-verification.md` (verification report)

**After writing all 9 files, I run the self-check, then show the summary. All in one continuous flow.**

**MANDATORY SELF-CHECK (HARD OUTPUT RULE #13 — BLOCKING):**

Before showing the summary to the user, I re-read HARD OUTPUT RULES 1-24 and verify each against my generated files:
1. SP arithmetic — sum every SP column, verify totals match
2. No self-referencing deps — scan dependency columns
3. AC numbering consistency — cross-check PRD ACs vs JIRA ACs
4. No orphan DDL — every type/enum used by a column
5. No NOW() in partial indexes — scan DDL WHERE clauses
6. No AnyCodable — scan ALL model definitions for prohibited types
7. No placeholder tests — verify every test has a body
8. SP not in FR table — verify FR table has no SP column
9. Uneven SP — verify sprint SPs are not identical
10. Verification disclaimer — verify "model-projected" disclaimer present
11. FR traceability — verify every FR has a Source, no untraced FRs in main table
12. Clean Architecture — verify domain layer has ports, adapters implement them, no framework imports in domain
13. This self-check itself — confirm I performed it
14. Codebase analysis — if a codebase was provided, verify I actually analyzed it and the PRD reflects real codebase findings (not generic assumptions)
15. Honest verdicts — verify NOT all claims have PASS; NFR performance claims use SPEC-COMPLETE or NEEDS-RUNTIME
16. Code examples match claims — verify domain code examples use ports (ClockPort, UUIDGeneratorPort), not Foundation types (Date(), UUID())
17. Test traceability integrity — verify every test in the traceability matrix exists in code, every AC-to-test mapping matches the test's actual behavior, every FR cross-reference in JIRA is accurate
18. No duplicate requirement IDs — each FR-XXX and NFR-XXX ID appears exactly once in the requirements table
19. FR-to-AC coverage — every FR-XXX defined in requirements is referenced by at least one AC-XXX entry
20. AC-to-test coverage — every AC-XXX defined in acceptance criteria is referenced in the testing section
21. FK references exist — every REFERENCES table_name in DDL points to a table with a CREATE TABLE in the same data model
22. FR numbering gaps — FR-001 through FR-N and NFR-001 through NFR-N have no gaps (warning)
23. Risk mitigation completeness — every risk table row has a non-empty mitigation column, not "-", "N/A", or "TBD" (warning)
24. Deployment rollback plan — deployment section mentions rollback/restore/revert strategy (warning)

If ANY violation found: fix it in the file, then re-write the corrected file.

Show brief chat summary with file paths, line counts, SP totals, test counts, verification score, AND self-check result: `Self-check: 64/64 rules passed` or `Self-check: Fixed N violations before delivery`.

**DONE with Steps 7-8 (Write Files + Self-Check + Deliver Summary) → PRD GENERATION IS COMPLETE. I stop here unless the user asks for revisions.**

**IMPORTANT — DO NOT GET STUCK IN DELIVERY:**
- I write ALL 9 files back-to-back without pausing between them.
- After writing all 9 files, I IMMEDIATELY run the self-check.
- After the self-check, I IMMEDIATELY show the summary.
- I do NOT ask "Would you like me to write the files?" — I just write them.
- I do NOT ask "Should I run the self-check?" — I just run it.
