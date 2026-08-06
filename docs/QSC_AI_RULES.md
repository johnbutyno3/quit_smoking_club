# QSC AI 開發約束規範

此文件為 AI 相關開發時必讀的約束與流程，所有專案貢獻者在修改程式前必須遵守以下規範。**請勿直接修改任何 Dart 程式檔**（除非有明確例外並事先獲得同意）。

## 1. 修改程式前必讀
- 請先閱讀以下專案文件，確保理解設計與限制：
  - `docs/QSC_RULES.md`
  - `docs/QSC_V3_ARCHITECTURE.md`
  - `docs/QSC_V3_TODO.md`
  - `docs/QSC_CURRENT_PHASE.md`

在開始修改任何程式碼前，確認變更與上述文件不衝突；若有衝突，先回報並更新對應文件或 TODO。

## 2. 架構固定（嚴格禁止跳層）
專案架構層級（由上而下）必須維持：

UI Layer
↓
UseCase
↓
Repository
↓
Service
↓
External Platform

- 嚴禁跨層直接存取或呼叫：「UI 直接呼叫 Service/External Platform」或「UseCase 直接存取 External Platform」等行為皆不允許。
- 若因特殊情形必須跨層，必需提出 RFC 並記錄在 `docs/QSC_V3_TODO.md`，取得核心團隊核准後方可例外實作。

## 3. 發現問題但不修改的流程
- 如果在程式碼或設計中發現問題（bug、設計違背、資料來源異常等），但您不得或不應該在當下修改：
  - 必須在 `docs/QSC_V3_TODO.md` 中新增 TODO 條目，說明：問題描述、重現步驟、影響範圍、建議處理方式與優先度。
  - TODO 條目格式請包含負責人（若已指派）、預估影響版本、是否為 blocker。
  - 不得在 TODO 中留下個人草稿式或不具可執行資訊的描述；以利接手者直接採取行動。

## 4. 禁止硬編碼 UI 中文
- 所有 UI 字串不得硬編碼中文於程式或佈局中。必須使用 localization key（專案的 l10n 機制）來管理字串。
- 新增或變更顯示文字時，請同步更新 localization 檔案並在 PR 說明中列出涉及的 key。
- 測試或暫時性文字也不得硬編碼；使用開發用 key 並在 TODO 中標註為暫時。

## 5. Content 規則（資料來源與快取策略）
- Supabase 為主要資料來源（source of truth）。所有內容讀取應以 Supabase 為第一優先來源。
- Local Cache 僅作為 fallback 與效能優化的暫存層，**不得**視為權威資料來源。
- 讀取順序範例：
  1. 嘗試從 Supabase 取得最新資料
  2. 若 Supabase 無法回應或該資料不存在，才使用 Local Cache
  3. 當從 Supabase 成功取得資料時，應更新 Local Cache（以保持一致性）
- 若某類內容非 Supabase 提供，需在 `docs/QSC_V3_TODO.md` 註明來源與同步策略。

## 6. 不得改變產品定位
- 專案定位：戒菸為起點，長期目標為『健康生活』。任何功能、文案或資料設計不得偏離此核心定位。
- 若有建議改變定位或延伸新方向，請提出產品提案並記錄於 `docs/QSC_V3_TODO.md`，經產品主管與核心團隊評估通過後方可執行。

---

如遇到與上述規範衝突的情形，請先在 `docs/QSC_V3_TODO.md` 建立條目並通知核心團隊，不要直接繞過或修改現有程式以達成短期目的。