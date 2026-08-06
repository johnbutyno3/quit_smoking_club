// Model for forum posts

class ForumPost {
  final String id;
  final String userId;
  final String nickname;
  final String title;
  final String category;
  final String content;
  final DateTime createdAt;
  final int likes;
  final int gifts;
  final bool isSOS;

  const ForumPost({
    required this.id,
    required this.userId,
    String? nickname,
    String? name,
    required this.title,
    required this.category,
    required this.content,
    required this.createdAt,
    this.likes = 0,
    this.gifts = 0,
    this.isSOS = false,
  }) : nickname = nickname ?? name ?? '';

  // 向下相容：舊程式呼叫 `post.name` 或使用 `ForumPost(name: ...)` 時可正常運作
  String get name => nickname;

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      // 向下相容：有些舊資料使用欄位 `name`
      nickname: json['nickname'] ?? json['name'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      likes: json['likes'] ?? 0,
      gifts: json['gifts'] ?? 0,
      isSOS: json['is_sos'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nickname': nickname,
      'title': title,
      'category': category,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'likes': likes,
      'gifts': gifts,
      'is_sos': isSOS,
    };
  }

  ForumPost copyWith({
    String? id,
    String? userId,
    String? nickname,
    String? title,
    String? category,
    String? content,
    DateTime? createdAt,
    int? likes,
    int? gifts,
    bool? isSOS,
  }) {
    return ForumPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      title: title ?? this.title,
      category: category ?? this.category,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      gifts: gifts ?? this.gifts,
      isSOS: isSOS ?? this.isSOS,
    );
  }
}
