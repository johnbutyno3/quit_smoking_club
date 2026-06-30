class SmokingState {
  final DateTime startTime;
  final DateTime endTime;
  final int plannedCount;
  final List<DateTime> smokeRecords;

  // 💡 紀錄上一次真正按下抽菸的時間點
  final DateTime? lastSmokeTime;

  const SmokingState({
    required this.startTime,
    required this.endTime,
    required this.plannedCount,
    this.smokeRecords = const [],
    this.lastSmokeTime,
  });

  // 當按下抽菸按鈕時，不僅增加紀錄，還更新 lastSmokeTime
  SmokingState addSmoke(DateTime time) {
    final newRecords = List<DateTime>.from(smokeRecords)..add(time);
    return SmokingState(
      startTime: startTime,
      endTime: endTime,
      plannedCount: plannedCount,
      smokeRecords: newRecords,
      lastSmokeTime: time, // 鎖定最新抽菸時間
    );
  }

  int get totalSmoked => smokeRecords.length;
}
