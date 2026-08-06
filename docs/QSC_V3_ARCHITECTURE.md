# QSC V3 Architecture Guide

最後更新：2026-08-06

---

## 1. 目的

本文件定義 QSC V3 的開發邊界與實作原則。

核心原則：

- 不自行重構既有架構
- 以最小修改完成需求
- UI、Domain、Data 分層職責清楚
- 所有未立即修正問題必須登錄 TODO

---

## 2. 專案分層與責任

### Presentation Layer

路徑：

- lib/screens/
- lib/widgets/

責任：

- 畫面渲染
- 使用者互動
- 呼叫 usecase/repository
- 顯示 localization 文字

禁止：

- 直接寫入資料庫
- 複製商業規則到 UI

### Domain/Application Layer

路徑：

- lib/engines/
- lib/usecases/

責任：

- 商業規則
- 計算邏輯
- 行為流程

禁止：

- 依賴 Flutter UI 元件

### Data Layer

路徑：

- lib/repositories/
- lib/services/
- lib/models/

責任：

- API/DB 存取
- 資料轉換
- 本機儲存

禁止：

- 混入畫面邏輯

---

## 3. Localization 規範

- 所有固定 UI 文字必須走 AppLocalizations
- 新增字串時同步更新：
  - lib/l10n/app_en.arb
  - lib/l10n/app_zh.arb
  - lib/l10n/app_zh_TW.arb
- 每次修改 ARB 後必須執行 flutter gen-l10n

---

## 4. 修改邊界規範

- 未經明確需求，不得調整檔案結構
- 不得更動 Firebase/Supabase schema（除非需求明確要求）
- 不得以重構名義修改既有核心流程
- 發現問題但本次不修時，必須記錄於 docs/QSC_V3_TODO.md

---

## 5. 驗證規範

每次交付至少執行：

1. flutter gen-l10n（若涉及 l10n）
2. flutter analyze

---

## 6. V3 變更管理

- 需求追蹤：docs/QSC_V3_TODO.md
- 工作流程：docs/QSC_WORKFLOW.md
- 變更記錄：docs/QSC_CHANGELOG.md
