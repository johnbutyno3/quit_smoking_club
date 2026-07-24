class CoinTransaction {
  final String id;
  final int amount;
  final String reason;
  final DateTime createdAt;

  CoinTransaction({
    required this.id,
    required this.amount,
    required this.reason,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'reason': reason,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CoinTransaction.fromJson(Map<String, dynamic> json) {
    return CoinTransaction(
      id: json['id'],
      amount: json['amount'],
      reason: json['reason'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
