import '../../models/ranking_model.dart';
import '../../repositories/ranking_repository.dart';

class UpdateRankingUseCase {
  final RankingRepository repository;

  UpdateRankingUseCase(this.repository);

  Future<void> execute(RankingModel ranking) {
    return repository.updateRanking(ranking);
  }
}
