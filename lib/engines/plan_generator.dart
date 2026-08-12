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

  /// 產生完整的每日戒菸計畫。
  ///
  /// 最後一天固定為 0，代表完成戒菸目標。
  List<DailyPlan> generateQuitPlan(int startCount, int days) {
    if (days <= 0) {
      return const <DailyPlan>[];
    }

    if (days == 1) {
      return const [DailyPlan(day: 1, plannedCount: 0)];
    }

    final safeStartCount = startCount < 0 ? 0 : startCount;
    final result = <DailyPlan>[];

    for (int day = 1; day <= days; day++) {
      final progress = (day - 1) / (days - 1);
      final count = (safeStartCount * (1 - progress)).round();

      result.add(
        DailyPlan(
          day: day,
          plannedCount: day == days ? 0 : count,
        ),
      );
    }

    return result;
  }

  /// 依目前 SmokingPlan 產生完整計畫。
  List<DailyPlan> generate() {
    return generateQuitPlan(plan.plannedCount, plan.durationDays);
  }

  /// 取得指定天數
  DailyPlan? getPlanOfDay(int day) {
    if (day <= 0) {
      return null;
    }

    final plans = generate();

    for (final dailyPlan in plans) {
      if (dailyPlan.day == day) {
        return dailyPlan;
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
