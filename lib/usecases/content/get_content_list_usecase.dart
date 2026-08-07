import '../../models/content/content_category.dart';
import '../../models/content/content_item.dart';
import '../../repositories/content/content_repository.dart';

class GetContentListUseCase {
  final ContentRepository _repository;

  GetContentListUseCase({ContentRepository? repository})
    : _repository = repository ?? ContentRepository();

  Future<List<ContentItem>> execute({
    String? language,
    ContentCategory? category,
  }) async {
    return _repository.getContents(language: language, category: category);
  }
}
