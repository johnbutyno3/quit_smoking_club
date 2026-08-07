import '../models/ranking_model.dart';
import 'supabase_ranking_repository.dart';

class RankingRepository {
  final SupabaseRankingRepository _svc;

  RankingRepository({SupabaseRankingRepository? svc})
    : _svc = svc ?? SupabaseRankingRepository();

  Future<List<RankingModel>> getRankings() => _svc.getRankings();

  Future<void> updateRanking(RankingModel ranking) =>
      _svc.updateRanking(ranking);

  Future<void> deleteRanking(String userId) => _svc.deleteRanking(userId);
}
