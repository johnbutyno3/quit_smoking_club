# QSC Workflow

最後更新：2026-08-06

---

## 1. 任務開始前

1. 先閱讀：
   - docs/QSC_V3_ARCHITECTURE.md
   - docs/QSC_V3_TODO.md
2. 確認需求邊界：
   - 是否可改架構
   - 是否可動 DB schema
   - 是否含 l10n 需求
3. 列出本次不處理但已知風險，準備登錄 TODO

### Before coding

1. Read docs/QSC_RULES.md
2. Read docs/QSC_CURRENT_PHASE.md
3. Read docs/QSC_V3_TODO.md
4. Confirm current Sprint
5. Only work on current priority items

---

## 2. 實作流程

1. 最小可行修改
2. 僅修改需求指定檔案與必要相依檔案
3. 不自行重構
4. 固定 UI 文字走 AppLocalizations

---

## 3. 驗證流程

1. 若改 ARB：flutter gen-l10n
2. flutter analyze
3. 若 analyze 有問題：
   - 優先修本次修改引入的問題
   - 不擴大處理範圍

---

## 4. 收尾流程

1. 更新 docs/QSC_CHANGELOG.md
2. 將未處理問題登錄 docs/QSC_V3_TODO.md
3. 回報：
   - 修改檔案
   - 驗證命令與結果
   - 尚未處理風險

### After coding

1. flutter analyze
2. Update TODO status
3. Update CHANGELOG
4. End of day: update docs/QSC_V3_TODO.md
5. If governance/rules changed: update docs/QSC_RULES.md and related guard docs

---

## 5. 禁止事項

- 未經需求允許，不得自行重構架構
- 不得將 TODO 留在腦中而不落文件
- 不得在未說明情況下擴大修改範圍
