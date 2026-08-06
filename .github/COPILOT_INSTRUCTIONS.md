# QSC Copilot Instructions

Last updated: 2026-08-06

## 開發前必讀（Mandatory Pre-Read）

在修改任何程式碼（尤其是 Dart 檔案）前，必須先閱讀並確認理解下列文件：

- `docs/QSC_RULES.md`
- `docs/QSC_AI_RULES.md`
- `docs/QSC_V3_ARCHITECTURE.md`
- `docs/QSC_V3_TODO.md`
- `docs/QSC_CURRENT_PHASE.md`

確定變更不違反上述文件規範；若有衝突或疑慮，先在 `docs/QSC_V3_TODO.md` 建立條目並通知核心團隊。

## 架構限制（Architecture Constraints）

專案層級固定（由上而下）：

UI Layer
↓
UseCase
↓
Repository
↓
Service
↓
External Platform

嚴格禁止跨層或跳層存取，例如：

- UI 直接呼叫 Service（禁止）
- UI 直接操作 Supabase（禁止）
- Repository 放置 UI 邏輯（禁止）
- Model 放置商業邏輯（禁止）

如需例外（極少數情況），必須提出 RFC 並在 `docs/QSC_V3_TODO.md` 記錄，且取得核心團隊核准。

## 修改規則（Modification Rules）

當發現問題時，依情況處理：

1. 可以修正：
	- 直接修改程式碼（遵守架構限制），並在 PR 與專案 CHANGELOG 中記錄變更與理由。

2. 暫不修改（不可立即變更或需更高階決策）：
	- 必須在 `docs/QSC_V3_TODO.md` 新增 TODO 條目，內容包含：問題描述、重現步驟、影響範圍、建議處理方式、優先度、負責人（若已指派）。

不得遺留臨時修補、不完整註解或直接繞過架構以達成短期目的。

## 產品限制（Product Constraints）

核心定位："戒菸只是開始，健康生活才是目標"。所有功能、文案與資料設計不得偏離此定位。

禁止以下任何形式的內容或方向：

- 將產品改為純粹的戒菸工具（單一功能化）
- 與菸品促銷或贊助相關的內容
- 替代菸品（如加熱菸、電子煙等）之推廣或教學內容

若有延伸或調整定位的建議，請以產品提案形式提交並在 `docs/QSC_V3_TODO.md` 記錄，待產品及核心團隊評估。

## Content 規則（Content Source & Cache）

- Supabase 為主要資料來源（source of truth），應優先查詢與同步。
- Local Cache 僅做為 fallback 或暫存以提升效能，**不得**視為權威資料來源。
- 讀取流程：
  1. 嘗試從 Supabase 取得資料
  2. 若 Supabase 無法回應或該資料不存在，使用 Local Cache
  3. 當從 Supabase 成功取得資料時，更新 Local Cache

若某內容非 Supabase 提供，需在 TODO 中註明來源與同步策略。

## 完成修改後（After Changes）

每次完成修改並合併前，必須執行：

- `flutter analyze` 並修正分析中發現的問題（若為 false-positive，請在 TODO/PR 中說明理由）
- 更新 `CHANGELOG`，記錄重要變更與影響範圍
- 更新 `docs/QSC_V3_TODO.md` 中相關 TODO 的狀態（已完成、延後、分派等）

## 注意事項

- 不要修改 Dart 檔案以外的規範所禁止之內容—若需大型重構或跨層調整，請先建立 TODO 並取得核准。
- 此檔案為 Copilot 與自動化工具遵循的指引之一；保持簡潔並於規範變更時同步更新此檔。

## Delivery Checklist（合併前檢查）

- [ ] 已閱讀並確認所有「開發前必讀」文件
- [ ] 變更遵守架構限制與 Content 規則
- [ ] 若發現不可立即修正之問題，已在 `docs/QSC_V3_TODO.md` 建立條目
- [ ] 已執行 `flutter analyze`
- [ ] 已更新 `CHANGELOG`
- [ ] 已更新 TODO 狀態

