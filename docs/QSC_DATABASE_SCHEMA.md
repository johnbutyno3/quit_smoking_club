# Quit Smoking Club

# QSC Database Schema Document V2.0

Last Updated: 2026-08-05

---

# 1. Database Overview

QSC uses a hybrid database architecture.

The system separates data according to ownership and access requirements.

---

## Private Data

Technology:

Firebase

Purpose:

Store user private information.

Examples:

* Account information
* Personal profile
* Quit smoking plans
* Smoking records
* User settings
* Coin balance
* VIP status

---

## Public Content and Community Data

Technology:

Supabase

Purpose:

Store public content and community features.

Examples:

* Articles
* Stories
* Music
* YouTube resources
* Games metadata
* Reading content
* Forum data

---

## Local Data

Technology:

Local Storage / Cache

Purpose:

* Offline access
* Cache frequently used content
* Temporary synchronization data

---

# 2. Database Architecture

Data flow:

```
User Interface

↓

Service

↓

Repository

↓

Data Source

↓

Firebase / Supabase / Local Storage
```

---

# 3. Firebase Database Structure

Firebase is responsible for private user data.

---

# 3.1 Users

Collection:

```
users
```

Fields:

* uid
* email
* displayName
* createdAt
* lastLoginAt
* accountStatus

---

# 3.2 User Profile

Collection:

```
user_profiles
```

Fields:

* uid
* nickname
* age
* smokingYears
* cigarettesPerDay
* cigarettePrice
* firstSmokeTime
* lastSmokeTime
* createdAt
* updatedAt

---

# 3.3 Quit Plan

Collection:

```
quit_plans
```

Fields:

* uid
* planStartDate
* targetQuitDate
* durationDays
* plannedCount
* startTime
* endTime
* status
* createdAt

---

# 3.4 Smoking Records

Collection:

```
smoking_records
```

Fields:

* uid
* recordId
* smokeTime
* location
* note
* createdAt

Used for:

* Quit progress analysis
* Behavior analysis
* Personal statistics

---

# 3.5 User Settings

Collection:

```
user_settings
```

Fields:

* uid
* language
* notificationEnabled
* theme
* privacySetting

---

# 4. Supabase Database Structure

Supabase manages public content and community data.

---

# 4.1 Unified Content System

Table:

```
content_items
```

Purpose:

A unified content source for all public content.

Supported categories:

* medical
* stories
* music
* youtube
* games

Fields:

```
id
unique_id
title
category
language
content
link
author
download_coin_cost
status
created_at
updated_at
```

Category examples:

```
medical
stories
music
youtube
games
```

The application uses:

```
SupabaseContentService

↓

ContentRepository

↓

ContentItem
```

---

# 4.2 Reading System

Reading uses a separated structure because books contain multiple chapters.

---

Table:

```
reading_books
```

Fields:

* id
* title
* author
* description
* language
* download_coin_cost
* status
* created_at
* updated_at

---

Table:

```
reading_chapters
```

Fields:

* id
* book_id
* chapter_order
* title
* content
* word_count
* created_at

Relationship:

```
reading_books

1

↓

N

reading_chapters
```

---

# 4.3 Forum Posts

Table:

```
forum_posts
```

Fields:

* id
* userId
* title
* content
* createdAt
* updatedAt
* status

Current limitation:

Text only.

Not supported:

* Image upload
* Video upload

---

# 4.4 Forum Comments

Table:

```
forum_comments
```

Fields:

* id
* postId
* userId
* content
* createdAt

---

# 5. Coin System Database

COIN is an internal virtual currency.

Rules:

* Cannot withdraw
* Cannot exchange for cash

---

## 5.1 Coin Balance

Technology:

Firebase

Fields:

* uid
* balance
* updatedAt

---

## 5.2 Coin Transactions

Technology:

Firebase

Fields:

* transactionId
* uid
* amount
* type
* reason
* createdAt

Types:

* earn
* spend

---

# 6. VIP System

Technology:

Firebase

Fields:

* uid
* vipLevel
* startDate
* expireDate
* status

VIP benefits:

* Remove advertisements
* Increase rewards
* Special discounts

---

# 7. Local Storage Strategy

Local storage is used for:

Cache:

* Recent content
* User preferences
* Quit plan data

Offline:

* Temporary actions
* Pending synchronization

---

# 8. Security Rules

Private data:

Only accessible by the owner.

Firebase:

Requires:

* Authentication
* Permission validation

Public data:

Supabase:

Controlled by:

* Read permission
* Admin permission

---

# 9. Database Design Rules

Before creating a new table:

Check:

1. Is this private user data?
2. Is this public content?
3. Does it require offline support?
4. Does it require transaction history?

Avoid:

* Duplicate data models
* Unnecessary tables
* Mixing private and public data

---

# 10. Future Expansion

Possible future systems:

* Ranking System
* Achievement System
* Reward History
* Notification System
* Enterprise Program

All new database designs must follow:

QSC Architecture Rules.

---

# END

Quit Smoking Club
QSC Database Schema Document V2.0
