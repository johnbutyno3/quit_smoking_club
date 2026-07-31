class RankingModel {
  final String userId;
  final String nickname;
  final int quitDays;
  final int savedMoney;
  final int achievementScore;
  final int communityScore;
  final int totalScore;

  const RankingModel({
    required this.userId,
    required this.nickname,
    required this.quitDays,
    required this.savedMoney,
    required this.achievementScore,
    required this.communityScore,
    required this.totalScore,
  });

  factory RankingModel.fromJson(Map<String, dynamic> json) {
    return RankingModel(
      userId: json['user_id'] ?? '',
      nickname: json['nickname'] ?? '',
      quitDays: json['quit_days'] ?? 0,
      savedMoney: json['saved_money'] ?? 0,
      achievementScore: json['achievement_score'] ?? 0,
      communityScore: json['community_score'] ?? 0,
      totalScore: json['total_score'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'nickname': nickname,
      'quit_days': quitDays,
      'saved_money': savedMoney,
      'achievement_score': achievementScore,
      'community_score': communityScore,
      'total_score': totalScore,
    };
  }
}
