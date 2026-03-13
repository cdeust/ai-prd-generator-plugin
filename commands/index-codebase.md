---
name: index-codebase
description: Index a codebase directory for RAG-enhanced PRD generation
allowed-tools: Bash, Read, Write, Glob, Grep, WebFetch
argument-hint: "[directory-path-or-github-url]"
---

# Index Codebase

## Step 1 — Detect mode

Check your available tools list. If a tool named `mcp__ai-prd-generator__check_health` exists, you are in **Cowork mode**. Otherwise you are in **CLI Terminal mode**.

**Cowork mode:**

Call `check_health` MCP tool. Note the `environment` field:
- `environment: "cli"` → Local directory access. Use `$ARGUMENTS` as the target path.
- `environment: "cowork"` → The plugin analyzes codebases from **locally shared directories**. If the user has shared a project folder, use Glob/Grep/Read to index it directly. If no directory is shared and `$ARGUMENTS` is a GitHub URL, try WebFetch as a fallback (may time out). If neither works, ask the user to share the project directory with the Cowork session.

## CLI Terminal Mode

Use `$ARGUMENTS` as the target directory path. If not provided, ask the user for the codebase path to index.

Verify the directory exists, then perform the indexing workflow:

1. **Scan** the directory for source files (respecting .gitignore patterns)
2. **Extract** code patterns: Repository, Service, Factory, Observer, Strategy, MVVM, Clean Architecture
3. **Identify** entities, interfaces, and dependency relationships
4. **Summarize** the codebase structure for RAG context

For GitHub repositories:
- Use `gh api repos/{owner}/{repo}/git/trees/main?recursive=1` to get file structure
- Use `gh api repos/{owner}/{repo}/contents/{path}` to fetch specific file contents
- For private repos: ensure `gh auth login` is completed first

## Cowork Mode

The plugin analyzes codebases from **locally shared directories** in Cowork. This is the primary and most reliable method.

1. **Shared directory (PRIMARY):** If the user has shared a project folder, use Glob/Grep/Read to scan and index it — same workflow as CLI mode
2. **WebFetch fallback:** If no local directory is shared and `$ARGUMENTS` is a public GitHub URL, try WebFetch to retrieve the repo structure, README, and key files (may time out)
3. **Ask the user:** If neither method works, ask the user to share the project directory with the Cowork session, or paste key source files
4. Extract patterns and entities from the provided context
5. Summarize the codebase structure for RAG context

Store the indexed context so subsequent PRD generation can reference it for:
- Architecture-aware technical specifications
- Accurate dependency mapping
- Existing pattern detection and reuse recommendations
- Integration point identification

Report the indexing results:
```
Codebase Indexed
Source:     [directory path | GitHub URL | user-provided]
Files:      [count] source files analyzed
Patterns:   [list of detected patterns]
Entities:   [count] extracted
RAG Depth:  [context-aware hop count]
Mode:       [cli | cowork]
```
