class MedicalArticle {
  final String id;
  final String title;
  final String summary;
  final String category;
  final String language;
  final String body;
  final String coverImage;
  final bool isVip;

  const MedicalArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.language,
    required this.body,
    required this.coverImage,
    required this.isVip,
  });
}
