import '../models/smoking_state.dart';

class RecoveryStage {
  final String title;
  final String description;
  final Duration unlockAfter;

  const RecoveryStage({
    required this.title,
    required this.description,
    required this.unlockAfter,
  });
}

class RecoveryTimelineItem {
  final RecoveryStage stage;
  final bool completed;
  final bool current;

  const RecoveryTimelineItem({
    required this.stage,
    required this.completed,
    required this.current,
  });
}

class RecoveryEngine {
  final SmokingState state;

  RecoveryEngine(this.state);

  Duration get quitDuration => DateTime.now().difference(state.planStartDate);

  /// 已完成的恢復階段
  List<RecoveryStage> get completedStages {
    return stages.where(isUnlocked).toList();
  }

  List<RecoveryTimelineItem> get timeline {
    return stages.map((stage) {
      final completed = isUnlocked(stage);

      return RecoveryTimelineItem(
        stage: stage,
        completed: completed,
        current: !completed && stage == nextStage,
      );
    }).toList();
  }

  /// 下一個恢復階段
  RecoveryStage? get nextStage {
    for (final stage in stages) {
      if (!isUnlocked(stage)) {
        return stage;
      }
    }
    return null;
  }

  /// 距離下一個恢復還剩多久
  Duration? get timeToNextStage {
    final next = nextStage;
    if (next == null) return null;

    return next.unlockAfter - quitDuration;
  }

  /// 完成百分比
  int get percent {
    return (progress * 100).round();
  }

  List<RecoveryStage> get stages => const [
    RecoveryStage(
      title: "20 分鐘",
      description: "心率開始恢復正常。",
      unlockAfter: Duration(minutes: 20),
    ),
    RecoveryStage(
      title: "12 小時",
      description: "血液中的一氧化碳恢復正常。",
      unlockAfter: Duration(hours: 12),
    ),
    RecoveryStage(
      title: "2 週",
      description: "肺功能開始改善。",
      unlockAfter: Duration(days: 14),
    ),
    RecoveryStage(
      title: "3 個月",
      description: "循環系統持續改善。",
      unlockAfter: Duration(days: 90),
    ),
    RecoveryStage(
      title: "1 年",
      description: "心血管疾病風險明顯下降。",
      unlockAfter: Duration(days: 365),
    ),
  ];

  bool isUnlocked(RecoveryStage stage) {
    return quitDuration >= stage.unlockAfter;
  }

  double get progress {
    final total = stages.last.unlockAfter.inSeconds;
    final current = quitDuration.inSeconds;

    if (current >= total) return 1.0;
    if (current <= 0) return 0.0;

    return current / total;
  }
}
