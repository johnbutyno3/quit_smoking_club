# Quit Smoking Club
# QSC Project Rules V1.1

最後更新：2026-07-30

---

# 1. Project Overview

## Project Name

Quit Smoking Club  
戒菸俱樂部


## Product Goal

建立全球戒菸社群平台。

定位：

不是單純的抽菸紀錄工具，而是一個完整戒菸生態系。

目標：

協助使用者：

- 開始戒菸
- 降低抽菸量
- 維持戒菸成果
- 建立戒菸社群支持


主要功能：

- 個人戒菸計畫
- 動態戒菸控制
- 抽菸紀錄分析
- 身體恢復進度
- SOS 減緩模組
- 社群論壇
- 遊戲中心
- 成就系統
- 金幣經濟系統
- VIP 會員制度
- 多國語言支援


---

# 2. Development Principles


## 2.1 Maintain Existing Architecture


目前專案架構：

lib/

- models/
- services/
- repositories/
- engines/
- pages/
- screens/
- widgets/
- l10n/


開發原則：

新增功能時：

優先使用現有架構。


禁止：

- 無必要新增 Layer
- 為了架構漂亮而重新設計
- 大規模搬移檔案
- 破壞既有功能


---

## 2.2 Code Responsibility Separation


Models：

負責：

- 資料結構
- Entity 定義


Services：

負責：

- 系統服務
- API
- Storage
- 外部整合


Repositories：

負責：

- 資料來源管理
- Firebase / Supabase / Local 資料交換


Engines：

負責：

- 核心計算邏輯
- 規則判斷
- 演算法


Pages / Screens：

負責：

- UI
- 使用者操作流程


Widgets：

負責：

- 可重複 UI 元件


---

# 3. Flutter Development Rules


Framework:

Flutter


Target Platforms:

- Android
- iOS
- Web


基本要求：

- 使用 Null Safety
- 保持模組化
- 商業邏輯與 UI 分離
- 避免重複程式碼
- 保持可維護性


---

# 4. Architecture Change Rules


任何重大架構修改：

必須先確認：

1. 是否真的解決問題？
2. 是否影響既有功能？
3. 是否增加維護成本？
4. 是否有更簡單方案？


禁止：

- 為追求完美架構而重寫專案
- 未測試就大規模修改
---

# 5. Localization Rules


所有使用者可看到的文字：

必須使用 localization。


禁止：

Text("開始戒菸")


正確：

Text(l10n.startQuit)


規則：

- 不允許在 Dart 程式中直接寫使用者文字
- 所有 UI 文字必須建立 localization key
- 新增功能時同步更新語言檔


支援：

- 繁體中文
- 英文
- 未來其他語言


---

# 6. Backend Architecture


## Firebase


用途：

會員與私人資料管理。


負責：

- Authentication
- User Profile
- 個人設定
- 個人戒菸資料
- 個人抽菸紀錄
- 私人進度資料


Firebase 不負責：

- 公開文章
- 公開內容平台
- 社群公開資料


---

## Supabase


用途：

公開內容來源平台。


負責：

- Medical Articles
- Success Stories
- Music
- YouTube References
- Games Content
- Public Community Data


資料策略：

Supabase 為主要內容來源。


App 內建資料：

僅作為：

- Offline fallback
- 初始資料
- 無網路備援


---

# 7. Data Separation Rules


資料分類：


## Private Data

儲存於：

Firebase


包含：

- 使用者帳號
- 個人資料
- 戒菸計畫
- 抽菸紀錄
- 個人設定


---

## Public Content

儲存於：

Supabase


包含：

- 醫療文章
- 戒菸故事
- 音樂
- 遊戲內容
- 公開排行


---

## Local Storage


用途：

- Cache
- Offline fallback
- 暫存資料


---

# 8. Backend Development Rules


新增資料功能時：

必須先判斷：

1. 是否屬於私人資料？
2. 是否屬於公開內容？
3. 是否需要離線支援？


禁止：

- 將公開內容大量放入 Firebase
- 將私人資料公開化
- 混用資料來源造成維護困難


