import '../models/smoking_plan.dart';

/// 每日戒菸計畫
class DailyPlan {
  final int day;
  final int plannedCount;

  const DailyPlan({required this.day, required this.plannedCount});
}

/// 戒菸計畫產生器
///
/// 負責戒菸計畫的衍生規則與時間排程。
/// SmokingPlan 本身只保存計畫資料，不負責計算排程。
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

  /// 取得指定天數。
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

  /// 依日期取得計畫。
  DailyPlan? getPlanByDate(DateTime date, DateTime quitStartDate) {
    final int day = date.difference(quitStartDate).inDays + 1;

    return getPlanOfDay(day);
  }

  /// 取得今天的計畫。
  DailyPlan? getTodayPlan(DateTime quitStartDate) {
    return getPlanByDate(DateTime.now(), quitStartDate);
  }

  /// 計算指定支數的計畫間隔時間（分鐘）。
  int intervalMinutes(int plannedCount) {
    if (plannedCount <= 1) return 0;

    final totalMinutes = plan.endTime.difference(plan.startTime).inMinutes;
    return totalMinutes ~/ (plannedCount - 1);
  }

  /// 依指定支數產生當日原定排程。
  List<DateTime> generateSchedule(int plannedCount) {
    if (plannedCount <= 0) {
      return const <DateTime>[];
    }

    final interval = intervalMinutes(plannedCount);

    return List<DateTime>.generate(
      plannedCount,
      (index) => plan.startTime.add(
        Duration(minutes: interval * index),
      ),
      growable: false,
    );
  }
}
