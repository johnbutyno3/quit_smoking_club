class SmokingLog {
  final DateTime time;
  final bool isPlanned; // true: 計畫內抽菸, false: 破戒/非計畫抽菸

  SmokingLog({required this.time, required this.isPlanned});

  // ==========================================
  // 📆 方便統計與 UI 篩選的輔助欄位 (對應大綱 2.3.4)
  // ==========================================

  /// 檢查此紀錄是否為「今天」
  bool get isToday {
    final now = DateTime.now();
    return time.year == now.year &&
        time.month == now.month &&
        time.day == now.day;
  }

  /// 獲取該紀錄的年月日字串 (格式: 2026-06-29)，方便 Group By 分組統計
  String get dateString {
    return "${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}";
  }

  // ==========================================
  // 💾 JSON 序列化轉換 (用於本地檔案或資料庫儲存)
  // ==========================================

  /// 將 JSON 轉回物件
  factory SmokingLog.fromJson(Map<String, dynamic> json) {
    return SmokingLog(
      time: DateTime.parse(json['time']),
      isPlanned: json['isPlanned'] ?? true,
    );
  }

  /// 將物件轉為 JSON
  Map<String, dynamic> toJson() {
    return {'time': time.toIso8601String(), 'isPlanned': isPlanned};
  }
}
