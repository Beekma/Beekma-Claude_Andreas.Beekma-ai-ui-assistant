# Architecture Decisions

This document captures key architectural decisions for the AI UI Assistant.
Format follows the ADR (Architecture Decision Record) pattern.

---

## ADR-001: Knowledge Base as JSON file, not in database

**Status**: Accepted
**Date**: 2026-05-02

### Context

The assistant needs domain knowledge about UI elements, statuses and rules.
Two options were considered: (a) store knowledge in MariaDB, or (b) store
it as a versioned JSON file in the repository.

### Decision

Knowledge Base is stored as `knowledge_base/kb.json` in Git.

### Rationale

- Versioning, diff and review come for free with Git.
- Knowledge changes are visible in pull requests, not hidden in DB rows.
- Editable in any text editor; no DB tooling required.
- Human-readable - acts as documentation at the same time.
- The MVP scope (~10-20 entries) does not justify the overhead of a DB layer.

### Consequences

- Changes require a Git commit, not a UI form.
- Acceptable trade-off for MVP. A migration to DB-backed KB stays an
  option for a future phase.

---

## ADR-002: System prompts versioned in database

**Status**: Accepted
**Date**: 2026-05-02

### Context

The system prompt is the primary control surface for the LLM behaviour.
It needs to be tunable without redeployment and changes need to be
auditable.

### Decision

Prompts are stored in a `prompts` table in MariaDB with full version
history. The maintainer can edit and activate versions through a
dedicated UI.

### Rationale

- Tuning the prompt is iterative work that should not require a deployment.
- Every version is preserved, enabling rollback and comparison.
- Audit trail (who changed what when) is essential for governance.
- Different from the Knowledge Base because prompts change more often
  and benefit from runtime editing.

### Consequences

- Requires a maintainer authentication layer.
- Database schema must support versioning and active-flag semantics.

---

## ADR-003: HTTP Basic Auth for maintainer area (Phase 1)

**Status**: Accepted (interim solution)
**Date**: 2026-05-02

### Context

The maintainer area must be protected. A full login system with
sessions, password reset and account management is significant
scope for the MVP.

### Decision

Phase 1 uses HTTP Basic Auth with credentials stored as a hash in
the `.env` file. Phase 2 will introduce session-based authentication
with the credentials persisted in the database.

### Rationale

- Phase 1 protects the area in minutes with very few lines of code.
- Sufficient for a single maintainer (the project owner).
- Phase 2 becomes a portfolio item in itself: implementing
  authentication with sessions and password hashing.

### Consequences

- The Phase 1 setup is intentionally minimal. The migration path to
  Phase 2 is documented and deliberately scheduled.
