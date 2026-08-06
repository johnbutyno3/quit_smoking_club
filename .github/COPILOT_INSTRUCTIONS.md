# QSC Copilot Instructions

Last updated: 2026-08-06

## Mandatory Pre-Read

Before any code change, always read:

1. docs/QSC_RULES.md
2. docs/QSC_CURRENT_PHASE.md
3. docs/QSC_V3_TODO.md

## Mandatory Development Rules

- Do not refactor unrelated modules.
- Do not create duplicate services.
- Do not bypass Repository/UseCase architecture.
- UI must not directly access any database.
- User-facing strings must use localization keys.
- Engineering documentation must be written in English.
- All unfinished work must be recorded in docs/QSC_V3_TODO.md.
- At the end of each workday, update docs/QSC_V3_TODO.md.
- If project rules/process changed, update docs/QSC_RULES.md and related guard documents.

## Delivery Checklist

- [ ] Read all mandatory pre-read documents
- [ ] Confirm current phase and sprint
- [ ] Work only on in-scope priority items
- [ ] Record unfinished items in TODO
- [ ] Run required validation commands
- [ ] End-of-day TODO/rules updates completed