---
---

# 9. AI Policy


目前版本：

不加入 AI 功能。


原因：

- 控制開發成本
- 避免 API 使用費用
- 維持商業模型健康
- 降低系統複雜度


未來若加入 AI：

必須重新評估：

- 實際使用需求
- 開發成本
- 維護成本
- 商業收益


---

# 10. Upload Policy


禁止：

- 圖片上傳
- 影片上傳


論壇內容：

目前設計：

只允許：

- 文字
- Emoji
- 系統 Badge


原因：

降低：

- Storage 成本
- 管理成本
- 審核風險
- 安全問題


---

# 11. Coin Economy Rules


## COIN 定義


COIN 為 App 內虛擬貨幣。


特性：

- 不可兌換現金
- 不具現金價值
- 僅限 App 內使用


用途：

- 社群功能
- 遊戲功能
- 特殊權限
- 虛擬商品
- VIP 相關優惠


---

## COIN Value


COIN 價值需依照使用者行為與商業數據調整。


目前目標：

約：

10～20 COIN ≈ 1 TWD


實際比例：

由後續：

- 使用率
- 收益
- 平衡性

持續調整。


---

# 12. Reward System Rules


使用者可透過：

- 每日登入
- 完成戒菸任務
- 閱讀內容
- 遊戲活動
- 社群互動

取得 COIN。


獎勵設計：

需避免：

- 無限制產生 COIN
- 經濟通膨
- 破壞付費價值


---

# 13. VIP System Rules


基本方向：

VIP 月費：

99 TWD / Month


VIP 權益：

- 移除廣告
- 增加 COIN 獲得量
- COIN 購買優惠
- 特殊功能優惠


VIP 設計目標：

提供更好的使用體驗。

不是直接限制免費使用者。


---

# 14. Advertising Rules


Free User：

可以顯示廣告。


VIP User：

移除廣告。


廣告用途：

- 提供免費服務收入
- 支援平台營運
- 作為部分功能解鎖方式


廣告設計：

需避免：

- 過度干擾使用者
- 破壞戒菸體驗


---
---

# 15. Forum Rules


論壇定位：

建立戒菸互助社群。


主要功能：

- 發文
- 留言
- 互動
- COIN 贈送
- 社群排行


---

## Forum Content Rules


禁止：

- 圖片上傳
- 影片上傳


允許：

- 文字內容
- Emoji
- 系統 Badge


---

## Forum Economy


部分功能可使用 COIN。


例如：

- 發表文章
- 特殊功能
- 私人聊天室
- 社群互動功能


消費設計：

需保持合理。

避免：

- 過度限制免費使用者
- 造成社群降低活躍度


---

# 16. Code Quality Rules


新增功能前：

必須確認：


1. 是否已有可使用的 Service？

2. 是否已有相關 Model？

3. 是否需要 Repository？

4. 是否應該放入 Engine？


---

避免：

- UI 包含大量商業邏輯
- 重複程式碼
- Hardcode 使用者文字
- 不必要新增檔案
- 未評估就修改架構


---

# 17. Database Rules


資料分級：


## User Private Data


來源：

Firebase


包含：

- 帳號資料
- 個人資料
- 戒菸計畫
- 抽菸紀錄
- 個人設定


---

## Public Content


來源：

Supabase


包含：

- 醫療內容
- 成功故事
- 音樂
- 遊戲內容
- 公開社群資料


---

## Local Data


用途：

- 快取
- 離線使用
- 暫存資料


---

# 18. Development Workflow


標準流程：


需求確認

↓

架構分析

↓

確認是否符合 QSC Rules

↓

修改程式

↓

Flutter Analyze

↓

測試

↓

Git Commit

↓

Push GitHub


---

# 19. Version Control Rules


Git Commit 必須清楚描述修改內容。


範例：


Fix:

修正問題


Feature:

新增功能


Refactor:

重構程式


Docs:

更新文件


---

禁止：

- 大量未說明修改
- 未測試直接提交
- 提交敏感資料


---

# 20. Current Development Priority


## Phase 1

