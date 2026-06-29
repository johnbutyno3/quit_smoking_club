class SmokingState {
  final DateTime startTime; // 每日第一支菸的時間 (例如: 08:00)
  final DateTime endTime; // 每日最後一支菸的時間 (例如: 22:00)
  final int plannedCount; // 當日計畫可抽數量
  final List<DateTime> logs; // 所有抽菸紀錄的時間戳記

  SmokingState({
    required this.startTime,
    required this.endTime,
    required this.plannedCount,
    List<DateTime>? logs,
  }) : logs = logs ?? [];

  // ==========================================
  // 📊 核心數據 (歷史總累計)
  // ==========================================

  /// 歷史總抽菸數
  int get totalSmoked => logs.length;

  /// 歷史總計畫剩餘可抽數
  int get remaining => (plannedCount - totalSmoked).clamp(0, 999);

  /// 歷史總超抽數量
  int get overCount =>
      totalSmoked > plannedCount ? totalSmoked - plannedCount : 0;

  // ==========================================
  // 📅 今日數據統計 (對應大綱 3.2.1 / 3.2.5 解決引擎連動錯誤)
  // ==========================================

  /// 獲取「今天」實際抽菸的數量
  int get todaySmokedCount {
    final now = DateTime.now();
    return logs
        .where(
          (log) =>
              log.year == now.year &&
              log.month == now.month &&
              log.day == now.day,
        )
        .length;
  }

  /// 今日已超抽數量
  int get todayOverCount {
    int diff = todaySmokedCount - plannedCount;
    return diff > 0 ? diff : 0;
  }

  /// 今日剩餘可抽數
  int get todayRemaining {
    int rem = plannedCount - todaySmokedCount;
    return rem < 0 ? 0 : rem;
  }

  /// 今日是否已經超量
  bool get isOverLimit => todaySmokedCount > plannedCount;

  // ==========================================
  // 🚬 行為更新（唯一寫入點 - 完美保留不可變設計）
  // ==========================================
  SmokingState addSmoke(DateTime time) {
    return SmokingState(
      startTime: startTime,
      endTime: endTime,
      plannedCount: plannedCount,
      logs: [...logs, time],
    );
  }

  // ==========================================
  // 📅 排程（唯一來源）
  // ==========================================
  List<DateTime> get schedule {
    final result = <DateTime>[];

    if (plannedCount <= 1) {
      result.add(startTime);
      return result;
    }

    final totalMinutes = endTime.difference(startTime).inMinutes;
    final interval = totalMinutes ~/ (plannedCount - 1);

    for (int i = 0; i < plannedCount; i++) {
      result.add(startTime.add(Duration(minutes: interval * i)));
    }

    return result;
  }
}
