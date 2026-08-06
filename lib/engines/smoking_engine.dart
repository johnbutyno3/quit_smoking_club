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

    return todayPlan?.plannedCount ?? plan.plannedCount;
  }

  /// 目前時間已經開放的抽菸額度
  int get availableSlots {
    final now = DateTime.now();

    int count = 0;

    for (final time in schedule) {
      if (now.isAfter(time) || now.isAtSameMomentAs(time)) {
        count++;
      }
    }

    return count;
  }

  int get remaining {
    final value = todayPlannedCount - totalSmoked;

    return value > 0 ? value : 0;
  }

  int get overCount {
    final value = totalSmoked - todayPlannedCount;

    return value > 0 ? value : 0;
  }

  // 每支間隔時間
  int get intervalMinutes {
    if (todayPlannedCount <= 1) return 0;

    final totalMinutes = state.endTime.difference(state.startTime).inMinutes;

    return totalMinutes ~/ (todayPlannedCount - 1);
  }

  // 下一次解禁時間
  DateTime? get nextUnlockTime {
    if (totalSmoked >= todayPlannedCount) {
      return null;
    }

    // 第一支
    if (state.lastSmokeTime == null) {
      return state.startTime;
    }

    // 後續從實際抽菸時間重新計算

    return state.lastSmokeTime!.add(Duration(minutes: intervalMinutes));
  }

  // 動態排程
  List<DateTime> get schedule {
    List<DateTime> result = [];

    DateTime current;

    if (state.lastSmokeTime == null) {
      current = state.startTime;
    } else {
      current = state.lastSmokeTime!;
    }

    for (int i = 0; i < todayPlannedCount; i++) {
      result.add(current.add(Duration(minutes: intervalMinutes * i)));
    }

    return result;
  }
}
