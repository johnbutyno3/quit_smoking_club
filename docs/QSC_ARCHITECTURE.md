# Quit Smoking Club
# QSC Architecture Document V1.1

最後更新：2026-08-12

---

# 1. Architecture Overview

Quit Smoking Club 採用模組化 Flutter 架構。

核心目標：

- 保持可維護性
- 分離 UI 與商業邏輯
- 支援 Android / iOS / Web
- 支援未來全球化

主要架構：

lib/

- models/
- services/
- repositories/
- engines/
- pages/
- screens/
- widgets/
- l10n/

---

# 2. Layer Responsibilities

## Models Layer

位置：

lib/models/

責任：

負責資料結構。

包含：

- Entity Model
- Data Object
- State Model

禁止：

- UI 邏輯
- API / Database 呼叫

---

# 3. Engines Layer

位置：

lib/engines/

責任：

負責核心計算與規則。

Engine 不負責：

- UI
- Database
- API

主要 Engine：

- SmokingEngine：戒菸狀態、額度、剩餘次數與時間控制
- PlanGenerator：戒菸計畫、每日目標與時間排程
- ScoreEngine：評分與行為評估
- RewardEngine：獎勵計算與 COIN 發放規則
- BehaviorEngine：行為分析與進度評估

---

# 4. Services Layer

位置：

lib/services/

責任：

提供系統服務、外部 API、Storage 與資料存取實作。

Service 不應被 UI 直接用來繞過 Repository 存取 Repository 所管理的資料。

主要 Service：

- CoinService
- StorageService
- UserService
- SupabaseContentService
- SupabaseReadingService

SupabaseContentService 負責 content_items 的資料存取；Repository 負責把資料來源轉換為 App domain model。

---

# 5. Repository Layer

位置：

lib/repositories/

責任：

管理資料來源與 domain model 之間的邊界。

Repository 可以決定資料來源：

- Firebase
- Supabase
- Local Storage

UI 不直接操作資料庫或 Supabase / Firebase client。

內容資料目前採用：

UI
↓
UseCase
↓
ContentRepository
↓
SupabaseContentService
↓
Supabase

---

# 6. Backend Architecture

## Firebase Flow

用途：私人資料與會員身份。

流程：

User
↓
Screen / UseCase
↓
Repository / Service
↓
Firebase

資料：

- Account
- Profile
- Quit Records
- Personal Settings

Firebase 不作為公開內容平台的主要資料來源。

---

## Supabase Flow

用途：公開內容與公開社群資料。

流程：

Content UI
↓
UseCase
↓
Repository
↓
Service
↓
Supabase

資料：

- Medical
- Stories
- Music
- YouTube References
- Games
- Public Content
- Public Community Data

App 內建內容僅作為離線 / 備援來源，不取代 Supabase 的主要內容來源角色。

---

# 7. UI Architecture

## Pages / Screens

位置：

lib/pages/
lib/screens/

責任：

- 畫面
- 使用者互動
- Navigation
- 呼叫 UseCase / Repository 所提供的功能

禁止：

- 直接操作資料庫
- 直接操作 Supabase / Firebase client
- 大量商業計算

---

## Widgets

位置：

lib/widgets/

責任：

可重複 UI 元件。

---

# 8. Localization Architecture

位置：

lib/l10n/

所有使用者可看到的文字必須使用 localization key。

UI
↓
Localization Key
↓
Language File

禁止在 Dart UI 程式中加入固定的使用者文字。

---

# 9. Data Flow Example

## Smoking Record Flow

User Action
↓
Screen
↓
Engine / UseCase
↓
Smoking State Update
↓
Repository
↓
Storage / Firebase

---

## Content Flow

User Action
↓
Screen
↓
UseCase
↓
ContentRepository
↓
SupabaseContentService
↓
Supabase

---

## Coin Spending Flow

User Action
↓
Feature Screen
↓
UseCase / Service
↓
CoinService
↓
Repository / Storage
↓
Update UI

---

# 10. Architecture Rules

新增功能時確認：

1. 是否已有 Model？
2. 是否已有 Engine？
3. 是否已有 Service？
4. 是否已有 Repository？
5. 是否需要 UseCase？
6. 是否符合 Firebase / Supabase 資料分界？
7. 是否符合 Localization 規則？

避免：

- UI 包含商業邏輯
- UI 直接存取資料庫
- Service 過度肥大
- Repository 直接承擔 UI 邏輯
- 重複資料來源
- 公開內容回流 Firebase
- 為了架構漂亮而無必要新增 Layer 或搬移檔案

---

# END

Quit Smoking Club

QSC Architecture Document V1.1
