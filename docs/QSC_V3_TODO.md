# QSC V3 TODO

最後更新：2026-08-06

---

## 狀態定義

- TODO：待處理
- DOING：進行中
- BLOCKED：受阻
- DONE：已完成

---

## P0 - Forum 核心正確性

- [DOING] Development Guard System

  Priority:
  P0

  Status:
  DOING

  Goal:
  Prevent AI/developers from modifying code without checking project rules.

  Files:
  - .github/COPILOT_INSTRUCTIONS.md
  - docs/QSC_RULES.md
  - docs/QSC_CURRENT_PHASE.md
  - tools/qsc_check.ps1
  - .github/workflows/qsc_check.yml

- [TODO] ForumRepository 尚未接上發文/按讚/送禮實作

  Priority:
  P0

  Sprint:
  Sprint 1 - Forum Core Stabilization

  Trigger:
  開始 Forum Repository 正式串接前

  Dependency:
  Supabase forum_posts / reactions schema 確認完成

  - 檔案：lib/repositories/forum_repository.dart
  - 現況：addPost/likePost/giftPost 仍為空實作註解
  - 風險：UI 顯示成功但資料可能未持久化

- [TODO] Forum 詳情頁留言作者名稱欄位對應可能錯誤

  Priority:
  P0

  Sprint:
  Sprint 1 - Forum Core Stabilization

  Trigger:
  開始 ForumDetail 留言資料整併前

  Dependency:
  comment payload 欄位命名規格確定

  - 檔案：lib/screens/forum_detail_page.dart
  - 現況：讀取 comment['userName']，但建立留言時使用 nickname
  - 風險：留言可能顯示匿名或錯誤名稱

- [TODO] Forum 詳情頁 currentUserName 傳值來源可疑

  Priority:
  P0

  Sprint:
  Sprint 1 - Forum Core Stabilization

  Trigger:
  修正留言寫入來源使用者資料前

  Dependency:
  UserService 目前登入者暱稱來源確認

  - 檔案：lib/screens/forum_page.dart
  - 現況：開啟 ForumDetailPage 時以 post.name 傳入 currentUserName
  - 風險：留言者暱稱可能被誤用為貼文作者名稱

- [TODO] ForumPage Like/Gift index 操作錯誤

  Priority:
  P0

  Sprint:
  Sprint 1 - Forum Core Stabilization

  Trigger:
  開始修正 Forum 分類互動前

  Dependency:
  _filteredPosts 與原始資料映射策略定義完成

  - 檔案：lib/screens/forum_page.dart
  - 現況：列表顯示使用 _filteredPosts，但 _handleLike/_handleSendGift 以 _posts[index] 直接操作
  - 風險：分類或排序時可能更新到錯誤貼文，造成 like/gift 寫入錯位

- [TODO] ForumPost model 欄位不足

  Priority:
  P1

  Sprint:
  Sprint 1 - Forum Core Stabilization

  Trigger:
  開始 Forum Repository 正式串接前

  Dependency:
  Supabase forum_posts schema 確認完成

  - 檔案：lib/models/forum_post.dart
  - 現況：缺少 category、userId、isDeleted、commentCount 等 Forum 常用欄位
  - 風險：前後端欄位映射不完整，導致篩選、統計與資料一致性困難

- [TODO] Like count Supabase count 同步策略未定

  Priority:
  P0

  Sprint:
  Sprint 1 - Forum Core Stabilization

  Trigger:
  開始實作 like 寫入與讀取流程前

  Dependency:
  Supabase count 聚合來源與更新時機定案

  - 檔案：lib/repositories/forum_repository.dart
  - 現況：目前 like 資料流程未定義即時回寫與 count 聚合來源（本地加一 vs Supabase 實際值）
  - 風險：多端操作下 like 數可能漂移，UI 顯示與資料庫不一致

---

## P1 - Forum 功能一致性

- [TODO] Forum 分類邏輯與 UI 類別不一致

  Priority:
  P1

  Sprint:
  Sprint 1 - Forum Core Stabilization

  Trigger:
  開始 Forum 分類功能補全前

  Dependency:
  category 資料模型與查詢條件一致化

  - 檔案：lib/screens/forum_page.dart
  - 現況：類別顯示 0~4，但篩選僅區分 SOS 與非 SOS
  - 風險：使用者點分類卻看不到符合預期的結果

