class SmokingState {
  final DateTime planStartDate;
  final DateTime startTime;
  final DateTime endTime;

  // 今日目標支數
  final int plannedCount;

  // 實際抽菸紀錄
  final List<DateTime> smokeRecords;

  // 每一支菸解禁時間
  final List<DateTime> unlockTimes;

  // 目前進度
  final int currentIndex;

  // 最後一次抽菸時間
  final DateTime? lastSmokeTime;

  const SmokingState({
    required this.planStartDate,
    required this.startTime,
    required this.endTime,
    required this.plannedCount,

    this.smokeRecords = const [],

    this.unlockTimes = const [],

    this.currentIndex = 0,

    this.lastSmokeTime,
  });

  SmokingState addSmoke(DateTime time) {
    final newRecords = List<DateTime>.from(smokeRecords)..add(time);

    return SmokingState(
      planStartDate: planStartDate,

      startTime: startTime,

      endTime: endTime,

      plannedCount: plannedCount,

      smokeRecords: newRecords,

      unlockTimes: unlockTimes,

      // 抽完下一支
      currentIndex: currentIndex + 1,

      lastSmokeTime: time,
    );
  }

  int get totalSmoked => smokeRecords.length;

  bool get finished => totalSmoked >= plannedCount;
}
