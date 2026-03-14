# Output Formats — File Specifications

## Verification File Format

**The `prd-verification.md` file leads with irrefutable structural checks and clearly separates facts from projections.**

**Rule: The report MUST be structured in tiers of decreasing objectivity. Deterministic checks first, model projections last.**

**Rule: In CLI Terminal mode (without the verification engine binary), all algorithm/strategy metrics (LLM call counts, judge counts, variance values, verification times, cost savings) are model-projected based on algorithm design parameters, NOT runtime telemetry. The verification report MUST include this disclaimer near the top: "Note: Metrics are model-projected based on algorithm design parameters. Runtime telemetry is available when using the verification engine binary."**

**Required Report Structure (in this order):**

**Section 1: STRUCTURAL INTEGRITY (deterministic — anyone can re-run these checks)**

This section contains ONLY checks that are reproducible and non-contestable:
- Hard Output Rules: X/24 passed (list each rule with pass/fail and evidence)
- SP Arithmetic: manual sums verified
- Cross-References: X defined, Y referenced, Z orphans
- Dependency Graph: acyclic (or list cycles)
- FR Traceability: X/X have Source column
- AC-to-Test Mapping: X/Y ACs have matching tests (verified test names exist in code)

**Section 2: CLAIM VERIFICATION LOG (verdict taxonomy applied)**

Every claim logged with the honest verdict taxonomy from Hard Output Rule #15. The verdict distribution MUST reflect reality — performance NFRs get SPEC-COMPLETE, claims depending on open questions get INCONCLUSIVE.

**Expected verdict distribution for a typical PRD:**
- PASS: 60-80% (structural completeness, FR/AC traceability, architectural compliance)
- SPEC-COMPLETE: 10-25% (performance NFRs, scalability claims, storage estimates)
- NEEDS-RUNTIME: 2-10% (load test results, p95 under production traffic)
- INCONCLUSIVE: 1-5% (claims referencing OQ-XXX, vendor-dependent items)
- FAIL: 0% after self-check corrections (any FAILs should be fixed before delivery)

A report with 100% PASS verdicts is REJECTED. It means the verdict taxonomy was not applied.

**Section 3: PIPELINE ENFORCEMENT DELTA (measured before/after)**

Pre-enforcement vs post-enforcement hard rules results. How many violations were caught and corrected by retry. This is measured per-run data, not assumed.

**Section 4: AUDIT FLAGS (pattern-level quality signals — deterministic)**

The Audit Flag Engine scans the generated PRD for patterns that "smell wrong" — uncited thresholds, suspicious precision, verdict-evidence mismatches, missing sections, statistical implausibility. Flags are metadata annotations that NEVER change verdicts or scores. The flag rate itself is a quality signal.

- **0 flags on >5 claims**: Suspiciously clean — may indicate the audit engine is not finding patterns it should
- **10-20% flag rate**: Expected for a typical PRD — some patterns will always be flagged
- **>50% flag rate**: Needs work — document has many quality signals to address

The report includes: total flags, claims scanned, flag rate, flags grouped by family (CITE, PREC, STAT, MISMATCH, CONS, TEST, BA, PO, PM, SM, STAKE, CEO, TECH, DEV, OPS, UX, MLAI, FREE, CM), and suggested actions for each flag.

Each flag entry shows:
- Rule ID (e.g., `CITE-001`)
- Finding: what was detected and why it's flagged
- Suggested action: what to fix
- Offending content snippet

**Rule: Audit flags do NOT block delivery. They are advisory quality signals. The author (human or AI) decides whether to act on each flag. However, a 0% flag rate on >5 claims SHOULD be noted as suspicious in the verification summary.**

**Section 5: OPERATIONAL METRICS (formula-derived, formulas shown)**

Token counts, LLM calls, time, cost — each with a visible formula. Example:
- "Tokens: 34,291 actual vs 56,000 estimate [formula: 8000 + 8×4000 per section]"
- "LLM Calls: 11 actual vs 16 estimate [formula: 8 sections × 2 calls/section]"

