class CoinTransaction {
  final String id;
  final int amount; // 正數=增加，負數=消耗
  final String reason;
  final DateTime createdAt;

  CoinTransaction({
    required this.id,
    required this.amount,
    required this.reason,
    required this.createdAt,
  });
}
