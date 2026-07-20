class QuitPlanResult {
  final int totalDays;
  final int startCount;
  final int packPrice;
  final int cigarettesPerPack;

  QuitPlanResult({
    required this.totalDays,
    required this.startCount,
    required this.packPrice,
    required this.cigarettesPerPack,
  });

  // 總花費
  int get totalCost {
    final packs = ((startCount * totalDays) / cigarettesPerPack).ceil();

    return packs * packPrice;
  }

  // 平均每天花費
  int get dailyCost {
    return (startCount / cigarettesPerPack * packPrice).round();
  }

  // 完成後節省
  int get saving {
    return totalCost;
  }
}
