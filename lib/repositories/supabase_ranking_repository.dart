import '../models/ranking_model.dart';
import '../services/supabase_ranking_service.dart';

class SupabaseRankingRepository {
  Future<List<RankingModel>> getRankings() async {
    final data = await SupabaseRankingService.getRankings();
    return data.map((e) => RankingModel.fromJson(e)).toList();
  }

  Future<void> updateRanking(RankingModel ranking) async {
    await SupabaseRankingService.updateRanking(
      userId: ranking.userId,
      nickname: ranking.nickname,
      quitDays: ranking.quitDays,
      savedMoney: ranking.savedMoney,
      achievementScore: ranking.achievementScore,
      communityScore: ranking.communityScore,
      totalScore: ranking.totalScore,
    );
  }

  Future<void> deleteRanking(String userId) async {
    await SupabaseRankingService.deleteRanking(userId);
  }
}
