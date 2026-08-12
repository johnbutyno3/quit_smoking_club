# QSC V3 Architecture Status

最後更新：2026-08-12

本文件為 `v3-main` 的實際架構狀態基準。若舊版 `QSC_ARCHITECTURE.md` 與本文件衝突，以本文件的 V3 實作狀態為準，後續再做文件合併。

---

## 1. Backend Ownership

### Firebase — Private / User-owned

- Authentication
- User Profile
- Personal Settings
- Quit Plan
- Smoking Records
- Private Progress
- COIN Balance
- VIP Status

### Supabase — Public / Community / Content

- Medical
- Stories
- Music
- YouTube
- Games content
- Reading
- Forum posts
- Forum comments
- Forum likes
- Public community data
- COIN transaction logs

### Local Storage

- Reading cache
- Offline fallback
- Temporary local state

---

## 2. Public Content Flow

```text
Screen
 ↓
UseCase / Repository
 ↓
ContentRepository
 ↓
SupabaseContentService
 ↓
Supabase
```

Categories:

- reading
- medical
- stories
- music
- youtube
- games

禁止重新建立 category-specific content access API。

Reading 因 Book / Chapter 結構特殊，保留：

```text
ReadingRepository
 ↓
SupabaseReadingService
 ↓
reading_books / reading_chapters
```

---

## 3. COIN Flow

Balance source of truth：**Firebase**。

```text
Feature
 ↓
UseCase
 ↓
CoinRepository
 ↓
CoinService
 ↓
Firebase balance
```

Transaction logs：

```text
CoinService
 ↓
SupabaseCoinLogService
 ↓
Supabase coin_logs
```

Supabase logs 不可取代 Firebase balance source of truth。

---

## 4. Forum Flow

```text
ForumPage
 ↓
Forum UseCase
 ↓
ForumRepository
 ↓
SupabaseForumService
 ↓
Supabase
```

已完成：

- Post read
- Post create flow
- Comment read/create flow
- Like backend toggle
- CreateForumPostUseCase
- CreateForumCommentUseCase

尚未完成：

- Like UI count synchronization
- Gift persistence
- Canonical category filtering
- Typed ForumComment
- Current-user nickname source correction

---

## 5. Architecture Rule

V3 現在是 stabilization，不是重新架構。

工作優先順序：

**修正正確性 → 資料一致性 → 型別與可維護性 → 效能 → 新功能**

禁止：

- 重做已完成 Firebase / Supabase 分流
- 為了「架構漂亮」大量搬移檔案
- 已完成項目反覆重新確認

---

## 6. Current Focus

目前唯一核心工作線：

**Forum Core Stabilization**

詳細 TODO 以 `QSC_V3_TODO.md` 為準。