穩定核心戒菸功能


包含：

- Smoking Engine
- Quit Plan
- Progress Tracking
- Smoke Records


---

## Phase 2

完成金幣系統


包含：

- CoinService
- Coin Transaction
- Shop
- Reward System


---

## Phase 3

完善論壇系統


包含：

- 發文
- 留言
- 社群互動
- COIN 經濟


---

## Phase 4

建立內容平台


包含：

- Medical
- Stories
- Music
- Games


---

## Phase 5

商業化


包含：

- VIP
- Advertisement
- In-App Purchase


---

## Phase 6

全球化發布


包含：

- 多語言
- 多地區支援
- 國際市場測試


---
---

# 21. Project Decision History


本文件記錄 QSC 長期重要決策。


---

## Architecture Decision


決策：

不重新設計目前 Flutter 架構。


原因：

目前架構已具備：

- Models
- Services
- Repositories
- Engines
- UI Layers


後續以：

穩定功能

↓

改善品質

↓

增加商業功能

為主要方向。


---

## Localization Decision


決策：

所有使用者介面文字必須使用 localization。


原因：

支援全球市場。


禁止：

直接在程式中寫固定語言文字。


---

## Backend Decision


決策：

採用混合架構。


Firebase：

負責：

- 使用者身份
- 私人資料
- 個人戒菸紀錄


Supabase：

負責：

- 公開內容
- 社群資料
- 內容管理平台


---

## AI Decision


決策：

目前版本不加入 AI。


原因：

- 控制成本
- 降低複雜度
- 優先完成核心產品


---

## Media Upload Decision


決策：

目前禁止圖片與影片上傳。


原因：

- 降低 Storage 成本
- 降低管理負擔
- 提升安全性


---

# 22. Product Philosophy


QSC 的核心：

不是要求使用者一次成功戒菸。

而是：

透過：

- 科學計畫
- 漸進控制
- 社群支持
- 遊戲化獎勵

提高長期成功率。


---

# 23. Development Philosophy


開發方向：


優先：

- 使用者體驗
- 穩定性
- 可維護性
- 商業可持續性


避免：

- 過度工程化
- 不必要複雜功能
- 為技術而技術


---

# 24. Future Expansion


未來可能方向：


- 更多語言
- 更多國家戒菸資料
- 全球社群
- 更多遊戲化功能
- 健康合作平台
- 企業戒菸方案


所有擴展：

必須符合：

QSC Project Rules


---

# Document Information


Project:

Quit Smoking Club


Document:

QSC Project Rules


Version:

V1.1


Purpose:

作為 QSC 長期開發、維護、架構決策依據。


---

# END

Quit Smoking Club
QSC Project Rules V1.1

---
## 程式修改指示規範

所有程式修改說明必須明確指出：

### 1. 修改檔案位置

必須提供完整路徑。

格式：

檔案：
lib/xxx/xxx.dart

---

### 2. 修改放置位置

必須說明：

- 哪個 class
- 哪個 method
- 哪段程式碼附近
- 新增在前或後

禁止只描述：
「加入這段」

---

### 3. 提供搜尋定位

修改前需提供可搜尋的原始程式碼片段，方便定位。

---

### 4. 明確說明修改方式

必須標示：

- 新增
- 刪除
- 替換
- 移動

---

### 5. Async 程式放置規範

禁止在 class 宣告區直接執行：

await function();

async 操作必須放在：

- Future 方法
- initState 搭配 async 初始化流程
- 已存在 async function

---

### 6. 修改後驗證

Flutter 修改完成後：

flutter analyze

必須確認：

0 errors

才進入下一修改階段。
---

# Content Architecture Principles

## Content Flow

UI
↓
Repository
↓
ContentRepository
↓
Supabase

Rules

- UI 不可直接存取資料來源。
- 所有內容必須經由 ContentRepository。
- Medical、Stories、Music、YouTube、Games 使用相同架構。

## MVP Rule

V1.0 只開發上市必要功能。

## Future Expansion

ContentRepository 保留未來支援：

- Official Content
- Partner Content
- Community Content