- [TODO] Forum category 字串判斷存在語系耦合風險

  Priority:
  P1

  Sprint:
  Sprint 1 - Forum Core Stabilization

  Trigger:
  開始整理 Forum category 枚舉前

  Dependency:
  category canonical value 規格定案

  - 檔案：lib/models/forum_post.dart
  - 現況：isSOS 判斷含 category == '菸癮犯了'
  - 風險：多語系或資料異動時判斷失效

- [TODO] ForumComment model 建立

  Priority:
  P1

  Sprint:
  Sprint 1 - Forum Core Stabilization

  Trigger:
  開始重構留言資料流前

  Dependency:
  forum_comments schema 與欄位命名確認

  - 檔案：lib/models/forum_comment.dart（待建立）、lib/screens/forum_detail_page.dart
  - 現況：留言以 Map<String, dynamic> 傳遞，欄位命名分散且缺少型別約束
  - 風險：欄位 typo 或 null 處理遺漏時不易在編譯期發現，維護與測試成本高

- [TODO] ForumCreatePostUseCase 建立

  Priority:
  P1

  Sprint:
  Sprint 1 - Forum Core Stabilization

  Trigger:
  開始拆分 UI 發文流程前

  Dependency:
  發文流程規格（扣幣、失敗回滾、成功回補）確認

  - 檔案：lib/usecases/forum/forum_create_post_usecase.dart（待建立）、lib/screens/forum_page.dart
  - 現況：發文流程在 UI 層同時處理 coin 扣款、資料組裝、repository 呼叫
  - 風險：流程分散且難測試，後續擴充（審核、敏感詞、重試）成本高

- [TODO] Forum pagination

  Priority:
  P1

  Sprint:
  Sprint 2 - Data Flow Cleanup

  Trigger:
  貼文列表筆數成長或載入時間超標時

  Dependency:
  Supabase 分頁查詢策略（cursor/offset）確認

  - 檔案：lib/repositories/forum_repository.dart、lib/services/supabase_forum_service.dart、lib/screens/forum_page.dart
  - 現況：目前採一次載入全部貼文，缺少分頁游標與增量載入機制
  - 風險：貼文量增加後首屏變慢、記憶體壓力提升，並影響使用體驗

---

## P2 - Forum 體驗與可維護性

- [TODO] Forum 幣值交易 reason 有中英文混用

  Priority:
  P2

  Sprint:
  Sprint 2 - Data Flow Cleanup

  Trigger:
  開始整理交易紀錄與報表欄位前

  Dependency:
  coin transaction reason 命名規範發布

  - 檔案：lib/screens/forum_page.dart
  - 現況：'論壇送禮' 與 'forum_create_post' 並存
  - 風險：報表與審計分類不一致

- [TODO] Forum Page 內存在大量歷史註解，建議後續整理

  Priority:
  P2

  Sprint:
  Sprint 2 - Data Flow Cleanup

  Trigger:
  Sprint 1 核心修復完成後

  Dependency:
  ForumPage 行為測試與流程穩定

  - 檔案：lib/screens/forum_page.dart
  - 現況：大型註解段落影響可讀性
  - 風險：維護與 code review 成本增加

- [TODO] Post/Comment soft delete 統一

  Priority:
  P1

  Sprint:
  Sprint 2 - Data Flow Cleanup

  Trigger:
  開始實作刪文刪留言一致化流程前

  Dependency:
  post/comment 稽核與復原需求確認

  - 檔案：lib/services/supabase_forum_service.dart、lib/services/supabase_comment_service.dart、lib/repositories/forum_repository.dart
  - 現況：post delete 採 is_deleted 軟刪除，comment delete 仍為實體刪除
  - 風險：審計與回復策略不一致，歷史資料追蹤與客服處理困難

---

## 登錄規則

- 本次需求不處理但發現的問題，必須新增一筆 TODO
- TODO 必須至少包含：檔案、現況、風險
