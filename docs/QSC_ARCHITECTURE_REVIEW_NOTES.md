# QSC Architecture Review Notes Addendum V1.0

最後更新：2026-07-31

---

# 1. PR Review Engineering Rules

本文件根據 Reading System V3 PR Review 結果補充。

目的：

* 提升大型 Flutter 專案可維護性
* 保持 QSC 模組化架構
* 避免未來多語言、商業功能擴張造成重構

---

# 2. Localization Rule Enhancement

所有 UI 顯示文字必須使用 Localization。

禁止：

```dart
Text("固定中文")
```

正確：

```dart
Text(
  AppLocalizations.of(context)!.readingTitle,
)
```

流程：

```
UI
 ↓
Localization Key
 ↓
ARB Language File
 ↓
Translated Text
```

適用：

* Page
* Screen
* Widget
* Dialog
* Snackbar
* Error Message
* Button Label

新增功能時：

必須同步更新：

```
lib/l10n/app_zh_TW.arb
lib/l10n/app_en.arb
```

---

# 3. Repository Dependency Injection Rule

Repository 不應直接建立大量 Service。

推薦：

```
Screen

↓

UseCase

↓

Repository

↓

Service

↓

Data Source
```

範例：

```dart
ReadingRepository(
  remote: SupabaseReadingService(),
  cache: ReadingCacheService(),
  coinRepository: CoinRepository(),
);
```

優點：

* 容易測試
* 容易替換 Firebase / Supabase
* 降低耦合

---

# 4. Service Responsibility Rule

Service 不應逐漸變成大型管理中心。

禁止：

單一 Service 同時負責：

* Database
* Authentication
* Logging
* Business Rules
* UI State

例如：

CoinService 不應永久包含：

```
CoinService

├ Balance
├ Storage
├ FirebaseAuth
├ Supabase Log
├ Reward Rules
└ Transaction History
```

未來拆分：

```
services/

coin_service.dart


repositories/

coin_repository.dart
coin_log_repository.dart
```

Service：

負責商業規則。

Repository：

負責資料來源。

---

# 5. UseCase Introduction Rule

當功能流程包含：

* 多個 Service
* 多個 Repository
* 商業判斷

應新增 UseCase。

例如閱讀下載：

舊：

```
ReadingLibraryPage

 ↓

ReadingRepository
```

新版：

```
ReadingLibraryPage

↓

DownloadBookUseCase

↓

ReadingRepository

↓

Supabase
Cache
Coin
```

適用：

* COIN 消費
* 任務獎勵
* VIP 權限
* 排名更新
* Forum 操作

---

# 6. Commercial Transaction Safety Rule

所有 COIN 交易必須考慮失敗回復。

流程：

```
使用者操作

↓

確認餘額

↓

扣除 COIN

↓

執行功能

↓

成功保存

↓

完成交易
```

若中途失敗：

```
Rollback / Refund
```

例如：

閱讀下載：

```
扣 COIN

↓

下載文章

↓

保存 Cache

↓

成功
```

若 Cache 保存失敗：

必須退款。

---

# 7. Reading System Development Rules

Reading System 必須遵守：

## Data Source

主要：

```
Supabase
```

用途：

* Medical
* Stories
* Reading
* Music
* Games
* Public Content

## Offline

使用：

```
Local Cache
```

用途：

* 離線閱讀
* 減少 API 使用
* 提升速度

## UI

禁止：

直接操作：

* Supabase
* Firebase
* Storage

必須：

```
UI

↓

Repository / UseCase

↓

Service
```

---

# 8. Future Refactoring Priority

依優先級：

## Priority 1

完成所有 Localization。

---

## Priority 2

建立主要 UseCase：

```
DownloadBookUseCase
CreatePostUseCase
SpendCoinUseCase
ClaimRewardUseCase
```

---

## Priority 3

拆分大型 Service：

例如：

```
CoinService
AchievementService
ContentService
```

---

# 9. Architecture Quality Goal

QSC 最終目標：

```
Feature

↓

Presentation Layer

↓

UseCase Layer

↓

Repository Layer

↓

Service Layer

↓

Data Source
```

保持：

* Flutter Best Practice
* Multi Platform Support
* Multi Language Ready
* Backend 可替換
* 商業功能可擴充

---

END

QSC Architecture Review Notes V1.0
