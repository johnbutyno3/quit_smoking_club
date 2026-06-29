import '../models/smoking_state.dart';

class SmokingEngine {
  SmokingState state;
  SmokingEngine(this.state);

  int get totalSmoked => state.totalSmoked;
  List<DateTime> get schedule => state.schedule;
  int get plannedCount => state.plannedCount;
  int get remaining => plannedCount - totalSmoked;

  // 💡 補齊這三個核心欄位，徹底消滅 6 個問題！
  int get overCount => state.overCount;
  int get todaySmokedCount => state.totalSmoked;
  bool get isOverLimit => totalSmoked > plannedCount;
}
