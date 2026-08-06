# QSC Module Status

最後更新：2026-08-06

---

## 專案目前階段

Phase:

V3 Architecture Stabilization

目標：

完成架構校正、模組整合、規範固定，再進入功能開發。

---

# Module Status

## Forum

Status:
DOING

Completion:
70%

Current:

- UI 基本完成
- Repository 架構完成
- Supabase Service 已建立

Remaining:

- 發文 CRUD 完整化
- Like 防重複
- Gift 交易完整化
- Comment 欄位統一

Priority:

P0

---

## Coin

Status:
DOING

Completion:
80%

Current:

- CoinService
- CoinRepository
- Coin UseCase
- Transaction Log

已建立。

Remaining:

- 統一交易 reason
- 防止重複領取
- Reward 規則整理

Priority:

P1

---

## Content

Status:
ALMOST DONE

Completion:
90%

Current:

- Supabase Content Source
- Repository Layer
- Medical
- Story
- Music
- YouTube

已建立。

Remaining:

- UI 串接確認
- Cache fallback 測試

Priority:

P1

---

## Reading

Status:
DOING

Completion:
80%

Current:

- Reading Repository
- Supabase Reading
- Cache
- Progress

已建立。

Remaining:

- 雲端同步策略確認
- 閱讀獎勵整合

Priority:

P1

---

## Ranking

Status:
DOING

Completion:
70%

Current:

- Ranking Repository
- Supabase Ranking
- Ranking UseCase

已建立。

Remaining:

- 分數來源統一
- Achievement 整合

Priority:

P1

---

## Smoking Engine

Status:
DOING

Completion:
60%

Current:

- SmokingEngine
- PlanGenerator
- ScoreEngine
- RewardEngine

已建立。

Remaining:

- V3 動態戒菸演算法校正
- Score / Behavior 責任整理

Priority:

P1

---

## User / Profile

Status:
DOING

Completion:
60%

Current:

- UserService
- StorageService
- User Model

已建立。

Remaining:

- User Repository 評估
- 雲端同步策略

Priority:

P1

---

# Development Rule

任何模組開始修改前：

1. 更新本文件 Status

2. 更新 QSC_V3_TODO.md

3. 完成後更新 CHANGELOG

禁止：

只依靠聊天記錄保存決策。

---

# Status Definition

TODO:
尚未處理

DOING:
正在開發

BLOCKED:
等待條件

DONE:
完成並驗證