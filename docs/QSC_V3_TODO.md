# QSC V3 TODO

最後更新：2026-08-12

本文件以 `v3-main` 實際程式碼為準。已完成項目不得反覆列為 TODO。

---

## DONE — 已完成的 V3 基礎工作

- [DONE] Firebase / Supabase content 分流
- [DONE] ContentRepository 統一公開內容入口
- [DONE] Medical / Stories / Music / YouTube 改用統一 content flow
- [DONE] Reading 使用獨立 ReadingRepository + SupabaseReadingService + Local Cache
- [DONE] COIN repository / use case / facade 分層
- [DONE] Forum 發文流程已進入 CreateForumPostUseCase
- [DONE] Forum Like 已進入 Supabase forum_likes toggle 流程
- [DONE] ForumPost 已具備 userId / nickname / category / isSOS 等核心欄位
- [DONE] Localization 架構持續使用，Flutter analyze 已通過

---

## P0 — 現在必須修

### 1. Forum Like UI 計數與 Supabase toggle 不一致
- [TODO]
- 檔案：`lib/screens/forum_page.dart`
- 現況：Repository 已實作 like toggle，但 UI `_handleLike()` 目前固定 `likes + 1`。
- 風險：取消讚時 UI 仍增加，數字會漂移。
- 修正：Repository 回傳新增/取消狀態或最新 count，UI 依實際結果更新。

### 2. Forum Gift 尚未真正持久化
- [TODO]
- 檔案：`lib/repositories/forum_repository.dart`
- 現況：`giftPost()` 目前為 compatibility no-op；UI 會扣 COIN，但沒有 `forum_gifts` persistence。
- 風險：使用者可能被扣 COIN，但送禮沒有資料紀錄。
- 修正：在資料表與 transaction 規格確定後，再接真正 gift persistence；在此之前不要宣稱送禮已完成。

### 3. Forum 留言作者欄位名稱不一致
- [TODO]
- 檔案：`lib/screens/forum_detail_page.dart`
- 現況：建立留言使用 `nickname`，顯示留言卻讀 `comment['userName']`。
- 風險：留言作者可能顯示匿名或錯誤名稱。
- 修正：統一 canonical field 為 `nickname`，並同步資料模型/Repository。

### 4. ForumDetail currentUserName 來源錯誤風險
- [TODO]
- 檔案：`lib/screens/forum_page.dart`
- 現況：開啟詳情頁時將 `post.name` 傳給 `currentUserName`。
- 風險：留言時可能把貼文作者名稱當成目前登入者名稱。
- 修正：從目前登入使用者資料取得 current nickname，不從 post 取得。

### 5. Forum 分類功能尚未真正完成
- [TODO]
- 檔案：`lib/screens/forum_page.dart`
- 現況：UI 有 0~4 五個分類，但 `_filteredPosts` 實際只區分全部 / SOS / 非 SOS。
- 風險：點擊分類後結果不符合分類名稱。
- 修正：建立 canonical ForumCategory，UI、Model、Supabase query 使用同一組值。

### 6. Forum category 不得依賴翻譯文字判斷
- [TODO]
- 檔案：`lib/models/forum_post.dart` / Forum filtering
- 現況：歷史邏輯曾使用中文 category 字串判斷。
- 風險：多語系後會失效。
- 修正：只使用 canonical enum/key，例如 `craving`, `story`, `health`, `support`。

---

## P1 — 下一批

### 7. ForumComment typed model
- [TODO]
- 現況：留言目前仍以 `Map<String, dynamic>` 傳遞。
- 目標：建立 `ForumComment` model，統一欄位與 null handling。

### 8. Forum pagination
- [TODO]
- 現況：目前一次載入全部貼文。
- 目標：Supabase cursor/limit 分頁，避免內容量成長後首屏變慢。

### 9. Post / Comment delete 策略統一
- [TODO]
- 現況：Post 使用 soft delete，Comment 目前為實體 delete。
- 目標：統一稽核、復原與權限策略。

### 10. COIN transaction reason canonicalization
- [TODO]
- 現況：交易 reason 存在中文與英文混用，例如 `論壇送禮` / `forum_create_post`。
- 目標：建立不可變 canonical transaction reason，UI 顯示文字仍走 localization。

---

## P2 — 穩定後再做

### 11. ForumPage 歷史註解整理
- [TODO]
- 核心功能穩定後再清理，不得因此阻塞功能修復。

### 12. Forum pagination / cache / performance tuning
- [TODO]
- 只有在實際資料量與效能需要時處理。

---

## 開發規則

1. 已標記 DONE 的項目不重新盤點。
2. 修正前先確認該 TODO 是否仍存在；不存在就直接標 DONE。
3. 新發現問題才新增 TODO。
4. 每完成一批程式修改，同步更新本文件。
5. `flutter analyze` 通過不代表功能完成；資料持久化、UI 行為與 backend consistency 仍需驗證。
6. 不為了 TODO 而重做已完成的 Firebase / Supabase 分流架構。

---

## Current Focus

**V3-main → Forum Core Stabilization**

先完成 P0 #1~#6，再進入 P1。
