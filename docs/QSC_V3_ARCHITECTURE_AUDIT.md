# QSC V3 Architecture Audit

Last Updated: 2026-08-06

## Current Phase

V3 Architecture Stabilization

This document records the current project architecture status.

This is an audit report, not a development rule document.

---

# 1. Current Layer Structure

Current target architecture:

Screen Layer
↓
UseCase Layer
↓
Repository Layer
↓
Service Layer
↓
External Platform


Current project status:

- Core architecture exists.
- Migration is incomplete.
- Some modules still directly depend on Repository without UseCase.
- Do not perform large-scale refactoring during stabilization.

---

# 2. Repository Layer Audit

Location:

lib/repositories


## Existing Repositories

- forum_repository.dart
- medical_repository.dart
- music_repository.dart
- ranking_repository.dart
- reading_repository.dart
- smoking_repository.dart
- story_repository.dart
- youtube_repository.dart
- coin_repository.dart
- content_repository.dart


## Status


### Completed / Stable

content_repository.dart

- Connected with SupabaseContentService.
- Suitable for public content management.


coin_repository.dart

- Connected with Coin UseCases.
- Current transaction flow is acceptable.


ranking_repository.dart

- Has related UseCases.
- Basic structure is correct.


### Partial

forum_repository.dart

Current missing implementations:

- addPost()
- likePost()
- giftPost()


Risk:

UI actions may appear successful while data is not persisted.

---

# 3. UseCase Layer Audit

Location:

lib/usecases


## Existing UseCases


## Coin

- get_coin_balance_usecase.dart
- spend_coin_usecase.dart
- claim_daily_reward_usecase.dart


Status:

Good.

Coin flow currently follows:

UI
↓
UseCase
↓
Repository
↓
Service


## Ranking

- get_rankings_usecase.dart
- update_ranking_usecase.dart
- delete_ranking_usecase.dart


Status:

Good.


## Current Limitation

Not all modules have UseCase layer.

Existing modules may still use:

Screen
↓
Repository
↓
Service


This is acceptable during stabilization.

---

# 4. Service Layer Audit

Location:

lib/services


## Supabase Services

Existing:

- supabase_service.dart
- supabase_content_service.dart
- supabase_forum_service.dart
- supabase_comment_service.dart
- supabase_like_service.dart
- supabase_ranking_service.dart
- supabase_reading_service.dart
- supabase_coin_log_service.dart


Assessment:

Supabase is correctly used for:

- Public content
- Community features
- Reading system
- Ranking
- Forum data


---

## Firebase Responsibilities

Current:

- Authentication
- User profile
- Private user information
- Personal quit tracking data


Do not migrate all Firebase functions to Supabase without architecture review.

---

# 5. Service Technical Debt


## CoinService

Risk:

Responsibilities may overlap with:

- coin_reward_service.dart
- supabase_coin_log_service.dart


Future review:

Separate:

- Balance management
- Reward calculation
- Transaction logging


---

## StorageService

Risk:

May contain too many responsibilities.

Current examples:

- user information
- coin data
- smoking records
- settings


Future review:

Separate local cache from business data.

---

# 6. Model Layer Audit

Location:

lib/models


## Core Models

- smoking_plan.dart
- smoking_state.dart
- smoking_log.dart
- quit_plan_result.dart


Status:

Stable.


## Community Models

- forum_post.dart
- ranking_model.dart


Status:

Mostly stable.

Future review:

Forum category logic should not depend on translated strings.


## Content Models

Existing:

- medical_article.dart
- music_item.dart
- story_item.dart
- youtube_item.dart
- content_item.dart


Current decision:

Keep separate models.

Do not merge without a clear requirement.

---

# 7. Technical Debt Priority


## P0

Forum completion:

- Implement ForumRepository missing functions.
- Ensure database persistence.


## P1

Review:

- StorageService responsibility.
- CoinService responsibility.
- Forum category design.


## P2

Evaluate:

- Content model unification.
- Additional UseCase migration.


---

# 8. Current Do Not Touch List

During V3 stabilization:

Do not:

- Rewrite architecture.
- Replace Firebase completely.
- Merge all models.
- Perform large UI redesign.
- Add unnecessary abstraction.


---

# 9. Next Development Order


1. Stabilize existing architecture.
2. Complete incomplete implementations.
3. Verify Firebase/Supabase boundaries.
4. Improve consistency.
5. Start UI/game/art development.s