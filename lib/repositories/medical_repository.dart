import 'content/content_repository.dart';
import '../models/content/content_item.dart';
import '../models/medical/medical_article.dart';

class MedicalRepository {
  MedicalRepository({ContentRepository? contentRepository})
    : _contentRepository = contentRepository ?? ContentRepository();

  final ContentRepository _contentRepository;

  Future<List<MedicalArticle>> getMedicalArticles() async {
    final items = await _contentRepository.getMedicalContents();
    return items.map(_toMedicalArticle).toList(growable: false);
  }

  MedicalArticle _toMedicalArticle(ContentItem item) {
    final resolvedId = item.id.isNotEmpty ? item.id : item.uniqueId;
    return MedicalArticle(
      id: resolvedId,
      title: item.title,
      summary: item.content,
      category: item.category.name,
      language: item.language,
      body: item.content,
      coverImage: item.link,
      isVip: false,
    );
  }
}
