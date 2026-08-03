import 'content_category.dart';

class ContentItem {
  final String id;
  final String title;
  final ContentCategory category;
  final String language;
  final String content;
  final String link;
  final String author;
  final int downloadCoinCost;

  const ContentItem({
    required this.id,
    required this.title,
    required this.category,
    required this.language,
    required this.content,
    required this.link,
    this.author = '',
    this.downloadCoinCost = 0,
  });

  String get uniqueId =>
      id.isNotEmpty ? id : '${category.name}|$language|$title';

  factory ContentItem.fromMap(Map<String, dynamic> json) {
    final rawLanguage = json['language']?.toString().trim().toLowerCase();
    return ContentItem(
      id: json['unique_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: ContentCategoryParser.fromValue(json['category']?.toString()),
      language: (rawLanguage == null || rawLanguage.isEmpty)
          ? 'all'
          : rawLanguage,
      content:
          json['content']?.toString() ?? json['description']?.toString() ?? '',
      link: json['link']?.toString() ?? json['url']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      downloadCoinCost:
          ((json['download_coin_cost'] ?? json['downloadCoinCost']) as num?)
              ?.toInt() ??
          0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'unique_id': uniqueId,
      'title': title,
      'category': category.name,
      'language': language,
      'content': content,
      'link': link,
      'author': author,
      'download_coin_cost': downloadCoinCost,
    };
  }
}
