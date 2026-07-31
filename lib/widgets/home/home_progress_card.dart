import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class HomeProgressCard extends StatelessWidget {
  final int currentDay;
  final int totalDays;
  final int smokedToday;
  final int targetToday;
  final int remaining;

  const HomeProgressCard({
    super.key,
    required this.currentDay,
    required this.totalDays,
    required this.smokedToday,
    required this.targetToday,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final progress = targetToday == 0
        ? 0.0
        : (smokedToday / targetToday).clamp(0.0, 1.0);

    return Card(
      color: Colors.white.withAlpha(230),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              l10n.quitProgress,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              l10n.dayProgress(currentDay, totalDays),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Text(l10n.todayGoal(targetToday)),

            const SizedBox(height: 8),

            Text(l10n.smokedToday(smokedToday)),

            const SizedBox(height: 8),

            Text(l10n.remainingToday(remaining)),

            const SizedBox(height: 16),

            LinearProgressIndicator(value: progress),
          ],
        ),
      ),
    );
  }
}
