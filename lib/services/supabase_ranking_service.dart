import 'supabase_service.dart';

class SupabaseRankingService {
  static Future<List<Map<String, dynamic>>> getRankings() async {
    final response = await SupabaseService.client
        .from('rankings')
        .select()
        .order('total_score', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> updateRanking({
    required String userId,
    required String nickname,
    required int quitDays,
    required int savedMoney,
    required int achievementScore,
    required int communityScore,
    required int totalScore,
  }) async {
    await SupabaseService.client.from('rankings').upsert({
      'user_id': userId,
      'nickname': nickname,
      'quit_days': quitDays,
      'saved_money': savedMoney,
      'achievement_score': achievementScore,
      'community_score': communityScore,
      'total_score': totalScore,
    });
  }

  static Future<void> deleteRanking(String userId) async {
    await SupabaseService.client
        .from('rankings')
        .delete()
        .eq('user_id', userId);
  }
}
