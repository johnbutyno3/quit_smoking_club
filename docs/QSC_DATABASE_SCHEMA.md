# Quit Smoking Club
# QSC Database Schema Document V1.0

最後更新：2026-07-30

---

# 1. Database Overview


QSC 採用混合資料架構。


資料分級：


Private Data

使用：

Firebase


用途：

儲存使用者私人資料。


---

Public Content

使用：

Supabase


用途：

儲存公開內容與社群資料。


---

Local Data

使用：

Local Storage / Cache


用途：

- 離線使用
- 快取
- 暫存資料


---

# 2. Database Architecture


資料流：


User Interface

↓

Service

↓

Repository

↓

Data Source

↓

Firebase / Supabase / Local Storage


---

# 3. Firebase Database Structure


Firebase 主要負責：

- 帳號
- 個人資料
- 戒菸資料
- 私人紀錄


---

# 3.1 Users


Collection:

users


用途：

使用者基本帳號資料。


Fields:

- uid
- email
- displayName
- createdAt
- lastLoginAt
- accountStatus


---

# 3.2 User Profile


Collection:

user_profiles


用途：

使用者個人設定。


Fields:

- uid
- nickname
- age
- smokingYears
- cigarettesPerDay
- cigarettePrice
- firstSmokeTime
- lastSmokeTime
- createdAt
- updatedAt


---

# 3.3 Quit Plan


Collection:

quit_plans


用途：

保存戒菸計畫。


Fields:

- uid
- planStartDate
- targetQuitDate
- durationDays
- plannedCount
- startTime
- endTime
- status
- createdAt


---

# 3.4 Smoking Records


Collection:

smoking_records


用途：

保存抽菸紀錄。


Fields:

- uid
- recordId
- smokeTime
- location
- note
- createdAt


用途：

提供：

- 戒菸分析
- 行為分析
- 進度計算


---

# 3.5 User Settings


Collection:

user_settings


用途：

使用者偏好設定。


Fields:

- uid
- language
- notificationEnabled
- theme
- privacySetting


---

# 4. Supabase Database Structure


Supabase 負責：

公開內容。


---

# 4.1 Medical Articles


Table:

medical_articles


用途：

醫療與戒菸知識。


Fields:

- id
- title
- content
- category
- language
- author
- createdAt
- updatedAt
- status


---

# 4.2 Success Stories


Table:

success_stories


用途：

戒菸成功故事。


Fields:

- id
- title
- content
- authorName
- language
- createdAt
- status


---

# 4.3 Music Content


Table:

music_contents


用途：

戒菸放鬆音樂。


Fields:

- id
- title
- description
- url
- category
- language


---

# 4.4 Games Content


Table:

games


用途：

遊戲中心資料。


Fields:

- id
- name
- description
- type
- rewardCoin
- status


---

# 4.5 Forum Posts


Table:

forum_posts


用途：

論壇文章。


Fields:

- id
- userId
- title
- content
- createdAt
- updatedAt
- status


限制：

目前只支援文字內容。


禁止：

- 圖片
- 影片


---

# 4.6 Forum Comments


Table:

forum_comments


用途：

文章留言。


Fields:

- id
- postId
- userId
- content
- createdAt


---

# 5. Coin System Database


COIN 為 App 內虛擬貨幣。


不可：

- 提領
- 兌換現金


---

# 5.1 Coin Balance


Storage:

Firebase


用途：

保存使用者目前 COIN。


Fields:

- uid
- balance
- updatedAt


---

# 5.2 Coin Transactions


Storage:

Firebase


用途：

保存交易紀錄。


Fields:

- transactionId
- uid
- amount
- type
- reason
- createdAt


Type:

- earn
- spend


---

# 6. VIP System


Storage:

Firebase


用途：

管理會員狀態。


Fields:

- uid
- vipLevel
- startDate
- expireDate
- status


VIP 功能：

- 移除廣告
- 增加 COIN 獎勵
- 特殊優惠


---

# 7. Local Storage Strategy


Local Storage 用途：


Cache:

- 使用者基本資料
- 最近內容
- 戒菸計畫


Offline:

- 暫存操作
- 待同步資料


---

# 8. Data Security Rules


私人資料：

只能由本人存取。


Firebase：

需要：

- Authentication
- Permission Check


公開內容：

Supabase：

依照：

- Read Permission
- Admin Permission


管理。


---

# 9. Database Design Rules


新增資料表前：

確認：


1. 是否屬於私人資料？

2. 是否屬於公開內容？

3. 是否需要離線？

4. 是否需要交易紀錄？


避免：

- 資料重複
- 不必要欄位
- 混合私人與公開資料


---

# 10. Future Expansion


未來可能增加：


- Ranking System
- Achievement System
- Reward History
- Notification System
- Enterprise Program


新增資料：

必須符合 QSC Architecture。


---

# END


Quit Smoking Club

QSC Database Schema Document V1.0