# Quit Smoking Club
# QSC Roadmap Document V3.0

最後更新：2026-08-12

---

# 1. Product Vision

Quit Smoking Club 的目標：

建立全球化、以健康生活為核心的戒菸社群平台。

戒菸是入口，不是整個產品的全部。

核心方向：

- 科學化戒菸計畫
- 漸進式降低抽菸量
- 社群陪伴
- 健康生活內容
- 遊戲化獎勵
- 長期戒菸維持

---

# 2. Current Project Status

目前版本：

**V3-main**

Framework:

Flutter

Platforms:

- Android
- iOS
- Web

Backend:

**Firebase + Supabase 分流架構**

---

# 3. V3 Architecture Status

## Firebase — Private / User-owned Data

保留 Firebase 作為：

- Authentication
- User Profile
- 個人設定
- 個人戒菸資料
- 抽菸紀錄
- 私人進度
- COIN balance
- VIP 狀態

## Supabase — Public / Community / Content

使用 Supabase 作為：

- Medical
- Stories
- Music
- YouTube
- Games content
- Reading content
- Forum
- 公開社群資料

## Local Storage

用途：

- Reading cache
- Offline fallback
- 暫存資料

---

# 4. Completed V3 Work

## Architecture

- [DONE] Models / Services / Repositories / Engines 分層
- [DONE] UseCase layer 持續導入
- [DONE] Firebase / Supabase data ownership 分流
- [DONE] ContentRepository 統一公開內容入口
- [DONE] 舊 `getMedicalContents()` / `getStoryContents()` / `getMusicContents()` / `getYouTubeContents()` 呼叫已清除

## Content

- [DONE] Medical → ContentRepository → Supabase
- [DONE] Stories → ContentRepository → Supabase
- [DONE] Music → ContentRepository → Supabase
- [DONE] YouTube → ContentRepository → Supabase
- [DONE] Reading → SupabaseReadingService + ReadingRepository + Local Cache

## COIN

- [DONE] CoinService Firebase balance source of truth
- [DONE] CoinRepository
- [DONE] SpendCoinUseCase
- [DONE] CoinFacadeUseCase
- [DONE] Supabase coin transaction logging
- [DONE] Forum create-post flow 使用 UseCase 扣幣

## Forum

- [DONE] ForumRepository → SupabaseForumService
- [DONE] Forum posts / comments / likes 使用 Supabase
- [DONE] Like toggle 基礎 backend flow
- [DONE] CreateForumPostUseCase
- [DONE] CreateForumCommentUseCase

## Quality

- [DONE] Localization architecture
- [DONE] Flutter analyze currently passes

---

# 5. Current Development Phase

# Phase 3 — Community Platform Stabilization

目前不是重新建立 Forum，而是**修正已存在流程的一致性與資料正確性**。

Priority 0：

1. Forum Like UI count 與 toggle 結果一致
2. Forum Gift persistence
3. Forum comment nickname 欄位一致
4. currentUserName 使用真正登入者資料
5. Forum category canonicalization
6. 移除 category 對中文翻譯文字的依賴

完成 P0 後：

Priority 1：

- ForumComment typed model
- Forum pagination
- Post / Comment delete policy 統一
- COIN transaction reason canonicalization

---

# 6. Phase 4 — Content Platform

主要來源：

**Supabase**

內容：

- Medical Articles
- Success Stories
- Music
- Games
- YouTube References
- Reading

特色：

- 多語言
- 全球內容
- Local cache
- Offline fallback

此階段核心 Content Architecture 已完成，後續以內容品質與資料管理為主，不重新設計資料流。

---

# 7. Phase 5 — Monetization

VIP baseline：

**99 TWD / Month**

方向：

- 移除廣告
- 更多 COIN
- COIN 購買優惠
- 特殊功能優惠

COIN：

- App 內虛擬貨幣
- 不可兌換現金
- 由使用率與收益持續調整經濟平衡

---

# 8. Phase 6 — Global Expansion

- 多語言
- 國家化內容
- 時區支援
- 全球社群測試

---

# 9. Future Features

- Achievement System
- Ranking System
- Enterprise Program
- Notification System
- 更多健康生活內容

---

# 10. Development Priority Rules

目前順序：

**Forum Core Stabilization**

↓

**Data Consistency / Transaction Safety**

↓

**Content Quality / Management**

↓

**Monetization**

↓

**Global Expansion**

禁止因為文件或架構整理而反覆重做已完成項目。

---

# 11. Roadmap Rules

所有新增功能必須符合：

- QSC Project Rules
- QSC Architecture
- QSC V3 TODO

規則：

- DONE 項目不得反覆列為 TODO
- 發現新問題才新增 TODO
- 先修真正影響正確性的問題
- 不為追求完美架構而重寫
- Firebase / Supabase 分流不可再次倒退

---

# END

Quit Smoking Club
QSC Roadmap Document V3.0
