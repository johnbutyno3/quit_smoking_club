# QSC Engineering Rules

Last updated: 2026-08-06

## Product Principles

- QSC is a long-term healthy lifestyle companion, not only a quit-smoking timer.
- Keep the product supportive, low-friction, and community-friendly.
- Prioritize user trust, data safety, and predictable behavior over speed hacks.

## Architecture Principles

- Keep architecture stable and evolve incrementally.
- Apply the layering path consistently: UI -> UseCase -> Repository -> Service -> External platform.
- Do not bypass layers to make short-term fixes.
- Any unfinished issue discovered during implementation must be recorded in docs/QSC_V3_TODO.md.

## Firebase Responsibility

- Authentication and account identity.
- Private user profile and personal quit-smoking records.
- User-specific settings and personal state synchronization.
- Firebase is not the source for public community/content systems.

## Supabase Responsibility

- Forum and community public data.
- Content distribution (articles, stories, music, links, reading assets).
- Public statistics and shared datasets.
- Supabase is the primary source for public content modules.

## Flutter Layering Rules

- Screens and widgets handle rendering and interaction only.
- UseCases hold business flows and transactional decisions.
- Repositories orchestrate data sources and shape domain-ready data.
- Services talk to external systems (Firebase, Supabase, APIs).
- UI must never directly access databases.

## Localization Rules

- Every user-facing string must use localization keys.
- Hardcoded UI strings are not allowed in production flows.
- When adding visible text, update ARB files and regenerate l10n output.

## Development Workflow

Before coding:

1. Read docs/QSC_RULES.md.
2. Read docs/QSC_CURRENT_PHASE.md.
3. Read docs/QSC_V3_TODO.md.
4. Confirm current sprint and allowed scope.

During coding:

1. Keep changes minimal and scoped.
2. Do not refactor unrelated modules.
3. Do not create duplicate services.

After coding:

1. Run flutter analyze.
2. Update TODO status and add newly discovered unfinished work.
3. Update docs/QSC_CHANGELOG.md when process or architecture documents change.
4. At the end of each workday, update docs/QSC_V3_TODO.md.
5. If rules or guard process changed, update docs/QSC_RULES.md and guard docs.
- Trigger
- Dependency
- File
- Current status
- Risk


---

# 11. AI Development Rules

AI 工具包含：

- ChatGPT
- Copilot
- 其他 AI Agent


執行修改前必須：

- 先閱讀專案規範
- 確認目前 Sprint
- 對應 TODO


禁止：

- 自行重構架構
- 刪除既有功能
- 建立重複系統
- 跳過審核流程


---

# 12. Change Management

重要修改後：

必須更新：

QSC_CHANGELOG.md


內容包含：

- 修改內容
- 修改原因
- 影響範圍
- 驗證結果


---

# 13. Final Principle

QSC 的目標：

建立全球化健康陪伴平台。


技術服務產品，而不是產品被技術限制。


所有開發決策優先考慮：

1. 使用者體驗
2. 長期維護
3. 架構穩定
4. 全球化能力