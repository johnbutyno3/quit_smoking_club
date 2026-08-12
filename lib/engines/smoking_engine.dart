import '../models/smoking_state.dart';
import '../models/smoking_plan.dart';
import 'plan_generator.dart';

class SmokingEngine {
  SmokingState state;
  SmokingPlan plan;

  SmokingEngine(this.state, this.plan);

  int get totalSmoked => state.smokeRecords.length;

  PlanGenerator get _planGenerator => PlanGenerator(plan);

  /// 今日計畫可抽支數。
  int get todayPlannedCount {
    final todayPlan = _planGenerator.getTodayPlan(state.planStartDate);
    return todayPlan?.plannedCount ?? 0;
  }

  /// 依原定計畫時間計算目前已開放的額度。
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

  /// 每支之間的計畫間隔時間（分鐘）。
  int get intervalMinutes {
    return _planGenerator.intervalMinutes(todayPlannedCount);
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
      return plan.startTime.isAfter(now) ? plan.startTime : now;
    }

    final dynamicNext = state.lastSmokeTime!.add(
      Duration(minutes: intervalMinutes),
    );

    return dynamicNext.isAfter(now) ? dynamicNext : now;
  }

  /// 原定計畫排程。
  ///
  /// 排程永遠從計畫 startTime 開始，不因實際抽菸時間改變。
  /// 實際抽菸造成的延後只由 nextUnlockTime 處理。
  List<DateTime> get schedule {
    return _planGenerator.generateSchedule(todayPlannedCount);
  }
}
