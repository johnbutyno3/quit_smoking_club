import '../models/smoking_state.dart';
import '../models/smoking_plan.dart';
import 'plan_generator.dart';

class SmokingEngine {
  SmokingState state;
  SmokingPlan plan;

  SmokingEngine(this.state, this.plan);

  int get totalSmoked => state.smokeRecords.length;

  /// 今日計畫可抽支數
  int get todayPlannedCount {
    final generator = PlanGenerator(plan);
    final todayPlan = generator.getTodayPlan(state.planStartDate);

    return todayPlan?.plannedCount ?? 0;
  }

  /// 依「計畫時間」計算目前已開放的額度。
  ///
  /// 不使用 lastSmokeTime，避免把「原定解禁時間」
  /// 與「實際抽菸時間」混成同一條時間軸。
  int get availableSlots {
    final now = DateTime.now();
    return schedule.where((time) => !now.isBefore(time)).length;
  }

  int get remaining {
    final value = todayPlannedCount - totalSmoked;
    return value > 0 ? value : 0;
  }

  int get overCount {
    final value = totalSmoked - todayPlannedCount;
    return value > 0 ? value : 0;
  }

  /// 每支之間的計畫間隔時間（分鐘）
  int get intervalMinutes {
    if (todayPlannedCount <= 1) return 0;

    final totalMinutes = state.endTime.difference(state.startTime).inMinutes;
    return totalMinutes ~/ (todayPlannedCount - 1);
  }

  /// 下一次實際解禁時間。
  ///
  /// 第一支以計畫開始時間為準；之後依最後一次實際抽菸時間重新計算。
  DateTime? get nextUnlockTime {
    if (todayPlannedCount <= 0 || totalSmoked >= todayPlannedCount) {
      return null;
    }

    final now = DateTime.now();

    if (state.lastSmokeTime == null) {
      return state.startTime.isAfter(now) ? state.startTime : now;
    }

    final dynamicNext = state.lastSmokeTime!.add(
      Duration(minutes: intervalMinutes),
    );

    return dynamicNext.isAfter(now) ? dynamicNext : now;
  }

  /// 原定計畫排程。
  ///
  /// 排程永遠從 startTime 開始，不因實際抽菸時間改變。
  /// 實際抽菸造成的延後只由 nextUnlockTime 處理。
  List<DateTime> get schedule {
    if (todayPlannedCount <= 0) {
      return const <DateTime>[];
    }

    return List<DateTime>.generate(
      todayPlannedCount,
      (index) => state.startTime.add(
        Duration(minutes: intervalMinutes * index),
      ),
      growable: false,
    );
  }
}