**Cost Efficiency:** Compare against a defined hypothetical baseline with explicit methodology. Use conditional language: "Compared to a naive N-judge consensus pipeline, the adaptive pipeline would use ~X% fewer calls." Do NOT state savings as fact without defining the counterfactual.

**Section 6: STRATEGY EFFECTIVENESS (with variance)**

Each strategy shows claims processed, confidence delta, and effectiveness. If strategy assignment is optimized per-claim (targeted routing), state this explicitly: "Strategy assignment is optimized per-claim via research-weighted selection, so negative deltas are not expected in targeted routing." If ANY strategy shows marginal impact (< 2% delta), report it honestly rather than inflating.

**Section 7: MODEL-PROJECTED QUALITY (advisory — clearly labeled)**

Any LLM-assessed quality score MUST be in this section (never in Section 1). Label as: "Model self-assessed quality. Not independently validated. Self-assessment by the generating model."

Do NOT present these scores with false precision (e.g., "Quality: 0.9134"). Round to one decimal: "~91%". Do NOT compare against undefined baselines like "naive LLM PRD (0.55)" without defining: which model, which prompt, which dataset, who measured it.

If baselines are expert estimates, state it: "Baseline: ~55% (expert estimate for single-pass LLM generation without verification — no independent benchmark)."

**Section 8: RAG Engine Performance** (if codebase indexed)

**Section 9: Issues Detected & Resolved**

**Section 10: Limitations & Human Review Required**

**Section 11: Value Delivered** (always last)

---

## Value Delivered (ALWAYS END WITH THIS SECTION)

**This section MUST be the LAST section of the verification report.** Include: What This PRD Provides (deliverable/status/business-value table), Quality Metrics Achieved (metric/result/benchmark table), Ready For checklist (stakeholder review, Sprint 0, technical deep-dive, JIRA import), and Recommended Next Steps (stakeholder review → Sprint 0 → Sprint 1 kickoff).

---

## JIRA File Format

**The `prd-jira.md` file MUST contain:**

**Rule: Story point distribution across sprints/epics MUST reflect actual complexity differences. NEVER distribute SP evenly (e.g., 13/13/13/13) — real projects have uneven distributions.**

**Rule: Self-referencing dependencies are FORBIDDEN. A story MUST NOT list itself as a dependency.**

**Rule: JIRA Summary table arithmetic MUST be verifiable. The "Total" row MUST equal the arithmetic sum of individual story SPs listed in the table. Sprint allocation SP MUST also sum to the same total. Before finalizing, manually add up all story SP values and verify they match the stated total. If they don't match, fix them.**

**Rule: JIRA AC IDs MUST reference the PRD's AC numbering. Do NOT create independent AC numbering in the JIRA file. If PRD AC-001 is "Create Snippet — Happy Path", then JIRA must reference that same AC-001, not renumber it. This ensures cross-references are consistent across all 9 output files.**

**Required JIRA file structure:** Header (project name, date, total SP, estimated duration), Epics with SP totals, Stories (type/priority/SP, user story description, ACs referencing PRD AC-XXX IDs with GIVEN-WHEN-THEN + baseline/target/measurement/impact, task breakdowns, dependencies, labels), Summary table (story/title/SP/priority/sprint with verified totals), and CSV Export section for JIRA import.

---

## Tests File Format

**The `prd-tests.md` file MUST be organized in 3 parts:**

| Part | Purpose | Audience |
|------|---------|----------|
| **PART A: Coverage Tests** | Code quality (unit, integration, API, UI) | Developers |
| **PART B: AC Validation Tests** | Prove each AC-XXX is satisfied | Business + QA |
| **PART C: Traceability Matrix** | Map every AC to its test(s) | PM + Auditors |

---

**PART A: Coverage Tests Structure**

