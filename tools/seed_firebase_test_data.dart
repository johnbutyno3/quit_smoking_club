import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:quit_smoking_club/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final docId = 'Medical|all|Firebase Test Item';
  final data = {
    'category': 'Medical',
    'language': 'all',
    'title': 'Firebase Test Item',
    'content': 'This item was created to verify Firebase connectivity.',
    'link': 'https://firebase.google.com',
    'unique_id': docId,
  };

  await FirebaseFirestore.instance
      .collection('content_items')
      .doc(docId)
      .set(data);

  final snapshot = await FirebaseFirestore.instance
      .collection('content_items')
      .doc(docId)
      .get();

  if (!snapshot.exists) {
    throw Exception('Seeded document was not found after write.');
  }

  print('✅ Firebase seed completed.');
  print(snapshot.data());
}
