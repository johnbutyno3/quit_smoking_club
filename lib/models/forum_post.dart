import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory ForumPost.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ForumPost(
      id: doc.id,
      name: data['name']?.toString() ?? '匿名朋友',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      content: data['content']?.toString() ?? '',
      likes: (data['likes'] as int?) ?? 0,
      gifts: (data['gifts'] as int?) ?? 0,
      isSOS: (data['isSOS'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'created_at': Timestamp.fromDate(createdAt),
      'content': content,
      'likes': likes,
      'gifts': gifts,
      'isSOS': isSOS,
    };
  }
}
