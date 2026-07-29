import '../../models/ranking_model.dart';
import '../../repositories/ranking_repository.dart';

class GetRankingsUseCase {
  final RankingRepository repository;

  GetRankingsUseCase(this.repository);

  Future<List<RankingModel>> execute() {
    return repository.getRankings();
  }
}
