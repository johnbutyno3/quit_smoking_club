import '../models/smoking_plan.dart';

/// 每日戒菸計畫
class DailyPlan {
  final int day;
  final int plannedCount;

  const DailyPlan({required this.day, required this.plannedCount});
}

/// 戒菸計畫產生器
class PlanGenerator {
  final SmokingPlan plan;

  const PlanGenerator(this.plan);

  /// 產生整個戒菸計畫
  List<DailyPlan> generate() {
    final List<DailyPlan> plans = [];

    final int startCount = plan.plannedCount;
    final int totalDays = plan.durationDays;

    if (totalDays <= 0) {
      return plans;
    }

    if (totalDays == 1) {
      return const [DailyPlan(day: 1, plannedCount: 0)];
    }

    for (int day = 1; day <= totalDays; day++) {
      final double progress = (day - 1) / (totalDays - 1);

      int count = (startCount * (1 - progress)).round();

      if (count < 0) {
        count = 0;
      }

      plans.add(DailyPlan(day: day, plannedCount: count));
    }

    plans[plans.length - 1] = DailyPlan(day: totalDays, plannedCount: 0);

    return plans;
  }

  /// 取得指定天數
  DailyPlan? getPlanOfDay(int day) {
    final plans = generate();

    for (final plan in plans) {
      if (plan.day == day) {
        return plan;
      }
    }

    return null;
  }

  /// 依日期取得計畫
  DailyPlan? getPlanByDate(DateTime date, DateTime quitStartDate) {
    final int day = date.difference(quitStartDate).inDays + 1;

    return getPlanOfDay(day);
  }

  /// 取得今天的計畫
  DailyPlan? getTodayPlan(DateTime quitStartDate) {
    return getPlanByDate(DateTime.now(), quitStartDate);
  }
}
