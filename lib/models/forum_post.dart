class ForumPost {
  final String id;
  final String name;
  final DateTime createdAt;
  final String content;
  final int likes;
  final int gifts;
  final bool isSOS;

  const ForumPost({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.content,
    required this.likes,
    required this.gifts,
    required this.isSOS,
  });

  ForumPost copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    String? content,
    int? likes,
    int? gifts,
    bool? isSOS,
  }) {
    return ForumPost(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      content: content ?? this.content,
      likes: likes ?? this.likes,
      gifts: gifts ?? this.gifts,
      isSOS: isSOS ?? this.isSOS,
    );
  }

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: json['id']?.toString() ?? '',
      name: json['nickname']?.toString() ?? json['name']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      content: json['content']?.toString() ?? '',
      likes: json['like_count'] ?? json['likes'] ?? 0,
      gifts: json['gifts'] ?? 0,
      isSOS:
          json['is_sos'] == true ||
          json['isSOS'] == true ||
          json['category'] == '菸癮犯了',
    );
  }
}
