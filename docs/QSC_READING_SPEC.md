# QSC Reading System Specification (V1)

## Purpose

Build a reading system that encourages long-term reading without
allowing users to farm COIN.

## Content Sources

-   Public-domain novels
-   Short stories
-   Fables
-   Smoking cessation articles
-   Inspirational stories
-   Primary source: Supabase

## Effective Reading Time

Formula:

    effectiveSeconds = min(300, max(20, ceil(wordCount / 4)))

Examples:

    Words   Effective Time
  ------- ----------------
      100           25 sec
      200           50 sec
      300           75 sec
      500          125 sec
     1000          250 sec

Rules: - User must remain on the page for at least the effective time. -
User must manually continue to the next page/chapter. - Only completed
pages count.

## Statistics

Track: - Daily reading time - Monthly reading time - Total reading
time - Daily words - Monthly words - Total words - Chapters completed -
Books completed

## Rewards

No immediate COIN for reading.

Monthly leaderboard: - Top 1%: 300 COIN - Top 5%: 100 COIN - Top 10%: 50
COIN

Only the highest reward is granted.

## Badges

First completion of a book: - Completion badge - Completion record - No
repeat COIN rewards

## Future

-   Reading streak
-   Daily recommendations
-   Favorites
-   Search
-   Reading analytics
