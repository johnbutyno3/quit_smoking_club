import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/forum_post.dart';

class ForumService {
  static const String _collection = 'forum_posts';

  final FirebaseFirestore _firestore;

  ForumService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<ForumPost>> fetchPosts() async {
    final query = await _firestore
        .collection(_collection)
        .orderBy('created_at', descending: true)
        .get();

    return query.docs.map(ForumPost.fromDocument).toList();
  }

  Future<void> addPost(ForumPost post) async {
    await _firestore.collection(_collection).add(post.toJson());
  }

  Future<void> likePost(String postId) async {
    final ref = _firestore.collection(_collection).doc(postId);
    await ref.update({'likes': FieldValue.increment(1)});
  }

  Future<void> giftPost(String postId) async {
    final ref = _firestore.collection(_collection).doc(postId);
    await ref.update({'gifts': FieldValue.increment(1)});
  }
}
