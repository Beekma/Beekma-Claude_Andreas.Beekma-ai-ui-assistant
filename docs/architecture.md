# Architecture

## Overview

The AI UI Assistant is a thin layer on top of an existing UI showcase.
It uses OpenAI's API as the language model and adds three layers
of control around it:

1. **Knowledge Base** - structured domain information (JSON)
2. **System Prompt** - behavioural constraints for the LLM
3. **Backend Proxy** - rate limiting, caching, logging, security

## Component diagram

```
+-----------------------------------------------------+
|  Frontend                                           |
|  +-- Chat widget (Visitor)                          |
|  +-- Logs dashboard (Maintainer, login)             |
|  +-- Prompt editor   (Maintainer, login)            |
+-----------------------------------------------------+
                         |
                         v  HTTPS
+-----------------------------------------------------+
|  PHP Backend                                        |
|  +-- chat.php        OpenAI proxy                   |
|  +-- logs.php        delivers log entries           |
|  +-- maintainer.php  prompt management              |
|  +-- middleware/                                    |
|       +-- rate_limit.php                            |
|       +-- cache.php          (hash-based)           |
|       +-- auth.php           (HTTP Basic Auth v1)   |
+-----------------------------------------------------+
                         |
                         v
+-----------------------------------------------------+
|  MariaDB                                            |
|  +-- logs            requests, tokens, cost         |
|  +-- prompts         versioned system prompts       |
|  +-- cache           question hash -> answer        |
|  +-- rate_limits     IP + time window               |
+-----------------------------------------------------+
                         |
                         v
              knowledge_base/kb.json
              (versioned in Git)
                         |
                         v
                 OpenAI API
```

## Request flow

```mermaid
sequenceDiagram
    actor Visitor
    participant Frontend
    participant Backend
    participant Database
    participant OpenAI

    Visitor->>Frontend: submits question
    Frontend->>Backend: POST /api/chat
    Backend->>Database: check rate limit
    Database-->>Backend: OK

    Backend->>Database: check cache (question hash)

    alt Cache hit
        Database-->>Backend: cached answer
        Backend->>Database: write log (cache_hit=true)
        Backend-->>Frontend: answer
        Frontend-->>Visitor: displays answer
    else Cache miss
        Database-->>Backend: no cache entry
        Backend->>Database: load active system prompt
        Database-->>Backend: system prompt
        Backend->>Backend: read kb.json
        Backend->>OpenAI: chat completion (prompt + KB + question)
        OpenAI-->>Backend: generated answer
        Backend->>Database: store in cache + write log
        Backend-->>Frontend: answer
        Frontend-->>Visitor: displays answer
    end
```

## Application status lifecycle

```mermaid
stateDiagram-v2
    [*] --> DRAFT

    state "In Review"              as IN_REVIEW
    state "Returned to Applicant"  as RETURNED_TO_APPLICANT
    state "On Hold"                as ON_HOLD

    DRAFT               --> CREATED               : submit
    DRAFT               --> CANCELLED             : cancel

    CREATED             --> IN_REVIEW             : startReview
    CREATED             --> CANCELLED             : cancel

    IN_REVIEW           --> VALIDATED             : validate
    IN_REVIEW           --> RETURNED_TO_APPLICANT : returnToApplicant
    IN_REVIEW           --> ON_HOLD               : putOnHold
    IN_REVIEW           --> CANCELLED             : cancel

    RETURNED_TO_APPLICANT --> CREATED             : submit
    RETURNED_TO_APPLICANT --> CANCELLED           : cancel

    VALIDATED           --> APPROVED              : approve
    VALIDATED           --> REJECTED              : reject

    ON_HOLD             --> IN_REVIEW             : startReview
    ON_HOLD             --> CANCELLED             : cancel

    APPROVED            --> ARCHIVED              : archive
    REJECTED            --> ARCHIVED              : archive
    CANCELLED           --> ARCHIVED              : archive

    ARCHIVED            --> [*]

    classDef decision fill:#fef3c7,stroke:#d97706,color:#000
    class APPROVED,REJECTED,CANCELLED decision
```

## Key principles

- **Knowledge Base in Git, not DB**: human-readable, reviewable,
  versioned alongside the code.
- **System prompts versioned in DB**: editable at runtime through
  the maintainer UI without redeployment.
- **API key only in backend**: never exposed to the browser.
- **Rate limiting at two levels**: per IP per hour + global per day.
- **Caching first**: identical questions are served from DB cache,
  not from OpenAI - cost optimisation.

## Security layers

1. API key isolation (backend `.env` only)
2. Input validation (length, characters)
3. Rate limiting (IP + global)
4. System prompt restricts answer scope
5. Output token limit (200 max)
6. Maintainer area behind authentication
7. Logging of all requests (audit trail)
