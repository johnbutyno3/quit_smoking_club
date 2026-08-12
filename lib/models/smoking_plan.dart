class SmokingPlan {
  final DateTime startTime; // 每日第一支菸的時間 (例如: 當天 08:00)
  final DateTime endTime; // 每日最後一支菸的時間 (例如: 當天 22:00)
  final int plannedCount; // 當日計畫可抽數量
  final int durationDays; // 總戒斷計畫天數 (大綱 2.2.1 預設 90 天)

  SmokingPlan({
    required this.startTime,
    required this.endTime,
    required this.plannedCount,
    this.durationDays = 90,
  });

  /// 驗證計畫天數是否符合 10~360 天的規範。
  bool get isValidDuration {
    return durationDays >= 10 && durationDays <= 360;
  }

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
