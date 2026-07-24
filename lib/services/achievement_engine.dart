import 'recovery_engine.dart';
import 'smoking_engine.dart';
import 'coin_service.dart';
import 'storage_service.dart';

class Achievement {
  final String id;

  final String titleKey;

  final String descriptionKey;

  final String icon;

  final bool unlocked;

  final String? progressKey;
  const Achievement({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.unlocked,
    this.progressKey,
  });
}

class AchievementEngine {
  final SmokingEngine smoking;
  final RecoveryEngine recovery;

  AchievementEngine({required this.smoking, required this.recovery});

  int get quitDays =>
      DateTime.now().difference(smoking.state.planStartDate).inDays + 1;
  int get savedMoney {
    final days = quitDays;

    final daily = smoking.state.plannedCount;

    return days * daily * 10;
  }

  List<Achievement> get achievements => [
    Achievement(
      id: "day1",
      titleKey: "achievementDay1Title",
      descriptionKey: "achievementDay1Description",
      icon: "🎉",
      unlocked: quitDays >= 1,
    ),
    Achievement(
      id: "day7",
      titleKey: "achievementDay7Title",
      descriptionKey: "achievementDay7Description",
      icon: "🔥",
      unlocked: quitDays >= 7,
      progressKey: quitDays >= 7 ? null : "achievementDay7Progress",
    ),
    Achievement(
      id: "day30",
      titleKey: "achievementDay30Title",
      descriptionKey: "achievementDay30Description",
      icon: "🏆",
      unlocked: quitDays >= 30,
      progressKey: quitDays >= 30 ? null : "achievementDay30Progress",
    ),
    Achievement(
      id: "money1000",
      titleKey: "achievementMoney1000Title",
      descriptionKey: "achievementMoney1000Description",
      icon: "💰",
      unlocked: savedMoney >= 1000,
      progressKey: savedMoney >= 1000 ? null : "achievementMoney1000Progress",
    ),
    Achievement(
      id: "recovery",
      titleKey: "achievementRecoveryTitle",
      descriptionKey: "achievementRecoveryDescription",
      icon: "❤️",
      unlocked: recovery.completedStages.isNotEmpty,
      progressKey: recovery.completedStages.isNotEmpty
          ? null
          : "achievementRecoveryProgress",
    ),
  ];

  List<Achievement> get unlocked =>
      achievements.where((e) => e.unlocked).toList();

  List<Achievement> get locked =>
      achievements.where((e) => !e.unlocked).toList();

  int get completedCount => unlocked.length;

  int get totalCount => achievements.length;

  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;
  Future<void> claimAchievementRewards() async {
    final claimed = await StorageService.getClaimedAchievements();

    final coinService = CoinService();

    for (final achievement in achievements) {
      if (achievement.unlocked && !claimed.contains(achievement.id)) {
        int reward = 0;

        switch (achievement.id) {
          case "day1":
            reward = 10;
            break;

          case "day7":
            reward = 50;
            break;

          case "day30":
            reward = 100;
            break;

          case "money1000":
            reward = 100;
            break;

          case "recovery":
            reward = 50;
            break;
        }

        if (reward > 0) {
          await coinService.addCoin(reward, 'achievement_${achievement.id}');

          await StorageService.saveClaimedAchievement(achievement.id);
        }
      }
    }
  }
}
