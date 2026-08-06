import 'recovery_engine.dart';
import 'smoking_engine.dart';
import '../config/coin_rules.dart';

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

  int _loginStreak = 0;
  int _totalSpentCoins = 0;

  AchievementEngine({required this.smoking, required this.recovery});

  void updateProgressContext({
    required int loginStreak,
    required int totalSpentCoins,
  }) {
    _loginStreak = loginStreak;
    _totalSpentCoins = totalSpentCoins;
  }

  int get quitDays =>
      DateTime.now().difference(smoking.state.planStartDate).inDays + 1;

  int get loginStreak => _loginStreak;

  int get totalSpentCoins => _totalSpentCoins;

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
      unlocked: quitDays >= 1 && loginStreak >= 1,
    ),

    Achievement(
      id: "day7",
      titleKey: "achievementDay7Title",
      descriptionKey: "achievementDay7Description",
      icon: "🔥",
      unlocked: quitDays >= 7 && loginStreak >= 7,
      progressKey: quitDays >= 7 && loginStreak >= 7
          ? null
          : "achievementDay7Progress",
    ),

    Achievement(
      id: "day30",
      titleKey: "achievementDay30Title",
      descriptionKey: "achievementDay30Description",
      icon: "🏆",
      unlocked: quitDays >= 30 && loginStreak >= 30,
      progressKey: quitDays >= 30 && loginStreak >= 30
          ? null
          : "achievementDay30Progress",
    ),

    Achievement(
      id: "spending1000",
      titleKey: "achievementSpending1000Title",
      descriptionKey: "achievementSpending1000Description",
      icon: "🛒",
      unlocked: _totalSpentCoins >= CoinRules.spendingAchievementTarget,
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

  int rewardForAchievement(String achievementId) {
    switch (achievementId) {
      case 'day1':
        return CoinRules.achievementDay1;
      case 'day7':
        return CoinRules.achievementDay7;
      case 'day30':
        return CoinRules.achievementDay30;
      case 'spending1000':
        return CoinRules.spendingAchievementReward;
      case 'recovery':
        return CoinRules.achievementRecovery;
      default:
        return 0;
    }
  }
}
