# QSC V3 Development Checklist

## 開發前

每次修改前確認：

- □ 已閱讀 QSC_RULES.md
- □ 已閱讀 QSC_AI_RULES.md
- □ 已閱讀 QSC_V3_ARCHITECTURE.md
- □ 已確認 QSC_V3_TODO.md
- □ 已確認目前開發 Phase

## 架構確認

- □ UI 是否只負責顯示
- □ 商業邏輯是否放 UseCase / Engine
- □ Repository 是否隔離資料來源
- □ Service 是否沒有越權

## 修改後

- □ flutter analyze 通過
- □ 更新 QSC_CHANGELOG.md
- □ 更新 QSC_V3_TODO.md 狀態
- □ Git commit 訊息清楚