**Rule: Every test method in PART A MUST have a FULL implementation with Given/When/Then setup, action, and XCTAssert* assertions. NEVER generate stub methods with only comments like `// Setup: snippet at version 3` or `// 50 valid DTOs → all 50 created`. If a test requires complex setup that cannot be fully specified, write the complete test body with concrete values and mark the test as `// INTEGRATION: requires running database` instead of leaving the body as comments. The test count in the file header MUST only count fully implemented test methods, not stubs.**

Standard test organization by layer:
- Unit Tests: Domain entities, services, utilities
- Integration Tests: Repository, external services
- API Tests: Endpoint contracts, error responses
- UI Tests: User flows, accessibility

---

**PART B: AC Validation Tests (CRITICAL)**

**Every AC from the PRD MUST have a corresponding validation test.**

For each AC, the test section MUST include:

| Element | Description |
|---------|-------------|
| AC Reference | AC-XXX with title |
| Criteria Reminder | The GIVEN-WHEN-THEN from PRD |
| Baseline/Target | From AC's KPI table |
| Test Description | What the test does to validate |
| Assertions | Specific checks that prove AC is met |
| Output Format | Log line for CI artifact collection |

**Test naming convention:** `testAC{number}_{descriptive_name}`

**Performance Test Methodology (CRITICAL):**

XCTest `wait(for:timeout:)` is a maximum wait, NOT a p95 assertion. A single-run timeout only fails if that one run exceeds the threshold. For p95 latency tests, I MUST use iteration-based measurement:
```swift
func testSearchLatencyP95() {
    let iterations = 100
    var durations: [TimeInterval] = []
    for _ in 0..<iterations {
        let start = CFAbsoluteTimeGetCurrent()
        // ... perform operation ...
        durations.append(CFAbsoluteTimeGetCurrent() - start)
    }
    durations.sort()
    let p95Index = Int(Double(iterations) * 0.95)
    let p95 = durations[p95Index]
    XCTAssertLessThan(p95, 0.5, "p95 latency \(p95)s exceeds 500ms target")
}
```
I NEVER use a single `wait(for:timeout:)` call as a performance assertion.

**AC Validation Categories:**

| Category | What Tests Validate |
|----------|---------------------|
| Performance | Latency p95 (iteration-based), throughput under load |
| Relevance | Precision@K, recall on validation set |
| Security | RLS isolation, auth enforcement |
| Functional | Business logic correctness |
| Reliability | Error handling, recovery |

---

**PART C: Traceability Matrix (MANDATORY)**

A table linking every AC to its validating test(s):

| Column | Description |
|--------|-------------|
| AC ID | AC-001, AC-002, etc. |
| AC Title | Short description |
| Test Name(s) | Test method(s) that validate this AC |
| Test Type | Unit, Integration, Performance, Security |
| Status | Pending, Passing, Failing |

**Rule: No AC without a test. No orphan ACs allowed.**

**Rule: Tests MUST NOT silently resolve open questions.** If the PRD lists an open question (OQ-XXX) — e.g., "Should tag search use AND or OR logic?" — and a test assumes one answer (e.g., uses `allSatisfy` for AND logic), the test MUST include a comment: `// ASSUMES: OQ-001 resolved as AND logic. Update if resolved differently.` A test that silently picks one resolution misleads reviewers into thinking the question is answered.

---

**Test Data Requirements Section**

| Element | Description |
|---------|-------------|
| Dataset Name | Identifier for the test fixture |
| Purpose | Which AC(s) it validates |
| Size | Number of records |
| Location | Path to fixture file |

---

## Complexity Rules (Determines Algorithm Activation)

| Complexity | Score Range | Algorithms Active |
|------------|-------------|-------------------|
| SIMPLE | < 0.30 | #1, #4, #5, #6 |
| MODERATE | 0.30 - 0.55 | + #2 Graph |
| COMPLEX | 0.55 - 0.75 | + NLI hints |
| CRITICAL | ≥ 0.75 | ALL including #3 Debate |
