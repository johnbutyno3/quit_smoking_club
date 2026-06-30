import '../models/smoking_state.dart';

class SmokingEngine {
  SmokingState state;

  SmokingEngine(this.state);

  int get totalSmoked => state.totalSmoked;
  int get remaining => state.plannedCount - totalSmoked;

  // 計算每一支菸的標準固定間隔 (分鐘)
  int get intervalMinutes {
    if (state.plannedCount <= 1) return 0;
    final totalDuration = state.endTime.difference(state.startTime).inMinutes;
    return totalDuration ~/ (state.plannedCount - 1);
  }

  // 💡 核心核心：隨時會變動的下一次解鎖時間算法！
  DateTime? get nextUnlockTime {
    if (totalSmoked >= state.plannedCount) return null;

    // 如果使用者還沒抽過第一支菸，解鎖起點就是計畫的 startTime
    if (state.lastSmokeTime == null) {
      return state.startTime;
    }

    // 舉例：原本每90分鐘一次，09:30才按抽菸，則從 09:30 開始計算 90 分鐘 ➔ 11:00
    return state.lastSmokeTime!.add(Duration(minutes: intervalMinutes));
  }

  // 生成今天理想的初始計畫排程表 (供底部膠囊 Chips 顯示參考)
  List<DateTime> get schedule {
    List<DateTime> list = [];
    final interval = intervalMinutes;
    for (int i = 0; i < state.plannedCount; i++) {
      list.add(state.startTime.add(Duration(minutes: interval * i)));
    }
    return list;
  }
}
