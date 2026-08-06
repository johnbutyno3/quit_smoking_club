import 'package:flutter/material.dart';
import '../engines/achievement_engine.dart';
import '../core/utils/achievement_localizer.dart';
import '../l10n/app_localizations.dart';

class AchievementCard extends StatelessWidget {
  final AchievementEngine achievement;

  const AchievementCard({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "🏅 ${l10n.todayAchievement}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            LinearProgressIndicator(
              value: achievement.progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),

            const SizedBox(height: 15),

            Text(
              l10n.achievementCompleted(
                achievement.completedCount,
                achievement.totalCount,
              ),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            ...achievement.achievements.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${item.icon} ${AchievementLocalizer.title(item, l10n)}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      AchievementLocalizer.description(item, l10n),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),

                    if (item.progressKey != null)
                      Text(
                        AchievementLocalizer.progress(item, l10n),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
