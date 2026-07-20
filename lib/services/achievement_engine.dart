import 'recovery_engine.dart';
import 'smoking_engine.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
  });
}

class AchievementEngine {
  final SmokingEngine smoking;
  final RecoveryEngine recovery;

  AchievementEngine({required this.smoking, required this.recovery});

  int get quitDays =>
      DateTime.now().difference(smoking.state.planStartDate).inDays + 1;

  List<Achievement> get achievements => [
    Achievement(
      id: "day1",
      title: "第一天",
      description: "開始戒菸旅程",
      icon: "🎉",
      unlocked: quitDays >= 1,
    ),
    Achievement(
      id: "day7",
      title: "一週達成",
      description: "連續戒菸 7 天",
      icon: "🔥",
      unlocked: quitDays >= 7,
    ),
    Achievement(
      id: "day30",
      title: "一個月達成",
      description: "連續戒菸 30 天",
      icon: "🏆",
      unlocked: quitDays >= 30,
    ),
    Achievement(
      id: "money1000",
      title: "省下 1000 元",
      description: "累積省下 1000 元",
      icon: "💰",
      unlocked: false,
    ),
    Achievement(
      id: "recovery",
      title: "健康恢復",
      description: "完成第一個身體恢復里程碑",
      icon: "❤️",
      unlocked: recovery.completedStages.isNotEmpty,
    ),
  ];

  List<Achievement> get unlocked =>
      achievements.where((e) => e.unlocked).toList();

  List<Achievement> get locked =>
      achievements.where((e) => !e.unlocked).toList();

  int get completedCount => unlocked.length;

  int get totalCount => achievements.length;

  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;
}
