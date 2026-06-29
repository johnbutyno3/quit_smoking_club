class SmokingPlan {
  final DateTime startTime; // 每日第一支菸的時間 (例如: 當天 08:00)
  final DateTime endTime; // 每日最後一支菸的時間 (例如: 當天 22:00)
  final int plannedCount; // 當日計畫可抽數量
  final int durationDays; // 總戒斷計畫天數 (大綱 2.2.1 預設 90 天)

  SmokingPlan({
    required this.startTime,
    required this.endTime,
    required this.plannedCount,
    this.durationDays = 90, // 預設為 90 天
  });

  /// 2.3.2 計算當日可抽菸的總區間分鐘數
  int get totalMinutes => endTime.difference(startTime).inMinutes;

  /// 2.3.2 抽菸時間間隔 (改用整數除法 ~/ 效能更佳)
  int get intervalMinutes {
    if (plannedCount <= 1) return 0;
    return totalMinutes ~/ (plannedCount - 1);
  }

  /// 2.2.1 驗證計畫天數是否符合 10~360 天的規範
  bool get isValidDuration {
    return durationDays >= 10 && durationDays <= 360;
  }

  /// 2.3 展開當日的抽菸排程時間表
  List<DateTime> generateSchedule() {
    List<DateTime> schedule = [];
    final int interval = intervalMinutes;

    for (int i = 0; i < plannedCount; i++) {
      schedule.add(startTime.add(Duration(minutes: interval * i)));
    }
    return schedule;
  }

  // ==========================================
  // 💾 JSON 序列化轉換 (便於儲存使用者的戒菸計畫)
  // ==========================================

  factory SmokingPlan.fromJson(Map<String, dynamic> json) {
    return SmokingPlan(
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      plannedCount: json['plannedCount'] ?? 5,
      durationDays: json['durationDays'] ?? 90,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'plannedCount': plannedCount,
      'durationDays': durationDays,
    };
  }
}
