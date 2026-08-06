import '../models/smoking_state.dart';

class RecoveryStage {
  final String titleKey;
  final String descriptionKey;
  final Duration unlockAfter;

  const RecoveryStage({
    required this.titleKey,
    required this.descriptionKey,
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
      titleKey: 'recoveryStage20mTitle',
      descriptionKey: 'recoveryStage20mDescription',
      unlockAfter: Duration(minutes: 20),
    ),
    RecoveryStage(
      titleKey: 'recoveryStage12hTitle',
      descriptionKey: 'recoveryStage12hDescription',
      unlockAfter: Duration(hours: 12),
    ),
    RecoveryStage(
      titleKey: 'recoveryStage2wTitle',
      descriptionKey: 'recoveryStage2wDescription',
      unlockAfter: Duration(days: 14),
    ),
    RecoveryStage(
      titleKey: 'recoveryStage3mTitle',
      descriptionKey: 'recoveryStage3mDescription',
      unlockAfter: Duration(days: 90),
    ),
    RecoveryStage(
      titleKey: 'recoveryStage1yTitle',
      descriptionKey: 'recoveryStage1yDescription',
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
