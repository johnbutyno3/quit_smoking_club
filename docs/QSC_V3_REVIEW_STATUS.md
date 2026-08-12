# QSC V3 Review Status

最後更新：2026-08-12

本文件將既有架構 review notes 與目前 `v3-main` 實作對齊。

---

## 已落地的規範

- Localization 使用既有 l10n 架構。
- Feature workflow 已逐步導入 UseCase。
- Repository 作為資料來源邊界。
- 公開內容統一由 ContentRepository 進入 Supabase。
- Reading 保留獨立 ReadingRepository，因 Book / Chapter 是不同 domain 結構。
- COIN balance 以 Firebase 為 source of truth。
- Supabase 僅保存 COIN transaction logs。
- Forum 不直接由 UI 操作 Supabase。
- 內建 Games（2048 / Sudoku）與公開 Games Content 分離；遊戲本體不得進入 ContentRepository。

---

## 不再列為架構問題

以下不是 V3 deviation：

1. Reading 使用獨立 Repository / Service。
2. Firebase 與 Supabase 同時存在。
3. COIN balance 在 Firebase、transaction log 在 Supabase。
4. Forum 使用 Supabase 而帳號 / 私人資料使用 Firebase。
5. 內建遊戲使用本地 Flutter 頁面，不依賴 Supabase content。

這些都是目前 V3 明確的 ownership decisions。

---

## 真正剩餘問題

### P0

#### Game / Navigation regression

- SOS 的 `GameHub` 歷史路徑曾將 `GameHub` 傳入 `MitigationPage`。
- `MitigationPage` 原本會把未知 `GameHub` 解析成 Reading category，最後顯示錯誤的醫學文章載入訊息。
- 已在 `v3-main` 加入防呆：`Games` / `GameHub` 永遠直接進 `GameHubPage`，不進 Content flow。
- 仍需在實機重新驗證 SOS → GameHub → 2048 / Sudoku 全鏈路。

#### Forum

- Forum Like UI count 與 toggle 結果一致性
- Forum Gift persistence
- Forum comment nickname 欄位一致性
- Forum current-user nickname source
- Forum category canonicalization

#### Home navigation

- Home 仍存在一個 `startPlan` 按鈕 callback 僅留下 placeholder 註解、沒有導頁的歷史程式碼。
- 需要在下一個安全修改批次處理，避免為了修單一區塊而重寫整個 HomePage。

---

### P1

- ForumComment typed model
- Forum pagination
- Post / Comment delete policy 統一
- COIN transaction reason canonicalization
- Sudoku / 2048 user-facing text localization
- SetupPage / legacy UI callback 靜態清理

---

## Review Rule

之後 code review 不再重複確認已完成的 V3 分流。

只檢查：

- 新程式是否違反 ownership
- 是否繞過 Repository / UseCase
- 是否破壞 transaction consistency
- 是否新增 hardcoded user-facing text
- 是否產生新的 duplicate data flow
- 是否有實際 bug / regression
- 所有可點擊 UI 是否真的有對應 action

---

## Final Principle

**V3 現在是 Stabilization，不是 Architecture Rewrite。**

任何後續修改都必須以實際 `v3-main` 程式碼與 `QSC_V3_TODO.md` 為基準。
