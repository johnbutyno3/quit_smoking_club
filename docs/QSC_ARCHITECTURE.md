# Quit Smoking Club
# QSC Architecture Document V1.0

最後更新：2026-07-30

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


例如：

- SmokingState
- SmokingPlan
- UserProfile
- CoinTransaction


禁止：

- 包含 UI 邏輯
- 包含 API 呼叫


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


目前 Engine：


## SmokingEngine

負責：

- 戒菸狀態計算
- 今日抽菸額度
- 剩餘次數
- 時間控制


---

## PlanGenerator

負責：

- 產生戒菸計畫
- 每日目標安排
- 時間排程


---

## ScoreEngine

負責：

- 戒菸評分
- 行為評估


---

## RewardEngine

負責：

- 獎勵計算
- COIN 發放規則


---

## BehaviorEngine

負責：

- 行為分析
- 使用者進度評估


---

# 4. Services Layer

位置：

lib/services/


責任：

提供系統服務。


包含：

- Storage
- Authentication
- Database Access
- External Service


目前主要 Service：


## CoinService

負責：

- COIN 餘額
- 增加 COIN
- 消費 COIN
- 交易紀錄


---

## StorageService

負責：

- Local Storage
- Cache
- 本機資料保存


---

## UserService

負責：

- 使用者資料管理
- 使用者狀態


---

# 5. Repository Layer

位置：

lib/repositories/


責任：

管理資料來源。


Repository 負責決定：

資料來源：

- Firebase
- Supabase
- Local Storage


UI 不直接操作資料庫。


---

# 6. Backend Architecture


## Firebase Flow

用途：

私人資料。


流程：

User

↓

Service

↓

Repository

↓

Firebase


資料：

- Account
- Profile
- Quit Records
- Personal Settings


---

## Supabase Flow

用途：

公開內容。


流程：

Content UI

↓

Repository

↓

Supabase


資料：

- Medical
- Stories
- Music
- Games
- Public Content


---

# 7. UI Architecture


## Pages / Screens

位置：

lib/pages/
lib/screens/


責任：

負責：

- 畫面
- 使用者互動
- Navigation


禁止：

- 直接寫資料庫邏輯
- 大量商業計算


---

## Widgets

位置：

lib/widgets/


責任：

可重複 UI 元件。


例如：

- Card
- Button
- Progress Widget


---

# 8. Localization Architecture

位置：

lib/l10n/


用途：

管理多語言。


規則：

所有 UI 文字：

UI

↓

Localization Key

↓

Language File


禁止：

直接寫固定文字。


---

# 9. Data Flow Example


## Smoking Record Flow

User Action

↓

Screen

↓

Smoking Engine

↓

Smoking State Update

↓

Repository

↓

Storage / Firebase


---

## Coin Spending Flow

User Action

↓

Feature Screen

↓

Service

↓

CoinService

↓

Storage

↓

Update UI


---

# 10. Architecture Rules


新增功能時：

確認：

1. 是否需要 Model？

2. 是否需要 Engine？

3. 是否需要 Service？

4. 是否需要 Repository？


避免：

- UI 包含商業邏輯
- Service 過度肥大
- 重複資料來源


---

# END

Quit Smoking Club

QSC Architecture Document V1.0