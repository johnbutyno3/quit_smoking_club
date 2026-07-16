import '../services/smoking_engine.dart';

class BehaviorEngine {
  // 對齊最新動態引擎數據
  int calculateScore(SmokingEngine engine) {
    final smoked = engine.totalSmoked;
    final planned = engine.todayPlannedCount;
    if (smoked <= planned) {
      return 100 - (smoked * 10);
    }
    return 0;
  }

  bool checkOverLimit(SmokingEngine engine) {
    return engine.totalSmoked > engine.state.plannedCount;
  }
}
