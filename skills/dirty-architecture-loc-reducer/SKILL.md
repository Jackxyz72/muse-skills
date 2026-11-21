---
name: dirty-architecture-loc-reducer
description: Identify dirty or over-engineered architecture that can be refactored aggressively without behavior loss to achieve significant LOC reduction. Use when asked to audit architecture for simplification, find refactor targets that cut code size, consolidate layers or modules, or deliver findings and a high-impact reduction plan while preserving functionality.
---

# Dirty Architecture LOC Reducer

## Overview
Surface architecture-level redundancy, over-abstraction, and indirection that can be collapsed without behavior change. Produce findings with evidence, estimated LOC savings, and a prioritized refactor plan.

## Workflow

### 1) Confirm scope and invariants
- Confirm target repo, languages, and timebox.
- Lock invariants: no behavior/functionality loss, preserve external APIs unless explicitly allowed, keep tests passing.
- Record do-not-touch areas and risk tolerance.

### 2) Capture baseline size
- Record LOC by language to anchor reduction goals.
- Prefer `tokei` or `cloc`; if unavailable, approximate with `rg --files` + `wc -l`.
- Store the baseline in the report as the "before" snapshot.

### 3) Map the architecture quickly
- Identify core flows, data models, and boundaries (UI/API/domain/persistence).
- Note duplicated pipelines, parallel stacks, or feature slices.
- Sketch a high-level dependency or ownership map (no deep diagramming).

### 4) Hunt dirty-architecture signals
- Flag redundant layer chains (controller -> service -> manager -> adapter -> provider).
- Flag single-use abstractions (interface + one impl, factory/builders used once).
- Flag parallel implementations (two paths doing the same job across modules).
- Flag pass-through wrappers that add no logic.
- Flag config bloat (flags, options, or envs that are static or unused).
- Flag adapter-of-adapter conversion chains and duplicated model mappings.
- Flag custom DSLs/frameworks that replace simple functions or data.
- Flag dead code, unused feature flags, unreachable branches, and stale modules.
- Flag duplicate error types, enums, or data transfer objects.

### 5) Form aggressive refactor candidates
- Collapse layers by inlining or merging modules with overlapping responsibility.
- Consolidate models and remove redundant mappers or translators.
- Replace over-generalized frameworks with straightforward functions or structs.
- Delete dead paths once verified unused by references, tests, and usage.
- Prefer deletion and consolidation over additive "cleanup".

### 6) Estimate impact and risk
- Estimate LOC savings per candidate (rough order-of-magnitude is fine).
- Assign risk (low/medium/high) and list tests or characterization steps.
- Note dependencies between refactors to enable safe sequencing.

### 7) Deliver findings and plan
- Produce a findings-first report with evidence and explicit invariants.
- Provide a short, ordered plan that maximizes LOC reduction early.

## Output Format

### Findings (prioritized)
For each finding, include:
- Title
- Evidence (files, symbols, call sites, usage counts)
- Refactor move (what to delete/merge/inline)
- Expected LOC savings (estimate)
- Behavior invariants to preserve
- Risk and tests to protect behavior
- Dependencies or sequencing notes

### Quick wins
List low-risk, high-delete-count items to build momentum.

### High-impact refactors
List larger but valuable changes with clear safety steps.

### Validation plan
Specify tests, characterization harnesses, or golden-file checks.

## Guardrails
- Avoid recommendations that remove functionality unless explicitly allowed.
- Avoid full rewrites; propose incremental, verifiable steps.
- Mark weakly-evidenced items as "needs verification" rather than assert.
- Keep the report concrete: cite paths and symbols, not generalities.