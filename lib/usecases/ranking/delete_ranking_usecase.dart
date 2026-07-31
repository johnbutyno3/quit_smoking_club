import '../../repositories/ranking_repository.dart';

class DeleteRankingUseCase {
  final RankingRepository repository;

  DeleteRankingUseCase(this.repository);

  Future<void> execute(String userId) {
    return repository.deleteRanking(userId);
  }
}
