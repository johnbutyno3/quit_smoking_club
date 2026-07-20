import 'package:flutter/material.dart';
import '../services/achievement_engine.dart';

class AchievementCard extends StatelessWidget {
  final AchievementEngine achievement;

  const AchievementCard({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "🏅 今日成就",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            LinearProgressIndicator(
              value: achievement.progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),

            const SizedBox(height: 15),

            Text(
              "完成 ${achievement.completedCount} / ${achievement.totalCount}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            ...achievement.unlocked.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  "${item.icon} ${item.title}",
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
